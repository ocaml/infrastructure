---
title: Migrating watch.ocaml.org from Scaleway to Cambridge
author: Mark Elvers and Anil Madhavapeddy
---

[watch.ocaml.org](https://watch.ocaml.org) has been migrated from its Scaleway-hosted VM to a virtual machine at the [Cambridge Computer Laboratory](https://www.cl.cam.ac.uk). The primary motivation for this move is to reduce hosting costs, as our Scaleway sponsorship credits have now expired.

The new VM is hosted using [Xen Orchestra](https://xen-orchestra.com), which is itself a management toolstack written in OCaml via [XAPI](https://github.com/xapi-project/xen-api) which is nice for a community OCaml video service!

The PeerTube instance and its data have been migrated across, and the service is now running as before with no user visible changes (we hope). The Ansible playbook and OCurrent-based deployment pipeline documented [previously](/2023/02/27/watch-ocaml-org.html) continue to manage updates to the service.

This was part of a [broader migration](/2026/04/02/scaleway-to-cambridge-migration.html) of OCaml CI services from Scaleway to Cambridge.
