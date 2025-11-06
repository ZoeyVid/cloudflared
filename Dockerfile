# syntax=docker/dockerfile:labs
FROM --platform=${BUILDPLATFORM} golang:1.25.4-alpine3.21 AS build
ARG CLOUDFLARED_VERSION=2025.10.1

ARG TARGETARCH
ARG TARGETOS

ARG CGO_ENABLED=0
RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates git build-base bash && \
    git clone --depth 1 https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src && \
    cd /src && \
    GOARCH="$TARGETARCH" GOOS="$TARGETOS" make -j "$(nproc)" cloudflared LINK_FLAGS="-s" && \
    file /src/cloudflared

FROM alpine:3.22.2
RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata tini curl
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared
USER nobody
ENV NO_AUTOUPDATE=true
ENTRYPOINT ["tini", "--", "cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
