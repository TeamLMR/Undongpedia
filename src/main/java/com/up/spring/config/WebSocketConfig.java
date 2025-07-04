package com.up.spring.config;

import com.up.spring.reservation.websocket.QueueWebSocketHandler;
import com.up.spring.notification.websocket.NotificationWebSocketHandler;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

@Configuration
@EnableWebSocket
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer, WebSocketConfigurer {

    private final QueueWebSocketHandler queueWebSocketHandler;
    private final NotificationWebSocketHandler notificationWebSocketHandler;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        // 메시지 브로커 설정
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // STOMP 엔드포인트 설정
        registry.addEndpoint("/queue-websocket")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // 기본 WebSocket 핸들러 등록 (Spring Bean 사용)
        registry.addHandler(queueWebSocketHandler, "/queue-websocket")
                .setAllowedOriginPatterns("*");

        registry.addHandler(notificationWebSocketHandler, "/ws/notification")
                .setAllowedOriginPatterns("*");
    }
}
