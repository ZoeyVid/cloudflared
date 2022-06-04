FROM --platform=${BUILDPLATFORM} golang:1.18.3-alpine3.16 as build

ARG CLOUDFLARED_VERSION=2022.5.3

ARG GO111MODULE=on
ARG CGO_ENABLED=0
ARG TARGETARCH
ARG TARGETOS
    
RUN apk add --no-cache ca-certificates git build-base
RUN go install golang.org/x/tools/gopls@latest
RUN git clone --recursive https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /src
WORKDIR /src
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make -j "$(nproc)" cloudflared

FROM alpine:3.16.0
RUN apk add --no-cache ca-certificates
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT cloudflared --no-autoupdate tunnel run --token ${token}
