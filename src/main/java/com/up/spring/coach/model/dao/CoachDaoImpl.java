package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class CoachDaoImpl implements CoachDao {
    @Override
    public int deleteCurrBySectionSeq(SqlSession sqlSession, long sectionSeq) {
        return sqlSession.delete("coach.deleteCurrBySectionSeq", sectionSeq);
    }

    @Override
    public int deleteSectionByCourseSeq(SqlSession sqlSession, long courseSeq) {
        return sqlSession.delete("coach.deleteSectionByCourseSeq", courseSeq);
    }

    @Override
    public int deleteCourseByCourseSeq(SqlSession sqlSession, long courseSeq) {
        return sqlSession.delete("coach.deleteCourseByCourseSeq", courseSeq);
    }

    @Override
    public List<Category> getCategoryAll(SqlSession sqlSession) {
        return sqlSession.selectList("coach.getCategoryAll");
    }
    @Override
    public Long insertTempCourse(SqlSession sqlSession, Course course) {
        return (long) sqlSession.insert("coach.insertTempCourse",course);
    }

    @Override
    public List<Section> getSectionList(SqlSession sqlSession, Long courseSeq) {
        return sqlSession.selectList("coach.getSectionList",courseSeq);
    }

    @Override
    public int insertSection(SqlSession sqlSession, Section section) {
        return sqlSession.insert("coach.insertSection",section);
    }

    @Override
    public int insertCurriculum(SqlSession sqlSession, Curriculum curriculum) {
        return sqlSession.insert("coach.insertCurriculum",curriculum);
    }

    @Override
    public List<Map<String, Object>> getDashboardInfo(SqlSession sqlSession, Long memberNo) {
        return sqlSession.selectList("coach.getDashboardInfo",memberNo);
    }

    @Override
    public List<Map<String, Object>> getMonthlyEarnings(SqlSession sqlSession, Long memberNo) {
        return sqlSession.selectList("coach.getMonthlyEarnings",memberNo);
    }
}
