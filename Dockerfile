FROM --platform=${BUILDPLATFORM} golang:1.21.6-alpine3.19 as build
ARG CLOUDFLARED_VERSION=2024.1.5    

RUN apk add --no-cache ca-certificates git build-base bash && \
    git clone --recursive https://github.com/cloudflare/cloudflared --branch "$CLOUDFLARED_VERSION" /src && \
    /src/.teamcity/install-cloudflare-go.sh

ARG CGO_ENABLED=0 \
    TARGETARCH \
    TARGETOS
RUN cd /src && \
    GOARCH="$TARGETARCH" GOOS="$TARGETOS" make -j "$(nproc)" cloudflared LINK_FLAGS="-s -w" && \
    file /src/cloudflared

FROM alpine:3.19.1
RUN apk add --no-cache ca-certificates tzdata tini curl
COPY --from=build /src/cloudflared /usr/local/bin/cloudflared
ENV NO_AUTOUPDATE=true
ENTRYPOINT ["tini", "--", "cloudflared", "--no-autoupdate", "--metrics", "localhost:9173"]
CMD ["tunnel", "run"]
HEALTHCHECK CMD curl -sI http://localhost:9173 -o /dev/null  || exit 1
