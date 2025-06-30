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
                                    <button id="${orders.ordersSeq}" class="btn btn-outline-danger btn-sm cancel-paid-btn">구매 취소</button>
                                </c:if>
                                <butten id="${orders.ordersSeq}" class="btn btn-outline-secondary btn-sm receipt-btn">거래명세서</butten>
                            </div>
                        </div>

                        <div class="text-md-end d-flex flex-column justify-content-end align-items-end" style="min-width: 180px;">
                            <small class="text-muted">결제 금액</small>
                            <div class="fw-bold fs-5">₩<fmt:formatNumber value="${orders.ordersPrice}" type="number"/></div>
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

<div class="modal fade" id="cancelModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel">결제 취소 확인</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>

            <div class="modal-body">
                해당 강의 결제를 정말 취소하시겠습니까?
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">아니오</button>
                <button type="button" class="btn btn-primary" id="confirmCancelBtn">네, 취소합니다</button>
            </div>

        </div>
    </div>
</div>

<div class="modal fade" id="invoiceModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel">거래명세서 확인</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>

            <div class="modal-body">
                해당 강의의 거래명세서를 받으시겠습니까?
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">아니오</button>
                <button type="button" class="btn btn-primary" id="confirmOrderInvoiceBtn">네</button>
            </div>

        </div>
    </div>
</div>

<script>
    let selectedOrderId = null;

    $('.cancel-paid-btn').on('click', function (e) {
        e.preventDefault();
        selectedOrderId = $(this).attr("id"); // 클릭된 버튼의 주문번호
        $('#cancelModal').modal('show'); // 모달 열기
    });

    $('#confirmCancelBtn').on('click', function () {
        if (selectedOrderId) {
            const redirectUrl = "${pageContext.request.contextPath}/payment/cancel?id=" + selectedOrderId;
            location.href = redirectUrl;
        }

    });

    $('.receipt-btn').on('click', function (e) {
        e.preventDefault();
        selectedOrderId = $(this).attr("id"); // 클릭된 버튼의 주문번호
        $('#invoiceModal').modal('show'); // 모달 열기
    });

    $('#confirmOrderInvoiceBtn').on('click', function () {
        if (selectedOrderId) {
            const redirectUrl = "${pageContext.request.contextPath}/payment/orderinvoice?id=" + selectedOrderId;
            location.href = redirectUrl;
        }
    });
</script>
