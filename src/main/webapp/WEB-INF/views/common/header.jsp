<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>

<c:set var="path" value="${pageContext.request.contextPath}"/>
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
</head>

<body class="index-page">

<!-- Header -->
<header class="border-bottom bg-white">
  <div class="container py-3 d-flex align-items-center justify-content-between flex-wrap gap-3">

    <!-- 로고 -->
    <a href="${path}" class="d-flex align-items-center gap-2 text-decoration-none">
      <img src="${path}/resources/assets/img/icon-192x192.png" alt="운동백과" width="32" height="32">
      <span class="fw-bold text-secondary fs-4">운동백과</span>
    </a>

    <!-- 네비게이션 -->
    <nav class="d-flex align-items-center gap-4 mx-3 flex-wrap">
      <a href="javascript:void(0);" class="fw-semibold text-secondary text-decoration-none d-flex align-items-center gap-1" id="toggleCategoryBtn">
        <span>카테고리</span>
        <i class="bi bi-chevron-down"></i>
      </a>
    </nav>

    <!-- 검색 -->
    <form class="d-lg-block flex-grow-1 mx-4 ">
      <div class="input-group">
        <input type="text" class="form-control" placeholder="운동을 검색해보세요!">
        <button class="btn btn-primary" type="submit">
          <i class="bi bi-search"></i>
        </button>
      </div>
    </form>

    <!-- 유저/장바구니 -->
    <div class="d-flex align-items-center gap-3">
      <div class="dropdown">
        <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="dropdown">
          <%--TODO: 로그인 회원 분기처리--%>
          <i class="bi bi-person me-1"> OOO 님 or Guest </i>
        </button>
        <div class="dropdown-menu p-3 ">
          <%--TODO: 로그인 회원 분기처리
              1. 로그인한 회원이면 바로 마이페이지로 가게
              2. 로그인 안했으면 로그인창으로
              작업 완료되면 아래 지워버릴것임못생겻어요..
          --%>
            <p>(임시) 이 토글 창은 사라집니다.</p>
            <a href="${path}/coach/dashboard" class="btn btn-secondary w-100 mb-3">코치</a>
            <a href="${path}/mypage" class="btn btn-secondary w-100 mb-3">마이페이지</a>
            <a href="${path}/login" class="btn btn-secondary w-100 mb-3">로그인</a>
            <a href="${path}/signup" class="btn btn-secondary w-100 ">회원가입</a>
        </div>
      </div>
      <button class="btn btn-sm btn-outline-secondary" onclick="location.href='${path}/cart'">
        <i class="bi bi-cart3"></i>
      </button>
    </div>
  </div>
</header>

<!-- 카테고리 바 -->
<div id="categoryBar" class="bg-light border-top py-3" style="display: none;">
  <div class="container d-flex flex-wrap justify-content-start gap-4 text-center">
    <div class="text-center" onclick="location.assign('${path}/course/list')" style="width: 72px;">
      <img src="" alt="" width="36" height="36" class="mb-1">
      <div class="small">Dummy</div>
    </div>
    <div class="text-center" onclick="location.assign('${path}/course/list')" style="width: 72px;">
      <img src="" alt="" width="36" height="36" class="mb-1">
      <div class="small">Dummy</div>
    </div>
    <div class="text-center" onclick="location.assign('${path}/course/list')" style="width: 72px;">
      <img src="" alt="" width="36" height="36" class="mb-1">
      <div class="small">Dummy</div>
    </div>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    const toggleBtn = document.getElementById("toggleCategoryBtn");
    const categoryBar = document.getElementById("categoryBar");
    const icon = toggleBtn.querySelector("i");

    toggleBtn.addEventListener("click", function () {
      const isVisible = categoryBar.style.display === "block";
      categoryBar.style.display = isVisible ? "none" : "block";
      icon.classList.toggle("bi-chevron-down", isVisible);
      icon.classList.toggle("bi-chevron-up", !isVisible);
    });
  });
</script>

<%--TODO: --%>
<%--    <c:if test="${not empty category}">--%>
<%--      <div id="categoryBar" class="bg-white border-bottom py-3" style="display: none;">--%>
<%--        <div class="container d-flex flex-wrap justify-content-start gap-4 text-center">--%>
<%--          <c:forEach var="detail" items="${category}">--%>
<%--            <div class="text-center" style="width: 72px;">--%>
<%--              <img src="${path}/resources/icons/${detail.cateKey}" alt="${detail.cateValue}" width="36" height="36" class="mb-1">--%>
<%--              <div class="small">${detail.cateValue}</div>--%>
<%--            </div>--%>
<%--          </c:forEach>--%>
<%--        </div>--%>
<%--      </div>--%>
<%--    </c:if>--%>

<%--TODO: 이건 따로 광고할 거 있을때 광고 테이블 데이터 좍 돌려주면 될것같은데..--%>
<%--  <div class="announcement-bar py-2">--%>
<%--    <div class="container-fluid container-xl">--%>
<%--      <div class="announcement-slider swiper init-swiper">--%>
<%--        <script type="application/json" class="swiper-config">--%>
<%--          {--%>
<%--            "loop": true,--%>
<%--            "speed": 600,--%>
<%--            "autoplay": {--%>
<%--              "delay": 5000--%>
<%--            },--%>
<%--            "slidesPerView": 1,--%>
<%--            "effect": "slide",--%>
<%--            "direction": "vertical"--%>
<%--          }--%>
<%--        </script>--%>
<%--        <div class="swiper-wrapper">--%>
<%--          &lt;%&ndash;TODO: swiper-slide 스크립트 분리&ndash;%&gt;--%>
<%--          <div class="swiper-slide">[충격]스타강사 OOO의 오프라인 강의 신청이 00:08:40:00 남았습니다.</div>--%>
<%--        </div>--%>
<%--      </div>--%>
<%--    </div>--%>
<%--  </div>--%>
