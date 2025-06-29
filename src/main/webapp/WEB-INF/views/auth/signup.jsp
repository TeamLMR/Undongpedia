<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<section>
    <div class="page-title light-background">
        <div class="container">
            <nav class="breadcrumbs">
                <ol>
                    <li><a href="${path}">홈</a></li>
                    <li class="current">회원가입</li>
                </ol>
            </nav>
            <h1>회원가입</h1>
        </div>
    </div>

    <section id="register" class="register section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row justify-content-center">
                <div class="col-lg-6">
                    <div class="registration-form-wrapper" data-aos="zoom-in" data-aos-delay="200">
                        <div class="section-header mb-4 text-center">
                            <h2>회원가입</h2>
                            <p>운동백과와 함께 건강한 몸을 만들어요!</p>
                        </div>

                        <form action="${path}/savemember" method="POST" id="signupForm">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <div class="form-group">
                                        <label for="firstName">이름</label>
                                        <input type="text" class="form-control" name="memberName" id="firstName" required minlength="2" placeholder="2글자 이상 한글, 영어만 입력">
                                        <div class="invalid-feedback" id="firstNameError"></div>
                                        <div class="valid-feedback" id="firstNameSuccess"></div>
                                    </div>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <div class="form-group">
                                        <label for="lastName">닉네임</label>
                                        <input type="text" class="form-control" name="memberNickname" id="lastName" required minlength="2" placeholder="">
                                        <div class="invalid-feedback" id="lastNameError"></div>
                                        <div class="valid-feedback" id="lastNameSuccess"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- 이메일 인증 섹션 -->
                            <div class="form-group mb-3">
                                <label for="email">이메일 <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="email" class="form-control" name="memberId" id="email" required placeholder="example@email.com">
                                    <button class="btn btn-outline-secondary" type="button" id="sendVerificationBtn">인증번호 보내기</button>
                                </div>
                                <div class="invalid-feedback" id="emailError"></div>
                            </div>

                            <!-- 인증번호 입력창 (초기에는 숨김) -->
                            <div class="form-group mb-3" id="verificationCodeSection" style="display: none;">
                                <label for="verificationCode">인증번호</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" name="verificationCode" id="verificationCode" placeholder="인증번호 6자리 입력" maxlength="6">
                                    <span class="input-group-text" id="timer">05:00</span>
                                    <button class="btn btn-outline-success" type="button" id="verifyCodeBtn">확인</button>
                                </div>
                                <div class="invalid-feedback" id="codeError"></div>
                            </div>

                            <!-- 이메일 인증 완료 표시 (초기에는 숨김) -->
                            <div class="alert alert-success" id="emailVerifiedAlert" style="display: none;">
                                <i class="bi bi-check-circle-fill me-2"></i>이메일 인증이 완료되었습니다.
                            </div>

                            <div class="form-group mb-3">
                                <label for="password">비밀번호</label>
                                <div class="password-input">
                                    <input type="password" class="form-control" name="memberPassword" id="password" required minlength="8" placeholder="최소 8자 이상">
                                    <i class="bi bi-eye toggle-password"></i>
                                </div>
                                <small class="password-requirements">
                                    최소 8자 이상이며 대문자, 소문자, 숫자, 특수문자를 포함해야 합니다
                                </small>
                            </div>

                            <div class="form-group mb-4">
                                <label for="confirmPassword">비밀번호 확인</label>
                                <div class="password-input">
                                    <input type="password" class="form-control" name="confirmPassword" id="confirmPassword" required minlength="8" placeholder="비밀번호를 다시 입력하세요">
                                    <i class="bi bi-eye toggle-password"></i>
                                </div>
                                <div class="invalid-feedback" id="passwordMatchError"></div>
                                <div class="valid-feedback" id="passwordMatchSuccess"></div>
                            </div>

                            <div class="form-group mb-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="newsletter" id="newsletter">
                                    <label class="form-check-label" for="newsletter">
                                        결제 정보 및 운동백과의 유용한 소식을 이메일로 받아보겠습니다
                                    </label>
                                </div>
                            </div>

                            <div class="form-group mb-4">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="terms" id="terms" required>
                                    <label class="form-check-label" for="terms">
                                        <a href="#">서비스 이용약관</a> 및 <a href="#">개인정보처리방침</a>에 동의합니다
                                    </label>
                                </div>
                            </div>

                            <div class="text-center mb-4">
                                <button type="submit" class="btn btn-primary w-100">회원가입</button>
                            </div>

                            <div class="text-center">
                                <p class="mb-0">이미 계정이 있으신가요? <a href="${path}/login">로그인</a></p>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <style>
        .invalid-feedback {
            display: block;
            width: 100%;
            margin-top: 0.25rem;
            font-size: 0.875rem;
            color: #dc3545;
        }

        .valid-feedback {
            display: block;
            width: 100%;
            margin-top: 0.25rem;
            font-size: 0.875rem;
            color: #198754;
        }

        .form-control.is-invalid {
            border-color: #dc3545;
        }

        .form-control.is-valid {
            border-color: #198754;
        }

        /* 이메일 인증 스타일 */
        .input-group-text#timer {
            background-color: #f8f9fa;
            border-color: #dee2e6;
            color: #198754;
            font-weight: 600;
            min-width: 60px;
            text-align: center;
        }

        #verificationCodeSection {
            animation: slideDown 0.3s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        #emailVerifiedAlert {
            animation: fadeIn 0.5s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        #verificationCode {
            text-align: center;
            font-size: 1.2rem;
            font-weight: 600;
            letter-spacing: 2px;
        }
    </style>

    <script>
        // ===== 전역 변수 =====
        let emailVerified = false;
        let verificationTimer = null;

        // ===== 랜덤 닉네임 생성 =====
        function generateRandomNickname() {
            const adjectives = ['강력한', '빠른', '건강한', '활기찬', '파워풀한', '슈퍼', '멋진', '쿨한', '열정적인', '끈기있는'];
            const exercises = ['헬스', '요가', '필라테스', '크로스핏', '러닝', '사이클', '복싱', '수영', '클라이밍', '웨이트'];
            const animals = ['사자', '치타', '독수리', '상어', '표범', '늑대', '호랑이', '팬더', '코끼리', '캥거루'];
            const titles = ['마스터', '킹', '퀸', '챔피언', '프로', '전문가', '달인', '고수', '선수', '코치'];

            const patterns = [
                () => `\${adjectives[Math.floor(Math.random() * adjectives.length)]}\${exercises[Math.floor(Math.random() * exercises.length)]}`,
                () => `\${exercises[Math.floor(Math.random() * exercises.length)]}\${titles[Math.floor(Math.random() * titles.length)]}`,
                () => `\${adjectives[Math.floor(Math.random() * adjectives.length)]}\${animals[Math.floor(Math.random() * animals.length)]}`,
                () => `\${animals[Math.floor(Math.random() * animals.length)]}\${titles[Math.floor(Math.random() * titles.length)]}`,
                () => `운동\${animals[Math.floor(Math.random() * animals.length)]}`,
                () => `헬시\${animals[Math.floor(Math.random() * animals.length)]}`
            ];

            const randomPattern = patterns[Math.floor(Math.random() * patterns.length)];
            return randomPattern();
        }

        // ===== 이메일 검증 =====
        function validateEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        // ===== 이메일 인증번호 발송 =====
        function sendVerificationEmail() {
            const emailInput = document.getElementById('email');
            const sendBtn = document.getElementById('sendVerificationBtn');
            const email = emailInput.value.trim();

            if (!email || !validateEmail(email)) {
                alert('올바른 이메일 주소를 입력해주세요.');
                emailInput.focus();
                return;
            }

            sendBtn.disabled = true;
            sendBtn.textContent = '발송 중...';

            fetch('/undongpedia/email/send-verification', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'email=' + encodeURIComponent(email)
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('verificationCodeSection').style.display = 'block';
                        sendBtn.textContent = '인증번호 발송됨';
                        startVerificationTimer(data.expireTime);
                        alert('인증번호가 이메일로 발송되었습니다.');
                        document.getElementById('verificationCode').focus();
                    } else {
                        sendBtn.disabled = false;
                        sendBtn.textContent = '인증번호 보내기';
                        alert(data.message || '인증번호 발송에 실패했습니다.');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    sendBtn.disabled = false;
                    sendBtn.textContent = '인증번호 보내기';
                    alert('서버 오류가 발생했습니다.');
                });
        }

        // ===== 인증번호 확인 =====
        function verifyEmailCode() {
            const emailInput = document.getElementById('email');
            const codeInput = document.getElementById('verificationCode');
            const verifyBtn = document.getElementById('verifyCodeBtn');

            const email = emailInput.value.trim();
            const code = codeInput.value.trim();

            if (!code || code.length !== 6) {
                alert('6자리 인증번호를 입력해주세요.');
                codeInput.focus();
                return;
            }

            verifyBtn.disabled = true;
            verifyBtn.textContent = '확인 중...';

            fetch('/undongpedia/email/verify-code', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `email=\${encodeURIComponent(email)}&code=\${encodeURIComponent(code)}`
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        clearInterval(verificationTimer);
                        document.getElementById('verificationCodeSection').style.display = 'none';
                        document.getElementById('emailVerifiedAlert').style.display = 'block';
                        emailInput.readOnly = true;
                        document.getElementById('sendVerificationBtn').style.display = 'none';

                        emailVerified = true;
                        alert('이메일 인증이 완료되었습니다!');
                    } else {
                        verifyBtn.disabled = false;
                        verifyBtn.textContent = '확인';
                        alert(data.message || '인증번호가 일치하지 않습니다.');
                        codeInput.value = '';
                        codeInput.focus();
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    verifyBtn.disabled = false;
                    verifyBtn.textContent = '확인';
                    alert('서버 오류가 발생했습니다.');
                });
        }

        // ===== 타이머 시작 =====
        function startVerificationTimer(expireTime) {
            const timerElement = document.getElementById('timer');

            verificationTimer = setInterval(() => {
                const now = new Date().getTime();
                const timeLeft = Math.max(0, expireTime - now);

                if (timeLeft === 0) {
                    clearInterval(verificationTimer);
                    const sendBtn = document.getElementById('sendVerificationBtn');
                    sendBtn.disabled = false;
                    sendBtn.textContent = '인증번호 재발송';
                    sendBtn.style.display = 'inline-block';
                    timerElement.textContent = '00:00';
                    alert('인증번호가 만료되었습니다. 새로운 인증번호를 요청해주세요.');
                    return;
                }

                const minutes = Math.floor(timeLeft / 60000);
                const seconds = Math.floor((timeLeft % 60000) / 1000);
                timerElement.textContent = `\${minutes.toString().padStart(2, '0')}:\${seconds.toString().padStart(2, '0')}`;
            }, 1000);
        }

        // ===== 페이지 로드 시 실행 =====
        document.addEventListener('DOMContentLoaded', function() {
            const nameRegex = /^[가-힣a-zA-Z]{2,}$/;

            // 닉네임 플레이스홀더 설정
            const nicknameInput = document.getElementById('lastName');
            if (nicknameInput) {
                nicknameInput.placeholder = generateRandomNickname();

                nicknameInput.addEventListener('focus', function() {
                    if (this.value === '') {
                        this.placeholder = generateRandomNickname();
                    }
                });

                nicknameInput.addEventListener('click', function() {
                    if (this.value === '') {
                        this.placeholder = generateRandomNickname();
                    }
                });
            }

            // 이메일 인증 버튼 이벤트
            document.getElementById('sendVerificationBtn').addEventListener('click', sendVerificationEmail);
            document.getElementById('verifyCodeBtn').addEventListener('click', verifyEmailCode);

            // Enter 키 이벤트
            document.getElementById('verificationCode').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    verifyEmailCode();
                }
            });

            // 이름 실시간 검증
            document.getElementById('firstName').addEventListener('input', function() {
                const value = this.value;
                const errorDiv = document.getElementById('firstNameError');
                const successDiv = document.getElementById('firstNameSuccess');

                if (value === '') {
                    this.classList.remove('is-valid', 'is-invalid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '';
                } else if (nameRegex.test(value)) {
                    this.classList.remove('is-invalid');
                    this.classList.add('is-valid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '올바른 이름입니다.';
                } else {
                    this.classList.remove('is-valid');
                    this.classList.add('is-invalid');
                    successDiv.textContent = '';
                    errorDiv.textContent = '2글자 이상의 한글 또는 영어만 입력해주세요.';
                }
            });

            // 닉네임 실시간 검증
            document.getElementById('lastName').addEventListener('input', function() {
                const value = this.value;
                const errorDiv = document.getElementById('lastNameError');
                const successDiv = document.getElementById('lastNameSuccess');

                if (value === '') {
                    this.classList.remove('is-valid', 'is-invalid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '';
                } else if (nameRegex.test(value)) {
                    this.classList.remove('is-invalid');
                    this.classList.add('is-valid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '멋진 닉네임이네요!';
                } else {
                    this.classList.remove('is-valid');
                    this.classList.add('is-invalid');
                    successDiv.textContent = '';
                    errorDiv.textContent = '2글자 이상의 한글 또는 영어만 입력해주세요.';
                }
            });

            // 비밀번호 확인 실시간 검증
            function checkPasswordMatch() {
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirmPassword').value;
                const errorDiv = document.getElementById('passwordMatchError');
                const successDiv = document.getElementById('passwordMatchSuccess');
                const confirmInput = document.getElementById('confirmPassword');

                if (confirmPassword === '') {
                    confirmInput.classList.remove('is-valid', 'is-invalid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '';
                } else if (password === confirmPassword) {
                    confirmInput.classList.remove('is-invalid');
                    confirmInput.classList.add('is-valid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '비밀번호가 일치합니다.';
                } else {
                    confirmInput.classList.remove('is-valid');
                    confirmInput.classList.add('is-invalid');
                    successDiv.textContent = '';
                    errorDiv.textContent = '비밀번호가 일치하지 않습니다.';
                }
            }

            document.getElementById('password').addEventListener('input', checkPasswordMatch);
            document.getElementById('confirmPassword').addEventListener('input', checkPasswordMatch);
        });

        // ===== 폼 제출 검증 =====
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            let isValid = true;

            // 이메일 인증 확인 (가장 먼저)
            // if (!emailVerified) {
            //     e.preventDefault();
            //     alert('이메일 인증을 완료해주세요.');
            //     document.getElementById('email').focus();
            //     return false;
            // }

            // 서비스 이용약관 동의 확인
            const termsChecked = document.getElementById('terms').checked;
            if (!termsChecked) {
                e.preventDefault();
                alert('서비스 이용약관 및 개인정보처리방침에 동의해주세요.');
                return false;
            }

            // 이름 확인
            const firstName = document.getElementById('firstName');
            if (firstName.classList.contains('is-invalid') || !firstName.classList.contains('is-valid')) {
                e.preventDefault();
                firstName.focus();
                isValid = false;
            }

            // 닉네임 확인
            const lastName = document.getElementById('lastName');
            if (lastName.classList.contains('is-invalid') || !lastName.classList.contains('is-valid')) {
                e.preventDefault();
                if (isValid) lastName.focus();
                isValid = false;
            }

            // 비밀번호 확인
            const confirmPassword = document.getElementById('confirmPassword');
            if (confirmPassword.classList.contains('is-invalid') || !confirmPassword.classList.contains('is-valid')) {
                e.preventDefault();
                if (isValid) confirmPassword.focus();
                isValid = false;
            }

            return isValid;
        });
    </script>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>