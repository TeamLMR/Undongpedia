counter = 0

request = function()
    counter = counter + 1
    local userId = "user" .. counter
    local seatId = "VIP-1-1"  -- 모두가 같은 좌석을 노림!

    local path = string.format(
        "/undongpedia/test/redis/seat-reservation?userId=%s&seatId=%s",
        userId, seatId
    )
    return wrk.format("POST", path)
end

response = function(status, headers, body)
    if status == 200 and body:find("예약 완료") then
        print("🎉 성공! " .. body)
    end
end