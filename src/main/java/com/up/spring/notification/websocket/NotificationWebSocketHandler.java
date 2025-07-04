package com.up.spring.notification.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.up.spring.notification.model.dto.Notification;
import com.up.spring.notification.model.dto.NotificationMessage;
import com.up.spring.notification.model.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;

import java.io.IOException;
import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 *   /ws/notification?memberNo={로그인사용자번호}
 *   └─ 1:1 단일 채널(WebSocketSession) 관리
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationWebSocketHandler implements WebSocketHandler {

    private final ObjectMapper objectMapper;
    private final NotificationService notificationService;  // 최초 unreadCount·최근 N개 조회용

    /* 세션 레지스트리 */
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    private final Map<String, String> sessionToUser     = new ConcurrentHashMap<>();

    /* ① 연결 수립 */
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        String memberNo = extractMemberNo(session);
        if (memberNo == null) {
            log.warn("❌ memberNo 파라미터 누락, WebSocket 종료: uri={}", session.getUri());
            session.close();
            return;
        }

        userSessions.put(memberNo, session);
        sessionToUser.put(session.getId(), memberNo);
        log.info("🔌 알림 WS 연결: memberNo={}", memberNo);

        /* 접속 직후 unreadCount · 최근 10개 알림 전송 */
        int unread = notificationService.countUnread(Long.valueOf(memberNo));
        List<Notification> recent = notificationService.selectNotifications(
                Map.of("memberNo", Long.valueOf(memberNo),
                        "cPage", 1,
                        "numPerPage", 10));
        sendMessage(session, Map.of(
                "type", "bootstrap",
                "unreadCount", unread,
                "notifications", recent
        ));
    }

    /* ② 클라이언트 메시지 (하트비트 등) */
    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) {
        log.debug("📨 알림 WS 메시지 수신: {}", message.getPayload());
    }

    /* ③ 에러 처리 */
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        log.error("🚨 알림 WS 오류: sessionId={}", session.getId(), exception);
        cleanup(session);
    }

    /* ④ 연결 종료 */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        log.info("🔌 알림 WS 종료: sessionId={}, status={}", session.getId(), status);
        cleanup(session);
    }

    @Override
    public boolean supportsPartialMessages() {
        return false;
    }

    /* ──────────────────────────────────────────────────
       외부(Redis Subscriber 등)에서 호출하는 푸시 메서드
       ────────────────────────────────────────────────── */
    public void sendNotification(Long memberNo, NotificationMessage dto) {
        WebSocketSession session = userSessions.get(String.valueOf(memberNo));
        if (session != null && session.isOpen()) {
            sendMessage(session, Map.of(
                    "type", "notification",
                    "data", dto
            ));
        } else {
            log.debug("세션이 닫혀 있어 푸시 생략: memberNo={}", memberNo);
        }
    }

    public void sendUnreadCount(Long memberNo, int unread) {
        WebSocketSession session = userSessions.get(String.valueOf(memberNo));
        if (session != null && session.isOpen()) {
            sendMessage(session, Map.of(
                    "type", "unread_count",
                    "unreadCount", unread
            ));
        }
    }

    /* ────────────────────────────────────────────────── */

    private void sendMessage(WebSocketSession session, Object payload) {
        try {
            String json = objectMapper.writeValueAsString(payload);
            session.sendMessage(new TextMessage(json));
        } catch (IOException e) {
            log.error("알림 WS 전송 실패: sessionId={}", session.getId(), e);
        }
    }

    private String extractMemberNo(WebSocketSession session) {
        URI uri = session.getUri();
        if (uri == null || uri.getQuery() == null) return null;
        for (String param : uri.getQuery().split("&")) {
            if (param.startsWith("memberNo=")) {
                return param.substring("memberNo=".length());
            }
        }
        return null;
    }

    private void cleanup(WebSocketSession session) {
        String memberNo = sessionToUser.remove(session.getId());
        if (memberNo != null) {
            userSessions.remove(memberNo);
        }
    }
}