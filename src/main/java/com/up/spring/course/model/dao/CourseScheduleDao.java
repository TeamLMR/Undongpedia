package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.CourseSchedule;
import org.apache.ibatis.session.SqlSession;

import java.sql.Date;
import java.util.List;
import java.util.Map;

public interface CourseScheduleDao {
    
    /**
     * 특정 강의의 모든 스케줄 조회 (미래 날짜만)
     */
    List<CourseSchedule> searchScheduleByCourseSeq(SqlSession sqlSession, long courseSeq);
    
    /**
     * 특정 강의의 특정 날짜 스케줄 조회
     */
    List<CourseSchedule> searchScheduleByDate(SqlSession sqlSession, Map<String, Object> params);
    
    /**
     * 예약 가능한 스케줄만 조회
     */
    List<CourseSchedule> searchAvailableSchedules(SqlSession sqlSession, long courseSeq);

    int searchTotalAvailableSchedules(SqlSession sqlSession, long courseSeq);

    Integer getAvailableSeats(SqlSession sqlSession, long scheduleId);

    int incrementBookedSeats(SqlSession sqlSession, long scheduleId);

    int decrementBookedSeats(SqlSession sqlSession, long scheduleId);

}
