<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/swiper@9/swiper-bundle.min.js"></script>

<script>
    // 이미지가 없는 경우를 체크하기 위해 해당 이미지의 URL을 변수에 저장
    const defaultImageUrl = "${pageContext.request.contextPath}/resources/images/dummy.png";

    // 이미지가 있는지 체크하는 함수
    function checkImageExists(imageUrl) {
        // 새로운 이미지 객체 생성
        const img = new Image();
        // 이미지 URL 설정
        img.src = '${pageContext.request.contextPath}' + imageUrl;

        // 이미지 로드가 성공한 경우
        img.onload = function () {
            // 이미지가 존재하는 경우 true를 반환
            return true;
        };
        // 이미지 로드가 실패한 경우
        img.onerror = function () {
            // 이미지가 존재하지 않는 경우 false를 반환
            return false;
        };
        console.log(img.src);
        // 이미지가 존재하는지 여부를 반환
        return img.complete;
    }

    // 이미지가 없는 경우 defaultImageUrl을 반환하는 함수
    function getImageUrl(imageUrl) {
        console.log("imageUrl: " + imageUrl)
        // 이미지가 존재하는 경우 해당 URL을 반환
        if (checkImageExists(imageUrl)) {
            return imageUrl;
        }
        // 이미지가 존재하지 않는 경우 defaultImageUrl을 반환
        return defaultImageUrl;
    }
</script>

