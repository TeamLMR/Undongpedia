package com.up.spring.reservation.dao;

import com.up.spring.reservation.dto.CourseReservationConfig;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class CourseReservationConfigDaoImpl implements CourseReservationConfigDao {

    @Override
    public CourseReservationConfig selectByCourseSeq(SqlSession sqlSession, Long courseSeq) {
        return sqlSession.selectOne("courseReservationConfig.selectByCourseSeq", courseSeq);
    }

    @Override
    public CourseReservationConfig selectByConfigId(SqlSession sqlSession, Long configId) {
        return sqlSession.selectOne("courseReservationConfig.selectByConfigId", configId);
    }

    @Override
    public List<CourseReservationConfig> selectAll(SqlSession sqlSession) {
        return sqlSession.selectList("courseReservationConfig.selectAll");
    }

    @Override
    public List<CourseReservationConfig> selectCoursesToOpen(SqlSession sqlSession, Timestamp currentTime) {
        return sqlSession.selectList("courseReservationConfig.selectCoursesToOpen", currentTime);
    }

    @Override
    public List<CourseReservationConfig> selectWaitingRoomAvailable(SqlSession sqlSession, Timestamp currentTime) {
        return sqlSession.selectList("courseReservationConfig.selectWaitingRoomAvailable", currentTime);
    }

    @Override
    public int insert(SqlSession sqlSession, CourseReservationConfig config) {
        return sqlSession.insert("courseReservationConfig.insert", config);
    }

    @Override
    public int update(SqlSession sqlSession, CourseReservationConfig config) {
        return sqlSession.update("courseReservationConfig.update", config);
    }

    @Override
    public int delete(SqlSession sqlSession, Long configId) {
        return sqlSession.update("courseReservationConfig.delete", configId);
    }

    @Override
    public int updateActive(SqlSession sqlSession, Long configId, String isActive) {
        Map<String, Object> params = new HashMap<>();
        params.put("configId", configId);
        params.put("isActive", isActive);
        return sqlSession.update("courseReservationConfig.updateActive", params);
    }
} 