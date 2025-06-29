package com.up.spring.email.model.service;

import com.up.spring.email.model.dto.VerificationResult;

public interface EmailVerificationService {

    /**
     * 이메일 인증번호 생성 및 저장
     */
    VerificationResult saveVerificationCode(String memberId);

    /**
     * 이메일 인증번호 확인
     */
    VerificationResult verifyCode(String memberId, String code);
}
