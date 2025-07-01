<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 로그인 사용자 정보 가져오기 -->
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- Flatpickr CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">

  <main class="main">

    <!-- Page Title -->
    <div class="page-title light-background">
      <div class="container">
        <nav class="breadcrumbs">
                      <ol>
              <li><a href="/">Home</a></li>
              <li><a href="/course/list">강의</a></li>
              <li class="current">강의 예약</li>
            </ol>
          </nav>
          <h1>강의 예약</h1>
      </div>
    </div><!-- End Page Title -->

    <!-- Course Reservation Section -->
    <section id="course-reservation" class="course-reservation section">

      <div class="container" data-aos="fade-up" data-aos-delay="100">

        <div class="row g-5">
          <!-- Course Images Column -->
          <div class="col-lg-6 mb-5 mb-lg-0" data-aos="fade-right" data-aos-delay="200">
            <div class="course-gallery">
              <!-- Course Thumbnail -->
              <div class="course-image-wrapper">
                <div class="image-container">
                  <img src="${empty course.courseThumbnail ? '/undongpedia/resources/images/dummy.webp' : course.courseThumbnail}" 
                       alt="강의 이미지" class="img-fluid course-image">
                </div>
              </div>
              
              <!-- Course Features -->
              <div class="course-features mt-4">
                <div class="feature-item">
                  <i class="bi bi-people"></i>
                  <div>
                    <h6>정원</h6>
                    <p id="selected-capacity">정원을 확인하세요</p>
                  </div>
                </div>
                <div class="feature-item">
                  <i class="bi bi-geo-alt"></i>
                  <div>
                    <h6>위치</h6>
                    <p id="selected-location">위치를 확인하세요</p>
                  </div>
                </div>
                <div class="feature-item">
                  <i class="bi bi-clock"></i>
                  <div>
                    <h6>수업 시간</h6>
                    <p id="selected-duration">시간을 선택하세요</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Course Reservation Form Column -->
          <div class="col-lg-6" data-aos="fade-left" data-aos-delay="200">
            <div class="reservation-form-wrapper" id="reservation-form-sticky">
              <!-- Course Meta -->
              <div class="course-meta">
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="course-category">
                    <c:choose>
                      <c:when test="${course.courseType == 'ON'}">온라인 강의</c:when>
                      <c:when test="${course.courseType == 'OFF'}">오프라인 강의</c:when>
                      <c:otherwise>강의</c:otherwise>
                    </c:choose>
                  </span>
                  <div class="course-difficulty">
                    <c:choose>
                      <c:when test="${course.courseDifficult == 1}">초급</c:when>
                      <c:when test="${course.courseDifficult == 2}">중급</c:when>
                      <c:when test="${course.courseDifficult == 3}">고급</c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </div>
                  <div class="course-share">
                    <button class="share-btn" aria-label="강의 공유">
                      <i class="bi bi-share"></i>
                    </button>
                  </div>
                </div>

                <h1 class="course-title">${course.courseTitle}</h1>

                <div class="course-rating">
                  <div class="stars">
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-fill"></i>
                    <i class="bi bi-star-half"></i>
                    <span class="rating-value">4.5</span>
                  </div>
                  <a href="#reviews" class="rating-count">리뷰 보기</a>
                </div>
              </div>

              <!-- Course Price -->
              <div class="course-price-container">
                <div class="price-wrapper">
                  <span class="current-price">
                    <c:choose>
                      <c:when test="${course.courseDiscount > 0}">
                        <c:set var="discountedPrice" value="${course.coursePrice * (100 - course.courseDiscount) / 100}" />
                        <c:out value="${discountedPrice}" />원
                      </c:when>
                      <c:otherwise>
                        <c:out value="${course.coursePrice}" />원
                      </c:otherwise>
                    </c:choose>
                  </span>
                  <c:if test="${course.courseDiscount > 0}">
                    <span class="original-price"><c:out value="${course.coursePrice}" />원</span>
                  </c:if>
                </div>
                <c:if test="${course.courseDiscount > 0}">
                  <span class="discount-badge"><c:out value="${course.courseDiscount}" />% 할인</span>
                </c:if>
              </div>

              <!-- Course Description -->
              <div class="course-short-description">
                <p><c:out value="${course.courseContent}" /></p>
              </div>

              <!-- Reservation Form -->
              <form id="reservationForm" class="reservation-form">
                <input type="hidden" id="courseSeq" value="${course.courseSeq}">
                
                <!-- Date Selection -->
                <div class="form-group mb-4">
                  <h6 class="form-label">예약 날짜 선택</h6>
                  <div class="date-picker-container">
                    <input type="text" id="reservationDate" class="form-control" 
                           placeholder="예약 가능한 날짜를 선택하세요" readonly required>
                    <i class="bi bi-calendar-event date-picker-icon"></i>
                  </div>
                  
                  <!-- 달력 범례 -->
                  <div class="calendar-legend">
                    <div class="legend-item">
                      <div class="legend-color legend-many"></div>
                      <span>여유</span>
                    </div>
                    <div class="legend-item">
                      <div class="legend-color legend-few"></div>
                      <span>마감임박</span>
                    </div>
                    <div class="legend-item">
                      <div class="legend-color legend-full"></div>
                      <span>마감</span>
                    </div>
                  </div>
                </div>

                <!-- Time Selection -->
                <div class="form-group mb-4">
                  <h6 class="form-label">시간 선택</h6>
                  <div id="timeSlotContainer" class="time-slots-container">
                    <div class="no-slots-message">
                      <i class="bi bi-calendar-x"></i>
                      <p>날짜를 선택하면 이용 가능한 시간대가 표시됩니다.</p>
                    </div>
                  </div>
                </div>

                <!-- Selected Info -->
                <div id="selectedInfo" class="selected-info mb-4" style="display: none;">
                  <div class="info-card">
                    <h6>선택된 예약 정보</h6>
                    <div class="info-row">
                      <span class="label">날짜:</span>
                      <span id="selectedDateText">-</span>
                    </div>
                    <div class="info-row">
                      <span class="label">시간:</span>
                      <span id="selectedTimeText">-</span>
                    </div>
                    <div class="info-row">
                      <span class="label">위치:</span>
                      <span id="selectedLocationText">-</span>
                    </div>
                    <div class="info-row">
                      <span class="label">잔여 좌석:</span>
                      <span id="remainingSeats">-</span>
                    </div>
                  </div>
                </div>

                <!-- Action Buttons -->
                <div class="reservation-actions">
                  <button type="submit" class="btn btn-primary reservation-btn" disabled>
                    <i class="bi bi-calendar-check"></i> 예약하기
                  </button>
                  <button type="button" class="btn btn-outline-secondary wishlist-btn" aria-label="찜하기">
                    <i class="bi bi-heart"></i>
                  </button>
                </div>
              </form>

              <!-- Course Benefits -->
              <div class="course-benefits">
                <div class="benefit-item">
                  <i class="bi bi-shield-check"></i>
                  <div>
                    <h6>안전한 예약</h6>
                    <p>예약 취소 정책 적용</p>
                  </div>
                </div>
                <div class="benefit-item">
                  <i class="bi bi-arrow-repeat"></i>
                  <div>
                    <h6>일정 변경 가능</h6>
                    <p>강의 24시간 전까지 변경 가능</p>
                  </div>
                </div>
                <div class="benefit-item">
                  <i class="bi bi-award"></i>
                  <div>
                    <h6>전문 강사</h6>
                    <p>경험이 풍부한 전문 강사진</p>
                  </div>
                </div>
                <c:if test="${course.courseType == 'ON'}">
                <div class="benefit-item">
                  <i class="bi bi-laptop"></i>
                  <div>
                    <h6>온라인 수강</h6>
                    <p>언제 어디서나 편리하게</p>
                  </div>
                </div>
                </c:if>
                <c:if test="${course.courseType == 'OFF'}">
                <div class="benefit-item">
                  <i class="bi bi-geo-alt"></i>
                  <div>
                    <h6>오프라인 수강</h6>
                    <p>직접 체험하는 실습 중심</p>
                  </div>
                </div>
                </c:if>
              </div>
            </div>
          </div>
        </div>

        <!-- Course Details Accordion -->
        <div class="row mt-5" data-aos="fade-up">
          <div class="col-12">
            <div class="product-details-accordion">
              <!-- Description Accordion -->
              <div class="accordion-item">
                <h2 class="accordion-header">
                  <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#description" aria-expanded="true" aria-controls="description">
                    강의 상세 설명
                  </button>
                </h2>
                <div id="description" class="accordion-collapse collapse show">
                  <div class="accordion-body">
                    <div class="product-description">
                      <h4>강의 개요</h4>
                      <p><c:out value="${course.courseContent}" /></p>

                      <div class="row mt-4">
                        <div class="col-md-6">
                          <h4>교육 대상</h4>
                          <p>
                            <c:choose>
                              <c:when test="${not empty course.courseTarget}">
                                <c:out value="${course.courseTarget}" />
                              </c:when>
                              <c:otherwise>모든 수준의 수강생</c:otherwise>
                            </c:choose>
                          </p>
                        </div>
                        <div class="col-md-6">
                          <h4>준비물</h4>
                          <p>
                            <c:choose>
                              <c:when test="${not empty course.coursePreparation}">
                                <c:out value="${course.coursePreparation}" />
                              </c:when>
                              <c:otherwise>별도 준비물 없음</c:otherwise>
                            </c:choose>
                          </p>
                        </div>
                      </div>

                      <!-- 추가 정보 -->
                      <div class="row mt-4">
                        <div class="col-md-6">
                          <h4>강의 유형</h4>
                          <p>
                            <c:choose>
                              <c:when test="${course.courseType == 'ON'}">
                                <i class="bi bi-laptop"></i> 온라인 강의
                              </c:when>
                              <c:when test="${course.courseType == 'OFF'}">
                                <i class="bi bi-geo-alt"></i> 오프라인 강의
                              </c:when>
                              <c:otherwise>-</c:otherwise>
                            </c:choose>
                          </p>
                        </div>
                        <div class="col-md-6">
                          <h4>난이도</h4>
                          <p>
                            <c:choose>
                              <c:when test="${course.courseDifficult == 1}">
                                <span class="badge bg-success">초급</span>
                              </c:when>
                              <c:when test="${course.courseDifficult == 2}">
                                <span class="badge bg-warning">중급</span>
                              </c:when>
                              <c:when test="${course.courseDifficult == 3}">
                                <span class="badge bg-danger">고급</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge bg-secondary">-</span>
                              </c:otherwise>
                            </c:choose>
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Schedule Accordion -->
              <div class="accordion-item">
                <h2 class="accordion-header">
                  <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#schedule" aria-expanded="false" aria-controls="schedule">
                    강의 일정표
                  </button>
                </h2>
                <div id="schedule" class="accordion-collapse collapse">
                  <div class="accordion-body">
                    <div id="scheduleCalendar" class="schedule-calendar">
                      <p>달력</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section><!-- /Course Reservation Section -->

  </main>




