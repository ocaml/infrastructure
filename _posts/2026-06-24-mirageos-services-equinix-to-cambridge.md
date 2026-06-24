---
title: MirageOS services migrated from Equinix to Cambridge
author: Mark Elvers
---

The MirageOS production services have moved from the Equinix Metal baremetal server (`infra-2`, being decommissioned) to `dopey.caelum.ci.dev` at the Cambridge. All services run as MirageOS unikernels under [robur-coop/albatross](https://github.com/robur-coop/albatross).

- [mirageos.org](https://mirageos.org) / [mirage.io](https://mirage.io) web — moved to dopey
- `ns0.mirageos.org` primary DNS (git-backed) — moved to dopey
- Let's Encrypt DNS secondary (certificate issuance) — moved to dopey
- [next.mirageos.org](https://next.mirageos.org) staging — moved to dopey
- DNS glue records for `mirageos.org` and `mirage.io` updated to the new addresses
- Secondary nameserver `ns1.mirageos.org` (robur) repointed
- [deploy.mirageos.org](https://deploy.mirageos.org) deployment pipeline repointed to dopey
