#!/bin/bash

# 대기열 테스트 스크립트
BASE_URL="http://localhost:8080/undongpedia"
COURSE_SEQ=20
SCHEDULE_ID=2

echo "🚀 대기열 시스템 테스트 시작"
echo "================================"

# 테스트 함수들
test_join_queue() {
    local member_no=$1
    echo "👤 사용자 $member_no - 대기열 진입 테스트"
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "{\"courseSeq\": $COURSE_SEQ, \"memberNo\": $member_no}" \
        "$BASE_URL/reservation/join-course-queue")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 대기열 진입 성공: $body"
    else
        echo "❌ 대기열 진입 실패 ($http_code): $body"
    fi
    echo ""
}

test_heartbeat() {
    local member_no=$1
    echo "💓 사용자 $member_no - 하트비트 전송"
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "{\"courseSeq\": $COURSE_SEQ, \"memberNo\": $member_no}" \
        "$BASE_URL/reservation/heartbeat")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 하트비트 성공: $body"
    else
        echo "❌ 하트비트 실패 ($http_code): $body"
    fi
    echo ""
}

test_queue_status() {
    echo "📊 대기열 상태 조회"
    
    response=$(curl -s -w "\n%{http_code}" -X GET \
        "$BASE_URL/reservation/queue-stats/$COURSE_SEQ")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 상태 조회 성공: $body"
    else
        echo "❌ 상태 조회 실패 ($http_code): $body"
    fi
    echo ""
}

test_booking() {
    local member_no=$1
    echo "🎫 사용자 $member_no - 예약 요청"
    
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d "{\"courseSeq\": $COURSE_SEQ, \"scheduleId\": $SCHEDULE_ID, \"memberNo\": $member_no}" \
        "$BASE_URL/reservation/book")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 예약 요청 성공: $body"
    else
        echo "❌ 예약 요청 실패 ($http_code): $body"
    fi
    echo ""
}

# 동시 대기열 진입 테스트
echo "🎯 테스트 1: 동시 대기열 진입 (10명)"
echo "-----------------------------------"
for i in {9001..9010}; do
    test_join_queue $i &
done
wait
echo "대기열 진입 테스트 완료"
echo ""

# 대기열 상태 확인
test_queue_status

# 하트비트 테스트
echo "🎯 테스트 2: 하트비트 전송"
echo "-------------------------"
for i in {9001..9005}; do
    test_heartbeat $i
    sleep 1
done

# 대기열 상태 재확인
test_queue_status

# 예약 요청 테스트
echo "🎯 테스트 3: 예약 요청 (5명 동시)"
echo "--------------------------------"
for i in {8001..8005}; do
    test_booking $i &
done
wait
echo "예약 요청 테스트 완료"
echo ""

# 최종 상태 확인
test_queue_status

echo "🏁 모든 테스트 완료!" 