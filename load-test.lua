counter = 0
request = function()
    counter = counter + 1
    local userId = "user" .. counter
    local seatId = "SEAT-" .. math.random(1, 100) .. "-" .. math.random(1, 50)
    local path = "/undongpedia/test/scenario/complete-reservation?userId=" .. userId .. "&seatId=" .. seatId
    return wrk.format("POST", path)
end