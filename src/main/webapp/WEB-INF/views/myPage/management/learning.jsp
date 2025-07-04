<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="container px-3 px-md-5 my-5">
    <h2 class="fw-bold mb-5">내 학습</h2>

    <c:if test="${not empty myCourse}">
        <c:forEach var="c" items="${myCourse}">
            <div class="position-relative mb-5">
                <!-- 배지 -->
<%--                <div class="position-absolute top-0 start-0 translate-middle-y bg-white px-3 py-1 small text-muted border rounded">--%>
<%--                    주문번호 ${paymentId} · 주문일--%>
<%--                    <fmt:formatDate value="${groupedOrders[0].createdAt}" pattern="yyyy.MM.dd" />--%>
<%--                </div>--%>
                <!-- 묶인 주문 카드 -->
                <div class="border rounded-3 bg-white p-4 pt-5 shadow-sm row">
                    <div class="col-12">
                        <div class="d-flex justify-content-start mb-3">
                            <c:choose>
                                <c:when test="${c.COURSE_TYPE eq 'ON'}">
                                    <span class="btn btn-success btn-sm m-1">온라인</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="btn btn-primary btn-sm m-1">오프라인</span>
                                </c:otherwise>
                            </c:choose>
                            <c:choose>
                                <c:when test="${c.PROGRESS > 0}">
                                    <span class="btn btn-sm btn-outline-primary  m-1">진행 중</span>
                                </c:when>
                                <c:when test="${c.PROGRESS == c.CURR_COUNT && c.CURR_COUNT != 0}">
                                    <span class="btn btn-sm btn-outline-success m-1">진행 완료</span>
                                </c:when>
                                <c:otherwise >
                                    <span class="btn btn-sm btn-outline-secondary m-1">진행 전</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="row mb-4">
                            <div class="col-4">
                                <img class="w-100" src="${pageContext.request.contextPath}${c.COURSE_THUMBNAIL}"/>
                            </div>
                            <div class="col-8">
                                <h4>${c.COURSE_TITLE}</h4>
                                <h6>
                                    진행도 ( ${c.PROGRESS} / ${c.CURR_COUNT} )
                                </h6>
                                <div class="progress mb-4">
                                    <c:choose>
                                        <c:when test="${c.PROGRESS > 0 && c.CURR_COUNT > 0}">
                                            <c:set var="p_width" value="${(c.PROGRESS * 100/c.CURR_COUNT)}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="p_width" value="0"/>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="progress-bar bg-warning" role="progressbar" style="width: ${p_width}%"
                                         aria-valuenow="20" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-end">
                                    <c:choose>
                                        <c:when test="${c.COURSE_TYPE=='ON'}">
                                            <button onclick="location.assign('${pageContext.request.contextPath}/course/detail?courseSeq=${c.COURSE_SEQ}')" class="m-1 btn btn-outline-primary">강의정보</button>
                                            <button onclick="location.assign('${pageContext.request.contextPath}/course/viewer?courseSeq=${c.COURSE_SEQ}')" class="m-1 btn btn-primary">강의듣기</button>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </c:if>

    <c:if test="${empty myCourse}">
        <div class="text-center text-muted py-5">
            <i class="bi bi-receipt fs-1 mb-3 d-block"></i>
            <p class="mb-0">신청한 강의가 없습니다.</p>
        </div>
    </c:if>
</div>


<script>
</script>
