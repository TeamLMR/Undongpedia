<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="course" value="${null}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>${course.title} - 운동피디아</title>
  <meta name="description" content="${course.description}">

  <!-- Favicons -->
  <link href="${pageContext.request.contextPath}/resources/assets/img/favicon.png" rel="icon">
  <link href="${pageContext.request.contextPath}/resources/assets/img/apple-touch-icon.png" rel="apple-touch-icon">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com" rel="preconnect">
  <link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

  <!-- Vendor CSS Files -->
  <link href="${pageContext.request.contextPath}/resources/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/resources/assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/resources/assets/vendor/swiper/swiper-bundle.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/resources/assets/vendor/aos/aos.css" rel="stylesheet">

  <!-- Main CSS File -->
  <link href="${pageContext.request.contextPath}/resources/assets/css/main.css" rel="stylesheet">

  <!-- Custom CSS for Course Booking -->
  <style>
    .booking-calendar {
      margin-bottom: 20px;
    }

    .time-slots {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
      gap: 10px;
      margin-top: 15px;
    }

    .time-slot {
      padding: 10px;
      border: 2px solid #e0e0e0;
      border-radius: 8px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s ease;
      position: relative;
    }

    .time-slot:hover {
      border-color: #3690e7;
      background-color: #f0f8ff;
    }

    .time-slot.selected {
      border-color: #3690e7;
      background-color: #3690e7;
      color: white;
    }

    .time-slot.full {
      background-color: #f5f5f5;
      color: #999;
      cursor: not-allowed;
      pointer-events: none;
    }

    .time-slot .time {
      font-weight: 600;
      font-size: 16px;
    }

    .time-slot .seats {
      font-size: 12px;
      margin-top: 5px;
    }

    .seats-available {
      color: #28a745;
    }

    .seats-limited {
      color: #ff9800;
    }

    .seats-full {
      color: #dc3545;
    }

    .booking-info {
      background-color: #f8f9fa;
      padding: 20px;
      border-radius: 10px;
      margin-bottom: 20px;
    }

    .real-time-indicator {
      display: inline-flex;
      align-items: center;
      font-size: 12px;
      color: #28a745;
      margin-left: 10px;
    }

    .real-time-indicator::before {
      content: '';
      width: 8px;
      height: 8px;
      background-color: #28a745;
      border-radius: 50%;
      margin-right: 5px;
      animation: pulse 2s infinite;
    }

    @keyframes pulse {
      0% { opacity: 1; }
      50% { opacity: 0.3; }
      100% { opacity: 1; }
    }
  </style>
</head>

<body class="course-details-page">

<!-- Header -->
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<main class="main">

  <!-- Page Title -->
  <div class="page-title light-background">
    <div class="container">
      <nav class="breadcrumbs">
        <ol>
          <li><a href="${pageContext.request.contextPath}/">홈</a></li>
          <li><a href="${pageContext.request.contextPath}/courses">강의</a></li>
