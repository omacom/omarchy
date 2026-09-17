# Ward threat model

Current assessment of the Rust plugin isolation runtime in [native/ward](../../native/ward), including the September 10 PR review fixes and the local `security/ward-fix` integration. This is a control inventory and evidence ledger, not a completed security audit or release sign-off.

## Deliverables

| File | Purpose |
| --- | --- |
| [01-layers.svg](01-layers.svg) | Trusted host, supervised controller and untrusted worker, with residual parser/driver exposure |
| [02-dataflow.svg](02-dataflow.svg) | Identity, review, admission, broker effects and fail-closed revocation |
| [03-trust-boundaries.svg](03-trust-boundaries.svg) | Nine boundaries, controls and remaining acceptance work |
| [04-stride-and-trust.md](04-stride-and-trust.md) | Current threats, controls, limitations and evidence |
| [review-regressions.md](review-regressions.md) | Review findings and executed regression coverage from both branches |
| [pen-test/findings.md](pen-test/findings.md) | Original 21 cases, with validator coverage distinguished from end-to-end enforcement |

## The nine trust boundaries

| Boundary | Between | Main control |
| --- | --- | --- |
| TB-0 | Downloaded checkout → host loader | Host-owned isolation identity retained until explicit full removal; no trusted QML fallback |
| TB-1 | Reviewer → approval store | Explicit exact-revision selection; protected authority paths; signed records |
| TB-2 | Store → active controller | Live epoch/unit checks; durable denial before stop and signing |
| TB-3 | Host → controller/supervisor | Authenticated controller connection, bounded queues and cgroup ownership |
| TB-4 | Controller → worker | Descriptor mounts, namespaces, Landlock, seccomp and resource ceilings |
| TB-5 | Worker → effect broker | Peer UID/cgroup authentication, typed records, budgets and live rechecks |
| TB-6 | Private Wayland → host presentation/input | Host-owned clips and focus; validated per-output buffers and epochs |
| TB-7 | Worker → media/audio/network services | Separately selected proxies and bounded service-specific contracts |
| TB-8 | Broker → host effects | Selected argv leaves, sealed DATA inputs, scoped HTTP and exact setting keys |

First-party and explicitly trusted local in-process plugins are outside Ward's worker boundary. A downloaded manifest cannot choose that trust category. The approving account remains the desktop account: full same-account compromise is outside this isolation model, but exposing that account's signing keys through a worker grant is a security defect, not an accepted exception.

Filesystem overlap checks cover selected roots, ancestors and resolved aliases, not a recursive audit of descendant inodes. A same-account host process can hardlink another protected file into a permitted subtree; this residual is outside the worker threat model. Signing-key link counts are separately checked, but that does not constitute general descendant-hardlink detection.

## Current conclusion

The review's installation-identity, authority-path, revocation, host-input and DATA-path defects have targeted fixes and regression evidence. The partial input fix from `security/ward-fix` is integrated with explicit host authorization and independent visual/pointer roaming modes; its original closed-after-ownership bypass is not retained.

Do not infer low residual risk everywhere. Approved CLIs retain host authority; writable grants persist real changes; network/media/audio grants have their stated effects. The kernel, render-node driver, private Smithay Wayland parser, Qt importer and host dependencies remain trusted attack surfaces. Default packaging and clean installed-VM/physical-display acceptance remain release work. See the [review ledger](review-regressions.md) for exact test scope and outstanding items.
