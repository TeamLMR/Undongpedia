<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>
<style>
    .video-container {
        padding: 10px;
        margin: auto;
    }
    .progress-bar-wrapper {
        background-color: #e0e0e0;
        height: 20px;
        border-radius: 10px;
        overflow: hidden;
        margin-top: 10px;
    }
    .progress-bar {
        height: 100%;
        background-color: #007bff;
        width: 0%;
        transition: width 0.3s;
    }
    .youtube-wrapper {
        position: relative;
        width: 100%;
        padding-top: 56.25%; /* 16:9 비율 = 9/16 * 100 */
        overflow: hidden;
    }

    .youtube-wrapper iframe {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        border: 0;
    }
</style>
<main class="main">
    <div class="row">
        <div class="col-9">
            <div class="video-container">
                <c:forEach var="sec" items="${section}">
                    <c:if test="${sec.sectionSeq == curr.sectionSeq}">
                        <c:set var="sectionTitle"  value="${sec.sectionTitle}"/>
                    </c:if>
                </c:forEach>
                <div>${sectionTitle} - ${curr.currTitle}</div>
                <c:choose>
                    <c:when test="${curr.currVideoType == 'UPLOAD'}">
                        <video id="lectureVideo" width="100%" controls data-lecture-seq="${curr.currSeq}">
                            <source src="${pageContext.request.contextPath}${curr.currVideoUrl}" type="video/mp4">
                            브라우저가 video 태그를 지원하지 않습니다.
                        </video>
                    </c:when>
                    <c:when test="${curr.currVideoType == 'YOUTUBE'}">
                        <div class="youtube-wrapper">
                            <div id="youtubePlayer"></div>
                        </div>
                    </c:when>
                </c:choose>

            </div>
        </div>
        <div id="product-details" class="product-details section col-3">
            <div class="container aos-init aos-animate" data-aos="fade-up" data-aos-delay="100">
                <div class="row aos-init aos-animate" data-aos="fade-up">
                    <div class="col-12">
                        <div class="progress-bar-wrapper">
                            <div id="progress-bar" class="progress-bar"></div>
                        </div>
                        <div class="accordion">
                            <!-- Description Accordion -->
                            <c:forEach var="s" items="${section}">
                                <div class="accordion-item">
                                    <div class="accordion-header">
                                        <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#sectionCurriculum${s.sectionSeq}" aria-expanded="true" aria-controls="sectionCurriculum${s.sectionSeq}">
                                            <span style="padding: 0 20px;font-size: medium;">${s.sectionTitle}</span>
                                        </button>
                                    </div>
                                    <div id="sectionCurriculum${s.sectionSeq}" class="accordion-collapse collapse show">
                                        <div class="accordion-body">
                                            <c:forEach var="c" items="${s.curriculums}">
                                                <a class="card m-1" href="${pageContext.request.contextPath}/course/viewer?courseSeq=${course.courseSeq}&currSeq=${c.currSeq}">
                                                    <div class="card-body">
                                                        <div class="row align-items-center fw-bolder" style="color: #0d4f8c;">
                                                            <div class="col-12" style="padding-left: 30px;">${c.currTitle}</div>
                                                        </div>
                                                    </div>
                                                </a>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>

                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