<style>
.course-reservation {
  padding: 60px 0;
}

.course-gallery .course-image {
  width: 100%;
  height: 400px;
  object-fit: cover;
  border-radius: 10px;
}

.course-features {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 10px;
}

.course-features .feature-item {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.course-features .feature-item:last-child {
  margin-bottom: 0;
}

.course-features .feature-item i {
  font-size: 24px;
  color: #007bff;
  margin-right: 15px;
}

.reservation-form-wrapper {
  background: #fff;
  padding: 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
}

.course-price-container {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 10px;
  margin-bottom: 25px;
}

.current-price {
  font-size: 28px;
  font-weight: bold;
  color: #007bff;
}

.original-price {
  font-size: 18px;
  text-decoration: line-through;
  color: #6c757d;
  margin-left: 10px;
}

.discount-badge {
  background: #dc3545;
  color: white;
  padding: 5px 10px;
  border-radius: 5px;
  font-size: 12px;
  margin-left: 10px;
}

.date-picker-container {
  position: relative;
}

.date-picker-container input {
  width: 100%;
  padding: 12px 45px 12px 12px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  background: white;
}

.date-picker-container input:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.date-picker-icon {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
  font-size: 18px;
  pointer-events: none;
}

.time-slots-container {
  min-height: 120px;
}

.no-slots-message {
  text-align: center;
  padding: 40px 20px;
  color: #6c757d;
}

.no-slots-message i {
  font-size: 48px;
  margin-bottom: 15px;
}

.time-slot {
  display: inline-block;
  margin: 5px;
  padding: 10px 15px;
  border: 2px solid #e9ecef;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s;
  background: white;
}

.time-slot:hover {
  border-color: #007bff;
  background: #f8f9fa;
}

.time-slot.selected {
  border-color: #007bff;
  background: #007bff;
  color: white;
}

.time-slot.unavailable {
  background: #f8f9fa;
  color: #6c757d;
  cursor: not-allowed;
  opacity: 0.6;
}

.selected-info {
  background: #e7f3ff;
  border: 1px solid #007bff;
  border-radius: 10px;
  padding: 0;
}

.info-card {
  padding: 20px;
}

.info-card h6 {
  color: #007bff;
  margin-bottom: 15px;
  font-weight: bold;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  padding: 5px 0;
  border-bottom: 1px solid rgba(0,123,255,0.1);
}

.info-row:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.info-row .label {
  font-weight: 500;
}

.reservation-actions {
  display: flex;
  gap: 15px;
  margin-top: 25px;
}

.reservation-btn {
  flex: 1;
  padding: 15px;
  font-size: 16px;
  font-weight: bold;
  border-radius: 8px;
}

.reservation-btn:disabled {
  background: #6c757d;
  border-color: #6c757d;
}

.course-benefits {
  margin-top: 30px;
  padding-top: 30px;
  border-top: 1px solid #e9ecef;
}

.benefit-item {
  display: flex;
  align-items: center;
  margin-bottom: 15px;
}

.benefit-item i {
  font-size: 20px;
  color: #28a745;
  margin-right: 15px;
}

.benefit-item h6 {
  margin-bottom: 5px;
  color: #333;
}

.benefit-item p {
  margin: 0;
  color: #6c757d;
  font-size: 14px;
}

.course-difficulty {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  background: #e9ecef;
  color: #495057;
}

.badge {
  padding: 0.375rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 500;
  border-radius: 0.375rem;
}

.badge.bg-success {
  background-color: #198754 !important;
}

.badge.bg-warning {
  background-color: #ffc107 !important;
  color: #000 !important;
}

.badge.bg-danger {
  background-color: #dc3545 !important;
}

.badge.bg-secondary {
  background-color: #6c757d !important;
}

/* Flatpickr 커스텀 스타일 */
.flatpickr-calendar {
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border-radius: 12px;
  border: none;
  font-family: inherit;
}

.flatpickr-day {
  position: relative;
}

.available-slots {
  position: absolute;
  bottom: 2px;
  right: 2px;
  background: #007bff;
  color: white;
  font-size: 8px;
  border-radius: 50%;
  width: 12px;
  height: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}

.flatpickr-day.fully-booked {
  background: #ffeaa7 !important;
  color: #2d3436 !important;
}

.flatpickr-day.fully-booked .available-slots {
  background: #e17055;
}

.flatpickr-day.few-slots {
  background: #fab1a0 !important;
  color: #2d3436 !important;
}

.flatpickr-day.few-slots .available-slots {
  background: #e84393;
}

.flatpickr-day.many-slots {
  background: #a7f0ba !important;
  color: #2d3436 !important;
}

.flatpickr-day.many-slots .available-slots {
  background: #00b894;
}

.flatpickr-day.selected,
.flatpickr-day.selected:hover {
  background: #007bff !important;
  color: white !important;
}

.flatpickr-day.selected .available-slots {
  background: rgba(255, 255, 255, 0.8);
  color: #007bff;
}

/* 달력 범례 */
.calendar-legend {
  display: flex;
  justify-content: space-around;
  margin-top: 10px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 8px;
  font-size: 12px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 5px;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.legend-many { background: #a7f0ba; }
.legend-few { background: #fab1a0; }
.legend-full { background: #ffeaa7; }

/* 에러 메시지 및 빈 시간대 메시지 스타일 */
.no-slots-message {
    text-align: center;
    padding: 3rem 1rem;
    color: #6c757d;
}

.no-slots-message i {
    font-size: 3rem;
    margin-bottom: 1rem;
    opacity: 0.5;
}

.error-message {
    text-align: center;
    padding: 2rem 1rem;
    color: #dc3545;
    background-color: #f8d7da;
    border: 1px solid #f5c6cb;
    border-radius: 0.375rem;
    margin: 1rem 0;
}

.error-message i {
    font-size: 2rem;
    margin-bottom: 0.5rem;
}
</style>

<!-- Flatpickr JS -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOMContentLoaded 이벤트 발생');
  document.body.className = 'product-details-page';
    
    const dateInput = document.getElementById('reservationDate');
    const timeSlotContainer = document.getElementById('timeSlotContainer');
    const selectedInfo = document.getElementById('selectedInfo');
    const reservationBtn = document.querySelector('.reservation-btn');
    const courseSeq = document.getElementById('courseSeq').value;
    
    console.log('DOM 요소들 확인:', {
        dateInput: dateInput,
        timeSlotContainer: timeSlotContainer,
        selectedInfo: selectedInfo,
        reservationBtn: reservationBtn,
        courseSeq: courseSeq
    });
    
    let selectedTimeSlot = null;
    let flatpickrInstance = null;
    
    // 예약 가능한 날짜 로드 및 flatpickr 초기화
    initializeDatePicker();
    
    // 추가 디버깅: input 변경 이벤트 리스너
    dateInput.addEventListener('change', function() {
        console.log('dateInput change 이벤트:', this.value);
        if (this.value && this.value.trim() !== '') {
            console.log('input change에서 시간대 로드:', this.value);
            loadTimeSlots(this.value);
        }
    });
    
    dateInput.addEventListener('input', function() {
        console.log('dateInput input 이벤트:', this.value);
    });
    
    function initializeDatePicker() {
        console.log('initializeDatePicker 시작, courseSeq:', courseSeq);
        
        // 예약 가능한 날짜 목록 가져오기
        fetch(`/undongpedia/reservation/available-dates?courseSeq=\${courseSeq}`)
            .then(response => {
                console.log('available-dates 응답 상태:', response.status);
                return response.json();
            })
            .then(availableDates => {
                console.log('예약 가능한 날짜 수신:', availableDates);
                
                // flatpickr 초기화
                flatpickrInstance = flatpickr(dateInput, {
                    locale: 'ko',
                    dateFormat: 'Y-m-d',
                    minDate: 'today',
                    maxDate: new Date().fp_incr(90), // 90일 후까지
                    enable: availableDates.map(date => date.date), // 예약 가능한 날짜만 활성화
                    inline: false,
                    allowInput: false,
                    clickOpens: true,
                    theme: 'material_blue',
                    onReady: function(selectedDates, dateStr, instance) {
                        console.log('flatpickr onReady 호출됨');
                    },
                    onOpen: function(selectedDates, dateStr, instance) {
                        console.log('flatpickr onOpen 호출됨');
                    },
                    onChange: function(selectedDates, dateStr, instance) {
                        console.log('flatpickr onChange 호출됨:', {
                            selectedDates: selectedDates,
                            dateStr: dateStr,
                            inputValue: dateInput.value
                        });

                        if (dateStr && dateStr.trim() !== '') {
                            console.log('시간대 로드 호출:', dateStr);
                            loadTimeSlots(dateStr);
                        } else {
                            console.warn('onChange에서 빈 날짜 값:', dateStr);
                            // 시간대 컨테이너 초기화
                            timeSlotContainer.innerHTML = '';
                            selectedInfo.style.display = 'none';
                            reservationBtn.disabled = true;
                        }
                    },
                    onDayCreate: function(dObj, dStr, fp, dayElem) {
                        const dateStr = fp.formatDate(dayElem.dateObj, 'Y-m-d');
                        const availableDate = availableDates.find(d => d.date === dateStr);
                        
                        if (availableDate) {
                            // 예약 가능한 날짜에 표시
                            // dayElem.innerHTML += `<span class="available-slots">\${availableDate.totalSlots}</span>`;
                            
                            // 예약 가능한 좌석 수에 따라 스타일 다르게 적용
                            if (availableDate.availableSlots === 0) {
                                dayElem.classList.add('fully-booked');
                            } else if (availableDate.availableSlots <= 3) {
                                dayElem.classList.add('few-slots');
                            } else {
                                dayElem.classList.add('many-slots');
                            }
                        }
                    }
                });
                
                console.log('flatpickr 초기화 완료 (성공):', flatpickrInstance);
            })
            .catch(error => {
                console.error('예약 가능한 날짜 로드 오류:', error);
                // 오류 시 기본 flatpickr 초기화
                flatpickrInstance = flatpickr(dateInput, {
                    locale: 'ko',
                    dateFormat: 'Y-m-d',
                    minDate: 'today',
                    maxDate: new Date().fp_incr(90),
                    theme: 'material_blue',
                    onChange: function(selectedDates, dateStr, instance) {
                        console.log('flatpickr onChange 호출됨 (에러 시):', {
                            selectedDates: selectedDates,
                            dateStr: dateStr,
                            inputValue: dateInput.value
                        });
                        
                        if (dateStr && dateStr.trim() !== '') {
                            console.log('시간대 로드 호출 (에러 시):', dateStr);
                            loadTimeSlots(dateStr);
                        } else {
                            console.warn('onChange에서 빈 날짜 값 (에러 시):', dateStr);
                            timeSlotContainer.innerHTML = '';
                            selectedInfo.style.display = 'none';
                            reservationBtn.disabled = true;
                        }
                    }
                });
                
                console.log('flatpickr 초기화 완료 (에러 시):', flatpickrInstance);
            });
    }
    
    // 시간대 로드 함수
    function loadTimeSlots(date) {
      console.log("받은 날짜 :"+date);
        // 날짜 유효성 검증
        if (!date || date.trim() === '') {
            console.warn('날짜가 비어있습니다:', date);
            showNoSlotsMessage();
            return;
        }
        
        // 날짜 형식 검증 (YYYY-MM-DD)
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(date)) {
            console.warn('잘못된 날짜 형식:', date);
            showNoSlotsMessage();
            return;
        }
        
      console.log(`시간대 로드 시작: courseSeq=\${courseSeq}, date=\${date}`);
           
           // URL 생성 및 로깅
          const apiUrl = `/undongpedia/reservation/timeslots?courseSeq=\${courseSeq}&date=\${date}`;
         console.log('생성된 API URL:', apiUrl);
         console.log('courseSeq 값:', courseSeq, '타입:', typeof courseSeq);
         console.log('date 값:', date, '타입:', typeof date);
         
         // AJAX로 해당 날짜의 시간대 정보 가져오기
         fetch(apiUrl)
             .then(response => {
                 console.log('HTTP 응답 상태:', response.status);
                 console.log('HTTP 응답 URL:', response.url);
                 return response.json();
             })
             .then(data => {
                 console.log('시간대 데이터 수신:', data);
                 renderTimeSlots(data);
             })
             .catch(error => {
                 console.error('시간대 로드 오류:', error);
                 showNoSlotsMessage();
             });
    }
    
    // 시간대 렌더링
    function renderTimeSlots(timeSlots) {
        // 에러 응답 처리
        if (timeSlots && timeSlots.length === 1 && timeSlots[0].error) {
            timeSlotContainer.innerHTML = `
                <div class="error-message">
                    <i class="bi bi-exclamation-triangle"></i>
                    <p>\${timeSlots[0].error}</p>
                </div>
            `;
            return;
        }
        
        if (!timeSlots || timeSlots.length === 0) {
            showNoSlotsMessage();
            return;
        }
        
        let html = '<div class="time-slots-grid">';
        timeSlots.forEach(slot => {
            const remainingSeats = parseInt(slot.courseCapacity) - parseInt(slot.bookedSeats);
            const isAvailable = remainingSeats > 0;
            
            html += `
                <div class="time-slot \${isAvailable ? '' : 'unavailable'}"
                     data-slot='\${JSON.stringify(slot)}'
                     \${isAvailable ? '' : 'disabled'}
                     >
                    <div class="time-text">\${slot.courseStartTime} - \${slot.courseEndTime}</div>
                    <div class="capacity-text">\${remainingSeats}/\${slot.courseCapacity}</div>
                    <div class="location-text">\${slot.courseLocation}</div>
                </div>
            `;
        });
        html += '</div>';
        
        timeSlotContainer.innerHTML = html;
        
        // 시간대 클릭 이벤트 추가
        document.querySelectorAll('.time-slot:not(.unavailable)').forEach(slot => {
            slot.addEventListener('click', function() {
                selectTimeSlot(this);
            });
        });
    }
    
    // 시간대 없을 때 메시지
    function showNoSlotsMessage() {
        timeSlotContainer.innerHTML = `
            <div class="no-slots-message">
                <i class="bi bi-calendar-x"></i>
                <p>선택한 날짜에 이용 가능한 시간대가 없습니다.</p>
            </div>
        `;
    }
    
    // 시간대 선택
    function selectTimeSlot(element) {
        // 이전 선택 해제
        document.querySelectorAll('.time-slot.selected').forEach(slot => {
            slot.classList.remove('selected');
        });
        
        // 새로운 선택
        element.classList.add('selected');
        selectedTimeSlot = JSON.parse(element.dataset.slot);
        
        // 선택된 정보 업데이트
        updateSelectedInfo();
        
        // 예약 버튼 활성화
        reservationBtn.disabled = false;
    }
    
    // 선택된 정보 업데이트
    function updateSelectedInfo() {
        if (!selectedTimeSlot) return;
        
        const selectedDate = dateInput.value;
        const remainingSeats = parseInt(selectedTimeSlot.courseCapacity) - parseInt(selectedTimeSlot.bookedSeats);
        
        document.getElementById('selectedDateText').textContent = selectedDate;
        document.getElementById('selectedTimeText').textContent = 
            `\${selectedTimeSlot.courseStartTime} - \${selectedTimeSlot.courseEndTime}`;
        document.getElementById('selectedLocationText').textContent = selectedTimeSlot.courseLocation;
        document.getElementById('remainingSeats').textContent = `\${remainingSeats}석`;
        
        // 사이드 정보도 업데이트
        document.getElementById('selected-capacity').textContent = `\${selectedTimeSlot.courseCapacity}명`;
        document.getElementById('selected-location').textContent = selectedTimeSlot.courseLocation;
        document.getElementById('selected-duration').textContent = 
            `\${selectedTimeSlot.courseStartTime} - \${selectedTimeSlot.courseEndTime}`;
        
        selectedInfo.style.display = 'block';
    }
    
    // 예약 폼 제출
    document.getElementById('reservationForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (!selectedTimeSlot) {
            alert('시간대를 선택해주세요.');
            return;
        }
        
        const reservationData = {
            courseSeq: courseSeq,
            scheduleId: selectedTimeSlot.scheduleId,
            reservationDate: dateInput.value,
            courseStartTime: selectedTimeSlot.courseStartTime,
            courseEndTime: selectedTimeSlot.courseEndTime
        };
        
        // 예약 처리
        processReservation(reservationData);
    });
    
    // 예약 처리 함수
    function processReservation(data) {
        reservationBtn.disabled = true;
        reservationBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> 예약 중...';
        
        fetch('/undongpedia/reservation/book', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                // 🔥 임시예약 ID가 있으면 장바구니로 이동 (WebSocket 처리와 일관성)
                if (result.data && result.data.tempReservationId) {
                    alert('임시예약이 완료되었습니다! 장바구니로 이동합니다.');
                    window.location.href = '/undongpedia/cart';
                }
                // 대기열이 필요한 경우
                else if (result.queueRequired || result.message.includes('대기열')) {
                    showQueueModal(data);
                } else {
                    // 일반 예약 성공 - 장바구니로 이동
                    alert('강의 예약이 완료되었습니다! 장바구니로 이동합니다.');
                    window.location.href = '/undongpedia/cart';
                }
            } else {
                alert('강의 예약에 실패했습니다: ' + result.message);
                reservationBtn.disabled = false;
                reservationBtn.innerHTML = '<i class="bi bi-calendar-check"></i> 예약하기';
            }
        })
        .catch(error => {
            console.error('강의 예약 오류:', error);
            alert('강의 예약 처리 중 오류가 발생했습니다.');
            reservationBtn.disabled = false;
            reservationBtn.innerHTML = '<i class="bi bi-calendar-check"></i> 예약하기';
        });
    }

