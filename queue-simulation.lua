-- 대기열 시뮬레이션 테스트 스크립트
counter = 0
courseSeq = 20  -- 테스트할 강의 번호

request = function()
    counter = counter + 1
    local memberNo = counter
    
    -- 3가지 요청을 순환: 하트비트 -> 하트비트 -> 예약시도
    local requestType = counter % 3
    
    if requestType == 1 then
        -- 하트비트 전송 (활성 사용자로 등록)
        local body = string.format('{"courseSeq":%d,"memberNo":%d}', courseSeq, memberNo)
        return wrk.format("POST", "/undongpedia/reservation/heartbeat", 
                         {"Content-Type: application/json"}, body)
                         
    elseif requestType == 2 then
        -- 추가 하트비트 (활성 사용자 유지)
        local body = string.format('{"courseSeq":%d,"memberNo":%d}', courseSeq, memberNo)
        return wrk.format("POST", "/undongpedia/reservation/heartbeat", 
                         {"Content-Type: application/json"}, body)
    else
        -- 예약 시도 (대기열 테스트)
        local body = string.format('{"courseSeq":%d,"scheduleId":1,"memberNo":%d}', courseSeq, memberNo)
        return wrk.format("POST", "/undongpedia/reservation/book", 
                         {"Content-Type: application/json"}, body)
    end
end

response = function(status, headers, body)
    -- 안전한 응답 처리
    if status == 200 and body then
        -- JSON 응답인지 확인
        if body:find("{") and body:find("}") then
            if body:find("대기열에 입장했습니다") then
                print("🎯 대기열 입장")
            elseif body:find("결제를 진행해주세요") then
                print("✅ 예약 성공")
            elseif body:find("대기열 순서") then
                print("⏳ 대기 중")
            elseif body:find("success") then
                print("📊 응답 수신")
            end
        else
            -- HTML 응답인 경우 무시
            print("📄 HTML 응답 (무시)")
        end
    elseif status ~= 200 then
        print("❌ HTTP " .. status .. " 에러")
    end
end

done = function(summary, latency, requests)
    print("\n=== 대기열 시뮬레이션 완료 ===")
    print("총 요청 수: " .. summary.requests)
    print("성공 요청: " .. (summary.requests - summary.errors.connect - summary.errors.read - summary.errors.write - summary.errors.status - summary.errors.timeout))
    
    -- 대기열 상태 확인
    os.execute("echo '\n=== 최종 대기열 상태 확인 ==='")
    os.execute("curl -s 'http://localhost:9090/undongpedia/reservation/queue-status/1?memberNo=1' | jq")
end 