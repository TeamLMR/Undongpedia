echo "Redis 데이터 정리 중..."

# 패턴별로 삭제
patterns=("seat:*" "lock:*" "test:*" "user:*" "queue:*" "ranking:*" "cache:*" "points:*")

for pattern in "${patterns[@]}"; do
    echo "삭제 중: $pattern"
    docker exec redis redis-cli --scan --pattern "$pattern" | xargs -r docker exec redis redis-cli DEL
done

echo "Redis 정리 완료!"