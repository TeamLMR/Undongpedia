<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/coach/common/header.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>
<style>
    .addCurriculumBtn:hover {
        background-color: #efefef;
    }
</style>
<div id="content-wrapper" class="d-flex flex-column">

    <div id="content">
        <jsp:include page="/WEB-INF/views/coach/common/topbar.jsp"/>
        <div class="container-fluid">
            <div class="container-fluid">
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">커리큘럼 등록하기</h1>
                </div>
                <div class="row">
                    <div class="col-xl-12 col-lg-12">
                        <c:if test="${not empty sectionList}">
                            <c:forEach var="section" items="${sectionList}">
                                <div class="card shadow mb-4">
                                    <input type="hidden" value="${section.sectionSeq}" id="sectionSeq${section.sectionSeq}">
                                    <div class="card-body">
                                        <div class="row no-gutters align-items-center mb-3">
                                            <div class="col pl-3 pr-3">
                                                <div class="text-lg font-weight-bold text-info text-uppercase mb-1">${section.sectionTitle}</div>
                                                <div class="row no-gutters align-items-center">${section.sectionContent}</div>
                                            </div>
                                        </div>
                                        <div class="row no-gutters align-items-center mb-3">
                                            <c:if test="${not empty section.curriculums}">
                                                <c:forEach var="cur" items="${section.curriculums}">
                                                    <c:if test="${cur.currSeq!=null}">
                                                        <c:set var="currOrder" value="${section.curriculums.size()}"/>
                                                        <div class="col p-3">
                                                            ${cur.currTitle}
                                                        </div>
                                                        <div class="col p-3">
                                                            <c:if test='${cur.currVideoType == "UPLOAD"}'>
                                                                <video controls style="max-width: 100%; height: auto;">
                                                                    <source src="${pageContext.request.contextPath}${cur.currVideoUrl}" type="video/mp4">
                                                                    브라우저가 비디오를 지원하지 않습니다.
                                                                </video>
                                                            </c:if>
                                                        </div>
                                                        <div class="col p-3">${cur.currPreview}</div>




                                                    </c:if>
                                                    <c:if test="${cur.currSeq==null}">
                                                        <c:set var="currOrder" value="0"/>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                        </div>
                                        <div class="row no-gutters align-items-center mb-3 addCurriculumBtn"
                                             style="border: lightgray dashed 1px;border-radius: 10px">
                                            <div class="col p-3">
                                                <input type="hidden" name="sectionListOrder" value="${currOrder}"/>
                                                <input type="hidden" name="sectionNo" value="${section.sectionSeq}">
                                                <i class="bi bi-plus-circle-fill"></i> 커리큘럼을 등록해 주세요
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:if>
                        <c:if test="${empty sectionList}">
                            <input type="hidden" class="sectionListOrder" value="0">
                            <div class="card shadow mb-4">
                                <div class="card-body">
                                    섹션이 없습니다. 아래에서 추가해주세요.
                                </div>
                            </div>
                        </c:if>
                        <div class="card shadow mb-4">
                            <div class="card-body">
                                <div class="row no-gutters align-items-center mb-3">
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">섹션 제목</div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="text" class="form-control form-control-user"
                                                           name="addSectionTitle"
                                                           id="addSectionTitle"
                                                           placeholder="ex) 오리엔테이션">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row no-gutters align-items-center mb-3">
                                    <div class="col pl-3 pr-3">
                                        <div class="text-lg font-weight-bold text-info text-uppercase mb-1">섹션 내용</div>
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group">
                                                    <input type="text" class="form-control form-control-user"
                                                           name="assSectionContent"
                                                           id="addSectionContent"
                                                           placeholder="ex) 강의에 대한 전반적인 설명... ">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row no-gutters align-items-center mb-3 mt-5">
                                    <div class="col pl-3 pr-3">
                                        <div class="row no-gutters align-items-center">
                                            <div class="col">
                                                <div class="form-group d-flex justify-content-end">
                                                    <button class="btn btn-lg btn-primary" onclick="addSection()">섹션
                                                        추가
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
        <div class="modal fade" id="addCurriculumModal" tabindex="-1" role="dialog" aria-labelledby="addCurriculumModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <form id="curriculumForm" action="${pageContext.request.contextPath}/coach/insertCurriculum" method="post"
                          enctype="multipart/form-data" onsubmit="return checkData()">
                        <input type="hidden" name="courseSeq" value="${tempCourseSeq}">
                        <div class="modal-header">
                            <h5 class="modal-title">커리큘럼 등록</h5>
                            <button class="close modalCloseAct" type="button" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="form-group text-center">
                                <img id="imagePreview" style="width: 100%; max-height: 300px; object-fit: cover;"/>
                            </div>

                            <div class="form-group">
                                <label for="currSeq">커리큘럼 번호</label>
                                <input type="text" class="form-control" id="currSeq" name="currSeq" placeholder="자동 생성" readonly>
                            </div>

                            <div class="form-group">
                                <label for="currTitle">커리큘럼 제목</label>
                                <input type="text" class="form-control" id="currTitle" name="currTitle" placeholder="예: 스쿼트 자세 배우기">
                            </div>

                            <div class="form-group">
                                <label for="currVideoType">영상 업로드 방식</label>
                                <select class="form-control" id="currVideoType" name="currVideoType">
                                    <option value="YOUTUBE">YouTube</option>
                                    <option value="UPLOAD">직접 업로드</option>
                                </select>
                            </div>
                            <div class="form-group" id="videoUrlGroup">
                                <label for="currVideoUrl">영상 URL</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="currVideoUrl" name="currVideoUrl" placeholder="예: https://youtube.com/...">
                                    <div class="input-group-append">
                                        <button type="button" class="btn btn-outline-primary" id="loadVideoBtn">연결하기</button>
                                    </div>
                                </div>
                            </div>

                            <div class="embed-responsive embed-responsive-16by9 mt-3 mb-3 d-none" id="videoUrlPreviewWrapper">
                                <iframe id="videoUrlPreview" class="embed-responsive-item" allowfullscreen></iframe>
                            </div>

                            <div class="form-group d-none" id="videoFileGroup">
                                <label>영상 파일 업로드</label>
                                <label for="currVideoFile" class="form-control text-center" id="videoFileLabel" style="cursor: pointer;">
                                    업로드 영상 선택
                                </label>
                                <input type="file" class="form-control-file" id="currVideoFile" name="currVideoFile" accept="video/*" style="display: none">
                                <div class="position-relative mt-2 d-none" id="videoPreviewWrapper">
                                    <button type="button" class="btn btn-sm btn-danger position-absolute" style="top: 0; right: 0; z-index: 2;" id="removeVideoButton">
                                        &times;
                                    </button>
                                    <video id="videoPreview" controls style="height: 15vw; border-radius: 0.5rem;">
                                        <source src="" type="video/mp4">
                                        브라우저가 비디오 태그를 지원하지 않습니다.
                                    </video>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="currPreview">미리보기 여부</label>
                                <select class="form-control" id="currPreview" name="currPreview">
                                    <option value="N">아니오</option>
                                    <option value="Y">예</option>
                                </select>
                            </div>

                                <input type="hidden" class="form-control" id="currOrder" name="currOrder">

                            <div class="form-group">
                                <input type="hidden" class="form-control" id="sectionSeq" name="sectionSeq" readonly>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary modalCloseAct" data-dismiss="modal">닫기</button>
                            <button type="submit" class="btn btn-primary" id="cropButton">등록 완료</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>


        <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>
        <script>
            const modalBtn = $(".addCurriculumBtn")
            const modal = $("#addCurriculumModal")

            modalBtn.on("click", function (e){
                const sectionInput = $(e.target).find("input[name='sectionNo']").val();
                const sectionListOrder = $(e.target).find("input[name='sectionListOrder']").val();
                $("#sectionSeq").val(sectionInput);
                $("#currOrder").val(sectionListOrder);
                modal.modal("show");
            })
            let cropper;
            let croppedImageBlob = null;

            const input = document.getElementById('inputImage');
            const image = document.getElementById('imagePreview');

            $('#currVideoType').on('change', function () {
                const selected = $(this).val();

                if (selected === 'YOUTUBE') {
                    $('#videoUrlGroup').removeClass('d-none');
                    $('#videoFileGroup').addClass('d-none');
                    $('#currVideoUrl').prop('disabled', false);
                    $('#currVideoFile').prop('disabled', true);
                } else if (selected === 'UPLOAD') {
                    $('#videoUrlGroup').addClass('d-none');
                    $('#videoFileGroup').removeClass('d-none');
                    $('#currVideoUrl').prop('disabled', true);
                    $('#currVideoFile').prop('disabled', false);
                }
            });
            $('#currVideoType').trigger('change');

            $('.modalCloseAct').on('click',function (){
                $('#currSeq').val('');
                $('#currTitle').val('');
                $('#currVideoType').val('YOUTUBE');
                $('#videoUrlGroup').removeClass('d-none');
                $('#videoFileGroup').addClass('d-none');
                $('#currVideoUrl').prop('disabled', false);
                $('#currVideoFile').prop('disabled', true);
                $('#videoPreview source').attr('src', '');
                $('#videoPreview')[0].load();
                $('#videoPreviewWrapper').addClass('d-none');
                $('#videoFileLabel').removeClass('d-none');
                $('#currPreview').val('N');
                $('#currOrder').val('');
                $('#sectionSeq').val('');
            });

            const addSection = () => {
                const title = $("#addSectionTitle").val();
                const content = $("#addSectionContent").val();
                const order = $(".sectionListOrder").val();
                const courseSeq = '${tempCourseSeq}';
                $.ajax({
                    url: "${pageContext.request.contextPath}/coach/ajaxAddSection",
                    type: "POST",
                    data: {sectionTitle: title, sectionContent: content, sectionOrder: order, courseSeq: courseSeq},
                    success: (response) => {
                        if (response > 0) {
                            location.assign("${pageContext.request.contextPath}/coach/addCourseSection?courseSeq=" + courseSeq);
                        } else {
                            alert("저장하는 중에 오류가 발생 했습니다. 다시 시도해 주세요")
                        }
                    },
                    errors: (response) => {
                        alert("저장하는 중에 오류가 발생 했습니다. 다시 시도해 주세요")
                    }
                });
            }
            $('#currVideoType').on('change', function () {
                const selected = $(this).val();

                if (selected === 'YOUTUBE') {
                    $('#videoUrlGroup').removeClass('d-none');
                    $('#videoFileGroup').addClass('d-none');
                    $('#currVideoUrl').prop('disabled', false);
                    $('#currVideoFile').val(''); // 파일 선택 초기화
                    $('#videoPreview source').attr('src', '');
                    $('#videoPreview')[0].load();
                    $('#videoPreviewWrapper').addClass('d-none');
                    $('#videoFileLabel').removeClass('d-none');
                } else if (selected === 'UPLOAD') {
                    $('#videoUrlGroup').addClass('d-none');
                    $('#videoFileGroup').removeClass('d-none');
                    $('#currVideoUrl').prop('disabled', true);
                    $('#currVideoFile').prop('disabled', false);
                }
            });
            $('#currVideoType').trigger('change');

            $('#currVideoFile').on('change', function (event) {
                const file = event.target.files[0];
                if (file && file.type.startsWith('video/')) {
                    const videoURL = URL.createObjectURL(file);

                    $('#videoPreview source').attr('src', videoURL);
                    $('#videoPreview')[0].load(); // video 태그 갱신
                    $('#videoPreviewWrapper').removeClass('d-none');
                    $('#videoFileLabel').addClass('d-none');
                }
            });
            // X 버튼 클릭 시 초기화
            $('#removeVideoButton').on('click', function () {
                $('#currVideoFile').val(''); // 파일 선택 초기화
                $('#videoPreview source').attr('src', '');
                $('#videoPreview')[0].load();
                $('#videoPreviewWrapper').addClass('d-none');
                $('#videoFileLabel').removeClass('d-none');
            });

            $('#loadVideoBtn').on('click', function () {
                const url = $('#currVideoUrl').val().trim();

                if (!url) {
                    alert('URL을 입력해주세요!');
                    return;
                }

                let embedUrl = '';

                // 유튜브 링크라면 임베드용으로 변환
                if (url.includes('youtube.com/watch?v=')) {
                    const videoId = new URL(url).searchParams.get("v");
                    embedUrl = "https://www.youtube.com/embed/"+videoId;
                } else if (url.includes('youtu.be/')) {
                    const videoId = url.split('youtu.be/')[1].split('?')[0];
                    embedUrl = "https://www.youtube.com/embed/"+videoId;
                } else {
                    alert('지원하지 않는 URL 형식입니다.');
                    return;
                }

                // iframe에 링크 삽입 + 애니메이션 등장
                $('#videoUrlPreview').attr('src', embedUrl);
                $('#videoUrlPreviewWrapper')
                    .hide()
                    .removeClass('d-none')
                    .fadeIn('slow');
            });

            const checkData = () =>{
                const title = document.getElementById("currTitle").value.trim();
                const videoType = document.getElementById("currVideoType").value;
                const videoUrl = document.getElementById("currVideoUrl").value.trim();
                const videoFile = document.getElementById("currVideoFile").files[0];
                const order = document.getElementById("currOrder").value.trim();

                if (title === "") {
                    alert("커리큘럼 제목을 입력해주세요.");
                    return false;
                }
                if (order === "" || isNaN(order)) {
                    alert("유효한 커리큘럼 순서를 입력해주세요.");
                    return false;
                }

                if (videoType === "YOUTUBE") {
                    if (videoUrl === "") {
                        alert("YouTube 영상 URL을 입력해주세요.");
                        return false;
                    }
                    const urlPattern = /^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$/;
                    if (!urlPattern.test(videoUrl)) {
                        alert("유효한 YouTube URL 형식이 아닙니다.");
                        return false;
                    }
                } else if (videoType === "UPLOAD") {
                    if (!videoFile) {
                        alert("영상 파일을 업로드해주세요.");
                        return false;
                    }
                }
                return true;
            }
        </script>

        <!-- End of Main Content -->
        <jsp:include page="/WEB-INF/views/coach/common/footer.jsp"/>
