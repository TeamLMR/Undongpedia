-- 🔥 극한 스트레스 테스트 - 10000명 사용자 시뮬레이션
counter = 0
start_time = os.time()

request = function()
    counter = counter + 1
    local memberNo = counter % 10000 + 1  -- 1-10000명 사이 순환
    
    -- 더 공격적인 요청 패턴 (80% 예약 요청, 20% 하트비트)
    if counter % 5 == 1 then
        -- 하트비트
        local body = string.format('{"courseSeq":20,"memberNo":%d}', memberNo)
        return wrk.format("POST", "/undongpedia/reservation/heartbeat", 
                         {["Content-Type"] = "application/json"}, body)
    else
        -- 예약 요청 (더 많은 비율)
        local body = string.format('{"courseSeq":20,"scheduleId":1,"memberNo":%d}', memberNo)
        return wrk.format("POST", "/undongpedia/reservation/book", 
                         {["Content-Type"] = "application/json"}, body)
    end
end

response = function(status, headers, body)
    if status == 200 then
        if counter % 5000 == 0 then  -- 5000번마다 출력
            local elapsed = os.time() - start_time
            local rps = counter / elapsed
            print(string.format("🔥 %d번째 요청 완료 - RPS: %.0f", counter, rps))
        end
    elseif status == 429 then
        print("⚡ 대기열 활성화됨!")
    elseif status >= 500 then
        print("💥 서버 에러: " .. status)
    end
end

done = function(summary, latency, requests)
    print("\n🔥🔥🔥 극한 스트레스 테스트 완료 🔥🔥🔥")
    print("총 요청: " .. summary.requests)
    print("총 에러: " .. (summary.errors.connect + summary.errors.read + summary.errors.write + summary.errors.status + summary.errors.timeout))
    print("성공률: " .. math.floor((summary.requests - summary.errors.connect - summary.errors.read - summary.errors.write - summary.errors.status - summary.errors.timeout) / summary.requests * 100) .. "%")
    print("평균 RPS: " .. math.floor(summary.requests / (summary.duration / 1000000)))
    print("평균 지연시간: " .. string.format("%.2fms", latency.mean / 1000))
    print("최대 지연시간: " .. string.format("%.2fms", latency.max / 1000))
    print("예상 대기열 사용자: 최대 10,000명 💀")
end 