---
name: riscv-bm-a2
fqdn: riscv-bm-a2.sw.ocaml.org
model: RV1
processor: rv64imafdcvsu
memory: 15GiB
disks:
  - mmcblk0: 116.5GB
  - mmcblk0boot0: 4MB
  - mmcblk0boot1: 4MB
os: Ubuntu 24.04 LTS
threads: 4
location: Scaleway
ssh: root@riscv-bm-a2
use: RISCV worker
pool: linux-riscv64
latitude: 48.8591
longitude: 2.2935
---
{% include details.html %}
