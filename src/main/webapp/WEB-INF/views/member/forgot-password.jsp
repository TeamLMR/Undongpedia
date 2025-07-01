<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>비밀번호 찾기</title>
    <jsp:include page="../common/header.jsp"/>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="text-center">비밀번호 찾기</h3>
                    </div>
                    <div class="card-body">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger" role="alert">
                                ${error}
                            </div>
                        </c:if>
                        <c:if test="${not empty message}">
                            <div class="alert alert-success" role="alert">
                                ${message}
                            </div>
                        </c:if>
                        <p class="text-center mb-4">
                            가입하신 이메일과 이름을 입력하시면<br>
                            비밀번호 재설정 링크를 발송해드립니다.
                        </p>
                        <form action="${pageContext.request.contextPath}/member/forgot-password" method="post">
                            <div class="form-group mb-3">
                                <label for="memberId">이메일</label>
                                <input type="email" class="form-control" id="memberId" name="memberId" 
                                       placeholder="가입한 이메일을 입력하세요" required
                                       value="${memberId}" <c:if test="${success}">disabled</c:if>>
                            </div>
                            <div class="form-group mb-3">
                                <label for="memberName">이름</label>
                                <input type="text" class="form-control" id="memberName" name="memberName" 
                                       placeholder="가입한 이름을 입력하세요" required
                                       value="${memberName}" <c:if test="${success}">disabled</c:if>>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block"
                                    <c:if test="${success}">disabled</c:if>>비밀번호 재설정 링크 받기</button>
                        </form>
                        <c:if test="${success}">
                            <div class="alert alert-success mt-3">
                                <b>${memberName}님, <strong>${memberId}</strong>으로 이메일이 발송되었습니다.</b><br>
                                <b> 이메일로 발송된 비밀번호 변경 링크는 30분간 유효합니다.</b><br>
                                <b> 이메일을 확인해주세요. </b>
                            </div>
                        </c:if>
                        <div class="text-center mt-3">
                            <a href="${pageContext.request.contextPath}/member/login">로그인으로 돌아가기</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="../common/footer.jsp"/>
</body>
</html> 