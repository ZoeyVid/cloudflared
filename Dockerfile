FROM --platform=${BUILDPLATFORM} golang:1.19.1-alpine3.16 as build

ARG CLOUDFLARED_VERSION=2022.8.4

ARG GO111MODULE=on
ARG CGO_ENABLED=0
ARG TARGETARCH
ARG TARGETOS
    
RUN apk add --no-cache ca-certificates git build-base
RUN git clone --recursive https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /src
WORKDIR /src
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make -j "$(nproc)" cloudflared

FROM alpine:3.16.2
RUN apk add --no-cache ca-certificates curl

COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

LABEL org.opencontainers.image.source="https://github.com/SanCraftDev/cloudflared"
ENTRYPOINT cloudflared --no-autoupdate --metrics localhost:9133 tunnel run --token ${token}

HEALTHCHECK CMD curl -skI localhost:9133 || exit 1
