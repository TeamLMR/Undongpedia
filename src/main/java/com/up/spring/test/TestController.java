package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestController {

    private final RedisTestService redisTestService;
    private final KafkaTestService kafkaTestService;

    /**
     * Redis 테스트 엔드포인트들
     */
    @GetMapping("/redis/basic")
    public ResponseEntity<String> testRedisBasic() {
        redisTestService.testBasicOperations();
        return ResponseEntity.ok("Redis 기본 연산 테스트 완료 - 로그를 확인하세요");
    }

    @PostMapping("/redis/seat-reservation")
    public ResponseEntity<Map<String, String>> testSeatReservation(
            @RequestParam String seatId,
            @RequestParam String userId) {

        redisTestService.testSeatReservation(seatId, userId);

        Map<String, String> response = new HashMap<>();
        response.put("message", "좌석 예약 테스트 완료");
        response.put("seatId", seatId);
        response.put("userId", userId);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/redis/waiting-queue")
    public ResponseEntity<String> testWaitingQueue(
            @RequestParam String eventId,
            @RequestParam String userId) {

        redisTestService.testWaitingQueue(eventId, userId);
        return ResponseEntity.ok("대기열 테스트 완료");
    }

    @GetMapping("/redis/ranking")
    public ResponseEntity<String> testRanking() {
        redisTestService.testRankingSystem();
        return ResponseEntity.ok("랭킹 시스템 테스트 완료");
    }

    @GetMapping("/redis/cache/{facilityId}")
    public ResponseEntity<String> testCache(@PathVariable String facilityId) {
        redisTestService.testCachePattern(facilityId);
        return ResponseEntity.ok("캐시 패턴 테스트 완료");
    }

    @PostMapping("/redis/transaction")
    public ResponseEntity<String> testRedisTransaction(
            @RequestParam String fromUser,
            @RequestParam String toUser,
            @RequestParam int points) {

        redisTestService.testTransaction(fromUser, toUser, points);
        return ResponseEntity.ok("트랜잭션 테스트 완료");
    }

    @DeleteMapping("/redis/cleanup")
    public ResponseEntity<String> cleanupRedis() {
        redisTestService.cleanup();
        return ResponseEntity.ok("Redis 테스트 데이터 정리 완료");
    }

    /**
     * Kafka 테스트 엔드포인트들
     */
    @GetMapping("/kafka/basic")
    public ResponseEntity<String> testKafkaBasic() {
        kafkaTestService.testBasicSend();
        return ResponseEntity.ok("Kafka 기본 메시지 전송 테스트 완료");
    }

    @GetMapping("/kafka/async")
    public ResponseEntity<String> testKafkaAsync() {
        kafkaTestService.testAsyncSend();
        return ResponseEntity.ok("Kafka 비동기 메시지 전송 테스트 시작");
    }

    @PostMapping("/kafka/reservation-event")
    public ResponseEntity<Map<String, String>> publishReservationEvent(
            @RequestParam String userId,
            @RequestParam String seatId,
            @RequestParam String eventType) {

        kafkaTestService.publishReservationEvent(userId, seatId, eventType);

        Map<String, String> response = new HashMap<>();
        response.put("message", "예약 이벤트 발행 완료");
        response.put("eventType", eventType);
        response.put("userId", userId);
        response.put("seatId", seatId);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/kafka/transaction")
    public ResponseEntity<String> testKafkaTransaction() {
        try {
            kafkaTestService.testTransactionalSend();
            return ResponseEntity.ok("Kafka 트랜잭션 테스트 성공");
        } catch (Exception e) {
            return ResponseEntity.ok("Kafka 트랜잭션 테스트 실패 (예상된 동작)");
        }
    }

    @GetMapping("/kafka/batch")
    public ResponseEntity<String> testKafkaBatch() {
        kafkaTestService.testBatchSend();
        return ResponseEntity.ok("Kafka 배치 전송 테스트 시작");
    }

    /**
     * 통합 시나리오 테스트
     */
    @PostMapping("/scenario/complete-reservation")
    public ResponseEntity<Map<String, Object>> completeReservationScenario(
            @RequestParam String userId,
            @RequestParam String seatId) {

        log.info("=== 예약 전체 시나리오 테스트 시작 ===");

        Map<String, Object> result = new HashMap<>();

        try {
            // 1. Redis로 좌석 잠금 및 예약
            redisTestService.testSeatReservation(seatId, userId);
            result.put("step1", "좌석 잠금 완료");

            // 2. Kafka로 예약 생성 이벤트 발행
            kafkaTestService.publishReservationEvent(userId, seatId, "RESERVATION_CREATED");
            result.put("step2", "예약 생성 이벤트 발행");

            // 3. 결제 요청 이벤트 발행
            Thread.sleep(1000); // 시뮬레이션을 위한 지연
            kafkaTestService.publishReservationEvent(userId, seatId, "PAYMENT_REQUESTED");
            result.put("step3", "결제 요청 이벤트 발행");

            // 4. 예약 확정 이벤트 발행
            Thread.sleep(1000);
            kafkaTestService.publishReservationEvent(userId, seatId, "RESERVATION_CONFIRMED");
            result.put("step4", "예약 확정 이벤트 발행");

            result.put("status", "SUCCESS");
            result.put("message", "예약 시나리오 완료");

        } catch (Exception e) {
            log.error("시나리오 실행 중 오류", e);
            result.put("status", "FAILED");
            result.put("error", e.getMessage());
        }

        return ResponseEntity.ok(result);
    }

    /**
     * 헬스체크
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        Map<String, String> health = new HashMap<>();

        try {
            // Redis 연결 확인
            redisTestService.testBasicOperations();
            health.put("redis", "OK");
        } catch (Exception e) {
            health.put("redis", "FAIL: " + e.getMessage());
        }

        try {
            // Kafka 연결 확인
            kafkaTestService.testBasicSend();
            health.put("kafka", "OK");
        } catch (Exception e) {
            health.put("kafka", "FAIL: " + e.getMessage());
        }

        health.put("status", health.containsValue("FAIL") ? "UNHEALTHY" : "HEALTHY");

        return ResponseEntity.ok(health);
    }
}