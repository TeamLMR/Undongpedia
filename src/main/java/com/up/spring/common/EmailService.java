package com.up.spring.common;

import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StreamUtils;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendEmail(String memberId, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(memberId);
        message.setSubject(subject);
        message.setText(text);
        message.setFrom("nulliswell@gmail.com");

        mailSender.send(message);
    }

    // 1. 인증번호 이메일 (랜덤 6자리)
    public void sendVerificationEmail(String memberId, String code) throws MessagingException {
        String htmlContent = loadTemplate("verification.html")
                .replace("{VERIFICATION_CODE}", code);
        sendHtmlEmail(memberId, "운동백과 이메일 인증번호", htmlContent);
    }

    // 2. 웰컴 이메일
    public void sendWelcomeEmail(String memberId, String memberName) throws MessagingException {
        String htmlContent = loadTemplate("welcome.html")
                .replace("{USER_NAME}", memberName)
                .replace("{WEBSITE_URL}", "https://운동백과.com");
        sendHtmlEmail(memberId, "운동백과 가입을 축하드립니다!", htmlContent);
    }

    // 3. 비밀번호 재설정 이메일
    public void sendPasswordResetEmail(String memberId, String memberName, String resetUrl) throws MessagingException {
        String htmlContent = loadTemplate("password-reset.html")
                .replace("{USER_NAME}", memberName)
                .replace("{RESET_URL}", resetUrl);
        sendHtmlEmail(memberId, "운동백과 비밀번호 재설정", htmlContent);
    }

    // HTML 템플릿 파일 로드
    private String loadTemplate(String fileName) {
        try {
            Resource resource = new ClassPathResource("templates/email/" + fileName);
            return StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException("이메일 템플릿을 로드할 수 없습니다: " + fileName, e);
        }
    }

    // HTML 이메일 발송
    private void sendHtmlEmail(String to, String subject, String htmlContent) throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlContent, true); // true = HTML
        helper.setFrom("nulliswell@gmail.com");

        mailSender.send(message);
    }
}