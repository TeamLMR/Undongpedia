package com.up.spring.notification.model.service;

import com.up.spring.notification.model.dto.Notification;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

public interface NotificationService {
    int insertNotification(Notification notification);

    List<Notification> selectNotifications(Map<String, Object> params);

    int countUnread(Long memberNo);

    int markAsRead(Long notificationId);

    int markAllRead(Long memberNo);

    int deleteNotification(Long notificationId);
}
