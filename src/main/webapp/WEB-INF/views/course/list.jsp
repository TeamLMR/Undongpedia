<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<section>
    <h3>course list</h3>

    <div onclick="location.href='${path}/course/detail'">
        <h3>코스 디테일 테스트</h3>
    </div>
</section>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>