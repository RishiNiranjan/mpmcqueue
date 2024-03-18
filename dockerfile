
FROM ubuntu:22.04 as builder

RUN apt-get update && apt-get install -y build-essential 

ARG TARGET_PLATFORM="libc"
