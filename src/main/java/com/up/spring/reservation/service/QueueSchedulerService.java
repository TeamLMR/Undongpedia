package com.up.spring.reservation.service;

import com.up.spring.reservation.websocket.QueueWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.time.Duration;

@Service
@RequiredArgsConstructor
@Slf4j
public class QueueSchedulerService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final ReservationRedisService reservationRedisService;
    private final QueueWebSocketHandler queueWebSocketHandler;
    
    // 활성 강의 관리를 위한 Redis Set 키
    private static final String ACTIVE_COURSES_KEY = "active:courses";
    
    // 대기열 처리 주기를 2분으로 조정 (서버 부하 감소)
    @Scheduled(fixedDelayString = "${queue.scheduler.interval:120000}")
    public void processAllQueues() {
        log.info("==대기열 처리 시작 (2분 주기)==");
        try {
            // Redis 연결 상태 확인
            try {
                redisTemplate.hasKey("health-check");
            } catch (Exception e) {
                log.warn("Redis 연결 불안정 - 대기열 처리 건너뜀: {}", e.getMessage());
                return;
            }
            
            // SCAN 대신 Set에서 활성 강의 목록 조회
            Set<Object> activeCourseIds = redisTemplate.opsForSet().members(ACTIVE_COURSES_KEY);
            
            if (activeCourseIds == null || activeCourseIds.isEmpty()) {
                log.debug("활성 강의가 없습니다.");
                return;
            }
            
            log.info("활성 강의 {}개 처리 시작", activeCourseIds.size());
            
            // 순차 처리로 Redis 부하 감소 (최대 10개 강의)
            activeCourseIds.stream()
                .limit(10)
                .forEach(courseIdObj -> {
                    try {
                        Long courseSeq = Long.valueOf(courseIdObj.toString());
                                                 
                         // 코스 대기열 처리
                         processCourseQueues(courseSeq);
                        
                    } catch (Exception e) {
                        log.error("강의 {} 대기열 처리 중 오류 발생", courseIdObj, e);
                    }
                });
            
            log.info("==대기열 처리 완료==");
            
        } catch (Exception e) {
            log.error("대기열 처리 중 전체 오류 발생", e);
        }
    }

    // 코스 대기열 처리 메서드 추가
    private void processCourseQueues(Long courseSeq) {
        try {
            String courseQueueKey = "queue:course:" + courseSeq;
            
            // 코스 대기열 크기 확인
            Long queueSize = redisTemplate.opsForZSet().zCard(courseQueueKey);
            if (queueSize == null || queueSize == 0) {
                log.debug("강의 {} - 코스 대기열이 비어있습니다.", courseSeq);
                return;
            }
            
            log.info("강의 {} - 코스 대기열 처리 시작, 대기인원: {}명", courseSeq, queueSize);
            
            // 첫 번째 대기자 조회
            Set<Object> firstMemberSet = redisTemplate.opsForZSet().range(courseQueueKey, 0, 0);
            if (firstMemberSet == null || firstMemberSet.isEmpty()) {
                log.debug("강의 {} - 첫 번째 대기자를 찾을 수 없습니다.", courseSeq);
                return;
            }
            
            Object firstMemberObj = firstMemberSet.iterator().next();
            int memberNo;
            if (firstMemberObj instanceof String) {
                memberNo = Integer.parseInt((String) firstMemberObj);
            } else if (firstMemberObj instanceof Number) {
                memberNo = ((Number) firstMemberObj).intValue();
            } else {
                log.warn("강의 {} - 유효하지 않은 memberNo 형식: {}", courseSeq, firstMemberObj);
                return;
            }
            
            // 사용자 활성 상태 확인
            if (!isUserStillActive(courseSeq, memberNo)) {
                log.info("강의 {} - 사용자 {} 비활성 상태, 코스 대기열에서 제거", courseSeq, memberNo);
                redisTemplate.opsForZSet().remove(courseQueueKey, firstMemberObj);
                
                // 다음 대기자에게 알림
                notifyNextInCourseQueue(courseSeq);
                return;
            }
            
            // 코스 대기열에서 첫 번째 대기자를 예약 페이지로 안내
            log.info("강의 {} - 사용자 {} 예약 페이지 안내", courseSeq, memberNo);
            
                         // 대기열 통과 토큰 생성 (5분간 유효) - 기존 토큰이 없을 때만
             String accessToken = "queue_pass:" + courseSeq + ":" + memberNo;
             String existingToken = (String) redisTemplate.opsForValue().get(accessToken);
             
             if (!"PASSED".equals(existingToken)) {
                 redisTemplate.opsForValue().set(accessToken, "PASSED", java.time.Duration.ofMinutes(5));
                 log.info("대기열 통과 토큰 생성 (스케줄러): {}", accessToken);
             } else {
                 log.debug("대기열 통과 토큰이 이미 존재함 (스케줄러): {}", accessToken);
             }
            
            // 코스 대기열에서 제거
            Long removed = redisTemplate.opsForZSet().remove(courseQueueKey, firstMemberObj);
            if (removed != null && removed > 0) {
                log.info("강의 {} - 사용자 {} 코스 대기열에서 제거 완료", courseSeq, memberNo);
                
                // WebSocket으로 해당 사용자에게 예약 페이지 이동 안내
                sendCourseQueueSuccessMessage(courseSeq, memberNo);
                
                // 다음 대기자들에게 위치 업데이트
                notifyNextInCourseQueue(courseSeq);
            }
            
        } catch (Exception e) {
            log.error("강의 {} 코스 대기열 처리 중 오류 발생", courseSeq, e);
        }
    }
    
    // 코스 대기열 성공 메시지 전송
    private void sendCourseQueueSuccessMessage(Long courseSeq, int memberNo) {
        try {
            Map<String, Object> successMessage = new HashMap<>();
            successMessage.put("type", "course_queue_success");
            successMessage.put("message", "예약 페이지로 이동합니다!");
            successMessage.put("courseSeq", courseSeq);
            
            queueWebSocketHandler.sendQueueUpdate(String.valueOf(courseSeq), String.valueOf(memberNo), successMessage);
            log.info("코스 대기열 성공 메시지 전송 - courseSeq: {}, memberNo: {}", courseSeq, memberNo);
        } catch (Exception e) {
            log.error("코스 대기열 성공 메시지 전송 실패 - courseSeq: {}, memberNo: {}", courseSeq, memberNo, e);
        }
    }
    
    // 코스 대기열 다음 대기자들에게 알림
    private void notifyNextInCourseQueue(Long courseSeq) {
        try {
            String courseQueueKey = "queue:course:" + courseSeq;
            
            // 상위 10명에게 위치 업데이트
            Set<Object> topMembers = redisTemplate.opsForZSet().range(courseQueueKey, 0, 9);
            Long totalInQueue = redisTemplate.opsForZSet().zCard(courseQueueKey);
            
            if (topMembers != null && !topMembers.isEmpty()) {
                int position = 1;
                for (Object memberObj : topMembers) {
                    String memberNo = String.valueOf(memberObj);
                    
                    Map<String, Object> queueData = new HashMap<>();
                    queueData.put("type", "queue_update");
                    queueData.put("position", position);
                    queueData.put("totalInQueue", totalInQueue);
                    queueData.put("estimatedWaitTime", (position - 1) * 60); // 1분당 1명 처리 가정
                    queueData.put("queueType", "course");
                    
                    queueWebSocketHandler.sendQueueUpdate(String.valueOf(courseSeq), memberNo, queueData);
                    position++;
                }
                
                log.debug("코스 대기열 위치 업데이트 전송 - 강의: {}, 총 {}명", courseSeq, totalInQueue);
            }
        } catch (Exception e) {
            log.error("코스 대기열 위치 업데이트 실패 - courseSeq: {}", courseSeq, e);
        }
    }

    private boolean isUserStillActive(Long courseSeq, int memberNo) {
        try {
            String heartbeatKey = "heartBeat:course:" + courseSeq;

            Double lastHeartbeatScore = redisTemplate.opsForZSet().score(heartbeatKey, memberNo);

            if (lastHeartbeatScore == null) {
                return false;
            }

            long lastHeartbeatTime = lastHeartbeatScore.longValue();
            long currentTime = System.currentTimeMillis();

            return (currentTime - lastHeartbeatTime) <= 1000 * 60;
        } catch (Exception e) {
            log.error("사용자 활성 상태 확인 중 오류 발생 - courseSeq: {}, memberNo: {}", courseSeq, memberNo, e);
            return false;
        }
    }

    private Set<String> getActiveCoursesWithHeartbeat() {
        // 이 메서드는 더 이상 사용하지 않음 - ACTIVE_COURSES_KEY 사용
        return new HashSet<>();
    }

    private Set<String> getScheduleQueuesForCourse(Long courseSeq) {
        Set<String> activeQueues = new HashSet<>();

        try {
            String pattern = "queue:course:" + courseSeq + ":schedule:*";

            ScanOptions scanOptions = ScanOptions.scanOptions()
                    .match(pattern)
                    .count(50)     // 스캔 크기 감소
                    .build();

            try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
                while (cursor.hasNext()) {
                    String key = cursor.next();
                    Long size = redisTemplate.opsForZSet().size(key);
                    if (size != null && size > 0) {
                        activeQueues.add(key);
                    }

                    // 스케줄 수 제한
                    if (activeQueues.size() >= 20) {
                        log.warn("강의{} 의 스케쥴이 너무 많습니다. 20개로 제한", courseSeq);
                        break;
                    }
                }
            }
            log.debug("강의{} : 활성 대기열 {}개", courseSeq, activeQueues.size());
        } catch (Exception e) {
            log.error("강의{} 스케줄 대기열 조회 중 오류 발생", courseSeq, e);
        }
        return activeQueues;
    }

    private Long extractCourseSeqFromHeartbeatKey(String heartbeatKey) {
        try {
            String[] parts = heartbeatKey.split(":");
            if (parts.length >= 3) {
                return Long.parseLong(parts[2]);
            } else {
                log.warn("강의 번호 추출 실패 : {}", heartbeatKey);
                return null;
            }
        } catch (Exception e) {
            log.error("강의 번호 추출 중 오류 발생: {}", heartbeatKey, e);
            return null;
        }
    }

    private Long extractScheduleIdFromQueueKey(String queueKey) {
        try {
            String[] parts = queueKey.split(":");
            if (parts.length >= 5) {
                return Long.parseLong(parts[4]);
            } else {
                log.warn("스케줄 ID 추출실패 : {}", queueKey);
                return null;
            }
        } catch (Exception e) {
            log.error("스케줄 ID 추출 중 오류 발생: {}", queueKey, e);
            return null;
        }
    }

    private void performLightCleanup() {
        try {
            int tempReservationCount = countKeysByPattern("temp_reservation:*", 10);
            if (tempReservationCount > 0) {
                log.debug("임시예약 {} 개", tempReservationCount);
            }
        } catch (Exception e) {
            log.error("가벼운 정리 작업 중 오류 발생", e);
        }
    }

    // 정리 작업 주기를 1시간으로 설정 (서버 부하 감소)
    @Scheduled(fixedRate = 60 * 60 * 1000)
    public void performHeavyCleanupTasks() {
        log.info("==작업 정리 시작(주기 1시간)==");
        try {
            // Redis 연결 상태 확인
            try {
                redisTemplate.hasKey("health-check");
            } catch (Exception e) {
                log.warn("Redis 연결 불안정 - 정리 작업 건너뜀: {}", e.getMessage());
                return;
            }
            
            cleanupExpiredTemporaryReservations();
            cleanupOldHeartbeats();
            cleanupEmptyQueues();
            
            // 대기열 활성화 캐시 정리
            reservationRedisService.cleanupQueueActivationCache();
            
            log.info("==작업 정리 완료(주기 1시간)==");
        } catch (Exception e) {
            log.error("정리 작업 중 오류 발생", e);
        }
    }

    public void cleanupExpiredTemporaryReservations() {
        int cleanedCount = 0;
        ScanOptions scanOptions = ScanOptions.scanOptions()
                .match("temp_reservation:*")
                .count(20)  // 스캔 크기 대폭 감소
                .build();

        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext() && cleanedCount < 100) {  // 최대 100개만 처리
                String key = cursor.next();
                try {
                    Long ttl = redisTemplate.getExpire(key, TimeUnit.SECONDS);
                    if (ttl <= 0) {
                        redisTemplate.delete(key);
                        cleanedCount++;
                    }
                } catch (Exception e) {
                    log.warn("키 정리 실패: {}", key, e);
                    break;  // 에러 발생 시 중단
                }
            }
        } catch (Exception e) {
            log.error("임시예약 정리 중 오류: {}", e.getMessage());
        }
        if (cleanedCount > 0) {
            log.info("만료된 임시예약 {} 개 정리", cleanedCount);
        }
    }

    public void cleanupOldHeartbeats() {
        long cutoffTime = System.currentTimeMillis() - 60 * 60 * 1000;
        int totalCleaned = 0;
        ScanOptions scanOptions = ScanOptions.scanOptions()
                .match("heartBeat:course:*")
                .count(100)
                .build();
        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext()) {
                String key = cursor.next();
                Long removedCount = redisTemplate.opsForZSet().removeRangeByScore(key, 0, cutoffTime);
                if (removedCount != null && removedCount > 0) {
                    totalCleaned += removedCount.intValue();
                }

                Long size = redisTemplate.opsForZSet().zCard(key);  
                if (size == null || size == 0) {
                    redisTemplate.delete(key);
                }

                if (totalCleaned >= 10000) {
                    log.warn("너무 많이 정리했어");
                    break;
                }
            }
            if (totalCleaned > 0) {
                log.info("하트비트{} 개 정리 완료", totalCleaned);
            }
        }
    }
    
    private void cleanupEmptyQueues() {
        int cleanedCount = 0;
        ScanOptions scanOptions = ScanOptions.scanOptions()
                .match("queue:*")
                .count(100)
                .build();
        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext()) {
                String key = cursor.next();

                Long size = redisTemplate.opsForZSet().zCard(key);
                if (size == null || size == 0) {
                    redisTemplate.delete(key);
                    cleanedCount++;
                }

                if (cleanedCount >= 1000) {
                    log.warn("너무 많이 정리했지롱");
                    break;
                }
            }
            if (cleanedCount > 0) {
                log.info("빈 대기열 {} 개 정리", cleanedCount);
            }
        }
    }

    public int countKeysByPattern(String pattern, int maxCount) {
        int count =0;
        ScanOptions scanOptions = ScanOptions.scanOptions()
                .match(pattern)
                .count(Math.min(maxCount, 100))     // 확인해보기
                .build();

        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext()) {
                cursor.next();
                count++;
            }
        }
        return count;
    }

    public java.util.Map<String, Object> getSchedulerStatus() {
        java.util.Map<String, Object> status = new java.util.HashMap<>();

        try {
            // 활성 강의 수
            Set<String> activeCourses = getActiveCoursesWithHeartbeat();
            status.put("activeCoursesCount", activeCourses.size());
            status.put("activeCourses", activeCourses);

            // 전체 대기열 수 (샘플링)
            int totalQueuesCount = countKeysByPattern("queue:*", 1000);
            status.put("totalQueuesCount", totalQueuesCount);
            status.put("totalQueuesNote", totalQueuesCount >= 1000 ? "1000개 이상 (제한됨)" : "정확한 개수");

            // 전체 임시 예약 수 (샘플링)
            int tempReservationsCount = countKeysByPattern("temp_reservation:*", 1000);
            status.put("tempReservationsCount", tempReservationsCount);
            status.put("tempReservationsNote", tempReservationsCount >= 1000 ? "1000개 이상 (제한됨)" : "정확한 개수");

            // 전체 하트비트 수 (샘플링)
            int heartbeatsCount = countKeysByPattern("heartBeat:*", 1000);
            status.put("heartbeatsCount", heartbeatsCount);
            status.put("heartbeatsNote", heartbeatsCount >= 1000 ? "1000개 이상 (제한됨)" : "정확한 개수");

            status.put("lastUpdated", System.currentTimeMillis());
            status.put("status", "RUNNING");
            status.put("scanMethod", "SCAN 명령어 사용 (안전함)");

        } catch (Exception e) {
            log.error("스케줄러 상태 조회 중 오류", e);
            status.put("status", "ERROR");
            status.put("error", e.getMessage());
        }

        return status;
    }

    // 대기열 위치 업데이트 브로드캐스트
    private void broadcastQueuePositionUpdate(Long courseSeq, Long scheduleId, String queueKey) {
        Set<Object> allMembers = redisTemplate.opsForZSet().range(queueKey, 0, -1);
        Long totalInQueue = redisTemplate.opsForZSet().zCard(queueKey);
        
        if (allMembers != null && !allMembers.isEmpty()) {
            int position = 1;
            for (Object memberObj : allMembers) {
                String memberNo = String.valueOf(memberObj);
                
                Map<String, Object> queueData = new HashMap<>();
                queueData.put("type", "queue_update");
                queueData.put("position", position);
                queueData.put("totalInQueue", totalInQueue);
                queueData.put("estimatedWaitTime", (position - 1) * 30); // 30초당 1명 처리 가정
                queueData.put("scheduleId", scheduleId);
                
                // 개별 사용자에게 위치 정보 전송
                queueWebSocketHandler.sendQueueUpdate(String.valueOf(courseSeq), memberNo, queueData);
                
                position++;
            }
            
            log.debug(" 대기열 위치 업데이트 전송 - 강의: {}, 스케줄: {}, 총 {}명",
                    courseSeq, scheduleId, totalInQueue);
        }
    }

    // 활성 강의 등록/해제 메서드 추가
    public void registerActiveCourse(Long courseSeq) {
        redisTemplate.opsForSet().add(ACTIVE_COURSES_KEY, courseSeq.toString());
        redisTemplate.expire(ACTIVE_COURSES_KEY, Duration.ofHours(24)); // 24시간 후 자동 만료
        log.debug("활성 강의 등록: {}", courseSeq);
    }
    
    public void unregisterActiveCourse(Long courseSeq) {
        redisTemplate.opsForSet().remove(ACTIVE_COURSES_KEY, courseSeq.toString());
        log.debug("활성 강의 해제: {}", courseSeq);
    }
    
    // 대기열 처리 시 더 효율적인 배치 처리
    private void processCourseQueuesOptimized(Long courseSeq) {
        try {
            // 하트비트 체크를 피하고 바로 스케줄 큐 처리
            String pattern = "queue:course:" + courseSeq + ":schedule:*";
            Set<String> scheduleQueues = redisTemplate.keys(pattern);
            
            if (scheduleQueues == null || scheduleQueues.isEmpty()) {
                return;
            }
            
            // 파이프라인을 사용한 배치 처리
            redisTemplate.executePipelined((org.springframework.data.redis.core.RedisCallback<Object>) connection -> {
                scheduleQueues.stream()
                    .limit(20)  // 강의당 최대 20개 스케줄
                    .forEach(queueKey -> {
                        connection.zSetCommands().zCard(queueKey.getBytes());
                    });
                return null;
            });
        } catch (Exception e) {
            log.error("최적화된 강의 처리 중 오류: {}", courseSeq, e);
        }
    }

}
