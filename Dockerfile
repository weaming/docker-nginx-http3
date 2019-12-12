FROM alpine:3.10

RUN apk add alpine-sdk
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-host x86_64-unknown-linux-musl --default-toolchain nightly -y
RUN apk add bash cmake perl libunwind go

# build nginx
WORKDIR /build
COPY . .
RUN bash build-nginx-with-http3.sh

CMD ["/usr/local/nginx/nginx"]