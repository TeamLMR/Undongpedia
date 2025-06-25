<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- Flatpickr CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
<section>
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
            <div class="course-details-accordion">
              <!-- Description Accordion -->
              <div class="accordion-item">
                <h2 class="accordion-header">
                  <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#description" aria-expanded="true" aria-controls="description">
                    강의 상세 설명
                  </button>
                </h2>
                <div id="description" class="accordion-collapse collapse show">
                  <div class="accordion-body">
                    <div class="course-description">
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
                      <p>달력 형태의 스케줄이 여기에 표시됩니다.</p>
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
</section>

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
</style>

<!-- Flatpickr JS -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const dateInput = document.getElementById('reservationDate');
    const timeSlotContainer = document.getElementById('timeSlotContainer');
    const selectedInfo = document.getElementById('selectedInfo');
    const reservationBtn = document.querySelector('.reservation-btn');
    const courseSeq = document.getElementById('courseSeq').value;
    
    let selectedTimeSlot = null;
    let flatpickrInstance = null;
    
    // 예약 가능한 날짜 로드 및 flatpickr 초기화
    initializeDatePicker();
    
    function initializeDatePicker() {
        // 예약 가능한 날짜 목록 가져오기
        fetch(`/undongpedia/reservation/available-dates?courseSeq=${courseSeq}`)
            .then(response => response.json())
            .then(availableDates => {
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
                    onChange: function(selectedDates, dateStr, instance) {
                        if (dateStr) {
                            loadTimeSlots(dateStr);
                        }
                    },
                    onDayCreate: function(dObj, dStr, fp, dayElem) {
                        const dateStr = fp.formatDate(dayElem.dateObj, 'Y-m-d');
                        const availableDate = availableDates.find(d => d.date === dateStr);
                        
                        if (availableDate) {
                            // 예약 가능한 날짜에 표시
                            dayElem.innerHTML += `<span class="available-slots">${availableDate.totalSlots}</span>`;
                            
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
                        if (dateStr) {
                            loadTimeSlots(dateStr);
                        }
                    }
                });
            });
    }
    
    // 시간대 로드 함수
    function loadTimeSlots(date) {
        // AJAX로 해당 날짜의 시간대 정보 가져오기
        fetch(`/undongpedia/reservation/timeslots?courseSeq=${courseSeq}&date=${date}`)
            .then(response => response.json())
            .then(data => {
                renderTimeSlots(data);
            })
            .catch(error => {
                console.error('시간대 로드 오류:', error);
                showNoSlotsMessage();
            });
    }
    
    // 시간대 렌더링
    function renderTimeSlots(timeSlots) {
        if (!timeSlots || timeSlots.length === 0) {
            showNoSlotsMessage();
            return;
        }
        
        let html = '<div class="time-slots-grid">';
        timeSlots.forEach(slot => {
            const remainingSeats = parseInt(slot.courseCapacity) - parseInt(slot.bookedSeats);
            const isAvailable = remainingSeats > 0;
            
            html += `
                <div class="time-slot ${isAvailable ? '' : 'unavailable'}" 
                     data-slot='${JSON.stringify(slot)}' 
                     ${isAvailable ? '' : 'disabled'}>
                    <div class="time-text">${slot.courseStartTime} - ${slot.courseEndTime}</div>
                    <div class="capacity-text">${remainingSeats}/${slot.courseCapacity}</div>
                    <div class="location-text">${slot.courseLocation}</div>
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
            `${selectedTimeSlot.courseStartTime} - ${selectedTimeSlot.courseEndTime}`;
        document.getElementById('selectedLocationText').textContent = selectedTimeSlot.courseLocation;
        document.getElementById('remainingSeats').textContent = `${remainingSeats}석`;
        
        // 사이드 정보도 업데이트
        document.getElementById('selected-capacity').textContent = `${selectedTimeSlot.courseCapacity}명`;
        document.getElementById('selected-location').textContent = selectedTimeSlot.courseLocation;
        document.getElementById('selected-duration').textContent = 
            `${selectedTimeSlot.courseStartTime} - ${selectedTimeSlot.courseEndTime}`;
        
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
                 alert('강의 예약이 완료되었습니다!');
                 // 예약 완료 페이지로 이동 또는 상태 업데이트
                 window.location.href = '/undongpedia/reservation/complete/' + result.reservationId;
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
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>