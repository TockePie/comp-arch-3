FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    qemu-system-arm \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
