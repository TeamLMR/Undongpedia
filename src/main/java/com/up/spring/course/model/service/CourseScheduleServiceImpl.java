package com.up.spring.course.model.service;

import com.up.spring.course.model.dao.CourseScheduleDao;
import com.up.spring.course.model.dto.CourseSchedule;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional
@RequiredArgsConstructor
@Slf4j
public class CourseScheduleServiceImpl implements CourseScheduleService {

    private final CourseScheduleDao courseScheduleDao;
    private final SqlSession sqlSession;

    @Override
    public List<CourseSchedule> searchScheduleByCourseSeq(long courseSeq) {
        try {
            List<CourseSchedule> schedules = courseScheduleDao.searchScheduleByCourseSeq(sqlSession, courseSeq);
            log.info("강의 스케줄 조회 성공 - courseSeq: {}, 총 {}개", courseSeq, schedules.size());
            return schedules;
        } catch (Exception e) {
            log.error("강의 스케줄 조회 중 오류 발생 - courseSeq: {}", courseSeq, e);
            throw e;
        }
    }

    @Override
    public List<CourseSchedule> searchScheduleByDate(long courseSeq, LocalDate date) {
        try {
            log.info("🔍 === searchScheduleByDate 호출 ===");
            log.info("입력 파라미터 - courseSeq: {}, date: {}", courseSeq, date);

            Map<String, Object> params = new HashMap<>();
            params.put("courseSeq", courseSeq);

            Date sqlDate = Date.valueOf(date); // LocalDate를 SQL Date로 변환
            params.put("courseDate", sqlDate);

            log.info("변환된 SQL Date: {}", sqlDate);
            log.info("MyBatis 파라미터 맵: {}", params);

            List<CourseSchedule> schedules = courseScheduleDao.searchScheduleByDate(sqlSession, params);
            log.info("날짜별 스케줄 조회 완료 - courseSeq: {}, date: {}, 총 {}개", courseSeq, date, schedules.size());

            // 결과가 없을 때 추가 디버깅
            if (schedules.isEmpty()) {
                log.warn("⚠️ 해당 날짜에 스케줄이 없습니다. 전체 스케줄을 조회해서 확인합니다.");
                List<CourseSchedule> allSchedules = courseScheduleDao.searchScheduleByCourseSeq(sqlSession, courseSeq);
                log.info("해당 강의의 전체 스케줄 수: {}", allSchedules.size());

                if (!allSchedules.isEmpty()) {
                    log.info("📅 현재 데이터베이스에 있는 스케줄 날짜들:");
                    for (CourseSchedule schedule : allSchedules) {
                        log.info("  - 스케줄 ID: {}, 날짜: {}, 시간: {} ~ {}",
                                schedule.getScheduleId(),
                                schedule.getCourseDate(),
                                schedule.getCourseStartTime(),
                                schedule.getCourseEndTime());
                    }

                    log.info("🔍 검색하려던 날짜와 비교:");
                    log.info("  - 검색 날짜: {} (타입: {})", sqlDate, sqlDate.getClass().getSimpleName());
                    log.info("  - LocalDate: {} (타입: {})", date, date.getClass().getSimpleName());
                }
            }

            return schedules;
        } catch (Exception e) {
            log.error("날짜별 스케줄 조회 중 오류 발생 - courseSeq: {}, date: {}", courseSeq, date, e);
            throw e;
        }
    }

    @Override
    public List<CourseSchedule> searchAvailableSchedules(long courseSeq) {
        try {
            List<CourseSchedule> schedules = courseScheduleDao.searchAvailableSchedules(sqlSession, courseSeq);
            log.info("예약 가능한 스케줄 조회 성공 - courseSeq: {}, 총 {}개", courseSeq, schedules.size());
            return schedules;
        } catch (Exception e) {
            log.error("예약 가능한 스케줄 조회 중 오류 발생 - courseSeq: {}", courseSeq, e);
            throw e;
        }
    }

    @Override
    public int searchTotalAvailableSchedules(long courseSeq) {
        return courseScheduleDao.searchTotalAvailableSchedules(sqlSession, courseSeq);
    }

    @Override
    public boolean isAvailable(long scheduleId) {
        Integer availableSeats = courseScheduleDao.getAvailableSeats(sqlSession, scheduleId);
        boolean available = availableSeats != null && availableSeats > 0;
        log.info("스케줄{}, 예약가능여부{}, 남은 자리{}",scheduleId,available,availableSeats);
        return available;
    }

    @Override
    public int getAvailableSeats(long scheduleId) {
        Integer availableSeats = courseScheduleDao.getAvailableSeats(sqlSession, scheduleId);

        return availableSeats != null ? availableSeats : 0;
    }

    @Override
    public boolean reserveSeat(long scheduleId) {
        int result= courseScheduleDao.incrementBookedSeats(sqlSession, scheduleId);
        if(result>0){
            log.info("예약 성공");
            return true;
        }else{
            log.warn("예약실패");
            return false;
        }
    }

    @Override
    public boolean cancelSeat(long scheduleId) {
        int result= courseScheduleDao.decrementBookedSeats(sqlSession, scheduleId);
        if(result>0){
            log.info("취소 성공");
            return true;
        } else{
            log.warn("취소 실패");
            return false;
        }
    }

    @Override
    public int insertSchedule(CourseSchedule schedule) {
        try {
            int result = courseScheduleDao.insertSchedule(sqlSession, schedule);
            log.info("스케줄 등록 성공 - courseSeq: {}, date: {}, time: {}~{}", 
                    schedule.getCourseSeq(), schedule.getCourseDate(), 
                    schedule.getCourseStartTime(), schedule.getCourseEndTime());
            return result;
        } catch (Exception e) {
            log.error("스케줄 등록 중 오류 발생 - courseSeq: {}", schedule.getCourseSeq(), e);
            throw e;
        }
    }
}
