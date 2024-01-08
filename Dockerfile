FROM --platform=${BUILDPLATFORM} golang:1.21.5-alpine3.19 as build
ARG CLOUDFLARED_VERSION=2024.1.0 \
    TARGETARCH

RUN apk add --no-cache ca-certificates git build-base && \
    git clone --recursive https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src && \
    cd /src && \
    GOARCH="$TARGETARCH" GO111MODULE=on CGO_ENABLED=0 make -j "$(nproc)" cloudflared

FROM alpine:3.19.0
RUN apk add --no-cache ca-certificates tzdata tini curl
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared
ENTRYPOINT ["tini", "--", "cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
