package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import com.up.spring.coach.model.dto.CoachApply;
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
    int updateTempCourse(SqlSession sqlSession, Course course);

    // 코치 신청 목록 조회
    List<CoachApply> selectCoachApplyList(SqlSession session, Map<String, Object> params);

    // 상태별 코치 신청 카운트
    Map<String, Integer> selectCoachApplyCount(SqlSession session);

    // 코치 신청 상세 정보 조회
    CoachApply selectCoachApplyDetail(SqlSession session, Long coaSeq);

    // 코치 신청 상태 업데이트
    int updateCoachApplyStatus(SqlSession session, Map<String, Object> params);

    // 코치 신청 등록
    int insertCoachApply(SqlSession session, CoachApply coachApply);
}
