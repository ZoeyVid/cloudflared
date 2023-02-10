FROM --platform=${BUILDPLATFORM} golang:1.19.5-alpine3.17 as build
ARG CLOUDFLARED_VERSION=2023.2.1

ARG GO111MODULE=on
ARG CGO_ENABLED=0
ARG TARGETARCH
ARG TARGETOS
    
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata git build-base && \
    git clone --recursive https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src
WORKDIR /src
RUN GOOS="$TARGETOS" GOARCH="$TARGETARCH" make -j "$(nproc)" cloudflared

FROM alpine:3.17.1
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata curl

COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT ["cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -skI localhost:9173 || exit 1
