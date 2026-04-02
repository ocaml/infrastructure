---
title: OCaml CI services migration from Scaleway to Cambridge complete
author: Mark Elvers and Anil Madhavapeddy
---

Several OCaml community and CI services have been migrated from Scaleway in Paris to the [Cambridge Computer Laboratory](https://www.cl.cam.ac.uk), as our Scaleway sponsorship credits have now expired. The affected services include:

- [watch.ocaml.org](https://watch.ocaml.org) -- PeerTube video hosting ([details](/2026/03/27/watch-ocaml-org-migration.html))
- [images.ci.ocaml.org](https://images.ci.ocaml.org) -- Docker base image builder
- [scheduler.ci.dev](https://scheduler.ci.dev) -- OCluster job scheduler
- [deploy.ci.dev](https://deploy.ci.dev) -- OCaml CI deployment orchestration
- [ci.mirageos.org](https://ci.mirageos.org) and [deploy.mirageos.org](https://deploy.mirageos.org) -- MirageOS CI and deployment

Multiple Scaleway VMs and baremetal servers have been consolidated onto fewer
machines in Cambridge.  Full technical details of the migration are available
in [Mark Elvers' blog post](https://www.tunbury.org/2026/04/01/from-scaleway-to-cambridge/).
