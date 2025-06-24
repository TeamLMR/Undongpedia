#!/bin/bash
# monitor-integrated.sh

while true; do
    clear
    echo "=== 통합 테스트 실시간 모니터링 ==="

    # 통계 조회
    curl -s http://localhost:9090/undongpedia/test/integrated/stats | jq

    echo ""
    echo "=== Redis 상태 ==="
    echo "예약된 좌석: $(docker exec redis redis-cli --scan --pattern "seat:*" | wc -l)"

    echo ""
    echo "=== Kafka 상태 ==="
    echo "Reservation Events:"
    docker exec kafka kafka-run-class kafka.tools.GetOffsetShell \
        --broker-list localhost:9092 --topic reservation-events | tail -1

    echo "Payment Events:"
    docker exec kafka kafka-run-class kafka.tools.GetOffsetShell \
        --broker-list localhost:9092 --topic payment-events | tail -1

    sleep 2
done