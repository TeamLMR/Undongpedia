package com.up.spring.course.model.dao;

import com.up.spring.course.model.dto.Course;
import org.apache.ibatis.session.SqlSession;

public interface CourseDao {
    Course searchById(SqlSession sqlSession, long courseSeq);
}