// 🔥 전역 스코프의 대기열 관련 변수 (최상위 레벨로 이동)
var queueWebSocket = null;
var queueHeartbeatInterval = null;
var queueStatusInterval = null;
var currentCourseSeq = null;
var currentScheduleId = null;
var currentMemberNo = null;

// 🔥 전역 함수들을 window 객체에 추가 (스코프 문제 해결)
window.queueWebSocket = null;
window.queueHeartbeatInterval = null;
window.queueStatusInterval = null;
window.currentCourseSeq = null;
window.currentScheduleId = null;
window.currentMemberNo = null;

// 🔥 강력한 모달 닫기 함수
function forceCloseQueueModal() {
    window.forceCloseQueueModal = function() {
    try {
        // 방법 1: Bootstrap Modal Instance로 닫기
        const modalElement = document.getElementById('queueModal');
        if (modalElement) {
            const modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) {
                modal.hide();
            }
        }
    } catch (e) {
        console.warn('모달 닫기 실패:', e);
    }
};
}
forceCloseQueueModal(); // 즉시 실행하여 window에 등록

// 🔥 대기열 완전 이탈 함수
window.leaveQueue = function() {
    if (confirm('대기열에서 나가시겠습니까?')) {
        console.log('🚪 대기열 나가기 시작...');
        
        // 1. 서버에 대기열 이탈 요청
        const contextPath = '<c:out value="${pageContext.request.contextPath}" />';
        fetch(contextPath + '/reservation/leave-schedule-queue', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                courseSeq: window.currentCourseSeq,
                scheduleId: window.currentScheduleId,
                memberNo: window.currentMemberNo
            })
        })
        .then(response => response.json())
        .then(data => {
            console.log('서버 대기열 이탈 응답:', data);
        })
        .catch(error => {
            console.error('서버 대기열 이탈 실패:', error);
        });
        
        // 2. 웹소켓 연결 해제 (재연결 방지)
        if (window.queueWebSocket) {
            try {
                window.queueWebSocket.onclose = null; // 재연결 방지
                window.queueWebSocket.close();
                window.queueWebSocket = null;
                console.log('🔌 WebSocket 연결 해제 (재연결 방지)');
            } catch (e) {
                console.warn('WebSocket 해제 실패:', e);
            }
        }
        
        // 3. 하트비트 정지
        if (window.queueHeartbeatInterval) {
            clearInterval(window.queueHeartbeatInterval);
            window.queueHeartbeatInterval = null;
        }
        
        // 4. 상태 폴링 정지
        if (window.queueStatusInterval) {
            clearInterval(window.queueStatusInterval);
            window.queueStatusInterval = null;
        }
        
        // 5. 모달 닫기
        window.forceCloseQueueModal();
        
        console.log('✅ 대기열 나가기 완료');
    }
};

    // 대기열 모달 표시
    function showQueueModal(reservationData) {
        window.currentCourseSeq = reservationData.courseSeq;
        window.currentScheduleId = reservationData.scheduleId;
        // 🔥 실제 로그인 사용자 정보 사용
        const loginMemberNo = '${loginMember.memberNo}';
        if (loginMemberNo && loginMemberNo !== '' && loginMemberNo !== 'null') {
            window.currentMemberNo = parseInt(loginMemberNo);
            console.log('✅ 로그인 사용자 - memberNo:', window.currentMemberNo);
        } else {
            // 비로그인 사용자 - 세션 스토리지에서 임시 ID 사용
            let tempMemberNo = sessionStorage.getItem('temp_member_no');
            if (!tempMemberNo) {
                tempMemberNo = parseInt(Date.now().toString().slice(-6) + Math.floor(Math.random() * 999).toString().padStart(3, '0'));
                sessionStorage.setItem('temp_member_no', tempMemberNo);
            }
            window.currentMemberNo = parseInt(tempMemberNo);
            console.log('🆔 비로그인 사용자 - 임시 memberNo:', window.currentMemberNo);
        }
        
        // 모달 표시
        const modal = new bootstrap.Modal(document.getElementById('queueModal'));
        modal.show();
        
        // WebSocket 연결 시작
        connectQueueWebSocket();
        
        // 하트비트 시작
        startQueueHeartbeat();
        
        // 첫 상태 조회 및 주기적 폴링 백업 (WebSocket 실패 시)
        checkModalQueueStatus();
        window.queueStatusInterval = setInterval(checkModalQueueStatus, 5000); // 5초마다 확인 (WebSocket 보조용)
    }

    // 대기열 웹소켓 연결
    function connectQueueWebSocket() {
        if (window.queueWebSocket && window.queueWebSocket.readyState === WebSocket.OPEN) {
            return; // 이미 연결됨
        }
        
        updateModalConnectionStatus('connecting');
        
        try {
            // courseSeq 값 검증
            if (!window.currentCourseSeq || window.currentCourseSeq === 'undefined' || window.currentCourseSeq === 'null') {
                console.error('❌ currentCourseSeq 값이 유효하지 않습니다:', window.currentCourseSeq);
                updateModalConnectionStatus('disconnected');
                return;
            }
            
            // 🔥 JSP EL을 별도 변수로 처리하여 URL 파싱 오류 방지
            const contextPath = '<c:out value="${pageContext.request.contextPath}" />';
            const wsUrl = 'ws://' + window.location.host + contextPath + '/queue-websocket?courseSeq=' + encodeURIComponent(window.currentCourseSeq) + '&memberNo=' + encodeURIComponent(window.currentMemberNo);
            console.log('🔌 대기열 WebSocket 연결 시도:', wsUrl);
            console.log('📋 변수값 확인 - host:', window.location.host, 'contextPath:', contextPath, 'currentCourseSeq:', window.currentCourseSeq, 'memberNo:', window.currentMemberNo);
            
            window.queueWebSocket = new WebSocket(wsUrl);
            
            window.queueWebSocket.onopen = function() {
                console.log('✅ 대기열 웹소켓 연결 성공');
                updateModalConnectionStatus('connected');
            };
            
            window.queueWebSocket.onmessage = function(event) {
                const data = JSON.parse(event.data);
                console.log('📨 대기열 웹소켓 메시지:', data);
                handleModalWebSocketMessage(data);
            };
            
            window.queueWebSocket.onclose = function(event) {
                console.log('❌ 대기열 웹소켓 연결 종료 - 코드:', event.code, '이유:', event.reason);
                updateModalConnectionStatus('disconnected');
                // 재연결 시도
                setTimeout(connectQueueWebSocket, 3000);
            };
            
            window.queueWebSocket.onerror = function(error) {
                console.error('🚨 대기열 웹소켓 오류:', error);
                updateModalConnectionStatus('disconnected');
            };
            
        } catch (error) {
            console.error('🚨 대기열 웹소켓 연결 실패:', error);
            updateModalConnectionStatus('disconnected');
        }
    }

    // 모달 WebSocket 메시지 처리
    function handleModalWebSocketMessage(data) {
        console.log('모달 WebSocket 메시지 처리:', data);
        
        switch(data.type) {
            case 'connected':
                console.log('✅ WebSocket 연결 확인:', data.message);
                break;
                
            case 'queue_update':
                // 서버에서 {type:'queue_update', data:{...}} 형태로 보내므로 data.data 사용
                updateModalQueueUI(data.data || data);
                break;
                
            case 'temp_reservation_success':
                handleModalTempReservationSuccess(data);
                break;
                
            case 'temp_reservation_failed':
                handleModalTempReservationFailed(data);
                break;
                
            case 'reservation_success':
                // 기존 호환성 - 장바구니로 이동
                alert(data.message + ' 장바구니로 이동합니다.');
                window.location.href = '<c:out value="${pageContext.request.contextPath}" />/cart';
                break;
                
            default:
                // 기본 데이터 형식 (기존 호환성)
                updateModalQueueUI(data.data || data);
        }
    }

    /**
     * 모달에서 임시예약 성공 처리
     */
    function handleModalTempReservationSuccess(data) {
        console.log('모달 임시예약 성공:', data);
        
        // 모든 타이머와 WebSocket 정리
        if (window.queueHeartbeatInterval) {
            clearInterval(window.queueHeartbeatInterval);
        }
        if (window.queueStatusInterval) {
            clearInterval(window.queueStatusInterval);
        }
        if (window.queueWebSocket) {
            window.queueWebSocket.onclose = null; // 재연결 방지
            window.queueWebSocket.close();
            window.queueWebSocket = null;
        }
        
        // 모달 닫기
        const modal = bootstrap.Modal.getInstance(document.getElementById('queueModal'));
        if (modal) modal.hide();
        
        // 장바구니에 추가
        const contextPath = '<c:out value="${pageContext.request.contextPath}" />';
        $.ajax({
            url: contextPath + '/cart/add-offline',
            type: 'POST',
            data: {
                tempReservationId: data.tempReservationId,
                scheduleId: data.scheduleId,
                courseSeq: data.courseSeq
            },
            success: function(response) {
                if (response.success) {
                    alert('임시예약이 완료되었습니다! 장바구니로 이동합니다.');
                    window.location.href = contextPath + '/cart';
                } else {
                    alert('장바구니 추가 실패: ' + response.message);
                    // 실패 시에도 장바구니로 이동 (사용자 편의)
                    window.location.href = contextPath + '/cart';
                }
            },
            error: function(xhr, status, error) {
                console.error('장바구니 추가 요청 실패:', error);
                alert('장바구니 추가 중 오류가 발생했습니다.');
                // 오류 시에도 장바구니로 이동
                window.location.href = contextPath + '/cart';
            }
        });
    }

    /**
     * 모달에서 임시예약 실패 처리
     */
    function handleModalTempReservationFailed(data) {
        console.log('모달 임시예약 실패:', data);
        alert('임시예약에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
        
        // 대기열 UI 업데이트 (다시 대기 상태로)
        if (data.queueData) {
            updateModalQueueUI(data.queueData);
        }
    }

    // 모달 연결 상태 업데이트
    function updateModalConnectionStatus(status) {
        const dot = document.getElementById('modalConnectionDot');
        const text = document.getElementById('modalConnectionText');
        
        if (dot && text) {
            dot.className = 'connection-dot ' + status;
            
            switch(status) {
                case 'connected':
                    text.textContent = '연결됨';
                    break;
                case 'connecting':
                    text.textContent = '연결 중...';
                    break;
                case 'disconnected':
                    text.textContent = '연결끊김';
                    break;
            }
        }
    }

    // 모달 대기열 UI 업데이트
    function updateModalQueueUI(queueData) {
        console.log('대기열 UI 업데이트:', queueData);
        
        // 현재 순서
        const positionEl = document.getElementById('modalPosition');
        if (positionEl) positionEl.textContent = queueData.position || '-';
        
        // 총 대기인원
        const totalEl = document.getElementById('modalTotalWaiting');
        if (totalEl) totalEl.textContent = (queueData.totalInQueue || 0) + '명';
        
        // 예상 대기시간
        const estimatedMinutes = Math.ceil((queueData.estimatedWaitTime || queueData.estimateWaitTime || queueData.estimatedTime || 0) / 60);
        const timeEl = document.getElementById('modalEstimatedTime');
        if (timeEl) timeEl.textContent = estimatedMinutes + '분';
        
        // 진행률 업데이트
        const total = queueData.totalInQueue || 1;
        const current = queueData.position || 1;
        const progress = total > 0 ? ((total - current + 1) / total) * 100 : 0;
        const progressEl = document.getElementById('modalProgress');
        if (progressEl) progressEl.style.width = Math.max(progress, 10) + '%'; // 최소 10%
        
        // 상태 메시지
        const statusMsg = document.getElementById('modalStatusMessage');
        if (statusMsg) {
            if (queueData.position === 1) {
                statusMsg.className = 'alert alert-warning';
                statusMsg.innerHTML = '잠시만요... 예약을 처리하고 있습니다.';
            } else {
                statusMsg.className = 'alert alert-info';
                statusMsg.innerHTML = queueData.position + '번째 순서입니다. 잠시만 기다려주세요.';
            }
        }
    }

    // 대기열 하트비트
    function startQueueHeartbeat() {
        window.queueHeartbeatInterval = setInterval(function() {
            const contextPath = '<c:out value="${pageContext.request.contextPath}" />';
            fetch(contextPath + '/reservation/heartbeat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    courseSeq: window.currentCourseSeq,
                    memberNo: window.currentMemberNo
                })
            }).catch(error => console.error('대기열 하트비트 실패:', error));
        }, 5000);
    }

    // 🔥 모달 스케줄 대기열 상태 확인 (폴링)
    function checkModalQueueStatus() {
        const contextPath = '<c:out value="${pageContext.request.contextPath}" />';
        
        // 💡 기존 API 사용하여 대기열 위치 확인
        fetch(contextPath + '/reservation/book', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                courseSeq: window.currentCourseSeq,
                scheduleId: window.currentScheduleId,
                memberNo: window.currentMemberNo
            })
        })
        .then(response => response.json())
        .then(data => {
            console.log('대기열 상태 응답:', data);
            if (data.success && data.data) {
                // 임시예약이 생성되었다면 장바구니로 이동
                if (data.data.tempReservationId) {
                    alert('임시예약이 완료되었습니다! 장바구니로 이동합니다.');
                    window.location.href = contextPath + '/cart';
                    return;
                }
                // 대기열 정보가 있다면 UI 업데이트
                updateModalQueueUI(data.data);
            }
        })
        .catch(error => {
            console.error('모달 대기열 상태 조회 실패:', error);
            // 에러 시에도 계속 폴링
            setTimeout(checkModalQueueStatus, 5000);
        });
    }

    // 실제 예약 진행
    function proceedToActualReservation() {
        // 모달 닫기
        const modal = bootstrap.Modal.getInstance(document.getElementById('queueModal'));
        if (modal) modal.hide();
        
        // 웹소켓 연결 해제
        if (window.queueWebSocket) {
            // 자동 재연결 방지
            try {
                window.queueWebSocket.onclose = null;
            } catch (e) {
                console.warn('WebSocket onclose 초기화 실패', e);
            }
            window.queueWebSocket.close();
            window.queueWebSocket = null;
            console.log('🔌 WebSocket 연결 해제 (재연결 방지)');
        }
        
        // 하트비트 정지
        if (window.queueHeartbeatInterval) {
            clearInterval(window.queueHeartbeatInterval);
        }
        
        // 상태 폴링 정지
        if (window.queueStatusInterval) {
            clearInterval(window.queueStatusInterval);
        }
        
        //  실제 예약 처리 (대기열 없이)
        const contextPath = '<c:out value="${pageContext.request.contextPath}" />';
        fetch(contextPath + '/reservation/book', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                courseSeq: window.currentCourseSeq,
                scheduleId: window.currentScheduleId,
                memberNo: window.currentMemberNo,
                skipQueue: true  // 대기열 스킵 플래그
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // 장바구니로 이동
                alert('예약이 완료되었습니다! 장바구니로 이동합니다.');
                window.location.href = contextPath + '/cart';
            } else {
                alert('예약 처리 실패: ' + data.message);
            }
        });
    }

    // 🔥 ESC키로 모달 닫기
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            const modal = document.getElementById('queueModal');
            if (modal && modal.classList.contains('show')) {
                if (confirm('ESC키로 대기열을 나가시겠습니까?')) {
                    leaveQueue();
                }
            }
        }
    });
});
</script>

