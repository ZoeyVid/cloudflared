FROM --platform=${BUILDPLATFORM} golang:1.20.7-alpine3.18 as build
ARG CLOUDFLARED_VERSION=2023.7.3 \
    TARGETARCH

RUN apk add --no-cache ca-certificates git build-base && \
    git clone --recursive https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src && \
    cd /src && \
    GOARCH="$TARGETARCH" GO111MODULE=on CGO_ENABLED=0 make -j "$(nproc)" cloudflared

FROM alpine:3.18.2
RUN apk add --no-cache ca-certificates tzdata curl
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared
ENTRYPOINT ["cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
