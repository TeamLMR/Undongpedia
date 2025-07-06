<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/coach/common/header.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>

<style>
    .payment-section {
        background: #f8f9fa;
        border-radius: 1rem;
        padding: 2rem;
        margin-bottom: 2rem;
    }

    .payment-header {
        justify-content: space-between;
        border-radius: 0.75rem;
        /*padding: 1.5rem;*/
        margin-bottom: 1.5rem;
    }

    .payment-card {
        transition: all 0.3s ease;
        border-radius: 0.75rem;
        border: none;
        margin-bottom: 1rem;
    }

    .payment-card:hover {
        transform: translateY(-2px);
    }

    .star-rating {
        color: #ffc107;
    }


    .payment-stats {
        background: #e9ecef;
        border-radius: 0.5rem;
        padding: 1rem;
    }

    .filter-tabs .nav-link {
        color: #6c757d;
        border: none;
        padding: 0.75rem 1.5rem;
        margin-right: 0.5rem;
        border-radius: 0.5rem;
        font-weight: 500;
    }

    .filter-tabs .nav-link.active {
        background: #4e73df;
        color: white;
    }

    .overview-card {
        border: none;
        border-radius: 1rem;
        overflow: hidden;
    }

    .overview-card .card-body {
        padding: 2rem;
    }

    .stat-icon {
        width: 60px;
        height: 60px;
        border-radius: 1rem;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
    }
</style>
<c:forEach var="val" items="${monthlyTotals}" varStatus="status">
    <c:set var="allPaymentResult" value="${allPaymentResult+val.value}"/>
</c:forEach>

<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<div id="content-wrapper" class="d-flex flex-column">
    <div id="content-wrapper" class="d-flex flex-column">
        <!-- Main Content -->
        <div id="content">
            <!-- Topbar -->
            <jsp:include page="/WEB-INF/views/coach/common/topbar.jsp"/>
            <div class="container-fluid">
                <div class="container-fluid">
                    <div class="d-sm-flex align-items-center justify-content-between mb-4">
                        <h1 class="h3 mb-0 text-gray-800">수익 관리</h1>
                    </div>
                    <!-- 수익 개요 카드 -->
                    <div class="row mb-4">
                        <!-- 최고 수익 달 -->
                        <div class="col-md-4 mb-3">
                            <div class="card overview-card shadow-sm align-items-start">
                                <div class="card-body d-flex align-items-center justify-content-between">
                                    <div class="stat-icon bg-warning text-white">
                                        <i class="bi bi-trophy-fill"></i>
                                    </div>
                                    <div class="mx-2 text-end">
                                        <h6 class="text-muted">최고 수익 달</h6>
                                        <h5 class="mb-0 text-dark">
                                            ${maxMonth}월 (₩<fmt:formatNumber value="${max}" type="number"/>)
                                        </h5>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="card overview-card shadow-sm align-items-start">
                                <div class="card-body d-flex align-items-center justify-content-between">
                                    <div class="stat-icon bg-success text-white">
                                        <i class="bi bi-graph-up-arrow"></i>
                                    </div>
                                    <div class="mx-2 text-end">
                                        <h6 class="text-muted">올해 총 수익</h6>
                                        <h5 class="mb-0 text-dark">
                                            <c:if test="${not empty allPaymentResult}">
                                                <fmt:formatNumber value="${allPaymentResult}" type="currency"/>

                                            </c:if>
                                            <c:if test="${empty allPaymentResult}">
                                                0
                                            </c:if>
                                        </h5>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Content Row -->
                    <div class="row">
                        <div class="col-12">
                            <c:if test="${not empty payments}">
                                <c:if test="${not empty payments}">
                                    <div class="table-responsive">
                                        <table class="table table-bordered align-middle text-center bg-white shadow-sm">
                                            <thead class="table-light">
                                            <tr>
                                                <th>코스 제목</th>
                                                <th>가격</th>
                                                <th>구매 인원 수</th>
                                                <th>총 주문 수</th>
                                                <th>총 수익</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="p" items="${payments}">
                                                <tr>
                                                    <td class="text-start">${p.courseTitle}</td>
                                                    <td>₩<fmt:formatNumber value="${p.coursePrice - (p.coursePrice * p.courseDiscount/100)}" type="number"/></td>
                                                    <td>${p.memberCount}명</td>
                                                    <td>${p.orderCount}회</td>
                                                    <td class="fw-bold text-primary">
                                                        ₩<fmt:formatNumber value="${(p.coursePrice - (p.coursePrice * p.courseDiscount/100)) * p.orderCount}" type="number"/>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:if>
                            </c:if>

                            <c:if test="${empty payments}">
                                <!-- 빈 상태 -->
                                <div class="text-center text-muted py-5">
                                    <i class="bi bi-bar-chart-line fs-1 mb-3 d-block"></i>
                                    <p class="mb-0">아직 판매된 코스가 없습니다.</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    <!-- 월별 수익 그래프 -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <canvas id="monthlySalesChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script>
            const ctx = document.getElementById('monthlySalesChart').getContext('2d');
            const monthlySalesChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
                    datasets: [{
                        label: '₩ 수익',
                        backgroundColor: '#4e73df',
                        borderColor: '#4e73df',
                        data: [
                            <c:forEach var="val" items="${monthlyTotals}" varStatus="status">
                                ${val.value}<c:if test="${!status.last}">,</c:if>
                            </c:forEach>
                        ]
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: { callback: function(value) { return '₩' + value.toLocaleString(); } }
                        }
                    }
                }
            });
        </script>
    <jsp:include page="/WEB-INF/views/coach/common/footer.jsp"/>
