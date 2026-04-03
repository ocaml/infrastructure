---
title: Revert Posthog Analytics on ocaml.org
date: "2026-04-03"
---

The Posthog analytics tracking added in PR [#3101](https://github.com/ocaml/ocaml.org/pull/3101)
has been reverted in PR [#3594](https://github.com/ocaml/ocaml.org/pull/3594).
The site returns to using Plausible as the sole analytics provider. Plausible
continued to collect metrics throughout the period that Posthog was active, so
there is a continuous set of statistics available with no gaps in coverage.
