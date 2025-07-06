<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<!-- Fonts -->
<link href="https://fonts.googleapis.com" rel="preconnect">
<link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&family=Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Quicksand:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<c:set var="path" value="${pageContext.request.contextPath}"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<c:if test="${empty loginMember}">
  <c:set var="linkedPath" value="${path}/login"/>
</c:if>
<c:if test="${not empty loginMember}">
  <c:set var="linkedPath" value="${path}/mypage"/>
</c:if>
<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>운동백과 - 세상의 모든 운동을 찾아서</title>
  <meta name="description" content="">
  <meta name="keywords" content="">
  <script src="${path}/resources/assets/vendor/jquery/jquery.min.js"></script>

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
  <div class="container py-3 d-flex align-items-center justify-content-around flex-wrap gap-3">
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
    <form class="d-lg-block flex-grow-1 mx-4" id="searchForm">
      <div class="input-group">
        <input type="text" name="keyword" class="form-control" placeholder="운동을 검색해보세요!">
        <button class="btn btn-primary" type="submit">
          <i class="bi bi-search"></i>
        </button>
      </div>
    </form>
    <!-- 유저/장바구니 -->
    <div class="header-actions d-flex align-items-center gap-3 justify-content-end">
      <c:if test="${empty loginMember}">
        <a href="${linkedPath}">로그인</a>
      </c:if>
      <c:if test="${not empty loginMember}">
        ${loginMember.memberNickname} 님
      </c:if>
      <button class="header-action-btn" onclick="location.href='${linkedPath}'">
        <i class="bi bi-person"></i>
      </button>
      <button class="header-action-btn" onclick="location.href='${path}/cart'">
        <i class="bi bi-cart3"></i>
      </button>
      <c:if test="${not empty loginMember}">
        <div class="dropdown cart-dropdown position-relative" id="notifArea" data-memberno="${loginMember.memberNo}">
          <button class="header-action-btn position-relative" id="notifDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
            <i class="bi bi-bell"></i>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" id="notifBadge" style="display:none;">0</span>
          </button>
          <div class="dropdown-menu cart-dropdown-menu dropdown-menu-end p-0" data-bs-auto-close="outside" aria-labelledby="notifDropdownBtn" style="width: 350px; max-height: 400px; overflow-y: auto;" id="notifMenu">
            <div class="dropdown-header"><h6>알림</h6></div>
            <div class="dropdown-body">
              <div class="cart-items" id="notifList">
                <!-- 빈 알림 메시지는 JS에서 동적으로 삽입 -->
              </div>
            </div>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</header>

