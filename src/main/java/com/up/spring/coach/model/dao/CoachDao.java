package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import org.apache.ibatis.session.SqlSession;

import java.util.List;
import java.util.Map;

public interface CoachDao {
    List<Category> getCategoryAll(SqlSession sqlSession);
    Long insertTempCourse(SqlSession sqlSession, Course course);
    List<Section> getSectionList(SqlSession sqlSession, Long courseSeq);
    int insertSection(SqlSession sqlSession, Section section);
    int insertCurriculum(SqlSession sqlSession, Curriculum curriculum);
    List<Map<String, Object>> getDashboardInfo(SqlSession sqlSession, Long memberNo);
    List<Map<String, Object>> getMonthlyEarnings(SqlSession sqlSession, Long memberNo);
    int deleteCurrBySectionSeq (SqlSession sqlSession, long sectionSeq);
    int deleteSectionByCourseSeq (SqlSession sqlSession, long courseSeq);
    int deleteCourseByCourseSeq (SqlSession sqlSession, long courseSeq);
}
