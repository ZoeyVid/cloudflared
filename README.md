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
