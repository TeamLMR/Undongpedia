package com.up.spring.common.controller;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;

@Controller
public class ErrorController {

    @GetMapping("/access-denied")
    public String accessDenied(Model model, Authentication auth) {
        if (auth != null) {
            model.addAttribute("message", auth.getName());
            model.addAttribute("authorities", auth.getAuthorities());
        }
        model.addAttribute("msg", "접근 권한이 없습니다.");
        model.addAttribute("loc", "/");
        return "common/msg";  // views/error/access-denied.jsp
    }
}
