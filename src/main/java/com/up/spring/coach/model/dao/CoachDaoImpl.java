package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CoachDaoImpl implements CoachDao {

    @Override
    public List<Category> getCategoryAll(SqlSession sqlSession) {
        return sqlSession.selectList("coach.getCategoryAll");
    }
    @Override
    public Long insertTempCourse(SqlSession sqlSession, Course course) {
        return (long) sqlSession.insert("coach.insertTempCourse",course);
    }
}
