<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<main class="main">
    <section id="hero" class="hero bg-dark bg-gradient text-white border-top"
             style="padding-top: 3rem; padding-bottom: 3rem;">
        <div class="swiper">
            <div class="">
                <c:if test="${not empty course}">
                    <div class="swiper-slide">
                        <div class="container py-2">
                            <div class="row align-items-center text-center text-lg-start g-3">
                                <!-- 텍스트 -->
                                <div class="col-lg-6">
                                    <h2 class="fw-bold display-6 mb-3 text-light">${course.courseTitle}</h2>

                                    <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                        <span class="fw-bold fs-4 text-white">₩<fmt:formatNumber
                                                type="number" maxFractionDigits="3"
                                                value="${(course.coursePrice *(100-course.courseDiscount))/100}"/></span>
                                        <c:if test="${course.courseDiscount > 0}">
                                            <span class="text-primary text-decoration-line-through fs-6">₩<fmt:formatNumber
                                                    type="number" maxFractionDigits="3"
                                                    value="${course.coursePrice}"/></span>
                                            <span class="badge bg-primary text-white">${course.courseDiscount}% 할인</span>
                                        </c:if>
                                    </div>

                                    <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
                                        <span class="btn btn-primary btn-sm">${course.memberNickname}</span>
                                        <span class="btn btn-primary btn-sm">${course.cateValue}</span>
                                        <span class="btn btn-light btn-sm">
                                            <c:forEach begin="1" end="5" var="i">
                                                <c:choose>
                                                    <c:when test="${i <= course.courseDifficult}">
                                                        <span style="color: gold;">★</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: lightgray;">★</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </span>
                                    </div>

                                    <a href="${pageContext.request.contextPath}/course/reservation?courseSeq=${course.courseSeq}"
                                       class="btn btn-light btn-lg px-5 py-3 fw-bold">
                                            <span class="fw-bold fs-4 text-primary">수강 신청 하기</span>
                                    </a>
                                </div>

                                <!-- 이미지 -->
                                <div class="col-lg-6 d-flex align-items-center justify-content-center">
                                    <div class="ratio ratio-16x9 w-100 rounded overflow-hidden shadow-sm">
                                        <img src="${pageContext.request.contextPath}${course.courseThumbnail != null ? course.courseThumbnail : '/resources/images/dummy.webp'}"
                                             class="w-100 h-100 object-fit-cover" alt="${course.courseTitle}">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:if>

            </div>

            <!-- Swiper 버튼 -->
            <div class="swiper-button-prev h-50"></div>
            <div class="swiper-button-next h-50"></div>
            <style>
                .swiper-button-prev,
                .swiper-button-next {
                    opacity: 0;
                }
            </style>
        </div>
    </section>
    <section id="product-details" class="product-details section">
        <div class="container aos-init aos-animate" data-aos="fade-up" data-aos-delay="100">
            <div class="row aos-init aos-animate" data-aos="fade-up">
                <div class="col-12">
                    <div class="product-details-accordion">
                        <!-- Description Accordion -->
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#reviewRecommend" aria-expanded="true" aria-controls="description">
                                    추천 리뷰를 확인해 보세요!
                                </button>
                            </h2>
                            <div id="reviewRecommend" class="accordion-collapse collapse show">
                                <div class="accordion-body">
                                    <div class="product-description">
                                        <h4>Product Overview</h4>
                                        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum at lacus congue, suscipit elit nec, tincidunt orci. Phasellus egestas nisi vitae lectus imperdiet venenatis. Suspendisse vulputate quam diam, et consectetur augue condimentum in. Aenean dapibus urna eget nisi pharetra, in iaculis nulla blandit. Praesent at consectetur sem, sed sollicitudin nibh. Ut interdum risus ac nulla placerat aliquet.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#targetRecommend" aria-expanded="true" aria-controls="description">
                                    이런 분들께 추천드려요!
                                </button>
                            </h2>
                            <div id="targetRecommend" class="accordion-collapse collapse show">
                                <div class="accordion-body">
                                    <div class="product-description">
                                        <div class="row align-items-center">
                                            <div class="col-3">
                                                <div class="text-center p-2" style="border: #0a53be 1px dashed;border-radius: 30px">
                                                    <h1 style="color: #0f3d81;"><i class="bi bi-arrow-through-heart w-75"></i></h1>
                                                    <h3 style="color: #0f3d81;">학습 대상은<br>누구일까요?</h3>
                                                </div>
                                            </div>
                                            <div class="col-9">
                                                <c:set var="targetList" value="${course.courseTarget.split(',')}"/>
                                                <ul class="feature-list">
                                                    <c:forEach var="t" items="${targetList}">
                                                        <li class="align-items-center"><i class="bi bi-check-circle"></i> ${t}</li>
                                                    </c:forEach>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#preparation" aria-expanded="true" aria-controls="description">
                                    준비물
                                </button>
                            </h2>
                            <div id="preparation" class="accordion-collapse collapse show">
                                <div class="accordion-body">
                                    <div class="product-description">
                                        <div class="col-9">
                                            <c:set var="preparationList" value="${course.coursePreparation.split(',')}"/>
                                            <ul class="feature-list">
                                                <c:forEach var="p" items="${preparationList}">
                                                    <li class="align-items-center"><i class="bi bi-check-circle"></i> ${p}</li>
                                                </c:forEach>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#description" aria-expanded="true" aria-controls="description">
                                    강의 상세내용
                                </button>
                            </h2>
                            <div id="description" class="accordion-collapse collapse show">
                                <div class="accordion-body">
                                    <div class="product-description">
                                        ${course.courseContent}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Reviews Accordion -->
                        <div class="accordion-item" id="reviews">
                            <h2 class="accordion-header">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#reviewsContent" aria-expanded="false" aria-controls="reviewsContent">
                                    리뷰 목록 (${reviewInfoMap.count})
                                </button>
                            </h2>
                            <div id="reviewsContent" class="accordion-collapse collapse show">
                                <div class="accordion-body">
                                    <div class="product-reviews">
                                        <div class="reviews-summary">
                                            <div class="row">
                                                <div class="col-lg-4">
                                                    <div class="overall-rating">
                                                        <div class="rating-number">${reviewInfoMap.average}</div>
                                                        <c:set var="avgInt" value="${fn:substringBefore(reviewInfoMap.average, '.')}" />
                                                        <c:set var="avgDec" value="${fn:substringAfter(reviewInfoMap.average, '.')}" />

                                                        <div class="rating-stars">
                                                            <!-- 꽉 찬 별 -->
                                                            <c:forEach var="i" begin="1" end="${avgInt}">
                                                                <i class="bi bi-star-fill"></i>
                                                            </c:forEach>

                                                            <!-- 반 별 -->
                                                            <c:if test="${avgDec >= 5}">
                                                                <i class="bi bi-star-half"></i>
                                                            </c:if>

                                                            <!-- 빈 별 -->
                                                            <c:forEach var="i" begin="1" end="${5 - avgInt - (avgDec >= 5 ? 1 : 0)}">
                                                                <i class="bi bi-star"></i>
                                                            </c:forEach>
                                                        </div>
                                                        <div class="rating-count">총 ${reviewInfoMap.count} 리뷰의 평점</div>
                                                    </div>
                                                </div>

                                                <div class="col-lg-8">
                                                    <div class="rating-breakdown">
                                                        <c:set var="rate" value="5"/>
                                                        <c:forEach begin="0" end="4" var="i">
                                                            <c:set var="r" value="${reviewInfoMap.rates[i]}"/>
                                                            <div class="rating-bar">
                                                                <div class="rating-label">
                                                                    ${rate}점
                                                                </div>
                                                                <div class="progress">
                                                                    <div class="progress-bar" role="progressbar" style="width:${reviewInfoMap.widths[rate.toString()]}%;"
                                                                         aria-valuenow="${r.RATE_COUNT}"
                                                                         aria-valuemin="0" aria-valuemax="${reviewInfoMap.count}"></div>
                                                                </div>
                                                                <div class="rating-count">${r.RATE_COUNT}</div>
                                                            </div>
                                                            <c:set var="rate" value="${rate-1}"/>

                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="reviews-list" id="reviews-list">

                                        </div>

                                        <div class="review-form-container mt-5">
                                            <h4>리뷰 남기기</h4>
                                            <form class="review-form" action="${pageContext.request.contextPath}/course/insertReview" method="post">
                                                <div class="rating-select mb-4">
                                                    <label class="form-label">평점</label>
                                                    <div class="star-rating">
                                                        <input type="radio" id="star5" name="reviewRate" value="5"><label for="star5" title="5 stars"><i class="bi bi-star-fill"></i></label>
                                                        <input type="radio" id="star4" name="reviewRate" value="4"><label for="star4" title="4 stars"><i class="bi bi-star-fill"></i></label>
                                                        <input type="radio" id="star3" name="reviewRate" value="3"><label for="star3" title="3 stars"><i class="bi bi-star-fill"></i></label>
                                                        <input type="radio" id="star2" name="reviewRate" value="2"><label for="star2" title="2 stars"><i class="bi bi-star-fill"></i></label>
                                                        <input type="radio" id="star1" name="reviewRate" value="1"><label for="star1" title="1 star"><i class="bi bi-star-fill"></i></label>
                                                    </div>
                                                </div>

                                                <div class="mb-3">
                                                    <label for="review-title" class="form-label">리뷰 제목</label>
                                                    <input type="text" class="form-control" id="review-title" name="reviewTitle" required="">
                                                </div>

                                                <div class="mb-4">
                                                    <label for="review-content" class="form-label">리뷰 내용</label>
                                                    <textarea class="form-control" id="review-content" name="reviewContent" rows="4" required=""></textarea>
                                                </div>
                                                <div class="text-end">
                                                    <input type="hidden" name="courseSeq" value="${course.courseSeq}">
                                                    <button type="submit" class="btn btn-primary" >작성하기</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>
