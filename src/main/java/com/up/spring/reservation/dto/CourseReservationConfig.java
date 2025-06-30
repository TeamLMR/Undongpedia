package com.up.spring.reservation.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Date;
import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourseReservationConfig {
    
    private Long configId;                    // CONFIG_ID
    private Long courseSeq;                   // COURSE_SEQ (외래키)
    private Timestamp openDateTime;           // OPEN_DATE_TIME
    private Integer maxConcurrentUsers;       // MAX_CONCURRENT_USERS (기본값: 20)
    private Integer waitingRoomOpenMinutes;   // WAITING_ROOM_OPEN_MINUTES (기본값: 10)
    private String isActive;                  // IS_ACTIVE ('Y'/'N', 기본값: 'Y')
    private Timestamp createdAt;              // CREATED_AT
    private Timestamp updatedAt;              // UPDATED_AT
    
    // Boolean 헬퍼 메서드들
    public boolean getIsActiveBoolean() {
        return "Y".equals(this.isActive);
    }
    
    public void setIsActiveBoolean(boolean active) {
        this.isActive = active ? "Y" : "N";
    }
    
    // 대기실 오픈 가능 시간 계산
    public Timestamp getWaitingRoomOpenTime() {
        if (openDateTime == null || waitingRoomOpenMinutes == null) {
            return null;
        }
        return new Timestamp(openDateTime.getTime() - (waitingRoomOpenMinutes * 60 * 1000));
    }
    
    // 오픈 시간 확인
    public boolean isOpenNow() {
        if (openDateTime == null) return true;
        return new Timestamp(System.currentTimeMillis()).after(openDateTime);
    }
    
    // 대기실 입장 가능 확인
    public boolean canEnterWaitingRoom() {
        Timestamp waitingRoomTime = getWaitingRoomOpenTime();
        if (waitingRoomTime == null) return false;
        return new Timestamp(System.currentTimeMillis()).after(waitingRoomTime);
    }
    
    // 빌더 패턴 기본값 설정
    public static class CourseReservationConfigBuilder {
        public CourseReservationConfigBuilder() {
            this.maxConcurrentUsers = 20;
            this.waitingRoomOpenMinutes = 10;
            this.isActive = "Y";
        }
    }
} 