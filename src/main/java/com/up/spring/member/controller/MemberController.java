package com.up.spring.member.controller;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.member.model.dto.Member;
import com.up.spring.member.model.service.MemberService;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.service.OrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MemberController {
    private final MemberService memberService;
    private final OrderService orderService;
    private final BCryptPasswordEncoder passwordEncoder;

    public long returnMemberNo(){
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        long memberNo = 0;
        if (m != null){
            memberNo = m.getMemberNo();
        }
        return memberNo;
    }

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

    @RequestMapping("/mypage/purchaseHistory")
    public String purchaseHistory(Model model){
        long memberNo = returnMemberNo();
        if  (memberNo != 0) {
            List<Orders> ordersList =  orderService.selectOrdersByMember(memberNo);
            //order 내역이 없을때
            if (ordersList != null && !ordersList.isEmpty()){
                model.addAttribute("ordersList", ordersList);
            } else {
                //아무것도 안보냄..?
            }
        }
        return "myPage/management/purchaseHistory";
    }

    @RequestMapping("/mypage/learning")
    public String course(){
        return "myPage/management/learning";
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
    public String savemember(@ModelAttribute("member") Member member) {
        String password = member.getMemberPassword();
        member.setMemberPassword(passwordEncoder.encode(password));
        memberService.saveMember(member);
        return "redirect:/";}

    @RequestMapping("/mypage/coachApply")
    public String coachPage(Model model) {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        CoachApply c = memberService.getCoachApply(m.getMemberNo());
        model.addAttribute("coachApply", c);
        return "myPage/setting/coachApply";
    }

    @PostMapping("/mypage/updateCoachApply")
    public String updateCoachApply(CoachApply coachApply, Model model) {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        coachApply.setMemberNo(m.getMemberNo());
        int result = memberService.updateCoachApply(coachApply);

        if (result == 1) {
            model.addAttribute("msg", "정보를 수정했습니다.");
            model.addAttribute("loc", "/mypage");
        }else {
            model.addAttribute("msg", "정보 수정에 실패했습니다.");
            model.addAttribute("loc", "/mypage");
        }
        return "common/msg";
    }
    @PostMapping("/mypage/insertCoachApply")
    public String insertCoachApply(CoachApply coachApply, Model model) {
        Member m = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        coachApply.setMemberNo(m.getMemberNo());
        coachApply.setCoaYn("N");
        int result = memberService.insertCoachApply(coachApply);
        if (result == 1) {
            model.addAttribute("msg", "신청이 완료되었습니다.");
            model.addAttribute("loc", "/mypage");
        }else {
            model.addAttribute("msg", "신청에 실패했습니다.");
            model.addAttribute("loc", "/mypage");
        }
        return "common/msg";
    }

}
