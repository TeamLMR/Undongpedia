package com.up.spring.admin.controller;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
@Slf4j
@RequiredArgsConstructor
public class AdminController {

    public long returnMemberNo(){
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        long memberNo = 0;
        if (m != null){
            memberNo = m.getMemberNo();
        }
        return memberNo;
    }

    @RequestMapping("/dashboard")
    public String dashboard(Model model) {
        return "/admin/dashboard";
    }

    @RequestMapping("/coachConfirm")
    public String coachConfirm(Model model){
        return "admin/management/coachConfirm";
    }
    @RequestMapping("/courseConfirm")
    public String courseConfirm(Model model){
        return "admin/management/courseConfirm";
    }
}

