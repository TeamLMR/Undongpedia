package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.kafka.support.SendResult;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.util.concurrent.ListenableFutureCallback;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
@RequiredArgsConstructor
public class KafkaTestService {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Autowired
    @Qualifier("transactionalKafkaTemplate")
    private KafkaTemplate<String, Object> transactionalKafkaTemplate;

    /**
     * 1. 기본 메시지 전송 테스트
     */
    public void testBasicSend() {
        log.info("=== Kafka 기본 메시지 전송 테스트 ===");

        Map<String, Object> message = new HashMap<>();
        message.put("messageId", UUID.randomUUID().toString());
        message.put("content", "테스트 메시지입니다");
        message.put("timestamp", LocalDateTime.now().toString());

        // 동기 전송
        try {
            SendResult<String, Object> result = kafkaTemplate.send("test-topic", message).get();
            log.info("메시지 전송 성공 - Offset: {}, Partition: {}",
                    result.getRecordMetadata().offset(),
                    result.getRecordMetadata().partition());
        } catch (Exception e) {
            log.error("메시지 전송 실패", e);
        }
    }

    /**
     * 2. 비동기 메시지 전송 테스트
     */
    public void testAsyncSend() {
        log.info("=== Kafka 비동기 메시지 전송 테스트 ===");

        for (int i = 0; i < 10; i++) {
            Map<String, Object> message = new HashMap<>();
            message.put("id", i);
            message.put("message", "비동기 메시지 " + i);
            message.put("timestamp", LocalDateTime.now().toString());

            ListenableFuture<SendResult<String, Object>> future =
                    kafkaTemplate.send("test-topic", String.valueOf(i), message);

            int finalI = i;
            future.addCallback(new ListenableFutureCallback<SendResult<String, Object>>() {
                @Override
                public void onSuccess(SendResult<String, Object> result) {
                    log.info("메시지 {} 전송 성공 - Partition: {}, Offset: {}",
                            finalI,
                            result.getRecordMetadata().partition(),
                            result.getRecordMetadata().offset());
                }

                @Override
                public void onFailure(Throwable ex) {
                    log.error("메시지 {} 전송 실패", finalI, ex);
                }
            });
        }
    }

    /**
     * 3. 예약 이벤트 발행 테스트
     */
    public void publishReservationEvent(String userId, String seatId, String eventType) {
        log.info("=== 예약 이벤트 발행 - Type: {} ===", eventType);

        Map<String, Object> event = new HashMap<>();
        event.put("eventId", UUID.randomUUID().toString());
        event.put("eventType", eventType);
        event.put("userId", userId);
        event.put("seatId", seatId);
        event.put("timestamp", LocalDateTime.now().toString());
        event.put("status", "PENDING");

        // 이벤트 타입별 추가 정보
        switch (eventType) {
            case "RESERVATION_CREATED":
                event.put("expiresAt", LocalDateTime.now().plusMinutes(10).toString());
                break;
            case "PAYMENT_REQUESTED":
                event.put("amount", 50000);
                event.put("paymentMethod", "CARD");
                break;
            case "RESERVATION_CONFIRMED":
                event.put("confirmationNumber", "CONF-" + System.currentTimeMillis());
                break;
        }

        kafkaTemplate.send("reservation-events", seatId, event);
        log.info("예약 이벤트 발행 완료: {}", event);
    }

    /**
     * 4. 트랜잭션 메시지 전송 테스트
     */
    @Transactional("kafkaTransactionManager")
    public void testTransactionalSend() {
        log.info("=== Kafka 트랜잭션 메시지 전송 테스트 ===");

        try {
            // 트랜잭션 템플릿 사용
            for (int i = 0; i < 3; i++) {
                Map<String, Object> message = new HashMap<>();
                message.put("txId", UUID.randomUUID().toString());
                message.put("sequence", i);
                message.put("data", "트랜잭션 메시지 " + i);

                transactionalKafkaTemplate.send("transaction-test", message);
                log.info("트랜잭션 메시지 {} 전송", i);

                // 중간에 예외 발생 시뮬레이션 (주석 해제하면 롤백됨)
                // if (i == 1) throw new RuntimeException("트랜잭션 테스트 예외");
            }

            log.info("모든 트랜잭션 메시지 전송 완료");
        } catch (Exception e) {
            log.error("트랜잭션 실패 - 모든 메시지 롤백", e);
            throw e;
        }
    }

    /**
     * 5. 배치 메시지 전송 테스트
     */
    public void testBatchSend() {
        log.info("=== Kafka 배치 메시지 전송 테스트 ===");

        // 배치로 전송될 메시지들
        CompletableFuture<?>[] futures = new CompletableFuture[100];

        for (int i = 0; i < 100; i++) {
            Map<String, Object> message = new HashMap<>();
            message.put("batchId", i);
            message.put("data", "배치 데이터 " + i);

            ListenableFuture<SendResult<String, Object>> future =
                    kafkaTemplate.send("batch-test", String.valueOf(i % 10), message);

            futures[i] = future.completable();
        }

        // 모든 메시지 전송 완료 대기
        CompletableFuture.allOf(futures).thenRun(() -> {
            log.info("배치 메시지 전송 완료!");
        });
    }

