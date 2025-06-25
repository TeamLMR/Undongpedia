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
    private String courseType; // Check (COURSE_TYPE IN ('ON','OFF')) 코스 온라인 오프라인
}
