package com.up.spring.email.model.dao;

import org.apache.ibatis.session.SqlSession;
import java.util.Map;

public interface EmailVerificationDao {

    /**
     * 이메일 인증번호 생성 및 저장
     */
    Map<String, Object> saveVerificationCode(SqlSession session, String memberId);

    /**
     * 이메일 인증번호 확인
     */
    Map<String, Object> verifyCode(SqlSession session, Map<String, String> params);
}