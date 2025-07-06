package com.up.spring.notification.controller;

import com.up.spring.notification.model.dto.Notification;
import com.up.spring.notification.model.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notification")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;


    @GetMapping
    public ResponseEntity<Map<String, Object>> getNotifications(
            @RequestParam Long memberNo,
            @RequestParam(defaultValue = "1") int cPage,
            @RequestParam(defaultValue = "10") int numPerPage,
            @RequestParam(required = false) String isRead) {

        Map<String, Object> params = new HashMap<>();
        params.put("memberNo", memberNo);
        params.put("cPage", cPage);
        params.put("numPerPage", numPerPage);
        if (isRead != null) params.put("isRead", isRead);

        List<Notification> list = notificationService.selectNotifications(params);
        int unreadCount = notificationService.countUnread(memberNo);

        Map<String, Object> body = Map.of(
                "notifications", list,
                "unreadCount", unreadCount
        );
        return ResponseEntity.ok(body);
    }


    @GetMapping("/unread-count")
    public ResponseEntity<Integer> getUnreadCount(@RequestParam Long memberNo) {
        return ResponseEntity.ok(notificationService.countUnread(memberNo));
    }


    @PutMapping("/{notificationId}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long notificationId) {
        notificationService.markAsRead(notificationId);
        return ResponseEntity.ok().build();
    }


    @PutMapping("/readAll")
    public ResponseEntity<Void> markAllRead(@RequestParam Long memberNo) {
        notificationService.markAllRead(memberNo);
        return ResponseEntity.ok().build();
    }


    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Void> deleteNotification(@PathVariable Long notificationId) {
        notificationService.deleteNotification(notificationId);
        return ResponseEntity.ok().build();
    }
} 