<!-- 카테고리 바 -->
<div id="categoryBar" class="bg-light py-3" style="display: none;">
  <div class="container d-flex flex-wrap justify-content-center gap-4 text-center">
    <c:forEach var="category" items="${categories}">
      <div class="text-center mx-auto opacity-75 category-item" 
           data-category-seq="${category.cateSeq}" 
           data-category-name="${category.cateValue}"
           style="width: 50px; cursor: pointer;" >
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
  $(document).ready(function() {
    // 기존 카테고리 토글 코드
    $("#toggleCategoryBtn").click(function() {
      const categoryBar = $("#categoryBar");
      const icon = $(this).find("i");
      const isVisible = categoryBar.is(":visible");
      
      if (isVisible) {
        categoryBar.hide();
        icon.removeClass("bi-chevron-up").addClass("bi-chevron-down");
      } else {
        categoryBar.show();
        icon.removeClass("bi-chevron-down").addClass("bi-chevron-up");
      }
    });
    
    // 카테고리 클릭 이벤트
    $(document).on('click', '.category-item', function() {
      const categorySeq = $(this).data('category-seq');
      const categoryName = $(this).data('category-name');
      
      // 카테고리 바 숨기기
      $("#categoryBar").hide();
      $("#toggleCategoryBtn i").removeClass("bi-chevron-up").addClass("bi-chevron-down");
      
      // 메인 페이지로 이동하면서 카테고리 검색
      window.location.href = '${pageContext.request.contextPath}/?category=' + categorySeq + '&categoryName=' + encodeURIComponent(categoryName);
    });
    
    // 검색 폼 처리 - 메인 페이지로 리다이렉트
    $("#searchForm").submit(function(e) {
      e.preventDefault(); // 기본 form 제출 방지
      
      const keyword = $(this).find('input[name="keyword"]').val().trim();
      if (!keyword) {
        alert('검색어를 입력해주세요!');
        return;
      }
      
      // 무조건 메인 페이지로 이동하면서 검색어 전달
      window.location.href = '${pageContext.request.contextPath}/?search=' + encodeURIComponent(keyword);
    });

    // ────────── 알림 WebSocket & REST 초기화 ──────────
    const memberNo = document.getElementById('notifArea')?.dataset.memberno || "";
    if(memberNo){
      const contextPath = '${pageContext.request.contextPath}';
      let notifWs;
      const wsScheme = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
      function connectNotifWS(){
        notifWs = new WebSocket(wsScheme + window.location.host + contextPath + '/ws/notification?memberNo=' + memberNo);
        notifWs.onmessage = function(e){ handleNotif(JSON.parse(e.data)); };
        notifWs.onclose = function(){ setTimeout(connectNotifWS, 5000); };
      }
      function handleNotif(msg){
        switch(msg.type){
          case 'bootstrap':
            updateBadge(msg.unreadCount);
            renderList(msg.notifications);
            break;
          case 'notification':
            addItem(msg.data);
            updateBadge(parseInt($('#notifBadge').text()||'0')+1);
            break;
          case 'unread_count':
            updateBadge(msg.unreadCount);
            break;
        }
      }
      function updateBadge(count){
        if(count>0){
          $('#notifBadge').text(count).show();
        } else {
          $('#notifBadge').hide();
        }
      }
      function addItem(n){
        $('#notifEmpty').remove();
        const itemHtml = '<div class="cart-item dynamic d-flex justify-content-between align-items-start">'
          + '<div class="cart-item-content flex-grow-1 me-2">'
          +   '<a href="' + n.notificationLink + '" class="text-decoration-none d-block notif-link" data-id="' + n.notificationId + '">' 
          +     '<h6 class="cart-item-title mb-0">' + n.notificationTitle + '</h6>'
          +     '<div class="cart-item-meta small text-muted">' + (n.notificationContent ?? '') + '</div>'
          +   '</a>'
          + '</div>'
          + '<span class="cart-item-remove notif-close text-secondary" style="cursor:pointer;" data-id="' + n.notificationId + '" title="닫기">&times;</span>'
          + '</div>';
        $('#notifList').append(itemHtml);
      }
      function renderList(list){
        $('#notifList .dynamic').remove();
        $('#notifEmpty').remove();
        const unread = list.filter(n=> n.isRead === 'N' || n.isRead===undefined);
        if(unread.length===0){
          $('#notifList').append('<div class="text-center py-2 text-muted" id="notifEmpty">알림이 없습니다</div>');
        } else {
          unread.forEach(addItem);
        }
      }
      // REST 부트스트랩 (새로고침 시 대비)
      $.get(contextPath + '/notification', {memberNo: memberNo, cPage:1, numPerPage:10}, function(res){
        updateBadge(res.unreadCount);
        renderList(res.notifications);
      });
      // 주기적 폴백 30초
      setInterval(function(){
        if(!notifWs || notifWs.readyState!==1){
          $.get(contextPath + '/notification/unread-count', {memberNo: memberNo}, function(cnt){ updateBadge(cnt); });
        }
      }, 30000);
      // 알림 클릭 시 읽음 처리
      $(document).on('click', '#notifList .notif-link', function(e){
        const id = $(this).data('id');
        $.ajax({url: contextPath + '/notification/' + id + '/read', type: 'PUT'});
        const cur = parseInt($('#notifBadge').text()||'0')-1;
        updateBadge(Math.max(0, cur));
      });
      // X 버튼 클릭 시 읽음 처리 후 삭제
      $(document).on('click', '#notifList .notif-close', function(e){
        e.preventDefault();
        e.stopPropagation();
        const id = $(this).data('id');
        const $item = $(this).closest('.cart-item');
        $.ajax({url: contextPath + '/notification/' + id + '/read', type: 'PUT'});
        $item.remove();
        const cur = parseInt($('#notifBadge').text()||'0')-1;
        updateBadge(Math.max(0, cur));
        if($('#notifList .dynamic').length===0){
          $('#notifList').append('<div class="text-center py-2 text-muted" id="notifEmpty">알림이 없습니다</div>');
        }
      });
      connectNotifWS();
    }
  });
</script>

<style>
  /* 간단한 헤더 아이콘 커스텀 (템플릿 스타일 추출) */
  header .header-actions {
    gap: 16px;
  }
  header .header-actions .header-action-btn {
    background: none;
    border: none;
    padding: 0.5rem;
    color: var(--default-color);
    font-size: 15px;
    cursor: pointer;
    display: flex;
    align-items: center;
    transition: color 0.3s ease;
  }
  header .header-actions .header-action-btn i {
    font-size: 24px;
  }
  header .header-actions .header-action-btn:hover {
    color: var(--accent-color);
  }

  /* 알림 드롭다운 내부 아이템 크기/폰트 축소 */
  header #notifMenu .cart-item {
    padding: 0.4rem 0.75rem;
  }
  header #notifMenu .cart-item .cart-item-title {
    font-size: 14px;
  }
  header #notifMenu .cart-item .cart-item-meta {
    font-size: 12px;
    margin-top: 2px;
    color: color-mix(in srgb, var(--default-color), transparent 40%);
  }
  header #notifMenu .cart-item + .cart-item {
    border-top: 1px solid color-mix(in srgb, var(--default-color), transparent 90%);
  }
  header #notifMenu .notif-close {
    font-size: 14px;
  }
</style>

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


