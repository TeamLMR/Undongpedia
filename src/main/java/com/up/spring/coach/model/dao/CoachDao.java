package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface CoachDao {
    List<Category> getCategoryAll(SqlSession sqlSession);
    Long insertTempCourse(SqlSession sqlSession, Course course);
    List<Section> getSectionList(SqlSession sqlSession, Long courseSeq);
    int insertSection(SqlSession sqlSession, Section section);
    int insertCurriculum(SqlSession sqlSession, Curriculum curriculum);
}
