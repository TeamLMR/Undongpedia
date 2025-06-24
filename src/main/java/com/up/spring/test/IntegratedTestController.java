package com.up.spring.test;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping("/test/integrated")
@RequiredArgsConstructor
@Slf4j
public class IntegratedTestController {

    private final IntegratedTestService integratedTestService;

    @PostMapping("/reservation")
    public CompletableFuture<ResponseEntity<Map<String, Object>>> integratedReservation(
            @RequestParam String userId,
            @RequestParam String seatId) {

        return integratedTestService.processReservation(userId, seatId)
                .thenApply(ResponseEntity::ok);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        return ResponseEntity.ok(integratedTestService.getStats());
    }

    @PostMapping("/batch-test")
    public ResponseEntity<Map<String, Object>> batchTest(
            @RequestParam(defaultValue = "1000") int users,
            @RequestParam(defaultValue = "10") int seats) {

        List<CompletableFuture<Map<String, Object>>> futures = new ArrayList<>();
        List<String> seatIds = new ArrayList<>();

        // 좌석 생성
        for (int i = 1; i <= seats; i++) {
            seatIds.add("VIP-" + i);
        }

        // 사용자별 예약 시도
        for (int i = 0; i < users; i++) {
            String userId = "user" + i;
            String seatId = seatIds.get(i % seats);
            futures.add(integratedTestService.processReservation(userId, seatId));
        }

        // 모든 요청 완료 대기
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();

        Map<String, Object> result = integratedTestService.getStats();
        result.put("users", users);
        result.put("seats", seats);

        return ResponseEntity.ok(result);
    }
}
