package com.up.spring.main.dao;

import com.up.spring.common.model.dto.Category;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class MainDaoImpl implements MainDao {
    @Override
    public List<Category> getCategorys(SqlSession session) {
        return session.selectList("getCategorys");
    }
}
