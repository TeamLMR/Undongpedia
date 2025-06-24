<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>

<c:set var="path" value="${pageContext.request.contextPath}"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<c:if test="${empty loginMember}">
  <c:set var="linkedPath" value="${path}/login"/>
  <c:set var="nickName" value="Guest"/>
</c:if>
<c:if test="${not empty loginMember}">
  <c:set var="linkedPath" value="${path}/mypage"/>
  <c:set var="nickName" value="${loginMember.memberNickName}"/>
</c:if>
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
      ${nickName} 님
      <button class="btn btn-light" onclick="location.href='${linkedPath}'">
        <i class="bi bi-person"></i>
      </button>
      <button class="btn btn-light" onclick="location.href='${path}/cart'">
        <i class="bi bi-cart3"></i>
      </button>
    </div>
  </div>
</header>

<!-- 카테고리 바 -->
<div id="categoryBar" class="bg-light py-3" style="display: none;">
  <div class="container d-flex flex-wrap justify-content-center gap-4 text-center">
    <c:forEach var="category" items="${categories}">
      <div class="text-center mx-auto opacity-75" onclick="location.assign('${path}/course/list')" style="width: 50px;" >
        <img src="${path}/resources/images/icons/${category.cateIcon}" alt="${category.cateValue}" width="30" height="30" class="mb-2">
        <div class="text-secondary small text-center" style="min-height: 2.5em;">
          <c:forEach var="part" items="${fn:split(category.cateValue, '/')}">
            <div class="lh-1">${part}</div>
          </c:forEach>
        </div>
      </div>
    </c:forEach>
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
