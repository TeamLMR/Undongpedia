package com.up.spring.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Course {
    private Long courseSeq; //시퀀스
    private String courseTitle; //제목
    private String courseContent; //내용
    private int courseCategory; //카테고리번호
    private int courseDifficult; //난이도
    private int coursePrice; // 가격
    private int courseDiscount; // 할인율
    private String courseThumbnail; // 썸네일
    private String courseTarget; // 교육대상
    private String coursePreparation; // 준비물
    private Timestamp courseCreateTime; // 생성일
    private Timestamp courseConfirmTime; // 승인일
    private int memberNo;
    private String courseExpose;
    private String courseType; // Check (COURSE_TYPE IN ('ON','OFF','EVENT')) 코스 온라인 오프라인 이벤트(오프라인 실시간예약)
    private String memberNickname;
    private String cateValue;
    
    // 리뷰 관련 필드
    private Double avgRating;      // 평점 평균 (없으면 0.0)
    private Integer reviewCount;   // 리뷰 개수 (없으면 0)
}
