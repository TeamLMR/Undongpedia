<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/coach/common/header.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css"/>

<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<div id="content-wrapper" class="d-flex flex-column">
    <!-- Main Content -->
    <div id="content" >
        <!-- Topbar -->
        <jsp:include page="/WEB-INF/views/coach/common/topbar.jsp"/>
        <div class="container-fluid">
            <div class="container-fluid">
                <div class="d-sm-flex align-items-center justify-content-between mb-4">
                    <h1 class="h3 mb-0 text-gray-800">코스 관리</h1>
                </div>
                <%--content row--%>
                <div class="row">
                    <!-- Pie Chart -->
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
                            <div class="card-body ">
                                <c:if test="${not empty courseList}">
                                    <c:forEach var="course" items="${courseList}">
                                    <div class="row text-secondary-emphasis small text-sm-center p-3 justify-content-between align-items-center border-bottom ">
                                        <div class="col-5 d-flex justify-content-start">
                                            <div class="col-4 d-flex justify-content-start" style="width: 50px;">
                                                <img src="${pageContext.request.contextPath}${course.courseThumbnail}" alt="썸네일" class="object-fit-cover img-fluid rounded">
                                            </div>
                                            <div class="col-8 d-flex justify-content-start">
                                                    ${course.courseTitle}
                                            </div>
                                        </div>
                                        <div class="col-1">
                                                ${course.cateValue}
                                        </div>
                                        <div class="col-1">
                                                ${course.courseType}
                                        </div>
                                        <div class="col-2">
                                            <fmt:formatNumber value="${course.coursePrice - (course.coursePrice * course.courseDiscount / 100)}" type="number"/>
                                        </div>
                                        <div class="col-1">
                                            <fmt:formatDate value="${course.courseCreateTime}" pattern="yy-MM-dd hh:mm"/>
                                        </div>
                                        <div class="col-1">
                                            <fmt:formatDate value="${course.courseConfirmTime}" pattern="yy-MM-dd hh:mm"/>
                                        </div>
                                        <div class="col-1 d-flex flex-column">
                                            <div class="btn-outline-primary btn btn-sm mb-2 modifyButton" id="${course.courseSeq}">
                                                수정
                                            </div>
                                            <div class="btn-outline-danger btn btn-sm deleteButton" id="${course.courseSeq}">
                                                삭제
                                            </div>
                                        </div>
                                    </div>
                                    </c:forEach>
                                </c:if>
                                <c:if test="${empty courseList}">
                                    <div class="text-secondary text-sm text-center">
                                        등록한 코스가 없습니다.
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="modifyModal" tabindex="-1" aria-labelledby="confirmModalLabel" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="confirmModalLabel">알림</h5>
                    <button class="close modalCloseAct" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    해당 코스를 수정하시겠습니까?
                </div>

                <div class="modal-footer">
                    <form action="${pageContext.request.contextPath}/coach/modifycourse" method="post"  name="modifyForm">
                        <input type="hidden" value="" id="modifyCourseSeq" name="modifyCourseSeq">
                        <button type="button" class="btn btn-secondary modalCloseAct" data-dismiss="modal">닫기
                        </button>
                        <button type="submit" class="btn btn-primary">네</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="confirmModalLabel" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white bi-">
                    <h5 class="modal-title" id="confirmModalLabel">경고</h5>
                    <button class="close modalCloseAct" type="button" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    정말 해당 코스를 삭제하시겠습니까?
                </div>

                <div class="modal-footer">
                    <form action="${pageContext.request.contextPath}/coach/deletecourse" method="post" name="deleteForm">
                        <input type="hidden" value="" id="delCourseSeq" name="delCourseSeq">
                        <button type="button" class="btn btn-secondary modalCloseAct" data-dismiss="modal">닫기
                        </button>
                        <button type="submit" class="btn btn-danger">네</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function () {
            bindingEvent();
        });

        function bindingEvent() {
            $('.deleteButton').off('click').on('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                const selectedCourseId = $(this).attr("id");
                console.log(selectedCourseId);
                $('#delCourseSeq').val(selectedCourseId);
                $('#deleteModal').modal('show');
            });

            $('.modifyButton').off('click').on('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                const selectedCourseId = $(this).attr("id");
                console.log(selectedCourseId);
                $('#modifyCourseSeq').val(selectedCourseId);
                $('#modifyModal').modal('show');
            });
        }
    </script>

    <jsp:include page="/WEB-INF/views/coach/common/footer.jsp"/>
