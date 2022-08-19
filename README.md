# Cloudflared

If you want to connect to services outside Docker over localhost and inside docker, but exposed to localhost: <br>

```yml
version: "3"
services:
    cloudflared:
        container_name: cloudflared
        image: sancraftdev/cloudflared:latest
#        image: sancraftdev/cloudflared:develop
        restart: always
        network_mode: host
        environment:
        - "TZ=Europe/Berlin"
        - "token=your-cloudflared-tunnel-token"
```
<br>
Or run: 

```sh
docker run -e "TZ=Europe/Berlin" -e "token=your-cloudflare-tunnel-token" --net host --restart always --name cloudflared sancraftdev/cloudflared:latest
```
For development version run: 

```sh
docker run -e "TZ=Europe/Berlin" -e "token=your-cloudflare-tunnel-token" --net host --restart always --name cloudflared sancraftdev/cloudflared:develop
```

If you want to add it to an exiting composer stack: <br>

```yml
    service-name-cloudflared:
        image: sancraftdev/cloudflared:latest
#        image: sancraftdev/cloudflared:develop
        container_name: service-name-cloudflared
        restart: always
        environment:
        - "TZ=Europe/Berlin"
        - "token=your-cloudflared-tunnel-token"
        links:
        - web-container-name # set here the name of the container the web service runs on, you dont need to expose its web ports
```

To get your Token, register here and add your domain to Cloudflare: https://dash.cloudflare.com <br>
Then register here: https://dash.teams.cloudflare.com <br>
And generate a token under: Access ⇾ Tunnel ⇾ Create Tunnel <br>
Now you can copy it and set the token in the command / compose file (replace your-cloudflared-tunnel-token with the token) <br>
Then you can set a public host on https://dash.cloudflare.com: Access ⇾ Tunnel ⇾ Configure Tunnel <br>
There you can set the address of the web source with its port (127.0.0.1:port for the network_mode: host version OR web-container-name:port for the second version) and the protocols (http / https - NO valid https certificate is required), then you can set above this the domain it should run on, and then you are done!

## Run custom cloudflared commands:
```yml
version: "3"
services:
    cloudflared:
        container_name: cloudflared
        image: sancraftdev/cloudflared:latest
#        image: sancraftdev/cloudflared:develop
        restart: always
        network_mode: host
        environment:
        - "TZ=Europe/Berlin"
        entrypoint: cloudflared
        command: --no-autoupdate --metrics localhost:9133 # command to execute after cloudflared --no-autoupdate --metrics localhost:9133 

```
```sh
docker run -e "TZ=Europe/Berlin" --net host --restart always --name cloudflared --entrypoint cloudflared sancraftdev/cloudflared:latest --no-autoupdate --metrics localhost:9133  # add args here after "--no-autoupdate" you want to run after "cloudflared --no-autoupdate --metrics localhost:9133 "
```
