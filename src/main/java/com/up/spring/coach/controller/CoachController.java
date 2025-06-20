package com.up.spring.coach.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/coach")
public class CoachController {
    @RequestMapping("/dashboard")
    public String dashboard(Model model) {
        return "/coach/dashboard";
    }
}
