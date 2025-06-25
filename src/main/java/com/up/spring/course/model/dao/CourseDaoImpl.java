package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.Course;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

@Repository
public class CourseDaoImpl implements CourseDao {
    @Override
    public Course searchById(SqlSession sqlSession, long courseSeq) {
        return sqlSession.selectOne("course.searchById", courseSeq);
    }
}
