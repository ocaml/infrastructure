---
title: opam.ocaml.org Deployment
---

# Basic Deployment

Opam is a single Docker container which exposes a website on port 80.  HTTPS is added using a reverse proxy such as NGINX or Caddy and an ACME provider such as Let's Encrypt.

Caddy offers automatic certificate generation and renewal, thus given a `Caddyfile` like this:

```
opam.ocaml.org {
    reverse_proxy opam_live:80
}
```

And a `docker-compose.yml` file, such as

```
version: "3.7"
services:
  caddy:  
    image: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /etc/caddy:/etc/caddy:ro
      - caddy_data:/data
      - caddy_config:/config
  opam_live:
    image: ocurrent/opam.ocaml.org:live
    sysctls:
      - 'net.ipv4.tcp_keepalive_time=60'
volumes:
  caddy_data:
  caddy_config:
```

The service can be available with Docker compose:

```shell
docker compose up
```

# Round-Robin DNS

Our deployment uses round-robin DNS with HTTP-01 challenges.  When the ACME client requests the validation challenge, the request may go to either machine, not necessarily the originator.  This is addressed by configuring each machine to send failed requests to `http://<YOUR_DOMAIN>/.well-known/acme-challenge/<TOKEN>` to the other machine.

NGINX allows this to be configured via the `try_files` directive, which supports a list of places to check.  Below is the configuration of `opam-4`, which shows that failed requests will be redirected to `opam-5`.  The configuration is reversed on `opam-5`.

```
server {
    server_name _;

    location @proxy {
        proxy_pass http://opam-5.ocaml.org;
    }

    location ^~ /.well-known/acme-challenge/ {
        default_type "text/plain";
        root         /var/www/html;
        try_files $uri @proxy;
        break;
    }

    location = /.well-known/acme-challenge/ {
        return 404;
    }

    location / {
      return 301 https://$host$request_uri;
    }
}
```

# Initial certificate setup for each machine

Copy the HTTP configuration file for NGINX (shown above) to both machines.  These files differ only in the `proxy_pass` configuration, with each machine pointing to the other.

```sh
scp nginx/opam-4-http.conf opam-4.ocaml.org:
scp nginx/opam-5-http.conf opam-5.ocaml.org:
```

On both machines, start NGINX

```
docker run --rm -it -p 80:80 -p 443:443 -v ~:/etc/nginx/conf.d:ro -v wwwroot:/var/www/html nginx
```

Create the certificates on both servers using Certbot.  The `--webroot` invocation tells Certbot to write the well-known challenge to the path provided `/var/www/html` which will be served over HTTP by NGINX.  As both are Docker containers, they communicate via a shared volume, `wwwroot`.  On `opam-5` create the certificate for `opam-5.ocaml.org` rather than `opam-4`.

```sh
for fqdn in opam-4.ocaml.org opam.ocaml.org staging.opam.ocaml.org ; do
docker run --rm -it -v wwwroot:/var/www/html -v letsencrypt:/etc/letsencrypt certbot/certbot certonly --webroot -m mark@tarides.com --agree-tos --no-eff-email -d $fqdn --webroot-path /var/www/html
done
```

Verify success by checking the certificates on the disk.

{% raw %}
    ls $(docker volume inspect --format '{{ .Mountpoint }}' letsencrypt)/live
{% endraw %}

The temporary NGINX containers can now be stopped.

# Certificate renewal

Using NGINX, we must renew the certificates manually.  This can be achieved via a daily cron job which runs `certbot renew`.  As we are running Certbot within a Docker container, we need to hook the deployment using an external file.  The renewal process is, therefore:

1) Remove `deploy` file from the Let's Encrypt Docker volume
2) Run `certbot renew` with `--deploy-hook "touch /etc/letsencrypt/deploy"`
3) Reload the NGINX configuration if the `deploy` file has been created

{% raw %}
    #!/bin/bash
    set -eux
    
    LEV="$(docker volume inspect --format '{{ .Mountpoint }}' letsencrypt)"
    rm -f $LEV/deploy
    
    systemtd-cat -t "certbot" docker run --rm -v wwwroot:/var/www/html -v letsencrypt:/etc/letsencrypt certbot/certbot renew --webroot -m mark@tarides.com --agree-tos --no-eff-email --webroot-path /var/www/html --deploy-hook "touch /etc/letsencrypt/deploy"
    
    if [ -f $LEV/deploy ] ; then
      PS=$(docker ps --filter=name=infra_nginx -q)
      if [ -n "$PS" ] ; then
        docker exec $PS nginx -s reload
      fi
    fi
{% endraw %}

