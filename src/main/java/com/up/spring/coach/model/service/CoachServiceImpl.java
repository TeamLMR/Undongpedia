package com.up.spring.coach.model.service;

import com.up.spring.coach.model.dao.CoachDao;
import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import com.up.spring.coach.model.dto.CoachApply;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class CoachServiceImpl implements CoachService {
    private final CoachDao coachDao;
    private final SqlSession sqlSession;

    @Override
    public Curriculum selectCurrByCurrSeq(long currSeq) {
        return coachDao.selectCurrByCurrSeq(sqlSession, currSeq);
    }

    @Override
    public Section getSection(long courseSeq, long sectionSeq) {
        return coachDao.getSection(sqlSession, courseSeq, sectionSeq);
    }

    @Override
    public int updateTempCourse(Course course) {
        return coachDao.updateTempCourse(sqlSession, course);
    }

    @Override
    public int deleteCurrByCurrSeq(long currSeq) {
        return coachDao.deleteCurrByCurrSeq(sqlSession, currSeq);
    }

    @Override
    public int deleteCurrBySectionSeq(long sectionSeq) {
        return coachDao.deleteCurrBySectionSeq(sqlSession, sectionSeq);
    }

    @Override
    public int deleteSectionByCourseSeq(long courseSeq) {
        return coachDao.deleteSectionByCourseSeq(sqlSession, courseSeq);
    }

    @Override
    public int deleteSectionBySectionSeq(long sectionSeq) {
        return coachDao.deleteSectionBySectionSeq(sqlSession, sectionSeq);
    }

    @Override
    public int updateCurrOrderBySectionSeqAfterDelete(long sectionSeq) {
        return coachDao.updateCurrOrderBySectionSeqAfterDelete(sqlSession, sectionSeq);
    }

    @Override
    public int deleteCourseByCourseSeq(long courseSeq) {
        return coachDao.deleteCourseByCourseSeq(sqlSession, courseSeq);
    }

    @Transactional
    public Map<String,Integer> delCurrAndUpdateCurrOrder(long sectionSeq, long currSeq){
        int deleteResultNum = deleteCurrByCurrSeq(currSeq);
        int updateResultNum = updateCurrOrderBySectionSeqAfterDelete(sectionSeq);
        log.debug("deleteCurrByCurrSeq:{}",deleteResultNum);
        log.debug("updateCurrOrderBySectionSeqAfterDelete:{}",updateResultNum);

        Map<String,Integer> result = new HashMap<>();
        result.put("deleteResult",deleteResultNum);
        result.put("updateResult",updateResultNum);
        return result;
    }

    @Transactional
    public Map<String,Integer> deleteSectionCascade(long courseSeq, long sectionSeq) {
        Section section =  getSection(courseSeq, sectionSeq);
        int deleteSectionNum = 0;
        int deleteCurrNum = 0;

        if (section != null) {
            //커리큘럼 삭제
            int deleteCurrResult = deleteCurrBySectionSeq(section.getSectionSeq());
            if (deleteCurrResult > 0) {
                deleteCurrNum += deleteCurrResult;
            }

            //섹션 삭제
            int deleteSectionBySectionSeq = deleteSectionBySectionSeq(sectionSeq);
            if (deleteSectionBySectionSeq > 0) {
                deleteSectionNum += deleteSectionBySectionSeq;
            }
        }

        Map<String,Integer> result = new HashMap<>();
        result.put("deleteCurrNum",deleteCurrNum);
        result.put("deleteSectionNum",deleteSectionNum);
        return result;
    }

    @Transactional
    public Map<String,Integer> deleteCourseCascade(long courseSeq) {
        List<Section> sectionList =  getSectionList(courseSeq);
        int deleteCurrNum = 0;
        int deleteSectionNum = 0;
        int deleteCourseNum = 0;

        if (!sectionList.isEmpty()) {
            //커리큘럼 삭제
            for (Section section : sectionList) {
                int deleteCurrResult = deleteCurrBySectionSeq(section.getSectionSeq());
                if (deleteCurrResult > 0) {
                    deleteCurrNum += deleteCurrResult;
                }
            }

            //섹션 삭제
            int deleteSectionResult = deleteSectionByCourseSeq(courseSeq);
            if (deleteSectionResult > 0) {
                deleteSectionNum += deleteSectionResult;
            }
        }
        //코스 삭제
        int deleteCourseResult = deleteCourseByCourseSeq(courseSeq);
        if (deleteCourseResult > 0) {
            deleteCourseNum += deleteCourseResult;
        }
        Map<String,Integer> result = new HashMap<>();
        result.put("deleteCurrNum",deleteCurrNum);
        result.put("deleteSectionNum",deleteSectionNum);
        result.put("deleteCourseNum",deleteCourseNum);
        return result;
    }

    @Override
    public List<Category> getCategoryAll() {
        return coachDao.getCategoryAll(sqlSession);
    }
    @Override
    public Long insertTempCourse(Course course) {
        return coachDao.insertTempCourse(sqlSession, course);
    }

    @Override
    public List<Section> getSectionList(Long corseSeq) {
        return coachDao.getSectionList(sqlSession, corseSeq);
    }

    @Override
    public int insertSection(Section section) {
        return coachDao.insertSection(sqlSession, section);
    }
    @Override
    public int insertCurriculum(Curriculum curriculum) {
        return coachDao.insertCurriculum(sqlSession, curriculum);
    }

    @Override
    public List<Map<String, Object>> getDashboardInfo(Long memberNo) {
        return coachDao.getDashboardInfo(sqlSession,memberNo);
    }

    @Override
    public List<Map<String, Object>> getMonthlyEarnings(Long memberNo) {
        return coachDao.getMonthlyEarnings(sqlSession,memberNo);
    }

    @Override
    public List<CoachApply> getCoachApplyList(Map<String, Object> params) {
        return coachDao.selectCoachApplyList(sqlSession, params);
    }

    @Override
    public Map<String, Integer> getCoachApplyCount() {
        return coachDao.selectCoachApplyCount(sqlSession);
    }

    @Override
    public CoachApply getCoachApplyDetail(Long coaSeq) {
        return coachDao.selectCoachApplyDetail(sqlSession, coaSeq);
    }

    @Override
    @Transactional
    public void updateCoachApplyStatus(Long coaSeq, String status) {
        Map<String, Object> params = new HashMap<>();
        params.put("coaSeq", coaSeq);
        params.put("status", status);
        coachDao.updateCoachApplyStatus(sqlSession, params);
    }

    @Override
    @Transactional
    public void insertCoachApply(CoachApply coachApply) {
        coachDao.insertCoachApply(sqlSession, coachApply);
    }
}
