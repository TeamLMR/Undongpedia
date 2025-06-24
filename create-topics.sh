# Kafka 컨테이너 이름
KAFKA_CONTAINER="kafka"

echo "=== Kafka 토픽 생성 시작 ==="

# 테스트용 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

# 예약 이벤트 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic reservation-events \
  --partitions 10 \
  --replication-factor 1 \
  --if-not-exists

# 결제 이벤트 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic payment-events \
  --partitions 5 \
  --replication-factor 1 \
  --if-not-exists

# 알림 이벤트 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic notification-events \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

# 좌석 잠금 이벤트 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic seat-lock-events \
  --partitions 5 \
  --replication-factor 1 \
  --if-not-exists

# 트랜잭션 테스트 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic transaction-test \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

# 배치 테스트 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic batch-test \
  --partitions 10 \
  --replication-factor 1 \
  --if-not-exists

# DLQ 토픽
docker exec -it $KAFKA_CONTAINER kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic reservation-events.DLT \
  --partitions 3 \
  --replication-factor 1 \
  --if-not-exists

echo "=== 토픽 목록 확인 ==="
docker exec -it $KAFKA_CONTAINER kafka-topics --list --bootstrap-server localhost:9092

echo "=== 토픽 생성 완료 ==="