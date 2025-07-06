<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/admin/common/header.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>

<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<div id="content-wrapper" class="d-flex flex-column">
    <!-- Main Content -->
    <div id="content">
        <!-- Topbar -->
        <jsp:include page="/WEB-INF/views/admin/common/topbar.jsp"/>
        <div class="container-fluid">
            <div class="container-fluid">
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">코스 승인</h1>
                    <select id="confirmStatus">
                        <option value="unconfirmed">미승인</option>
                        <option value="confirmed">승인</option>
                    </select>
                </div>
                <div class="row">
                    <div class="col-xl-12 col-lg-12">
                        <div class="card shadow mb-4">
                            <!-- Card Header - Dropdown -->
                            <div class="card-header  py-3 align-items-center justify-content-between">
                                <div class="row text-secondary small text-sm-center">
                                    <div class="col-5 d-flex justify-content-start">
                                        <div class="col-4 d-flex justify-content-start">
                                            썸네일
                                        </div>
                                        <div class="col-8 d-flex justify-content-start">
                                            제목
                                        </div>
                                    </div>
                                    <div class="col-1">
                                        카테고리
                                    </div>
                                    <div class="col-1">
                                        온/오프
                                    </div>
                                    <div class="col-2">
                                        가격
                                    </div>
                                    <div class="col-1">
                                        작성시간
                                    </div>
                                    <div class="col-1">
                                        승인시간
                                    </div>
                                    <div class="col-1 1 d-flex">
                                        수정/삭제
                                    </div>
                                </div>
                            </div>
                            <!-- Card Body -->
                            <div class="card-body" id="applyList">


                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel" role="dialog"
         aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 70%; !important;">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="detailModalLabel">알림</h5>
                    <button class="close modalCloseAct" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    <div id="courseDetailArea"></div>
                </div>

                <div class="modal-footer">
                    <form action="${pageContext.request.contextPath}/admin/course/apply/confirm" method="post" name="confirmForm" onsubmit="return confirmFromCheck()">
                        <input type="text" value="" id="confirmCourseSeq" name="confirmCourseSeq">
                        <button type="button" class="btn btn-secondary modalCloseAct" data-dismiss="modal">닫기
                        </button>
                        <button type="submit" class="btn btn-primary">승인하기</button>
                    </form>
                </div>
            </div>
        </div>
    </div>



