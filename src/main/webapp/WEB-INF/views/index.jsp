<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>


<c:set var="dummyImg" value="${pageContext.request.contextPath}/resources/images/dummy.webp"/>
<main class="main">
    <section id="hero" class="hero bg-dark bg-gradient text-white border-top" style="padding-top: 3rem; padding-bottom: 3rem;">
        <div class="swiper init-swiper">
            <div class="swiper-wrapper">

                <!-- 슬라이드 1 -->
                <div class="swiper-slide">
                    <div class="container py-2">
                        <div class="row align-items-center text-center text-lg-start g-3 ">

                            <!-- 텍스트 -->
                            <div class="col-lg-6">
                                <p class="text-uppercase text-light small mb-2">🔥 [선착순]</p>
                                <h2 class="fw-bold display-6 mb-3 text-light">자세 교정, 지금 시작하세요</h2>
                                <p class="text-secondary mb-4">10만 수강생이 선택한 피지컬 갤러리의 어깨 통증 개선 클래스</p>

                                <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                    <span class="fw-bold fs-4 text-white">₩64,500</span>
                                    <span class="text-primary text-decoration-line-through fs-6">₩129,000</span>
                                    <span class="badge bg-primary text-white">50% 할인</span>
                                </div>

                                <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
                                    <span class="btn btn-primary btn-sm">재활</span>
                                    <span class="btn btn-primary btn-sm">자세 교정</span>
                                    <span class="btn btn-primary btn-sm">초급</span>
                                    <span class="btn btn-primary btn-sm">⭐ 4.8 (100+ 수강평)</span>
                                </div>

                                <a href="#" class="btn btn-light btn-lg px-5 py-3 fw-bold text-primary">
                                    <span>00일:01시:49분:50초</span>
                                </a>
                            </div>

                            <!-- 이미지 -->
                            <div class="col-lg-6 d-flex align-items-center justify-content-center">
                                <div class="ratio ratio-16x9 w-100 rounded overflow-hidden shadow-sm">
                                    <img src="${dummyImg}" class="w-100 h-100 object-fit-cover" alt="강의 이미지">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 슬라이드 2: 복사 가능 -->
                <div class="swiper-slide">
                    <div class="container py-2">
                        <div class="row align-items-center text-center text-lg-start g-3 ">

                            <!-- 텍스트 -->
                            <div class="col-lg-6">

                                <p class="text-uppercase text-light small mb-2">🔥 [선착순]</p>
                                <h2 class="fw-bold display-6 mb-3 text-light">이벤트 제목</h2>
                                <p class="text-secondary mb-4">이벤트 설명</p>

                                <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                    <span class="fw-bold fs-4 text-white">₩0,000</span>
                                    <span class="text-primary text-decoration-line-through fs-6">₩0,000</span>
                                    <span class="badge bg-primary text-white">00% 할인</span>
                                </div>

                                <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
                                    <span class="btn btn-primary btn-sm">카테고리</span>
                                    <span class="btn btn-primary btn-sm">난이도</span>
                                    <span class="btn btn-primary btn-sm">⭐ 0.0 (0+ 수강평)</span>
                                </div>

                                <a href="#" class="btn btn-light btn-lg px-5 py-3 fw-bold  text-primary">
                                    <span>00일:00시:00분:00초</span>
                                </a>
                            </div>

                            <!-- 이미지 -->
                            <div class="col-lg-6 d-flex align-items-center justify-content-center">
                                <div class="ratio ratio-16x9 w-100 rounded overflow-hidden shadow-sm">
                                    <img src="${pageContext.request.contextPath}/resources/images/naver.png" class="img-fluid w-100 h-100 object-fit-cover" alt="강의 이미지">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

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
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            new Swiper(".init-swiper", {
                loop: true,
                speed: 600,
                autoplay: {
                    delay: 7000,
                    disableOnInteraction: false
                },
                navigation: {
                    nextEl: ".swiper-button-next",
                    prevEl: ".swiper-button-prev"
                }
            });
        });
    </script>
    <!-- /Hero Section -->
    <!-- 필터 바 -->
    <div class="bg-light px-3 px-lg-5 py-3 border-bottom border-top">
        <div class="container-fluid d-flex flex-wrap align-items-center gap-2">

            <!-- 모든 버튼 -->
            <button class="btn btn-outline-secondary">
                <i class="bi bi-sliders"></i> 모두
            </button>

            <!-- 드롭다운: 온라인/오프라인 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    온라인
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#">전체</a></li>
                    <li><a class="dropdown-item" href="#">온라인</a></li>
                    <li><a class="dropdown-item" href="#">오프라인</a></li>
                </ul>
            </div>

            <!-- 드롭다운: 난이도 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    난이도
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#">전체</a></li>
                    <li><a class="dropdown-item" href="#">초급</a></li>
                    <li><a class="dropdown-item" href="#">중급</a></li>
                    <li><a class="dropdown-item" href="#">고급</a></li>
                </ul>
            </div>

            <!-- 드롭다운: 무료/유료 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    무료
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#">전체</a></li>
                    <li><a class="dropdown-item" href="#">무료</a></li>
                    <li><a class="dropdown-item" href="#">유료</a></li>
                </ul>
            </div>

            <!-- 드롭다운: 별점순 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    별점순
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item" href="#">높은 순</a></li>
                    <li><a class="dropdown-item" href="#">낮은 순</a></li>
                </ul>
            </div>

        </div>
    </div>
    <!-- Best Sellers Section -->
    <section id="best-sellers" class="best-sellers section py-5">
        <div class="container-fluid px-3 px-lg-5">
            <div class="row py-4 g-4" id="courseList">
                <!-- 강의 카드 -->
                <c:if test="${not empty courseList}">
                    <c:forEach var="c" items="${courseList}">
                        <div class="col-12 col-sm-6 col-md-4 col-lg-3">
                            <div class="card h-100 border-0 shadow-sm">
                                <div class="ratio" style="--bs-aspect-ratio: 80%; min-height: 200px;">
                                    <img src="${pageContext.request.contextPath}${c.courseThumbnail}" class="w-100 h-100 object-fit-cover" alt="강의 썸네일">
                                </div>
                                <div class="card-body d-flex flex-column justify-content-between" style="min-height: 240px;">
                                    <div>
                                        <p class="text-muted small mb-1">${c.memberNickname}</p>
                                        <h5 class="card-title fw-semibold text-truncate">${c.courseTitle}</h5>
                                        <p class="card-text text-secondary small text-truncate">${c.courseContent}</p>
                                    </div>
                                    <div class="d-flex flex-wrap align-items-center gap-2 mt-3">
                                        <span class="btn btn-light btn-sm">${c.cateValue}</span>
                                        <span class="btn btn-light btn-sm">${c.courseType=='ON'?'온라인':'오프라인'}</span>
                                        <span class="btn btn-light btn-sm">
                                            <c:forEach begin="1" end="5" var="i">
                                                <c:choose>
                                                    <c:when test="${i <= c.courseDifficult}">
                                                        <span style="color: gold;">★</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color: lightgray;">★</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </span>

                                    </div>
                                    <div class="btn btn-sm btn-primary d-flex align-items-center justify-content-between mt-3">
                                        <div class="text-light">
                                            <i class="bi bi-heart-fill"></i> 4.8 <span class="text-muted"></span>
                                        </div>
                                        <a href="#" class="text-light">수강평 100+</a>
                                    </div>
                                    <div class="d-flex flex-wrap align-items-center mt-3 gap-3 justify-content-end mb-3">
                                        <span class="text-danger text-decoration-line-through fs-6">
                                            ₩ <fmt:formatNumber type="number" maxFractionDigits="3" value="${c.coursePrice}"/>
                                        </span>
                                        <span> ➡️ </span>
                                        <span class="fw-bold fs-6 text-primary">
                                            ₩ <fmt:formatNumber type="number" maxFractionDigits="3" value="${c.coursePrice * ((100-c.courseDiscount)/100)}"/>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </c:forEach>
                </c:if>

            </div>
        </div>
    </section>
    <!-- /Best Sellers Section -->
    <script>
    let page = 1;
    let isLoading = false;
    let hasMore = true;
    $(window).on("scroll", function () {
        if (!hasMore || isLoading) return;

        const scrollTop = $(window).scrollTop();
        const windowHeight = $(window).height();
        const documentHeight = $(document).height();

        if (scrollTop + windowHeight >= documentHeight - 50) {
            isLoading = true;
            page++;

            $.ajax({
                url: "${pageContext.request.contextPath}/main/ajaxLoadMoreData",
                type: "GET",
                data: { page: page },
                success: function (data) {
                    if (data.length === 0) {
                        hasMore = false;
                        $("#courseList").append("<p class='text-center mt-3' style='color: lightgray'>마지막 페이지 입니다.</p>");
                        return;
                    }

                    // 예시 템플릿 렌더링
                    data.forEach(function (course) {
                        let stars="";
                        for(let i=1; i<6; i++){
                            if(i<= course['courseDifficult']) {
                                stars += '<span style="color: gold;">★</span>'
                            } else {
                                stars += '<span style="color: lightgray;">★</span>'
                            }
                        }
                        $("#courseList").append(
                            '<div class="col-12 col-sm-6 col-md-4 col-lg-3">'
                            + '<div class="card h-100 border-0 shadow-sm">'
                            + '    <div class="ratio" style="--bs-aspect-ratio: 80%; min-height: 200px;">'
                            + '        <img src="${pageContext.request.contextPath}' + course['courseThumbnail'] + '" class="w-100 h-100 object-fit-cover" alt="강의 썸네일">'
                            + '    </div>'
                            + '    <div class="card-body d-flex flex-column justify-content-between" style="min-height: 240px;">'
                            + '        <div>'
                            + '            <p class="text-muted small mb-1">' + course['memberNickname'] + '</p>'
                            + '            <h5 class="card-title fw-semibold text-truncate">' + course['courseTitle'] + '</h5>'
                            + '            <p class="card-text text-secondary small text-truncate">' + course['courseContent'] + '</p>'
                            + '        </div>'
                            + '        <div class="d-flex flex-wrap align-items-center gap-2 mt-3">'
                            + '            <span class="btn btn-light btn-sm">' + course['cateValue'] + '</span>'
                            + '            <span class="btn btn-light btn-sm">' + (course['courseType'] === 'ON' ? '온라인' : '오프라인') + '</span>'
                            + '            <span class="btn btn-light btn-sm">'
                            + '               '+stars+''
                            + '            </span>'
                            + '        </div>'
                            + '        <div class="btn btn-sm btn-primary d-flex align-items-center justify-content-between mt-3">'
                            + '            <div class="text-light">'
                            + '                <i class="bi bi-heart-fill"></i> 4.8 <span class="text-muted"></span>'
                            + '            </div>'
                            + '            <a href="#" class="text-light">수강평 100+</a>'
                            + '        </div>'
                            + '        <div class="d-flex flex-wrap align-items-center mt-3 gap-3 justify-content-end mb-3">'
                            + '            <span class="text-danger text-decoration-line-through fs-6">'
                            + '                ₩ ' + course['coursePrice'] + ''
                            + '            </span>'
                            + '            <span> ➡️ </span>'
                            + '            <span class="fw-bold fs-6 text-primary">'
                            + '                ₩ ' + (course['coursePrice'] * ((100 - course['courseDiscount']) / 100)) + ''
                            + '</span>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                        );
                    });
                },
                error: function () {
                    console.error("데이터 불러오기 실패");
                },
                complete: function () {
                    isLoading = false;
                }
            });
        }
    });
    </script>

</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

