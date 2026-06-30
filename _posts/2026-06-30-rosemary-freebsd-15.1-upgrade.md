---
title: FreeBSD worker upgraded to FreeBSD 15.1
author: Mark Elvers
---

`rosemary` (the `freebsd-x86_64` cluster worker) has been upgraded from FreeBSD 15.0 to 15.1, chiefly to move OpenZFS off the `2.4.0-rc4` release candidate that shipped in 15.0 onto the stable `2.4.2` in 15.1, while investigating rare transient build failures.

- Host upgraded 15.0-RELEASE → 15.1-RELEASE (OpenZFS `2.4.0-rc4` → `2.4.2`)
- obuilder ZFS pool wiped and recreated; base images rebuilt on 15.1: `freebsd-15.1-ocaml-4.14` (4.14.4) and `freebsd-15.1-ocaml-5.5` (5.5.0, the default)
- [ocaml-ci](https://github.com/ocurrent/ocaml-ci) and [opam-repo-ci](https://github.com/ocurrent/opam-repo-ci) updated to request the `freebsd-15.1` images
