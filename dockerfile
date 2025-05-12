FROM rabbitmq:3-management

# 1) 시간 동기화 설정: Asia/Seoul 타임존으로 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 2) TLS, AMQPS 활성화를 위한 설정 파일 복사
COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf