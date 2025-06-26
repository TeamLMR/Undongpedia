<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container mt-4">
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h3><i class="fas fa-chart-line"></i> 실시간 대기열 모니터링</h3>
                    <small>자동 업데이트: <span id="updateInterval">2초</span>마다</small>
                </div>
                <div class="card-body">
                    
                    <!-- 대기열 상태 요약 -->
                    <div class="row mb-4">
                        <div class="col-md-3">
                            <div class="card bg-info text-white">
                                <div class="card-body text-center">
                                    <h2 id="activeMembers">-</h2>
                                    <p>활성 사용자</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-white" id="queueStatusCard">
                                <div class="card-body text-center">
                                    <h2 id="queueStatus">-</h2>
                                    <p>대기열 상태</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bg-warning text-white">
                                <div class="card-body text-center">
                                    <h2 id="queueCount">-</h2>
                                    <p>대기 중인 인원</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card bg-success text-white">
                                <div class="card-body text-center">
                                    <h2 id="processedCount">-</h2>
                                    <p>처리 완료</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 실시간 로그 -->
                    <div class="row">
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5><i class="fas fa-list"></i> 실시간 활동 로그</h5>
                                    <button class="btn btn-sm btn-outline-secondary" onclick="clearLogs()">로그 지우기</button>
                                </div>
                                <div class="card-body" style="height: 400px; overflow-y: auto;">
                                    <div id="activityLog">
                                        <p class="text-muted">모니터링 시작 중...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="card">
                                <div class="card-header">
                                    <h5><i class="fas fa-users"></i> 대기열 순서 (상위 10명)</h5>
                                </div>
                                <div class="card-body" style="height: 400px; overflow-y: auto;">
                                    <div id="queueList">
                                        <p class="text-muted">대기열 정보 로딩 중...</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 컨트롤 패널 -->
                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5><i class="fas fa-cogs"></i> 테스트 컨트롤</h5>
                                </div>
                                <div class="card-body">
                                    <div class="btn-group me-3">
                                        <button class="btn btn-success" onclick="sendHeartbeats(10)">하트비트 10명</button>
                                        <button class="btn btn-info" onclick="sendHeartbeats(30)">하트비트 30명</button>
                                        <button class="btn btn-warning" onclick="sendBookingRequests(5)">예약요청 5명</button>
                                        <button class="btn btn-danger" onclick="sendBookingRequests(20)">예약요청 20명</button>
                                    </div>
                                    
                                    <div class="btn-group">
                                        <button class="btn btn-outline-primary" onclick="changeUpdateInterval(1000)">1초</button>
                                        <button class="btn btn-outline-primary active" onclick="changeUpdateInterval(2000)">2초</button>
                                        <button class="btn btn-outline-primary" onclick="changeUpdateInterval(5000)">5초</button>
                                        <button class="btn btn-outline-secondary" onclick="stopMonitoring()">중지</button>
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

<script>
let monitoringInterval;
let currentInterval = 2000;
let logCounter = 0;

// 모니터링 시작
function startMonitoring() {
    if (monitoringInterval) clearInterval(monitoringInterval);
    
    monitoringInterval = setInterval(async () => {
        await updateQueueStatus();
    }, currentInterval);
    
    // 즉시 한번 실행
    updateQueueStatus();
    
    addLog('🚀 실시간 모니터링 시작', 'info');
}

// 대기열 상태 업데이트
async function updateQueueStatus() {
    try {
        // 🎯 전체 대기열 통계 조회
        const response = await fetch('/undongpedia/reservation/queue-stats/1');
        const data = await response.json();
        
        // UI 업데이트
        document.getElementById('activeMembers').textContent = data.activeMembers || 0;
        document.getElementById('queueStatus').textContent = data.queueActive ? '활성' : '비활성';
        
        // 대기열 상태에 따른 카드 색상 변경
        const statusCard = document.getElementById('queueStatusCard');
        if (data.queueActive) {
            statusCard.className = 'card bg-danger text-white';
        } else {
            statusCard.className = 'card bg-secondary text-white';
        }
        
        // 🎯 대기열 순서 정보 업데이트
        updateQueueList(data);
        
        // 대기 중인 인원 수 업데이트
        document.getElementById('queueCount').textContent = data.totalInQueue || 0;
        
        // 로그 추가
        const queueInfo = data.totalInQueue > 0 ? ('총 ' + data.totalInQueue + '명 대기중') : '대기열 없음';
        addLog('📊 활성사용자: ' + data.activeMembers + ', 대기열: ' + (data.queueActive ? '활성' : '비활성') + ', ' + queueInfo, 'info');
        
    } catch (error) {
        addLog('❌ 상태 업데이트 실패: ' + error.message, 'error');
    }
}

