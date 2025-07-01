package com.up.spring.payment.service;

import com.up.spring.payment.model.service.OfflineCartService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class CartExpiryEventHandler {

    private final OfflineCartService offlineCartService;

    @KafkaListener(topics = "reservation-events", groupId = "cart-expiry-group")
    public void handleReservationEvent(Map<String, Object> event) {
        try {
            String eventType = (String) event.get("eventType");
            
            if ("CART_EXPIRED".equals(eventType)) {
                handleCartExpired(event);
            } else if ("TEMP_RESERVATION_EXPIRED".equals(eventType)) {
                handleTempReservationExpired(event);
            }
            
        } catch (Exception e) {
            log.error("예약 이벤트 처리 중 오류 발생", e);
        }
    }

    /**
     * 장바구니 만료 이벤트 처리
     */
    private void handleCartExpired(Map<String, Object> event) {
        try {
            String tempReservationId = (String) event.get("tempReservationId");
            log.info("🗑️ 장바구니 만료 이벤트 처리 시작 - tempReservationId: {}", tempReservationId);
            
            // 오프라인 장바구니에서 해당 임시예약 ID로 된 항목들 삭제
            int deletedCount = offlineCartService.deleteByTempReservationId(tempReservationId);
            
            if (deletedCount > 0) {
                log.info("✅ 만료된 장바구니 삭제 완료 - tempReservationId: {}, 삭제된 항목 수: {}", 
                        tempReservationId, deletedCount);
            } else {
                log.debug("ℹ️ 삭제할 장바구니 항목이 없음 - tempReservationId: {}", tempReservationId);
            }
            
        } catch (Exception e) {
            log.error("장바구니 만료 처리 실패", e);
        }
    }

    /**
     * 임시예약 만료 이벤트 처리 (추가 안전장치)
     */
    private void handleTempReservationExpired(Map<String, Object> event) {
        try {
            String tempReservationId = (String) event.get("tempReservationId");
            log.info("⏰ 임시예약 만료 이벤트 처리 - tempReservationId: {}", tempReservationId);
            
            // 임시예약이 만료되면 연관된 장바구니도 함께 정리
            int deletedCount = offlineCartService.deleteByTempReservationId(tempReservationId);
            
            if (deletedCount > 0) {
                log.info("✅ 임시예약 만료로 인한 장바구니 정리 완료 - tempReservationId: {}, 삭제된 항목 수: {}", 
                        tempReservationId, deletedCount);
            }
            
        } catch (Exception e) {
            log.error("임시예약 만료 처리 실패", e);
        }
    }
} 