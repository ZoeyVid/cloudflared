FROM zoeyvid/cloudflared:latest as cloudflared

FROM alpine:3.20.0
COPY --from=cloudflared           /usr/local/bin/cloudflared /usr/local/bin/cloudflared
COPY --from=zoeyvid/curl-quic:388 /usr/local/bin/curl        /usr/local/bin/curl
RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata tini bind-tools
USER nobody
ENV NO_AUTOUPDATE=true
ENTRYPOINT ["tini", "--", "cloudflared", "--no-autoupdate", "--metrics", "localhost:9172", "proxy-dns", "--address", "0.0.0.0"]
CMD ["--upstream", "https://dns.adguard-dns.com/dns-query"]
HEALTHCHECK CMD ([ "$(dig example.org IN A +short @127.0.0.1 | grep '^[0-9.]\+$' | sort | head -n1)" = "$(dig example.org IN A +short +https +tls-ca=/etc/ssl/certs/ca-certificates.crt @1.1.1.1 | grep '^[0-9.]\+$' | sort | head -n1)" ] && curl -sI http://localhost:9172 -o /dev/null) || exit 1
EXPOSE 53/tcp
EXPOSE 53/udp