// 🎯 대기열 순서 리스트 업데이트
function updateQueueList(data) {
    const queueListDiv = document.getElementById('queueList');
    
    if (!data.queueActive) {
        queueListDiv.innerHTML = '<p class="text-muted">대기열이 비활성 상태입니다.</p>';
        return;
    }
    
        console.log('API 응답 데이터:', data);
    
    if (!data.queueActive) {
        queueListDiv.innerHTML = '<p class="text-muted">대기열이 비활성 상태입니다.</p>';
        return;
    }
    
    if (!data.totalInQueue || data.totalInQueue === 0) {
        queueListDiv.innerHTML = '<p class="text-muted">대기열에 사용자가 없습니다.</p>';
        return;
    }
    
    // 대기열 정보 표시
    let queueHtml = 
        '<div class="alert alert-info">' +
            '<strong>📊 대기열 현황</strong><br>' +
            '전체 대기 인원: <span class="badge bg-primary">' + data.totalInQueue + '명</span><br>' +
            '대기열 상태: <span class="badge bg-danger">활성</span><br>' +
            '평균 대기시간: <span class="badge bg-secondary">약 ' + Math.floor(data.totalInQueue * 0.5) + '분</span>' +
        '</div>';
    
    // 실제 상위 10명 리스트
    queueHtml += '<div class="list-group">';
    if (data.topMembers && data.topMembers.length > 0) {
        for (let i = 0; i < Math.min(10, data.topMembers.length); i++) {
            const memberNo = data.topMembers[i];
            queueHtml += 
                '<div class="list-group-item d-flex justify-content-between align-items-center">' +
                    '<span>' +
                        '<i class="fas fa-user"></i> ' +
                        '사용자 #' + memberNo +
                    '</span>' +
                    '<span class="badge bg-secondary rounded-pill">' + (i + 1) + '번째</span>' +
                '</div>';
        }
    } else {
        // 가상의 리스트 (topMembers가 없을 경우)
        for (let i = 1; i <= Math.min(10, data.totalInQueue); i++) {
            queueHtml += 
                '<div class="list-group-item d-flex justify-content-between align-items-center">' +
                    '<span>' +
                        '<i class="fas fa-user"></i> ' +
                        '사용자 #' + i +
                    '</span>' +
                    '<span class="badge bg-secondary rounded-pill">' + i + '번째</span>' +
                '</div>';
        }
    }
    queueHtml += '</div>';
    
    queueListDiv.innerHTML = queueHtml;
}

// 로그 추가 함수
function addLog(message, type = 'info') {
    const logDiv = document.getElementById('activityLog');
    const timestamp = new Date().toLocaleTimeString();
    const logClass = type === 'error' ? 'text-danger' : type === 'success' ? 'text-success' : 'text-info';
    
    const logEntry = document.createElement('div');
    logEntry.className = 'border-bottom pb-2 mb-2 ' + logClass;
    logEntry.innerHTML = '<small class="text-muted">' + timestamp + '</small><br>' + message;
    
    logDiv.insertBefore(logEntry, logDiv.firstChild);
    
    // 로그가 너무 많으면 제거
    const logs = logDiv.children;
    if (logs.length > 50) {
        logDiv.removeChild(logs[logs.length - 1]);
    }
}

// 하트비트 전송
async function sendHeartbeats(count) {
    addLog('💓 ' + count + '명 하트비트 전송 시작...', 'info');
    
    const promises = [];
    for (let i = 1; i <= count; i++) {
        const promise = fetch('/undongpedia/reservation/heartbeat', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({courseSeq: 1, memberNo: Math.floor(Math.random() * 1000) + 1})
        });
        promises.push(promise);
    }
    
    try {
        await Promise.all(promises);
        addLog('✅ ' + count + '명 하트비트 전송 완료', 'success');
    } catch (error) {
        addLog('❌ 하트비트 전송 실패: ' + error.message, 'error');
    }
}

// 예약 요청 전송
async function sendBookingRequests(count) {
    addLog('🎫 ' + count + '명 예약 요청 전송 시작...', 'info');
    
    const promises = [];
    for (let i = 1; i <= count; i++) {
        const promise = fetch('/undongpedia/reservation/book', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                courseSeq: 1, 
                scheduleId: 1, 
                memberNo: Math.floor(Math.random() * 1000) + 1
            })
        });
        promises.push(promise);
    }
    
    try {
        await Promise.all(promises);
        addLog('✅ ' + count + '명 예약 요청 완료', 'success');
    } catch (error) {
        addLog('❌ 예약 요청 실패: ' + error.message, 'error');
    }
}

// 업데이트 간격 변경
function changeUpdateInterval(interval) {
    currentInterval = interval;
    document.getElementById('updateInterval').textContent = (interval / 1000) + '초';
    
    // 버튼 active 상태 변경
    document.querySelectorAll('.btn-outline-primary').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // 모니터링 재시작
    startMonitoring();
    addLog('⏱️ 업데이트 간격을 ' + (interval/1000) + '초로 변경', 'info');
}

// 로그 지우기
function clearLogs() {
    document.getElementById('activityLog').innerHTML = '<p class="text-muted">로그가 지워졌습니다.</p>';
}

// 모니터링 중지
function stopMonitoring() {
    if (monitoringInterval) {
        clearInterval(monitoringInterval);
        monitoringInterval = null;
        addLog('⏹️ 모니터링 중지', 'info');
    }
}

// 페이지 로드 시 자동 시작
document.addEventListener('DOMContentLoaded', function() {
    startMonitoring();
});

// 페이지 떠날 때 정리
window.addEventListener('beforeunload', function() {
    stopMonitoring();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/> 