FROM ubuntu:24.04 AS build

RUN apt-get update
RUN apt-get install -y --no-install-recommends clang llvm lld make ca-certificates git

ARG WASM_TOOLS_URL="https://github.com/bytecodealliance/wasm-tools/releases/download/v1.229.0/wasm-tools-1.229.0-aarch64-linux.tar.gz"
ARG WASM_RT_URL="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-25/libclang_rt.builtins-wasm32-wasi-25.0.tar.gz"

ADD $WASM_TOOLS_URL /tmp/wasm-tools.tar.gz
ADD $WASM_RT_URL /tmp/wasm-rt.tar.gz

RUN tar -xzf /tmp/wasm-tools.tar.gz -C /usr/local/bin --strip-components=1

WORKDIR /build
RUN git clone https://github.com/WebAssembly/wasi-libc

WORKDIR /build/wasi-libc
RUN make -j8
RUN mkdir -p /usr/lib/llvm-18/lib/clang/18/lib/wasi
RUN tar -xzf /tmp/wasm-rt.tar.gz -C /usr/lib/llvm-18/lib/clang/18/lib/wasi --strip-components=1

WORKDIR /build/src
COPY . .
RUN make

FROM scratch
COPY --from=build /build/src/calculator_world.wasm /