<!-- 🔥 대기열 모달 -->
<div class="modal fade" id="queueModal" tabindex="-1" aria-labelledby="queueModalLabel" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="queueModalLabel">
                    <i class="bi bi-people"></i> 대기열
                </h5>
                <!-- 연결 상태 표시 -->
                <div class="ms-auto me-3">
                    <span id="modalConnectionDot" class="connection-dot connecting"></span>
                    <small id="modalConnectionText">연결 중...</small>
                </div>
                <!-- 대기열 나가기(✕) 버튼 -->
                <button type="button" class="btn-close btn-close-white" 
                        onclick="leaveQueue()" 
                        title="대기열 나가기"></button>
            </div>
            <div class="modal-body text-center py-4">
                <!-- 현재 순서 -->
                <div class="mb-4">
                    <div class="queue-position display-4 fw-bold text-primary" id="modalPosition">-</div>
                    <p class="text-muted mb-0">현재 순서</p>
                </div>

                <!-- 진행률 바 -->
                <div class="progress mb-4" style="height: 8px;">
                    <div id="modalProgress" class="progress-bar bg-success progress-bar-striped progress-bar-animated" 
                         style="width: 0%"></div>
                </div>

                <!-- 대기 정보 -->
                <div class="row text-center mb-4">
                    <div class="col-6">
                        <h5 id="modalTotalWaiting" class="text-primary">-</h5>
                        <small class="text-muted">총 대기</small>
                    </div>
                    <div class="col-6">
                        <h5 id="modalEstimatedTime" class="text-primary">-</h5>
                        <small class="text-muted">예상시간</small>
                    </div>
                </div>

                <!-- 상태 메시지 -->
                <div id="modalStatusMessage" class="alert alert-info">
                    대기열 상태를 확인하고 있습니다...
                </div>

                <!-- 안내 문구 -->
                <small class="text-muted">
                    <i class="bi bi-info-circle"></i>
                    창을 닫으면 대기열에서 제외됩니다
                </small>
            </div>
            <div class="modal-footer justify-content-center">
                <div class="text-center w-100 mb-3">
                    <small class="text-muted">
                        💡 <strong>모달 닫는 방법:</strong><br>
                        • 아래 "대기열 나가기" 버튼<br>
                        • 우상단 ✕ 버튼<br>
                        • ESC키 (확인 후 닫기)
                    </small>
                </div>
                <button type="button" class="btn btn-outline-secondary btn-lg" onclick="leaveQueue()">
                    <i class="bi bi-x-circle"></i> 대기열 나가기
                </button>
            </div>
        </div>
    </div>
</div>

<style>
.connection-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    display: inline-block;
    margin-right: 5px;
}

.connection-dot.connected { 
    background-color: #28a745; 
    animation: pulse 2s infinite;
}

.connection-dot.disconnected { 
    background-color: #dc3545; 
}

.connection-dot.connecting { 
    background-color: #ffc107; 
    animation: blink 1s infinite;
}

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.5; }
    100% { opacity: 1; }
}

@keyframes blink {
    0%, 50% { opacity: 1; }
    51%, 100% { opacity: 0.3; }
}

.queue-position {
    font-size: 3rem !important;
}
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>