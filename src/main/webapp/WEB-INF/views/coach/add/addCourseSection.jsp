<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/coach/common/header.jsp"/>
<!-- Content Wrapper -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>

<div id="content-wrapper" class="d-flex flex-column">

    <!-- Main Content -->
    <div id="content">
        <!-- Topbar -->
        <jsp:include page="/WEB-INF/views/coach/common/topbar.jsp"/>
        <div class="container-fluid">
            <div class="container-fluid">
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">코스 등록하기</h1>
                </div>
                <div class="row">
                    <div class="col-xl-12 col-lg-12">
                        <form action="coach/addCourseData" method="post" enctype="multipart/form-data" onsubmit="courseFormCheck()">
                        <div class="card shadow mb-4">
                            <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                                <h6 class="m-0 font-weight-bold text-primary">코스 정보 입력</h6>
                            </div>
                            <div class="card-body">
                                <div class="row no-gutters align-items-center mb-3">
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 제목
                                        </div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="text" class="form-control form-control-user"
                                                           name="courseTitle"
                                                           id="courseTitle"
                                                           placeholder="ex) 바른자세 하루 10분만 투자하세요!">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row no-gutters align-items-center mb-3">
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 내용
                                        </div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="text" class="form-control form-control-user"
                                                           name="courseContent"
                                                           id="courseContent"
                                                           placeholder="ex) 자세 교정이 필요하신 분! 이번 코스를 통해 ... ">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row no-gutters align-items-center mb-3">
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 카테고리
                                        </div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <select id="courseCategory" name="courseCategory"
                                                            class="form-control form-control-user">
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
                                                    <select id="sort-select" name="courseDifficult"
                                                            class="form-control form-control-user">
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
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">코스 가격
                                        </div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="number" class="form-control form-control-user"
                                                           min="0"
                                                           name="coursePrice" id="coursePrice" placeholder="가격을 입력하세요">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">할인율
                                        </div>
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
                                                    <input type="number" class="form-control form-control-user" id="priceResult" placeholder="판매 가격">
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
                                                    <label id="thumLabel" for="inputImage" class="thumbnail-upload-label form-control form-control-user">
                                                        썸네일을 등록하세요
                                                    </label>
                                                    <input class="form-control form-control-user" type="file" id="inputImage" accept="image/*" style="display: none"/>

                                                    <input type="hidden" name="croppedImageBase64" id="croppedImageBase64" />
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
                                                                <button class="btn btn-secondary" data-dismiss="modal">닫기</button>
                                                                <button class="btn btn-primary" id="cropButton">크롭 완료</button>
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
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">교육 대상
                                        </div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="text" class="form-control form-control-user"
                                                           name="courseTarget"
                                                           id="courseTarget"
                                                           placeholder="ex) 기초체력이 부족하신 분">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row no-gutters align-items-center mb-3">
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">준비물
                                        </div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="text" class="form-control form-control-user"
                                                           name="coursePreparation"
                                                           id="coursePreparation"
                                                           placeholder="ex) 폼롤러 등">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                                <div class="row no-gutters align-items-center mb-3 mt-5">
                                    <div class="col pl-3 pr-3">
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group d-flex justify-content-between">
                                                    <button class="btn btn-lg btn-outline-primary">임시 저장</button>
                                                    <button class="btn btn-lg btn-primary">다음 입력 단계</button>
                                                </div>
                                            </div>
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
        <script>let cropper;
        let croppedImageBlob = null;

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
                $('#exampleModal').modal('show'); // ← Bootstrap 모달 열기

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
            document.getElementById('croppedImageBase64').value = base64Image;
            document.getElementById('thumLabel').innerText = "썸네일 등록 완료!";

            $('#exampleModal').modal('hide');
        });

        function calculateDiscountedPrice() {
            const price = parseFloat($('#coursePrice').val()) || 0;
            const discount = parseFloat($('#courseDiscount').val()) || 0;

            const discountedPrice = Math.floor(price * (1 - discount / 100)); // 소수점 버림
            $('#priceResult').val(discountedPrice);
        }

        // 이벤트 연결
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
        const courseFormCheck = () => {
            const title = document.getElementById('courseTitle').value.trim();
            const content = document.getElementById('courseContent').value.trim();
            const category = document.getElementById('courseCategory').value;
            const price = document.getElementById('coursePrice').value;
            const discount = document.getElementById('courseDiscount').value;
            const croppedImage = document.getElementById('croppedImageBase64').value;

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

            if (!croppedImage) {
                alert("썸네일을 등록하고 크롭을 완료해주세요.");
                return false;
            }
            return true;
        };

        </script>

        <!-- End of Main Content -->
        <jsp:include page="/WEB-INF/views/coach/common/footer.jsp"/>
