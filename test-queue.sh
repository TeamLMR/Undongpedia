#!/bin/bash

echo "🚀 대기열 시뮬레이션 시작!"
echo "==============================="

# 서버 확인
echo "1️⃣ 서버 상태 확인..."
curl -s http://localhost:9090/undongpedia/reservation/20 > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ 서버 정상 동작 중"
else
    echo "❌ 서버가 실행되지 않았습니다. 서버를 먼저 시작해주세요."
    exit 1
fi

echo ""
echo "2️⃣ 단계 1: 활성 사용자 30명 생성 (하트비트 전송)"
echo "----------------------------------------"

# 30명의 사용자가 하트비트 전송
for i in {1..30}
do
    curl -s -X POST http://localhost:9090/undongpedia/reservation/heartbeat \
         -H "Content-Type: application/json" \
         -d "{\"courseSeq\":1,\"memberNo\":$i}" > /dev/null &
done

# 모든 하트비트가 완료될 때까지 대기
wait
echo "✅ 30명의 활성 사용자 하트비트 전송 완료"

echo ""
echo "3️⃣ 단계 2: 현재 활성 사용자 수 확인"
echo "--------------------------------"

# 대기열 상태 확인
response=$(curl -s "http://localhost:9090/undongpedia/reservation/queue-status/1?memberNo=1")
echo "📊 현재 상태: $response"

echo ""
echo "4️⃣ 단계 3: 동시 예약 요청 (50명)"
echo "-----------------------------"

# 50명이 동시에 예약 요청
for i in {1..50}
do
    curl -s -X POST http://localhost:9090/undongpedia/reservation/book \
         -H "Content-Type: application/json" \
         -d "{\"courseSeq\":20,\"scheduleId\":1,\"memberNo\":$i}" &
    
    # 10명씩 배치로 나누어 전송
    if [ $((i % 10)) -eq 0 ]; then
        echo "📤 $i명 예약 요청 전송..."
        sleep 1
    fi
done

# 모든 요청 완료 대기
wait
echo "✅ 50명 예약 요청 완료"

echo ""
echo "5️⃣ 단계 4: 최종 대기열 상태 확인"
echo "-----------------------------"

# 여러 사용자의 대기열 상태 확인
for i in {1..5}
do
    echo "👤 사용자 $i 상태:"
    curl -s "http://localhost:9090/undongpedia/reservation/queue-status/1?memberNo=$i" | jq
    echo ""
done

echo ""
echo "6️⃣ 단계 5: Redis 데이터 직접 확인 (선택사항)"
echo "----------------------------------------"
echo "Redis CLI에서 다음 명령어로 확인 가능:"
echo "redis-cli ZCARD heartBeat:course:1"
echo "redis-cli ZCARD queue:course:1"
echo "redis-cli ZRANGE queue:course:1 0 -1 WITHSCORES"

echo ""
echo "🎉 대기열 시뮬레이션 완료!"
echo "===============================" 