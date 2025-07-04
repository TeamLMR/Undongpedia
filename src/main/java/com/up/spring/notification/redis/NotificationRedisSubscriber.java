package com.up.spring.notification.redis;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.up.spring.notification.model.dto.NotificationMessage;
import com.up.spring.notification.websocket.NotificationWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.data.redis.listener.PatternTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationRedisSubscriber implements MessageListener {

    private final RedisMessageListenerContainer container;
    private final NotificationWebSocketHandler wsHandler;
    private final ObjectMapper objectMapper;

    @PostConstruct
    public void subscribe() {
        // @class 필드 무시하도록 설정
        objectMapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

        container.addMessageListener(this, new PatternTopic("notifications:*"));
        log.info("레디스 시작");
    }

    @Override
    public void onMessage(Message message, byte[] pattern) {
        String channel = new String(message.getChannel(), StandardCharsets.UTF_8); // notifications:123
        String body = new String(message.getBody(), StandardCharsets.UTF_8);

        try {
            Long memberNo = Long.parseLong(channel.split(":")[1]);
            NotificationMessage dto = objectMapper.readValue(body, NotificationMessage.class);

            /* WebSocket push */
            wsHandler.sendNotification(memberNo, dto);

        } catch (Exception e) {
            log.error(" Redis 구독 메시지 처리 실패: channel={}, body={}", channel, body, e);
        }

    }
}
