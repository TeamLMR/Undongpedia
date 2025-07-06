package com.up.spring.email.model.service;

import com.up.spring.common.EmailService;
import com.up.spring.email.model.dao.PasswordUpdateDao;
import com.up.spring.email.model.dto.PasswordUpdateToken;
import com.up.spring.email.model.dto.PasswordUpdateValidationResult;
import com.up.spring.member.model.dao.MemberDao;
import com.up.spring.member.model.dto.Member;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.mail.MessagingException;
import java.util.Date;
import java.util.UUID;

@Service

public class PasswordUpdateServiceImpl implements PasswordUpdateService {
    @Autowired
    private final PasswordUpdateDao passwordUpdateDao;
    @Autowired
    private final MemberDao memberDao;
    @Autowired
    private final SqlSession sqlSession;
    @Autowired
    private final EmailService emailService;
    @Autowired
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public PasswordUpdateServiceImpl(PasswordUpdateDao passwordUpdateDao,
                                   MemberDao memberDao,
                                   SqlSession sqlSession,
                                   EmailService emailService,
                                   PasswordEncoder passwordEncoder) {
        this.passwordUpdateDao = passwordUpdateDao;
        this.memberDao = memberDao;
        this.sqlSession = sqlSession;
        this.emailService = emailService;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void createPasswordUpdateTokenForMember(Long memberNo, String email) {
        // 기존 토큰 무효화
        passwordUpdateDao.invalidateExistingTokens(sqlSession, memberNo);

        // 새 토큰 생성
        String token = UUID.randomUUID().toString();
        Date expiryDate = new Date(System.currentTimeMillis() + (24 * 60 * 60 * 1000)); // 24시간 유효

        PasswordUpdateToken passwordUpdateToken = new PasswordUpdateToken();
        passwordUpdateToken.setToken(token);
        passwordUpdateToken.setMemberNo(memberNo);
        passwordUpdateToken.setExpiryDate(expiryDate);
        passwordUpdateToken.setUsed("N");

        passwordUpdateDao.insertPasswordUpdateToken(sqlSession, passwordUpdateToken);

        // 이메일 발송
        try {
            Member member = memberDao.selectOne(sqlSession, memberNo);
//            String resetUrl = "http://localhost:9090/undongpedia/member/update-password?token=" + token;
            String resetUrl = "https://chunjaefullstack.r-e.kr:3306/undongpedia/member/update-password?token=" + token;
            emailService.sendPasswordResetEmail(email, member.getMemberName(), resetUrl);
        } catch (MessagingException e) {
            throw new RuntimeException("비밀번호 업데이트 이메일 발송 실패", e);
        }
    }

    @Override
    public PasswordUpdateValidationResult validatePasswordUpdateToken(String token) {
        PasswordUpdateToken passwordUpdateToken = passwordUpdateDao.selectPasswordUpdateToken(sqlSession, token);

        if (passwordUpdateToken == null) {
            return new PasswordUpdateValidationResult(false, null, "유효하지 않은 토큰입니다.");
        }

        if ("Y".equals(passwordUpdateToken.getUsed())) {
            return new PasswordUpdateValidationResult(false, null, "이미 사용된 토큰입니다.");
        }

        if (new Date().after(passwordUpdateToken.getExpiryDate())) {
            return new PasswordUpdateValidationResult(false, null, "만료된 토큰입니다.");
        }

        return new PasswordUpdateValidationResult(true, passwordUpdateToken.getMemberNo(), null);
    }

    @Override
    @Transactional
    public void updatePassword(String token, String newPassword) {
        PasswordUpdateToken passwordUpdateToken = passwordUpdateDao.selectPasswordUpdateToken(sqlSession, token);
        
        if (passwordUpdateToken == null || "Y".equals(passwordUpdateToken.getUsed()) || 
            new Date().after(passwordUpdateToken.getExpiryDate())) {
            throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
        }

        // 비밀번호 업데이트
        Member member = memberDao.selectOne(sqlSession, passwordUpdateToken.getMemberNo());
        member.setMemberPassword(passwordEncoder.encode(newPassword));
        memberDao.updatePassword(sqlSession, member);

        // 토큰 사용 완료 처리
        passwordUpdateDao.updateTokenAsUsed(sqlSession, token);
    }
} 