package com.up.spring.main.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

public interface MainDao {
    List<Category> getCategorys(SqlSession session);
    List<Course> getCourseList(SqlSession session, Map<String, Object> params);
}