    /**
     * 예약 이벤트 리스너
     */
    @KafkaListener(topics = "reservation-events",
            groupId = "reservation-service",
            containerFactory = "kafkaListenerContainerFactory")
    public void handleReservationEvent(@Payload Map<String, Object> event,
                                       @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
                                       @Header(KafkaHeaders.RECEIVED_PARTITION_ID) int partition,
                                       @Header(KafkaHeaders.OFFSET) long offset,
                                       Acknowledgment ack) {

        log.info("=== 예약 이벤트 수신 ===");
        log.info("Topic: {}, Partition: {}, Offset: {}", topic, partition, offset);
        log.info("Event: {}", event);

        try {
            String eventType = (String) event.get("eventType");

            switch (eventType) {
                case "RESERVATION_CREATED":
                    handleReservationCreated(event);
                    break;
                case "PAYMENT_REQUESTED":
                    handlePaymentRequested(event);
                    break;
                case "RESERVATION_CONFIRMED":
                    handleReservationConfirmed(event);
                    break;
                case "QUEUE_ENTERED":
                    handleQueueEntered(event);
                    break;
                case "TEMP_RESERVATION_CREATED":
                    handleTempReservationCreated(event);
                    break;
                case "RESERVATION_TURN":
                    handleReservationTurn(event);
                    break;
                default:
                    log.warn("알 수 없는 이벤트 타입: {}", eventType);
            }

            // 메시지 처리 완료 확인
            ack.acknowledge();
            log.info("메시지 처리 완료 및 커밋");

        } catch (Exception e) {
            log.error("이벤트 처리 실패", e);
            // 에러 발생 시 재처리를 위해 커밋하지 않음
        }
    }

    /**
     * 배치 리스너 테스트
     */
    @KafkaListener(topics = "batch-test",
            groupId = "batch-consumer-group",
            containerFactory = "batchKafkaListenerContainerFactory")
    public void handleBatch(List<ConsumerRecord<String, Object>> records,
                            Acknowledgment ack) {
        log.info("=== 배치 메시지 수신: {}건 ===", records.size());

        try {
            for (ConsumerRecord<String, Object> record : records) {
                log.debug("배치 메시지 - Key: {}, Value: {}", record.key(), record.value());
            }

            // 배치 처리 완료
            ack.acknowledge();
            log.info("배치 처리 완료");

        } catch (Exception e) {
            log.error("배치 처리 실패", e);
        }
    }

    // 이벤트 핸들러 메서드들
    private void handleReservationCreated(Map<String, Object> event) {
        log.info("예약 생성 이벤트 처리: {}", event.get("seatId"));
        // 예약 생성 로직
    }

    private void handlePaymentRequested(Map<String, Object> event) {
        log.info("결제 요청 이벤트 처리: 금액 {}", event.get("amount"));
        // 결제 처리 로직
    }

    private void handleReservationConfirmed(Map<String, Object> event) {
        log.info("예약 확정 이벤트 처리: {}", event.get("confirmationNumber"));
        // 예약 확정 로직
    }

    private void handleQueueEntered(Map<String, Object> event) {
        log.info("🎯 대기열 입장 이벤트 처리: 사용자 {}, 순서 {}/{}", 
                event.get("memberNo"), event.get("position"), event.get("totalInQueue"));
        // 대기열 입장 알림, 사용자 상태 업데이트 등
    }

    private void handleTempReservationCreated(Map<String, Object> event) {
        log.info("⏰ 임시 예약 생성 이벤트 처리: 사용자 {}, 임시예약ID {}", 
                event.get("memberNo"), event.get("tempReservationId"));
        // 임시 예약 알림, 결제 페이지 안내 등
    }

    private void handleReservationTurn(Map<String, Object> event) {
        log.info("🔔 예약 순서 도착 이벤트 처리: 사용자 {}, 강의 {}", 
                event.get("memberNo"), event.get("courseSeq"));
        // 사용자에게 예약 진행 알림, WebSocket 푸시 등
    }

    /**
     * DLQ (Dead Letter Queue) 처리
     */
    @KafkaListener(topics = "reservation-events.DLT",
            groupId = "dlt-processor")
    public void handleDeadLetter(ConsumerRecord<String, Object> record) {
        log.error("=== Dead Letter 메시지 수신 ===");
        log.error("Topic: {}, Partition: {}, Offset: {}",
                record.topic(), record.partition(), record.offset());
        log.error("Failed Message: {}", record.value());

        // DLQ 메시지 처리 (알림, 수동 처리 등)
    }
}