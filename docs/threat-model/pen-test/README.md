# Ward negative security tests

The historical white-box and docs-derived “black-box” passes supplied 21 bounded regression cases in `native/ward/tests/pen_test.rs` and `pen_test_blackbox.rs`. Most call validators directly. They are not malicious workers traversing the full installation, approval, admission and host-effect chain.

## Coverage levels

- Validator: request/schema, selected argv, setting keys, text policy or scope definition.
- Decoder: hostile raw bytes and descriptor counts reach a receiver without sender validation first.
- Integration: real approval, process/namespace, broker or Qt host interaction reaches the relevant enforcement boundary.

Passing one level does not establish another. The [case ledger](findings.md) labels the original coverage; [whitebox.md](whitebox.md) records the original targeted checks and [blackbox.md](blackbox.md) corrects the docs-derived scope. Offensive bundles in `plugins/` are fork-only research assets, not automatically executed regression tests.

## Current evidence

The September 10 review added installation identity, authority-path and revocation regressions, actual closed-surface input tests, sealed DATA input tests, projection and decoder tests. Read [review-regressions.md](../review-regressions.md) for current results from both integrated branches and remaining release gates.

Optional real systemd, GPU, private audio, proxy and installed-display suites have explicit prerequisites. A test function returning early because an opt-in is absent is not end-to-end evidence, even when the runner prints “ok.” No complete penetration-test or blanket low-residual-risk conclusion follows from these cases.
