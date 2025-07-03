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
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.beans.factory.annotation.Value;

import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MemberController {
    private final MemberService memberService;
    private final OrderService orderService;
    private final BCryptPasswordEncoder passwordEncoder;
    private final PasswordUpdateService passwordUpdateService;
    private final EmailService emailService;
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    @Value("${x.naver.client.id}")
    private String naverClientId;
    
    @Value("${x.naver.client.secret}")
    private String naverClientSecret;

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
    public String savemember(@ModelAttribute("member") Member member, 
                            @RequestParam(required = false) String memberSigntype,
                            @RequestParam(required = false) String memberIdHidden,
                            @RequestParam(required = false) String memberNameHidden,
                            @RequestParam(required = false) String memberNicknameHidden,
                            HttpSession session) {

        log.debug("회원가입 요청 - memberId: {}, memberName: {}, memberNickname: {}, memberSigntype: {}", 
                 member.getMemberId(), member.getMemberName(), member.getMemberNickname(), memberSigntype);

        // hidden 필드 값이 있으면 사용
        if (memberIdHidden != null && !memberIdHidden.isEmpty()) {
            member.setMemberId(memberIdHidden);
        }
        if (memberNameHidden != null && !memberNameHidden.isEmpty()) {
            member.setMemberName(memberNameHidden);
        }
        if (memberNicknameHidden != null && !memberNicknameHidden.isEmpty()) {
            member.setMemberNickname(memberNicknameHidden);
        }

        String password = member.getMemberPassword();
        member.setMemberPassword(passwordEncoder.encode(password));
        
        // 네이버 로그인인 경우 signType 설정
        if ("NAVER".equals(memberSigntype)) {
            member.setMemberSignType("NAVER");
            log.debug("네이버 회원가입으로 설정됨");
        } else {
            // 일반 회원가입인 경우 GENERAL로 설정
            member.setMemberSignType("GENERAL");
            log.debug("일반 회원가입으로 설정됨");
        }
        
        log.debug("최종 memberSignType: {}", member.getMemberSignType());
        
        int result=memberService.saveMember(member);
        if(result > 0){
            try {
                emailService.sendWelcomeEmail(member.getMemberId(), member.getMemberName());
            } catch (Exception e) {
                log.error("웰컴 이메일 발송 실패", e);
            }
            
            // 회원가입 완료 후 자동 로그인 처리
            Member savedMember = memberService.searchById(member.getMemberId());
            if (savedMember != null) {
                UsernamePasswordAuthenticationToken auth = 
                    new UsernamePasswordAuthenticationToken(
                        savedMember, null, savedMember.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(auth);
                session.setAttribute("SPRING_SECURITY_CONTEXT", SecurityContextHolder.getContext());
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

    @RequestMapping("/login.do")
    public String naverLoginCallback(@RequestParam(required = false) String code,
                                     @RequestParam(required = false) String state,
                                     HttpSession session,
                                     RedirectAttributes redirectAttr) {
        log.debug("네이버 로그인 콜백 - code: {}, state: {}", code, state);
        
        if (code == null || state == null) {
            redirectAttr.addFlashAttribute("error", "네이버 로그인 정보가 올바르지 않습니다.");
            return "redirect:/";
        }
        
        try {
            // 1. code로 access_token 요청
            String accessToken = getNaverAccessToken(code, state);
            if (accessToken == null) {
                redirectAttr.addFlashAttribute("error", "네이버 인증에 실패했습니다.");
                return "redirect:/";
            }
            
            // 2. access_token으로 사용자 정보 요청
            Map<String, String> userInfo = getNaverUserInfo(accessToken);
            if (userInfo == null) {
                redirectAttr.addFlashAttribute("error", "네이버 사용자 정보를 가져올 수 없습니다.");
                return "redirect:/";
            }
            
            String email = userInfo.get("email");
            String name = userInfo.get("name");
            String nickname = userInfo.get("nickname");
            
            log.debug("네이버 사용자 정보 - email: {}, name: {}, nickname: {}", email, name, nickname);
            
            // 3. 회원 존재 여부 확인
            Member member = memberService.searchById(email);
            if (member != null) {
                // 탈퇴한 회원인지 확인
                if ("WITHDRAW".equals(member.getMemberStatus())) {
                    redirectAttr.addFlashAttribute("error", "탈퇴한 회원입니다.");
                    return "redirect:/";
                }
                
                // 이미 회원이면 Spring Security 인증 처리
                // Spring Security의 Authentication 객체를 생성하여 로그인 처리
                org.springframework.security.authentication.UsernamePasswordAuthenticationToken auth = 
                    new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                        member, null, member.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(auth);
                session.setAttribute("SPRING_SECURITY_CONTEXT", SecurityContextHolder.getContext());
                return "redirect:/";
            } else {
                // 회원이 아니면 회원가입 폼으로 네이버 정보 전달
                redirectAttr.addFlashAttribute("naverEmail", email);
                redirectAttr.addFlashAttribute("naverName", name);
                redirectAttr.addFlashAttribute("naverNickname", nickname);

                return "redirect:/signup";
            }
            
        } catch (Exception e) {
            log.error("네이버 로그인 처리 중 오류 발생", e);
            redirectAttr.addFlashAttribute("error", "네이버 로그인 처리 중 오류가 발생했습니다.");
            return "redirect:/";
        }
    }
    
    private String getNaverAccessToken(String code, String state) {
        try {
            String clientId = "CBUQIgHQrx9kpSArabUl"; // 로그인 페이지에서 사용하는 클라이언트 ID
            String clientSecret = "gz5M0ZC0FN"; // 네이버 API 설정 파일의 시크릿 사용
            String redirectURI = URLEncoder.encode("http://localhost:9090/undongpedia/login.do", "UTF-8");
            
            String tokenURL = "https://nid.naver.com/oauth2.0/token";
            String params = "grant_type=authorization_code" +
                    "&client_id=" + clientId +
                    "&client_secret=" + clientSecret +
                    "&redirect_uri=" + redirectURI +
                    "&code=" + code +
                    "&state=" + state;
            
            log.debug("네이버 access_token 요청 URL: {}", tokenURL);
            log.debug("네이버 access_token 요청 파라미터: {}", params);
            
            URL url = new URL(tokenURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.getOutputStream().write(params.getBytes("UTF-8"));
            
            int responseCode = conn.getResponseCode();
            log.debug("네이버 access_token 응답 코드: {}", responseCode);
            
            if (responseCode == 200) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();
                
                log.debug("네이버 access_token 응답: {}", response.toString());
                
                Map<String, Object> jsonResponse = objectMapper.readValue(response.toString(), Map.class);
                String accessToken = (String) jsonResponse.get("access_token");
                log.debug("네이버 access_token: {}", accessToken);
                return accessToken;
            } else {
                // 오류 응답 읽기
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
                StringBuilder errorResponse = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    errorResponse.append(line);
                }
                br.close();
                log.error("네이버 access_token 오류 응답: {}", errorResponse.toString());
            }
        } catch (Exception e) {
            log.error("네이버 access_token 요청 중 오류", e);
        }
        return null;
    }
    
    private Map<String, String> getNaverUserInfo(String accessToken) {
        try {
            String apiURL = "https://openapi.naver.com/v1/nid/me";
            URL url = new URL(apiURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);
            
            log.debug("네이버 사용자 정보 요청 URL: {}", apiURL);
            log.debug("네이버 사용자 정보 요청 헤더: Authorization: Bearer {}", accessToken);
            
            int responseCode = conn.getResponseCode();
            log.debug("네이버 사용자 정보 응답 코드: {}", responseCode);
            
            if (responseCode == 200) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }
                br.close();
                
                log.debug("네이버 사용자 정보 응답: {}", response.toString());
                
                Map<String, Object> jsonResponse = objectMapper.readValue(response.toString(), Map.class);
                if ("00".equals(jsonResponse.get("resultcode"))) {
                    Map<String, Object> responseObj = (Map<String, Object>) jsonResponse.get("response");
                    Map<String, String> userInfo = new HashMap<>();
                    userInfo.put("email", (String) responseObj.get("email"));
                    userInfo.put("name", (String) responseObj.get("name"));
                    userInfo.put("nickname", (String) responseObj.get("nickname"));
                    
                    log.debug("네이버 사용자 정보 파싱 결과 - email: {}, name: {}, nickname: {}", 
                             userInfo.get("email"), userInfo.get("name"), userInfo.get("nickname"));
                    
                    return userInfo;
                } else {
                    log.error("네이버 사용자 정보 요청 실패 - resultcode: {}", jsonResponse.get("resultcode"));
                }
            } else {
                // 오류 응답 읽기
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
                StringBuilder errorResponse = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    errorResponse.append(line);
                }
                br.close();
                log.error("네이버 사용자 정보 오류 응답: {}", errorResponse.toString());
            }
        } catch (Exception e) {
            log.error("네이버 사용자 정보 요청 중 오류", e);
        }
        return null;
    }

    @PostMapping("/member/withdraw")
    public String withdrawMember(HttpSession session, RedirectAttributes redirectAttr) {
        try {
            Member loginMember = (Member) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            if (loginMember == null) {
                redirectAttr.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
                return "redirect:/";
            }

            int result = memberService.withdrawMember(loginMember.getMemberNo());
            if (result > 0) {
                // 로그아웃 처리
                SecurityContextHolder.clearContext();
                session.invalidate();
                redirectAttr.addFlashAttribute("message", "회원탈퇴가 완료되었습니다.");
                return "redirect:/";
            } else {
                redirectAttr.addFlashAttribute("error", "회원탈퇴 처리에 실패했습니다.");
                return "redirect:/mypage";
            }
        } catch (Exception e) {
            log.error("회원탈퇴 처리 중 오류 발생", e);
            redirectAttr.addFlashAttribute("error", "회원탈퇴 처리 중 오류가 발생했습니다.");
            return "redirect:/mypage";
        }
    }

}
