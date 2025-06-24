package com.up.spring.main.dao;

import com.up.spring.common.model.dto.Category;
import org.apache.ibatis.session.SqlSession;

import java.util.List;

public interface MainDao {
    List<Category> getCategorys(SqlSession session);
}
