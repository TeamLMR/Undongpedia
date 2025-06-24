package com.up.spring.main.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.main.service.MainService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Slf4j
@Controller
@RequiredArgsConstructor
public class MainController {
    private final MainService mainService;

    @RequestMapping("/")
    public String index(Model model) {
        List<Category> categories = mainService.getCategories();
        log.debug("categories: {}", categories);
        model.addAttribute("categories", categories);
        return "index";
    }

}
