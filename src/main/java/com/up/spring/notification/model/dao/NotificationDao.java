package com.up.spring.notification.model.dao;

import com.up.spring.notification.model.dto.Notification;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

public interface NotificationDao {
    int insertNotification(SqlSession sqlSession, Notification notification);

    List<Notification> selectNotifications(SqlSession sqlSession, Map<String, Object> params);

    int countUnread(SqlSession sqlSession, Long memberNo);

    int markAsRead(SqlSession sqlSession, Long notificationId);

    int markAllRead(SqlSession sqlSession, Long memberNo);

    int deleteNotification(SqlSession sqlSession, Long notificationId);

    /**
     * 중복 알림 여부 확인 (memberNo + type + link 기준)
     */
    int existsNotification(SqlSession sqlSession, Notification notification);
}
