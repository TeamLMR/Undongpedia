package com.up.spring.main.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.main.service.MainService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.event.ApplicationContextEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.WebApplicationContext;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
        int cPage = 1;
        int numPerPage = 8;
        Map<String, Object> params = new HashMap<>();
        params.put("cPage", cPage);
        params.put("numPerPage", numPerPage);
        List<Course> courseList = mainService.getCourseList(params);
        model.addAttribute("courseList", courseList);
        return "/index";
    }

    @EventListener
    public void applicationStartEvent(ApplicationContextEvent event) {
        log.debug("applicationStartEvent");
        List<Category> categories = mainService.getCategories();
        log.debug("categories: {}", categories);
        Objects.requireNonNull(webApplicationContext.getServletContext()).setAttribute("categories", categories);
    }

    @RequestMapping("/main/ajaxLoadMoreData")
    @ResponseBody
    public List<Course> ajaxLoadMoreData(int page) {
        int cPage = page;
        int numPerPage = 8;
        log.debug("cPage: {}", cPage);
        log.debug("numPerPage: {}", numPerPage);
        Map<String, Object> params = new HashMap<>();
        params.put("cPage", cPage);
        params.put("numPerPage", numPerPage);
        return mainService.getCourseList(params);
    }
}
