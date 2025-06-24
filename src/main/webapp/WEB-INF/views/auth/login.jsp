<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="path" value="${pageContext.request.contextPath}"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>


<main class="main">

    <!-- Page Title -->
    <div class="page-title light-background position-relative">
        <div class="container">
            <nav class="breadcrumbs">
                <ol>
                    <li><a href="${path}">홈</a></li>
                    <li class="current">로그인</li>
                </ol>
            </nav>
            <h1>로그인</h1>
        </div>
    </div><!-- End Page Title -->

    <!-- Login Section -->
    <section id="login" class="login section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row justify-content-center">
                <div class="col-lg-5 col-md-8" data-aos="zoom-in" data-aos-delay="200">
                    <div class="login-form-wrapper">
                        <div class="login-header text-center">
                            <h2>로그인</h2>
                            <p>운동백과에서 건강한 몸을 만들어요!</p>
                        </div>

                        <form method="post" action="${path}/login.do">
                            <div class="mb-4">
                                <label for="email" class="form-label">이메일</label>
                                <input type="email" class="form-control" id="email" name="memberId" placeholder="이메일을 입력하세요" required="" autocomplete="email">
                            </div>

                            <div class="mb-3">
                                <div class="d-flex justify-content-between">
                                    <label for="password" class="form-label">비밀번호</label>
                                    <a href="${path}/forgot-password" class="forgot-link">비밀번호를 잊으셨나요?</a>
                                </div>
                                <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호를 입력하세요" required="" autocomplete="current-password">
                            </div>

                            <div class="mb-4 form-check">
                                <input type="checkbox" class="form-check-input" id="remember" name="remember">
                                <label class="form-check-label" for="remember">로그인 유지</label>
                            </div>

                            <div class="d-grid gap-2 mb-4">
                                <button type="submit" class="btn btn-primary">로그인</button>
                                <button type="button" class="btn btn-outline">
                                    <i class="bi bi-naver me-2"></i>네이버로 로그인
                                </button>
                            </div>

                            <div class="signup-link text-center">
                                <span>계정이 없으신가요?</span>
                                <a href="${path}/signup">무료로 회원가입</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section><!-- /Login Section -->

</main>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>