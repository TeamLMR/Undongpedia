package com.up.spring.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.listener.PatternTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;

@Configuration
@Slf4j
@RequiredArgsConstructor
public class RedisListenerConfig {

    private final RedisExpirationListener redisExpirationListener;

    @Bean
    public RedisMessageListenerContainer redisMessageListenerContainer(
            RedisConnectionFactory connectionFactory) {
        
        RedisMessageListenerContainer container = new RedisMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
        

        container.addMessageListener(redisExpirationListener, 
            new PatternTopic("__keyevent@*__:expired"));
        
        log.info("Redis 키 만료 이벤트 리스너 등록 완료");
        
        return container;
    }
} 