<c:set var="dummyImg" value="${pageContext.request.contextPath}/resources/images/dummy.webp"/>
<main class="main">
    <section id="hero" class="hero bg-dark bg-gradient text-white border-top"
             style="padding-top: 3rem; padding-bottom: 3rem;">
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
                                            <p class="text-uppercase text-light small mb-2"> [선착순 EVENT]</p>
                                            <h2 class="fw-bold display-6 mb-3 text-light">${event.courseTitle}</h2>
                                            <p class="text-secondary mb-4">${event.courseContent}</p>

                                            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                                <span class="fw-bold fs-4 text-white">₩<fmt:formatNumber type="number"
                                                                                                         maxFractionDigits="3"
                                                                                                         value="${event.discountedPrice}"/></span>
                                                <c:if test="${event.courseDiscount > 0}">
                                                    <span class="text-primary text-decoration-line-through fs-6">₩<fmt:formatNumber
                                                            type="number" maxFractionDigits="3"
                                                            value="${event.coursePrice}"/></span>
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
                                                <span class="countdown-timer"
                                                      data-open-time="${event.openDateTime.time}">
                                                    오픈까지 계산중...
                                                </span>
                                            </button>
                                        </div>

                                        <!-- 이미지 -->
                                        <div class="col-lg-6 d-flex align-items-center justify-content-center">
                                            <div class="ratio ratio-16x9 w-100 rounded overflow-hidden shadow-sm">
                                                <img src="${pageContext.request.contextPath}${event.courseThumbnail != null ? event.courseThumbnail : '/resources/images/dummy.png'}"
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
                                        <a href="${pageContext.request.contextPath}/course/list"
                                           class="btn btn-light btn-lg px-5 py-3 fw-bold text-primary">
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
            
            <!-- 검색어 표시 -->
            <div id="searchKeywordDisplay" class="d-none">
                <span class="badge bg-primary fs-6 px-3 py-2">
                    <i class="bi bi-search me-1"></i>
                    "<span id="currentSearchKeyword"></span>"
                    <button type="button" class="btn-close btn-close-white ms-2" onclick="resetSearch()" aria-label="검색 취소"></button>
                </span>
            </div>

            <!-- 드롭다운: 온라인/오프라인 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    온라인
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item course-type-filter" data-type="all" href="#">전체</a></li>
                    <li><a class="dropdown-item course-type-filter" data-type="ON" href="#">온라인</a></li>
                    <li><a class="dropdown-item course-type-filter" data-type="OFF" href="#">오프라인</a></li>
                </ul>
            </div>

            <!-- 드롭다운: 난이도 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    난이도
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item difficulty-filter" data-difficulty="all" href="#">전체</a></li>
                    <li><a class="dropdown-item difficulty-filter" data-difficulty="1" href="#">⭐️ </a></li>
                    <li><a class="dropdown-item difficulty-filter" data-difficulty="2" href="#">⭐️⭐️</a></li>
                    <li><a class="dropdown-item difficulty-filter" data-difficulty="3" href="#">⭐️⭐️⭐️</a></li>
                    <li><a class="dropdown-item difficulty-filter" data-difficulty="4" href="#">⭐️⭐️⭐️⭐️</a></li>
                    <li><a class="dropdown-item difficulty-filter" data-difficulty="5" href="#">⭐️⭐️⭐️⭐️⭐️</a></li>
                </ul>
            </div>

            <!-- 드롭다운: 무료/유료 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    무료
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item price-filter" data-price="all" href="#">전체</a></li>
                    <li><a class="dropdown-item price-filter" data-price="free" href="#">무료</a></li>
                    <li><a class="dropdown-item price-filter" data-price="paid" href="#">유료</a></li>
                </ul>
            </div>

            <!-- 드롭다운: 정렬 -->
            <div class="dropdown">
                <button class="btn btn-outline-secondary dropdown-toggle" data-bs-toggle="dropdown">
                    최신순
                </button>
                <ul class="dropdown-menu">
                    <li><a class="dropdown-item sort-filter" data-sort="latest" href="#">최신순</a></li>
                    <li><a class="dropdown-item sort-filter" data-sort="price_asc" href="#">가격 낮은순</a></li>
                    <li><a class="dropdown-item sort-filter" data-sort="price_desc" href="#">가격 높은순</a></li>
                    <li><a class="dropdown-item sort-filter" data-sort="rating" href="#">평점순</a></li>
                </ul>
            </div>

        </div>
    </div>
    <!-- Best Sellers Section -->
    <section id="best-sellers" class="best-sellers section py-5">
        <div class="container-fluid px-3 px-lg-5">
            <div class="row justify-content-center mb-4">
                <div class="col-12 text-center">
                    <h2 class="section-title fw-bold">강의 목록</h2>
                    <p class="text-muted">다양한 운동 강의를 만나보세요</p>
                </div>
            </div>
            <div class="row py-4 g-4" id="courseList">
                <!-- 강의 카드 -->
                <c:if test="${not empty courseList}">
                    <c:forEach var="c" items="${courseList}">
                        <div class="col-12 col-sm-6 col-md-4 col-lg-3 list-to-detail" id="${c.courseSeq}">
                            <div class="card h-100 border-0 shadow-sm">
                                <div class="ratio" style="--bs-aspect-ratio: 80%; min-height: 200px;">
                                    <img id="productImage${c.courseSeq}" src="" class="w-100 h-100 object-fit-cover"
                                         alt="강의 썸네일">
                                    <script>
                                        // 이미지가 있으면 myImage 아이디를 갖고 있는 img 태그에 적용한다.
                                        // 없으면 getImageUrl 함수안에 return defaultImageUrl; 실행.
                                        document.getElementById("productImage${c.courseSeq}").src = getImageUrl("${c.courseThumbnail}");
                                    </script>
                                </div>
                                <div class="card-body d-flex flex-column justify-content-between"
                                     style="min-height: 240px;">
                                    <div>
                                        <p class="text-muted small mb-1">${c.memberNickname}</p>
                                        <h5 class="card-title fw-semibold text-truncate">${c.courseTarget}</h5>
                                            <%--                                        <p class="card-text text-secondary small text-truncate">${c.courseContent}</p>--%>
                                    </div>
                                    <div class="d-flex flex-wrap align-items-center gap-2 mt-3">
                                        <span class="badge bg-light text-secondary border">${c.cateValue}</span>
                                        <span class="badge bg-light text-secondary border">${c.courseType=='ON'?'온라인':'오프라인'}</span>
                                        <span class="badge bg-light text-secondary border">
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
                                    <div class="badge bg-primary border d-flex align-items-center justify-content-between mt-3">
                                        <div class="text-light">
                                            <i class="bi bi-heart-fill"></i> <fmt:formatNumber
                                                value="${c.avgRating != null ? c.avgRating : 0.0}" pattern="0.0"/> <span
                                                class="text-muted"></span>
                                        </div>
                                        <div class="text-light">수강평 ${c.reviewCount != null ? c.reviewCount : 0}개</div>
                                    </div>
                                    <div class="d-flex flex-wrap align-items-center mt-3 gap-3 justify-content-end mb-3">
                                        <c:choose>
                                            <c:when test="${c.courseDiscount > 0}">
                                                <span class="text-danger text-decoration-line-through fs-6">
                                                    ₩ <fmt:formatNumber type="number" maxFractionDigits="3" value="${c.coursePrice}"/>
                                                </span>
                                                <span> ➡️ </span>
                                                <span class="fw-bold fs-6 text-primary">
                                                    ₩ <fmt:formatNumber type="number" maxFractionDigits="3"
                                                                        value="${c.coursePrice * ((100 - c.courseDiscount) / 100)}"/>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="fw-bold fs-6 text-primary">
                                                    ₩ <fmt:formatNumber type="number" maxFractionDigits="3" value="${c.coursePrice}"/>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                        <button id="${c.courseSeq}" type="button"
                                                class="bi-cart btn-primary btn cart-btn"></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:if>

            </div>
        </div>
    </section>

    </button>
    <!-- /Best Sellers Section -->
    <script>
        let page = 1;
        let isLoading = false;
        let hasMore = true;

        // 필터 상태 관리
        let currentFilters = {
            courseType: 'all',     // 온라인/오프라인
            difficulty: 'all',     // 난이도 1~5
            priceType: 'all',      // 무료/유료
            sortBy: 'latest'       // 정렬방식
        };

        // 필터링된 강의 목록 불러오기
        function loadFilteredCourses(resetPage = true) {
            if (resetPage) {
                page = 1;
                hasMore = true;
            }

            isLoading = true;
            
            $.ajax({
                url: '${pageContext.request.contextPath}/main/filterCourses',
                type: 'GET',
                data: Object.assign({page: page}, currentFilters),
                success: function (data) {
                    if (resetPage) {
                        $('#courseList').empty();
                    }

                    if (data.length === 0) {
                        if (resetPage) {
                            $('#courseList').html('<div class="col-12 text-center"><p class="text-muted">조건에 맞는 강의가 없습니다.</p></div>');
                        } else {
                            hasMore = false;
                            $("#courseList").append("<p class='text-center mt-3' style='color: lightgray'>마지막 페이지 입니다.</p>");
                        }
                        return;
                    }

                    updateCourseList(data);

                    if (resetPage) {
                        page = 1; // 페이지 초기화
                    }

                    // 8개 미만이면 더 이상 로드할 데이터가 없다고 가정
                    if (data.length < 8) {
                        hasMore = false;
                    }
                },
                error: function () {
                    console.error('필터링 실패');
                    alert('강의 목록을 불러오는데 실패했습니다.');
                },
                complete: function () {
                    isLoading = false;
                }
            });
        }

        // 강의 목록 UI 업데이트
        function updateCourseList(courses) {
            courses.forEach(function (course) {
                let stars = "";
                for (let i = 1; i < 6; i++) {
                    if (i <= course['courseDifficult']) {
                        stars += '<span style="color: gold;">★</span>'
                    } else {
                        stars += '<span style="color: lightgray;">★</span>'
                    }
                }

                const courseHtml =
                    '<div class="col-12 col-sm-6 col-md-4 col-lg-3 list-to-detail" id="' + course['courseSeq'] + '">'
                    + '<div class="card h-100 border-0 shadow-sm">'
                    + '    <div class="ratio" style="--bs-aspect-ratio: 80%; min-height: 200px;">'
                    + '        <img id="productImage' + course['courseSeq'] + '" src="" class="w-100 h-100 object-fit-cover" alt="강의 썸네일"/>'
                    + '    </div>'
                    + '    <div class="card-body d-flex flex-column justify-content-between" style="min-height: 240px;">'
                    + '        <div>'
                    + '            <p class="text-muted small mb-1">' + course['memberNickname'] + '</p>'
                    + '            <h5 class="card-title fw-semibold text-truncate">' + course['courseTitle'] + '</h5>'
                    + '            <p class="card-text text-secondary small text-truncate">' + course['courseTarget'] + '</p>'
                    + '        </div>'
                    + '        <div class="d-flex flex-wrap align-items-center gap-2 mt-3">'
                    + '            <span class="badge bg-light text-secondary border">' + course['cateValue'] + '</span>'
                    + '            <span class="badge bg-light text-secondary border">' + (course['courseType'] === 'ON' ? '온라인' : '오프라인') + '</span>'
                    + '            <span class="badge bg-light text-secondary border">'
                    + '               ' + stars + ''
                    + '            </span>'
                    + '        </div>'
                    + '        <div class="badge bg-primary border d-flex align-items-center justify-content-between mt-3">'
                    + '            <div class="text-light">'
                    + '                <i class="bi bi-heart-fill"></i> ' + (course['avgRating'] != null ? parseFloat(course['avgRating']).toFixed(1) : '0.0') + ' <span class="text-muted"></span>'
                    + '            </div>'
                    + '            <div class="text-light">수강평 ' + (course['reviewCount'] != null ? course['reviewCount'] : 0) + '개</div>'
                    + '        </div>'
                    + (
                        course['courseDiscount'] > 0
                            ? (
                                '<div class="d-flex flex-wrap align-items-center mt-3 gap-3 justify-content-end mb-3">' +
                                '    <span class="text-danger text-decoration-line-through fs-6">' +
                                '        ₩ ' + course['coursePrice'].toLocaleString() +
                                '    </span>' +
                                '    <span> ➡️ </span>' +
                                '    <span class="fw-bold fs-6 text-primary">' +
                                '        ₩ ' + Math.floor(course['coursePrice'] * ((100 - course['courseDiscount']) / 100)).toLocaleString() +
                                '    </span>' +
                                '    <button id="' + course['courseSeq'] + '" type="button" class="btn-primary btn cart-btn"><i class="bi-cart"></i></button>' +
                                '</div>'
                            )
                            : (
                                '<div class="d-flex flex-wrap align-items-center mt-3 gap-3 justify-content-end mb-3">' +
                                '    <span class="fw-bold fs-6 text-primary">' +
                                '        ₩ ' + course['coursePrice'].toLocaleString() +
                                '    </span>' +
                                '    <button id="' + course['courseSeq'] + '" type="button" class="btn-primary btn cart-btn"><i class="bi-cart"></i></button>' +
                                '</div>'
                            )
                    )
                    + '    </div>'
                    + '</div>'
                    + '</div>';

                $("#courseList").append(courseHtml);

                // 이미지 처리
                const $img = $("#productImage" + course['courseSeq']);
                const fullPath = '${pageContext.request.contextPath}' + course['courseThumbnail'];
                $img.attr('src', fullPath);
                $img.on('error', function () {
                    $(this).attr('src', '${pageContext.request.contextPath}/resources/images/dummy.png');
                });
            });

            // 이벤트 리스너 재등록
            bindCourseEvents();
        }

        // 강의 카드 이벤트 바인딩
        function bindCourseEvents() {
            $('.list-to-detail').off('click').on('click', function (e) {
                const id = $(this).attr("id");
                const redirectUrl = "${pageContext.request.contextPath}/course/detail?courseSeq=" + id;
                location.assign(redirectUrl);
            });

            $('.cart-btn').off('click').on('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                const selectedCourseId = $(this).attr("id");
                $('#courseSeq').val(selectedCourseId);
                $('#cartModal').modal('show');
            });
        }

        // 필터 UI 업데이트
        function updateFilterUI() {
            // 온라인/오프라인 버튼 텍스트 업데이트
            const courseTypeButton = $('.dropdown').eq(0).find('button.dropdown-toggle');
            const courseTypeTexts = {
                'all': '전체',
                'ON': '온라인',
                'OFF': '오프라인'
            };
            courseTypeButton.text(courseTypeTexts[currentFilters.courseType] || '전체');

            // 난이도 버튼 텍스트 업데이트
            const difficultyButton = $('.dropdown').eq(1).find('button.dropdown-toggle');
            const difficultyTexts = {
                'all': '전체',
                '1': '⭐️',
                '2': '⭐️⭐️',
                '3': '⭐️⭐️⭐️',
                '4': '⭐️⭐️⭐️⭐️',
                '5': '⭐️⭐️⭐️⭐️⭐️'
            };
            difficultyButton.text(difficultyTexts[currentFilters.difficulty] || '전체');

            // 가격 버튼 텍스트 업데이트
            const priceButton = $('.dropdown').eq(2).find('button.dropdown-toggle');
            const priceTexts = {
                'all': '전체',
                'free': '무료',
                'paid': '유료'
            };
            priceButton.text(priceTexts[currentFilters.priceType] || '전체');

            // 정렬 버튼 텍스트 업데이트
            const sortButton = $('.dropdown').eq(3).find('button.dropdown-toggle');
            const sortTexts = {
                'latest': '최신순',
                'price_asc': '가격 낮은순',
                'price_desc': '가격 높은순',
                'rating': '평점순'
            };
            sortButton.text(sortTexts[currentFilters.sortBy] || '최신순');
        }

        // 페이지 로드 시 필터 이벤트 설정
        $(document).ready(function () {
            // URL 파라미터에서 검색어 확인
            const urlParams = new URLSearchParams(window.location.search);
            const searchKeyword = urlParams.get('search');
            
            if (searchKeyword) {
                // 검색어가 있으면 필터에 추가해서 검색 실행
                currentFilters.keyword = searchKeyword;
                updateSectionTitle(searchKeyword); // 제목 업데이트
                loadFilteredCourses(true); // 기존 함수 활용!
                showSearchStatus(searchKeyword); // 검색 상태 표시
                showSearchKeywordInFilter(searchKeyword); // 필터에 검색어 표시
                
                // 헤더의 검색창에 검색어 유지
                $('input[name="keyword"]').val(searchKeyword);
            }
            
            // 모든 필터 초기화 버튼
            $('.btn-outline-secondary').first().click(function () {
                currentFilters = {
                    courseType: 'all',
                    difficulty: 'all',
                    priceType: 'all',
                    sortBy: 'latest'
                };
                delete currentFilters.keyword; // 검색어 제거
                updateFilterUI();
                loadFilteredCourses();
                resetSectionTitle(); // 제목 원복
                $('#searchStatus').remove(); // 검색 상태 제거
                hideSearchKeywordInFilter(); // 검색어 표시 숨기기
            });

            // 온라인/오프라인 필터
            $('.course-type-filter').click(function (e) {
                e.preventDefault();
                currentFilters.courseType = $(this).data('type');
                updateFilterUI();
                loadFilteredCourses();
            });

            // 난이도 필터
            $('.difficulty-filter').click(function (e) {
                e.preventDefault();
                currentFilters.difficulty = $(this).data('difficulty');
                updateFilterUI();
                loadFilteredCourses();
            });

            // 가격 필터
            $('.price-filter').click(function (e) {
                e.preventDefault();
                currentFilters.priceType = $(this).data('price');
                updateFilterUI();
                loadFilteredCourses();
            });

            // 정렬 필터
            $('.sort-filter').click(function (e) {
                e.preventDefault();
                currentFilters.sortBy = $(this).data('sort');
                updateFilterUI();
                loadFilteredCourses();
            });
        });
        $(window).on("scroll", function () {
            if (!hasMore || isLoading) return;

            const scrollTop = $(window).scrollTop();
            const windowHeight = $(window).height();
            const documentHeight = $(document).height();
            if (scrollTop + windowHeight >= documentHeight - 50) {
                page++; // 페이지 증가
                loadFilteredCourses(false); // resetPage = false로 호출
            }
        });
        
        // 검색 관련 함수들
        function updateSectionTitle(keyword) {
            const titleElement = $('.section-title');
            if (titleElement.length) {
                titleElement.html('<i class="bi bi-search me-2"></i>"' + keyword + '" 검색 결과');
            }
            
            // 검색 시 히어로 섹션 숨기기
            $('#hero').hide();
        }
        
        function resetSectionTitle() {
            const titleElement = $('.section-title');
            if (titleElement.length) {
                titleElement.text('강의 목록');
            }
            
            // 전체보기 시 히어로 섹션 다시 표시
            $('#hero').show();
        }
        
        function showSearchStatus(keyword) {
            // 기존 검색 상태 제거
            $('#searchStatus').remove();
            
            // 새 검색 상태 추가
            const statusHtml = 
                '<div id="searchStatus" class="container-fluid px-3 px-lg-5 mt-3 mb-4">' +
                '<div class="alert alert-info d-flex justify-content-between align-items-center">' +
                '<div>' +
                '<i class="bi bi-info-circle me-2"></i>' +
                '<strong>"' + keyword + '"</strong> 검색 결과를 표시하고 있습니다.' +
                '</div>' +
                '<button type="button" class="btn btn-outline-primary btn-sm" onclick="resetSearch()">' +
                '<i class="bi bi-arrow-clockwise me-1"></i>전체보기' +
                '</button>' +
                '</div>' +
                '</div>';
            
            // 강의 목록 위에 추가
            $('.section-title').parent().parent().after(statusHtml);
        }
        
        function resetSearch() {
            // URL에서 검색 파라미터 제거하고 페이지 새로고침
            window.location.href = '${pageContext.request.contextPath}/';
        }
        
        function showSearchKeywordInFilter(keyword) {
            $('#currentSearchKeyword').text(keyword);
            $('#searchKeywordDisplay').removeClass('d-none');
        }
        
        function hideSearchKeywordInFilter() {
            $('#searchKeywordDisplay').addClass('d-none');
        }
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
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
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


