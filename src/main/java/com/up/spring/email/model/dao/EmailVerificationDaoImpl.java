package com.up.spring.email.model.dao;

import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Repository
@Slf4j
public class EmailVerificationDaoImpl implements EmailVerificationDao {

    @Override
    public Map<String, Object> saveVerificationCode(SqlSession session, String memberId) {
        Map<String, Object> resultMap = new HashMap<>();

        try {
            // 1. 6자리 랜덤 인증번호 생성
            String code = generateVerificationCode();

            // 2. 기존 인증번호 삭제 (있다면)
            Map<String, Object> deleteParams = new HashMap<>();
            deleteParams.put("memberId", memberId);
            session.delete("emailVerification.deleteExistingCode", deleteParams);

            // 3. 새 인증번호 저장
            Map<String, Object> insertParams = new HashMap<>();
            insertParams.put("memberId", memberId);
            insertParams.put("code", code);

            int insertResult = session.insert("emailVerification.insertVerificationCode", insertParams);

            if (insertResult > 0) {
                log.info("인증번호 생성 성공: memberId={}, code={}", memberId, code);
                resultMap.put("success", true);
                resultMap.put("code", code);
                resultMap.put("message", "인증번호가 생성되었습니다.");
            } else {
                log.error("인증번호 삽입 실패: memberId={}", memberId);
                resultMap.put("success", false);
                resultMap.put("code", null);
                resultMap.put("message", "인증번호 생성에 실패했습니다.");
            }

        } catch (Exception e) {
            log.error("인증번호 저장 중 DB 오류: memberId={}", memberId, e);
            resultMap.put("success", false);
            resultMap.put("code", null);
            resultMap.put("message", "데이터베이스 오류가 발생했습니다.");
        }

        return resultMap;
    }

    @Override
    public Map<String, Object> verifyCode(SqlSession session, Map<String, String> params) {
        Map<String, Object> resultMap = new HashMap<>();

        try {
            String memberId = params.get("memberId");
            String code = params.get("code");

            // 1. 만료된 인증번호 삭제
            session.delete("emailVerification.deleteExpiredCodes");

            // 2. 인증번호 확인
            Map<String, Object> verifyParams = new HashMap<>();
            verifyParams.put("memberId", memberId);
            verifyParams.put("verificationCode", code);

            Integer count = session.selectOne("emailVerification.countValidCode", verifyParams);

            if (count != null && count > 0) {
                // 3. 인증 성공 시 해당 인증번호 삭제
                session.delete("emailVerification.deleteVerifiedCode", verifyParams);

                log.info("이메일 인증 성공: memberId={}", memberId);
                resultMap.put("success", true);
                resultMap.put("message", "이메일 인증이 완료되었습니다.");
            } else {
                log.warn("이메일 인증 실패: memberId={}, 유효하지 않은 인증번호", memberId);
                resultMap.put("success", false);
                resultMap.put("message", "인증번호가 일치하지 않거나 만료되었습니다.");
            }

        } catch (Exception e) {
            log.error("인증번호 확인 중 DB 오류: params={}", params, e);
            resultMap.put("success", false);
            resultMap.put("message", "데이터베이스 오류가 발생했습니다.");
        }

        return resultMap;
    }

    /**
     * 6자리 랜덤 인증번호 생성
     */
    private String generateVerificationCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000); // 100000 ~ 999999
        return String.valueOf(code);
    }
}