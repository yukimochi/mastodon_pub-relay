FROM alpine:3.8 AS builder

WORKDIR /pub_relay

COPY shard.yml shard.lock /pub_relay/

RUN apk -U upgrade && \
    apk add build-base openssl-dev crystal shards llvm5-dev llvm5-static && \
    shards install --production

COPY . /pub_relay/

RUN echo 'require "llvm/lib_llvm"; require "llvm/enums"; require "./src/server"' > hack_server.cr && \
    echo 'require "llvm/lib_llvm"; require "llvm/enums"; require "./src/worker"' > hack_worker.cr && \
    mkdir -p bin && \
    crystal build hack_server.cr --static -o bin/server && \
    crystal build hack_worker.cr --static -o bin/worker

FROM alpine:3.8

RUN apk -U --no-cache add ca-certificates
COPY --from=builder /pub_relay/bin/server /pub_relay/bin/worker /usr/bin/
COPY ./spec/test_actor.pem /actor.pem
