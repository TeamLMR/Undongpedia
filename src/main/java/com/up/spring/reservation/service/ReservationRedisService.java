package com.up.spring.reservation.service;


import com.up.spring.course.model.service.CourseScheduleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
@RequiredArgsConstructor
public class ReservationRedisService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final RedissonClient redissonClient;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final CourseScheduleService courseScheduleService;

    //접속자 수 계산
    public void updateHeartBeat(Long courseSeq, int memberNo) {
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long currentTime = System.currentTimeMillis();

        redisTemplate.opsForZSet().add(heartBeatKey, memberNo, currentTime);
        redisTemplate.expire(heartBeatKey, Duration.ofMinutes(5));

        log.debug("하트비트 : {}, {}, {}", courseSeq, memberNo, currentTime);
    }

    public Long getActiveMemberCount(Long courseSeq) {
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long oneMinuteAgo = System.currentTimeMillis() - 60 * 1000;

        Long count = redisTemplate.opsForZSet().count(heartBeatKey, oneMinuteAgo, Double.MAX_VALUE);

        log.debug("강의 {}, 사용자 {}", courseSeq, count);
        return count;
    }

    public void cleanUpInactiveMembers(Long courseSeq) {
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long oneMinuteAgo = System.currentTimeMillis() - 60 * 1000;

        Long count = redisTemplate.opsForZSet().removeRangeByScore(heartBeatKey, 0, oneMinuteAgo);

        if (count != null && count > 0) {
            log.info("사용자정리 : {},{}명제거", courseSeq, count);
        }
    }

    public Map<String, Object> getActiveMembers(Long courseSeq) {
        Map<String, Object> result = new HashMap<>();
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long oneMinuteAgo = System.currentTimeMillis() - 60 * 1000;

        Set<Object> activeMembers = redisTemplate.opsForZSet().rangeByScore(heartBeatKey, oneMinuteAgo, Double.MAX_VALUE);

        if (activeMembers != null && !activeMembers.isEmpty()) {
            result.put("activeUsers", activeMembers);
            result.put("activeUserCount", activeMembers.size());

            log.debug("코스 :{}, 사용자 수 : {}", courseSeq, activeMembers.size());
        }

        return result;

    }


    public boolean shouldActivateQueue(Long courseSeq) {
        int maxMember = 20;

        Long activeMemberCount = getActiveMemberCount(courseSeq);
        boolean result = activeMemberCount >= maxMember;

        log.info("강의 {}, 원하는접속자{} ,현재접속자 {}, 대기열활성화 여부{}", courseSeq, maxMember, activeMemberCount, result);

        return result;
    }


    //대기열
    public Map<String, Object> addToQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        long timestamp = System.currentTimeMillis();

        Boolean added = redisTemplate.opsForZSet().add(queueKey, memberNo, timestamp);
        redisTemplate.expire(queueKey, Duration.ofMinutes(15));

        if (added != null && !added) {
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
            return createResponse(true, "이미 대기열에 있습니다", position != null ? position + 1 : 0);
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);


        Map<String, Object> eventData = new HashMap<>();
        eventData.put("courseSeq", courseSeq);
        eventData.put("memberNo", memberNo);
        eventData.put("position", position);
        eventData.put("totalInQueue", totalInQueue);
        eventData.put("timestamp", timestamp);

        publishEvent("QUEUE_ENTERED", eventData);

        log.info("대기열 입장 강의{}, 사용자{}, 순서{}, 전체 대기열{}", courseSeq, memberNo, position, totalInQueue);

        return createResponse(true, "대기열에 입장했습니다.", position != null ? position + 1 : 0);
    }


    public Map<String, Object> getQueuePosition(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;

        Double score = redisTemplate.opsForZSet().score(queueKey, memberNo);
        if (score == null) {
            return createResponse(false, "대기열에 없습니다.");
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);

        Map<String, Object> queueInfo = new HashMap<>();
        queueInfo.put("position", position != null ? position + 1 : 0);
        queueInfo.put("totalInQueue", totalInQueue);
        queueInfo.put("estimateWaitTime", (position != null ? position : 0) * 30);
        queueInfo.put("joinAt", new Date(score.longValue()));

        // 🎯 실제 순서 정보가 포함된 메시지 생성
        String message = String.format("대기열 %d번째 (전체 %d명 대기중, 예상 대기시간 %d초)", 
            position != null ? position + 1 : 0, 
            totalInQueue, 
            (position != null ? position : 0) * 30);

        return createResponse(true, message, queueInfo);

    }


    public String processNextInQueue(Long courseSeq) {
        String queueKey = "queue:course:" + courseSeq;

        Set<Object> firstMember = redisTemplate.opsForZSet().range(queueKey, 0, 0);

        if (firstMember == null || firstMember.isEmpty()) {
            return null;
        }
        String nextMemberNo = (String) firstMember.iterator().next();

        redisTemplate.opsForZSet().remove(queueKey, nextMemberNo);

        Map<String, Object> eventData = new HashMap<>();
        eventData.put("courseSeq", courseSeq);
        eventData.put("memberNo", nextMemberNo);
        publishEvent("RESERVATION_TURN", eventData);

        log.info("예약 순서 도착 : 강의{}, 사용자{}", courseSeq, nextMemberNo);

        return nextMemberNo;
    }

    public void removeFromQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        Long removed = redisTemplate.opsForZSet().remove(queueKey, memberNo);
        if (removed != null && removed > 0) {
            log.info("대기열제거 : 강의{},사용자{}", courseSeq, removed);
        }
    }

    /**
     * 대기열 전체 조회 (관리자용)
     */
    //추후 사용하게 되면 주석 해제
