package com.up.spring.main.service;

import com.up.spring.common.model.dto.Category;
import lombok.NoArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
@NoArgsConstructor
public class MainServiceImpl implements MainService {
    @Override
    public List<Category> getCategories() {
        return List.of();
    }
}
