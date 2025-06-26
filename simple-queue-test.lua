-- 간단한 대기열 테스트 (에러 방지)
counter = 0

request = function()
    counter = counter + 1
    local memberNo = counter % 100 + 1  -- 1-100 사이 순환
    
    -- 하트비트만 전송 (가장 안전)
    if counter % 3 == 1 then
        local body = string.format('{"courseSeq":1,"memberNo":%d}', memberNo)
        return wrk.format("POST", "/undongpedia/reservation/heartbeat", 
                         {["Content-Type"] = "application/json"}, body)
    -- 예약 요청
    else
        local body = string.format('{"courseSeq":1,"scheduleId":1,"memberNo":%d}', memberNo)
        return wrk.format("POST", "/undongpedia/reservation/book", 
                         {["Content-Type"] = "application/json"}, body)
    end
end

response = function(status, headers, body)
    -- 단순히 상태 코드만 체크
    if status == 200 then
        print("✅ " .. counter)
    elseif status == 302 then
        print("🔄 리다이렉트")
    else
        print("❌ " .. status)
    end
end

done = function(summary, latency, requests)
    print("\n=== 테스트 완료 ===")
    print("총 요청: " .. summary.requests)
    print("에러: " .. (summary.errors.connect + summary.errors.read + summary.errors.write + summary.errors.status + summary.errors.timeout))
    print("성공률: " .. math.floor((summary.requests - summary.errors.connect - summary.errors.read - summary.errors.write - summary.errors.status - summary.errors.timeout) / summary.requests * 100) .. "%")
end 