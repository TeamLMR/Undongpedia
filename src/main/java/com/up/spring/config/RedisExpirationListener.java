package com.up.spring.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@Slf4j
@RequiredArgsConstructor
public class RedisExpirationListener implements MessageListener {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Override
    public void onMessage(Message message, byte[] pattern) {
        try {
            // 만료된 키 이름 추출
            String expiredKey = new String(message.getBody());
            String channel = new String(message.getChannel());
            
            log.debug("Redis 키 만료 이벤트 수신 - 채널: {}, 키: {}", channel, expiredKey);
            
            // 장바구니 만료 키인지 확인
            if (expiredKey.startsWith("cart_expiry:")) {
                String tempReservationId = expiredKey.replace("cart_expiry:", "");
                handleCartExpiry(tempReservationId);
            }
            // 임시예약 만료 키인지 확인 (추가 안전장치)
            else if (expiredKey.startsWith("temp_reservation:")) {
                String tempReservationId = expiredKey.replace("temp_reservation:", "");
                handleReservationExpiry(tempReservationId);
            }
            
        } catch (Exception e) {
            log.error("Redis 키 만료 이벤트 처리 중 오류 발생", e);
        }
    }

    /**
     * 장바구니 만료 처리
     */
    private void handleCartExpiry(String tempReservationId) {
        try {
            log.info("🗑️ 장바구니 만료 처리 시작 - tempReservationId: {}", tempReservationId);
            
            // Kafka로 장바구니 만료 이벤트 발행
            Map<String, Object> event = Map.of(
                "eventType", "CART_EXPIRED",
                "tempReservationId", tempReservationId,
                "timestamp", System.currentTimeMillis()
            );
            
            kafkaTemplate.send("reservation-events", event);
            log.info("✅ 장바구니 만료 이벤트 발행 완료 - tempReservationId: {}", tempReservationId);
            
        } catch (Exception e) {
            log.error("장바구니 만료 이벤트 발행 실패 - tempReservationId: {}", tempReservationId, e);
        }
    }

    /**
     * 임시예약 만료 처리 (추가 안전장치)
     */
    private void handleReservationExpiry(String tempReservationId) {
        try {
            log.info("⏰ 임시예약 만료 감지 - tempReservationId: {}", tempReservationId);
            
            // Kafka로 임시예약 만료 이벤트 발행
            Map<String, Object> event = Map.of(
                "eventType", "TEMP_RESERVATION_EXPIRED",
                "tempReservationId", tempReservationId,
                "timestamp", System.currentTimeMillis()
            );
            
            kafkaTemplate.send("reservation-events", event);
            log.info("✅ 임시예약 만료 이벤트 발행 완료 - tempReservationId: {}", tempReservationId);
            
        } catch (Exception e) {
            log.error("임시예약 만료 이벤트 발행 실패 - tempReservationId: {}", tempReservationId, e);
        }
    }
} 