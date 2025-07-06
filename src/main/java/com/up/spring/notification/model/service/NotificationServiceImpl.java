package com.up.spring.notification.model.service;

import com.up.spring.notification.model.dao.NotificationDao;
import com.up.spring.notification.model.dto.Notification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final SqlSession sqlSession;
    private final NotificationDao notificationDao;


    @Override
    @Transactional
    public int insertNotification(Notification notification) {
        int dup = notificationDao.existsNotification(sqlSession, notification);
        if (dup > 0) {
            log.debug("중복 알림 스킵 - memberNo:{}, type:{}, link:{}",
                    notification.getMemberNo(), notification.getNotificationType(), notification.getNotificationLink());
            return 0;
        }
        return notificationDao.insertNotification(sqlSession, notification);
    }

    @Override
    public List<Notification> selectNotifications(Map<String, Object> params) {
        return notificationDao.selectNotifications(sqlSession, params);
    }

    @Override
    public int countUnread(Long memberNo) {
        return notificationDao.countUnread(sqlSession, memberNo);
    }

    @Override
    public int markAsRead(Long notificationId) {
        return notificationDao.markAsRead(sqlSession, notificationId);
    }

    @Override
    public int markAllRead(Long memberNo) {
        return notificationDao.markAllRead(sqlSession, memberNo);
    }

    @Override
    public int deleteNotification(Long notificationId) {
        return notificationDao.deleteNotification(sqlSession, notificationId);
    }
}
