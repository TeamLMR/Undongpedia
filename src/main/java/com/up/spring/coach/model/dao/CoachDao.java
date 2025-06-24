package com.up.spring.coach.model.dao;

import com.up.spring.common.model.dto.Category;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface CoachDao {
    List<Category> getCategoryAll(SqlSession sqlSession);
}
