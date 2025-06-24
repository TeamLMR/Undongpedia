package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/api/test/reservation")
@RequiredArgsConstructor
public class TestReservationApiController {

    private final RedisTemplate<String, Object> redisTemplate;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @PostMapping
    public ResponseEntity<Map<String, Object>> makeReservation(@RequestBody Map<String, String> request) {
        String time = request.get("time");
        String date = request.get("date");
        String key = "reservation:test:" + date + ":" + time;
        Map<String, Object> response = new HashMap<>();

        try {
            // Redis에 예약 정보 저장 시도
            Boolean isSuccess = redisTemplate.opsForValue().setIfAbsent(key, "RESERVED");
            
            if (Boolean.TRUE.equals(isSuccess)) {
                // Kafka에 예약 이벤트 발행
                Map<String, Object> event = new HashMap<>();
                event.put("type", "RESERVATION");
                event.put("date", date);
                event.put("time", time);
                event.put("timestamp", System.currentTimeMillis());
                
                kafkaTemplate.send("test-reservation-events", key, event);

                response.put("success", true);
                response.put("message", "예약이 완료되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "이미 예약된 시간입니다.");
            }
        } catch (Exception e) {
            log.error("예약 처리 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "예약 처리 중 오류가 발생했습니다.");
        }

        return ResponseEntity.ok(response);
    }

    @GetMapping("/status")
    public ResponseEntity<List<Map<String, String>>> getReservationStatus(
            @RequestParam(required = false) String date) {
        
        // 날짜가 제공되지 않은 경우 오늘 날짜 사용
        if (date == null || date.isEmpty()) {
            date = java.time.LocalDate.now().toString();
        }
        
        String pattern = "reservation:test:" + date + ":*";
        Set<String> keys = redisTemplate.keys(pattern);
        
        List<Map<String, String>> reservations = keys.stream()
            .map(key -> {
                Map<String, String> reservation = new HashMap<>();
                String time = key.split(":")[3];
                reservation.put("time", time);
                return reservation;
            })
            .collect(Collectors.toList());

        return ResponseEntity.ok(reservations);
    }
} 