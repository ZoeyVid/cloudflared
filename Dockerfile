FROM --platform=${BUILDPLATFORM} golang:1.20.1-alpine3.17 as build
ARG CLOUDFLARED_VERSION=2023.3.0

ARG GO111MODULE=on
ARG CGO_ENABLED=0
ARG TARGETARCH
ARG TARGETOS
    
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates tzdata git build-base && \
    git clone --recursive https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src
WORKDIR /src
RUN GOOS="$TARGETOS" GOARCH="$TARGETARCH" make -j "$(nproc)" cloudflared

FROM alpine:3.17.2
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates tzdata curl

COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT ["cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
