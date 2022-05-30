FROM --platform=${BUILDPLATFORM} golang:alpine as build

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

FROM alpine
RUN apk add --no-cache ca-certificates
RUN rm -rf /var/cache/apk/*
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT ["sh", "-c", "cloudflared", "--no-autoupdate"]
CMD ["tunnel", "run", "--token", "${token}"]
