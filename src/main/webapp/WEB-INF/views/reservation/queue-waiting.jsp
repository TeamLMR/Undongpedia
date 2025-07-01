<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!-- 로그인 사용자 정보 가져오기 -->
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<style>
.queue-container {
    min-height: 80vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f8f9fa;
}

.queue-card {
    background: white;
    border-radius: 10px;
    padding: 3rem;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    max-width: 400px;
    width: 90%;
}

.queue-position {
    font-size: 3rem;
    font-weight: bold;
    color: #007bff;
    margin: 1rem 0;
}

.connection-dot {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    display: inline-block;
    margin-right: 8px;
}

.connected { background-color: #28a745; }
.disconnected { background-color: #dc3545; }
.connecting { background-color: #ffc107; }

.progress {
    height: 8px;
    border-radius: 4px;
}
</style>

<main class="main">
    <div class="queue-container">
        <div class="queue-card">
            <!-- 연결 상태 -->
            <div class="mb-3">
                <span id="connectionDot" class="connection-dot connecting"></span>
                <small id="connectionText">연결 중...</small>
            </div>

            <!-- 강의 제목 -->
            <h3 class="mb-4">${course.courseTitle}</h3>

            <!-- 현재 순서 -->
            <div class="queue-position" id="currentPosition">-</div>
            <p class="text-muted mb-3">현재 순서</p>

            <!-- 진행률 바 -->
            <div class="progress mb-4">
                <div id="queueProgress" class="progress-bar bg-success progress-bar-striped progress-bar-animated" 
                     style="width: 0%"></div>
            </div>

            <!-- 대기 정보 -->
            <div class="row text-center mb-4">
                <div class="col-6">
                    <h5 id="totalWaiting">-</h5>
                    <small class="text-muted">총 대기</small>
                </div>
                <div class="col-6">
                    <h5 id="estimatedTime">-</h5>
                    <small class="text-muted">예상시간</small>
                </div>
            </div>

            <!-- 상태 메시지 -->
            <div id="statusMessage" class="alert alert-info">
                대기열 상태를 확인하고 있습니다...
            </div>

            <!-- 안내 -->
            <small class="text-muted">
                페이지를 닫으면 대기열에서 제외됩니다
            </small>
        </div>
    </div>
</main>

<script>
// 전역 변수
const courseSeq = '<c:out value="${courseSeq}" />';
const contextPath = '<c:out value="${pageContext.request.contextPath}" />';

// 🔥 실제 로그인 사용자 정보 사용
let memberNo;
const loginMemberNo = '${loginMember.memberNo}'; // 로그인 사용자의 memberNo

console.log('🔍 초기 변수 상태:');
console.log('  - loginMemberNo 원본:', '${loginMember.memberNo}');
console.log('  - loginMemberNo 변수:', loginMemberNo);
console.log('  - typeof loginMemberNo:', typeof loginMemberNo);

if (loginMemberNo && loginMemberNo !== '' && loginMemberNo !== 'null' && loginMemberNo !== 'undefined') {
    // 로그인한 경우 실제 memberNo 사용
    memberNo = parseInt(loginMemberNo);
    console.log(' 로그인 사용자 - memberNo:', memberNo, 'typeof:', typeof memberNo);
} else {
    // 로그인하지 않은 경우 세션 스토리지에서 임시 ID 사용
    let tempMemberNo = sessionStorage.getItem('temp_member_no');
    if (!tempMemberNo) {
        tempMemberNo = Date.now().toString().slice(-6) + Math.floor(Math.random() * 999).toString().padStart(3, '0');
        sessionStorage.setItem('temp_member_no', tempMemberNo);
        console.log('비로그인 사용자 - 임시 ID 생성:', tempMemberNo);
    } else {
        console.log('비로그인 사용자 - 기존 임시 ID 사용:', tempMemberNo);
    }
    memberNo = parseInt(tempMemberNo);
    console.log('최종 memberNo:', memberNo, 'typeof:', typeof memberNo);
}

// 중복 진입 방지를 위한 고유 키 생성
const queueKey = 'queue_member_' + courseSeq;
const existingEntry = sessionStorage.getItem(queueKey);
if (existingEntry && existingEntry === memberNo.toString()) {
    console.log('이미 대기열에 진입한 사용자입니다.');
} else {
    sessionStorage.setItem(queueKey, memberNo.toString());
}

let queueWebSocket = null;
let heartbeatInterval = null;

// 페이지 로드시 초기화
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 대기열 페이지 로드 - courseSeq:', courseSeq);
    
    // 먼저 대기열에 추가
    joinQueue();
    
    connectWebSocket();
    startHeartbeat();
    setupPageLeaveWarning();
    
    // 대기열 상태 주기적으로 확인
    setInterval(checkQueueStatus, 2000); // 2초마다 상태 확인
});

// 웹소켓 연결
function connectWebSocket() {
    updateConnectionStatus('connecting');
    
    try {
        // courseSeq 값 검증
        if (!courseSeq || courseSeq === 'undefined' || courseSeq === 'null') {
            console.error(' courseSeq 값이 유효하지 않습니다:', courseSeq);
            updateConnectionStatus('disconnected');
            return;
        }
        
        // memberNo 값 검증
        if (!memberNo || memberNo === 'undefined' || memberNo === 'null' || isNaN(memberNo)) {
            console.error(' memberNo 값이 유효하지 않습니다:', memberNo);
            console.log(' 디버깅 정보:');
            console.log('  - loginMemberNo:', loginMemberNo);
            console.log('  - typeof loginMemberNo:', typeof loginMemberNo);
            console.log('  - sessionStorage temp_member_no:', sessionStorage.getItem('temp_member_no'));
            updateConnectionStatus('disconnected');
            return;
        }
        
        // URL 생성 및 로깅
        const wsUrl = 'ws://' + window.location.host + contextPath + '/queue-websocket?courseSeq=' + encodeURIComponent(courseSeq) + '&memberNo=' + encodeURIComponent(memberNo);
        console.log(' WebSocket 연결 시도:', wsUrl);
        console.log(' 변수값 확인 - host:', window.location.host, 'contextPath:', contextPath, 'courseSeq:', courseSeq, 'memberNo:', memberNo, 'typeof memberNo:', typeof memberNo);
        
        queueWebSocket = new WebSocket(wsUrl);
        
        queueWebSocket.onopen = function() {
            console.log(' 웹소켓 연결 성공');
            updateConnectionStatus('connected');
        };
        
        queueWebSocket.onmessage = function(event) {
            const data = JSON.parse(event.data);
            console.log(' 웹소켓 메시지 수신:', data);
            handleWebSocketMessage(data);
        };
        
        queueWebSocket.onclose = function(event) {
            console.log(' 웹소켓 연결 끊김 - 코드:', event.code, '이유:', event.reason);
            updateConnectionStatus('disconnected');
            setTimeout(connectWebSocket, 3000);
        };
        
        queueWebSocket.onerror = function(error) {
            console.error(' 웹소켓 오류:', error);
            updateConnectionStatus('disconnected');
        };
        
    } catch (error) {
        console.error(' 웹소켓 연결 실패:', error);
        updateConnectionStatus('disconnected');
    }
}

// WebSocket 메시지 처리
function handleWebSocketMessage(data) {
    console.log('WebSocket 메시지 처리:', data);
    
    switch(data.type) {
        case 'queue_update':
        case 'connected':
            updateQueueUI(data.data || data);
            break;
            
        case 'temp_reservation_success':
            handleTempReservationSuccess(data);
            break;
            
        case 'temp_reservation_failed':
            handleTempReservationFailed(data);
            break;
            
        default:
            console.log('알 수 없는 메시지 타입:', data.type);
            // 기본적으로 queue_update로 처리
            updateQueueUI(data);
    }
}

/**
 * 임시예약 성공 처리
 */
function handleTempReservationSuccess(data) {
    console.log('임시예약 성공:', data);
    
    // 모든 타이머와 WebSocket 정리
    if (heartbeatInterval) {
        clearInterval(heartbeatInterval);
    }
    if (queueWebSocket) {
        queueWebSocket.onclose = null; // 재연결 방지
        queueWebSocket.close();
    }
    
    // 장바구니에 추가
    $.ajax({
        url: contextPath + '/cart/add-offline',
        type: 'POST',
        data: {
            tempReservationId: data.tempReservationId,
            scheduleId: data.scheduleId,
            courseSeq: data.courseSeq
        },
        success: function(response) {
            if (response.success) {
                alert('임시예약이 완료되었습니다! 장바구니로 이동합니다.');
                window.location.href = contextPath + '/cart';
            } else {
                alert('장바구니 추가 실패: ' + response.message);
                // 실패 시에도 장바구니로 이동 (사용자 편의)
                window.location.href = contextPath + '/cart';
            }
        },
        error: function(xhr, status, error) {
            console.error('장바구니 추가 요청 실패:', error);
            alert('장바구니 추가 중 오류가 발생했습니다.');
            // 오류 시에도 장바구니로 이동
            window.location.href = contextPath + '/cart';
        }
    });
}

/**
 * 임시예약 실패 처리
 */
function handleTempReservationFailed(data) {
    console.log('임시예약 실패:', data);
    alert('임시예약에 실패했습니다: ' + (data.message || '알 수 없는 오류'));
    
    // 대기열 UI 업데이트 (다시 대기 상태로)
    if (data.queueData) {
        updateQueueUI(data.queueData);
    }
}

// 연결 상태 업데이트
function updateConnectionStatus(status) {
    const dot = document.getElementById('connectionDot');
    const text = document.getElementById('connectionText');
    
    dot.className = 'connection-dot ' + status;
    
    switch(status) {
        case 'connected':
            text.textContent = '연결됨';
            break;
        case 'connecting':
            text.textContent = '연결 중...';
            break;
        case 'disconnected':
            text.textContent = '연결끊김';
            break;
    }
}

// 대기열 UI 업데이트
function updateQueueUI(queueData) {
    console.log(' UI 업데이트 시작 - queueData:', queueData);
    
    // 현재 순서
    const position = queueData.position || '-';
    document.getElementById('currentPosition').textContent = position;
    console.log(' 현재 순서:', position);
    
    // 총 대기인원
    const totalInQueue = queueData.totalInQueue || 0;
    document.getElementById('totalWaiting').textContent = totalInQueue + '명';
    console.log(' 총 대기인원:', totalInQueue);
    
    // 예상 대기시간 (estimateWaitTime로 수정)
    const estimatedMinutes = Math.ceil((queueData.estimateWaitTime || 0) / 60);
    document.getElementById('estimatedTime').textContent = estimatedMinutes + '분';
    console.log('예상 대기시간:', estimatedMinutes + '분');
    
    // 🔥 진행률 계산 및 업데이트
    const progress = totalInQueue > 0 ? 
        ((totalInQueue - position + 1) / totalInQueue) * 100 : 0;
    document.getElementById('queueProgress').style.width = progress + '%';
    console.log(' 진행률:', progress.toFixed(2) + '%');
    
    // 상태 메시지 및 자동 이동
    const statusMsg = document.getElementById('statusMessage');
    if (position === 1) {
        console.log(' 대기 순서가 되었습니다!');
        statusMsg.className = 'alert alert-success';
        statusMsg.innerHTML = '예약 페이지로 이동합니다...';
        
        // 🔥 2초 후 자동 이동
        setTimeout(function() {
            console.log(' 예약 페이지로 이동');
            window.location.href = contextPath + '/reservation/' + courseSeq;
        }, 2000);
        
    } else {
        statusMsg.className = 'alert alert-info';
        statusMsg.innerHTML = position + '번째 순서입니다. 잠시만 기다려주세요.';
    }
}

// 하트비트 시작
function startHeartbeat() {
    heartbeatInterval = setInterval(function() {
        fetch(contextPath + '/reservation/heartbeat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                courseSeq: courseSeq,
                memberNo: memberNo
            })
        }).catch(error => console.error('하트비트 실패:', error));
    }, 5000);
}

