package com.up.spring.main.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.course.model.dto.Course;
import com.up.spring.main.dto.EventCourse;
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
import org.springframework.web.bind.annotation.RequestParam;
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
    public String index(Model model, 
                       @RequestParam(required = false) String search,
                       @RequestParam(required = false) String category,
                       @RequestParam(required = false) String categoryName) {
        
        // 검색 조건이 있는 경우 필터링된 결과 조회
        if ((search != null && !search.trim().isEmpty()) || (category != null && !category.trim().isEmpty())) {
            Map<String, Object> filters = new HashMap<>();
            filters.put("keyword", search != null ? search.trim() : "");
            filters.put("categorySeq", category != null ? category.trim() : "");
            filters.put("cPage", 1);
            filters.put("numPerPage", 8);
            
            List<Course> courseList = mainService.getFilteredCourses(filters);
            model.addAttribute("courseList", courseList);
            
            // 검색 조건을 모델에 추가
            if (search != null && !search.trim().isEmpty()) {
                model.addAttribute("searchKeyword", search.trim());
            }
            if (category != null && !category.trim().isEmpty()) {
                model.addAttribute("selectedCategory", category.trim());
                model.addAttribute("selectedCategoryName", categoryName);
            }
        } else {
            // 기본 강의 목록 조회
            int cPage = 1;
            int numPerPage = 8;
            Map<String, Object> params = new HashMap<>();
            params.put("cPage", cPage);
            params.put("numPerPage", numPerPage);
            List<Course> courseList = mainService.getCourseList(params);
            model.addAttribute("courseList", courseList);
        }
        
        // 활성화된 이벤트 강의 조회
        List<EventCourse> eventCourses = mainService.getActiveEventCourses();
        model.addAttribute("eventCourses", eventCourses);
        
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
    
    @RequestMapping("/main/filterCourses")
    @ResponseBody
    public List<Course> filterCourses(
            @RequestParam(defaultValue = "all") String courseType,
            @RequestParam(defaultValue = "all") String difficulty, 
            @RequestParam(defaultValue = "all") String priceType,
            @RequestParam(defaultValue = "latest") String sortBy,
            @RequestParam(defaultValue="") String keyword,
            @RequestParam(defaultValue = "") String categorySeq,
            @RequestParam(defaultValue = "1") int page
    ) {

        int cPage = page;
        int numPerPage = 8;

        Map<String, Object> filters = new HashMap<>();
        filters.put("courseType", courseType);
        filters.put("difficulty", difficulty);
        filters.put("priceType", priceType);
        filters.put("sortBy", sortBy);
        filters.put("cPage", cPage);
        filters.put("keyword", keyword);
        filters.put("categorySeq", categorySeq);
        filters.put("numPerPage", numPerPage);
        
        List<Course> result = mainService.getFilteredCourses(filters);
        
        return result;
    }




}