<%--          <li class="current">${course.title}</li>--%>
        </ol>
      </nav>
      <h1>강의 상세</h1>
    </div>
  </div>

  <!-- Course Details Section -->
  <section id="course-details" class="course-details section">
    <div class="container" data-aos="fade-up">
      <div class="row g-5">

        <!-- Course Images Column -->
        <div class="col-lg-6 mb-5 mb-lg-0">
          <div class="course-gallery">
            <div class="main-image-wrapper">
              <img src="${pageContext.request.contextPath}${course.mainImage}"
                   alt="${course.title}" class="img-fluid main-image">
            </div>

            <!-- 추가 이미지가 있다면 -->
            <c:if test="${not empty course.additionalImages}">
              <div class="thumbnails-horizontal mt-3">
                <c:forEach items="${course.additionalImages}" var="image">
                  <div class="thumbnail-item">
                    <img src="${pageContext.request.contextPath}${image}"
                         alt="${course.title}" class="img-fluid">
                  </div>
                </c:forEach>
              </div>
            </c:if>
          </div>
        </div>

        <!-- Course Info Column -->
        <div class="col-lg-6">
          <div class="course-info-wrapper">

            <!-- Course Meta -->
            <div class="course-meta">
              <span class="course-category">${course.category}</span>
              <h1 class="course-title">${course.title}</h1>

              <div class="instructor-info">
                <i class="bi bi-person-circle"></i>
                <span>강사: ${course.instructor.name}</span>
              </div>

              <div class="course-rating">
                <div class="stars">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                      <c:when test="${i <= course.rating}">
                        <i class="bi bi-star-fill"></i>
                      </c:when>
                      <c:otherwise>
                        <i class="bi bi-star"></i>
                      </c:otherwise>
                    </c:choose>
                  </c:forEach>
                  <span class="rating-value">${course.rating}</span>
                </div>
                <a href="#reviews" class="rating-count">${course.reviewCount}개 리뷰</a>
                <span class="real-time-indicator">실시간 예약</span>
              </div>
            </div>

            <!-- Course Price -->
            <div class="course-price-container">
              <div class="price-wrapper">
                  <span class="current-price">
                    <fmt:formatNumber value="${course.price}" pattern="#,###"/>원
                  </span>
                <c:if test="${course.originalPrice > course.price}">
                    <span class="original-price">
                      <fmt:formatNumber value="${course.originalPrice}" pattern="#,###"/>원
                    </span>
                  <span class="discount-badge">
                      ${Math.round((course.originalPrice - course.price) / course.originalPrice * 100)}% 할인
                    </span>
                </c:if>
              </div>
              <div class="course-info">
                <i class="bi bi-clock"></i>
                <span>강의 시간: ${course.duration}분</span>
              </div>
            </div>

            <!-- Course Description -->
            <div class="course-short-description">
              <p>${course.shortDescription}</p>
            </div>

            <!-- Booking Options -->
            <div class="booking-options">

              <!-- Date Selection -->
              <div class="option-group">
                <h6 class="option-title">날짜 선택</h6>
                <div class="booking-calendar">
                  <input type="date" id="courseDate" class="form-control"
                         min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                         required>
                </div>
              </div>

              <!-- Time Slot Selection -->
              <div class="option-group" id="timeSlotSection" style="display: none;">
                <h6 class="option-title">시간 선택</h6>
                <div class="time-slots" id="timeSlots">
                  <!-- 시간대는 날짜 선택 후 동적으로 로드됨 -->
                </div>
              </div>

              <!-- Number of People -->
              <div class="option-group" id="peopleSection" style="display: none;">
                <h6 class="option-title">예약 인원</h6>
                <div class="quantity-selector">
                  <button class="quantity-btn decrease" onclick="updatePeople(-1)">
                    <i class="bi bi-dash"></i>
                  </button>
                  <input type="number" id="numberOfPeople" class="quantity-input"
                         value="1" min="1" max="4" readonly>
                  <button class="quantity-btn increase" onclick="updatePeople(1)">
                    <i class="bi bi-plus"></i>
                  </button>
                </div>
                <small class="text-muted">최대 4명까지 예약 가능합니다.</small>
              </div>
            </div>

            <!-- Booking Summary -->
            <div class="booking-info" id="bookingSummary" style="display: none;">
              <h6>예약 정보</h6>
              <div class="summary-item">
                <span>선택 날짜:</span>
                <span id="selectedDate">-</span>
              </div>
              <div class="summary-item">
                <span>선택 시간:</span>
                <span id="selectedTime">-</span>
              </div>
              <div class="summary-item">
                <span>예약 인원:</span>
                <span id="selectedPeople">1명</span>
              </div>
              <div class="summary-item">
                <span>총 금액:</span>
                <strong id="totalPrice">-</strong>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="course-actions">
              <button class="btn btn-primary reserve-btn" id="reserveBtn" disabled>
                <i class="bi bi-calendar-check"></i> 예약하기
              </button>
              <button class="btn btn-outline-secondary wishlist-btn">
                <i class="bi bi-heart"></i>
              </button>
            </div>

            <!-- Course Features -->
            <div class="course-features">
              <div class="feature-item">
                <i class="bi bi-shield-check"></i>
                <div>
                  <h6>예약 보장</h6>
                  <p>실시간 좌석 확인</p>
                </div>
              </div>
              <div class="feature-item">
                <i class="bi bi-arrow-repeat"></i>
                <div>
                  <h6>취소 가능</h6>
                  <p>24시간 전까지 무료 취소</p>
                </div>
              </div>
              <div class="feature-item">
                <i class="bi bi-people"></i>
                <div>
                  <h6>소규모 클래스</h6>
                  <p>최대 ${course.maxCapacity}명</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</main>

