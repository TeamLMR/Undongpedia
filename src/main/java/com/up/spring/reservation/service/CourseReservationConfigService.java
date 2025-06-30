package com.up.spring.reservation.service;

import com.up.spring.reservation.dto.CourseReservationConfig;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

public interface CourseReservationConfigService {
    
    // 조회
    Optional<CourseReservationConfig> getConfigByCourseSeq(Long courseSeq);
    
    CourseReservationConfig getConfigByConfigId(Long configId);
    
    List<CourseReservationConfig> getAllConfigs();
    
    // 비즈니스 로직
    String getReservationMode(Long courseSeq);
    
    boolean isEventCourse(Long courseSeq);
    
    boolean isOpenTime(Long courseSeq);
    
    boolean canEnterWaitingRoom(Long courseSeq);
    
    int getMaxConcurrentUsers(Long courseSeq);
    
    // 스케줄러용
    List<CourseReservationConfig> getCoursesToOpen();
    
    List<CourseReservationConfig> getWaitingRoomAvailableCourses();
    
    // 등록/수정/삭제
    boolean createConfig(CourseReservationConfig config);
    
    boolean updateConfig(CourseReservationConfig config);
    
    boolean deleteConfig(Long configId);
    
    boolean activateConfig(Long configId);
    
    boolean deactivateConfig(Long configId);
} 