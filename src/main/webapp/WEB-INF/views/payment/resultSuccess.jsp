<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main class="main">
    <!-- Page Title -->
    <div class="page-title light-background">
        <div class="container">
            <nav class="breadcrumbs">
                <ol>
                    <li><a href="${pageContext.request.contextPath}">Home</a></li>
                    <li class="current">Payment Complete</li>
                </ol>
            </nav>
            <h1>결제 완료</h1>
        </div>
    </div>
    <!-- End Page Title -->

    <section class="payment-complete section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm p-4">
                        <div class="text-center mb-4">
                            <i class="bi bi-check-circle text-success" style="font-size: 3rem;"></i>
                            <h2 class="mt-3">결제가 성공적으로 완료되었습니다!</h2>
                            <p class="text-muted">아래에서 수강하실 강의 목록을 확인하세요.</p>
                        </div>
                        <c:if test="${not empty ordersList}">
                            <c:forEach var="invoice" items="${ordersList}">
                                <c:forEach var="course" items="${invoice.courses}">
                                    <div class="cart-item border-top pt-3 mt-3">
                                        <div class="row align-items-center">
                                            <div class="col-lg-8 col-12">
                                                <div class="product-info d-flex align-items-center">
                                                    <div class="product-details">
                                                        <c:if test="${not empty course.courseTitle}">
                                                            <h6 class="product-title mb-1">${course.courseTitle}</h6>
                                                        </c:if>
                                                        <c:if test="${not empty invoice.ordersTimestamp}">
                                                            <p class="text-muted mb-0">
                                                                <i class="bi bi-clock me-1"></i>
                                                                <fmt:formatDate value="${invoice.ordersTimestamp}" pattern="yyyy-MM-dd HH:mm"/>
                                                            </p>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-lg-4 col-12 text-end">
                                                <div class="text-end">
                                                    <c:if test="${not empty invoice.ordersPrice}">
                                                        <div class="fs-5">₩
                                                            <fmt:formatNumber value="${invoice.ordersPrice}" type="number"/>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:forEach>
                        </c:if>

                        <div class="text-center mt-5">
                            <a href="${pageContext.request.contextPath}/mypage" class="btn btn-primary btn-lg">
                                <i class="bi bi-mortarboard me-2"></i>내 강의실로 이동
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
