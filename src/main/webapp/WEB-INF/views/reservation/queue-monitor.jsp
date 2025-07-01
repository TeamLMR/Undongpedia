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
                    
                    <!-- 테스트 설정 추가 -->
                    <div class="row mb-4">
                        <div class="col-md-12">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h5><i class="fas fa-cog"></i> 테스트 설정</h5>
                                    <div class="row">
                                        <div class="col-md-4">
                                            <label>Course ID:</label>
                                            <input type="number" id="testCourseSeq" class="form-control" value="20" min="1">
                                        </div>
                                        <div class="col-md-4">
                                            <label>Schedule ID:</label>
                                            <input type="number" id="testScheduleId" class="form-control" value="2" min="1">
                                        </div>
                                        <div class="col-md-4">
                                            <label>&nbsp;</label>
                                            <button class="btn btn-primary form-control" onclick="applyTestSettings()">
                                                <i class="fas fa-check"></i> 설정 적용
                                            </button>
                                        </div>
                                    </div>
                                    <small class="text-muted">현재 테스트 대상: Course <span id="currentCourse">20</span>, Schedule <span id="currentSchedule">2</span></small>
                                </div>
                            </div>
                        </div>
                    </div>
                    
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

                    <div class="card mt-4">
                        <div class="card-header">
                            <h5 class="mb-0">🧪 대기열 테스트 도구</h5>
                        </div>
                        <div class="card-body">
                            <!-- 테스트 시나리오 선택 -->
                            <div class="mb-3">
                                <h6>테스트 시나리오</h6>
                                <div class="btn-group" role="group">
                                    <button type="button" class="btn btn-outline-primary" onclick="startCourseQueueTest()">
                                        코스 대기열 테스트
                                    </button>
                                    <button type="button" class="btn btn-outline-primary" onclick="startScheduleQueueTest()">
                                        스케줄 대기열 테스트
                                    </button>
                                </div>
                            </div>

                            <!-- 가상 사용자 생성 -->
                            <div class="mb-3">
                                <h6>가상 사용자 생성</h6>
                                <div class="input-group">
                                    <input type="number" id="virtualUserCount" class="form-control" 
                                           placeholder="생성할 사용자 수" value="5" min="1" max="20">
                                    <button class="btn btn-warning" onclick="createVirtualUsers()">
                                        <i class="bi bi-people-fill"></i> 가상 사용자 생성
                                    </button>
                                </div>
                            </div>

                            <!-- 테스트 결과 -->
                            <div class="mb-3">
                                <h6>테스트 로그</h6>
                                <div id="testLog" class="border rounded p-3" style="height: 200px; overflow-y: auto; font-family: monospace; font-size: 12px;">
                                    <div class="text-muted">테스트를 시작하면 여기에 로그가 표시됩니다...</div>
                                </div>
                            </div>

                            <!-- 대기열 상태 실시간 모니터링 -->
                            <div class="mb-3">
                                <h6>대기열 상태</h6>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="border rounded p-3">
                                            <h6>코스 대기열</h6>
                                            <div id="courseQueueStatus">
                                                <p>대기인원: <span id="courseQueueCount">0</span>명</p>
                                                <div id="courseQueueMembers" class="small"></div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="border rounded p-3">
                                            <h6>스케줄 대기열</h6>
                                            <div id="scheduleQueueStatus">
                                                <p>대기인원: <span id="scheduleQueueCount">0</span>명</p>
                                                <div id="scheduleQueueMembers" class="small"></div>
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
</div>

<script>
// contextPath 변수 정의
const contextPath = '<c:out value="${pageContext.request.contextPath}" />';

let monitoringInterval;
let currentInterval = 2000;
let logCounter = 0;
let testCourseSeq = 20;  // 기본값을 20으로 설정
let testScheduleId = 2;   // 기본값을 2로 설정

