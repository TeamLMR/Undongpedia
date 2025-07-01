package com.up.spring.email.model.service;

import com.up.spring.email.model.dto.PasswordUpdateValidationResult;

public interface PasswordUpdateService {
    /**
     * 회원의 비밀번호 업데이트 토큰을 생성하고 이메일을 발송합니다.
     */
    void createPasswordUpdateTokenForMember(Long memberNo, String email);

    /**
     * 비밀번호 업데이트 토큰의 유효성을 검증합니다.
     */
    PasswordUpdateValidationResult validatePasswordUpdateToken(String token);

    /**
     * 비밀번호를 업데이트합니다.
     */
    void updatePassword(String token, String newPassword);
} 