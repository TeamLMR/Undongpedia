package com.up.spring.main.service;


import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.main.dto.EventCourse;

import java.util.List;
import java.util.Map;

public interface MainService {
    List<Category> getCategories();
    List<Course> getCourseList(Map<String, Object> params);
    List<EventCourse> getActiveEventCourses();
}
