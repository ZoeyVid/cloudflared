FROM --platform=${BUILDPLATFORM} alpine:20221110 as build

ARG CLOUDFLARED_VERSION=2022.11.0

ARG GO111MODULE=on
ARG CGO_ENABLED=0
ARG TARGETARCH
ARG TARGETOS
    
RUN apk upgrade --no-cache
RUN apk add --no-cache ca-certificates wget tzdata git go make
RUN git clone --recursive https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /src
WORKDIR /src
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make -j "$(nproc)" cloudflared

FROM alpine:20221110
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata curl

COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT cloudflared --no-autoupdate --metrics localhost:9173 tunnel run --token ${token}
HEALTHCHECK CMD curl -skI localhost:9173 || exit 1
