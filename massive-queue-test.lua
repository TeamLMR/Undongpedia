-- 대규모 대기열 테스트 (1000명+ 사용자)
counter = 0

request = function()
    counter = counter + 1
    local memberNo = counter % 1000 + 1  -- 1-1000명 사이 순환
    
    -- 하트비트만 전송 (가장 안전)
    if counter % 3 == 1 then
        local body = string.format('{"courseSeq":20,"memberNo":%d}', memberNo)
        return wrk.format("POST", "/undongpedia/reservation/heartbeat", 
                         {["Content-Type"] = "application/json"}, body)
    -- 예약 요청
    else
        local body = string.format('{"courseSeq":20,"scheduleId":1,"memberNo":%d}', memberNo)
        return wrk.format("POST", "/undongpedia/reservation/book", 
                         {["Content-Type"] = "application/json"}, body)
    end
end

response = function(status, headers, body)
    -- 간단한 카운팅만
    if status == 200 then
        if counter % 1000 == 0 then  -- 1000번마다 출력
            print("✅ " .. counter .. "번째 요청 완료")
        end
    else
        print("❌ " .. status)
    end
end

done = function(summary, latency, requests)
    print("\n=== 대규모 테스트 완료 ===")
    print("총 요청: " .. summary.requests)
    print("에러: " .. (summary.errors.connect + summary.errors.read + summary.errors.write + summary.errors.status + summary.errors.timeout))
    print("성공률: " .. math.floor((summary.requests - summary.errors.connect - summary.errors.read - summary.errors.write - summary.errors.status - summary.errors.timeout) / summary.requests * 100) .. "%")
    print("예상 대기열 사용자 수: 최대 1000명")
end 