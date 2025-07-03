package com.up.spring.coach.model.service;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Section;

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
}
