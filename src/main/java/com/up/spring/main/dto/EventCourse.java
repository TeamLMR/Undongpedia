package com.up.spring.main.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventCourse {
    
    // Course 기본 정보
    private Long courseSeq;
    private String courseTitle;
    private String courseContent;
    private int courseCategory;
    private int courseDifficult;
    private int coursePrice;
    private int courseDiscount;
    private String courseThumbnail;
    private String courseTarget;
    private String coursePreparation;
    private Timestamp courseCreateTime;
    private Timestamp courseConfirmTime;
    private int memberNo;
    private String courseExpose;
    private String courseType;
    private String memberNickname;
    private String cateValue;
    
    // CourseReservationConfig 정보
    private Long configId;
    private Timestamp openDateTime;
    private Integer maxConcurrentUsers;
    private Integer waitingRoomOpenMinutes;
    private String isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // 계산된 필드들
    private Timestamp waitingRoomOpenTime;
    private boolean canEnterWaitingRoom;
    private boolean isOpenNow;
    private long timeUntilOpen;  // 오픈까지 남은 시간 (밀리초)
    
    // 헬퍼 메서드들
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
    
    // 오픈까지 남은 시간 계산 (밀리초)
    public long getTimeUntilOpen() {
        if (openDateTime == null) return 0;
        long now = System.currentTimeMillis();
        long openTime = openDateTime.getTime();
        return Math.max(0, openTime - now);
    }
    
    // 할인된 가격 계산
    public int getDiscountedPrice() {
        return (int) (coursePrice * ((100.0 - courseDiscount) / 100.0));
    }
} 