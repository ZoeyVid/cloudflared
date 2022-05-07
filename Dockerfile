FROM golang:alpine as build
ARG CLOUDFLARED_VERSION=2022.5.0 \
    TARGETOS \
    TARGETARCH \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}
RUN apk add git build-base && \
    go install golang.org/x/tools/gopls@latest && \
    git clone https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /cloudflared && \
    cd /cloudflared && make -j2 cloudflared

FROM alpine
COPY --from=build /cloudflared/cloudflared /cloudflared

ENTRYPOINT /cloudflared --no-autoupdate tunnel run --token ${token}