</main>
<c:choose>
    <c:when test="${curr.currVideoType == 'UPLOAD'}">
        <script>
            const video = document.getElementById('lectureVideo');
            const progressBar = document.getElementById('progress-bar');
            const currSeq = video.dataset.lectureSeq;
            const memberNo = '${loginMember.memberNo}';
            const courseSeq = '${course.courseSeq}';
            const sectionSeq = '${curr.sectionSeq}';
            let saveInterval;

            // 진도율 저장 함수
            function saveProgress() {
                const currentTime = Math.floor(video.currentTime);
                const duration = Math.floor(video.duration);
                $.ajax({
                    url: '${pageContext.request.contextPath}/course/saveProgress',
                    method: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify({
                        courseSeq: courseSeq,
                        sectionSeq: sectionSeq,
                        currSeq: currSeq,
                        prgPlayTime: currentTime,
                        prgTotalTime: duration
                    }),
                    success: function () {
                        const percentage = (currentTime / duration) * 100;
                        progressBar.style.width = percentage + '%';
                        console.log("진도율 저장됨: " + percentage.toFixed(1) + "%");
                    },
                    error: function () {
                        console.warn("진도율 저장 실패");
                    }
                });
            }

            // 10초마다 저장
            video.addEventListener('play', () => {
                saveInterval = setInterval(saveProgress, 10000);
            });

            video.addEventListener('pause', () => {
                clearInterval(saveInterval);
                saveProgress(); // 멈출 때 한번 저장
            });

            video.addEventListener('ended', () => {
                clearInterval(saveInterval);
                saveProgress(); // 끝났을 때도 저장
            });

            // 로딩 시 기존 진도 불러오기
            $(document).ready(function () {
                $.ajax({
                    url: '${pageContext.request.contextPath}/course/getProgress',
                    method: 'GET',
                    data: {
                        currSeq: currSeq
                    },
                    success: function (res) {
                        if (res.prgPlayTime) {
                            video.currentTime = res.prgPlayTime;
                        }
                    }
                });
            });
        </script>
    </c:when>
    <c:when test="${curr.currVideoType == 'YOUTUBE'}">
        <script>
            let player;
            let ytSaveInterval;
            let ytDuration = 0;

            // YouTube API 로드 후 호출되는 함수
            function onYouTubeIframeAPIReady() {
                const videoId = getYouTubeId('${curr.currVideoUrl}'); // https://www.youtube.com/watch?v=xxxx 에서 v 추출

                player = new YT.Player('youtubePlayer', {
                    width: '100%',
                    videoId: videoId,
                    events: {
                        'onReady': onPlayerReady,
                        'onStateChange': onPlayerStateChange
                    }
                });
            }

            // 플레이어 준비되면 실행
            function onPlayerReady(event) {
                // 총 영상 길이를 가져옴
                ytDuration = player.getDuration();

                // 기존 진도 불러오기
                $.ajax({
                    url: '${pageContext.request.contextPath}/course/getProgress',
                    method: 'GET',
                    data: {
                        currSeq: '${curr.currSeq}'
                    },
                    success: function (res) {

                        if (res.prgPlayTime) {
                            player.seekTo(res.prgPlayTime, true);
                        }
                    }
                });
            }

            // 상태 변화 감지
            function onPlayerStateChange(event) {
                const currSeq = '${curr.currSeq}';
                const courseSeq = '${course.courseSeq}';
                const sectionSeq = '${curr.sectionSeq}';

                if (event.data === YT.PlayerState.PLAYING) {
                    ytSaveInterval = setInterval(() => {
                        const currentTime = Math.floor(player.getCurrentTime());
                        const percentage = (currentTime / ytDuration) * 100;
                        $("#progress-bar").css("width", percentage + "%");

                        $.ajax({
                            url: '${pageContext.request.contextPath}/course/saveProgress',
                            method: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify({
                                courseSeq: courseSeq,
                                sectionSeq: sectionSeq,
                                currSeq: currSeq,
                                prgPlayTime: currentTime,
                                prgTotalTime: ytDuration
                            }),
                            success: function () {
                                console.log("진도율 저장됨(YT): " + percentage.toFixed(1) + "%");
                            }
                        });
                    }, 10000);
                }

                if (event.data === YT.PlayerState.PAUSED || event.data === YT.PlayerState.ENDED) {
                    clearInterval(ytSaveInterval);

                    // 재생 멈출 때도 저장
                    const currentTime = Math.floor(player.getCurrentTime());
                    $.ajax({
                        url: '${pageContext.request.contextPath}/course/saveProgress',
                        method: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify({
                            courseSeq: courseSeq,
                            sectionSeq: sectionSeq,
                            currSeq: currSeq,
                            prgPlayTime: currentTime,
                            prgTotalTime: ytDuration
                        })
                    });
                }
            }

            function getYouTubeId(url) {
                const regExp = /(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?|shorts)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/i;
                const match = url.match(regExp);
                return match && match[1] ? match[1] : '';
            }
        </script>
    </c:when>
</c:choose>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
