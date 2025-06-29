package com.up.spring.email.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class VerificationResult {

    private boolean success;  // 성공/실패 여부
    private String code;      // 생성된 인증번호 (성공시에만)
    private String message;   // 결과 메시지

    // ========================================
    // 💡 EmailController에서 사용하는 메서드들!
    // ========================================

    /**
     * 성공 여부 확인
     * Controller에서: result.isSuccess()
     */
    public boolean isSuccess() {
        return success;
    }

    /**
     * 인증번호 반환
     * Controller에서: result.getCode()
     */
    public String getCode() {
        return code;
    }

    /**
     * 결과 메시지 반환
     * Controller에서: result.getMessage()
     */
    public String getMessage() {
        return message;
    }

    // ========================================
    // 편의 메서드들
    // ========================================

    /**
     * 성공 결과 생성
     */
    public static VerificationResult success(String code, String message) {
        return VerificationResult.builder()
                .success(true)
                .code(code)
                .message(message)
                .build();
    }

    /**
     * 실패 결과 생성
     */
    public static VerificationResult failure(String message) {
        return VerificationResult.builder()
                .success(false)
                .code(null)
                .message(message)
                .build();
    }

    /**
     * Map을 VerificationResult로 변환
     * Service에서 DAO 결과를 변환할 때 사용
     */
    public static VerificationResult fromMap(java.util.Map<String, Object> map) {
        Boolean success = (Boolean) map.get("success");
        String code = (String) map.get("code");
        String message = (String) map.get("message");

        return VerificationResult.builder()
                .success(success != null ? success : false)
                .code(code)
                .message(message != null ? message : "알 수 없는 오류가 발생했습니다.")
                .build();
    }
}