<script>
    $(document).ready(function () {
        fn_paging(1);
    })

    function fn_paging(page) {
        $.ajax({
            url: '${pageContext.request.contextPath}/course/reviewlistajax?page='+page+'&courseSeq=${course.courseSeq}',
            method: 'GET',
            dataType: 'json',
            success: function (response) {
                let reviews = response['reviews']['reviews'];
                $("#reviews-list").html("");
                reviews.forEach(function (r) {
                    let stars = "";
                    for(let i=1; i<6; i++) {
                        if (i <= r['reviewRate']) {
                            stars += '<i class="bi bi-star-fill"></i>'
                        } else {
                            stars += '<i class="bi bi-star"></i>'
                        }
                    }
                    let review = '<div class="review-item">' +
                        '<div class="review-header">' +
                        '<div class="reviewer-info">' +
                        '<img src="<c:url value="/resources/assets/img/person/undraw_profile.svg"/>" alt="Reviewer" class="reviewer-avatar">' +
                        '<div>' +
                        '<h5 class="reviewer-name">'+r['memberNickname']+'</h5>' +
                        '<div class="review-date">'+formatTimestamp(r['reviewCreateDate'])+'</div>' +
                        '</div>' +
                        '</div>' +
                        '<div class="review-rating">' + stars + '</div>' +
                        '</div>' +
                        '<h5 class="review-title">'+r['reviewTitle']+'</h5>' +
                        '<div class="review-content">' +
                        '<p>'+r['reviewContent']+'</p>' +
                        '</div>' +
                        '</div>';
                        '</div>';
                    $("#reviews-list").append(review);
                });

                $("#reviews-list").append(response['pageBar']);

            },
            error: function (xhr, status, error) {
                console.error("에러:", error);
            }
        });
    }

    function formatTimestamp(ms) {
        const date = new Date(ms);
        const pad = (n) => n.toString().padStart(2, '0');

        const year = date.getFullYear();

        const month = pad(date.getMonth() + 1); // 0-based
        const day = pad(date.getDate());
        const hours = pad(date.getHours());
        const minutes = pad(date.getMinutes());
        const seconds = pad(date.getSeconds());

        return year+"-"+month+"-"+day+" "+hours+":"+minutes+":"+seconds;
    }
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>