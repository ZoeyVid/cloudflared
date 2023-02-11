# Cloudflared

If you want to connect to services outside Docker over localhost and inside docker, but exposed to localhost: <br>

```yml
version: "3"
services:
    cloudflared:
        container_name: cloudflared
        image: zoeyvid/cloudflared
        restart: always
        network_mode: host
        environment:
        - "TZ=Europe/Berlin"
        - "TUNNEL_TOKEN=your-cloudflared-tunnel-token"
```

If you want to add it to an exiting composer stack: <br>

```yml
    service-name-cloudflared:
        image: zoeyvid/cloudflared
        container_name: service-name-cloudflared
        restart: always
        environment:
        - "TZ=Europe/Berlin"
        - "TUNNEL_TOKEN=your-cloudflared-tunnel-token"
        links:
        - web-container-name # set here the name of the container the web service runs on, you dont need to expose its web ports
```

To get your Token, register here and add your domain to Cloudflare: https://dash.cloudflare.com <br>
Then register here: https://one.dash.cloudflare.com <br>
And generate a token under: Access ⇾ Tunnel ⇾ Create Tunnel <br>
Now you can copy it and set the token in the command / compose file (replace your-cloudflared-tunnel-token with the token) <br>
Then you can set a public host on https://dash.cloudflare.com: Access ⇾ Tunnel ⇾ Configure Tunnel <br>
There you can set the address of the web source with its port (localhost:port for the network_mode: host version OR web-container-name:port for the second version) and the protocols (http / https - NO valid https certificate is required), then you can set above this the domain it should run on, and then you are done! <br>

## Run custom cloudflared commands:
```yml
version: "3"
services:
    cloudflared:
        container_name: cloudflared
        image: zoeyvid/cloudflared
        restart: always
        network_mode: host
        environment:
        - "TZ=Europe/Berlin"
        command: <command>

```

# Cloudflared-DNS

```yml
version: "3"
services:
    cloudflared:
        container_name: cloudflared-dns
        image: zoeyvid/cloudflared-dns
        restart: always
        ports:
        - "127.0.0.1:53:53"
        - "127.0.0.1:53:53/udp"
        - "[::1]:53:53"
        - "[::1]:53:53/udp"
        environment:
        - "TZ=Europe/Berlin"
        dns:
        - 9.9.9.9
        - 149.112.112.112
        - 2620:fe::fe
        - 2620:fe::fe:9
        - 1.1.1.2
        - 1.0.0.2
        - 2606:4700:4700::1112
        - 2606:4700:4700::1002
        - 94.140.14.14
        - 94.140.15.15
        - 2a10:50c0::ad1:ff
        - 2a10:50c0::ad2:ff
        command: --upstream https://dns.adguard-dns.com/dns-query
```

## Disable systemd-resolved (used on debian)
```sh
systemctl disable --now systemd-resolved
rm -rf /etc/resolv.conf
echo nameserver 127.0.0.1 >> /etc/resolv.conf
```
