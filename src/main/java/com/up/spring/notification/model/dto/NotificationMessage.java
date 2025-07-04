package com.up.spring.notification.model.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class NotificationMessage {
    private Long id;
    private String type;
    private String title;
    private String content;
    private String link;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    private int unreadCount;

    public static NotificationMessage of(Notification notification, int unreadCount){
        return NotificationMessage.builder()
                .id(notification.getNotificationId())
                .type(notification.getNotificationType())
                .title(notification.getNotificationTitle())
                .content(notification.getNotificationContent())
                .link(notification.getNotificationLink())
                .createdAt(notification.getCreatedAt())
                .unreadCount(unreadCount)
                .build();
    }
}