<!-- Footer -->
<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<!-- WebSocket for Real-time Updates -->
<script>
  const courseId = '${course.id}';
  const coursePrice = ${course.price};
  let selectedDate = null;
  let selectedTime = null;
  let numberOfPeople = 1;
  let ws = null;

  // WebSocket 연결
  function connectWebSocket() {
    ws = new WebSocket('ws://localhost:8080/reservation-ws');

    ws.onopen = function() {
      console.log('WebSocket 연결됨');
    };

    ws.onmessage = function(event) {
      const message = JSON.parse(event.data);
      if (message.type === 'SEAT_UPDATE' && message.courseId === courseId) {
        updateTimeSlotAvailability(message.date, message.time, message.availableSeats);
      }
    };

    ws.onerror = function(error) {
      console.error('WebSocket 에러:', error);
    };

    ws.onclose = function() {
      console.log('WebSocket 연결 종료');
      // 재연결 시도
      setTimeout(connectWebSocket, 3000);
    };
  }

  // 날짜 선택 이벤트
  document.getElementById('courseDate').addEventListener('change', function() {
    selectedDate = this.value;
    loadAvailableTimeSlots(selectedDate);
  });

  // 시간대 로드
  function loadAvailableTimeSlots(date) {
    fetch(`${pageContext.request.contextPath}/api/courses/${courseId}/available-slots?date=` + date)
            .then(response => response.json())
            .then(data => {
              displayTimeSlots(data);
              document.getElementById('timeSlotSection').style.display = 'block';
            })
            .catch(error => console.error('Error:', error));
  }

  // 시간대 표시
  function displayTimeSlots(slots) {
    const container = document.getElementById('timeSlots');
    container.innerHTML = '';

    slots.forEach(slot => {
      const div = document.createElement('div');
      div.className = 'time-slot';

      if (slot.availableSeats === 0) {
        div.classList.add('full');
      }

      div.innerHTML = `
          <div class="time">${slot.time}</div>
          <div class="seats ${getSeatsClass(slot.availableSeats, slot.totalSeats)}">
            ${slot.availableSeats}/${slot.totalSeats}석
          </div>
        `;

      div.onclick = function() {
        if (slot.availableSeats > 0) {
          selectTimeSlot(this, slot.time);
        }
      };

      container.appendChild(div);
    });
  }

  // 좌석 상태에 따른 클래스
  function getSeatsClass(available, total) {
    const ratio = available / total;
    if (ratio === 0) return 'seats-full';
    if (ratio <= 0.3) return 'seats-limited';
    return 'seats-available';
  }

  // 시간대 선택
  function selectTimeSlot(element, time) {
    // 기존 선택 제거
    document.querySelectorAll('.time-slot.selected').forEach(el => {
      el.classList.remove('selected');
    });

    // 새로운 선택
    element.classList.add('selected');
    selectedTime = time;

    // 인원 선택 섹션 표시
    document.getElementById('peopleSection').style.display = 'block';
    updateBookingSummary();
  }

  // 인원 수 업데이트
  function updatePeople(change) {
    const input = document.getElementById('numberOfPeople');
    let newValue = parseInt(input.value) + change;

    if (newValue >= 1 && newValue <= 4) {
      input.value = newValue;
      numberOfPeople = newValue;
      updateBookingSummary();
    }
  }

  // 예약 정보 업데이트
  function updateBookingSummary() {
    if (selectedDate && selectedTime) {
      document.getElementById('bookingSummary').style.display = 'block';
      document.getElementById('selectedDate').textContent = selectedDate;
      document.getElementById('selectedTime').textContent = selectedTime;
      document.getElementById('selectedPeople').textContent = numberOfPeople + '명';

      const totalPrice = coursePrice * numberOfPeople;
      document.getElementById('totalPrice').textContent =
              new Intl.NumberFormat('ko-KR').format(totalPrice) + '원';

      document.getElementById('reserveBtn').disabled = false;
    }
  }

  // 시간대 가용성 실시간 업데이트
  function updateTimeSlotAvailability(date, time, availableSeats) {
    if (selectedDate === date) {
      const slots = document.querySelectorAll('.time-slot');
      slots.forEach(slot => {
        if (slot.querySelector('.time').textContent === time) {
          const seatsDiv = slot.querySelector('.seats');
          const totalSeats = parseInt(seatsDiv.textContent.split('/')[1]);

          seatsDiv.textContent = `${availableSeats}/${totalSeats}석`;
          seatsDiv.className = 'seats ' + getSeatsClass(availableSeats, totalSeats);

          if (availableSeats === 0) {
            slot.classList.add('full');
            if (selectedTime === time) {
              // 선택한 시간대가 만석이 되면 선택 해제
              slot.classList.remove('selected');
              selectedTime = null;
              document.getElementById('reserveBtn').disabled = true;
            }
          } else {
            slot.classList.remove('full');
          }
        }
      });
    }
  }

  // 예약하기 버튼 클릭
  document.getElementById('reserveBtn').addEventListener('click', function() {
    if (!selectedDate || !selectedTime) {
      alert('날짜와 시간을 선택해주세요.');
      return;
    }

    // Redis를 통한 좌석 잠금 및 예약 처리
    const reservationData = {
      courseId: courseId,
      date: selectedDate,
      time: selectedTime,
      numberOfPeople: numberOfPeople
    };

    // 버튼 비활성화 (중복 클릭 방지)
    this.disabled = true;
    this.innerHTML = '<i class="bi bi-hourglass-split"></i> 예약 처리중...';

    fetch('${pageContext.request.contextPath}/api/reservations', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(reservationData)
    })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                alert('예약이 완료되었습니다!');
                window.location.href = '${pageContext.request.contextPath}/reservations/' + data.reservationId;
              } else {
                alert(data.message || '예약에 실패했습니다. 다시 시도해주세요.');
                this.disabled = false;
                this.innerHTML = '<i class="bi bi-calendar-check"></i> 예약하기';
              }
            })
            .catch(error => {
              console.error('Error:', error);
              alert('예약 처리 중 오류가 발생했습니다.');
              this.disabled = false;
              this.innerHTML = '<i class="bi bi-calendar-check"></i> 예약하기';
            });
  });

  // 페이지 로드 시 WebSocket 연결
  document.addEventListener('DOMContentLoaded', function() {
    connectWebSocket();
  });
</script>

<!-- Vendor JS Files -->
<script src="${pageContext.request.contextPath}/resources/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/assets/vendor/aos/aos.js"></script>
<script src="${pageContext.request.contextPath}/resources/assets/vendor/swiper/swiper-bundle.min.js"></script>

<!-- Main JS File -->
<script src="${pageContext.request.contextPath}/resources/assets/js/main.js"></script>

</body>
</html>