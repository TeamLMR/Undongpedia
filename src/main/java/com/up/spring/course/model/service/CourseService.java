package com.up.spring.course.model.service;

import com.up.spring.course.model.dto.Course;

public interface CourseService {
    Course searchById(long courseSeq);
}
