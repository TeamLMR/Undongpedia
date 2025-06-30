package com.up.spring.reservation.service;

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

@Service
@RequiredArgsConstructor
@Slf4j
public class QueueSchedulerService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final ReservationRedisService reservationRedisService;

    // 자동 대기열 (5초)

    @Scheduled(fixedDelay = 1000)
    public void processAllQueues() {
//        log.debug("==대기열 처리 시작==");
        Set<String> activeCourses = getActiveCoursesWithHeartbeat();

        if (activeCourses.isEmpty()) {
//            log.debug("대기열 활성강의가 없습니다.");
            return;
        }

        log.info("대기열 활성강의 {}개 : {}", activeCourses.size(), activeCourses);

        for (String courseKey : activeCourses) {
            Long courseSeq = extractCourseSeqFromHeartbeatKey(courseKey);
            if (courseSeq != null) {
                processCourseQueues(courseSeq);
            }
        }

        performLightCleanup();

//        log.debug("==대기열 처리 완료==");

    }

    private void processCourseQueues(Long courseSeq) {
        log.debug("{}: 대기열 처리시작", courseSeq);

        reservationRedisService.cleanUpInactiveMembers(courseSeq);

        if (!reservationRedisService.shouldActivateQueue(courseSeq)) {
            log.debug("{} : 대기열 비활성 상태", courseSeq);
            return;
        }

        Set<String> scheduleQueues = getScheduleQueuesForCourse(courseSeq);
        if (scheduleQueues.isEmpty()) {
            log.debug("{} : 처리할 스케줄대기열이 없습니다", courseSeq);
            return;
        }

        log.info("강의{} - {}개 스케쥴 대기열 처리", courseSeq, scheduleQueues.size());
        for (String queueKey : scheduleQueues) {
            Long scheduleId = extractScheduleIdFromQueueKey(queueKey);
            if (scheduleId != null) {
                processScheduleQueue(courseSeq, scheduleId, queueKey);
            }
        }

    }

    private void processScheduleQueue(Long courseSeq, Long scheduleId, String queueKey) {

        Long queueSize = redisTemplate.opsForZSet().zCard(queueKey);
        if (queueSize == null || queueSize == 0) {
            log.debug("{} : 대기열이 비어있습니다.", scheduleId);
            return;
        }

        log.debug("{} : 대기열처리 - 대기인원 {}명", scheduleId, queueSize);

        Set<Object> firstMemberSet = redisTemplate.opsForZSet().range(queueKey, 0, 0);

        if (firstMemberSet == null || firstMemberSet.isEmpty()) {
            log.debug("{} : 첫번째 사용자를 찾을 수 없습니다.", scheduleId);
            return;
        }
        Object firstMemberObj = firstMemberSet.iterator().next();
        int memberNo;
        if (firstMemberObj instanceof String) {
            memberNo = Integer.parseInt((String) firstMemberObj);
        } else if (firstMemberObj instanceof Number) {
            memberNo = ((Number) firstMemberObj).intValue();
        } else {
            return;
        }

        if (!isUserStillActive(courseSeq, memberNo)) {
            log.info("스케쥴{} : 사용자{} 비활선상태, 대기열에서 제거", scheduleId, memberNo);
            redisTemplate.opsForZSet().remove(queueKey, firstMemberObj);
        }

        boolean reservationCreated = createTemporaryReservationForUser(courseSeq, scheduleId, memberNo);

        if (reservationCreated) {
            Long removed = redisTemplate.opsForZSet().remove(queueKey, firstMemberObj);
            log.info("스케쥴{}, 사용자{} : 임시예약 생성, 대기열 제거 제거 여부 :{}", scheduleId, memberNo, removed);

            Long remainingCount = redisTemplate.opsForZSet().zCard(queueKey);
            log.info("스케쥴{} : 남은 대기인원 {} 명", scheduleId, remainingCount);
        } else {
            log.warn("스케쥴{}, 사용자{} 임시예약 생성 실패", scheduleId, memberNo);
        }


    }

    private boolean createTemporaryReservationForUser(Long courseSeq, Long scheduleId, int memberNo) {
        Map<String, Object> reservationData = new HashMap<>();
        reservationData.put("courseSeq", courseSeq);
        reservationData.put("scheduleId", scheduleId);
        reservationData.put("memberNo", memberNo);

        Map<String, Object> result = reservationRedisService.createTemporaryReservation(reservationData);

        Boolean success = (Boolean) result.get("success");
        String message = (String) result.get("message");

        if (Boolean.TRUE.equals(success)) {
            log.info("사용자{} : 임시예약 성공: {}", scheduleId, message);
            return true;
        } else {
            log.warn("사용자{} : 임시예약 실패 : {}", scheduleId, message);
            return false;
        }

    }

    private boolean isUserStillActive(Long courseSeq, int memberNo) {

        String heartbeatKey = "heartBeat:course:" + courseSeq;

        Double lastHeartbeatScore = redisTemplate.opsForZSet().score(heartbeatKey, memberNo);

        if (lastHeartbeatScore == null) {
            return false;
        }

        long lastHeartbeatTime = lastHeartbeatScore.longValue();
        long currentTime = System.currentTimeMillis();

        return (currentTime - lastHeartbeatTime) <= 1000 * 60;
    }

    private Set<String> getActiveCoursesWithHeartbeat() {

        //keys 명령어는 작업을 블로킹하고 진행, O(N)의 시간이 걸림 따라서 사용 지양
//        Set<String> heartbeatKeys = redisTemplate.keys("heartbeat:course:*");
        Set<String> activeKeys = new HashSet<>();
        try {
            ScanOptions scanOptions = ScanOptions.scanOptions()
                    .match("heartBeat:course:*")
                    .count(100) //스캔할 키 갯수
                    .build();
            try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
                while (cursor.hasNext()) {
                    String key = cursor.next();

                    Long size = redisTemplate.opsForZSet().size(key);
                    if (size != null && size > 0) {
                        activeKeys.add(key);
                    }
                    if (activeKeys.size() >= 1000) {
                        log.warn("키가 너무 많습니다.");
                        break;
                    }
                }
            }

        } catch (Exception e) {
            log.error("scan 오류", e);
        }
        return activeKeys;
    }

    private Set<String> getScheduleQueuesForCourse(Long courseSeq) {
        Set<String> activeQueues = new HashSet<>();

        try {
            String pattern = "queue:course:" + courseSeq + ":schedule:*";

            ScanOptions scanOptions = ScanOptions.scanOptions()
                    .match(pattern)
                    .count(100)     // 대기열 개수 추후 조정예정
                    .build();

            try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
                while (cursor.hasNext()) {
                    String key = cursor.next();
                    Long size = redisTemplate.opsForZSet().size(key);
                    if (size != null && size > 0) {
                        activeQueues.add(key);
                    }

                    if (activeQueues.size() >= 200) {
                        log.warn("강의{} 의 스케쥴이 너무 많습니다.", courseSeq);
                        break;
                    }
                }
            }
            log.debug("강의{} : 활성 대기열 {}개", courseSeq, activeQueues.size());
        } catch (Exception e) {
            log.error("scan 사용 강의{} : 오류 {}", courseSeq, e.getMessage());
        }
        return activeQueues;
    }

    private Long extractCourseSeqFromHeartbeatKey(String heartbeatKey) {
        String[] parts = heartbeatKey.split(":");
        if (parts.length >= 3) {
            return Long.parseLong(parts[2]);
        } else {
            log.warn("강의 번호 추출 실패 : {}", heartbeatKey);
            return null;
        }
    }

    private Long extractScheduleIdFromQueueKey(String queueKey) {
        String[] parts = queueKey.split(":");
        if (parts.length >= 5) {
            return Long.parseLong(parts[4]);
        } else {
            log.warn("스케줄 ID 추출실패 : {}", queueKey);
            return null;
        }
    }

    private void performLightCleanup() {
        int tempReservationCount = countKeysByPattern("temp_reservation:*", 10);
        if (tempReservationCount > 0) {
            log.debug("임시예약 {} 개", tempReservationCount);
        }
    }

    @Scheduled(fixedRate = 60 * 60 * 1000)
    public void performHeavyCleanupTasks() {
        log.info("==작업 정리 시작(주기 1시간)");

        cleanupExpiredTemporaryReservations();

        cleanupOldHeartbeats();

        cleanupEmptyQueues();

        log.info("==작업 정리 완료(주기 1시간)==");

    }

    public void cleanupExpiredTemporaryReservations() {
        int cleanedCount = 0;
        ScanOptions scanOptions = ScanOptions.scanOptions()
                .match("temp_reservation:*")
                .count(100)
                .build();

        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext()) {
                String key = cursor.next();
                Long ttl = redisTemplate.getExpire(key, TimeUnit.SECONDS);
                if (/*ttl != null*/ ttl <= 0) {
                    redisTemplate.delete(key);
                    cleanedCount++;
                }
                if (cleanedCount >= 1000) {
                    log.warn("너무 많이 지웠지롱");
                    break;
                }
            }
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
                if (removedCount!=null && removedCount > 0) {
                    totalCleaned +=removedCount.intValue();
                }

                Long size = redisTemplate.opsForZSet().zCard(key);  //zCard의 별칭 -> size
                if (size != null && size > 0) {
                    redisTemplate.delete(key);
                }

                if(totalCleaned >=10000){
                    log.warn("너무 많이 정리했어");
                    break;
                }
            }
            if(totalCleaned >0){
                log.info("하트비트{} 개 정리 완료", totalCleaned);
            }
        }

    }
    private void cleanupEmptyQueues(){
        int cleanedCount = 0;
        ScanOptions scanOptions = ScanOptions.scanOptions()
                .match("queue:*")
                .count(100)
                .build();
        try (Cursor<String> cursor = redisTemplate.scan(scanOptions)) {
            while (cursor.hasNext()) {
                String key = cursor.next();

                Long size = redisTemplate.opsForZSet().zCard(key);
                if (size != null && size > 0) {
                    redisTemplate.delete(key);
                    cleanedCount++;
                }

                if (cleanedCount >= 1000) {
                    log.warn("너무 많이 정리했지롱");
                    break;
                }
            }
            if(cleanedCount >0){
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
            while (cursor.hasNext() && count < maxCount) {
                cursor.next();
                count++;
            }
        }
        return count;
    }

    /**
     * 스케줄러 상태 조회 (모니터링용)
     * 현재 처리 중인 대기열들의 상태를 반환합니다.
     * SCAN을 사용하여 안전하게 통계를 수집합니다.
     *
     * @return 스케줄러 상태 정보
     */
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
}
