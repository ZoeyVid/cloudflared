FROM --platform=${BUILDPLATFORM} golang:alpine as build
ARG CLOUDFLARED_VERSION=2022.5.1 \
    TARGETOS \
    TARGETARCH \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}
RUN apk add --no-cache git build-base && \
    go install golang.org/x/tools/gopls@latest && \
    git clone https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /src/cloudflared && \
    cd /src/cloudflared && \
    make -j "$(nproc)" cloudflared

FROM scratch
COPY --from=build /src/cloudflared/cloudflared /usr/local/bin/cloudflared
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["cloudflared", "--no-autoupdate", "tunnel", "run", "--token"]
CMD ["${token}"]
