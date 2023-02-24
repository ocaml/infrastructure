---
title: watch.ocaml.org
---

watch.ocaml.org is a deployment of [PeerTube](https://joinpeertube.org).

Docker deployments of PeerTube typically uses this
[docker-compose.yml](https://github.com/Chocobozzz/PeerTube/blob/develop/support/docker/production/docker-compose.yml)
file and following the
[instructions](https://docs.joinpeertube.org/install/docker), however
this limits our ability to run `docker service update` to refresh the
Docker image when a new version is released.

We will use Ansible to deploy a Docker service stack which will be peridically updated 
using [ocurrent deployer](https://deploy.ci.ocaml.org).

The Ansible playbook is shown below.  There are some initial setup
steps to prepopulate the SSL certificate and secrets followed by a
docker stack which implements the `docker-compose.yml` file.

```
- hosts: watch.ocaml.org
  name: Install Peer Tube
  tasks:
    - name: Query certbot volume
      docker_volume_info:
        name: certbot-conf
      register: result
    - name: Create certbot volume
      shell:
        cmd: docker volume create certbot-conf 
      when: not result.exists
    - name: Initialise a certbot certificate
      shell:
        cmd: docker run --rm --name certbot -p 80:80 -v "certbot-conf:/etc/letsencrypt" certbot/certbot certonly --standalone -d watch.ocaml.org --expand -n --agree-tos -m mark@tarides.com
      when: not result.exists
    - name: Download the nginx configuration file from the template
      shell:
        cmd: docker run --rm -v nginx-conf:/etc/nginx/conf.d bash wget https://raw.githubusercontent.com/Chocobozzz/PeerTube/master/support/nginx/peertube -O /etc/nginx/conf.d/peertube.template
    - name: Copy environment
      copy:
        src: secrets/env
        dest: /root/.env
        mode: 0600
    - name: set up deployer stack
      docker_stack:
        name: infra
        prune: yes
        compose:
          - version: "3.3"
            services:
              webserver:
                image: chocobozzz/peertube-webserver:latest
                env_file:
                  - /root/.env
                ports:
                 - "80:80"
                 - "443:443"
                volumes:
                  - nginx-conf:/etc/nginx/conf.d
                  - peertube-assets:/var/www/peertube/peertube-latest/client/dist:ro
                  - peertube-data:/var/www/peertube/storage
                  - certbot-www:/var/www/certbot
                  - certbot-conf:/etc/letsencrypt
                depends_on:
                  - peertube
                restart: "always"
              certbot:
                container_name: certbot
                image: certbot/certbot
                volumes:
                  - certbot-conf:/etc/letsencrypt
                  - certbot-www:/var/www/certbot
                restart: unless-stopped
                entrypoint: /bin/sh -c "trap exit TERM; while :; do certbot renew --webroot -w /var/www/certbot; sleep 12h & wait $${!}; done;"
                depends_on:
                  - webserver
              peertube:
                image: chocobozzz/peertube:production-bullseye
                env_file:
                  - /root/.env
                ports:
                 - "1935:1935"
                volumes:
                  - peertube-assets:/app/client/dist
                  - peertube-data:/data
                  - peertube-conf:/config
                depends_on:
                  - postgres
                  - redis
                  - postfix
                restart: "always"
              postgres:
                env_file:
                  - /root/.env
                image: postgres:13-alpine
                volumes:
                  - postgres:/var/lib/postgresql/data
                restart: "always"
              redis:
                image: redis:6-alpine
                volumes:
                  - redis:/data
                restart: "always"
              postfix:
                image: mwader/postfix-relay
                env_file:
                  - /root/.env
                volumes:
                  - opendkim:/etc/opendkim/keys
                restart: "always"
            volumes:
              peertube-assets:
                external: true
              peertube-data:
                external: true
              peertube-conf:
                external: true
              nginx-conf:
                external: true
              certbot-conf:
                external: true
              certbot-www:
                external: true
              opendkim:
                external: true
              redis:
                external: true
              postgres:
                external: true
```

The website site is backed up using [Tarsnap](https://www.tarsnap.com).
The Ansible playbook below installs Tarsnap on Ubuntu.

The backup script is perodically run
using [ocurrent deployer](https://deploy.ci.ocaml.org).

```
- hosts: watch.ocaml.org
  name: Install Tarsnap
  tasks:
  - name: Download Tarsnap's PGP public key
    apt_key:
      url: https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc
      keyring: /usr/share/keyrings/tarsnap-archive-keyring.gpg
      state: present
  - name: Add Tarsnap Repository
    apt_repository:
      repo:  "deb [signed-by=/usr/share/keyrings/tarsnap-archive-keyring.gpg] http://pkg.tarsnap.com/deb/{{ ansible_distribution_release|lower }} ./"
      filename: tarsnap
      state: present
      update_cache: yes
  - name: Install Tarsnap
    package:
      name: tarsnap
      state: present
  - name: Copy tarsnap key
    copy:
      src: secrets/tarsnap.key
      dest: /root/tarsnap.key
      mode: 0600
```

