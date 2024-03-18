
FROM ubuntu:22.04 as builder

RUN apt-get update && apt-get install -y build-essential gawk wget \
    file git patch wget curl sudo iproute2 libcap2-bin autoconf automake \
    make cmake gcc g++ ccache libtool openssl zlib1g-dev libssl-dev libxml2 libxml2-dev vim

ARG TARGET_PLATFORM="libc"
