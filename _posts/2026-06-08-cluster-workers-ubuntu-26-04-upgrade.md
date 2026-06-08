---
title: Cluster workers upgraded to Ubuntu 26.04
date: "2026-06-08"
---

All Linux cluster workers upgraded from Ubuntu 24.04 to 26.04 (kernel 6.8 → 7.0):

- `linux-x86_64`: asteria, bremusa, clete, doris, eumache, laodoke, odawa, phoebe, toxis
- `linux-arm64`: ainia, kydoime, molpadia, okypous, ocaml-1, ocaml-2
- `linux-ppc64`: orithia, scyleia
- `linux-s390x`: s390x-worker-01

`riscv-bm-01`–`04` remain on Ubuntu 24.04; the hardware does not support 26.04.
