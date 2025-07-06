package com.up.spring.coach.model.dao;

import com.up.spring.coach.model.dto.CoachPayment;
import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import com.up.spring.coach.model.dto.CoachApply;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class CoachDaoImpl implements CoachDao {
    private final SqlSession sqlSession;

    @Override
    public List<CoachPayment> selectPaymentListByMemberNo(SqlSession sqlSession, long memberNo) {
        return sqlSession.selectList("selectPaymentListByMemberNo", memberNo);
    }

    @Override
    public Curriculum selectCurrByCurrSeq(SqlSession sqlSession, long currSeq) {
        return sqlSession.selectOne("selectCurrByCurrSeq", currSeq);
    }

    @Override
    public Section getSection(SqlSession sqlSession, long courseSeq, long sectionSeq) {
        Map<String, Object> params = new HashMap<>();
        params.put("courseSeq", courseSeq);
        params.put("sectionSeq", sectionSeq);
        return sqlSession.selectOne("coach.getSection", params);
    }

    @Override
    public int deleteCurrByCurrSeq(SqlSession sqlSession, long currSeq) {
        return sqlSession.delete("coach.deleteCurrByCurrSeq", currSeq);
    }

    @Override
    public int deleteSectionBySectionSeq(SqlSession sqlSession, long sectionSeq) {
        return sqlSession.delete("coach.deleteSectionBySectionSeq", sectionSeq);
    }

    @Override
    public int updateTempCourse(SqlSession sqlSession, Course course) {
        return sqlSession.update("coach.updateTempCourse", course);
    }

    @Override
    public int updateCurrOrderBySectionSeqAfterDelete(SqlSession sqlSession, long sectionSeq) {
        return sqlSession.update("coach.updateCurrOrderBySectionSeqAfterDelete", sectionSeq);
    }

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

    @Override
    public List<CoachApply> selectCoachApplyList(SqlSession session, Map<String, Object> params) {
        return session.selectList("coach.selectCoachApplyList", params);
    }

    @Override
    public Map<String, Integer> selectCoachApplyCount(SqlSession session) {
        return session.selectOne("coach.selectCoachApplyCount");
    }

    @Override
    public CoachApply selectCoachApplyDetail(SqlSession session, Long coaSeq) {
        return session.selectOne("coach.selectCoachApplyDetail", coaSeq);
    }

    @Override
    public int updateCoachApplyStatus(SqlSession session, Map<String, Object> params) {
        return session.update("coach.updateCoachApplyStatus", params);
    }

    @Override
    public int insertCoachApply(SqlSession session, CoachApply coachApply) {
        return session.insert("coach.insertCoachApply", coachApply);
    }
}
