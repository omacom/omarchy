# Acceptance Tests

Read this before writing or running the graphical acceptance suite under
`test/acceptance.d/`.

The graphical acceptance suite lives in `test/acceptance` with test files under
`test/acceptance.d/*-test.sh`. It exercises a real installed Omarchy desktop,
including session health, shell surfaces, panels, keyboard navigation,
representative applications, and system setup. Source
`test/acceptance.d/base-test.sh` for the shared helpers.

Run acceptance tests in a disposable VM through the sibling `omarchy-iso`
repository, not in the active development session. The suite opens and closes
applications and temporarily changes desktop configuration.

For acceptance-test-only changes, reuse an installed base and sync the suite:

```bash
cd ../omarchy-iso
./bin/omarchy-iso-test release/<iso>.iso --reuse-base --sync-omarchy ../omarchy --no-preview
```

Use `--sync-all ../omarchy` instead of `--sync-omarchy ../omarchy` when the
acceptance run must exercise local `bin/`, `config/`, or `shell/` source too.
Verify the actual running configuration with `quickshell list -a -j` and compare the loaded runtime tree's hashes with the tested source; copying the suite or a second source tree does not update an already running shell. When testing an alternate complete runtime, launch it through the guest compositor's session with its explicit `OMARCHY_PATH`. Do not start it with `nohup` over SSH: exporting the Wayland environment does not change the caller's session provenance, and background NetworkManager requests can then produce authentication prompts that intercept keyboard tests.

Panel keyboard tests reject unexpected layer surfaces and retain the compositor layer JSON before sending input. Layer evidence and failure screenshot names include the test name so a later file cannot overwrite an earlier failure. This is an isolated-context precondition, not a claim that layer existence proves keyboard ownership. Inspect and fix the test context instead of dismissing authentication, sending another Escape, or extending the wait.

`panels-test.sh` retains its immediate hide/re-summon Escape assertion. IPC latency and disabled animations mean that assertion alone does not prove a fade reopen. `panel-reopen-test.sh` temporarily loads a test-only plugin into the whole running shell, enables animations and restores the previous setting afterward. Each run stages a unique QML entry-point URL so Qt cannot silently reuse a previous fixture's cached component. The fixture uses the real `KeyboardPanel`, checks positive fade duration and no intervening backing-window unmap, waits for Qt to report focus released before reopening during the still-mapped fade, then observes fresh reactivation before sending one Escape per case, and records actual key arrival and focus-prime state. A fixed reopen timer can combine Wayland leave/enter into unchanged Qt activity; release must be observed before requesting focus again. A stale active flag from the previous opening cannot release input. The early case fails without input if reactivation misses the focus-prime window; actual key arrival must still satisfy the intended before/after-prime coverage. This input-readiness condition does not replace compositor ownership traces when diagnosing a failure. Cleanup restores the animation flag and verifies the effective setting using the Lua configuration API, then refreshes and verifies the shell's animation cache before removing the fixture and restoring shell configuration. Cleanup attempts all restoration steps after an error, fails the test and retains recovery preimages in its artifacts directory when restoration fails. No production component hooks or additional Quickshell process are used.

Changes to package manifests, installation, finalization, or shipped defaults
require a fresh ISO built from the local checkouts and a run without
`--reuse-base`:

```bash
cd ../omarchy-iso
./bin/omarchy-iso-make --no-boot-offer --local-source ../omarchy ../omarchy-pkgs
./bin/omarchy-iso-test release/<generated-iso>.iso --no-preview
```

Keep unrelated acceptance workflows in separate test files. The runner records
a failed file and continues with the remaining files, which preserves as much
diagnostic coverage as possible. Restore modified user state with traps, close
anything the test opens, and capture every visually distinct state (including
entered input where relevant) as `success-<step>.png`; failure helpers capture
`failure-<step>.png`. The ISO harness collects the screenshots and logs under
its timestamped `test-runs/` directory and opens the screenshots after the run
unless `--no-preview` is passed.

The ISO harness exercises compositor-level shortcuts with QMP virtual keyboard
input. In-guest `wtype` is suitable for typing into focused controls, but it
does not reliably prove that a global Hyprland keybinding works.
