<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">

<c:set var="path" value="${pageContext.request.contextPath}"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>운동백과 - 세상의 모든 운동을 찾아서</title>
  <meta name="description" content="">
  <meta name="keywords" content="">

  <!-- Favicons -->
  <link href="${path}/resources/assets/img/favicon.png" rel="icon">
  <link href="${path}/resources/assets/img/apple-touch-icon.png" rel="apple-touch-icon">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com" rel="preconnect">
  <link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Quicksand:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Vendor CSS Files -->
  <link href="${path}/resources/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="${path}/resources/assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
  <link href="${path}/resources/assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">
  <link href="${path}/resources/assets/vendor/aos/aos.css" rel="stylesheet">
  <link href="${path}/resources/assets/vendor/glightbox/css/glightbox.min.css" rel="stylesheet">
  <link href="${path}/resources/assets/vendor/drift-zoom/drift-basic.css" rel="stylesheet">

  <!-- Main CSS File -->
  <link href="${path}/resources/assets/css/main.css" rel="stylesheet">

  <!-- =======================================================
  * Template Name: FashionStore
  * Template URL: https://bootstrapmade.com/fashion-store-bootstrap-template/
  * Updated: Apr 26 2025 with Bootstrap v5.3.5
  * Author: BootstrapMade.com
  * License: https://bootstrapmade.com/license/
  ======================================================== -->
</head>

<body class="index-page">

<header id="header" class="header position-relative">

  <!-- Main Header -->
  <div class="main-header">
    <div class="container-fluid container-xl">
      <div class="d-flex py-3 align-items-center justify-content-between">

        <!-- Logo -->
        <a href="${path}" class="logo d-flex align-items-center">
          <!-- Uncomment the line below if you also wish to use an image logo -->
          <img src="${path}/resources/assets/img/icon-192x192.png" alt="">
          <h1 class="sitename"><span>운동백과</span></h1>
        </a>

        <!-- Search -->
        <form class="search-form desktop-search-form">
          <div class="input-group">
            <input type="text" class="form-control" placeholder="Search for products...">
            <button class="btn search-btn" type="submit">
              <i class="bi bi-search"></i>
            </button>
          </div>
        </form>

        <!-- Actions -->
        <div class="header-actions d-flex align-items-center justify-content-end">

          <!-- Mobile Search Toggle -->
          <button class="header-action-btn mobile-search-toggle d-xl-none" type="button" data-bs-toggle="collapse" data-bs-target="#mobileSearch" aria-expanded="false" aria-controls="mobileSearch">
            <i class="bi bi-search"></i>
          </button>

          <!-- Account -->
          <div class="dropdown account-dropdown">
            <button class="header-action-btn" data-bs-toggle="dropdown">
              <i class="bi bi-person"></i>
              <span class="action-text d-none d-md-inline-block">Account</span>
            </button>
            <div class="dropdown-menu">
              <div class="dropdown-body">
                <a class="dropdown-item d-flex align-items-center" href="${path}/mypage">
                  <i class="bi bi-person-circle me-2"></i>
                  <span>마이페이지</span>
                </a>
              </div>
              <c:if test="${empty loginMember}">
              <div class="dropdown-footer">
                <a href="${path}/login" class="btn btn-primary w-100 mb-2">로그인</a>
                <a href="${path}/signup" class="btn btn-outline-primary w-100">회원가입</a>
              </div>
              </c:if>
            </div>
          </div>

          <!-- Cart -->
          <div class="dropdown cart-dropdown">
            <button class="header-action-btn" data-bs-toggle="dropdown" onclick="location.href='${path}/cart'">
              <i class="bi bi-cart3"></i>
              <span class="action-text d-none d-md-inline-block">Cart</span>
              <span class="badge">0</span>
            </button>
          <!-- Mobile Navigation Toggle -->
          <i class="mobile-nav-toggle d-xl-none bi bi-list me-0"></i>
        </div>
      </div>
    </div>
  </div>

  <!-- Navigation -->
  <div class="header-nav">
    <div class="container-fluid container-xl position-relative">
      <nav id="navmenu" class="navmenu">
        <ul>
          <li><a href="${path}" class="active">클래스</a></li>
          <li class="products-megamenu-1"><a href="#"><span>카테고리</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
            <ul class="mobile-megamenu">
              <li class="dropdown"><a href="#"><span>카테고리</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
                <ul>
                  <li><a href="#">운동들</a></li>
                </ul>
              </li>
            </ul>
            <div class="desktop-megamenu">
              <div class="megamenu-content tab-content">
                <div class="tab-pane fade show active" id="featured-content-1862" role="tabpanel" aria-labelledby="category-tab">
                  <div class="product-grid">

                    <%--TODO: 포스트 카드 스크립트로 분리--%>
                    <div class="product-card" onclick="location.href='${path}/course/list'">
                      <div class="product-image">
                        <img src="${path}/resources/assets/img/icon-192x192.png" alt="Category" loading="lazy">
                      </div>
                      <div class="product-info">
                        <h5>운동</h5>
                        <p class="price">근육근육</p>
                      </div>
                    </div>

                  </div>
                </div>
              </div>

            </div>
          </li>
        </ul>
      </nav>
    </div>
  </div>

  <div class="announcement-bar py-2">
    <div class="container-fluid container-xl">
      <div class="announcement-slider swiper init-swiper">
        <script type="application/json" class="swiper-config">
          {
            "loop": true,
            "speed": 600,
            "autoplay": {
              "delay": 5000
            },
            "slidesPerView": 1,
            "effect": "slide",
            "direction": "vertical"
          }
        </script>
        <div class="swiper-wrapper">
          <%--TODO: swiper-slide 스크립트 분리--%>
          <div class="swiper-slide">[충격]스타강사 OOO의 오프라인 강의 신청이 00:08:40:00 남았습니다.</div>
        </div>
      </div>
    </div>
  </div>

  <!-- Mobile Search Form -->
  <div class="collapse" id="mobileSearch">
    <div class="container">
      <form class="search-form">
        <div class="input-group">
          <input type="text" class="form-control" placeholder="Search for products...">
          <button class="btn search-btn" type="submit">
            <i class="bi bi-search"></i>
          </button>
        </div>
      </form>
    </div>
  </div>

</header>
