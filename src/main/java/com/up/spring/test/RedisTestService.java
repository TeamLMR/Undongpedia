package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class RedisTestService {

    private final RedisTemplate<String, Object> redisTemplate;

    @Autowired
    @Qualifier("reservationRedisTemplate")
    private RedisTemplate<String, Object> reservationRedisTemplate;

    private final RedissonClient redissonClient;

    /**
     * 1. 기본 String 연산 테스트
     */
    public void testBasicOperations() {
        log.info("=== Redis 기본 연산 테스트 시작 ===");

        // SET/GET 테스트
        String key = "test:user:1";
        Map<String, Object> userData = new HashMap<>();
        userData.put("name", "홍길동");
        userData.put("age", 30);
        userData.put("registeredAt", LocalDateTime.now().toString());

        redisTemplate.opsForValue().set(key, userData);
        log.info("데이터 저장 완료: {}", userData);

        Object retrieved = redisTemplate.opsForValue().get(key);
        log.info("데이터 조회 결과: {}", retrieved);

        // TTL 설정 테스트
        String tempKey = "test:temp:session";
        redisTemplate.opsForValue().set(tempKey, "임시 세션 데이터", 10, TimeUnit.SECONDS);
        log.info("TTL 10초로 설정된 데이터 저장");

        Long ttl = redisTemplate.getExpire(tempKey);
        log.info("남은 TTL: {}초", ttl);
    }

    /**
     * 2. 좌석 예약 시뮬레이션 (분산 락 사용)
     */
    public void testSeatReservation(String seatId, String userId) {
        log.info("=== 좌석 예약 테스트 시작 - 좌석: {}, 사용자: {} ===", seatId, userId);

        String lockKey = "lock:seat:" + seatId;
        RLock lock = redissonClient.getFairLock(lockKey);

        try {
            // 10초 동안 락 획득 시도, 최대 5초 동안 락 유지
            boolean isLocked = lock.tryLock(10, 5, TimeUnit.SECONDS);

            if (isLocked) {
                log.info("락 획득 성공!");

                // 좌석이 이미 예약되었는지 확인
                String seatKey = "seat:" + seatId;
                Object existingReservation = reservationRedisTemplate.opsForValue().get(seatKey);

                if (existingReservation != null) {
                    log.warn("이미 예약된 좌석입니다: {}", existingReservation);
                    return;
                }

                // 예약 정보 저장
                Map<String, Object> reservation = new HashMap<>();
                reservation.put("userId", userId);
                reservation.put("seatId", seatId);
                reservation.put("reservedAt", LocalDateTime.now().toString());
                reservation.put("status", "RESERVED");

                // 예약 정보는 10분간 유지 (임시 예약)
                reservationRedisTemplate.opsForValue().set(seatKey, reservation, 600, TimeUnit.SECONDS);
                log.info("좌석 예약 완료: {}", reservation);

                // 사용자의 예약 목록에 추가
                String userReservationKey = "user:reservation:" + userId;
                reservationRedisTemplate.opsForSet().add(userReservationKey, seatId);

            } else {
                log.warn("락 획득 실패 - 다른 사용자가 예약 중입니다");
            }

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("예약 중 인터럽트 발생", e);
        } finally {
            if (lock.isHeldByCurrentThread()) {
                lock.unlock();
                log.info("락 해제 완료");
            }
        }
    }

    /**
     * 3. 대기열 시스템 테스트
     */
    public void testWaitingQueue(String eventId, String userId) {
        log.info("=== 대기열 시스템 테스트 - 이벤트: {}, 사용자: {} ===", eventId, userId);

        String queueKey = "queue:event:" + eventId;

        // 대기열에 사용자 추가
        Long position = redisTemplate.opsForList().rightPush(queueKey, userId);
        log.info("대기열 추가 완료 - 현재 위치: {}", position);

        // 대기열 크기 확인
        Long queueSize = redisTemplate.opsForList().size(queueKey);
        log.info("현재 대기열 크기: {}", queueSize);

        // 대기열에서 순서대로 처리 (FIFO)
        String nextUser = (String) redisTemplate.opsForList().leftPop(queueKey);
        log.info("다음 처리할 사용자: {}", nextUser);
    }

    /**
     * 4. 실시간 랭킹 시스템 테스트 (Sorted Set)
     */
    public void testRankingSystem() {
        log.info("=== 실시간 랭킹 시스템 테스트 ===");

        String rankingKey = "ranking:reservation:count";

        // 예약 수 업데이트
        redisTemplate.opsForZSet().incrementScore(rankingKey, "체육관A", 5);
        redisTemplate.opsForZSet().incrementScore(rankingKey, "체육관B", 3);
        redisTemplate.opsForZSet().incrementScore(rankingKey, "체육관C", 8);
        redisTemplate.opsForZSet().incrementScore(rankingKey, "체육관D", 2);

        // 상위 3개 조회
        Set<Object> top3 = redisTemplate.opsForZSet().reverseRange(rankingKey, 0, 2);
        log.info("TOP 3 체육관: {}", top3);

        // 특정 체육관의 순위 조회
        Long rank = redisTemplate.opsForZSet().reverseRank(rankingKey, "체육관B");
        log.info("체육관B 순위: {}위", rank != null ? rank + 1 : "순위 없음");
    }

    /**
     * 5. 캐시 패턴 테스트
     */
    public void testCachePattern(String facilityId) {
        log.info("=== 캐시 패턴 테스트 - 시설 ID: {} ===", facilityId);

        String cacheKey = "cache:facility:" + facilityId;

        // 캐시 조회
        Object cachedData = redisTemplate.opsForValue().get(cacheKey);

        if (cachedData != null) {
            log.info("캐시 히트! 데이터: {}", cachedData);
        } else {
            log.info("캐시 미스! DB에서 조회 시뮬레이션...");

            // DB 조회 시뮬레이션
            Map<String, Object> facilityData = new HashMap<>();
            facilityData.put("id", facilityId);
            facilityData.put("name", "운동시설 " + facilityId);
            facilityData.put("address", "서울시 강남구");
            facilityData.put("loadedAt", LocalDateTime.now().toString());

            // 캐시에 저장 (1시간 TTL)
            redisTemplate.opsForValue().set(cacheKey, facilityData, 1, TimeUnit.HOURS);
            log.info("캐시에 저장 완료: {}", facilityData);
        }
    }

    /**
     * 6. 트랜잭션 테스트
     */
    public void testTransaction(String fromUser, String toUser, int points) {
        log.info("=== Redis 트랜잭션 테스트 - {}에서 {}로 {}포인트 이체 ===",
                fromUser, toUser, points);

        try {
            // 트랜잭션 시작
            reservationRedisTemplate.multi();

            String fromKey = "points:" + fromUser;
            String toKey = "points:" + toUser;

            // 포인트 차감 및 추가
            reservationRedisTemplate.opsForValue().increment(fromKey, -points);
            reservationRedisTemplate.opsForValue().increment(toKey, points);

            // 트랜잭션 실행
            reservationRedisTemplate.exec();
            log.info("트랜잭션 완료!");

        } catch (Exception e) {
            reservationRedisTemplate.discard();
            log.error("트랜잭션 실패", e);
        }
    }

    /**
     * 모든 테스트 키 정리
     */
    public void cleanup() {
        log.info("=== 테스트 데이터 정리 ===");
        Set<String> keys = redisTemplate.keys("test:*");
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
            log.info("{}개의 테스트 키 삭제 완료", keys.size());
        }
    }
}