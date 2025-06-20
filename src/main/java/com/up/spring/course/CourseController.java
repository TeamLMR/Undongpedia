package com.up.spring.course;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class CourseController {
    @RequestMapping("/course/list")
    public String list() {
        return "course/list";
    }

    @RequestMapping("/course/detail")
    public String detail() {
        return "course/detail";
    }
}
