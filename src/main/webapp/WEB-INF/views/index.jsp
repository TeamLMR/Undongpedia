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
                <c:choose>
                    <c:when test="${not empty eventCourses}">
                        <!-- 실제 이벤트 강의 데이터 -->
                        <c:forEach var="event" items="${eventCourses}">
                            <div class="swiper-slide">
                                <div class="container py-2">
                                    <div class="row align-items-center text-center text-lg-start g-3">
                                        <!-- 텍스트 -->
                                        <div class="col-lg-6">
                                            <p class="text-uppercase text-light small mb-2">🔥 [선착순 EVENT]</p>
                                            <h2 class="fw-bold display-6 mb-3 text-light">${event.courseTitle}</h2>
                                            <p class="text-secondary mb-4">${event.courseContent}</p>

                                            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                                <span class="fw-bold fs-4 text-white">₩<fmt:formatNumber type="number" maxFractionDigits="3" value="${event.discountedPrice}"/></span>
                                                <c:if test="${event.courseDiscount > 0}">
                                                    <span class="text-primary text-decoration-line-through fs-6">₩<fmt:formatNumber type="number" maxFractionDigits="3" value="${event.coursePrice}"/></span>
                                                    <span class="badge bg-primary text-white">${event.courseDiscount}% 할인</span>
                                                </c:if>
                                            </div>

                                            <div class="d-flex flex-wrap align-items-center gap-2 mb-4">
                                                <span class="btn btn-primary btn-sm">${event.cateValue}</span>
                                                <span class="btn btn-primary btn-sm">
                                                    <c:choose>
                                                        <c:when test="${event.courseDifficult == 1}">초급</c:when>
                                                        <c:when test="${event.courseDifficult == 2}">중급</c:when>
                                                        <c:when test="${event.courseDifficult == 3}">고급</c:when>
                                                        <c:otherwise>난이도 ${event.courseDifficult}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <span class="btn btn-primary btn-sm">최대 ${event.maxConcurrentUsers}명</span>
                                            </div>

                                            <button type="button" 
                                               class="btn btn-light btn-lg px-5 py-3 fw-bold text-primary event-btn"
                                               data-course-seq="${event.courseSeq}"
                                               data-open-time="${event.openDateTime.time}"
                                               onclick="handleEventButtonClick(this)">
                                                <span class="countdown-timer" data-open-time="${event.openDateTime.time}">
                                                    오픈까지 계산중...
                                                </span>
                                            </button>
                                        </div>

                                        <!-- 이미지 -->
                                        <div class="col-lg-6 d-flex align-items-center justify-content-center">
                                            <div class="ratio ratio-16x9 w-100 rounded overflow-hidden shadow-sm">
                                                <img src="${pageContext.request.contextPath}${event.courseThumbnail != null ? event.courseThumbnail : '/resources/images/dummy.webp'}" 
                                                     class="w-100 h-100 object-fit-cover" alt="${event.courseTitle}">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <!-- 기본 더미 슬라이드 (이벤트가 없을 때) -->
                        <div class="swiper-slide">
                            <div class="container py-2">
                                <div class="row align-items-center text-center text-lg-start g-3">
                                    <div class="col-lg-6">
                                        <p class="text-uppercase text-light small mb-2">🎯 곧 만나요!</p>
                                        <h2 class="fw-bold display-6 mb-3 text-light">특별한 이벤트를 준비 중입니다</h2>
                                        <p class="text-secondary mb-4">더 나은 강의와 혜택으로 찾아뵙겠습니다</p>
                                        <a href="${pageContext.request.contextPath}/course/list" class="btn btn-light btn-lg px-5 py-3 fw-bold text-primary">
                                            전체 강의 보기
                                        </a>
                                    </div>
                                    <div class="col-lg-6 d-flex align-items-center justify-content-center">
                                        <div class="ratio ratio-16x9 w-100 rounded overflow-hidden shadow-sm">
                                            <img src="${dummyImg}" class="w-100 h-100 object-fit-cover" alt="준비중">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
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
            // Swiper 초기화
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
            
            // 카운트다운 타이머 초기화
            initCountdownTimers();
        });
        
        function initCountdownTimers() {
            const timers = document.querySelectorAll('.countdown-timer');
            
            timers.forEach(timer => {
                const openTime = parseInt(timer.getAttribute('data-open-time'));
                if (openTime) {
                    updateCountdown(timer, openTime);
                    // 1초마다 업데이트
                    setInterval(() => updateCountdown(timer, openTime), 1000);
                }
            });
        }
        
        function updateCountdown(element, openTime) {
            const now = new Date().getTime();
            const distance = openTime - now;
            
            if (distance < 0) {
                element.innerHTML = "예약하러 가기";
                element.parentElement.classList.remove('btn-light');
                element.parentElement.classList.add('btn-light');
                element.parentElement.setAttribute('data-is-open', 'true');
                return;
            }
            
            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            element.innerHTML = `⏰ \${days}일 \${hours.toString().padStart(2, '0')}:\${minutes.toString().padStart(2, '0')}:\${seconds.toString().padStart(2, '0')}`;
            element.parentElement.setAttribute('data-is-open', 'false');
        }
        
        // 이벤트 버튼 클릭 핸들러
        function handleEventButtonClick(button) {
            const openTime = parseInt(button.getAttribute('data-open-time'));
            const courseSeq = button.getAttribute('data-course-seq');
            const now = new Date().getTime();
            const isOpen = button.getAttribute('data-is-open') === 'true';
            
            if (isOpen || (openTime && openTime <= now)) {
                // 오픈된 경우 -> 예약 페이지로 이동
                window.location.href = contextPath + '/reservation/queue/' + courseSeq;
            } else {
                // 오픈 전인 경우 -> 모달 띄우기
                showPreOpenModal(openTime);
            }
        }
        
        // 오픈 전 모달 표시
        function showPreOpenModal(openTime) {
            const now = new Date().getTime();
            const distance = openTime - now;
            
            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            const timeText = days + '일 ' + hours.toString().padStart(2, '0') + ':' + minutes.toString().padStart(2, '0') + ':' + seconds.toString().padStart(2, '0');
            
            document.getElementById('preOpenTimeText').textContent = timeText;
            const modal = new bootstrap.Modal(document.getElementById('preOpenModal'));
            modal.show();
        }
        
        // contextPath 설정
        const contextPath = '${pageContext.request.contextPath}';
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

<!-- 이벤트 오픈 전 모달 -->
<div class="modal fade" id="preOpenModal" tabindex="-1" aria-labelledby="preOpenModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="preOpenModalLabel">
                    <i class="bi bi-clock-fill me-2"></i>이벤트 오픈 전입니다
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center py-4">
                <div class="mb-4">
                    <i class="bi bi-hourglass-split display-1 text-primary"></i>
                </div>
                <h4 class="fw-bold mb-3">아직이지롱~</h4>
                <p class="text-muted mb-4">선착순 이벤트가 아직 시작되지 않았습니다.<br>조금만 더 기다려주세요!</p>
                
                <div class="alert alert-info d-flex align-items-center justify-content-center">
                    <i class="bi bi-info-circle-fill me-2"></i>
                    <strong>오픈까지 남은 시간: <span id="preOpenTimeText" class="text-primary"></span></strong>
                </div>
                
                <p class="small text-muted">
                    ⏰ 정확한 시간에 자동으로 오픈됩니다<br>
                    📱 페이지를 새로고침하지 마시고 기다려주세요
                </p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-outline-primary" data-bs-dismiss="modal">
                    <i class="bi bi-check-circle me-1"></i>확인
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

