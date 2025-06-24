package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@Slf4j
@RequiredArgsConstructor
public class IntegratedTestService {

    private final RedisTemplate<String, Object> redisTemplate;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final RedissonClient redissonClient;

    private final AtomicInteger totalAttempts = new AtomicInteger(0);
    private final AtomicInteger redisSuccess = new AtomicInteger(0);
    private final AtomicInteger kafkaSuccess = new AtomicInteger(0);
    private final AtomicInteger totalSuccess = new AtomicInteger(0);

    @Async("taskExecutor")
    public CompletableFuture<Map<String, Object>> processReservation(String userId, String seatId) {
        Map<String, Object> result = new HashMap<>();
        int attemptNumber = totalAttempts.incrementAndGet();

        long startTime = System.currentTimeMillis();

        try {
            // 1단계: Redis 좌석 예약
            boolean redisResult = reserveSeat(seatId, userId);
            result.put("redisSuccess", redisResult);

            if (redisResult) {
                redisSuccess.incrementAndGet();

                // 2단계: Kafka 이벤트 발행
                boolean kafkaResult = publishEvents(userId, seatId);
                result.put("kafkaSuccess", kafkaResult);

                if (kafkaResult) {
                    kafkaSuccess.incrementAndGet();
                    totalSuccess.incrementAndGet();
                }
            }

            long duration = System.currentTimeMillis() - startTime;
            result.put("duration", duration);
            result.put("attemptNumber", attemptNumber);

        } catch (Exception e) {
            log.error("예약 처리 실패: {}", e.getMessage());
            result.put("error", e.getMessage());
        }

        return CompletableFuture.completedFuture(result);
    }

    private boolean reserveSeat(String seatId, String userId) {
        String lockKey = "lock:seat:" + seatId;
        RLock lock = redissonClient.getFairLock(lockKey);

        try {
            // 빠른 실패를 위해 짧은 타임아웃
            if (lock.tryLock(1, 1, TimeUnit.SECONDS)) {
                try {
                    // 이미 예약되었는지 확인
                    if (redisTemplate.hasKey("seat:" + seatId)) {
                        return false;
                    }

                    // 예약 정보 저장
                    Map<String, Object> reservation = new HashMap<>();
                    reservation.put("userId", userId);
                    reservation.put("seatId", seatId);
                    reservation.put("timestamp", System.currentTimeMillis());
                    reservation.put("status", "RESERVED");

                    redisTemplate.opsForValue().set("seat:" + seatId, reservation, 10, TimeUnit.MINUTES);
                    return true;

                } finally {
                    lock.unlock();
                }
            }
        } catch (Exception e) {
            log.error("Redis 예약 실패: {}", e.getMessage());
        }
        return false;
    }

    private boolean publishEvents(String userId, String seatId) {
        try {
            Map<String, Object> event = new HashMap<>();
            event.put("eventId", UUID.randomUUID().toString());
            event.put("userId", userId);
            event.put("seatId", seatId);
            event.put("timestamp", System.currentTimeMillis());

            // 1. 예약 생성 이벤트
            event.put("eventType", "RESERVATION_CREATED");
            kafkaTemplate.send("reservation-events", seatId, event).get(1, TimeUnit.SECONDS);

            // 2. 결제 요청 이벤트
            event.put("eventType", "PAYMENT_REQUESTED");
            event.put("amount", 50000);
            kafkaTemplate.send("payment-events", seatId, event).get(1, TimeUnit.SECONDS);

            // 3. 알림 이벤트
            event.put("eventType", "NOTIFICATION_SENT");
            kafkaTemplate.send("notification-events", userId, event).get(1, TimeUnit.SECONDS);

            return true;
        } catch (Exception e) {
            log.error("Kafka 이벤트 발행 실패: {}", e.getMessage());
            return false;
        }
    }

    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalAttempts", totalAttempts.get());
        stats.put("redisSuccess", redisSuccess.get());
        stats.put("kafkaSuccess", kafkaSuccess.get());
        stats.put("totalSuccess", totalSuccess.get());
        stats.put("redisSuccessRate",
                totalAttempts.get() > 0 ? (redisSuccess.get() * 100.0 / totalAttempts.get()) : 0);
        stats.put("kafkaSuccessRate",
                redisSuccess.get() > 0 ? (kafkaSuccess.get() * 100.0 / redisSuccess.get()) : 0);
        return stats;
    }
}
