package com.up.spring.security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class SecurityController {

    @RequestMapping("/loginpage")
    public String loginPage() {
        return "auth/login";
    }

    @RequestMapping("/loginsuccess")
    public String loginSuccess() {
        return"redirect:/";
    }
    @RequestMapping("/loginfail")
    public String loginFail() {
        return"redirect:/loginpage";
    }
    @RequestMapping("/sessionmax.do")
    public String sessionMax(Model model) {
        model.addAttribute("msg","다른 사용자가 이용중입니다.");
        return "auth/login";
    }

}
