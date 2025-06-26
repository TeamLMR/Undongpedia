// 브라우저 개발자 도구에서 실행할 대기열 시뮬레이션
// F12 -> Console -> 이 코드 붙여넣기 -> Enter

async function queueSimulation() {
    console.log('🚀 대기열 시뮬레이션 시작!');
    
    const baseUrl = 'http://localhost:9090/undongpedia/reservation';
    const courseSeq = 1;
    
    // 1단계: 활성 사용자 30명 생성
    console.log('1️⃣ 활성 사용자 30명 생성 중...');
    
    const heartbeatPromises = [];
    for (let i = 1; i <= 30; i++) {
        const promise = fetch(`${baseUrl}/heartbeat`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({courseSeq: courseSeq, memberNo: i})
        });
        heartbeatPromises.push(promise);
    }
    
    await Promise.all(heartbeatPromises);
    console.log('✅ 30명 하트비트 전송 완료');
    
    // 2단계: 현재 상태 확인
    console.log('2️⃣ 현재 상태 확인 중...');
    
    const statusResponse = await fetch(`${baseUrl}/queue-status/${courseSeq}?memberNo=1`);
    const statusData = await statusResponse.json();
    console.log('📊 현재 상태:', statusData);
    
    // 3단계: 동시 예약 요청 50명
    console.log('3️⃣ 50명 동시 예약 요청 시작...');
    
    const bookingPromises = [];
    for (let i = 1; i <= 50; i++) {
        const promise = fetch(`${baseUrl}/book`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                courseSeq: courseSeq,
                scheduleId: 1,
                memberNo: i
            })
        }).then(response => response.json())
          .then(data => {
              if (data.message.includes('대기열')) {
                  console.log(`🎯 사용자 ${i}: 대기열 입장 - ${data.message}`);
              } else if (data.message.includes('결제')) {
                  console.log(`✅ 사용자 ${i}: 예약 성공 - ${data.message}`);
              } else {
                  console.log(`⏳ 사용자 ${i}: ${data.message}`);
              }
              return data;
          });
        
        bookingPromises.push(promise);
        
        // 10명씩 배치로 전송
        if (i % 10 === 0) {
            console.log(`📤 ${i}명 요청 전송...`);
            await new Promise(resolve => setTimeout(resolve, 500));
        }
    }
    
    const bookingResults = await Promise.all(bookingPromises);
    console.log('✅ 50명 예약 요청 완료');
    
    // 4단계: 결과 분석
    console.log('4️⃣ 결과 분석 중...');
    
    const queueCount = bookingResults.filter(r => r.message.includes('대기열')).length;
    const successCount = bookingResults.filter(r => r.message.includes('결제')).length;
    const waitingCount = bookingResults.filter(r => r.message.includes('순서')).length;
    
    console.log('📊 결과 요약:');
    console.log(`   - 대기열 입장: ${queueCount}명`);
    console.log(`   - 예약 성공: ${successCount}명`);
    console.log(`   - 대기 중: ${waitingCount}명`);
    
    // 5단계: 개별 사용자 상태 확인
    console.log('5️⃣ 상위 5명 사용자 상태 확인...');
    
    for (let i = 1; i <= 5; i++) {
        const userStatus = await fetch(`${baseUrl}/queue-status/${courseSeq}?memberNo=${i}`);
        const userData = await userStatus.json();
        console.log(`👤 사용자 ${i}:`, userData);
    }
    
    console.log('🎉 대기열 시뮬레이션 완료!');
}

// 시뮬레이션 실행
queueSimulation().catch(console.error);

// 실시간 모니터링 함수
function startQueueMonitoring(intervalSeconds = 5) {
    console.log(`📡 ${intervalSeconds}초마다 대기열 상태 모니터링 시작...`);
    
    const monitor = setInterval(async () => {
        try {
            const response = await fetch('http://localhost:9090/undongpedia/reservation/queue-status/1?memberNo=1');
            const data = await response.json();
            console.log(`⏰ ${new Date().toLocaleTimeString()} - 대기열 상태:`, data);
        } catch (error) {
            console.error('모니터링 오류:', error);
        }
    }, intervalSeconds * 1000);
    
    // 30초 후 모니터링 중지
    setTimeout(() => {
        clearInterval(monitor);
        console.log('📡 모니터링 중지');
    }, 30000);
}

// 사용법:
// 1. queueSimulation() - 대기열 시뮬레이션 실행
// 2. startQueueMonitoring() - 실시간 모니터링 시작 