# NGINX and new Docker containers

If the NGINX `proxy_pass` directive points to a specific host such as `proxy_pass http://opam_live`, then this is evaluated once when NGINX starts.  When the Docker container for the backend service is updated, the IP address will change, and NGINX will fail to reach the new container.  However, when you use a variable to specify the domain name in the `proxy_pass` directive, NGINX re‑resolves the domain name when its TTL expires. You must include the `resolver` directive to explicitly specify the name server.  Here 127.0.0.11 is the Docker name server.

```
    location / {
        resolver 127.0.0.11 [::1]:5353 valid=15s;
        set $opam_live "opam_live";
        proxy_pass http://$opam_live;
    }
```


# IPv6 Considerations

As noted for [www.ocaml.org](/www-ocaml-org), Docker does not listen on IPv6 addresses in swarm mode, and ACME providers check both A and AAAA records.  As we have NGINX operating as a reverse proxy, we can define NGINX as a global service with exactly one container per swarm node, and that the ports are in host mode, which publishes a host port on the node which does listen on IPv6.  In the Docker service configuration shown in the next section note `deploy: mode: global` and `ports: mode: host`.

# TCP BBR Congestion Control

Cubic has been the default TCP congestion algorithm on Linux since 2.6.19 with both MacOS and Microsoft also using it as the default.  Google proposed Bottleneck Bandwidth and Round-trip propagation time (BBR) in 2016 which has been available in the Linux kernel since 4.9.  It has been shown to generally achieve higher bandwidths and lower latencies.  Thanks to @jpds for the impletement details:

Add these two configuration commands to `/etc/sysctl.d/01-bbr.conf`:

```
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
```

and set them with

```sh
sudo sysctl -p /etc/sysctl.d/01-bbr.conf
```

# Ansible deployment

We use an Anisble playbook to manage the deployment to the two hosts.

{% raw %}
    - hosts: all
      name: Set up SwarmKit
      tasks:
        - docker_swarm:
            listen_addr: "127.0.0.1:2377"
            advertise_addr: "127.0.0.1:2377"
    
    - hosts: opam-4.ocaml.org:opam-5.ocaml.org
      tasks:
        - name: configure sysctl
          copy:
            src: "{{ item }}"
            dest: /etc/sysctl.d
          loop:
            - "sysctl/01-bbr.conf"
          notify:
            - reload sysctl settings
        - name: configure nginx
          copy:
            src: "{{ item }}"
            dest: /etc/nginx/conf.d
          loop:
        - name: create nginx directory
          file:
            path: /etc/nginx/conf.d
            state: directory
        - name: configure nginx
          copy:
            src: "{{ item }}"
            dest: /etc/nginx/conf.d
          loop:
            - "nginx/{{ inventory_hostname_short }}-http.conf"
            - "nginx/{{ inventory_hostname_short }}.conf"
            - "nginx/opam.conf"
            - "nginx/staging.conf"
          notify:
            - restart nginx
        - name: install certbot renewal script
          copy:
            src: letsencrypt-renew
            dest: /etc/cron.daily/letsencrypt-renew
            mode: u=rwx,g=rx,o=rx
        - name: Set up docker services
          docker_stack:
            name: infra
            compose:
              - version: "3.8"
                services:
                  nginx:
                    deploy:
                      mode: global
                    ports:
                      - target: 80
                        published: 80
                        protocol: tcp
                        mode: host
                      - target: 443
                        published: 443
                        protocol: tcp
                        mode: host
                    image: nginx
                    volumes:
                      - /etc/nginx/conf.d:/etc/nginx/conf.d:ro
                      - wwwroot:/var/www/html
                      - letsencrypt:/etc/letsencrypt:ro
                  opam_live:
                    image: ocurrent/opam.ocaml.org:live
                    command: --root /usr/share/caddy
                volumes:
                  wwwroot:
                    external: true
                  letsencrypt:
                    external: true
      handlers:
        - name: restart nginx
          shell:
            cmd: PS=$(docker ps --filter=name=infra_nginx -q) && if [ -n "$PS" ] ; then docker exec $PS nginx -s reload; fi
        - name: reload sysctl settings
          shell:
            cmd: sysctl --system
{% endraw %}
