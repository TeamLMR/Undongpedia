package com.up.spring.email.controller;

import com.up.spring.common.EmailService;
import com.up.spring.email.model.dto.VerificationResult;
import com.up.spring.email.model.service.EmailVerificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.mail.MessagingException;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/email")
@RequiredArgsConstructor
@Slf4j
public class EmailController {

    private final EmailService emailService;
    private final EmailVerificationService emailVerificationService;

    /**
     * 회원가입용 이메일 인증번호 발송
     * POST /email/send-verification
     */
    @PostMapping("/send-verification")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sendVerificationCode(@RequestParam String email) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 이메일 형식 검증
            if (!isValidEmail(email)) {
                response.put("success", false);
                response.put("message", "올바른 이메일 형식이 아닙니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 인증번호 저장 (기존 미사용 인증번호는 자동 삭제됨)
            VerificationResult result = emailVerificationService.saveVerificationCode(email);

            if (!result.isSuccess()) {
                response.put("success", false);
                response.put("message", result.getMessage());
                return ResponseEntity.badRequest().body(response);
            }

            // 이메일 발송
            emailService.sendVerificationEmail(email, result.getCode());

            log.info("인증번호 발송 완료: {} -> {}", email, result.getCode());

            response.put("success", true);
            response.put("message", "인증번호가 발송되었습니다. (유효시간: 5분)");
            response.put("expireTime", System.currentTimeMillis() + (5 * 60 * 1000));

            return ResponseEntity.ok(response);

        } catch (MessagingException e) {
            log.error("이메일 발송 실패: {}", email, e);
            response.put("success", false);
            response.put("message", "이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);

        } catch (Exception e) {
            log.error("인증번호 발송 중 오류 발생: {}", email, e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 회원가입용 인증번호 확인
     * POST /email/verify-code
     */
    @PostMapping("/verify-code")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyCode(@RequestParam String email,
                                                          @RequestParam String code,
                                                          HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 인증번호 확인 (만료된 인증번호는 자동 삭제됨)
            VerificationResult result = emailVerificationService.verifyCode(email, code);

            if (result.isSuccess()) {
                // 인증 성공 - 세션에 저장
                session.setAttribute("email_verified_" + email, true);
                session.setAttribute("email_verified_time_" + email, System.currentTimeMillis());

                response.put("success", true);
                response.put("message", result.getMessage());

                log.info("이메일 인증 성공: {}", email);
                return ResponseEntity.ok(response);

            } else {
                // 인증 실패
                response.put("success", false);
                response.put("message", result.getMessage());

                return ResponseEntity.badRequest().body(response);
            }

        } catch (Exception e) {
            log.error("인증번호 확인 중 오류 발생: {} - {}", email, code, e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 이메일 인증 상태 확인
     * GET /email/verify-status
     */
    @GetMapping("/verify-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getVerificationStatus(@RequestParam String email,
                                                                     HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 세션에서 확인 (최근 30분 이내)
            Boolean isVerified = (Boolean) session.getAttribute("email_verified_" + email);
            Long verifiedTime = (Long) session.getAttribute("email_verified_time_" + email);

            if (isVerified != null && isVerified) {
                if (verifiedTime != null && (System.currentTimeMillis() - verifiedTime) < (30 * 60 * 1000)) {
                    response.put("verified", true);
                    response.put("message", "이메일 인증이 완료된 상태입니다.");
                    return ResponseEntity.ok(response);
                } else {
                    // 세션 만료 - 세션에서 제거
                    session.removeAttribute("email_verified_" + email);
                    session.removeAttribute("email_verified_time_" + email);
                }
            }

            response.put("verified", false);
            response.put("message", "이메일 인증이 필요합니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("인증 상태 확인 중 오류: {}", email, e);
            response.put("verified", false);
            response.put("message", "인증 상태 확인 중 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 이메일 형식 검증
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email.matches(emailRegex);
    }
}