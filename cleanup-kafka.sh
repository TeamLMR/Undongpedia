# 토픽 삭제
topics=("test-topic" "reservation-events" "payment-events" "notification-events" "seat-lock-events" "transaction-test" "batch-test" "reservation-events.DLT")

for topic in "${topics[@]}"; do
    echo "삭제 중: $topic"
    docker exec kafka kafka-topics --bootstrap-server localhost:9092 --delete --topic $topic
done

# 잠시 대기
sleep 5

# 토픽 재생성
./create-topics.sh