// 대기열 상태 확인
function checkQueueStatus() {
    console.log('🔍 대기열 상태 확인 시작 - courseSeq:', courseSeq, 'memberNo:', memberNo);
    
    fetch(contextPath + '/reservation/queue-status/' + courseSeq + '?memberNo=' + memberNo)
        .then(response => response.json())
        .then(data => {
            console.log('📦 대기열 상태 응답:', data);
            
            if (data.success && data.userPosition && data.userPosition.success && data.userPosition.data) {
                console.log(' 대기열 정보 업데이트:', data.userPosition.data);
                updateQueueUI(data.userPosition.data);
            } else {
                console.log(' 대기열에 없음 또는 오류:', data);
                // 대기열에 없으면 예약 페이지로 추가
                if (!data.queueActive) {
                    console.log(' 대기열 비활성화 상태 - 예약페이지로 이동');
                    window.location.href = contextPath + '/reservation/' + courseSeq;
                }
            }
        })
        .catch(error => {
            console.error(' 대기열 상태 조회 실패:', error);
        });
}

//  코스 대기열 추가 (이벤트 강의 진입용)
function joinQueue() {
    console.log(' 코스 대기열 추가 요청 시작');
    
    fetch(contextPath + '/reservation/join-course-queue', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            courseSeq: courseSeq,
            memberNo: memberNo
        })
    })
    .then(response => response.json())
    .then(data => {
        console.log(' 코스 대기열 추가 응답:', data);
        
        if (data.success && data.data) {
            console.log(' 코스 대기열 추가 성공');
            updateQueueUI(data.data);
        } else {
            console.error(' 코스 대기열 추가 실패:', data.message);
        }
    })
    .catch(error => {
        console.error('코스 대기열 추가 오류:', error);
    });
}

// 페이지 이탈 경고
function setupPageLeaveWarning() {
    window.addEventListener('beforeunload', function(e) {
        e.preventDefault();
        e.returnValue = '페이지를 떠나면 대기열에서 제거됩니다.';
    });
}

// 정리 작업
window.addEventListener('unload', function() {
    if (queueWebSocket) {
        queueWebSocket.close();
    }
    if (heartbeatInterval) {
        clearInterval(heartbeatInterval);
    }
});


</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/> 