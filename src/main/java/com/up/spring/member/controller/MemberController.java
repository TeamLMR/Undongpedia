package com.up.spring.member.controller;

import com.up.spring.member.model.dto.Member;
import com.up.spring.member.model.service.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.Mapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final BCryptPasswordEncoder passwordEncoder;

    /*myPage 관련*/
    @RequestMapping("/mypage")
    public String myPage(){
        /*TODO: 마이페이지 첫 시작 페이지는 home으로 세팅했음*/
        return "myPage/home";
    }

    @RequestMapping("/mypage/personal")
    public String personalPage(){
        log.info("마이페이지지롱");
        return "myPage/setting/personal";
    }

    /*auth 관련*/
    @RequestMapping("/mypage/signup")
    public String signup() {

        return "auth/signup";
    }

    @RequestMapping("/mypage/login")
    public String login() {
        return "auth/login";
    }

    @PostMapping("/mypage/savemember")
    public String savemember(@ModelAttribute("member") Member member) {
        log.info("{}",member);
        String password = member.getMemberPassword();
        log.info("{}",member);
        member.setMemberPassword(passwordEncoder.encode(password));
        log.info("{}", member);
        int result=memberService.saveMember(member);
        log.info("{}, {}", member, result);

        return "redirect:/";
    }


}
