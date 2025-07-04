package com.up.spring.course.model.service;

import com.up.spring.course.model.dto.*;

import java.util.List;
import java.util.Map;


public interface CourseService {
    Course searchById(long courseSeq);
    List<Course> getCourseApplyList(String status);
    int courseApplyConfirm(long courseSeq);
    Map<String,Object> getReviewInfo(long courseSeq);
    Map<String,Object> getReviewAjax(long courseSeq,Map<String,Object> params);
    int insertReview(Review review);
    int deleteReview(Review review);
    List<Course> searchCourseListByMemberNo(long memberNo);
    Curriculum getFirstCurriculum(long courseSeq);
    Curriculum getCurriculumBySeq(long currSeq);
    Progress getProgressBySeq(Map<String,Object> params);
    int insertProgress(Progress progress);
    int updateProgress(Progress progress);
    List<Map<String, Object>> getSectionCurrWithProgress(Map<String, Object> params);
    List<Map<String, Object>> getMyLearningCourse(long memberNo);

}
