<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/coach/common/header.jsp"/>
<!-- Content Wrapper -->
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>

<div id="content-wrapper" class="d-flex flex-column">

  <!-- Main Content -->
  <div id="content">
    <!-- Topbar -->
    <jsp:include page="/WEB-INF/views/coach/common/topbar.jsp"/>
    <div class="container-fluid">
      <div class="container-fluid">
        <div class="d-sm-flex align-items-center justify-content-between mb-4">
          <h1 class="h3 mb-0 text-gray-800">오프라인 코스 등록하기</h1>
        </div>
        <div class="row">
          <div class="col-xl-12 col-lg-12">
            <form action="${pageContext.request.contextPath}/coach/addOfflineCourseWithSchedule" method="post" onsubmit="return offlineCourseFormCheck()">
              <input type="hidden" name="memberNo" id="memberNo" value="${loginMember.memberNo}">
              <input type="hidden" name="courseType" value="OFFLINE">

              <!-- 코스 기본 정보 카드 -->
              <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                  <h6 class="m-0 font-weight-bold text-primary">코스 기본 정보</h6>
                </div>
                <div class="card-body">
                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 제목</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="text" class="form-control form-control-user"
                                   name="courseTitle" id="courseTitle"
                                   placeholder="ex) 바른자세 하루 10분만 투자하세요!">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 내용</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                                                    <textarea class="form-control" name="courseContent" id="courseContent"
                                                              rows="10" placeholder="ex) 자세 교정이 필요하신 분! 이번 코스를 통해 ..."></textarea>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 카테고리</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <select id="courseCategory" name="courseCategory" class="form-control form-control-user">
                              <option value="">선택하세요</option>
                              <c:if test="${not empty categories}">
                                <c:forEach var="c" items="${categories}">
                                  <option value="${c.cateSeq}">${c.cateValue}</option>
                                </c:forEach>
                              </c:if>
                            </select>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 난이도</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <select name="courseDifficult" class="form-control form-control-user">
                              <option value="1">⭐️ : 처음 배우신 분 추천</option>
                              <option value="2">⭐️⭐️ : 코스를 한 번 이상 이수한 멤버에게 추천</option>
                              <option value="3">⭐️⭐️⭐️ : 기본기가 능숙한 멤버에게 추천</option>
                              <option value="4">⭐️⭐️⭐️⭐️ : 6개월 이상 꾸준히 숙련된 멤버에게 추천</option>
                              <option value="5">⭐️⭐️⭐️⭐️⭐️ : 해당 운동 숙련자에게 추천</option>
                            </select>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 가격</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="number" class="form-control form-control-user" min="0"
                                   name="coursePrice" id="coursePrice" placeholder="가격을 입력하세요">
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">할인율</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="number" class="form-control form-control-user" min="0" max="100"
                                   name="courseDiscount" id="courseDiscount" placeholder="할인율 입력하세요"/>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">최종 판매 가격</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="number" class="form-control form-control-user" id="priceResult" placeholder="판매 가격" readonly>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">수업 장소</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="text" class="form-control form-control-user"
                                   name="courseLocation" id="courseLocation"
                                   placeholder="ex) 서울시 강남구 테헤란로 123 (2층 헬스장)">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">최대 수강 인원</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="number" class="form-control form-control-user" min="1" max="50"
                                   name="maxParticipants" id="maxParticipants" placeholder="ex) 10">
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">수업 시간 (분)</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="number" class="form-control form-control-user" min="30" max="300"
                                   name="courseDuration" id="courseDuration" placeholder="ex) 60">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 썸네일, 교육대상, 준비물 등 기존 필드들... (생략 가능) -->
                </div>
              </div>

              <!-- 스케줄 설정 카드 -->
              <div class="card shadow mb-4">
                <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                  <h6 class="m-0 font-weight-bold text-primary">수업 스케줄 설정</h6>
                  <button type="button" class="btn btn-sm btn-success" id="addScheduleBtn">
                    <i class="fas fa-plus"></i> 스케줄 추가
                  </button>
                </div>
                <div class="card-body">
                  <div id="scheduleContainer">
                    <!-- 기본 스케줄 입력 폼 -->
                    <div class="schedule-item border rounded p-3 mb-3" data-schedule-index="0">
                      <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="text-primary mb-0">스케줄 #1</h6>
                        <button type="button" class="btn btn-sm btn-outline-danger remove-schedule-btn" style="display: none;">
                          <i class="fas fa-trash"></i> 삭제
                        </button>
                      </div>

                      <div class="row">
                        <div class="col-md-3">
                          <label class="font-weight-bold">반복 패턴</label>
                          <select name="schedules[0].repeatType" class="form-control form-control-sm">
                            <option value="WEEKLY">매주</option>
                            <option value="BIWEEKLY">격주</option>
                            <option value="MONTHLY">매월</option>
                          </select>
                        </div>
                        <div class="col-md-2">
                          <label class="font-weight-bold">요일</label>
                          <select name="schedules[0].dayOfWeek" class="form-control form-control-sm">
                            <option value="1">월요일</option>
                            <option value="2">화요일</option>
                            <option value="3">수요일</option>
                            <option value="4">목요일</option>
                            <option value="5">금요일</option>
                            <option value="6">토요일</option>
                            <option value="7">일요일</option>
                          </select>
                        </div>
                        <div class="col-md-2">
                          <label class="font-weight-bold">시작 시간</label>
                          <input type="time" name="schedules[0].startTime" class="form-control form-control-sm" value="09:00">
                        </div>
                        <div class="col-md-2">
                          <label class="font-weight-bold">시작 날짜</label>
                          <input type="date" name="schedules[0].startDate" class="form-control form-control-sm">
                        </div>
                        <div class="col-md-3">
                          <label class="font-weight-bold">종료 날짜</label>
                          <input type="date" name="schedules[0].endDate" class="form-control form-control-sm">
                        </div>
                      </div>

                      <div class="row mt-2">
                        <div class="col-md-12">
                          <label class="font-weight-bold">스케줄 설명 (선택)</label>
                          <input type="text" name="schedules[0].description" class="form-control form-control-sm"
                                 placeholder="ex) 초급자 대상 기초반">
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="alert alert-info mt-3">
                    <i class="fas fa-info-circle"></i>
                    <strong>안내:</strong> 매주 반복되는 스케줄을 설정하면 자동으로 해당 기간 동안의 모든 수업 일정이 생성됩니다.
                    <br>예시: 매주 수요일 19:00, 2024-01-01 ~ 2024-03-31 설정 시 해당 기간의 모든 수요일에 수업이 생성됩니다.
                  </div>
                </div>
              </div>

              <!-- 제출 버튼 -->
              <div class="card shadow mb-4">
                <div class="card-body">
                  <div class="row no-gutters align-items-center">
                    <div class="col">
                      <div class="form-group d-flex justify-content-between">
                        <button type="button" class="btn btn-lg btn-outline-primary">임시 저장</button>
                        <button type="submit" class="btn btn-lg btn-primary">
                          <i class="fas fa-check"></i> 코스 및 스케줄 등록
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>
    <script>
      let scheduleIndex = 1;

      // 스케줄 추가 버튼 클릭
      document.getElementById('addScheduleBtn').addEventListener('click', function() {
        addScheduleItem();
      });

      function addScheduleItem() {
        const container = document.getElementById('scheduleContainer');
        const newScheduleHtml = `
                <div class="schedule-item border rounded p-3 mb-3" data-schedule-index="${scheduleIndex}">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="text-primary mb-0">스케줄 #${scheduleIndex + 1}</h6>
                        <button type="button" class="btn btn-sm btn-outline-danger remove-schedule-btn">
                            <i class="fas fa-trash"></i> 삭제
                        </button>
                    </div>

                    <div class="row">
                        <div class="col-md-3">
                            <label class="font-weight-bold">반복 패턴</label>
                            <select name="schedules[${scheduleIndex}].repeatType" class="form-control form-control-sm">
                                <option value="WEEKLY">매주</option>
                                <option value="BIWEEKLY">격주</option>
                                <option value="MONTHLY">매월</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="font-weight-bold">요일</label>
                            <select name="schedules[${scheduleIndex}].dayOfWeek" class="form-control form-control-sm">
                                <option value="1">월요일</option>
                                <option value="2">화요일</option>
                                <option value="3">수요일</option>
                                <option value="4">목요일</option>
                                <option value="5">금요일</option>
                                <option value="6">토요일</option>
                                <option value="7">일요일</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="font-weight-bold">시작 시간</label>
                            <input type="time" name="schedules[${scheduleIndex}].startTime" class="form-control form-control-sm" value="09:00">
                        </div>
                        <div class="col-md-2">
                            <label class="font-weight-bold">시작 날짜</label>
                            <input type="date" name="schedules[${scheduleIndex}].startDate" class="form-control form-control-sm">
                        </div>
                        <div class="col-md-3">
                            <label class="font-weight-bold">종료 날짜</label>
                            <input type="date" name="schedules[${scheduleIndex}].endDate" class="form-control form-control-sm">
                        </div>
                    </div>

                    <div class="row mt-2">
                        <div class="col-md-12">
                            <label class="font-weight-bold">스케줄 설명 (선택)</label>
                            <input type="text" name="schedules[${scheduleIndex}].description" class="form-control form-control-sm"
                                   placeholder="ex) 초급자 대상 기초반">
                        </div>
                    </div>
                </div>
            `;

        container.insertAdjacentHTML('beforeend', newScheduleHtml);
        scheduleIndex++;

        // 첫 번째 스케줄이 아니면 삭제 버튼 보이기
        updateDeleteButtons();
      }

      // 스케줄 삭제
      document.addEventListener('click', function(e) {
        if (e.target.closest('.remove-schedule-btn')) {
          const scheduleItem = e.target.closest('.schedule-item');
          scheduleItem.remove();
          updateDeleteButtons();
          reindexSchedules();
        }
      });

      function updateDeleteButtons() {
        const scheduleItems = document.querySelectorAll('.schedule-item');
        const deleteButtons = document.querySelectorAll('.remove-schedule-btn');

        if (scheduleItems.length > 1) {
          deleteButtons.forEach(btn => btn.style.display = 'inline-block');
        } else {
          deleteButtons.forEach(btn => btn.style.display = 'none');
        }
      }

      function reindexSchedules() {
        const scheduleItems = document.querySelectorAll('.schedule-item');
        scheduleItems.forEach((item, index) => {
          item.setAttribute('data-schedule-index', index);
          item.querySelector('h6').textContent = `스케줄 #${index + 1}`;

          // name 속성들 재설정
          const inputs = item.querySelectorAll('input, select');
          inputs.forEach(input => {
            const name = input.getAttribute('name');
            if (name && name.includes('schedules[')) {
              const newName = name.replace(/schedules\[\d+\]/, `schedules[${index}]`);
              input.setAttribute('name', newName);
            }
          });
        });
      }

      // 가격 계산
      function calculateDiscountedPrice() {
        const price = parseFloat($('#coursePrice').val()) || 0;
        const discount = parseFloat($('#courseDiscount').val()) || 0;
        const discountedPrice = Math.floor(price * (1 - discount / 100));
        $('#priceResult').val(discountedPrice);
      }

      $('#coursePrice, #courseDiscount').on('input', calculateDiscountedPrice);

      // 폼 검증
      function offlineCourseFormCheck() {
        const title = document.getElementById('courseTitle').value.trim();
        const location = document.getElementById('courseLocation').value.trim();
        const maxParticipants = document.getElementById('maxParticipants').value;

        if (!title) {
          alert("코스 제목을 입력해주세요.");
          return false;
        }

        if (!location) {
          alert("수업 장소를 입력해주세요.");
          return false;
        }

        if (!maxParticipants || parseInt(maxParticipants) < 1) {
          alert("최대 수강 인원을 입력해주세요.");
          return false;
        }

        // 스케줄 검증
        const scheduleItems = document.querySelectorAll('.schedule-item');
        for (let i = 0; i < scheduleItems.length; i++) {
          const startDate = scheduleItems[i].querySelector('input[name*="startDate"]').value;
          const endDate = scheduleItems[i].querySelector('input[name*="endDate"]').value;

          if (!startDate || !endDate) {
            alert(`스케줄 #${i + 1}의 시작/종료 날짜를 입력해주세요.`);
            return false;
          }

          if (new Date(startDate) >= new Date(endDate)) {
            alert(`스케줄 #${i + 1}의 종료 날짜는 시작 날짜보다 뒤여야 합니다.`);
            return false;
          }
        }

        return true;
      }

      // 오늘 날짜를 기본값으로 설정
      document.addEventListener('DOMContentLoaded', function() {
        const today = new Date().toISOString().split('T')[0];
        const nextMonth = new Date();
        nextMonth.setMonth(nextMonth.getMonth() + 3);
        const threeMonthsLater = nextMonth.toISOString().split('T')[0];

        document.querySelector('input[name="schedules[0].startDate"]').value = today;
        document.querySelector('input[name="schedules[0].endDate"]').value = threeMonthsLater;
      });

    </script>

    <!-- End of Main Content -->
<jsp:include page="/WEB-INF/views/coach/common/footer.jsp"/>