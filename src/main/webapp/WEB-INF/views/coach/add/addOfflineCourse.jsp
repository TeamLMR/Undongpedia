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

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">썸네일 설정</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <label id="thumbLabel" for="inputImage" class="col-3 thumbnail-upload-label form-control form-control-user"
                                   style="height: 10vw; display: flex; justify-content: center;align-items: center;">
                              썸네일을 등록하세요
                            </label>
                            <input class="form-control form-control-user" type="file" id="inputImage" accept="image/*" style="display: none"/>
                            <input type="hidden" name="courseThumbnail" id="courseThumbnail"/>
                          </div>
                          <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
                               aria-hidden="true">
                            <div class="modal-dialog modal-lg" role="document">
                              <div class="modal-content">
                                <div class="modal-header">
                                  <h5 class="modal-title">이미지 크롭</h5>
                                  <button class="close" type="button" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                  </button>
                                </div>
                                <div class="modal-body text-center" style="overflow: hidden">
                                  <img id="imagePreview" style="width: 100%; max-height: 500px;" />
                                </div>
                                <div class="modal-footer">
                                  <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
                                  <button type="button" class="btn btn-primary" id="cropButton">크롭 완료</button>
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">교육 대상</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="text" class="form-control form-control-user"
                                   name="courseTarget" id="courseTarget"
                                   placeholder="ex) 기초체력이 부족하신 분">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  
                  <div class="row no-gutters align-items-center mb-3">
                    <div class="col pl-3 pr-3">
                      <div class="text-lg font-weight-bold text-info text-uppercase mb-1">준비물</div>
                      <div class="row no-gutters align-items-center">
                        <div class="col">
                          <div class="form-group">
                            <input type="text" class="form-control form-control-user"
                                   name="coursePreparation" id="coursePreparation"
                                   placeholder="ex) 편한 운동복, 수건, 물병">
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
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
                        <div class="col-md-2">
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
                            <option value="3" selected>수요일</option>
                            <option value="4">목요일</option>
                            <option value="5">금요일</option>
                            <option value="6">토요일</option>
                            <option value="7">일요일</option>
                          </select>
                        </div>
                        <div class="col-md-2">
                          <label class="font-weight-bold">시작 시간</label>
                          <input type="time" name="schedules[0].startTime" class="form-control form-control-sm" value="19:00">
                        </div>
                        <div class="col-md-2">
                          <label class="font-weight-bold">종료 시간</label>
                          <input type="time" name="schedules[0].endTime" class="form-control form-control-sm" value="20:00">
                        </div>
                        <div class="col-md-2">
                          <label class="font-weight-bold">시작 날짜</label>
                          <input type="date" name="schedules[0].startDate" class="form-control form-control-sm">
                        </div>
                        <div class="col-md-2">
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
    <script src="https://cdn.ckeditor.com/ckeditor5/39.0.1/classic/ckeditor.js"></script>
    <script>
      ClassicEditor
        .create(document.querySelector('#courseContent'),
          {
            ckfinder: {
              uploadUrl: '${pageContext.request.contextPath}/coach/upload/editorImage'
            }
          })
        .catch(error => {
          console.error(error);
        });

      let cropper;
      let croppedImageBlob = null;
      let scheduleIndex = 1;

      const input = document.getElementById('inputImage');
      const image = document.getElementById('imagePreview');

      // 이미지 선택 시 모달 열기 + Cropper 적용
      input.addEventListener('change', function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (event) {
          image.src = event.target.result;

          // 모달 먼저 띄운 뒤 cropper 적용
          $('#exampleModal').modal('show');

          // Cropper 적용은 이미지가 실제로 DOM에 나타난 후에 해야 함
          $('#exampleModal').on('shown.bs.modal', function () {
            if (cropper) {
              cropper.destroy();
            }
            cropper = new Cropper(image, {
              aspectRatio: 16 / 9,
              viewMode: 1,
            });
          });
        };
        reader.readAsDataURL(file);
      });

      // 크롭 버튼 눌렀을 때
      document.getElementById('cropButton').addEventListener('click', function () {
        if (!cropper) return;

        const canvas = cropper.getCroppedCanvas();
        // base64 데이터 생성
        const base64Image = canvas.toDataURL('image/jpeg');

        // hidden input에 base64 문자열 저장
        document.getElementById('courseThumbnail').value = base64Image;
        document.getElementById('thumbLabel').innerHTML =`<img class='h-100' src='\${base64Image}'>`;
        $('#exampleModal').modal('hide');
      });

      // 가격 계산
      function calculateDiscountedPrice() {
        const price = parseFloat($('#coursePrice').val()) || 0;
        const discount = parseFloat($('#courseDiscount').val()) || 0;
        const discountedPrice = Math.floor(price * (1 - discount / 100));
        $('#priceResult').val(discountedPrice);
      }

      $('#coursePrice, #courseDiscount').on('input', function (){
        const price = $('#coursePrice');
        if(price.val() < 0){
          price.val(0);
          alert("양수만 입력 가능합니다.");
        }
        const discount = $('#courseDiscount');
        if(discount.val() < 0 || discount.val() > 100) {
          discount.val(0);
          alert("0부터 100사이만 입력 가능합니다.")
        }
        calculateDiscountedPrice();
      });

      // 수강 인원 및 수업 시간 유효성 검사
      $('#maxParticipants').on('input', function() {
        const participants = $(this).val();
        if(participants < 1 || participants > 50) {
          $(this).val(10);
          alert("수강 인원은 1~50명 사이로 입력해주세요.");
        }
      });

      $('#courseDuration').on('input', function() {
        const duration = $(this).val();
        if(duration < 30 || duration > 300) {
          $(this).val(60);
          alert("수업 시간은 30~300분 사이로 입력해주세요.");
        }
      });

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
                        <div class="col-md-2">
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
                            <input type="time" name="schedules[${scheduleIndex}].startTime" class="form-control form-control-sm" value="19:00">
                        </div>
                        <div class="col-md-2">
                            <label class="font-weight-bold">종료 시간</label>
                            <input type="time" name="schedules[${scheduleIndex}].endTime" class="form-control form-control-sm" value="20:00">
                        </div>
                        <div class="col-md-2">
                            <label class="font-weight-bold">시작 날짜</label>
                            <input type="date" name="schedules[${scheduleIndex}].startDate" class="form-control form-control-sm">
                        </div>
                        <div class="col-md-2">
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

      // 폼 검증
      function offlineCourseFormCheck() {
        const title = document.getElementById('courseTitle').value.trim();
        const content = document.getElementById('courseContent').value.trim();
        const category = document.getElementById('courseCategory').value;
        const price = document.getElementById('coursePrice').value;
        const discount = document.getElementById('courseDiscount').value;
        const thumbnail = document.getElementById('courseThumbnail').value;
        const location = document.getElementById('courseLocation').value.trim();
        const maxParticipants = document.getElementById('maxParticipants').value;
        const duration = document.getElementById('courseDuration').value;

        if (!title) {
          alert("코스 제목을 입력해주세요.");
          document.getElementById('courseTitle').focus();
          return false;
        }

        if (!content) {
          alert("코스 내용을 입력해주세요.");
          document.getElementById('courseContent').focus();
          return false;
        }

        if (!category) {
          alert("코스 카테고리를 선택해주세요.");
          document.getElementById('courseCategory').focus();
          return false;
        }

        if (!price || parseInt(price) < 0) {
          alert("코스 가격을 0 이상으로 입력해주세요.");
          document.getElementById('coursePrice').focus();
          return false;
        }

        if (discount && (parseInt(discount) < 0 || parseInt(discount) > 100)) {
          alert("할인율은 0~100 사이로 입력해주세요.");
          document.getElementById('courseDiscount').focus();
          return false;
        }

        if (!thumbnail) {
          alert("썸네일을 등록해주세요.");
          return false;
        }

        // 오프라인 코스 전용 검증
        if (!location) {
          alert("수업 장소를 입력해주세요.");
          document.getElementById('courseLocation').focus();
          return false;
        }

        if (!maxParticipants || parseInt(maxParticipants) < 1 || parseInt(maxParticipants) > 50) {
          alert("최대 수강 인원을 1~50명 사이로 입력해주세요.");
          document.getElementById('maxParticipants').focus();
          return false;
        }

        if (!duration || parseInt(duration) < 30 || parseInt(duration) > 300) {
          alert("수업 시간을 30~300분 사이로 입력해주세요.");
          document.getElementById('courseDuration').focus();
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
  </div>
</div>