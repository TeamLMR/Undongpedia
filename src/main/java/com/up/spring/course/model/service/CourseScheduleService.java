package com.up.spring.course.model.service;

import com.up.spring.course.model.dto.CourseSchedule;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

public interface CourseScheduleService {
    
    /**
     * 특정 강의의 모든 스케줄 조회 (미래 날짜만)
     */
    List<CourseSchedule> searchScheduleByCourseSeq(long courseSeq);
    
    /**
     * 특정 강의의 특정 날짜 스케줄 조회
     */
    List<CourseSchedule> searchScheduleByDate(long courseSeq, LocalDate date);
    
    /**
     * 예약 가능한 스케줄만 조회
     */
    List<CourseSchedule> searchAvailableSchedules(long courseSeq);
}