<script>
    $(document).ready(function () {
        courseList();
    });

    function openDetailModal(courseSeq) {
        $('#confirmCourseSeq').val(courseSeq);
        $.ajax({
            url: "${pageContext.request.contextPath}/admin/course/apply/detail",
            type: "POST",
            data: {
                courseSeq: courseSeq
            },
            success: function (data) {
                // data 안에 course, sectionList가 있는 걸로 가정
                const course = data.course;
                const sections = data.sectionList;

                let html = '';

                html += '<h4>' + course.courseTitle + '</h4>';
                html += '<p><strong>카테고리:</strong> ' + course.cateValue + '</p>';
                html += '<p><strong>강사:</strong> ' + course.memberNickname + '</p>';
                html += '<p><strong>가격:</strong> ' + course.coursePrice + '원 (할인: ' + course.courseDiscount + '%)</p>';
                html += '<p><strong>노출 여부:</strong> ' + (course.courseExpose === 'Y' ? '노출' : '비노출') + '</p>';
                html += '<p><strong>등록일:</strong> ' + timeFormat(course.courseCreateTime) + '</p>';
                html += '<p><strong>대상:</strong> ' + course.courseTarget + '</p>';
                html += '<p><strong>준비물:</strong> ' + course.coursePreparation + '</p>';
                html += '<p><strong>코스 타입:</strong> ' + course.courseType + '</p>';
                html += '<p><strong>코스 소개:</strong></p>';
                html += '<div class="border p-2 mb-3" style="overflow:scroll"' + course.courseContent + '</div>';

                html += '<img src="${pageContext.request.contextPath}' + course.courseThumbnail + '" class="img-fluid mb-3" alt="썸네일"/>';

                html += '<hr><h5>섹션 및 커리큘럼</h5>';
                sections.forEach(function (section, i) {
                    html += '<div class="mb-3">';
                    html += '<h6>[' + (i + 1) + '] ' + section.sectionTitle + '</h6>';
                    html += '<p class="text-muted">' + section.sectionContent + '</p>';

                    if (section.curriculums && section.curriculums.length > 0 && section.curriculums[0].currTitle) {
                        html += '<ul>';
                        section.curriculums.forEach(function (curr) {
                            html += '<li><strong>' + curr.currTitle + '</strong>';
                            if (curr.currVideoType === 'YOUTUBE' && curr.currVideoUrl) {
                                const videoId = getYouTubeId(curr.currVideoUrl);
                                html += '<div class="ratio ratio-16x9"><iframe src="https://www.youtube.com/embed/'+videoId+'" frameborder="0" allowfullscreen></iframe></div>';
                            }else if(curr.currVideoType === 'UPLOAD' && curr.currVideoUrl) {
                                html += '<video controls style="width: 100%; max-height: 500px;"><source src="${pageContext.request.contextPath}'+curr.currVideoUrl+'" type="video/mp4">지원되지 않는 형식입니다.</video>';
                            }
                            html += '</li>';
                        });
                        html += '</ul>';
                    } else {
                        html += '<p class="text-secondary">등록된 커리큘럼이 없습니다.</p>';
                    }

                    html += '</div>';
                });
                document.getElementById("courseDetailArea").innerHTML = html;
                $('#detailModal').modal('show');
            },
            error: function () {
                alert('코스 상세 정보를 불러오는 데 실패했습니다.');
            }
        });
    }
    // 닫기 버튼 처리 (선택 사항, 이미 data-dismiss로 처리됨)
    $(document).on("click", ".modalCloseAct", function (e) {

        $('#detailModal').modal('hide');
    });

    $('#confirmStatus').on("change", function (){
        courseList();
    })

    function courseList() {
        let status = $('#confirmStatus').val();
        $.ajax({
            url: "${pageContext.request.contextPath}/admin/course/apply/list",
            type: "POST",
            data: {
                status : status
            },
            success: (response) => {
                let courseList = response.courseList;
                $("#applyList").html("");

                courseList.forEach(c =>{
                    let price = Math.ceil(c['coursePrice']-(c['coursePrice']*(c['courseDiscount']/100)));
                    let createTime = '';
                    let confirmTime = '';
                    if(c['courseCreateTime'] != null){
                        createTime = timeFormat(c['courseCreateTime']);
                    }

                    if(c['courseConfirmTime'] != null){
                        confirmTime = timeFormat(c['courseConfirmTime']);
                    }

                    let html =
                        '<div class="row text-secondary-emphasis small text-sm-center p-3 justify-content-between align-items-center border-bottom ">' +
                        '    <div class="col-5 d-flex justify-content-start">' +
                        '        <div class="col-4 d-flex justify-content-start" style="width: 50px;">' +
                        '            <img src="${pageContext.request.contextPath}'+c['courseThumbnail']+'" alt="썸네일" class="object-fit-cover img-fluid rounded">' +
                        '        </div>' +
                        '        <div class="col-8 d-flex justify-content-start align-items-center">'+c['courseTitle']+'</div>' +
                        '    </div>' +
                        '    <div class="col-1">'+c['cateValue']+'</div>' +
                        '    <div class="col-1">'+c['courseType']+'</div>' +
                        '    <div class="col-2">' + price +'</div>' +
                        '    <div class="col-1 small">' + createTime +'</div>' +
                        '    <div class="col-1 small">' + confirmTime +'</div>'+
                        '<div class="col-1 d-flex flex-column">' +
                        '<button type="button" class="btn btn-outline-primary" onclick="openDetailModal('+c['courseSeq']+')">상세보기</button>'+
                        '</div>' +
                        '</div>'
                    $("#applyList").append(html);
                })

            }
        });
    }

    function timeFormat(time){
        const date = new Date(time);

        const year = date.getFullYear();
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const day = date.getDate().toString().padStart(2, '0');

        const hours = date.getHours().toString().padStart(2, '0');
        const minutes = date.getMinutes().toString().padStart(2, '0');
        const seconds = date.getSeconds().toString().padStart(2, '0');

        return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;

    }
    function getYouTubeId(url) {
        const regExp = /(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i;
        const match = url.match(regExp);
        return match && match[1] ? match[1] : '';
    }

    function confirmFromCheck(){
        if(confirm("승인하시겠습니까?")){
            return true;
        }
        return false;
    }
</script>
<jsp:include page="/WEB-INF/views/admin/common/footer.jsp"/>