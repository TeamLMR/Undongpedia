package com.up.spring.member.controller;

import com.up.spring.member.model.dto.Member;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
public class MemberController {
    /*myPage 관련*/
    @RequestMapping("/mypage")
    public String myPage(){
        /*TODO: 마이페이지 첫 시작 페이지는 home으로 세팅했음*/
        return "myPage/home";
    }

    @RequestMapping("/mypage/personal")
    public String personalPage(){
        return "myPage/setting/personal";
    }

    /*auth 관련*/
    @RequestMapping("/signup")
    public String signup() {
        return "auth/signup";
    }

    @RequestMapping("/login")
    public String login() {
        return "auth/login";
    }

    @RequestMapping("/savemember")
    public String savemember(@ModelAttribute("member") Member member) {return "auth/savemember";}


}
