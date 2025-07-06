package com.up.spring.reservation.service;


import com.up.spring.course.model.service.CourseScheduleService;
import com.up.spring.reservation.websocket.QueueWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.sql.Date;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

import com.up.spring.payment.model.dao.OrdersDao;
import org.apache.ibatis.session.SqlSession;

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

    //결제 중복예약 확인용
    private final OrdersDao ordersDao;
    private final SqlSession sqlSession;

    //접속자 수 계산
    public void updateHeartBeat(Long courseSeq, int memberNo) {
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long currentTime = System.currentTimeMillis();

        redisTemplate.opsForZSet().add(heartBeatKey, memberNo, currentTime);
        redisTemplate.expire(heartBeatKey, Duration.ofMinutes(5));

//        log.debug("하트비트 : {}, {}, {}", courseSeq, memberNo, currentTime);
    }

    public Long getActiveMemberCount(Long courseSeq) {
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long oneMinuteAgo = System.currentTimeMillis() - 60 * 1000;

        Long count = redisTemplate.opsForZSet().count(heartBeatKey, oneMinuteAgo, Double.MAX_VALUE);

        // 사용자가 있을 때만 로그 출력
        if (count != null && count > 0) {
//            log.debug("활성 사용자 - 강의 {}: {}명", courseSeq, count);
        }
        return count;
    }

    public void cleanUpInactiveMembers(Long courseSeq) {
        String heartBeatKey = "heartBeat:course:" + courseSeq;
        long oneMinuteAgo = System.currentTimeMillis() - 60 * 1000;

        Long count = redisTemplate.opsForZSet().removeRangeByScore(heartBeatKey, 0, oneMinuteAgo);

        if (count != null && count > 0) {
//            log.info("사용자정리 : {},{}명제거", courseSeq, count);
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

//            log.debug("코스 :{}, 사용자 수 : {}", courseSeq, activeMembers.size());
        }

        return result;

    }


    public boolean shouldActivateQueue(Long courseSeq) {
        // 캐시된 결과가 있으면 반환
        Long cacheTime = queueActivationCacheTime.get(courseSeq);
        if (cacheTime != null && (System.currentTimeMillis() - cacheTime) < QUEUE_ACTIVATION_CACHE_TTL) {
            Boolean cachedResult = queueActivationCache.get(courseSeq);
            if (cachedResult != null) {
                return cachedResult;
            }
        }

        // 🔥 대기열 활성화 조건을 더 엄격하게 설정
        Long activeMemberCount = getActiveMemberCount(courseSeq);
        boolean shouldActivate = activeMemberCount != null && activeMemberCount >= queueActivationThreshold;
        
        // 🔥 추가 조건: 최소 2명 이상이 활성 상태일 때만 대기열 활성화
        if (shouldActivate && activeMemberCount < 2) {
            shouldActivate = false;
            log.debug("대기열 활성화 조건 미충족 - 강의: {}, 활성인원: {}, 최소요구: 2명", courseSeq, activeMemberCount);
        }

        // 캐시 업데이트
        queueActivationCache.put(courseSeq, shouldActivate);
        queueActivationCacheTime.put(courseSeq, System.currentTimeMillis());

        // 상태 변화가 있을 때만 로그 출력 (선택사항)
        // log.debug("대기열 상태 체크 - 강의 {}, 현재인원 {}, 활성화 {}", courseSeq, activeMemberCount, shouldActivate);

        return shouldActivate;
    }


    //  코스 레벨 대기열 (대기열 페이지 진입)
    public Map<String, Object> addToCourseQueue(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        String memberKey = String.valueOf(memberNo); // ✅ ZSET 멤버를 항상 문자열로 저장
        long timestamp = System.currentTimeMillis();

        // 대기열 확인 (문자열 → 정수 순으로 검사)
        Double existingScore = redisTemplate.opsForZSet().score(queueKey, memberKey);
        if (existingScore == null) {
            existingScore = redisTemplate.opsForZSet().score(queueKey, memberNo);
            if (existingScore != null) {
                // 과거 정수형으로 저장된 멤버를 발견하면 문자열 버전으로 교체하여 일관성 유지
                redisTemplate.opsForZSet().remove(queueKey, memberNo);
                redisTemplate.opsForZSet().add(queueKey, memberKey, existingScore);
                log.debug("정수형 멤버 키를 문자열로 교체 - queueKey:{}, memberNo:{}", queueKey, memberNo);
            }
        }

        if (existingScore != null) {
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberKey);
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
        Boolean added = redisTemplate.opsForZSet().add(queueKey, memberKey, timestamp);
        redisTemplate.expire(queueKey, Duration.ofMinutes(15));

        if (added == null || !added) {
            // 추가 실패 (동시성 문제로 인한 경우)
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberKey);
            return createResponse(true, "대기열 추가 중 충돌 발생", position != null ? position + 1 : 0);
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberKey);
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
        String memberKey = String.valueOf(memberNo); // ✅ ZSET 멤버를 항상 문자열로 저장
        long timestamp = System.currentTimeMillis();

        // 이미 대기열에 있는지 먼저 확인 (문자열 → 정수 순으로 검사)
        Double existingScore = redisTemplate.opsForZSet().score(queueKey, memberKey);
        if (existingScore == null) {
            existingScore = redisTemplate.opsForZSet().score(queueKey, memberNo);
            if (existingScore != null) {
                // 과거 정수형으로 저장된 멤버를 발견하면 문자열 버전으로 교체하여 일관성 유지
                redisTemplate.opsForZSet().remove(queueKey, memberNo);
                redisTemplate.opsForZSet().add(queueKey, memberKey, existingScore);
                log.debug("정수형 멤버 키를 문자열로 교체 - queueKey:{}, memberNo:{}", queueKey, memberNo);
            }
        }

        if (existingScore != null) {
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberKey);
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
        Boolean added = redisTemplate.opsForZSet().add(queueKey, memberKey, timestamp);
        redisTemplate.expire(queueKey, Duration.ofMinutes(15));

        if (added == null || !added) {
            // 추가 실패 (동시성 문제로 인한 경우)
            Long position = redisTemplate.opsForZSet().rank(queueKey, memberKey);
            return createResponse(true, "대기열 추가 중 충돌 발생", position != null ? position + 1 : 0);
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberKey);
        Long totalInQueue = redisTemplate.opsForZSet().count(queueKey, Double.NEGATIVE_INFINITY, Double.POSITIVE_INFINITY);

        Map<String, Object> queueInfo = new HashMap<>();
        queueInfo.put("position", position != null ? position + 1 : 0);
        queueInfo.put("totalInQueue", totalInQueue);
        queueInfo.put("estimateWaitTime", (position != null ? position : 0) * 30);
        queueInfo.put("queueType", "SCHEDULE");
        queueInfo.put("scheduleId", scheduleId);

        log.info("스케줄 대기열 입장 - 강의{}, 스케줄{}, 사용자{}, 순서{}/{}",
            courseSeq, scheduleId, memberNo, position + 1, totalInQueue);

        // 🔥 첫 번째 순서라면 즉시 임시예약 처리 (비동기)
        if (position != null && position == 0) { // Redis rank는 0부터 시작
            log.info("🎯 첫 번째 순서 즉시 처리(Async) - 강의{}, 스케줄{}, 사용자{}", courseSeq, scheduleId, memberNo);
            // 🔥 모달창이 뜰 시간을 위해 약간의 지연 추가
            asyncProcessNextWithDelay(courseSeq, scheduleId, 500); // 0.5초 지연
        }

        // WebSocket으로 대기열 업데이트 전송
        broadcastQueueUpdate(courseSeq, scheduleId);

        return createResponse(true, "예약 대기열에 입장했습니다.", queueInfo);
    }

    // 코스 대기열 조회
    public Map<String, Object> getCourseQueuePosition(Long courseSeq, int memberNo) {
        String queueKey = "queue:course:" + courseSeq;
        return getQueuePositionInternal(queueKey, String.valueOf(memberNo), "COURSE");
    }

    // 스케줄 대기열 조회
    public Map<String, Object> getScheduleQueuePosition(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        
        // 🔥 먼저 임시예약 성공 상태 확인
        String successKey = "temp_success:" + courseSeq + ":" + scheduleId + ":" + memberNo;
        Map<String, Object> successData = (Map<String, Object>) redisTemplate.opsForValue().get(successKey);
        
        if (successData != null) {
            log.info("🎯 임시예약 성공 상태 발견: 사용자{}, 스케줄{}, 데이터: {}", memberNo, scheduleId, successData);
            
            // 성공 상태 삭제 (한 번만 사용)
            redisTemplate.delete(successKey);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "임시예약이 완료되었습니다. 장바구니로 이동합니다.");
            response.put("tempReservationSuccess", true);
            response.put("tempReservationId", successData.get("tempReservationId"));
            response.put("scheduleId", successData.get("scheduleId"));
            
            log.info("🎯 임시예약 성공 응답 생성: {}", response);
            
            return response;
        }
        
        return getQueuePositionInternal(queueKey, String.valueOf(memberNo), "SCHEDULE");
    }

    // 내부 대기열 조회 메서드
    private Map<String, Object> getQueuePositionInternal(String queueKey, Object memberObj, String queueType) {
        Double score = redisTemplate.opsForZSet().score(queueKey, memberObj);
        if (score == null) {
            return createResponse(false, "대기열에 없습니다.");
        }

        Long position = redisTemplate.opsForZSet().rank(queueKey, memberObj);
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
        String memberKey = String.valueOf(memberNo);
        
        // 🔥 디버깅을 위한 Redis 상태 확인
        Double score = redisTemplate.opsForZSet().score(queueKey, memberKey);
        log.debug("🔍 Redis 조회 - 키: {}, 멤버: {}, 존재여부: {}", queueKey, memberKey, score != null);
        
        if (score == null) {
            // String으로 찾지 못했으면 int로도 확인
            score = redisTemplate.opsForZSet().score(queueKey, memberNo);
            log.debug("🔍 Redis 조회 (int) - 키: {}, 멤버: {}, 존재여부: {}", queueKey, memberNo, score != null);
        }
        
        // 🔥 String으로 변환하여 제거 시도 (Redis에 저장된 형태와 일치시키기 위해)
        Long removed = redisTemplate.opsForZSet().remove(queueKey, memberKey);
        log.debug("🔍 String 제거 시도 - 키: {}, 멤버: {}, 결과: {}", queueKey, memberKey, removed);
        
        // 🔥 만약 String으로 제거되지 않으면 int로도 시도
        if (removed == null || removed == 0) {
            removed = redisTemplate.opsForZSet().remove(queueKey, memberNo);
            log.debug("🔍 int 제거 시도 - 키: {}, 멤버: {}, 결과: {}", queueKey, memberNo, removed);
        }
        
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
        } else {
            log.warn("코스 대기열 제거 실패 - 강의{}, 사용자{} (Redis에 존재하지 않음)", courseSeq, memberNo);
            
            // 🔥 Redis 전체 상태 확인 (디버깅용)
            Long totalMembers = redisTemplate.opsForZSet().zCard(queueKey);
            Set<Object> allMembers = redisTemplate.opsForZSet().range(queueKey, 0, 9);
            log.debug("🔍 Redis 전체 상태 - 총 멤버: {}, 상위 10명: {}", totalMembers, allMembers);
        }
    }

    // 스케줄 대기열에서 제거
    public void removeFromScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        Long removed = redisTemplate.opsForZSet().remove(queueKey, String.valueOf(memberNo));
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
                
                // 🔥 임시예약 성공 상태를 Redis에 저장 (WebSocket 연결 전에도 확인 가능)
                if (tempResult.get("data") != null) {
                    Map<String, Object> data = (Map<String, Object>) tempResult.get("data");
                    String tempReservationId = (String) data.get("tempReservationId");
                    
                    // 성공 상태 저장 (5분간 유효)
                    String successKey = "temp_success:" + courseSeq + ":" + scheduleId + ":" + memberNo;
                    Map<String, Object> successData = new HashMap<>();
                    successData.put("tempReservationId", tempReservationId);
                    successData.put("scheduleId", scheduleId);
                    successData.put("timestamp", System.currentTimeMillis());
                    redisTemplate.opsForValue().set(successKey, successData, Duration.ofMinutes(5));
                    
                    log.info("🎯 임시예약 성공 상태 저장: {}", successKey);
                    
                    // 🔥 WebSocket 메시지 전송을 비동기로 처리 (연결 지연 대비)
                    try {
                        queueWebSocketHandler.sendTempReservationSuccess(
                            String.valueOf(courseSeq), 
                            String.valueOf(memberNo), 
                            tempReservationId, 
                            scheduleId
                        );
                    } catch (Exception e) {
                        log.warn("WebSocket 메시지 전송 실패 (Redis 플래그로 대체): {}", e.getMessage());
                    }
                }
                
                // 🔥 다음 사용자는 스케줄러가 처리하도록 위임 (재귀 방지)
                log.info("✅ 임시예약 완료 - 다음 사용자는 스케줄러가 처리: 강의{}, 스케줄{}", courseSeq, scheduleId);
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

        // ===== 중복 예약 방지 =====
        if(scheduleId != null){
            java.util.Map<String,Object> dupParams = new java.util.HashMap<>();
            dupParams.put("memberNo", memberNo);
            dupParams.put("scheduleId", scheduleId);
            int dupCnt;
            try {
                dupCnt = ordersDao.existsScheduleReservation(sqlSession, dupParams);
            } catch(Exception ex){
                log.error("중복 예약 조회 실패", ex);
                dupCnt = 0;
            }
            if(dupCnt > 0){
                log.warn("중복 스케줄 예약 시도 차단 - memberNo:{}, scheduleId:{}", memberNo, scheduleId);
                return createResponse(false, "이미 예약한 시간입니다.");
            }
        }
        
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
                    // 이미 스케줄러가 임시예약을 만들었을 수도 있으므로 seatKey 확인 후 재사용 시도
                    String seatKey = "temp_occupied:" + scheduleId;
                    String existingReservationId = (String) redisTemplate.opsForValue().get(seatKey);

                    if (existingReservationId != null) {
                        Map<String,Object> tempReq = new java.util.HashMap<>();
                        tempReq.put("courseSeq", courseSeq);
                        tempReq.put("scheduleId", scheduleId);
                        tempReq.put("memberNo", memberNo);

                        Map<String,Object> tempRes = createTemporaryReservation(tempReq);
                        if(tempRes != null && Boolean.TRUE.equals(tempRes.get("success"))){
                            log.info("✅ 이미 생성된 임시예약 재사용 - tempReservationId:{}", ((java.util.Map)tempRes.get("data")).get("tempReservationId"));
                            return tempRes;
                        }
                    }

                    // 아직 임시예약이 생성되지 않았으면 대기 메시지를 유지한다.
                    result.put("message", "곧 차례입니다. 잠시만 기다려주세요.");
                    log.info("⏳ 첫 번째 순서 - 임시예약 대기: 사용자{}, 스케줄{}", memberNo, scheduleId);
                }
            }
            
            return result;
        }
    }

    // 스케줄 대기열 확인 메서드들
    public boolean isInScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        // 먼저 문자열 멤버 확인
        Double score = redisTemplate.opsForZSet().score(queueKey, String.valueOf(memberNo));
        if (score == null) {
            // 하위 호환: 정수 형태로 저장된 멤버도 검사
            score = redisTemplate.opsForZSet().score(queueKey, memberNo);
        }
        return score != null;
    }

    public boolean isFirstInScheduleQueue(Long courseSeq, Long scheduleId, int memberNo) {
        String queueKey = "queue:course:" + courseSeq + ":schedule:" + scheduleId;
        Long rank = redisTemplate.opsForZSet().rank(queueKey, String.valueOf(memberNo));
        if (rank == null) {
            rank = redisTemplate.opsForZSet().rank(queueKey, memberNo);
        }
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

    /**
     * 임시예약 취소 처리 (장바구니 수동 삭제 등)
     *  1. temp_reservation:{id} 조회하여 scheduleId, courseSeq 확보
     *  2. 좌석 수 복구(+1) 및 관련 Redis 키 정리
     */
    public void cancelTemporaryReservation(String tempReservationId) {
        if (tempReservationId == null || tempReservationId.isBlank()) {
            return;
        }

        String tempKey = "temp_reservation:" + tempReservationId;
        Map<String, Object> tempReservation = (Map<String, Object>) redisTemplate.opsForValue().get(tempKey);
        if (tempReservation == null) {
            log.debug("취소할 임시예약 정보가 없음 - tempReservationId: {}", tempReservationId);
            return;
        }

        Long scheduleId = toLong(tempReservation.get("scheduleId"));
        Long courseSeq = toLong(tempReservation.get("courseSeq"));

        // 좌석 복구 (캐시)
        if (scheduleId != null) {
            scheduleCacheService.updateSeatsCount(scheduleId, 1);

            // temp_occupied 키 정리
            String seatKey = "temp_occupied:" + scheduleId;
            String occupiedVal = (String) redisTemplate.opsForValue().get(seatKey);
            if (tempReservationId.equals(occupiedVal)) {
                redisTemplate.delete(seatKey);
            }
        }

        // temp_reservation, cart_expiry 키 삭제
        redisTemplate.delete(tempKey);
        String cartExpiryKey = "cart_expiry:" + tempReservationId;
        redisTemplate.delete(cartExpiryKey);

        // 코스 스케줄 캐시 무효화
        if (courseSeq != null) {
            scheduleCacheService.invalidateCourseSchedulesCache(courseSeq);
        }

        log.info("🌀 임시예약 취소 완료 - tempReservationId:{}, scheduleId:{}, courseSeq:{}", tempReservationId, scheduleId, courseSeq);
    }

    // ===================== Async Helper =====================
    @org.springframework.scheduling.annotation.Async("reservationExecutor")
    public void asyncProcessNext(Long courseSeq, Long scheduleId) {
        try {
            Thread.sleep(100); // Redis 업데이트 완료 대기
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        processNextInScheduleQueue(courseSeq, scheduleId);
    }

    @org.springframework.scheduling.annotation.Async("reservationExecutor")
    public void asyncProcessNextWithDelay(Long courseSeq, Long scheduleId, long delayMillis) {
        try {
            Thread.sleep(delayMillis); // 지연 추가
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        processNextInScheduleQueue(courseSeq, scheduleId);
    }
}