// 테스트 설정 적용
function applyTestSettings() {
    testCourseSeq = parseInt(document.getElementById('testCourseSeq').value);
    testScheduleId = parseInt(document.getElementById('testScheduleId').value);
    
    document.getElementById('currentCourse').textContent = testCourseSeq;
    document.getElementById('currentSchedule').textContent = testScheduleId;
    
    addLog('⚙️ 테스트 설정 변경 - Course: ' + testCourseSeq + ', Schedule: ' + testScheduleId, 'success');
    
    // 즉시 상태 업데이트
    updateQueueStatus();
}

// 모니터링 시작
function startMonitoring() {
    if (monitoringInterval) clearInterval(monitoringInterval);
    
    monitoringInterval = setInterval(async () => {
        await updateQueueStatus();
    }, currentInterval);
    
    // 즉시 한번 실행
    updateQueueStatus();
    
    addLog('🚀 실시간 모니터링 시작 - Course: ' + testCourseSeq, 'info');
}

// 대기열 상태 업데이트
async function updateQueueStatus() {
    try {
        // 🎯 전체 대기열 통계 조회 - 동적 courseSeq 사용
        const response = await fetch('/undongpedia/reservation/queue-stats/' + testCourseSeq);
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
    addLog('💓 ' + count + '명 하트비트 전송 시작... (Course: ' + testCourseSeq + ')', 'info');
    
    const promises = [];
    for (let i = 1; i <= count; i++) {
        const promise = fetch('/undongpedia/reservation/heartbeat', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                courseSeq: testCourseSeq,  // 동적 courseSeq 사용
                memberNo: Math.floor(Math.random() * 1000) + 1
            })
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
    addLog('🎫 ' + count + '명 예약 요청 전송 시작... (Course: ' + testCourseSeq + ', Schedule: ' + testScheduleId + ')', 'info');
    
    const promises = [];
    for (let i = 1; i <= count; i++) {
        const promise = fetch('/undongpedia/reservation/book', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                courseSeq: testCourseSeq,     // 동적 courseSeq 사용
                scheduleId: testScheduleId,   // 동적 scheduleId 사용
                memberNo: Math.floor(Math.random() * 1000) + 1
            })
        });
        promises.push(promise);
    }
    
    try {
        await Promise.all(promises);
        addLog( + count + '명 예약 요청 완료', 'success');
    } catch (error) {
        addLog('예약 요청 실패: ' + error.message, 'error');
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
    addLog('업데이트 간격을 ' + (interval/1000) + '초로 변경', 'info');
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
        addLog('모니터링 중지', 'info');
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

// 테스트 로그 함수
function addTestLog(message, type = 'info') {
    const testLog = document.getElementById('testLog');
    const timestamp = new Date().toLocaleTimeString();
    const color = type === 'error' ? 'text-danger' : type === 'success' ? 'text-success' : 'text-dark';
    
    const logEntry = document.createElement('div');
    logEntry.className = color;
    logEntry.innerHTML = `[\${timestamp}] \${message}`;
    
    testLog.appendChild(logEntry);
    testLog.scrollTop = testLog.scrollHeight;
}

// 코스 대기열 테스트
function startCourseQueueTest() {
    const courseSeq = prompt('테스트할 강의 번호를 입력하세요:', '1');
    if (!courseSeq) return;
    
    addTestLog('🚀 코스 대기열 테스트 시작 - courseSeq: ' + courseSeq, 'success');
    
    // 새 창들 열기
    const testWindows = [];
    for (let i = 1; i <= 3; i++) {
        setTimeout(() => {
            const win = window.open(
                contextPath + '/reservation/queue/' + courseSeq,
                'test_user_' + i,
                'width=800,height=600,left=' + (i * 100) + ',top=' + (i * 50)
            );
            testWindows.push(win);
            addTestLog(`사용자 \${i} - 대기열 페이지 접속`);
        }, i * 1000); // 1초 간격으로 접속
    }
}

// 스케줄 대기열 테스트
function startScheduleQueueTest() {
    const courseSeq = prompt('테스트할 강의 번호를 입력하세요:', '1');
    if (!courseSeq) return;
    
    addTestLog('🚀 스케줄 대기열 테스트 시작 - courseSeq: ' + courseSeq, 'success');
    
    // 예약 페이지를 여러 창에서 열기
    for (let i = 1; i <= 3; i++) {
        setTimeout(() => {
            window.open(
                contextPath + '/reservation/' + courseSeq,
                'schedule_test_' + i,
                'width=1000,height=700,left=' + (i * 100) + ',top=' + (i * 50)
            );
            addTestLog(`사용자 \${i} - 예약 페이지 접속`);
        }, i * 500);
    }
}

// 가상 사용자 생성 (API 호출)
async function createVirtualUsers() {
    const count = parseInt(document.getElementById('virtualUserCount').value);
    const courseSeq = prompt('강의 번호를 입력하세요:', '1');
    
    if (!courseSeq) return;
    
    addTestLog(`🤖 \${count}명의 가상 사용자 생성 시작...`);
    
    for (let i = 1; i <= count; i++) {
        const memberNo = 9000 + i; // 가상 사용자 번호
        
        try {
            // 코스 대기열에 추가
            const response = await fetch(contextPath + '/reservation/join-course-queue', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    courseSeq: courseSeq,
                    memberNo: memberNo
                })
            });
            
            // 응답 상태 확인
            if (!response.ok) {
                addTestLog(`❌ 가상 사용자 \${memberNo} HTTP 오류: \${response.status} \${response.statusText}`, 'error');
                continue;
            }
            
            // 응답 텍스트를 먼저 가져와서 확인
            const responseText = await response.text();
            console.log('응답 텍스트:', responseText);
            
            // JSON 파싱 시도
            let data;
            try {
                data = JSON.parse(responseText);
            } catch (parseError) {
                addTestLog(`❌ 가상 사용자 \${memberNo} JSON 파싱 오류. 응답: \${responseText.substring(0, 100)}...`, 'error');
                continue;
            }
            
            if (data.success) {
                addTestLog(`✅ 가상 사용자 \${memberNo} 추가 성공 - 순서: \${data.data.position}`, 'success');
            } else {
                addTestLog(`❌ 가상 사용자 \${memberNo} 추가 실패: \${data.message}`, 'error');
            }
            
        } catch (error) {
            addTestLog(`❌ 가상 사용자 \${memberNo} 추가 오류: \${error.message}`, 'error');
        }
        
        // 0.5초 대기
        await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    addTestLog('✅ 가상 사용자 생성 완료!', 'success');
    
    // 대기열 상태 갱신
    refreshQueueStats();
}

