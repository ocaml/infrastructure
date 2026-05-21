---
title: Fermat upgraded to Ubuntu 24.04
date: "2026-05-21"
---

The benchmarking server `fermat.caelum.ci.dev` has been upgraded from Ubuntu
22.04 to 24.04, taking the kernel from 5.15 to 6.8. The trigger was a request
from Thomas, who was trying to benchmark the effect of some `io_uring` flags
that are not available on 5.15. The newer kernel covers every `io_uring`
addition made since 5.15, so those benchmarks can now proceed.
