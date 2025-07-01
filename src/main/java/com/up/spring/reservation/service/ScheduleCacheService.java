package com.up.spring.reservation.service;


import com.up.spring.course.model.dto.CourseSchedule;
import com.up.spring.course.model.service.CourseScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScheduleCacheService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final CourseScheduleService courseScheduleService;

    private static final String SCHEDULE_KEY_PREFIX = "schedule:";
    private static final String SCHEDULE_SEATS_PREFIX = "schedule:seats:";
    private static final String COURSE_SCHEDULES_PREFIX = "course:schedules:";

    private static final long SCHEDULE_TTL = 60 * 60;
    private static final long SEATS_TTL = 60 * 5;
    private static final long COURSE_SCHEDULES_TTL = 60 * 30;


    public Integer getAvailableSeats(Long scheduleId) {
        String cacheKey = SCHEDULE_SEATS_PREFIX + scheduleId;

        Integer cachedSeats = (Integer) redisTemplate.opsForValue().get(cacheKey);
        if (cachedSeats != null) {
            return cachedSeats;
        }

        int availableSeats = courseScheduleService.getAvailableSeats(scheduleId);

        redisTemplate.opsForValue().set(cacheKey, availableSeats, SEATS_TTL, TimeUnit.SECONDS);

        return availableSeats;
    }

    public void cacheSchedule(CourseSchedule schedule) {
        if (schedule == null) {
            return;
        }
        String cacheKey = SCHEDULE_KEY_PREFIX + schedule.getScheduleId();
        redisTemplate.opsForValue().set(cacheKey, schedule, SCHEDULE_TTL, TimeUnit.SECONDS);
    }

    public void updateSeatsCount(Long scheduleId, int change) {
        String cacheKey = SCHEDULE_SEATS_PREFIX + scheduleId;

        Integer currentSeats = (Integer) redisTemplate.opsForValue().get(cacheKey);
        if (currentSeats != null) {
            int newSeats = Math.max(0, currentSeats + change);
            redisTemplate.opsForValue().set(cacheKey, newSeats, SEATS_TTL, TimeUnit.SECONDS);
        } else {
            int dbSeats = courseScheduleService.getAvailableSeats(scheduleId);
            int newSeats = Math.max(0, dbSeats + change);
            redisTemplate.opsForValue().set(cacheKey, newSeats, SEATS_TTL, TimeUnit.SECONDS);
        }

    }

    public List<CourseSchedule> getCourseSchedules(Long courseSeq) {
        String cacheKey = COURSE_SCHEDULES_PREFIX + courseSeq;

        List<CourseSchedule> courseSchedules = (List<CourseSchedule>) redisTemplate.opsForValue().get(cacheKey);
        if (courseSchedules != null) {
            return courseSchedules;
        }

        List<CourseSchedule> schedules = courseScheduleService.searchScheduleByCourseSeq(courseSeq);
        redisTemplate.opsForValue().set(cacheKey, schedules, COURSE_SCHEDULES_TTL, TimeUnit.SECONDS);
        return schedules;
    }

    public void invalidateCourseSchedulesCache(Long courseSeq) {
        String cacheKey = COURSE_SCHEDULES_PREFIX + courseSeq;
        String availableKey = COURSE_SCHEDULES_PREFIX + "available:" + courseSeq;

        redisTemplate.delete(cacheKey);
        redisTemplate.delete(availableKey);
    }

    public void warmUpCache(Long courseSeq) {
        List<CourseSchedule> allSchedules = courseScheduleService.searchScheduleByCourseSeq(courseSeq);
        if (allSchedules != null && !allSchedules.isEmpty()) {
            String courseKey = COURSE_SCHEDULES_PREFIX + courseSeq;
            redisTemplate.opsForValue().set(courseKey, allSchedules, SEATS_TTL, TimeUnit.SECONDS);

            List<CourseSchedule> availableSchedules = courseScheduleService.searchAvailableSchedules(courseSeq);
            if (availableSchedules != null && availableSchedules.isEmpty()) {
                String availableKey = COURSE_SCHEDULES_PREFIX + "available:" + courseSeq;
                redisTemplate.opsForValue().set(availableKey, availableSchedules, SEATS_TTL, TimeUnit.SECONDS);
            }

            for (CourseSchedule schedule : allSchedules) {
                cacheSchedule(schedule);

                int seats = courseScheduleService.getAvailableSeats(schedule.getScheduleId());
                String seatKey = SCHEDULE_SEATS_PREFIX + schedule.getScheduleId();
                redisTemplate.opsForValue().set(seatKey, seats, SEATS_TTL, TimeUnit.SECONDS);
            }

            log.info("캐시 웜업 완료 : 코스{}, 스케쥴 {} 개", courseSeq, allSchedules.size());


        }
    }

    public void evictExpiredCache() {
        Set<String> scheduleKeys = redisTemplate.keys(SCHEDULE_KEY_PREFIX + "*");
        Set<String> seatKeys = redisTemplate.keys(SCHEDULE_SEATS_PREFIX + "*");
        Set<String> courseKeys = redisTemplate.keys(COURSE_SCHEDULES_PREFIX + "*");

        int totalDeleted = 0;
        for (String key : scheduleKeys) {
            Long ttl = redisTemplate.getExpire(key);
            if (ttl != null && ttl <= 0) {
                redisTemplate.delete(key);
                totalDeleted++;
            }
        }

        for (String key : seatKeys) {
            Long ttl = redisTemplate.getExpire(key);
            if (ttl != null && ttl <= 0) {
                redisTemplate.delete(key);
                totalDeleted++;
            }
        }

        for (String key : courseKeys) {
            Long ttl = redisTemplate.getExpire(key);
            if (ttl != null && ttl <= 0) {
                redisTemplate.delete(key);
                totalDeleted++;
            }
        }
    }

    public void onReservationSuccess(Long scheduleId, Long courseSeq) {
        updateSeatsCount(scheduleId, -1);

        invalidateCourseSchedulesCache(courseSeq);
    }

    public void onReservationCancel(Long ScheduleId, Long courseSeq) {
        updateSeatsCount(ScheduleId, 1);

        invalidateCourseSchedulesCache(courseSeq);
    }

}
