package com.up.spring.notification.model.dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    private Long notificationId;
    private Long memberNo;
    private String notificationType;
    private String notificationTitle;
    private String notificationContent;
    private String notificationLink;
    private String isRead;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
}
