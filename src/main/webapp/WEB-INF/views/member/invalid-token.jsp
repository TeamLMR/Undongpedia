<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>유효하지 않은 링크</title>
    <jsp:include page="../common/header.jsp"/>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="text-center">유효하지 않은 링크</h3>
                    </div>
                    <div class="card-body text-center">
                        <p class="mb-4">${error}</p>
                        <p>비밀번호 재설정 링크가 만료되었거나 유효하지 않습니다.</p>
                        <p>새로운 비밀번호 재설정 링크를 받으시려면 아래 버튼을 클릭해주세요.</p>
                        <a href="${pageContext.request.contextPath}/member/forgot-password" class="btn btn-primary">
                            새 비밀번호 재설정 링크 받기
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="../common/footer.jsp"/>
</body>
</html> 