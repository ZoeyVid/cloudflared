FROM --platform=linux/amd64 golang:alpine as build

ARG CLOUDFLARED_VERSION=2022.5.1 \
    TARGETOS \
    TARGETARCH \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH}
    
RUN apk add --no-cache git build-base
RUN go install golang.org/x/tools/gopls@latest
RUN git clone https://github.com/cloudflare/cloudflared --branch ${CLOUDFLARED_VERSION} /src
RUN cd /src && \
    make -j "$(nproc)" cloudflared

FROM alpine
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared

ENTRYPOINT ["cloudflared", "--no-autoupdate", "tunnel", "run", "--token", "${token}"]
