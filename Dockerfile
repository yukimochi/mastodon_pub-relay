FROM debian:9-slim AS jemalloc

ENV JEMALLOC_VER 5.1.0

RUN mkdir /rootfs

RUN apt-get update && \
    apt-get -y install --no-install-recommends build-essential bzip2 ca-certificates curl && \
    curl -L https://github.com/jemalloc/jemalloc/releases/download/$JEMALLOC_VER/jemalloc-$JEMALLOC_VER.tar.bz2 | tar jx && \
    cd jemalloc-$JEMALLOC_VER && \
    ./configure --prefix=/rootfs && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install

FROM ubuntu

COPY --from=jemalloc /rootfs /

RUN apt-get update && \
    apt-get -y install --no-install-recommends ca-certificates llvm libgmp-dev libz-dev libssl1.0-dev libevent-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
COPY bin/pub-relay /usr/bin/
COPY ./spec/test_actor.pem /actor.pem
