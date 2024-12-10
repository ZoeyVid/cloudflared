# syntax=docker/dockerfile:labs
FROM --platform=${BUILDPLATFORM} golang:1.23.4-alpine3.21 AS build
ARG CLOUDFLARED_VERSION=2024.12.1

RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates git build-base bash && \
    git clone --recursive https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src && \
    /src/.teamcity/install-cloudflare-go.sh && \
    go version

ARG PATH="/tmp/go/bin:$PATH" \
    CGO_ENABLED=0 \
    TARGETARCH \
    TARGETOS
RUN cd /src && \
    go version && \
    GOARCH="$TARGETARCH" GOOS="$TARGETOS" make -j "$(nproc)" cloudflared LINK_FLAGS="-s -w" && \
    file /src/cloudflared

FROM alpine:3.21.0
RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata tini curl
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared
USER nobody
ENV NO_AUTOUPDATE=true
ENTRYPOINT ["tini", "--", "cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