//    public Map<String, Object> getQueueStatus(Long courseSeq) {
//        String queueKey = "queue:course:" + courseSeq;
//
//        // 전체 대기열 조회 (순서대로)
//        Set<Object> queueMembers = redisTemplate.opsForZSet().range(queueKey, 0, -1);
//        Long totalCount = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);
//
//        // 상위 10명의 상세 정보
//        Set<ZSetOperations.TypedTuple<Object>> topMembers = redisTemplate.opsForZSet().rangeWithScores(queueKey, 0, 9);
//
//        List<Map<String, Object>> topMembersList = new ArrayList<>();
//        int position = 1;
//        for (ZSetOperations.TypedTuple<Object> member : topMembers) {
//            Map<String, Object> memberInfo = new HashMap<>();
//            memberInfo.put("userId", member.getValue());
//            memberInfo.put("position", position++);
//            memberInfo.put("joinedAt", new Date(member.getScore().longValue()));
//            memberInfo.put("waitingTime", System.currentTimeMillis() - member.getScore().longValue());
//            topMembersList.add(memberInfo);
//        }
//
//        Map<String, Object> status = new HashMap<>();
//        status.put("totalCount", totalCount);
//        status.put("topMembers", topMembersList);
//        status.put("allMembers", queueMembers);
//
//        return createResponse(true, "대기열 상태", status);
//    }
    public void cleanupOldQueueMembers(Long courseSeq, long maxWaitTimeMinutes) {
        String queueKey = "queue:course:" + courseSeq;
        long cutoffTime = System.currentTimeMillis() - maxWaitTimeMinutes * 60 * 1000;

        Long removedCount = redisTemplate.opsForZSet().removeRangeByScore(queueKey, 0, cutoffTime);
        if (removedCount != null && removedCount > 0) {
            log.info("오래된 대기열 사용자 정리 : 강의{}, {}명 제거", courseSeq, removedCount);
        }
    }

    public boolean isInQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        Double score = redisTemplate.opsForZSet().score(queueKey, memberNo);
        return score != null;
    }

    public boolean isFirstInQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        Long rank = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        return rank != null && rank == 0;
    }

    public Map<String, Object> processReservationRequest(Map<String, Object> data) {
        Long courseSeq = ((Number) data.get("courseSeq")).longValue();
        int memberNo = ((Number) data.get("memberNo")).intValue();

        updateHeartBeat(courseSeq, memberNo);

        cleanUpInactiveMembers(courseSeq);

        if (shouldActivateQueue(courseSeq)) {

            if (!isInQueue(courseSeq, memberNo)) {

                return addToQueue(courseSeq, memberNo);

            } else if (isFirstInQueue(courseSeq, memberNo)) {
                removeFromQueue(courseSeq, memberNo);
                return createTemporaryReservation(data);
            } else {
                return getQueuePosition(courseSeq, memberNo);
            }
        } else {
            return createTemporaryReservation(data);
        }
    }

    public Map<String, Object> createTemporaryReservation(Map<String, Object> data) {
        Long scheduleId = ((Number) data.get("scheduleId")).longValue();
        int memberNo = ((Number) data.get("memberNo")).intValue();
        Long courseSeq = ((Number) data.get("courseSeq")).longValue();

        String lockKey = "lock:schedule:" + scheduleId;
        RLock lock = redissonClient.getFairLock(lockKey);

        try {
            if (lock.tryLock(10, 5, TimeUnit.SECONDS)) {
                String seatKey = "temp_occupied:" + scheduleId;
                if (redisTemplate.hasKey(seatKey)) {
                    return createResponse(false, "다른 사용자가 예약 진행 중입니다.");
                }

                if (!courseScheduleService.isAvailable(scheduleId)) {
                    return createResponse(false, "좌석이 마감되었습니다.");
                }
                String tempReservationId="TEMP_"+System.currentTimeMillis()+"_"+memberNo;

                Map<String, Object> tempReservation = new HashMap<>();
                tempReservation.put("tempReservationId", tempReservationId);
                tempReservation.put("courseSeq", courseSeq);
                tempReservation.put("memberNo", memberNo);
                tempReservation.put("scheduleId", scheduleId);
                tempReservation.put("status","TEMP_RESERVED");
                tempReservation.put("createdAt", LocalDateTime.now().toString());
                tempReservation.put("expiresAt",LocalDateTime.now().plusMinutes(10).toString());


                String tempKey="temp_reservation:" + tempReservationId;

                redisTemplate.opsForValue().set(tempKey, tempReservation,Duration.ofMinutes(10));

                redisTemplate.opsForValue().set(seatKey, tempReservationId, Duration.ofMinutes(10));

                //카프카 이벤트
                publishEvent("TEMP_RESERVATION_CREATED", tempReservation);

                log.info("임시예약 완료 사용자{}, 임시예약{}, 스케쥴{}", memberNo, tempReservationId,scheduleId);

                Map<String, Object> responseData = new HashMap<>();
                responseData.put("tempReservationId", tempReservationId);
                responseData.put("expiresAt", tempReservation.get("expiresAt"));
                responseData.put("remainingSeconds",60*10);


                int availableSeats = courseScheduleService.getAvailableSeats(scheduleId);
                log.info("스케쥴{}, 남은자리{}", scheduleId, availableSeats);

                return createResponse(true,"결제를 진행해주세요 10분 간 유지됩니다.", responseData);
            }
        } catch (InterruptedException e) {
            log.error("임시예약 오류", e);
        }finally {
            if(lock.isHeldByCurrentThread()) {
                lock.unlock();
            }
        }
        return createResponse(false,"예약이 실패했습니다.");
    }

    private void publishEvent(String eventType, Map<String, Object> data) {
        Map<String, Object> event = new HashMap<>();
        event.put("eventType", eventType);
        event.put("timestamp", LocalDateTime.now().toString());
        event.putAll(data);

        kafkaTemplate.send("reservation-events", event);
        log.debug("이벤트 발행: {}", eventType);
    }

    private Map<String, Object> createResponse(boolean success, String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("message", message);
        return response;
    }

    private Map<String, Object> createResponse(boolean success, String message, Object data) {
        Map<String, Object> response = createResponse(success, message);
        response.put("data", data);
        return response;
    }
}