<div class="modal fade" id="cartModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel">장바구니</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>

            <div class="modal-body">
                장바구니에 담으시겠습니까?
            </div>

            <div class="modal-footer">
                <form action="${pageContext.request.contextPath}/cart/add" method="post">
                    <input type="hidden" value="" id="courseSeq" name="addCourseSeq">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">아니오</button>
                    <button type="submit" class="btn btn-primary" id="confirmCartBtn">네</button>
                </form>
            </div>

        </div>
    </div>
</div>
<script>
    let selectedCourseId = null;

    // 초기 페이지 로드 시 이벤트 바인딩
    $(document).ready(function () {
        bindCourseEvents();
    });
</script>


<div class="modal fade" id="resultModal" tabindex="-1" aria-labelledby="resultModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <h5 class="modal-title" id="resultModalLabel">알림</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>

            <div class="modal-body" id="resultModalMessage">
                <!--메세지 -->
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">확인</button>
            </div>

        </div>
    </div>
</div>


<script>
    document.addEventListener('DOMContentLoaded', function () {
        onload = () => {
            const urlParams = new URLSearchParams(window.location.search);
            const result = urlParams.get('result');
            const msg = urlParams.get('msg');
            console.log(urlParams, result, msg);
            if (result && msg) {
                if (result === 'success') {
                    $('#resultModal .modal-body').text(msg);
                    $('#resultModal').modal('show');
                } else if (result === 'fail') {
                    $('#resultModal .modal-body').text(msg);
                    $('#resultModal').modal('show');
                }
            }
        }
    });
</script>


<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

