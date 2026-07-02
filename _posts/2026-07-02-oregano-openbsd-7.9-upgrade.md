---
title: OpenBSD worker upgraded to OpenBSD 7.9
author: Mark Elvers
---

`oregano` (the `openbsd-amd64` cluster worker) has been upgraded to OpenBSD 7.9.

- Base images rebuilt on 7.9: `openbsd-79-amd64-ocaml-4.14` (4.14.4) and `openbsd-79-amd64-ocaml-5.5` (5.5.0)
- [ocaml-ci](https://github.com/ocurrent/ocaml-ci) updated to request the `openbsd-79` images ([#1066](https://github.com/ocurrent/ocaml-ci/pull/1066))
