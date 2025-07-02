package com.up.spring.course.model.service;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Curriculum;
import com.up.spring.course.model.dto.Progress;
import com.up.spring.course.model.dto.Review;

import java.util.List;
import java.util.Map;


public interface CourseService {
    Course searchById(long courseSeq);
    Map<String,Object> getReviewInfo(long courseSeq);
    Map<String,Object> getReviewAjax(long courseSeq,Map<String,Object> params);
    int insertReview(Review review);
    List<Course> searchCourseListByMemberNo(long memberNo);
    Curriculum getFirstCurriculum(long courseSeq);
    Curriculum getCurriculumBySeq(long currSeq);
    Progress getProgressBySeq(Map<String,Object> params);
    int insertProgress(Progress progress);
    int updateProgress(Progress progress);
}
