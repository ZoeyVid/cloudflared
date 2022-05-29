FROM --platform=linux/amd64 alpine as build

ARG CLOUDFLARED_VERSION=2022.5.1 \
    TARGETOS \
    TARGETARCH \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}
    
RUN apk add --no-cache git build-base go
RUN go install golang.org/x/tools/gopls@latest
RUN git clone https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /src/cloudflared && \
    cd /src/cloudflared && \
    make -j "$(nproc)" cloudflared

FROM --platform=linux/amd64 scratch

COPY --from=build /src/cloudflared/cloudflared /cloudflared
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

CMD ["/cloudflared", "--no-autoupdate", "tunnel", "run", "--token", "${token}"]
