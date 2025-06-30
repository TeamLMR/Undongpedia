package com.up.spring.main.service;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.main.dao.MainDao;
import com.up.spring.main.dto.EventCourse;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MainServiceImpl implements MainService {
    private final SqlSession session;
    private final MainDao mainDao;

    @Override
    public List<Category> getCategories() {
        return mainDao.getCategorys(session);
    }
    
    @Override
    public List<Course> getCourseList(Map<String, Object> params) {
        return mainDao.getCourseList(session,params);
    }
    
    @Override
    public List<EventCourse> getActiveEventCourses() {
        return mainDao.getActiveEventCourses(session);
    }
}
