---
title: OCaml.org Deployment
---

OCaml.org is a single Docker container which exposes the website on port 8080.  Therefore, the simplest deployment is to just run:

```shell
docker run --rm -it -p 8080:8080 ocurrent/v3.ocaml.org-server:live
```

This makes the website available at http://127.0.0.1:8080.

To provide HTTPS, a reverse proxy can be used such as Nginx or Caddy.  We use Caddy as it has automatic certificate provisioning and renewal.

The `Caddyfile` lists the expected domain names and the internal name of the Docker container.  The complete file is shown below.

```
v3a.ocaml.org, v3b.ocaml.org, v3.ocaml.org, ocaml.org, www.ocaml.org {
	reverse_proxy www:8080
}
```

Both Caddy and the website itself can be deployed using Docker Compose with a `docker-compose.yml` file as below.

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
  www:
    image: ocurrent/v3.ocaml.org-server:live
    sysctls:
      - 'net.ipv4.tcp_keepalive_time=60'
volumes:
  caddy_data:
  caddy_config:
```

Create the service as follows:

```shell
docker compose up
```

We use [OCurrent Deployer](https://deploy.ci.ocaml.org) to build the website Docker image from GitHub and deploy the update to the machine.

The update process uses `docker service update --image ocurrent/v3.ocaml.org-server` which requires Docker to be in swarm mode.  If the machine has an IPv6 address published in DNS, special care is needed as `docker swarm init` [does not listen on IPv6 addresses](https://github.com/moby/moby/issues/24379) and ACME providers check the published AAAA records point to the target machine.  As we have Caddy operating as a reverse proxy we can define Caddy as a global service with exactly one container per swarm node, and that the ports are in host mode, which publishes a host port on the node.  The default of a replicated service with distributed ingress ports does not listen on IPv6.  Docker Composer listens on both IPv4 and IPv6 by default.

The initial configration is performed using an Ansible Playbook as follows:

```
---
- hosts: all
  name: Set up SwarmKit
  tasks:
    - docker_swarm:
        listen_addr: "127.0.0.1:2377"
        advertise_addr: "127.0.0.1:2377"

- hosts: v3b.ocaml.org
  name: Configure controller host
  tasks:
    - name: create caddy directory
      file:
        path: /etc/caddy
        state: directory
    - name: configure caddy
      copy:
        src: Caddyfile
        dest: /etc/caddy/Caddyfile
      notify:
        - restart caddy
    - name: set up infrastructure stack
      docker_stack:
        name: infra
        prune: yes
        compose:
          - version: "3.7"
            services:
              caddy:
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
                image: caddy
                volumes:
                  - /etc/caddy:/etc/caddy:ro
                  - caddy_data:/data
                  - caddy_config:/config
              www:
                image: ocurrent/v3.ocaml.org-server:live
                sysctls:
                  - 'net.ipv4.tcp_keepalive_time=60'
            volumes:
              caddy_data:
              caddy_config:
  handlers:
    - name: restart caddy
      shell:
        cmd: PS=$(docker ps --filter=name=infra_caddy -q) && if [ -n "$PS" ] ; then docker exec -w /etc/caddy $PS caddy reload ; fi
```

