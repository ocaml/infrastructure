---
title: About
permalink: /about/
---

Disks

```sh
lsblk
```

And then

```sh
apt install smartmontools
smartctl -i /dev/sdb
```

Processor

```sh
nproc
```

Ubuntu release

```sh
lsb_release  -a
```

Machine model
```sh
sudo dmidecode | less
```

