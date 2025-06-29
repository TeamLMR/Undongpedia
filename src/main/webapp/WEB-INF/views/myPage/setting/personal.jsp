<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<%-- 현재 로그인한 사용자 정보를 JavaScript 전역변수로 설정 --%>
<script>
    window.currentUserEmail = '${loginMember.memberId}';
    window.currentUserName = '${loginMember.memberName}';
</script>

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
        margin-bottom: 1.5rem;
    }

    .form-group label {
        font-weight: 500;
        color: #333;
        margin-bottom: 0.75rem;
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
        margin-top: 0.5rem;
        font-size: 0.875rem;
        color: #dc3545;
    }

    .valid-feedback {
        display: block;
        width: 100%;
        margin-top: 0.5rem;
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
        margin-bottom: 1.5rem;
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
        padding: 2rem;
        margin-bottom: 2.5rem;
    }

    .info-section h5 {
        color: #333;
        margin-bottom: 1.5rem;
        display: flex;
        align-items: center;
    }

    .info-section h5 i {
        margin-right: 0.75rem;
        color: #007bff;
    }

    .readonly-field {
        background: #fff;
        border: 1px solid #e9ecef;
        color: #495057;
        padding: 0.75rem;
        border-radius: 8px;
        margin-bottom: 0.75rem;
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
        margin-left: 0.5rem;
    }

    .verified-badge i {
        margin-right: 0.25rem;
    }

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

    .btn-success {
        background-color: #198754;
        border-color: #198754;
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

    .member-update-container {
        padding: 2rem;
        max-width: 600px;
        margin: 0 auto;
    }

    .row {
        margin-bottom: 1rem;
    }

    .newsletter-section {
        margin: 2.5rem 0;
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

    .submit-section {
        margin-top: 3rem;
        padding-top: 2rem;
        border-top: 1px solid #dee2e6;
        text-align: center;
    }
</style>

<div class="member-update-container">
    <div class="section-header">
        <h2>회원정보 수정</h2>
        <p>개인정보를 안전하게 관리하세요</p>
    </div>

    <form action="/member/update" method="POST" id="updateForm">

        <!-- 읽기 전용 정보 섹션 -->
        <div class="info-section">
            <h5>
                <i class="bi bi-lock-fill"></i>
                기본 정보
            </h5>

            <div class="form-group">
                <label>이름</label>
                <div class="readonly-field">${loginMember.memberName}</div>
            </div>

            <div class="form-group">
                <label>이메일</label>
                <div class="readonly-field">
                    ${loginMember.memberId}
                    <span class="verified-badge">
                        <i class="bi bi-check-circle-fill"></i>인증완료
                    </span>
                </div>
            </div>
        </div>

        <!-- 수정 가능한 정보 섹션 -->
        <div class="row">
            <div class="col-12">
                <div class="form-group">
                    <label for="lastName">닉네임</label>
                    <input type="text" class="form-control" name="lastName" id="lastName"
                           value="${loginMember.memberNickname}" required minlength="2" placeholder="닉네임을 입력하세요">
                    <div class="invalid-feedback" id="lastNameError"></div>
                    <div class="valid-feedback" id="lastNameSuccess"></div>
                </div>
            </div>
        </div>

        <!-- 비밀번호 변경 섹션 -->
        <div class="password-change-section">
            <h5>
                <i class="bi bi-shield-lock"></i>
                비밀번호 변경
            </h5>
            <div class="section-description">
                보안을 위해 비밀번호 변경은 이메일 인증을 통해 진행됩니다.
            </div>

            <button type="button" class="btn btn-outline-primary" onclick="sendPasswordReset()">
                <i class="bi bi-envelope me-2"></i>
                비밀번호 변경 링크 이메일 전송
            </button>

            <div id="emailSentMessage" class="email-sent-message" style="display: none;">
                <i class="bi bi-check-circle-fill me-2"></i>
                <div>
                    <strong>이메일이 전송되었습니다!</strong>
                    <p>${loginMember.memberId}으로 비밀번호 변경 링크를 보냈습니다.<br>
                        이메일을 확인하여 비밀번호를 변경해주세요. (링크 유효시간: 30분)</p>
                </div>
            </div>
        </div>

        <!-- 뉴스레터 구독 섹션 -->
        <div class="newsletter-section">
            <label class="custom-checkbox">
                <input type="checkbox" name="newsletter" id="newsletter" checked>
                <span class="checkmark"></span>
                <div>
                    <div class="checkbox-label">
                        결제 정보 및 운동백과의 유용한 소식을 이메일로 받아보겠습니다
                    </div>
                </div>
            </label>
        </div>

        <div class="submit-section">
            <button type="submit" class="btn btn-primary">정보 수정</button>
        </div>

    </form>
</div>

<script>
    // ===== 비밀번호 재설정 이메일 발송 함수 =====
    function sendPasswordReset() {
        const btn = event.target;
        const originalHTML = btn.innerHTML;

        // 사용자 정보 확인
        if (!window.currentUserEmail || !window.currentUserName) {
            alert('사용자 정보를 확인할 수 없습니다. 다시 로그인해주세요.');
            return;
        }

        // 버튼 비활성화
        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-arrow-clockwise me-2"></i>전송 중...';

        // 실제 API 호출
        fetch('/undongpedia/email/send-password-reset', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `email=${encodeURIComponent(window.currentUserEmail)}&memberName=${encodeURIComponent(window.currentUserName)}`
        })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 성공 메시지 표시
                    const emailMessage = document.getElementById('emailSentMessage');
                    if (emailMessage) {
                        emailMessage.style.display = 'flex';
                    }

                    // 버튼 상태 변경
                    btn.innerHTML = '<i class="bi bi-check-circle me-2"></i>전송 완료';
                    btn.classList.remove('btn-outline-primary');
                    btn.classList.add('btn-success');

                    // 3초 후 원래 상태로 복원
                    setTimeout(() => {
                        btn.disabled = false;
                        btn.innerHTML = '<i class="bi bi-envelope me-2"></i>비밀번호 변경 링크 재전송';
                        btn.classList.remove('btn-success');
                        btn.classList.add('btn-outline-primary');
                    }, 3000);

                } else {
                    // 실패 시 버튼 복원
                    btn.disabled = false;
                    btn.innerHTML = originalHTML;
                    alert(data.message || '이메일 발송에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                btn.disabled = false;
                btn.innerHTML = originalHTML;
                alert('서버 오류가 발생했습니다.');
            });
    }

    // ===== 랜덤 닉네임 생성 함수 =====
    function generateRandomNickname() {
        const adjectives = ['강력한', '빠른', '건강한', '활기찬', '파워풀한', '슈퍼', '멋진', '쿨한', '열정적인', '끈기있는'];
        const exercises = ['헬스', '요가', '필라테스', '크로스핏', '러닝', '사이클', '복싱', '수영', '클라이밍', '웨이트'];
        const animals = ['사자', '치타', '독수리', '상어', '표범', '늑대', '호랑이', '팬더', '코끼리', '캥거루'];
        const titles = ['마스터', '킹', '퀸', '챔피언', '프로', '전문가', '달인', '고수', '선수', '코치'];

        const patterns = [
            () => `${adjectives[Math.floor(Math.random() * adjectives.length)]}${exercises[Math.floor(Math.random() * exercises.length)]}`,
            () => `${exercises[Math.floor(Math.random() * exercises.length)]}${titles[Math.floor(Math.random() * titles.length)]}`,
            () => `${adjectives[Math.floor(Math.random() * adjectives.length)]}${animals[Math.floor(Math.random() * animals.length)]}`,
            () => `${animals[Math.floor(Math.random() * animals.length)]}${titles[Math.floor(Math.random() * titles.length)]}`,
            () => `운동${animals[Math.floor(Math.random() * animals.length)]}`,
            () => `헬시${animals[Math.floor(Math.random() * animals.length)]}`
        ];

        const randomPattern = patterns[Math.floor(Math.random() * patterns.length)];
        return randomPattern();
    }

    // ===== 페이지 로드 시 실행 =====
    document.addEventListener('DOMContentLoaded', function() {
        const nameRegex = /^[가-힣a-zA-Z]{2,}$/;

        // 닉네임 관련 기능
        const nicknameInput = document.getElementById('lastName');
        if (nicknameInput) {
            nicknameInput.addEventListener('focus', function () {
                if (this.placeholder === '') {
                    this.placeholder = generateRandomNickname();
                }
            });

            nicknameInput.addEventListener('click', function () {
                if (this.placeholder === '') {
                    this.placeholder = generateRandomNickname();
                }
            });

            // 닉네임 실시간 검증
            nicknameInput.addEventListener('input', function () {
                const value = this.value;
                const errorDiv = document.getElementById('lastNameError');
                const successDiv = document.getElementById('lastNameSuccess');

                if (!this.classList) {
                    console.error('닉네임 input의 classList가 없습니다');
                    return;
                }

                if (value === '') {
                    this.classList.remove('is-valid', 'is-invalid');
                    if (errorDiv) errorDiv.textContent = '';
                    if (successDiv) successDiv.textContent = '';
                } else if (nameRegex.test(value)) {
                    this.classList.remove('is-invalid');
                    this.classList.add('is-valid');
                    if (errorDiv) errorDiv.textContent = '';
                    if (successDiv) successDiv.textContent = '멋진 닉네임이네요!';
                } else {
                    this.classList.remove('is-valid');
                    this.classList.add('is-invalid');
                    if (successDiv) successDiv.textContent = '';
                    if (errorDiv) errorDiv.textContent = '2글자 이상의 한글 또는 영어만 입력해주세요.';
                }
            });
        }

        // 폼 제출 검증
        const updateForm = document.getElementById('updateForm');
        if (updateForm) {
            updateForm.addEventListener('submit', function (e) {
                e.preventDefault();

                let isValid = true;

                // 닉네임 확인
                const lastName = document.getElementById('lastName');
                if (lastName && (lastName.classList.contains('is-invalid') || !lastName.classList.contains('is-valid'))) {
                    lastName.focus();
                    isValid = false;
                }

                if (isValid) {
                    // 성공 시뮬레이션
                    alert('회원정보가 성공적으로 수정되었습니다!');

                    // 유효성 검사 클래스 제거
                    document.querySelectorAll('.is-valid, .is-invalid').forEach(el => {
                        el.classList.remove('is-valid', 'is-invalid');
                    });

                    // 에러 메시지 초기화
                    document.querySelectorAll('.invalid-feedback, .valid-feedback').forEach(el => {
                        el.textContent = '';
                    });
                }
            });
        }
    });
</script>