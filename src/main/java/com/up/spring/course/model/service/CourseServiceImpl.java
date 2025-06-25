package com.up.spring.course.model.service;


import com.up.spring.course.model.dao.CourseDao;
import com.up.spring.course.model.dto.Course;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private final CourseDao courseDao;
    private final SqlSession sqlSession;

    @Override
    public Course searchById(long courseSeq) {
        return courseDao.searchById(sqlSession, courseSeq);
    }
}
