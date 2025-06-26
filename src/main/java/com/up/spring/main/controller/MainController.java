package com.up.spring.main.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.main.service.MainService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.event.ApplicationContextEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.context.WebApplicationContext;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Objects;

@Slf4j
@Controller
@RequiredArgsConstructor
public class MainController {
    private final MainService mainService;
    private final WebApplicationContext webApplicationContext;
    /*
    어떻게 항상 어디든지 가져와서 화면에 주는지?
    * 여기서 세션에 등록을 해줘야하는건지?
    */

    @RequestMapping("/")
    public String index(Model model) {
        return "/index";
    }

    @EventListener
    public void applicationStartEvent(ApplicationContextEvent event) {
        log.debug("applicationStartEvent");
        List<Category> categories = mainService.getCategories();
        log.debug("categories: {}", categories);
        Objects.requireNonNull(webApplicationContext.getServletContext()).setAttribute("categories", categories);
    }

}
