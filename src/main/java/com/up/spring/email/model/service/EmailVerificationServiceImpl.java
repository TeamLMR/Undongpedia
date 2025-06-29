package com.up.spring.email.model.service;

import com.up.spring.email.model.dao.EmailVerificationDao;
import com.up.spring.email.model.dto.VerificationResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class EmailVerificationServiceImpl implements EmailVerificationService {

    private final EmailVerificationDao emailVerificationDao;
    private final SqlSession session;

    @Override
    public VerificationResult saveVerificationCode(String memberId) {
        try {
            Map<String, Object> result = emailVerificationDao.saveVerificationCode(session, memberId);
            return VerificationResult.fromMap(result);
        } catch (Exception e) {
            log.error("인증번호 생성 중 서비스 오류: memberId={}", memberId, e);
            return VerificationResult.failure("서비스 오류가 발생했습니다.");
        }
    }

    @Override
    public VerificationResult verifyCode(String memberId, String code) {
        try {
            Map<String, String> params = new HashMap<>();
            params.put("memberId", memberId);
            params.put("code", code);

            Map<String, Object> result = emailVerificationDao.verifyCode(session, params);
            return VerificationResult.fromMap(result);
        } catch (Exception e) {
            log.error("인증번호 확인 중 서비스 오류: memberId={}, code={}", memberId, code, e);
            return VerificationResult.failure("서비스 오류가 발생했습니다.");
        }
    }
}