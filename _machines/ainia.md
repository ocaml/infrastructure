---
name: ainia
ip: 128.232.124.247
fqdn: ainia.ocamllabs.io
manufacturer: Avantek
model: Ampere(TM) Mt Snow
os: Ubuntu 24.04
threads: 80
memory: 256GB
processor: Ampere Altra Processor ARMv8
location: Caelum
notes: Cluster worker + Arthur has a login for ARM benchmarking.  8 cores isolated
pool: linux-arm64
disks:
  - 900GB NVMe
  - 2 x 3.5TB NVMe
latitude: 52.2109
longitude: 0.0917
---
{% include details.html %} 

In `/etc/default/grub`
```
GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS1,115200n8 isolcpus=72,73,74,75,76,77,78,79"
```

