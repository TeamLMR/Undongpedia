<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>비밀번호 업데이트</title>
    <jsp:include page="../common/header.jsp"/>
</head>
<body>
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h3 class="text-center">비밀번호 업데이트</h3>
                </div>
                <div class="card-body">
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" role="alert">
                                ${errorMessage}
                        </div>
                    </c:if>
                    <form action="${pageContext.request.contextPath}/member/update-password" method="post">
                        <input type="hidden" name="token" value="${token}"/>
                        <div class="form-group">
                            <label for="password">새 비밀번호</label>
                            <input type="password" class="form-control" id="password" name="newPassword" required>
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">비밀번호 확인</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        </div>
                        <button type="submit" class="btn btn-primary btn-block">비밀번호 업데이트</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="../common/footer.jsp"/>
</body>
</html> 