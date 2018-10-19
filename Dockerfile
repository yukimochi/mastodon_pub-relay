FROM alpine:3.8

RUN apk -U --no-cache add ca-certificates
COPY bin/server bin/worker /usr/bin/
COPY ./spec/test_actor.pem /actor.pem
