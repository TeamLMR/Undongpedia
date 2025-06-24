counter = 0

request = function()
    counter = counter + 1
    local userId = "user" .. counter
    local seatId = "VIP-" .. (math.random(1, 10))

    local path = string.format(
        "/undongpedia/test/integrated/reservation?userId=%s&seatId=%s",
        userId, seatId
    )
    return wrk.format("POST", path)
end

done = function(summary, latency, requests)
    os.execute("curl -s http://localhost:9090/undongpedia/test/integrated/stats | jq")
end