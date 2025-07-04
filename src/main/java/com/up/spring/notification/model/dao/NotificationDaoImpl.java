package com.up.spring.notification.model.dao;

import com.up.spring.notification.model.dto.Notification;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class NotificationDaoImpl implements NotificationDao {
    @Override
    public int insertNotification(SqlSession sqlSession, Notification notification) {
        return sqlSession.insert("notification.insertNotification", notification);
    }

    @Override
    public List<Notification> selectNotifications(SqlSession sqlSession, Map<String, Object> params) {
        return sqlSession.selectList("notification.selectNotifications", params);
    }

    @Override
    public int countUnread(SqlSession sqlSession, Long memberNo) {
        return sqlSession.selectOne("notification.countUnread", memberNo);
    }

    @Override
    public int markAsRead(SqlSession sqlSession, Long notificationId) {
        return sqlSession.update("notification.markAsRead", notificationId);
    }

    @Override
    public int markAllRead(SqlSession sqlSession, Long memberNo) {
        return sqlSession.update("notification.markAllRead", memberNo);
    }

    @Override
    public int deleteNotification(SqlSession sqlSession, Long notificationId) {
        return sqlSession.update("notification.deleteNotification", notificationId);
    }

    @Override
    public int existsNotification(SqlSession sqlSession, Notification notification) {
        return sqlSession.selectOne("notification.existsNotification", notification);
    }
}
