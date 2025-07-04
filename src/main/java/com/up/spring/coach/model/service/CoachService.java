package com.up.spring.coach.model.service;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;
import com.up.spring.coach.model.dto.CoachApply;

import java.util.List;
import java.util.Map;

public interface CoachService {
    List<Category> getCategoryAll ();
    Long insertTempCourse (Course course);
    List<Section> getSectionList (Long courseSeq);
    int insertSection (Section section);
    int insertCurriculum (Curriculum curriculum);
    List<Map<String, Object>> getDashboardInfo (Long memberNo);
    List<Map<String, Object>> getMonthlyEarnings (Long memberNo);
    int deleteCurrBySectionSeq (long sectionSeq);
    int deleteSectionByCourseSeq (long courseSeq);
    int deleteCourseByCourseSeq (long courseSeq);
    Map<String,Integer> deleteCourseCascade(long delCourseSeq);
    int updateTempCourse(Course course);

    // 코치 신청 목록 조회
    List<CoachApply> getCoachApplyList(Map<String, Object> params);

    // 상태별 코치 신청 카운트
    Map<String, Integer> getCoachApplyCount();

    // 코치 신청 상세 정보 조회
    CoachApply getCoachApplyDetail(Long coaSeq);

    // 코치 신청 상태 업데이트
    void updateCoachApplyStatus(Long coaSeq, String status);

    // 코치 신청 등록
    void insertCoachApply(CoachApply coachApply);
}
