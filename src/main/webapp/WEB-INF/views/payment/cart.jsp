<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<section>
    <h3>cart</h3>
    <button onclick="location.assign('${pageContext.request.contextPath}/payment/start')">
        <img src= "${pageContext.request.contextPath}/resources/images/btn_npaygr_pay.svg" alt="">
    </button>
</section>

<%--    /*--%>
<%--    * 1. 버튼으로 요청 받은 후 PaymentController--%>
<%--    * 2. PaymentController에서 해당 상품의 이름, 갯수, api 정보들을 세팅--%>
<%--    * 3. returnUrl 로 반환--%>
<%--    * 4-1. 결제 결과 성공 -> 유저 데이터에 수강목록 추가--%>
<%--    * 4-2  결제 결과 실패 -> 장바구니로 redirect--%>
<%--    * 5. ??--%>
<%--    * */--%>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>