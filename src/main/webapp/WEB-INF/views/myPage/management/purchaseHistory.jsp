<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="container px-3 px-md-5 my-5">
    <h2 class="fw-bold mb-5">구매내역</h2>

    <c:if test="${not empty ordersList}">
        <c:forEach var="orders" items="${ordersList}">
            <div class="position-relative mb-5">
                <!-- 카드 위 배지 -->
                <div class="position-absolute top-0 start-0 translate-middle-y bg-white px-3 py-1 small text-muted border rounded">
                    주문일 <fmt:formatDate value="${orders.createdAt}" pattern="yyyy.MM.dd" /> · 주문번호 ${orders.detail.ordersPaymentId}
                </div>

                <!-- 주문 카드 -->
                <div class="border rounded-3 bg-white p-4 pt-5 shadow-sm">
                    <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3">

                        <!-- 왼쪽: 수강 정보 -->
                        <div class="flex-grow-1">
                            <c:choose>
                                <c:when test="${orders.cancelYn eq 'Y' && orders.ordersStatus eq 'CANC'}">
                                    <span class="badge bg-light text-danger border">결제 취소</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-primary border">결제 완료</span>
                                </c:otherwise>
                            </c:choose>
                            <c:choose>
                                <c:when test="${orders.ordersPrimaryPay eq 'CARD'}">
                                    <span class="badge bg-light text-dark border">카드 결제</span>
                                </c:when>
                                <c:when test="${orders.ordersPrimaryPay eq 'BANK'}">
                                    <span class="badge bg-light text-dark border">계좌이체</span>
                                </c:when>
                                <c:when test="${orders.ordersPrimaryPay eq 'POINT'}">
                                    <span class="badge bg-light text-dark border">네이버 페이</span>
                                </c:when>
                            </c:choose>
                            <h5 class="fw-bold mt-2">${orders.courseTitle}</h5>

                            <!-- 버튼 영역 -->
                            <div class="d-flex gap-2 mt-3">
                                <c:if test="${orders.ordersStatus eq 'PAID' && orders.cancelYn eq 'N'}">
                                    <a href="${path}/orders/cancel?id=" class="btn btn-outline-danger btn-sm">구매 취소</a>
                                </c:if>
                                <a href="${path}/orders/receipt?id=" class="btn btn-outline-secondary btn-sm">영수증 다운로드</a>
                            </div>
                        </div>

                        <div class="text-md-end d-flex flex-column justify-content-end align-items-end" style="min-width: 180px;">
                            <small class="text-muted">결제 금액</small>
                            <div class="fw-bold fs-5">₩<fmt:formatNumber value="${orders.ordersPrice}" type="number" /></div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </c:if>

    <c:if test="${empty ordersList}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-receipt fs-1 mb-3 d-block"></i>
            <p class="mb-0">주문 내역이 없습니다.</p>
        </div>
    </c:if>
</div>

