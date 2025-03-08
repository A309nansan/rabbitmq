#!/bin/bash

# 이 파일은 Jenkins에서 Execute Shell에 작성한 script 내용입니다.

# 명령어 실패 시 스크립트 종료
set -euo pipefail

# 로그 출력 함수
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# 에러 발생 시 로그와 함께 종료하는 함수
error() {
  log "Error on line $1"
  exit 1
}

trap 'error $LINENO' ERR

log "스크립트 실행 시작."

# docker network 생성
if docker network ls --format '{{.Name}}' | grep -q '^nansan-network$'; then
  log "Docker network named 'nansan-network' is already existed."
else
  log "Docker network named 'nansan-network' is creating..."
  docker network create --driver bridge nansan-network
fi

# 기존 rabbitmq 이미지를 삭제하고 새로 빌드
log "rabbitmq image remove and build."
docker rmi rabbitmq:latest || true
docker build -t rabbitmq:latest .

# Docker로 rabbitmq 서비스 실행
log "Execute rabbitmq..."
docker run -d \
  --name rabbitmq \
  --restart unless-stopped \
  -e RABBITMQ_DEFAULT_USER=${RABBITMQ_DEFAULT_USER} \
  -e RABBITMQ_DEFAULT_PASS=${RABBITMQ_DEFAULT_PASS} \
  -p 15672:15672 \
  -v /var/rabbitmq:/var/lib/rabbitmq \
  --network nansan-network \
  rabbitmq:latest

echo "작업이 완료되었습니다."
