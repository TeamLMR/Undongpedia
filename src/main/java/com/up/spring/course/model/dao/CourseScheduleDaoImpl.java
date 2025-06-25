package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.CourseSchedule;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.util.List;
import java.util.Map;

@Repository
public class CourseScheduleDaoImpl implements CourseScheduleDao {
    @Override
    public List<CourseSchedule> searchScheduleByCourseSeq(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectList("courseSchedule.searchScheduleByCourseSeq", courseSeq);
    }
    
    @Override
    public List<CourseSchedule> searchScheduleByDate(SqlSession sqlSession, Map<String, Object> params) {
        return sqlSession.selectList("courseSchedule.searchScheduleByDate", params);
    }
    
    @Override
    public List<CourseSchedule> searchAvailableSchedules(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectList("courseSchedule.searchAvailableSchedules", courseSeq);
    }
}
