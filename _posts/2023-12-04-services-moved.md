---
title: Relocating opam.ci.ocaml.org and ocaml.ci.dev
---

About six months ago, [opam-repo-ci (opam.ci.ocaml.org)](https://opam.ci.ocaml.org) was suffering a lack of system memory [issue 220](https://github.com/ocurrent/opam-repo-ci/issues/220) which caused it to be moved to the same machine which was being used to host [ocaml-ci (ocaml.ci.dev)](https://ocaml.ci.dev).

Subsequently, that machine suffered from BTRFS volume corruption [issue 51](https://github.com/ocaml/infrastructure/issues/51).  Therefore, both services were moved to a big new server.  The data was efficiently migrated using BTRFS tools `btrfs send | btrfs receive`.

Since the move, we have seen issues with BTRFS metadata plus we have suffered from a build-up of sub volumes as reported by other users: [Docker gradually exhausts disk space on BTRFS](https://github.com/moby/moby/issues/27653).

Unfortunately, both services went down on Friday evening [issue 85](https://github.com/ocaml/infrastructure/issues/85).  Analysis showed over 500 BTRFS sub volumes, a shortage of metadata space and insufficient space to perform a BTRFS _rebalance_.

Returning to the original configuration of splitting the ci.dev and ocaml.org services, they have been moved on to new and separate hardware.  The underlying filesystem is now a RAID1-backed ext4 formatted with `-i 8192` to ensure sufficient inodes are available.  Docker is using Overlayfs.  RSYNC was used to copy the databases and logs from the old server.  This change should add resilience and has doubled the capacity for storing history logs.

