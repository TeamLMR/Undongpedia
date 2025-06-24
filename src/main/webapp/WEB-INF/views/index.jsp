<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="dummyImg" value="${pageContext.request.contextPath}/resources/images/dummy.webp"/>
<main class="main">
    <!-- Hero Section -->
    <section class="hero section bg-white py-5 border-top" id="hero">
        <div class="container-fluid">
            <div class="swiper ecommerce-hero-slider init-swiper px-3 px-lg-5">
                <script type="application/json" class="swiper-config">
                    {
                        "loop": true,
                        "speed": 600,
                        "autoplay": { "delay": 7000 },
                        "navigation": {
                            "nextEl": ".swiper-button-next",
                            "prevEl": ".swiper-button-prev"
                        }
                    }
                </script>

                <div class="swiper-wrapper">
                    <div class="row align-items-center flex-column flex-lg-row text-center text-lg-start px-3 px-lg-5 py-4 g-4">
                        <!-- 텍스트 -->
                        <div class="col-lg-6">

                            <!-- 배지 -->
                            <p class="text-uppercase text-muted mb-2">🔥 [선착순]</p>

                            <!-- 타이틀 -->
                            <h2 class="fw-bold display-6 mb-3">자세 교정, 지금 시작하세요</h2>

                            <!-- 설명 -->
                            <p class="text-secondary mb-4">10만 수강생이 선택한 피지컬 갤러리의 어깨 통증 개선 클래스</p>

                            <!-- 가격 -->
                            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                <span class="fw-bold fs-4 text-primary">₩64,500</span>
                                <span class="text-muted text-decoration-line-through fs-6">₩129,000</span>
                                <span class="badge bg-primary text-white">50% 할인</span>
                            </div>

                            <!-- 카테고리 & 수강평 -->
                            <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
                                <span class="btn btn-outline-primary btn-sm">재활</span>
                                <span class="btn btn-outline-primary btn-sm">자세 교정</span>
                                <span class="btn btn-outline-primary btn-sm">초급</span>
                                <span class="btn btn-outline-primary btn-sm">⭐ 4.8 (100+ 수강평)</span>
                            </div>

                            <!-- CTA 버튼 -->
                            <a href="#" class="btn btn-primary btn-lg px-5 py-3 fw-bold w-100 w-md-auto">
                                카운트 다운 <span>00일:01시:49분:50초</span>
                            </a>

                        </div>

                        <div class="col-lg-6">
                                <img src="${dummyImg}" class="img-fluid rounded shadow-sm" alt="강의 이미지">
                        </div>

                    </div>

                </div>

                <!-- 눈에 안 보이지만 작동하는 버튼 -->
                <div class="swiper-button-prev"></div>
                <div class="swiper-button-next"></div>
            </div>
        </div>
    </section>
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
            <div class="row px-3 px-lg-5 py-4 g-4">
                <!-- 강의 카드 -->
                <div class="col-12 col-sm-6 col-lg-3">
                    <div class="card h-100 border-0 shadow-sm">

                        <!-- 썸네일 -->
                        <div class="ratio ratio-4x3 overflow-hidden" style="min-height: 180px;">
                            <img src="${dummyImg}" class="img-fluid object-fit-cover w-100 h-100" alt="강의 썸네일">
                        </div>

                        <!-- 내용 -->
                        <div class="card-body d-flex flex-column justify-content-between" style="min-height: 220px;">
                            <div>
                                <p class="text-muted small mb-1">피지컬 갤러리</p>
                                <h5 class="card-title fw-semibold text-truncate">자세 교정, 지금 시작하세요</h5>
                                <p class="card-text text-secondary small text-truncate">통증 없이 생활하는 법, 재활 전문가와 함께하는 클래스</p>
                            </div>
                            <div class="d-flex flex-wrap align-items-center gap-2 mt-3">
                                <span class="btn btn-light btn-sm">재활</span>
                                <span class="btn btn-light btn-sm">자세 교정</span>
                                <span class="btn btn-light btn-sm">초급</span>

                            </div>
                            <div class="btn btn-sm btn-primary d-flex align-items-center justify-content-between mt-3">
                                <div class="text-light">
                                    <i class="bi bi-heart-fill"></i> 4.8 <span class="text-muted"></span>
                                </div>
                                <a href="#" class="text-light">수강평 100+</a>
                            </div>
                            <div class="d-flex flex-wrap align-items-center mt-3 gap-3 justify-content-end mb-3">
                                <span class="text-danger text-decoration-line-through fs-6">₩129,000</span>
                                <span> ➡️ </span>
                                <span class="fw-bold fs-6 text-primary">₩64,500</span>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </section>
    <!-- /Best Sellers Section -->
    <style>
        .swiper-button-prev,
        .swiper-button-next {
            opacity: 0;
        }
    </style>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

