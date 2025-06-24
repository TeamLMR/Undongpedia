package com.up.spring.coach.model.service;

import com.up.spring.coach.model.dao.CoachDao;
import com.up.spring.common.model.dto.Category;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CoachServiceImpl implements CoachService {
    @Autowired
    private SqlSession sqlSession;
    @Autowired
    private CoachDao coachDao;

    @Override
    public List<Category> getCategoryAll() {
        return coachDao.getCategoryAll(sqlSession);
    }
}
