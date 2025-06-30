package com.up.spring.reservation.dao;

import com.up.spring.reservation.dto.CourseReservationConfig;
import org.apache.ibatis.session.SqlSession;

import java.sql.Timestamp;
import java.util.List;

public interface CourseReservationConfigDao {
    
    // 조회
    CourseReservationConfig selectByCourseSeq(SqlSession sqlSession, Long courseSeq);
    
    CourseReservationConfig selectByConfigId(SqlSession sqlSession, Long configId);
    
    List<CourseReservationConfig> selectAll(SqlSession sqlSession);
    
    // 오픈 시간이 된 강의들 조회
    List<CourseReservationConfig> selectCoursesToOpen(SqlSession sqlSession, Timestamp currentTime);
    
    // 대기실 입장 가능한 강의들 조회
    List<CourseReservationConfig> selectWaitingRoomAvailable(SqlSession sqlSession, Timestamp currentTime);
    
    // 등록
    int insert(SqlSession sqlSession, CourseReservationConfig config);
    
    // 수정
    int update(SqlSession sqlSession, CourseReservationConfig config);
    
    // 삭제 (논리삭제)
    int delete(SqlSession sqlSession, Long configId);
    
    // 활성화/비활성화
    int updateActive(SqlSession sqlSession, Long configId, String isActive);
} 