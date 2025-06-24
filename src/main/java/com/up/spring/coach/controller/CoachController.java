package com.up.spring.coach.controller;

import com.up.spring.common.model.dto.Category;
import com.up.spring.coach.model.service.CoachService;
import com.up.spring.course.model.dto.Course;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/coach")
@Slf4j
public class CoachController {
    @Autowired
    private CoachService coachService;
    @RequestMapping("/dashboard")
    public String dashboard(Model model) {
        return "/coach/dashboard";
    }

    @RequestMapping("/addCourse")
    public String addCourse(Model model) {

        List<Category> categories = coachService.getCategoryAll();
        model.addAttribute("categories", categories);
        return "/coach/add/addCourse";
    }

    @PostMapping("/addCourseSection")
    public String addCourseSection(Course course, Model model) {
        return "/coach/add/addCourseSection";
    }

    @RequestMapping("/courseReview")
    public String courseReview(Model model) {
        return "/coach/management/review";
    }
    @RequestMapping("/courseQna")
    public String courseQna(Model model) {
        return "/coach/management/courseQna";
    }
}
