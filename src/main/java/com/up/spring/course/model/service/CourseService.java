package com.up.spring.course.model.service;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.Review;

import java.util.List;
import java.util.Map;

public interface CourseService {
    Course searchById(long courseSeq);
    Map<String,Object> getReviewInfo(long courseSeq);
    Map<String,Object> getReviewAjax(long courseSeq,Map<String,Object> params);
    int insertReview(Review review);
}
