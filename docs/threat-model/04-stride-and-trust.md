# Ward threat model — STRIDE and trust assessment

Updated after the September 10 PR review and integration of `security/ward-fix`. Earlier uniformly low residual ratings are withdrawn. This assessment distinguishes implemented controls, exercised regressions and unverified release behavior. It is not an exhaustive audit.

## Assets and trust

| Asset | Owner and exposure |
| --- | --- |
| Isolation identity | Host state and native store; survives editable manifest/config removal |
| Signing keys, approval records and epochs | Host-only authority; never valid filesystem selections for workers |
| Reviewed bundle / PATH | Exact content-addressed revision, copied to a private read-only session stage |
| Persistent HOME / DATA | Per-plugin writable storage; persists across runs and contains untrusted bytes |
| Host CLI and dependencies | Trusted selected executable snapshot; interpreter, libraries, config and semantic effects retain host authority |
| Private display and GPU buffers | Controller parses worker Wayland; Qt imports bounded controller-produced buffers |
| Desktop observation | Host-owned detached scalar data; polling and worker disclosure require the admitted grant |
| Host input | Slot gestures and explicit host summons authorize panels; worker masks are requests, not permission |

The approving user and desktop user are the same account. Ward isolates an untrusted plugin, not an independently compromised desktop account. First-party and explicitly trusted local plugins run outside this boundary. A downloaded manifest cannot promote itself into that path.

## STRIDE inventory

S = spoofing, T = tampering, R = repudiation, I = information disclosure, D = denial of service, E = elevation of privilege. These are threat categories, not a numeric assurance score.

| Boundary | Threats | Implemented controls | Evidence and remaining limits |
| --- | --- | --- | --- |
| TB-0: installation → loader | S/E: remove `sandbox`, change ID, corrupt/delete checkout, lose native payload | Host-owned monotonic identity combines install markers and native review/approval identity; CLI and registry consult it independently of manifests/runtime availability; unavailable discovery fails closed | Real CLI review-before-enable, stripped/malformed/missing checkout and missing-runtime tests; offscreen registry trusted-URL denial. Registry distribution/provenance and default native packaging remain release gates. |
| TB-1: reviewer → store | T/I/E: forge grants or select signing keys, store parents, host config/runtime, aliases | Signed revision-bound records; explicit selections; canonical protected-root/ancestor checks; device/inode alias checks and signing-key hardlink rejection, rechecked at admission | Real Store approval plus CLI negative selections, old signed unsafe records and alias tests. This does not establish a separate human identity or protect against full host-account compromise. |
| TB-2: store → controller | T/E/D: stale authority, signing failure prevents revoke, partial publication | Pending denial is durable before stopping; stop is attempted before signing disabled state; requests recheck live epoch/unit under lock; recovery is explicit | Real service stops when the signing key is unavailable; pending denial blocks old authority. Revocation cannot undo completed external effects; cleanup failures are reported, not success. |
| TB-3: host → supervisor | S/D: false controller peer, orphaned worker, stalled GUI | Selected unit authenticates the host channel; rejected candidates do not abort admission; retry deadline/pacing, bounded channels and cgroup teardown | Supervisor and session tests; candidate-retry test uses real channels with injected authentication outcomes, not a full hostile-UID service test. Missing/failed graphics startup and persisted enable intent still need lifecycle acceptance. |
| TB-4: supervisor → worker | I/E/D: arbitrary host files/sockets, inherited descriptors, resource exhaustion | Descriptor-selected mounts; namespaces, dropped capabilities, Landlock, seccomp and cgroups; connected descriptors closed before sandbox bootstrap reconnects | Real worker, storage and sandbox suites require their explicit opt-ins. Selected filesystem binds expose actual files/subtrees. Render-node access intentionally exposes kernel GPU ioctls; private Wayland parsing remains controller attack surface. |
| TB-5: worker → broker | S/T/D/E: wrong peer, hostile records, floods, post-revoke requests | UID and unit-cgroup checks, bounded versioned/typed records, sealed payloads, per-kind budgets, bounded clients and live authority checks | Real broker/exec tests plus codec tests. Sender rejection is not decoder coverage; malformed receiver bytes are tested separately. Budgeting does not prove all parser implementations safe. |
| TB-6: private presentation → desktop | I/E/D: full-screen closed input, stale output IDs, exclusive focus, oversized buffers | Closed slots only; separate host visual/pointer modes; keyboard only for an authorized own panel; synchronous Qt pointer clips and grab cancellation; output epochs, frame ownership and consistent dimension/pixel caps | Hostile full-output/exclusive-focus worker fixture verifies host click/key delivery before and after panel ownership, visual click-through and pointer-without-keyboard roaming. Hotplug, Escape, summon, restart and native Qt revoke tests pass. Host/worker graphics parsers and drivers still need ongoing adversarial testing. |
| TB-7: worker → mediated services | I/E/D: bus ownership, unrelated methods, capture without consent, private-network access | MPRIS selected player and fixed read/control allow-list; no bus ownership or OpenUri/Properties.Set. Playback, microphone, output capture, public proxy and scoped HTTP are separate grants | Media/audio/network suites are independent opt-ins. MPRIS does permit selected control calls; it is not a no-calls proxy. Capture grants disclose selected audio by design; raw network bypasses scoped mediation when explicitly selected. |
| TB-8: broker → effects | T/I/E/D: argv siblings, mutable DATA aliases, broad command semantics, structural settings | Positive complete argv trees; component-boundary token roots; beneath-root DATA regular-file snapshots with no links/mount crossing and a 64 MiB total bound; sealed executable; exact HTTP scopes and own-setting keys, escaped notifications | Real host jobs consume descriptor inputs; alias denial occurs before child creation; snapshot replacement/seal tests. An approved CLI is not itself sandboxed by argv matching. DATA is read-only file input, not an output path or directory/filename-semantics API. |

## Worker-facing data

`grants.json` is a projection, not the signed authority record. Filesystem slots expose access/target; exec slots expose selected leaves/lifetime. Host paths, inode pins, executable digests and trees are not copied into this file. Host-chosen PATH/DATA spellings remain exposed specifically for the exec token contract. Context strips ungranted settings and desktop observation. Host polling is enabled only while a ready, nonfailed session has the admitted observation grant; private output allocation does not imply desktop observation.

## Residual risks and release gates

- Approved CLI semantics, dependencies and credentials remain host authority. Free text, script interpreters, configuration-reading commands and untrusted input-file parsers require meaningful review.
- Writable filesystem/storage effects and completed network/service effects are real and cannot be rolled back by revocation.
- Kernel namespaces, Landlock, seccomp, cgroups, DRM drivers, Smithay/private Wayland, Qt importers and host helpers are trusted components, not eliminated surfaces.
- Selected observations, audio capture, media controls and networking expose exactly the corresponding capability; their utility also carries privacy/effect risk.
- Default native payload packaging, clean installed-VM and physical-display acceptance, and transactional failed-start lifecycle behavior are not established by source-level tests.
- Regression tests are bounded examples. The original 21 pen-test cases mostly exercise validators and are not exhaustive penetration testing or a complete integration-suite result.

Use the [review regression ledger](review-regressions.md) and [case findings](pen-test/findings.md) for executed evidence. Do not turn a skipped optional test into a passing security claim.
