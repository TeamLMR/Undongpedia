package com.up.spring.member.controller;

import com.up.spring.coach.model.dto.CoachApply;
import com.up.spring.common.EmailService;
import com.up.spring.email.model.dto.PasswordUpdateValidationResult;
import com.up.spring.email.model.service.PasswordUpdateService;
import com.up.spring.member.model.dto.Member;
import com.up.spring.member.model.service.MemberService;
import com.up.spring.payment.model.dto.Orders;
import com.up.spring.payment.model.service.OrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MemberController {
    private final MemberService memberService;
    private final OrderService orderService;
    private final BCryptPasswordEncoder passwordEncoder;
    private final PasswordUpdateService passwordUpdateService;
    private final EmailService emailService;

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
        log.info("마이페이지지롱");
        return "myPage/setting/personal";
    }

    @RequestMapping("/mypage/purchaseHistory")
    public String purchaseHistory(Model model){
        long memberNo = returnMemberNo();
        if  (memberNo != 0) {
            List<Orders> ordersList =  orderService.selectOrdersByMember(memberNo);
            if (ordersList != null && !ordersList.isEmpty()){
                Map<String, List<Orders>> groupOrdersMap = ordersList.stream()
                        .collect(Collectors.groupingBy(o -> o.getDetail().getOrdersPaymentId()));
                model.addAttribute("groupedOrdersMap", groupOrdersMap);
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

    @RequestMapping("/mypage/login")
    public String login() {
        return "auth/login";
    }

    @PostMapping("/mypage/savemember")
    public String savemember(@ModelAttribute("member") Member member) {

        String password = member.getMemberPassword();
        member.setMemberPassword(passwordEncoder.encode(password));
        int result=memberService.saveMember(member);
        if(result > 0){
            try {
                emailService.sendWelcomeEmail(member.getMemberId(), member.getMemberName());
            } catch (Exception e) {
                log.error("웰컴 이메일 발송 실패", e);
            }
        }
        return "redirect:/";
    }

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

    @PostMapping("/member/update")
    public String updateMember(@RequestParam("lastName") String nickname, Model model) {
        // 현재 로그인한 사용자 정보 가져오기
        Member loginMember = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        // 닉네임만 업데이트
        loginMember.setMemberNickname(nickname);

        // 서비스 호출
        int result = memberService.updateMemberNickname(loginMember.getMemberNo(), nickname);

        if (result > 0) {
            model.addAttribute("msg", "닉네임이 성공적으로 변경되었습니다.");
            model.addAttribute("loc", "/mypage");
        } else {
            model.addAttribute("msg", "닉네임 변경에 실패했습니다.");
            model.addAttribute("loc", "/mypage");
        }

        return "common/msg";
    }

    @PostMapping("/member/request-password-update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> requestPasswordUpdate() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            Member loginMember = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (loginMember == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요한 서비스입니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }

            passwordUpdateService.createPasswordUpdateTokenForMember(loginMember.getMemberNo(), loginMember.getMemberId());
            response.put("success", true);
            response.put("message", "비밀번호 업데이트 링크가 이메일로 발송되었습니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("비밀번호 재설정 요청 중 오류 발생", e);
            response.put("success", false);
            response.put("message", "이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @GetMapping("/member/update-password")
    public String showPasswordUpdateForm(@RequestParam String token, Model model) {
        PasswordUpdateValidationResult result = passwordUpdateService.validatePasswordUpdateToken(token);
        
        if (!result.isValid()) {
            model.addAttribute("error", result.getErrorMessage());
            if (result.getMemberNo() != null) {
                model.addAttribute("memberNo", result.getMemberNo());
                return "member/expired-token";
            }
            return "member/invalid-token";
        }
        
        model.addAttribute("token", token);
        return "member/update-password";
    }

    @PostMapping("/member/update-password")
    public String updatePassword(
            @RequestParam String token,
            @RequestParam String newPassword,
            RedirectAttributes redirectAttr) {
        try {
            passwordUpdateService.updatePassword(token, newPassword);
            redirectAttr.addFlashAttribute("message", "비밀번호가 성공적으로 변경되었습니다.");
            return "redirect:/logout.do";
        } catch (IllegalStateException e) {
            redirectAttr.addFlashAttribute("error", e.getMessage());
            return "redirect:/member/update-password?token=" + token;
        }
    }

    @PostMapping("/member/resend-update-link")
    public String resendUpdateLink(@RequestParam Long memberNo, HttpSession session, RedirectAttributes redirectAttr) {
        Member loginMember = (Member) session.getAttribute("loginMember");
        if (loginMember == null || !loginMember.getMemberNo().equals(memberNo)) {
            redirectAttr.addFlashAttribute("error", "유효하지 않은 요청입니다.");
            return "redirect:/member/login";
        }

        passwordUpdateService.createPasswordUpdateTokenForMember(memberNo, loginMember.getMemberId());
        redirectAttr.addFlashAttribute("message", "새로운 비밀번호 업데이트 링크가 이메일로 발송되었습니다.");
        return "redirect:/member/request-password-update";
    }

    @GetMapping("/member/forgot-password")
    public String showForgotPasswordForm() {
        return "member/forgot-password";
    }

    @PostMapping("/member/forgot-password")
    public String processForgotPassword(@RequestParam String memberId, 
                                       @RequestParam String memberName,
                                       Model model,
                                       RedirectAttributes redirectAttr) {
        try {
            Member member = memberService.searchById(memberId);

            if (member == null) {
                redirectAttr.addFlashAttribute("error", "해당 이메일로 가입된 회원이 없습니다.");
                return "redirect:/member/forgot-password";
            }
            if (!memberName.equals(member.getMemberName())) {
                redirectAttr.addFlashAttribute("error", "이름이 일치하지 않습니다.");
                return "redirect:/member/forgot-password";
            }

            passwordUpdateService.createPasswordUpdateTokenForMember(member.getMemberNo(), member.getMemberId());

            // 성공 시 model에 값 전달
            model.addAttribute("success", true);
            model.addAttribute("memberId", memberId);
            model.addAttribute("memberName", memberName);
            return "member/forgot-password";

        } catch (Exception e) {
            log.error("비밀번호 찾기 처리 중 오류 발생", e);
            redirectAttr.addFlashAttribute("error", "처리 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            return "redirect:/member/forgot-password";
        }
    }

}
