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
                    <li><a href="${path}/login">로그인</a></li>
                    <li class="current">비밀번호 찾기</li>
                </ol>
            </nav>
            <h1>비밀번호 찾기</h1>
        </div>
    </div>

    <section id="forgot-password" class="forgot-password section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row justify-content-center">
                <div class="col-lg-6">
                    <div class="forgot-password-wrapper" data-aos="zoom-in" data-aos-delay="200">
                        <div class="section-header mb-4 text-center">
                            <h2>비밀번호를 잊으셨나요?</h2>
                            <p>가입하신 이메일과 이름을 입력하시면<br>비밀번호 재설정 링크를 보내드립니다.</p>
                        </div>

                        <form id="forgotPasswordForm">
                            <!-- 이메일 입력 -->
                            <div class="form-group mb-3">
                                <label for="email">이메일 <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" name="memberId" id="email"
                                       required placeholder="example@email.com">
                                <div class="invalid-feedback" id="emailError"></div>
                                <div class="valid-feedback" id="emailSuccess"></div>
                            </div>

                            <!-- 이름 입력 -->
                            <div class="form-group mb-4">
                                <label for="memberName">이름 <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" name="memberName" id="memberName"
                                       required minlength="2" placeholder="가입 시 입력한 이름">
                                <div class="invalid-feedback" id="nameError"></div>
                                <div class="valid-feedback" id="nameSuccess"></div>
                            </div>

                            <!-- 비밀번호 재설정 버튼 -->
                            <div class="text-center mb-4">
                                <button type="button" class="btn btn-primary w-100" onclick="sendPasswordResetLink()">
                                    비밀번호 재설정 링크 받기
                                </button>
                            </div>

                            <!-- 돌아가기 링크 -->
                            <div class="text-center">
                                <p class="mb-0">
                                    <a href="${path}/login" class="text-decoration-none">
                                        <i class="bi bi-arrow-left me-1"></i>로그인 페이지로 돌아가기
                                    </a>
                                </p>
                            </div>
                        </form>

                        <!-- 이메일 발송 성공 메시지 (초기에는 숨김) -->
                        <div class="alert alert-success mt-4" id="successMessage" style="display: none;">
                            <div class="d-flex align-items-start">
                                <i class="bi bi-check-circle-fill me-3 mt-1" style="font-size: 1.5rem;"></i>
                                <div>
                                    <h5 class="alert-heading mb-2">이메일이 발송되었습니다!</h5>
                                    <p class="mb-2">
                                        <strong id="sentEmail"></strong>으로 비밀번호 재설정 링크를 발송했습니다.
                                    </p>
                                    <p class="mb-0">
                                        <small>링크는 30분간 유효합니다. 이메일을 확인해주세요.</small>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- 사용자 없음 메시지 (초기에는 숨김) -->
                        <div class="alert alert-warning mt-4" id="notFoundMessage" style="display: none;">
                            <div class="d-flex align-items-start">
                                <i class="bi bi-exclamation-triangle-fill me-3 mt-1" style="font-size: 1.5rem;"></i>
                                <div>
                                    <h5 class="alert-heading mb-2">일치하는 회원 정보가 없습니다</h5>
                                    <p class="mb-2">
                                        입력하신 이메일과 이름으로 등록된 계정을 찾을 수 없습니다.
                                    </p>
                                    <div class="mt-3">
                                        <a href="${path}/signup" class="btn btn-warning btn-sm">
                                            <i class="bi bi-person-plus me-1"></i>회원가입 하러가기
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <style>
        .forgot-password-wrapper {
            background: white;
            border-radius: 12px;
            padding: 3rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }

        .section-header h2 {
            color: #333;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .section-header p {
            color: #6c757d;
            font-size: 0.95rem;
            line-height: 1.6;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            font-weight: 500;
            color: #333;
            margin-bottom: 0.5rem;
            display: block;
        }

        .form-control {
            border-radius: 8px;
            border: 1px solid #dee2e6;
            padding: 0.75rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: #007bff;
            box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
        }

        .btn-primary {
            background: #007bff;
            border: none;
            border-radius: 8px;
            padding: 0.75rem 2rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            background: #0056b3;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0, 123, 255, 0.3);
        }

        .btn-primary:disabled {
            background: #6c757d;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

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

        .alert {
            border: none;
            border-radius: 10px;
            animation: slideIn 0.3s ease-out;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
        }

        .alert-warning {
            background: #fff3cd;
            color: #856404;
        }

        .alert-heading {
            font-size: 1.1rem;
            font-weight: 600;
        }

        .btn-warning {
            background: #ffc107;
            border: none;
            color: #212529;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-warning:hover {
            background: #e0a800;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(255, 193, 7, 0.3);
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @media (max-width: 767px) {
            .forgot-password-wrapper {
                padding: 2rem 1.5rem;
            }
        }
    </style>

    <script>
        // ===== 이메일 검증 =====
        function validateEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        // ===== 이름 검증 =====
        function validateName(name) {
            const re = /^[가-힣a-zA-Z]{2,}$/;
            return re.test(name);
        }

        // ===== 비밀번호 재설정 링크 발송 =====
        function sendPasswordResetLink() {
            const emailInput = document.getElementById('email');
            const nameInput = document.getElementById('memberName');
            const email = emailInput.value.trim();
            const name = nameInput.value.trim();

            // 유효성 검사
            let isValid = true;

            // 이메일 검사
            if (!email || !validateEmail(email)) {
                emailInput.classList.add('is-invalid');
                document.getElementById('emailError').textContent = '올바른 이메일 주소를 입력해주세요.';
                isValid = false;
            } else {
                emailInput.classList.remove('is-invalid');
                emailInput.classList.add('is-valid');
                document.getElementById('emailError').textContent = '';
                document.getElementById('emailSuccess').textContent = '올바른 이메일 형식입니다.';
            }

            // 이름 검사
            if (!name || !validateName(name)) {
                nameInput.classList.add('is-invalid');
                document.getElementById('nameError').textContent = '2글자 이상의 한글 또는 영어만 입력해주세요.';
                isValid = false;
            } else {
                nameInput.classList.remove('is-invalid');
                nameInput.classList.add('is-valid');
                document.getElementById('nameError').textContent = '';
                document.getElementById('nameSuccess').textContent = '올바른 이름입니다.';
            }

            if (!isValid) {
                return;
            }

            // 버튼 비활성화
            const button = event.target;
            button.disabled = true;
            button.innerHTML = '<i class="bi bi-arrow-clockwise me-2"></i>처리 중...';

            // 여기에 실제 API 호출 로직이 들어갑니다
            // 지금은 시뮬레이션만 합니다
            setTimeout(() => {
                // 랜덤으로 성공/실패 시뮬레이션
                const isUserFound = Math.random() > 0.5;

                // 메시지 초기화
                document.getElementById('successMessage').style.display = 'none';
                document.getElementById('notFoundMessage').style.display = 'none';

                if (isUserFound) {
                    // 성공 메시지 표시
                    document.getElementById('sentEmail').textContent = email;
                    document.getElementById('successMessage').style.display = 'block';

                    // 폼 숨기기
                    document.getElementById('forgotPasswordForm').style.display = 'none';
                } else {
                    // 사용자 없음 메시지 표시
                    document.getElementById('notFoundMessage').style.display = 'block';

                    // 버튼 복원
                    button.disabled = false;
                    button.innerHTML = '비밀번호 재설정 링크 받기';
                }
            }, 1500);
        }

        // ===== 페이지 로드 시 실행 =====
        document.addEventListener('DOMContentLoaded', function() {
            // 이메일 실시간 검증
            document.getElementById('email').addEventListener('input', function() {
                const value = this.value;
                const errorDiv = document.getElementById('emailError');
                const successDiv = document.getElementById('emailSuccess');

                if (value === '') {
                    this.classList.remove('is-valid', 'is-invalid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '';
                } else if (validateEmail(value)) {
                    this.classList.remove('is-invalid');
                    this.classList.add('is-valid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '올바른 이메일 형식입니다.';
                } else {
                    this.classList.remove('is-valid');
                    this.classList.add('is-invalid');
                    successDiv.textContent = '';
                    errorDiv.textContent = '올바른 이메일 주소를 입력해주세요.';
                }
            });

            // 이름 실시간 검증
            document.getElementById('memberName').addEventListener('input', function() {
                const value = this.value;
                const errorDiv = document.getElementById('nameError');
                const successDiv = document.getElementById('nameSuccess');

                if (value === '') {
                    this.classList.remove('is-valid', 'is-invalid');
                    errorDiv.textContent = '';
                    successDiv.textContent = '';
                } else if (validateName(value)) {
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

            // Enter 키 이벤트
            document.getElementById('forgotPasswordForm').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    sendPasswordResetLink();
                }
            });
        });
    </script>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>