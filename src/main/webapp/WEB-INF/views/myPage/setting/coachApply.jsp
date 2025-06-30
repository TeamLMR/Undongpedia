<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<style>
    .section-header {
        text-align: center;
        margin-bottom: 2rem;
    }

    .section-header h2 {
        color: #333;
        margin-bottom: 0.5rem;
    }

    .section-header p {
        color: #6c757d;
        margin: 0;
    }

    .form-group {
        margin-bottom: 1.5rem; /* 기존 1rem에서 1.5rem으로 증가 */
    }

    .form-group label {
        font-weight: 500;
        color: #333;
        margin-bottom: 0.75rem; /* 기존 0.5rem에서 0.75rem으로 증가 */
        display: block;
    }

    .form-control {
        border-radius: 8px;
        border: 1px solid #dee2e6;
        padding: 0.75rem;
        transition: all 0.3s ease;
        width: 100%;
    }

    .form-control:focus {
        border-color: #007bff;
        box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
    }

    .form-control:disabled,
    .form-control[readonly] {
        background-color: #f8f9fa;
        color: #6c757d;
        opacity: 1;
    }

    .invalid-feedback {
        display: block;
        width: 100%;
        margin-top: 0.5rem; /* 기존 0.25rem에서 0.5rem으로 증가 */
        font-size: 0.875rem;
        color: #dc3545;
    }

    .valid-feedback {
        display: block;
        width: 100%;
        margin-top: 0.5rem; /* 기존 0.25rem에서 0.5rem으로 증가 */
        font-size: 0.875rem;
        color: #198754;
    }

    .form-control.is-invalid {
        border-color: #dc3545;
    }

    .form-control.is-valid {
        border-color: #198754;
    }

    .btn-primary {
        background: #007bff;
        border: #007bff;
        border-radius: 8px;
        padding: 0.75rem 2rem;
        font-weight: 500;
        transition: all 0.3s ease;
    }

    .btn-success {
        border-radius: 8px;
        padding: 0.75rem 2rem;
        font-weight: 500;
    }

    .btn-primary:hover {
        background: #0056b3;
        border-color: #0056b3;
    }

    .alert-success {
        background: #d4edda;
        border: 1px solid #c3e6cb;
        color: #155724;
        border-radius: 8px;
        padding: 1rem;
        margin-bottom: 1.5rem; /* 기존 1rem에서 1.5rem으로 증가 */
    }

    .form-check-input {
        margin-top: 0.25rem;
    }

    .form-check-label {
        color: #495057;
        cursor: pointer;
    }

    .info-section {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 2rem; /* 기존 1.5rem에서 2rem으로 증가 */
        margin-bottom: 2.5rem; /* 기존 2rem에서 2.5rem으로 증가 */
    }

    .info-section h5 {
        color: #333;
        margin-bottom: 1.5rem; /* 기존 1rem에서 1.5rem으로 증가 */
        display: flex;
        align-items: center;
    }

    .info-section h5 i {
        margin-right: 0.75rem; /* 기존 0.5rem에서 0.75rem으로 증가 */
        color: #007bff;
    }

    .readonly-field {
        background: #fff;
        border: 1px solid #e9ecef;
        color: #495057;
        padding: 0.75rem;
        border-radius: 8px;
        margin-bottom: 0.75rem; /* 기존 0.5rem에서 0.75rem으로 증가 */
    }

    .verified-badge {
        background: #d4edda;
        color: #155724;
        padding: 0.25rem 0.75rem;
        border-radius: 12px;
        font-size: 0.8rem;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        margin-left: 0.5rem; /* ms-2 대신 명시적으로 추가 */
    }

    .verified-badge i {
        margin-right: 0.25rem;
    }

    /* 비밀번호 변경 섹션 스타일 */
    .password-change-section {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        padding: 2rem;
        margin-bottom: 2rem;
        border-left: 4px solid #17a2b8;
    }

    .password-change-section h5 {
        color: #333;
        margin-bottom: 1rem;
        display: flex;
        align-items: center;
        font-weight: 600;
    }

    .password-change-section h5 i {
        color: #17a2b8;
    }

    .section-description {
        color: #6c757d;
        font-size: 0.9rem;
        margin-bottom: 1.5rem;
        line-height: 1.5;
    }

    .btn-outline-primary {
        border-color: #17a2b8;
        color: #17a2b8;
        font-weight: 500;
        padding: 0.75rem 1.5rem;
        transition: all 0.3s ease;
    }

    .btn-outline-primary:hover {
        background-color: #17a2b8;
        border-color: #17a2b8;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(23, 162, 184, 0.3);
    }

    .email-sent-message {
        background: #d1ecf1;
        border: 1px solid #bee5eb;
        color: #0c5460;
        border-radius: 8px;
        padding: 1rem;
        margin-top: 1rem;
        display: flex;
        align-items: flex-start;
        animation: slideInDown 0.3s ease-out;
    }

    .email-sent-message i {
        color: #0c5460;
        font-size: 1.2rem;
        margin-top: 0.1rem;
        flex-shrink: 0;
    }

    .email-sent-message strong {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 600;
    }

    .email-sent-message p {
        margin: 0;
        font-size: 0.9rem;
        line-height: 1.4;
    }

    @keyframes slideInDown {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    /* 전체 폼을 감싸는 컨테이너 추가 */
    .member-update-container {
        padding: 2rem;
        max-width: 600px;
        margin: 0 auto;
    }

    /* 행 간격 개선 */
    .row {
        margin-bottom: 1rem;
    }

    /* 뉴스레터 체크박스 섹션 - 간단한 스타일 */
    .newsletter-section {
        margin: 2.5rem 0; /* 위아래 간격 */
    }

    .custom-checkbox {
        display: flex;
        align-items: flex-start;
        cursor: pointer;
        padding: 1rem 0;
    }

    .custom-checkbox input {
        position: absolute;
        opacity: 0;
        cursor: pointer;
    }

    .custom-checkbox .checkmark {
        position: relative;
        height: 20px;
        width: 20px;
        background-color: #fff;
        border: 2px solid #dee2e6;
        border-radius: 4px;
        margin-right: 1rem;
        flex-shrink: 0;
        transition: all 0.3s ease;
        margin-top: 2px;
    }

    .custom-checkbox input:checked ~ .checkmark {
        background-color: #007bff;
        border-color: #007bff;
    }

    .custom-checkbox .checkmark:after {
        content: "";
        position: absolute;
        display: none;
        left: 6px;
        top: 2px;
        width: 6px;
        height: 10px;
        border: solid white;
        border-width: 0 2px 2px 0;
        transform: rotate(45deg);
    }

    .custom-checkbox input:checked ~ .checkmark:after {
        display: block;
    }

    .checkbox-label {
        color: #495057;
        font-size: 0.95rem;
        line-height: 1.5;
        font-weight: 500;
        margin: 0;
    }

    /* 제출 버튼 영역 간격 개선 */
    .submit-section {
        margin-top: 3rem; /* 버튼 위 간격 추가 */
        padding-top: 2rem;
        border-top: 1px solid #dee2e6; /* 구분선 추가 */
        text-align: center;
    }
</style>

<!-- 전체를 감싸는 컨테이너 추가 -->
<c:if test="${coachApply.coaYn=='Y'}">
    <div class="member-update-container d-flex align-items-center justify-content-around mt-5" style="border: #17a2b8 1px solid; border-radius: 20px">
        <h3>코치 관리자 페이지</h3>
        <button class="btn btn-outline-primary" type="button" onclick="location.assign('${pageContext.request.contextPath}/coach/dashboard')">
            이동하기 <i class="bi bi-link"></i>
        </button>
    </div>
</c:if>
<div class="member-update-container">
    <div class="section-header">
        <h2>코치 신청</h2>
        <p>코치가 되어 운동정보를 공유해 보세요!</p>
    </div>
    <c:if test="${not empty coachApply}">
        <form action="${pageContext.request.contextPath}/mypage/updateCoachApply" method="POST" onsubmit="return checkFormData()">
        <input type="hidden" value="${coachApply.coaSeq}" name="coaSeq">
        <input type="hidden" value="${coachApply.coaYn}" name="coaYn">
        <div class="info-section">
            <h5>
                <i class="bi bi-piggy-bank"></i>
                계좌 정보 등록
            </h5>

            <div class="form-group">
                <label>예금주</label>
                <input class="form-control" name="coaBankName" value="${coachApply.coaBankName}">
            </div>

            <div class="form-group">
                <label>은행명</label>
                <select class="form-control" name="coaBank">
                    <option value="">은행을 선택해주세요</option>
                    <option value="한국은행" ${coachApply.coaBank eq '한국은행' ? 'selected' : ''}>한국은행</option>
                    <option value="산업은행" ${coachApply.coaBank eq '산업은행' ? 'selected' : ''}>산업은행</option>
                    <option value="기업은행" ${coachApply.coaBank eq '기업은행' ? 'selected' : ''}>기업은행</option>
                    <option value="국민은행" ${coachApply.coaBank eq '국민은행' ? 'selected' : ''}>국민은행</option>
                    <option value="외환은행" ${coachApply.coaBank eq '외환은행' ? 'selected' : ''}>외환은행</option>
                    <option value="수협은행" ${coachApply.coaBank eq '수협은행' ? 'selected' : ''}>수협은행</option>
                    <option value="수출입은행" ${coachApply.coaBank eq '수출입은행' ? 'selected' : ''}>수출입은행</option>
                    <option value="농협은행" ${coachApply.coaBank eq '농협은행' ? 'selected' : ''}>농협은행</option>
                    <option value="농협회원조합" ${coachApply.coaBank eq '농협회원조합' ? 'selected' : ''}>농협회원조합</option>
                    <option value="우리은행" ${coachApply.coaBank eq '우리은행' ? 'selected' : ''}>우리은행</option>
                    <option value="SC제일은행" ${coachApply.coaBank eq 'SC제일은행' ? 'selected' : ''}>SC제일은행</option>
                    <option value="서울은행" ${coachApply.coaBank eq '서울은행' ? 'selected' : ''}>서울은행</option>
                    <option value="한국씨티은행" ${coachApply.coaBank eq '한국씨티은행' ? 'selected' : ''}>한국씨티은행</option>
                    <option value="iM뱅크(대구)" ${coachApply.coaBank eq 'iM뱅크(대구)' ? 'selected' : ''}>iM뱅크(대구)</option>
                    <option value="부산은행" ${coachApply.coaBank eq '부산은행' ? 'selected' : ''}>부산은행</option>
                    <option value="광주은행" ${coachApply.coaBank eq '광주은행' ? 'selected' : ''}>광주은행</option>
                    <option value="제주은행" ${coachApply.coaBank eq '제주은행' ? 'selected' : ''}>제주은행</option>
                    <option value="전북은행" ${coachApply.coaBank eq '전북은행' ? 'selected' : ''}>전북은행</option>
                    <option value="경남은행" ${coachApply.coaBank eq '경남은행' ? 'selected' : ''}>경남은행</option>
                    <option value="새마을금고연합회" ${coachApply.coaBank eq '새마을금고연합회' ? 'selected' : ''}>새마을금고연합회</option>
                    <option value="신협중앙회" ${coachApply.coaBank eq '신협중앙회' ? 'selected' : ''}>신협중앙회</option>
                    <option value="산림조합" ${coachApply.coaBank eq '산림조합' ? 'selected' : ''}>산림조합</option>
                    <option value="우체국" ${coachApply.coaBank eq '우체국' ? 'selected' : ''}>우체국</option>
                    <option value="하나은행" ${coachApply.coaBank eq '하나은행' ? 'selected' : ''}>하나은행</option>
                    <option value="신한은행" ${coachApply.coaBank eq '신한은행' ? 'selected' : ''}>신한은행</option>
                    <option value="케이뱅크" ${coachApply.coaBank eq '케이뱅크' ? 'selected' : ''}>케이뱅크</option>
                    <option value="카카오뱅크" ${coachApply.coaBank eq '카카오뱅크' ? 'selected' : ''}>카카오뱅크</option>
                    <option value="토스뱅크" ${coachApply.coaBank eq '토스뱅크' ? 'selected' : ''}>토스뱅크</option>
                </select>

            </div>

            <div class="form-group">
                <label>계좌번호</label>
                <input class="form-control" name="coaBankNum" value="${coachApply.coaBankNum}">
            </div>
        </div>

        <!-- 수정 가능한 정보 섹션 -->
        <div class="row">
            <div class="col-12">
                <div class="form-group">
                    <label for="coaIntro">소개</label>
                    <textarea class="form-control" name="coaIntro" id="coaIntro" rows="15">${coachApply.coaIntro}</textarea>
                </div>
            </div>
        </div>

        <div class="submit-section">
            <button type="button" class="btn btn-${coachApply.coaYn=='N'?'block':'success'}">${coachApply.coaYn=="N"?"승인대기중":"승인 완료"}</button>
            <button type="submit" class="btn btn-primary">정보 수정</button>
        </div>
    </form>
    </c:if>
    <c:if test="${empty coachApply}">
        <form action="${pageContext.request.contextPath}/mypage/insertCoachApply" method="POST" onsubmit="return checkFormData()">
            <div class="info-section">
                <h5>
                    <i class="bi bi-lock-fill"></i>
                    계좌 정보 등록
                </h5>

                <div class="form-group">
                    <label>예금주</label>
                    <input class="form-control" name="coaBankName">
                </div>

                <div class="form-group">
                    <label>은행명</label>
                    <select class="form-control" name="coaBank">
                        <option value="">은행을 선택해주세요</option>
                        <option value="한국은행">한국은행</option>
                        <option value="산업은행">산업은행</option>
                        <option value="기업은행">기업은행</option>
                        <option value="국민은행">국민은행</option>
                        <option value="외환은행">외환은행</option>
                        <option value="수협은행">수협은행</option>
                        <option value="수출입은행">수출입은행</option>
                        <option value="농협은행">농협은행</option>
                        <option value="농협회원조합">농협회원조합</option>
                        <option value="우리은행">우리은행</option>
                        <option value="SC제일은행">SC제일은행</option>
                        <option value="서울은행">서울은행</option>
                        <option value="한국씨티은행">한국씨티은행</option>
                        <option value="iM뱅크(대구)">iM뱅크(대구)</option>
                        <option value="부산은행">부산은행</option>
                        <option value="광주은행">광주은행</option>
                        <option value="제주은행">제주은행</option>
                        <option value="전북은행">전북은행</option>
                        <option value="경남은행">경남은행</option>
                        <option value="새마을금고연합회">새마을금고연합회</option>
                        <option value="신협중앙회">신협중앙회</option>
                        <option value="산림조합">산림조합</option>
                        <option value="우체국">우체국</option>
                        <option value="하나은행">하나은행</option>
                        <option value="신한은행">신한은행</option>
                        <option value="케이뱅크">케이뱅크</option>
                        <option value="카카오뱅크">카카오뱅크</option>
                        <option value="토스뱅크">토스뱅크</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>계좌번호</label>
                    <input class="form-control" name="coaBankNum">
                </div>
            </div>
            <div class="row">
                <div class="col-12">
                    <div class="form-group">
                        <label for="coaIntro">소개</label>
                        <textarea class="form-control" name="coaIntro" rows="15"></textarea>
                    </div>
                </div>
            </div>

            <div class="submit-section">
                <button type="submit" class="btn btn-primary">신청하기</button>
            </div>

        </form>

    </c:if>


</div>

<script>
    const checkFormData = () => {
        const bankName = document.querySelector('input[name="coaBankName"]').value.trim();
        const bank = document.querySelector('select[name="coaBank"]').value;
        const bankNum = document.querySelector('input[name="coaBankNum"]').value.trim();
        const intro = document.querySelector('textarea[name="coaIntro"]').value.trim();

        if (!bankName) {
            alert("예금주를 입력해주세요.");
            return false;
        }

        if (!bank) {
            alert("은행을 선택해주세요.");
            return false;
        }

        if (!bankNum) {
            alert("계좌번호를 입력해주세요.");
            return false;
        }

        // 숫자만 입력되었는지 검사 (계좌번호)
        const accountNumberOnly = /^[0-9\-]+$/;
        if (!accountNumberOnly.test(bankNum)) {
            alert("계좌번호는 숫자 또는 '-'만 입력 가능합니다.");
            return false;
        }

        if (!intro) {
            alert("소개 내용을 입력해주세요.");
            return false;
        }

        // 모든 검사를 통과했을 경우 전송 허용
        return true;
    }
</script>