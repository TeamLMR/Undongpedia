<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/coach/common/header.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>
<c:if test="${not empty resultMap}">
    <c:forEach var="entry" items="${resultMap}">
        <c:set var="reviewCount" value="${reviewCount + entry.value.size()}"/>
        <c:forEach var="review" items="${entry.value}" varStatus="status">
            <c:set var="addAllAverRev" value="${addAllAverRev + review.reviewRate}"/>
        </c:forEach>
    </c:forEach>
    <c:set var="allAverRev" value="${addAllAverRev /reviewCount}"/>
    <fmt:formatNumber value="${allAverRev}" var = "allAverRev" pattern="0.0" />
</c:if>

<style>
    .course-section {
        background: #f8f9fa;
        border-radius: 1rem;
        padding: 2rem;
        margin-bottom: 2rem;
    }

    .course-header {
        justify-content: space-between;
        border-radius: 0.75rem;
        /*padding: 1.5rem;*/
        margin-bottom: 1.5rem;
    }

    .review-card {
        transition: all 0.3s ease;
        border-radius: 0.75rem;
        border: none;
        margin-bottom: 1rem;
    }

    .review-card:hover {
        transform: translateY(-2px);
    }

    .star-rating {
        color: #ffc107;
    }

    .reviewer-avatar {
        width: 40px;
        height: 40px;
        background: linear-gradient(135deg, #7692e3 0%, #4e73df 100%);
        font-size: 0.9rem;
    }

    .course-stats {
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

<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<div id="content-wrapper" class="d-flex flex-column">
    <!-- Main Content -->
    <div id="content">
        <!-- Topbar -->
        <jsp:include page="/WEB-INF/views/coach/common/topbar.jsp"/>
        <div class="container-fluid">
            <div class="container-fluid">
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">리뷰 관리</h1>
                </div>
                <div class="row mb-4">
                    <div class="col-md-3 mb-3">
                        <div class="card overview-card shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center justify-content-around">
                                    <div class="stat-icon bg-primary text-white me-3">
                                        <i class="bi bi-person"></i>
                                    </div>
                                    <div>
                                        <h6 class="text-muted mb-1">전체 리뷰</h6>
                                        <h4 class="mb-0">${reviewCount}</h4>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card overview-card shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center justify-content-around">
                                    <div class="stat-icon bg-primary text-white me-3">
                                        <i class="bi bi-star"></i>
                                    </div>
                                    <div>
                                        <h6 class="text-muted mb-1">전체 리뷰 평균</h6>
                                        <h4 class="mb-0">${allAverRev}</h4>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 mb-3">
                        <div class="card overview-card shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center justify-content-around">
                                    <div class="stat-icon bg-primary text-white me-3">
                                        <i class="bi bi-book"></i>
                                    </div>
                                    <div>
                                        <h6 class="text-muted mb-1">운영 코스</h6>
                                        <h4 class="mb-0">${not empty resultMap ? resultMap.size() : 0}</h4>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

<%--                <!-- 필터 탭 -->--%>
<%--                <div class="row mb-4">--%>
<%--                    <div class="col-12">--%>
<%--                        <ul class="nav filter-tabs">--%>
<%--                            <li class="nav-item">--%>
<%--                                <a class="nav-link active" href="#">모든 리뷰</a>--%>
<%--                            </li>--%>
<%--                            <li class="nav-item">--%>
<%--                                <a class="nav-link" href="#">최신순</a>--%>
<%--                            </li>--%>
<%--                            <li class="nav-item">--%>
<%--                                <a class="nav-link" href="#">평점 높은순</a>--%>
<%--                            </li>--%>
<%--                            <li class="nav-item">--%>
<%--                                <a class="nav-link" href="#">평점 낮은순</a>--%>
<%--                            </li>--%>
<%--                        </ul>--%>
<%--                    </div>--%>
<%--                </div>--%>

                <!-- Content Row -->
                <div class="row">
                    <div class="col-12">
                        <c:if test="${not empty resultMap}">
                            <c:forEach var="entry" items="${resultMap}">
                                <!-- 코스별 섹션 -->
                                <div class="course-section">
                                    <!-- 코스 헤더 -->
                                    <div class="course-header">
                                        <div class="row align-items-center ">
                                            <div class="col-md-8">

                                                <h4 class="mb-1 fw-bold text-dark">
                                                        ${entry.key.courseTitle}
                                                </h4>
                                                <p class="text-muted mb-0">
                                                    <span class="me-3"><i class="bi bi-clock me-1"></i>개설일: <fmt:formatDate value="${entry.key.courseCreateTime}" pattern="yyyy.MM.dd" />
                                                    </span>
                                                </p>
                                            </div>
                                            <div class="col-md-4 text-md-end">
                                                <div class="course-stats d-flex align-items-center justify-content-around">
                                                    <span class="me-3">
                                                        <strong>평균</strong>
                                                        <span class="text-warning">
                                                            <c:set var="averRev" value="0"/>
                                                            <c:forEach var="review" items="${entry.value}" varStatus="status">
                                                                <c:set var="averRev" value="${averRev+review.reviewRate}"/>
                                                            </c:forEach>
                                                            <i class="bi bi-star-fill"></i>
                                                            <c:if test="${not empty averRev}">
                                                                <fmt:formatNumber value="${averRev/entry.value.size()}" pattern="0.0" />


                                                            </c:if>
                                                        </span>
                                                    </span>
                                                    <span>
                                                        <strong>리뷰</strong> ${entry.value.size()}개
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 리뷰 목록 -->
                                    <div class="row">
                                        <c:forEach var="review" items="${entry.value}" varStatus="status">
                                            <div class="col-12">
                                                <div class="card review-card shadow-sm">
                                                    <div class="card-body">
                                                        <div class="row">
                                                            <div class="col-md-9">
                                                                <small class="text-muted">
                                                                    <i class="bi bi-calendar3 me-1"></i>
                                                                    <fmt:formatDate value="${review.reviewCreateDate}" pattern="yyyy.MM.dd" />
                                                                </small>
                                                                <!-- 리뷰 헤더 -->
                                                                <div class="d-flex justify-content-between align-items-start mb-2">
                                                                    <h5 class="card-title mb-1">${review.reviewTitle}</h5>
                                                                </div>

                                                                <!-- 별점 -->
                                                                <div class="star-rating mb-3">
                                                                    <c:forEach begin="1" end="5" var="i">
                                                                        <c:choose>
                                                                            <c:when test="${i <= review.reviewRate}">
                                                                                <i class="bi bi-star-fill"></i>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <i class="bi bi-star"></i>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </c:forEach>
                                                                    <span class="ms-2 text-muted">${review.reviewRate}점</span>
                                                                </div>

                                                                <!-- 리뷰 내용 -->
                                                                <p class="card-text text-secondary">
                                                                        ${review.reviewContent}
                                                                </p>
                                                            </div>

                                                            <div class="col-md-3">
                                                                <!-- 리뷰어 정보 -->
                                                                <div class="text-md-end">
                                                                    <div class="d-flex align-items-center justify-content-md-end mb-2">
                                                                        <div class="reviewer-avatar rounded-circle d-flex align-items-center justify-content-center text-white me-2">
                                                                            <span class="fw-bold">${review.memberNickname.substring(0,1)}</span>
                                                                        </div>
                                                                        <div class="text-start">
                                                                            <h6 class="mb-0 small">${review.memberNickname}</h6>
                                                                            <small class="text-muted">수강생</small>
                                                                        </div>
                                                                    </div>

                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <c:if test="${entry.value.size() > 3}">
                                        <div class="text-center mt-3">
                                            <button class="btn btn-outline-primary btn-sm">
                                                <i class="bi bi-chevron-down me-1"></i>
                                                더 많은 리뷰 보기
                                            </button>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </c:if>

                        <c:if test="${empty resultMap}">
                            <!-- 빈 상태 -->
                            <div class="card border-0 shadow-sm">
                                <div class="card-body text-center py-5">
                                    <i class="bi bi-chat-square-text text-muted" style="font-size: 4rem;"></i>
                                    <h5 class="mt-4 mb-2">아직 작성된 리뷰가 없습니다</h5>
                                    <p class="text-muted mb-4">수강생들이 코스를 수강하고 리뷰를 작성하면 여기에 표시됩니다.</p>
                                    <a href="${pageContext.request.contextPath}/coach/addCourse" class="btn btn-primary">
                                        <i class="bi bi-plus-circle me-2"></i>새 코스 만들기
                                    </a>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>


<jsp:include page="/WEB-INF/views/coach/common/footer.jsp"/>