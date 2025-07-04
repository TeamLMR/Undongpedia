package com.up.spring.notification.event;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.up.spring.notification.model.dto.Notification;
import com.up.spring.notification.model.dto.NotificationMessage;
import com.up.spring.notification.model.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@Slf4j
@RequiredArgsConstructor
public class NotificationEventHandler {

    private final NotificationService notificationService;
    private final RedisTemplate<String, Object> redisTemplate;
    private final ObjectMapper objectMapper;

    @KafkaListener(
            topics = {
                    "${kafka.topic.payment-events}",
                    "${kafka.topic.reservation-events}",
                    "${kafka.topic.user-events}"
            }, groupId = "notification-service", containerFactory = "kafkaListenerContainerFactory"
    )
    public void handleEvent(
            @Payload Map<String, Object> payload,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            Acknowledgment ack,
            ConsumerRecord<String, Object> record) {
        try {
            Notification notification = mapToNotification(topic, payload);
            if (notification == null) {
                ack.acknowledge();
                return;
            }
            notificationService.insertNotification(notification);

            int unread = notificationService.countUnread(notification.getMemberNo());
            NotificationMessage message = NotificationMessage.of(notification, unread);
            redisTemplate.convertAndSend(
                    "notifications:" + notification.getMemberNo(),
                    message
            );
            ack.acknowledge();

        } catch (Exception e) {
            log.error("카프카 알림 실패 record={}", record, e);
        }
    }

    private Notification mapToNotification(String topic, Map<String, Object> payload) {

        /*
         * 공통 전처리 : memberNo가 없거나 파싱할 수 없는 경우 알림을 만들지 않는다.
         * 일부 시스템 이벤트(ex. CART_EXPIRED, TEMP_RESERVATION_EXPIRED)는 회원 번호가 없으므로
         * Null 검사로 빠르게 종료해 NumberFormatException을 방지한다.
         */
        Long memberNo = null;
        Object memberObj = payload.get("memberNo");
        if (memberObj != null) {
            try {
                memberNo = Long.valueOf(String.valueOf(memberObj));
            } catch (NumberFormatException ignored) {
                // 파싱 실패 시 null 유지
            }
        }

        if (memberNo == null) {
            // memberNo 가 없는 이벤트는 알림 대상이 없으므로 처리하지 않음
            return null;
        }

        switch (topic) {
            case "payment-events":
                String evtType = String.valueOf(payload.get("eventType"));
                return Notification.builder()
                        .memberNo(memberNo)
                        .notificationType(evtType)
                        .notificationTitle("결제가 완료되었습니다!")
                        .notificationContent(
                                payload.get("courseName") + "의 결제가 완료되었습니다. 결제금액 : " + payload.get("totalPayAmount") + "원"
                        )
                        .notificationLink("/payment/end")
                        .build();
            case "reservation-events":
                String evRaw = String.valueOf(payload.get("eventType"));
                String evBase = evRaw.contains(":" ) ? evRaw.substring(0, evRaw.indexOf(':')) : evRaw;
                if ("TEMP_RESERVATION_CREATED".equals(evBase)) {
                    String tempResId = String.valueOf(payload.get("tempReservationId"));
                    return Notification.builder()
                            .memberNo(memberNo)
                            .notificationType(evRaw)
                            .notificationTitle("임시예약이 완료되었습니다")
                            .notificationContent("결제를 10분 안에 완료해주세요.")
                            .notificationLink("/undongpedia/cart?tempReservationId=" + tempResId)
                            .build();
                }
                return Notification.builder()
                        .memberNo(memberNo)
                        .notificationType(evRaw)
                        .notificationTitle("예약 상태가 변경되었습니다")
                        .notificationContent("예약 번호 " + payload.get("reservationId") + " 상태: " + evRaw)
                        .notificationLink("/reservation/detail?reservationId=" + payload.get("reservationId"))
                        .build();

            case "user-events":
                return Notification.builder()
                        .memberNo(memberNo)
                        .notificationType((String) payload.get("eventType"))
                        .notificationTitle((String) payload.get("title"))
                        .notificationContent((String) payload.get("message"))
                        .notificationLink((String) payload.getOrDefault("link", "/"))
                        .build();

        }
        return null;
    }
}
