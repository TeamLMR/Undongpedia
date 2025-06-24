package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CoachDaoImpl implements CoachDao {

    @Override
    public List<Category> getCategoryAll(SqlSession sqlSession) {
        return sqlSession.selectList("coach.getCategoryAll");
    }
}
