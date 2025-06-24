<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">

<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>예약 시스템</title>

  <!-- Favicons -->
  <link href="/resources/assets/img/favicon.png" rel="icon">
  <link href="/resources/assets/img/apple-touch-icon.png" rel="apple-touch-icon">

  <!-- Fonts -->
  <link href="https://fonts.googleapis.com" rel="preconnect">
  <link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">

  <!-- Vendor CSS Files -->
  <link href="/resources/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="/resources/assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
  <link href="/resources/assets/vendor/aos/aos.css" rel="stylesheet">

  <!-- Main CSS File -->
  <link href="/resources/assets/css/main.css" rel="stylesheet">

  <style>
    .time-slot {
      border: 1px solid #ddd;
      padding: 15px;
      margin-bottom: 10px;
      border-radius: 5px;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    .time-slot:hover {
      background-color: #f8f9fa;
    }
    .time-slot.selected {
      background-color: #0d6efd;
      color: white;
      border-color: #0d6efd;
    }
    .time-slot.unavailable {
      background-color: #f8f9fa;
      cursor: not-allowed;
      opacity: 0.6;
    }
    .reservation-status {
      font-size: 0.9em;
      color: #6c757d;
    }
  </style>
</head>

<body>
  <main class="main">
    <!-- Page Title -->
    <div class="page-title light-background">
      <div class="container">
        <h1>예약하기</h1>
      </div>
    </div>

    <!-- Reservation Section -->
    <section id="reservation" class="section">
      <div class="container" data-aos="fade-up">
        <div class="row">
          <!-- Date Selection -->
          <div class="col-lg-6 mb-4">
            <div class="card">
              <div class="card-body">
                <h5 class="card-title">날짜 선택</h5>
                <input type="date" id="reservationDate" class="form-control" min="">
              </div>
            </div>
          </div>

          <!-- Time Slots -->
          <div class="col-lg-6">
            <div class="card">
              <div class="card-body">
                <h5 class="card-title">시간 선택</h5>
                <div id="timeSlots">
                  <div class="time-slot" data-time="10:00">
                    <h6>오전 10:00</h6>
                    <div class="reservation-status">
                      <span class="available-seats">예약 가능</span>
                    </div>
                  </div>
                  <div class="time-slot" data-time="14:00">
                    <h6>오후 2:00</h6>
                    <div class="reservation-status">
                      <span class="available-seats">예약 가능</span>
                    </div>
                  </div>
                  <div class="time-slot" data-time="18:00">
                    <h6>오후 6:00</h6>
                    <div class="reservation-status">
                      <span class="available-seats">예약 가능</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Reservation Summary -->
          <div class="col-12 mt-4">
            <div class="card">
              <div class="card-body">
                <h5 class="card-title">예약 정보</h5>
                <div class="row">
                  <div class="col-md-6">
                    <p><strong>선택한 날짜:</strong> <span id="selectedDate">-</span></p>
                    <p><strong>선택한 시간:</strong> <span id="selectedTime">-</span></p>
                  </div>
                  <div class="col-md-6 text-md-end">
                    <button id="reserveButton" class="btn btn-primary" disabled>
                      예약하기
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <!-- Vendor JS Files -->
  <script src="/resources/assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="/resources/assets/vendor/aos/aos.js"></script>

  <!-- Main JS File -->
  <script src="/resources/assets/js/main.js"></script>

  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // 오늘 날짜를 최소 날짜로 설정
      const today = new Date().toISOString().split('T')[0];
      document.getElementById('reservationDate').min = today;
      document.getElementById('reservationDate').value = today;

      // 시간대 선택 이벤트
      const timeSlots = document.querySelectorAll('.time-slot');
      timeSlots.forEach(slot => {
        slot.addEventListener('click', function() {
          if (!this.classList.contains('unavailable')) {
            timeSlots.forEach(s => s.classList.remove('selected'));
            this.classList.add('selected');
            document.getElementById('selectedTime').textContent = this.getAttribute('data-time');
            updateReservationButton();
          }
        });
      });

      // 날짜 선택 이벤트
      document.getElementById('reservationDate').addEventListener('change', function() {
        document.getElementById('selectedDate').textContent = this.value;
        updateReservationButton();
        checkAvailability(this.value);
      });

      // 예약하기 버튼 클릭 이벤트
      document.getElementById('reserveButton').addEventListener('click', function() {
        const date = document.getElementById('reservationDate').value;
        const time = document.querySelector('.time-slot.selected').getAttribute('data-time');
        
        fetch('/api/test/reservation', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            date: date,
            time: time
          })
        })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            alert('예약이 완료되었습니다.');
            checkAvailability(date);
          } else {
            alert(data.message || '예약에 실패했습니다.');
          }
        })
        .catch(error => {
          console.error('Error:', error);
          alert('예약 처리 중 오류가 발생했습니다.');
        });
      });

      // 예약 버튼 상태 업데이트
      function updateReservationButton() {
        const date = document.getElementById('selectedDate').textContent;
        const time = document.getElementById('selectedTime').textContent;
        const button = document.getElementById('reserveButton');
        
        button.disabled = date === '-' || time === '-';
      }

      // 예약 가능 여부 확인
      function checkAvailability(date) {
        fetch(`/api/test/reservation/status?date=${date}`)
          .then(response => response.json())
          .then(data => {
            timeSlots.forEach(slot => {
              const time = slot.getAttribute('data-time');
              const isReserved = data.some(reservation => reservation.time === time);
              
              if (isReserved) {
                slot.classList.add('unavailable');
                slot.classList.remove('selected');
                slot.querySelector('.reservation-status').innerHTML = '<span class="text-danger">예약 완료</span>';
              } else {
                slot.classList.remove('unavailable');
                slot.querySelector('.reservation-status').innerHTML = '<span class="text-success">예약 가능</span>';
              }
            });
            updateReservationButton();
          })
          .catch(error => {
            console.error('Error:', error);
          });
      }

      // 초기 예약 상태 확인
      checkAvailability(today);
    });
  </script>
</body>
</html> 