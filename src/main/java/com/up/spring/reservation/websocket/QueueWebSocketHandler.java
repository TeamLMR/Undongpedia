package com.up.spring.reservation.websocket;

import org.springframework.stereotype.Component;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.net.URI;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

@Component
@Slf4j
public class QueueWebSocketHandler extends TextWebSocketHandler {

    private final Map<Long, CopyOnWriteArraySet<WebSocketSession>> courseSessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long courseSeq = getCourseSeqFromSession(session);
        if (courseSeq != null) {
            courseSessions.computeIfAbsent(courseSeq, k -> new CopyOnWriteArraySet<>()).add(session);
            log.info("웹소켓 연결성공 {}, {}", courseSeq, session.getId());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        Long courseSeq = getCourseSeqFromSession(session);
        if (courseSeq != null) {
            CopyOnWriteArraySet<WebSocketSession> sessions = courseSessions.get(courseSeq);
            if (sessions != null) {
                sessions.remove(session);
                log.info("웹소켓 연결 종료 {}, {}", courseSeq, session.getId());
            }
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("웹소켓 에러 - sessionId: {}", session.getId(), exception);
    }

    public void broadCastQueueUpdate(Long courseSeq, String message){
        CopyOnWriteArraySet<WebSocketSession> sessions = courseSessions.get(courseSeq);
        if (sessions != null && !sessions.isEmpty()) {
            log.info("대기열 상태 {} {}", courseSeq, sessions.size());
            sessions.forEach(session -> {
                if(session.isOpen()){
                    try{
                        session.sendMessage(new TextMessage(message));
                    } catch(IOException e){
                        log.error("메세지 전송 실패 {}", session.getId(), e);
                    }
                }

            });
        }
    }

    private Long getCourseSeqFromSession(WebSocketSession session) {
        URI uri=session.getUri();
        if(uri!=null) {
            String query=uri.getQuery();
            if(query!=null) {
                String[] params=query.split("&");
                for(String param:params) {
                    String[] keyValue=param.split("=");
                    if(keyValue.length==2 && "courseSeq".equals(keyValue[0])) {
                        return Long.parseLong(keyValue[1]);
                    }
                }
            }
        }
        return null;
    }

    public int getConnectedSessionCount(Long courseSeq) {
        CopyOnWriteArraySet<WebSocketSession> sessions = courseSessions.get(courseSeq);
        return sessions != null ? sessions.size() : 0;
    }
}