// 대기열 상태 갱신
function refreshQueueStats() {
    const courseSeq = document.getElementById('courseSeq').value || '1';
    
    // API 호출하여 대기열 상태 가져오기
    fetch(contextPath + '/reservation/queue-stats/' + courseSeq)
        .then(async response => {
            if (!response.ok) {
                console.error('HTTP 오류:', response.status, response.statusText);
                return;
            }
            
            const responseText = await response.text();
            console.log('대기열 상태 응답:', responseText);
            
            try {
                const data = JSON.parse(responseText);
                if (data.success) {
                    // 코스 대기열 업데이트
                    document.getElementById('courseQueueCount').textContent = data.totalInQueue || 0;
                    
                    // 상위 멤버 표시
                    const membersHtml = data.topMembers ? 
                        data.topMembers.map((m, i) => `\${i+1}. 사용자 \${m}`).join('<br>') :
                        '대기자 없음';
                    document.getElementById('courseQueueMembers').innerHTML = membersHtml;
                }
            } catch (parseError) {
                console.error('JSON 파싱 오류:', parseError);
                console.error('응답 내용:', responseText.substring(0, 200));
            }
        })
        .catch(error => {
            console.error('대기열 상태 조회 실패:', error);
        });
}

// 5초마다 대기열 상태 갱신
setInterval(refreshQueueStats, 5000);

// 페이지 로드시 초기 상태 조회
document.addEventListener('DOMContentLoaded', function() {
    refreshQueueStats();
    addTestLog('🔍 대기열 모니터링 시작', 'success');
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/> 