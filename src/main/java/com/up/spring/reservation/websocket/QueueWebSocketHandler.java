package com.up.spring.reservation.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.io.IOException;
import java.net.URI;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class QueueWebSocketHandler implements WebSocketHandler {

    private final ObjectMapper objectMapper = new ObjectMapper();
    
    // 사용자별 WebSocket 세션 관리
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    private final Map<String, String> sessionToUser = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String courseSeq = extractCourseSeq(session);
        String memberNo = extractMemberNo(session);

        log.info(" WebSocket 연결 시도 - URI: {}, courseSeq: {}, memberNo: {}",
            session.getUri(), courseSeq, memberNo);
        
        if (courseSeq != null && memberNo != null) {
            String userKey = courseSeq + ":" + memberNo;
            userSessions.put(userKey, session);
            sessionToUser.put(session.getId(), userKey);
            
            log.info("🔌 대기열 WebSocket 연결: courseSeq={}, memberNo={}", courseSeq, memberNo);
            
            // 연결 확인 메시지 전송
            sendMessage(session, Map.of(
                "type", "connected",
                "message", "대기열 연결 완료"
            ));
        } else {
            log.warn(" WebSocket 연결 실패: courseSeq={}, memberNo={}, URI={}",
                courseSeq, memberNo, session.getUri());
            session.close();
        }
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        // 하트비트나 기타 메시지 처리
        log.debug("📨 WebSocket 메시지 수신: {}", message.getPayload());
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("🚨 WebSocket 전송 오류: sessionId={}", session.getId(), exception);
        cleanup(session);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) throws Exception {
        String userKey = sessionToUser.get(session.getId());
        log.info("대기열 WebSocket 연결 종료: userKey={}, 상태={}", userKey, closeStatus);
        cleanup(session);
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }

    // 특정 사용자에게 대기열 업데이트 전송
    public void sendQueueUpdate(String courseSeq, String memberNo, Map<String, Object> queueData) {
        String userKey = courseSeq + ":" + memberNo;
        WebSocketSession session = userSessions.get(userKey);
        
        if (session != null && session.isOpen()) {
            Map<String, Object> message = Map.of(
                "type", "queue_update",
                "data", queueData
            );
            sendMessage(session, message);
        }
    }

    // 강의별 모든 사용자에게 브로드캐스트
    public void broadcastToQueue(String courseSeq, Map<String, Object> message) {
        userSessions.entrySet().stream()
            .filter(entry -> entry.getKey().startsWith(courseSeq + ":"))
            .forEach(entry -> {
                WebSocketSession session = entry.getValue();
                if (session.isOpen()) {
                    sendMessage(session, message);
                }
            });
    }

    /**
     * 임시예약 성공 시 특정 사용자에게 메시지 전송
     */
    public void sendTempReservationSuccess(String courseSeq, String memberNo, String tempReservationId, Long scheduleId) {
        String userKey = courseSeq + ":" + memberNo;
        WebSocketSession session = userSessions.get(userKey);
        
        if (session != null && session.isOpen()) {
            Map<String, Object> message = Map.of(
                "type", "temp_reservation_success",
                "tempReservationId", tempReservationId,
                "scheduleId", scheduleId,
                "courseSeq", Long.parseLong(courseSeq),
                "message", "임시예약이 완료되었습니다. 장바구니로 이동합니다."
            );
            sendMessage(session, message);
            log.info("임시예약 성공 메시지 전송 - userKey: {}, tempReservationId: {}", userKey, tempReservationId);
        } else {
            log.warn("임시예약 성공 메시지 전송 실패 - 세션을 찾을 수 없음: userKey={}", userKey);
        }
    }

    /**
     * 임시예약 실패 시 특정 사용자에게 메시지 전송
     */
    public void sendTempReservationFailed(String courseSeq, String memberNo, String reason, Map<String, Object> queueData) {
        String userKey = courseSeq + ":" + memberNo;
        WebSocketSession session = userSessions.get(userKey);
        
        if (session != null && session.isOpen()) {
            Map<String, Object> message = Map.of(
                "type", "temp_reservation_failed",
                "message", reason,
                "queueData", queueData != null ? queueData : Map.of()
            );
            sendMessage(session, message);
            log.info("임시예약 실패 메시지 전송 - userKey: {}, reason: {}", userKey, reason);
        } else {
            log.warn("임시예약 실패 메시지 전송 실패 - 세션을 찾을 수 없음: userKey={}", userKey);
        }
    }

    /**
     * 특정 사용자의 WebSocket 세션 조회
     */
    public WebSocketSession getUserSession(String courseSeq, String memberNo) {
        String userKey = courseSeq + ":" + memberNo;
        return userSessions.get(userKey);
    }

    private void sendMessage(WebSocketSession session, Map<String, Object> message) {
        try {
            String json = objectMapper.writeValueAsString(message);
            session.sendMessage(new TextMessage(json));
        } catch (IOException e) {
            log.error("메시지 전송 실패: sessionId={}", session.getId(), e);
        }
    }

    private String extractCourseSeq(WebSocketSession session) {
        URI uri = session.getUri();
        if (uri != null && uri.getQuery() != null) {
            String query = uri.getQuery();
            String[] params = query.split("&");
            for (String param : params) {
                if (param.startsWith("courseSeq=")) {
                    return param.substring("courseSeq=".length());
                }
            }
        }
        return null;
    }

    private String extractMemberNo(WebSocketSession session) {
        URI uri = session.getUri();
        if (uri != null && uri.getQuery() != null) {
            String query = uri.getQuery();
            String[] params = query.split("&");
            for (String param : params) {
                if (param.startsWith("memberNo=")) {
                    return param.substring("memberNo=".length());
                }
            }
        }
        return null;
    }

    private void cleanup(WebSocketSession session) {
        String userKey = sessionToUser.remove(session.getId());
        if (userKey != null) {
            userSessions.remove(userKey);
        }
    }
}
