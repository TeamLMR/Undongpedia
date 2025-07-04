package com.up.spring.reservation.service;


import com.up.spring.course.model.service.CourseScheduleService;
import com.up.spring.reservation.websocket.QueueWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.sql.Date;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.ConcurrentHashMap;

@Service
@Slf4j
@RequiredArgsConstructor
public class ReservationRedisService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final RedissonClient redissonClient;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final CourseScheduleService courseScheduleService;
    private final ScheduleCacheService scheduleCacheService;
    
    // WebSocket 핸들러 추가
    private final QueueWebSocketHandler queueWebSocketHandler;

    // 대기열 활성화 임계값 설정 (기본값 5명, 설정 가능)
    @Value("${queue.activation.threshold:5}")
    private int queueActivationThreshold;

    // WebSocket 브로드캐스트 스로틀링을 위한 캐시
    private final Map<String, Long> lastBroadcastTime = new ConcurrentHashMap<>();
    
    @Value("${queue.websocket.throttle.ms:2000}")
    private long broadcastThrottleMs;
    
    @Value("${queue.max.queue.size:1000}")
    private int maxQueueSize;
    
    // 대기열 활성화 체크 캐싱 (30초간 유효)
    private final Map<Long, Boolean> queueActivationCache = new ConcurrentHashMap<>();
    private final Map<Long, Long> queueActivationCacheTime = new ConcurrentHashMap<>();
    private static final long QUEUE_ACTIVATION_CACHE_TTL = 30000; // 30초

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

        // 사용자가 있을 때만 로그 출력
        if (count != null && count > 0) {
            log.debug("활성 사용자 - 강의 {}: {}명", courseSeq, count);
        }
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
        long currentTime = System.currentTimeMillis();
        
        // 캐시 확인 (30초 내 결과가 있으면 재사용)
        Long cacheTime = queueActivationCacheTime.get(courseSeq);
        if (cacheTime != null && (currentTime - cacheTime) < QUEUE_ACTIVATION_CACHE_TTL) {
            Boolean cachedResult = queueActivationCache.get(courseSeq);
            if (cachedResult != null) {
                // 캐시 사용할 때는 로그 출력하지 않음
                return cachedResult;
            }
        }
        
        // 설정 가능한 임계값 사용 (기본 5명)
        Long activeMemberCount = getActiveMemberCount(courseSeq);
        boolean shouldActivate = activeMemberCount >= queueActivationThreshold;

        // 순환 참조 제거 - 활성 강의 등록은 별도로 처리
        if (shouldActivate) {
            // Redis Set에 활성 강의 직접 추가
            redisTemplate.opsForSet().add("active:courses", courseSeq.toString());
            redisTemplate.expire("active:courses", Duration.ofHours(24));
            
            // 활성화될 때만 로그 출력
            log.info("🔥 대기열 활성화 - 강의 {}, 현재인원 {}명 (임계값: {}명)", 
                courseSeq, activeMemberCount, queueActivationThreshold);
        }

        // 결과 캐싱
        queueActivationCache.put(courseSeq, shouldActivate);
        queueActivationCacheTime.put(courseSeq, currentTime);

        // 상태 변화가 있을 때만 로그 출력 (선택사항)
        // log.debug("대기열 상태 체크 - 강의 {}, 현재인원 {}, 활성화 {}", courseSeq, activeMemberCount, shouldActivate);

        return shouldActivate;
    }


    //  코스 레벨 대기열 (대기열 페이지 진입)
    public Map<String, Object> addToCourseQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        long timestamp = System.currentTimeMillis();

        // 대기열 확인
        Double existingScore = redisTemplate.opsForZSet().score(queueKey, memberNo);
        if (existingScore != null) {
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
            Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);
            
            Map<String, Object> queueInfo = new HashMap<>();
            queueInfo.put("position", position != null ? position + 1 : 0);
            queueInfo.put("totalInQueue", totalInQueue);
            queueInfo.put("estimateWaitTime", (position != null ? position : 0) * 30);
            queueInfo.put("queueType", "COURSE");
            
            log.info("이미 코스 대기열에 있음 - 강의{}, 사용자{}, 순서{}/{}",
                courseSeq, memberNo, position + 1, totalInQueue);
            
            return createResponse(true, "이미 대기열에 있습니다. 현재 " + (position + 1) + "번째입니다.", queueInfo);
        }

        // 대기열 크기 확인
        Long currentQueueSize = redisTemplate.opsForZSet().zCard(queueKey);
        if (currentQueueSize != null && currentQueueSize >= maxQueueSize) {
            log.warn("코스 대기열 크기 초과 - 강의: {}, 현재: {}명, 최대: {}명", courseSeq, currentQueueSize, maxQueueSize);
            return createResponse(false, "대기열이 가득찼습니다. 나중에 다시 시도해주세요.");
        }

        // 새로 추가
        Boolean added = redisTemplate.opsForZSet().add(queueKey, memberNo, timestamp);
        redisTemplate.expire(queueKey, Duration.ofMinutes(15));

        if (added == null || !added) {
            // 추가 실패 (동시성 문제로 인한 경우)
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
            return createResponse(true, "대기열 추가 중 충돌 발생", position != null ? position + 1 : 0);
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);

        Map<String, Object> queueInfo = new HashMap<>();
        queueInfo.put("position", position != null ? position + 1 : 0);
        queueInfo.put("totalInQueue", totalInQueue);
        queueInfo.put("estimateWaitTime", (position != null ? position : 0) * 30);
        queueInfo.put("queueType", "COURSE");

        log.info("코스 대기열 입장 - 강의{}, 사용자{}, 순서{}/{}", courseSeq, memberNo, position + 1, totalInQueue);

        return createResponse(true, "코스 대기열에 입장했습니다.", queueInfo);
    }

    // 스케줄 레벨 대기열 (예약 모달용)
    public Map<String, Object> addToScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        long timestamp = System.currentTimeMillis();

        // 이미 대기열에 있는지 먼저 확인
        Double existingScore = redisTemplate.opsForZSet().score(queueKey, memberNo);
        if (existingScore != null) {
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
            Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);
            
            Map<String, Object> queueInfo = new HashMap<>();
            queueInfo.put("position", position != null ? position + 1 : 0);
            queueInfo.put("totalInQueue", totalInQueue);
            queueInfo.put("estimateWaitTime", (position != null ? position : 0) * 30);
            queueInfo.put("queueType", "SCHEDULE");
            queueInfo.put("scheduleId", scheduleId);
            
            log.info("이미 스케줄 대기열에 있음 - 강의{}, 스케줄{}, 사용자{}, 순서{}/{}",
                courseSeq, scheduleId, memberNo, position + 1, totalInQueue);
            
            return createResponse(true, "이미 예약 대기열에 있습니다. 현재 " + (position + 1) + "번째입니다.", queueInfo);
        }

        // 새로 추가
        Boolean added = redisTemplate.opsForZSet().add(queueKey, memberNo, timestamp);
        redisTemplate.expire(queueKey, Duration.ofMinutes(15));

        if (added == null || !added) {
            // 추가 실패 (동시성 문제로 인한 경우)
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
            return createResponse(true, "대기열 추가 중 충돌 발생", position != null ? position + 1 : 0);
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);

        Map<String, Object> queueInfo = new HashMap<>();
        queueInfo.put("position", position != null ? position + 1 : 0);
        queueInfo.put("totalInQueue", totalInQueue);
        queueInfo.put("estimateWaitTime", (position != null ? position : 0) * 30);
        queueInfo.put("queueType", "SCHEDULE");
        queueInfo.put("scheduleId", scheduleId);

        log.info("스케줄 대기열 입장 - 강의{}, 스케줄{}, 사용자{}, 순서{}/{}",
            courseSeq, scheduleId, memberNo, position + 1, totalInQueue);

        // 🔥 첫 번째 순서라면 즉시 임시예약 처리
        if (position != null && position == 0) { // Redis rank는 0부터 시작
            log.info("🎯 첫 번째 순서 즉시 처리 - 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
            // 비동기로 처리하여 응답 지연 방지
            new Thread(() -> {
                try {
                    Thread.sleep(100); // 100ms 후 처리 (Redis 업데이트 완료 대기)
                    processNextInScheduleQueue(courseSeq, scheduleId);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    log.error("첫 번째 순서 즉시 처리 중단", e);
                }
            }).start();
        }

        // WebSocket으로 대기열 업데이트 전송
        broadcastQueueUpdate(courseSeq, scheduleId);

        return createResponse(true, "예약 대기열에 입장했습니다.", queueInfo);
    }

    // 코스 대기열 조회
    public Map<String, Object> getCourseQueuePosition(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        return getQueuePositionInternal(queueKey, memberNo, "COURSE");
    }

    // 스케줄 대기열 조회
    public Map<String, Object> getScheduleQueuePosition(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        return getQueuePositionInternal(queueKey, memberNo, "SCHEDULE");
    }

    // 내부 대기열 조회 메서드
    private Map<String, Object> getQueuePositionInternal(String queueKey, int memberNo, String queueType) {
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
        queueInfo.put("queueType", queueType);

        return createResponse(true, "대기열 순서.", queueInfo);
    }

    // 코스 대기열에서 제거
    public void removeFromCourseQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        Long removed = redisTemplate.opsForZSet().remove(queueKey, memberNo);
        if (removed != null && removed > 0) {
            log.info("코스 대기열 제거 - 강의{}, 사용자{}", courseSeq, memberNo);
            
            // 대기열 통과 토큰 생성 (5분간 유효) - 기존 토큰이 없을 때만
            String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
            String existingToken = (String) redisTemplate.opsForValue().get(accessToken);
            
            if (!"PASSED".equals(existingToken)) {
                redisTemplate.opsForValue().set(accessToken, "PASSED", Duration.ofMinutes(5));
                log.info("대기열 통과 토큰 생성: {}", accessToken);
            } else {
                log.debug("대기열 통과 토큰이 이미 존재함: {}", accessToken);
            }
            
            // 남은 사용자들에게 실시간 대기열 업데이트 전송 (코스 레벨)
            broadcastCourseQueueUpdate(courseSeq);
        }
    }

    // 스케줄 대기열에서 제거
    public void removeFromScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        Long removed = redisTemplate.opsForZSet().remove(queueKey, memberNo);
        if (removed != null && removed > 0) {
            log.info("스케줄 대기열 제거 - 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
            
            // 🔥 즉시 다음 첫 번째 사용자 처리
            processNextInScheduleQueue(courseSeq, scheduleId);
            
            // 남은 사용자들에게 실시간 대기열 업데이트 전송
            broadcastQueueUpdate(courseSeq, scheduleId);
        }
    }
    
    // 🔥 스케줄 대기열의 다음 첫 번째 사용자를 즉시 처리
    public void processNextInScheduleQueue(Long courseSeq, Long scheduleId) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        
        // 첫 번째 대기자 조회
        Set<Object> firstMemberSet = redisTemplate.opsForZSet().range(queueKey, 0, 0);
        if (firstMemberSet == null || firstMemberSet.isEmpty()) {
            log.debug("스케줄 대기열이 비어있음 - 강의{}, 스케줄{}", courseSeq, scheduleId);
            return;
        }
        
        Object firstMemberObj = firstMemberSet.iterator().next();
        int memberNo;
        try {
            if (firstMemberObj instanceof String) {
                memberNo = Integer.parseInt((String) firstMemberObj);
            } else if (firstMemberObj instanceof Number) {
                memberNo = ((Number) firstMemberObj).intValue();
            } else {
                log.warn("유효하지 않은 memberNo 형식: {}", firstMemberObj);
                return;
            }
        } catch (NumberFormatException e) {
            log.error("memberNo 변환 실패: {}", firstMemberObj, e);
            return;
        }
        
        log.info("🎯 즉시 임시예약 처리 시작 - 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
        
        // 임시예약 데이터 생성
        Map<String, Object> reservationData = new HashMap<>();
        reservationData.put("courseSeq", courseSeq);
        reservationData.put("scheduleId", scheduleId);
        reservationData.put("memberNo", memberNo);
        
        // 임시예약 시도
        Map<String, Object> tempResult = createTemporaryReservation(reservationData);
        
        if (tempResult.get("success") != null && (Boolean) tempResult.get("success")) {
            // 🔥 임시예약 성공 - 대기열에서 제거
            Long removed = redisTemplate.opsForZSet().remove(queueKey, firstMemberObj);
            if (removed != null && removed > 0) {
                log.info("✅ 즉시 임시예약 성공 - 대기열에서 제거: 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
                
                // WebSocket으로 임시예약 성공 메시지 전송
                if (tempResult.get("data") != null) {
                    Map<String, Object> data = (Map<String, Object>) tempResult.get("data");
                    String tempReservationId = (String) data.get("tempReservationId");
                    
                    queueWebSocketHandler.sendTempReservationSuccess(
                        String.valueOf(courseSeq), 
                        String.valueOf(memberNo), 
                        tempReservationId, 
                        scheduleId
                    );
                }
                
                // 🔥 재귀적으로 다음 사용자도 처리 (연쇄 처리)
                processNextInScheduleQueue(courseSeq, scheduleId);
            }
        } else {
            // 임시예약 실패 (좌석 마감 등)
            log.warn("❌ 즉시 임시예약 실패 - 강의{}, 스케줄{}, 사용자{}, 이유: {}", 
                courseSeq, scheduleId, memberNo, tempResult.get("message"));
                
            // 좌석 마감인 경우 전체 대기열 정리
            if (tempResult.get("message") != null && 
                tempResult.get("message").toString().contains("마감")) {
                
                // 해당 스케줄의 모든 대기자에게 마감 알림
                notifyQueueClosed(courseSeq, scheduleId, "선택하신 시간대의 좌석이 모두 마감되었습니다.");
                
                // 대기열 정리
                redisTemplate.delete(queueKey);
                log.info("🚫 좌석 마감으로 스케줄 대기열 정리 - 강의{}, 스케줄{}", courseSeq, scheduleId);
            }
        }
    }
    
    // 🔥 대기열 마감 알림
    private void notifyQueueClosed(Long courseSeq, Long scheduleId, String message) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        
        // 모든 대기자에게 마감 알림
        Set<Object> allMembers = redisTemplate.opsForZSet().range(queueKey, 0, -1);
        if (allMembers != null && !allMembers.isEmpty()) {
            for (Object memberObj : allMembers) {
                String memberNo = String.valueOf(memberObj);
                
                Map<String, Object> closeMessage = new HashMap<>();
                closeMessage.put("type", "queue_closed");
                closeMessage.put("message", message);
                closeMessage.put("scheduleId", scheduleId);
                
                queueWebSocketHandler.sendQueueUpdate(String.valueOf(courseSeq), memberNo, closeMessage);
            }
            
            log.info("📢 대기열 마감 알림 전송 - 강의{}, 스케줄{}, 대상{}명", courseSeq, scheduleId, allMembers.size());
        }
    }

    // 기존 addToQueue 메서드는 그대로 유지 (하위 호환성)
    //대기열
    public Map<String, Object> addToQueue(Long courseSeq, int memberNo) {
        // 코스 레벨 대기열로 리다이렉트
        return addToCourseQueue(courseSeq, memberNo);
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

        return createResponse(true, "대기열 순서.", queueInfo);

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

    // 예약 처리 (항상 스케줄 레벨 대기열 사용)
    public Map<String, Object> processReservationRequest(Map<String, Object> data) {
        Long courseSeq = toLong(data.get("courseSeq"));
        Long scheduleId = toLong(data.get("scheduleId"));
        Integer memberNoInt = toInt(data.get("memberNo"));
        if (courseSeq == null || scheduleId == null || memberNoInt == null) {
            return createResponse(false, "요청 파라미터가 올바르지 않습니다.");
        }
        int memberNo = memberNoInt;

        updateHeartBeat(courseSeq, memberNo);
        cleanUpInactiveMembers(courseSeq);

        // 🔥 항상 스케줄 레벨 대기열 사용 (대기열 활성화 임계값 무시)
        log.info("💡 예약 요청 - 항상 대기열 사용: 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
        
        if (!isInScheduleQueue(courseSeq, scheduleId, memberNo)) {
            // 🔥 모든 사용자 무조건 스케줄 대기열에 추가
            Map<String, Object> result = addToScheduleQueue(courseSeq, scheduleId, memberNo);
            result.put("queueRequired", true);
            log.info("🎯 모든 사용자 대기열 추가: 강의{}, 스케줄{}, 사용자{}, 순서{}", 
                courseSeq, scheduleId, memberNo, result.get("data") != null ? 
                ((Map<String, Object>) result.get("data")).get("position") : "?");
            return result;
            
        } else {
            // 🔥 이미 대기열에 있으면 위치만 조회 (바로 임시예약 시도하지 않음)
            Map<String, Object> result = getScheduleQueuePosition(courseSeq, scheduleId, memberNo);
            result.put("queueRequired", true);
            
            if (result.get("data") != null) {
                Map<String, Object> queueData = (Map<String, Object>) result.get("data");
                Integer position = toInt(queueData.get("position"));
                log.info("📋 대기열 위치 조회: 강의{}, 스케줄{}, 사용자{}, 순서{}", 
                    courseSeq, scheduleId, memberNo, position);
                
                if (position != null && position == 1) {
                    // 첫 번째 순서지만 스케줄러가 처리할 때까지 대기
                    result.put("message", "곧 차례입니다. 잠시만 기다려주세요.");
                    log.info("⏳ 첫 번째 순서 - 스케줄러 처리 대기: 사용자{}, 스케줄{}", memberNo, scheduleId);
                }
            }
            
            return result;
        }
    }

    // 스케줄 대기열 확인 메서드들
    public boolean isInScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        Double score = redisTemplate.opsForZSet().score(queueKey, memberNo);
        return score != null;
    }

    public boolean isFirstInScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        Long rank = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        return rank != null && rank == 0;
    }

    public Map<String, Object> createTemporaryReservation(Map<String, Object> data) {
        Long scheduleId = toLong(data.get("scheduleId"));
        Integer memberNoInt = toInt(data.get("memberNo"));
        Long courseSeq = toLong(data.get("courseSeq"));
        if (scheduleId == null || memberNoInt == null || courseSeq == null) {
            return createResponse(false, "요청 파라미터가 올바르지 않습니다.");
        }
        int memberNo = memberNoInt;

        String lockKey = "lock:schedule:" + scheduleId;
        RLock lock = redissonClient.getFairLock(lockKey);

        try {
            if (lock.tryLock(10, 5, TimeUnit.SECONDS)) {
                String seatKey = "temp_occupied:" + scheduleId;
                // 기존 임시예약 확인 - 본인 것이면 재사용, 타인 것이면 만료 체크
                String existingReservationId = (String) redisTemplate.opsForValue().get(seatKey);
                if (existingReservationId != null) {
                    // 기존 임시예약 정보 조회
                    String existingTempKey = "temp_reservation:" + existingReservationId;
                    Map<String, Object> existingReservation = (Map<String, Object>) redisTemplate.opsForValue().get(existingTempKey);
                    
                    if (existingReservation != null) {
                        int existingMemberNo = ((Number) existingReservation.get("memberNo")).intValue();
                        
                        // 본인의 기존 예약이면 그대로 반환
                        if (existingMemberNo == memberNo) {
                            log.info("기존 임시예약 재사용 - 사용자{}, 예약ID{}", memberNo, existingReservationId);
                            
                            Map<String, Object> responseData = new HashMap<>();
                            responseData.put("tempReservationId", existingReservationId);
                            responseData.put("expiresAt", existingReservation.get("expiresAt"));
                            responseData.put("remainingSeconds", 60 * 10); // 실제로는 남은 시간 계산 필요
                            
                            // WebSocket으로 임시예약 성공 메시지 전송 (기존 예약 재사용)
                            queueWebSocketHandler.sendTempReservationSuccess(
                                String.valueOf(courseSeq), 
                                String.valueOf(memberNo), 
                                existingReservationId, 
                                scheduleId
                            );
                            
                            return createResponse(true, "기존 임시예약이 유효합니다.", responseData);
                        } else {
                            // 다른 사용자의 예약이면 에러
                            log.warn("다른 사용자의 임시예약 존재 - 현재사용자{}, 기존사용자{}, 스케줄{}", 
                                memberNo, existingMemberNo, scheduleId);
                            return createResponse(false, "다른 사용자가 예약 진행 중입니다.");
                        }
                    } else {
                        // 임시예약 정보가 없으면 키 정리
                        log.info("만료된 temp_occupied 키 정리 - scheduleId: {}", scheduleId);
                        redisTemplate.delete(seatKey);
                    }
                }

                Integer availableSeats = scheduleCacheService.getAvailableSeats(scheduleId);
                if (availableSeats <= 0) {
                    log.warn("🚫 좌석 마감 - 예약 실패: 강의{}, 스케줄{}, 사용자{}, 잔여좌석: {}", 
                        courseSeq, scheduleId, memberNo, availableSeats);
                    
                    // 좌석 마감 시 대기열에서 제거 (더 이상 기다릴 필요 없음)
                    removeFromScheduleQueue(courseSeq, scheduleId, memberNo);
                    
                    return createResponse(false, "죄송합니다. 선택하신 시간대의 좌석이 모두 마감되었습니다.");
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

                // 장바구니 만료 추적용 키 생성 (Redis 키 만료 이벤트 트리거용)
                String cartExpiryKey = "cart_expiry:" + tempReservationId;
                redisTemplate.opsForValue().set(cartExpiryKey, "expire", Duration.ofMinutes(10));

                //카프카 이벤트 (tempReservationId 포함하여 중복 알림 방지)
                publishEvent("TEMP_RESERVATION_CREATED:" + tempReservationId, tempReservation);

                log.info("임시예약 완료 사용자{}, 임시예약{}, 스케쥴{}", memberNo, tempReservationId,scheduleId);

                Map<String, Object> responseData = new HashMap<>();
                responseData.put("tempReservationId", tempReservationId);
                responseData.put("expiresAt", tempReservation.get("expiresAt"));
                responseData.put("remainingSeconds",60*10);

                // WebSocket으로 임시예약 성공 메시지 전송
                queueWebSocketHandler.sendTempReservationSuccess(
                    String.valueOf(courseSeq), 
                    String.valueOf(memberNo), 
                    tempReservationId, 
                    scheduleId
                );

                // 대기열 통과 토큰 소비 (사용 완료)
                consumeQueuePassToken(courseSeq, memberNo);

                scheduleCacheService.updateSeatsCount(scheduleId,-1);
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
        
        // 락 획득 실패 시 실패 응답 (이미 대기열에 있는 상태)
        log.warn("⚠️ 락 획득 실패 - 예약 실패: 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
        return createResponse(false, "예약 처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
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

    // WebSocket으로 대기열 업데이트 브로드캐스트
    private void broadcastQueueUpdate(Long courseSeq, Long scheduleId) {
        String throttleKey = courseSeq + ":" + scheduleId;
        Long lastTime = lastBroadcastTime.get(throttleKey);
        long currentTime = System.currentTimeMillis();
        
        // 스로틀링: 마지막 브로드캐스트로부터 설정된 시간 이내면 스킵
        if (lastTime != null && (currentTime - lastTime) < broadcastThrottleMs) {
            log.debug("브로드캐스트 스로틀링 - 강의: {}, 스케줄: {}", courseSeq, scheduleId);
            return;
        }
        
        lastBroadcastTime.put(throttleKey, currentTime);
        
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        
        // 대기열 상위 10명에게만 업데이트 전송 (성능 최적화)
        Set<Object> topMembers = redisTemplate.opsForZSet().range(queueKey, 0, 9);
        Long totalInQueue = redisTemplate.opsForZSet().zCard(queueKey);
        
        if (topMembers != null && !topMembers.isEmpty()) {
            int position = 1;
            for (Object memberObj : topMembers) {
                String memberNo = String.valueOf(memberObj);
                
                Map<String, Object> queueData = new HashMap<>();
                queueData.put("position", position);
                queueData.put("totalInQueue", totalInQueue);
                queueData.put("estimatedWaitTime", (position - 1) * 30);
                queueData.put("queueType", "schedule");
                queueData.put("scheduleId", scheduleId);
                
                queueWebSocketHandler.sendQueueUpdate(String.valueOf(courseSeq), memberNo, queueData);
                position++;
            }
            
            log.debug("🔔 대기열 업데이트 전송 (상위 10명) - 강의: {}, 스케줄: {}", courseSeq, scheduleId);
        }
    }

    private void broadcastCourseQueueUpdate(Long courseSeq) {
        String throttleKey = "course:" + courseSeq;
        Long lastTime = lastBroadcastTime.get(throttleKey);
        long currentTime = System.currentTimeMillis();
        
        // 스로틀링
        if (lastTime != null && (currentTime - lastTime) < broadcastThrottleMs) {
            return;
        }
        
        lastBroadcastTime.put(throttleKey, currentTime);
        
        String queueKey = "queue:course:" + courseSeq;
        
        // 상위 10명에게만 업데이트
        Set<Object> topMembers = redisTemplate.opsForZSet().range(queueKey, 0, 9);
        Long totalInQueue = redisTemplate.opsForZSet().zCard(queueKey);
        
        if (topMembers != null && !topMembers.isEmpty()) {
            int position = 1;
            for (Object memberObj : topMembers) {
                String memberNo = String.valueOf(memberObj);
                
                Map<String, Object> queueData = new HashMap<>();
                queueData.put("position", position);
                queueData.put("totalInQueue", totalInQueue);
                queueData.put("estimatedWaitTime", (position - 1) * 30);
                queueData.put("queueType", "course");
                
                queueWebSocketHandler.sendQueueUpdate(String.valueOf(courseSeq), memberNo, queueData);
                position++;
            }
        }
    }

    //  대기열 통과 토큰 검증
    public boolean hasQueuePassToken(Long courseSeq, int memberNo) {
        String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
        String tokenValue = (String) redisTemplate.opsForValue().get(accessToken);
        boolean hasToken = "PASSED".equals(tokenValue);
        
        if (hasToken) {
            log.info("대기열 통과 토큰 확인됨: 강의{}, 사용자{}", courseSeq, memberNo);
        } else {
            log.debug("대기열 통과 토큰 없음: 강의{}, 사용자{}", courseSeq, memberNo);
        }
        
        return hasToken;
    }
    
    //  대기열 통과 토큰 삭제 (예약 완료 시 사용)
    public void consumeQueuePassToken(Long courseSeq, int memberNo) {
        String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
        Boolean deleted = redisTemplate.delete(accessToken);
        if (Boolean.TRUE.equals(deleted)) {
            log.info("대기열 통과 토큰 사용 완료: 강의{}, 사용자{}", courseSeq, memberNo);
        }
    }
    
    /**
     * 오래된 대기열 활성화 캐시 정리 (30분마다 호출)
     */
    public void cleanupQueueActivationCache() {
        long currentTime = System.currentTimeMillis();
        int cleanedCount = 0;
        
        // 만료된 캐시 엔트리 제거 (5분 초과된 것들)
        Iterator<Map.Entry<Long, Long>> iterator = queueActivationCacheTime.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<Long, Long> entry = iterator.next();
            if (currentTime - entry.getValue() > QUEUE_ACTIVATION_CACHE_TTL * 10) {
                queueActivationCache.remove(entry.getKey());
                iterator.remove();
                cleanedCount++;
            }
        }
        
        if (cleanedCount > 0) {
            log.debug("대기열 활성화 캐시 정리 완료: {}개 제거", cleanedCount);
        }
    }

    private Long toLong(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Number) {
            return ((Number) obj).longValue();
        }
        try {
            return Long.valueOf(obj.toString());
        } catch (NumberFormatException e) {
            log.warn("Long 변환 실패: {}", obj, e);
            return null;
        }
    }

    private Integer toInt(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Number) {
            return ((Number) obj).intValue();
        }
        try {
            return Integer.valueOf(obj.toString());
        } catch (NumberFormatException e) {
            log.warn("Integer 변환 실패: {}", obj, e);
            return null;
        }
    }
}
