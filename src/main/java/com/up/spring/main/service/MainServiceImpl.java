package com.up.spring.main.service;

import com.up.spring.common.model.dto.Category;
import com.up.spring.main.dao.MainDao;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@RequiredArgsConstructor
public class MainServiceImpl implements MainService {
    private final SqlSession session;
    private final MainDao mainDao;

    @Override
    public List<Category> getCategories() {
        return mainDao.getCategorys(session);
    }
}
