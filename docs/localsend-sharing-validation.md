# LocalSend sharing validation

Latest installed-VM run: [October 19 current-head localization validation](#fresh-installed-vm-localization-validation-october-19-2026-edt). The full graphical suite ran at `dc2ff87b11ba458a059d14233e6698b86ecc22bc`: **7/10 files passed**, with three failures retained; targeted LocalSend and real GTK localization checks passed. Earlier results below remain historical.

The Share menu and CLI now support native LocalSend text messages through a multiline composer or `omarchy share text [message]`. Ordinary clipboard sharing uses LocalSend's native `--text` route without temporary files, aligned with guilhermetk's independently authored #6979. His contribution is credited in the reconciliation commit; his branch is unchanged.

Text and clipboard launches share the existing protected launcher: fixed systemd descriptions keep message contents out of command-derived journal descriptions, environment expansion is disabled, flag-like messages are protected, and the detached service reports LocalSend errors. Clipboard-read failures and file/folder service-launch failures also notify. File/folder selection remains unchanged. LocalSend still receives text in process arguments and trims surrounding whitespace.

The contribution branch now includes quattro at `4e059acff2f4e4c4e5a303ce9bc97223097e45eb`, without rewriting history. English menu and notification catalog entries follow the current translation system. The composer pins GTK/GDK 3 and uses the system Python.

Earlier container validation on October 17, 2026 (before the desk run below):
- Final sharing suite: **21 tests passed without skips**, plus the real menu-parser assertion. Includes privacy, literal/flag-like text, cancellation, clipboard reads, oversized clipboard errors, scheduling and detached child failures, file/folder routes, and catalog-based notifications.
- New real GTK suite: **four scenarios passed under Xvfb**, covering multiline Unicode output, button sensitivity, Ctrl+Enter, Cancel, Escape, and blank Ctrl+Enter. The rendered composer was inspected with entered text. The suite explicitly skips when GTK or a display is unavailable.
- Full CLI suite passed with GNU awk. ShellCheck and Bash syntax checks passed.
- Current upstream catalog structure, reference, placeholder, plural and number checks passed. `extract-scan --check` reports no candidates and no stale catalogs. The complete i18n shell test later fails in the unchanged locale-generator section because this container runs as root and has no installed `/usr/share/omarchy`; this is not a clean full i18n-suite result.
- Released LocalSend **1.18.2** was launched under Xvfb with a synthetic flag-like Unicode message. Its Send view staged native text with the expected **31-byte** trimmed payload. No message was sent to another device; multicast discovery is restricted here.
- The aggregate `./test/all` runner stalled outside sharing. A complete per-file shell sweep with 120-second limits and per-file output logs compared the original and reconciled pre-upstream-sync trees: **322/323 files exercised; the same 69 files failed; no new failing files and no timeouts**. There were skipped checks in 35/36 files; the additional skip is the real GTK suite in the headless sweep, separately run successfully under Xvfb. This comparison is not a claim that the final current-upstream full suite is green.

## Desk validation on October 17, 2026 EDT

Fetched `Gberfield/omarchy:add-share-text` into a new standalone checkout; its starting head was still `a1cd232510813de2e649de96a2c3e8f720fb5832`. Existing checkouts and the installed `/usr/share/omarchy` configuration were not edited. GUI checks used this chat's independent hidden native Sway/Wayland session on desk. This is a real graphical session, but it is not an installed Omarchy/Hyprland acceptance VM.

Versions: LocalSend `1.18.2-1`, GTK `3.24.52-1`, PyGObject `3.56.3-1`, Python `3.14.7`, systemd `261.2-1`, Bash `5.3.15`, GNU awk `5.4.1-1`, Node `26.8.2`, jq `1.8.2`, ShellCheck `0.11.0-137`, and GitHub CLI `2.102.0`.

### Oversized clipboard regression

[Review comment r4305015851](https://github.com/omacom/omarchy/pull/14480#discussion_r4305015851) correctly identified the per-argument limit. A 140 KiB synthetic clipboard reproduced `Argument list too long` against the starting head. The previous test only checked notification on this failure; it did not preserve large clipboard sharing.

Text of at least 64 KiB now uses a private `message.txt` file and LocalSend's existing file route. The threshold counts UTF-8 bytes, leaving headroom below Linux's 128 KiB per-argument limit on 4 KiB-page systems. Smaller messages retain the native `--text` route and its flag protection. The directory is mode 0700, the file is mode 0600, and cleanup occurs after LocalSend exits or service scheduling fails. This fallback applies to composed text, clipboard text, and direct text that reaches the command. A caller still cannot supply an argument larger than the kernel allows to the CLI itself. Command substitution retains its existing removal of trailing newlines; the native LocalSend text route also trims surrounding whitespace. Forced `SIGKILL`, power loss, or a service shell that cannot start can leave a private temporary file behind; normal cleanup is not secure erasure.

The focused suite grew from 21 to **27 tests**, with a failing run against the old implementation before the fix. Coverage includes the oversized clipboard, multibyte threshold, native text below the threshold, oversized composer output, restrictive permissions, exact file contents, and cleanup/notifications for preparation, scheduling, and detached child failures. No changes were made to guilhermetk's branch.

### Commands and results

Run from the isolated repository root:

```bash
bash test/shell.d/share-text-test.sh
OMARCHY_SHARE_GTK_SCREENSHOT=/work/composer-final.png bash test/shell.d/share-text-gtk-test.sh
./test/cli
I18N_STRUCTURAL=1 bash test/shell.d/i18n-test.sh
python3 -B scripts/i18n-sync.py extract-scan --check
OMARCHY_PATH="$PWD" PATH="$PWD/bin:$PATH" bash test/shell.d/notification-send-test.sh
OMARCHY_PATH="$PWD" PATH="$PWD/bin:$PATH" bash test/shell.d/menu-plugin-test.sh
shellcheck -x -P SCRIPTDIR bin/omarchy-menu-share test/shell.d/share-text-test.sh test/shell.d/share-text-gtk-test.sh
bash -n bin/omarchy-menu-share test/shell.d/share-text-test.sh test/shell.d/share-text-gtk-test.sh
git diff --check
```

- **PASS:** 27 sharing tests plus the real Share-menu parser assertion, including a rerun inside the hidden graphical session; no skips.
- **PASS:** all four real GTK scenarios in that Wayland session; no skips. The entered composer screenshot was inspected. GTK accessibility-bus and PyGObject deprecation warnings remain in the logs.
- **PASS:** CLI suite (125 assertions), notification wrapper (17 assertions), plugin picker (12 assertions), ShellCheck, Bash syntax, and whitespace checks.
- **PASS WITH ONE INTENTIONAL SKIP:** structural i18n suite (401 `ok` lines, including the structural-mode translation-completeness skip). This run reaches the locale-generator and sync fixtures that the earlier container run did not complete. It does not prove translation completeness.
- **PASS:** extraction scan reports `candidates: []`, `menuCatalogStale: false`, and `keybindingsCatalogStale: false`.
- **INITIAL FAIL, superseded by the 164-check host pass below:** `OMARCHY_PATH="$PWD" PATH="$PWD/bin:$PATH" bash test/shell.d/menu-test.sh` stops at `menu checks Opaque Bar while the bar is opaque`, expected `["opaque"]`, actual `[]`. The standalone `omarchy-bar background` scratch-home probe returns `opaque`; this restricted run was not counted as passing; the later host rerun supersedes it. Earlier plugin-picker failures caused by the installed environment were resolved by explicitly selecting this checkout's `OMARCHY_PATH` and `PATH`.

### Targeted GUI routes

The production CLI/router, composer, clipboard reader, file/folder dispatch, and packaged LocalSend ran in the hidden desktop. Because that desktop's private bus has no systemd manager, GUI staging used a narrowly scoped `systemd-run` adapter that removes the manager options and executes the production service command in the hidden session. Those GUI checks do **not** prove graphical systemd integration. The actual systemd checks below use desk's real user manager separately, without modifying its environment.

Commands included:

```bash
omarchy share text
omarchy share text --share
omarchy share clipboard
omarchy share file '/work/synthetic folder/synthetic file.txt'
omarchy share folder '/work/synthetic folder'
omarchy share text $' \t\n'
```

- **PASS:** entered `LSVALID café 🌎` followed by a second line containing literal `${HOME}`, `$(touch unwanted)`, quotes, and `--share`; the composer opened LocalSend and staged the expected 62-byte native payload. The CLI `--share` message staged 7 bytes; the synthetic clipboard staged 57 bytes. No `unwanted` file appeared.
- **PASS:** file and folder routes each staged the synthetic 21-byte file. No recipient was selected and nothing was sent to another device.
- **PASS:** whitespace-only direct input and actual composer Escape cancellation returned zero without calling the launch adapter. The GTK suite separately verifies whitespace button sensitivity, blank Ctrl+Enter, Ctrl+Enter acceptance, Cancel, and Escape.
- **PASS:** the updated oversized clipboard route staged a synthetic 204 KB file in packaged LocalSend. Its content was synthetic multiline Unicode with literal shell-like text. The private file/directory cleanup and clipboard restoration were checked after ending the owned validation app.
- **INITIAL LIMIT, closed by installed VM checks below:** the actual menu plugin configuration loads, but its overlay requires Hyprland monitor IPC. This Sway session cannot render it; parser/routing tests pass, while installed Share-menu clicks remain a VM acceptance gap. No production overlay was patched or replaced.
- **INITIAL LIMIT, closed by installed VM checks below:** actual portal file/folder picker interaction was unexecuted; explicit file/folder arguments and automated picker selection/cancellation/failure fixtures were exercised.
- **LIMITED:** LocalSend logs missing private system-bus/NetworkManager access, GTK warnings, an existing-instance HTTP 403, and discovery/listener address-in-use warnings. Staging is observed; discovery, reception, and transmission are not accepted by these checks. An automatic safety review rejected an intended Edit-control click as insufficiently identified; that inspection was left unexecuted.

Only synthetic data was placed in the hidden clipboard. Its prior selection was absent and was restored to absent; the host clipboard was not read or changed.

### Real systemd and notifications

The local probe command was:

```bash
dbus-run-session -- python3 -B ../evidence/notification-receiver.py
```

This launches `../evidence/systemd_validation.py`, which invokes the real `bin/omarchy-menu-share` through `/usr/bin/systemd-run` on desk's actual user manager. Per-service `--setenv` values select controlled LocalSend/clipboard fixtures and a private notification receiver; the manager environment and installed services are unchanged. The probe's source, per-unit JSON journal records, arguments, notifications, and results are retained beside the isolated checkout under `../evidence/`, not committed as raw host journal metadata.

**PASS: 13 cases.** These cover literal multiline Unicode and shell-like direct/clipboard arguments, flag-like text, file/folder arguments, detached status-7 failure, actual packaged LocalSend failure with an isolated nonexistent display (status 1), oversized clipboard success/failure, and four real scheduling rejections using an already-active uniquely named validation unit. All validation units were stopped/reset by exact owned name. **Seven critical notifications** reached a private real D-Bus receiver through the production `omarchy-notification-send`/`busctl` implementation, with the expected catalog summaries/bodies and urgency 2. This verifies delivery, not installed-shell toast rendering.

For text/clipboard cases, manager journal `MESSAGE` fields used the fixed `Share text with LocalSend` description; none contained the synthetic `LSVALID-` markers. Literal `${HOME}` and shell-like strings reached the controlled child unchanged. File/folder paths still appear in their existing command-derived descriptions.

**Privacy limit confirmed live:** the actual LocalSend startup failure logged `cannot open display`, and that application's structured journal entry included the synthetic message in `_CMDLINE`. Fixed descriptions protect systemd's command-derived start/stop text; they do not prevent process-argument exposure or journal metadata recording it. The source comment now states this narrower guarantee. Oversized fallback contents are file data rather than arguments, but that file remains readable to its owner while staged.

The first notification probe sampled before the service had finished; its failed witness is retained, and the probe now waits for terminal manager state. An initial oversized-probe expectation also included trailing newlines that the pre-existing clipboard command substitution removes; the corrected expectation follows that existing behavior. Neither probe correction is a production fix.

## Follow-up validation on October 17, 2026 EDT

The earlier opaque-bar shell-test failure is superseded. A diagnostic copy showed Node `spawnSync bash EPERM` in the restricted sandbox. The unchanged `OMARCHY_PATH="$PWD/omarchy" PATH="$PWD/omarchy/bin:$PATH" bash omarchy/test/shell.d/menu-test.sh` passed **all 164 checks** through the authorized host execution route. No product workaround or weakened assertion was introduced.

The account has pull-only permission on upstream. An [approval request](https://github.com/omacom/omarchy/pull/14480#issuecomment-6244041382) was posted for the held translation workflow. At runtime-code head `a777fa86b4da343d3c8d0706428f27401aa77296`, [run 39084738026](https://github.com/omacom/omarchy/actions/runs/39084738026) remains `completed` / `action_required` with **zero jobs**. Greptile review succeeded for that head; this is not an Actions pass. No approval endpoint or bypass was used.

### Fresh installed VM

The user explicitly approved creating, testing, shutting down, and removing the disposable overlay for `localsend-14480-validation`, retaining the base image and evidence. Desk and all existing desktops stayed running. A fresh local-source ISO used `omarchy-iso` `3872d5a3695258944084f975749b4f88b7eced4a`, package recipes `f097a2472d364a548130d2bff43614eb9417cda1`, and archiso `424e78130db2af6c1ceb55b442d7914b1109ff2b`. The accepted image is named `omarchy-2026.10.18-x86_64-local.iso`, built October 17 EDT, SHA256 **`7a9f5682e1eaf51b47ab9661f83c816a04b2a757d1f62470d655b59642fb7a0a`**. Installed launcher/composer hashes match the tested runtime commit exactly.

Guest versions: LocalSend `1.18.2-1`, GTK `1:3.24.52-2`, PyGObject `3.58.1-1`, systemd `262-1`, and running kernel `7.2.8-9-omarchy` with matching headers. Host QEMU is `11.1.1`.

Build-preparation failures are retained separately from product results. The first ISO (`c420c4fd63ec21f9f7016c540341247976283cf554241ef2d498f621c5de029e`) installed root-owned public files with my private checkout's 0700/0600 modes and stopped at user finalization. Only owned public tracked source modes were normalized to Git executable bits; runtime bytes were unchanged. The next build rejected an old same-filename cached settings package checksum. The rebuilt package and index agreed, and all **1,197** offline package hashes passed audit. A task-local guard invalidated only the three locally rebuilt package cache entries before assembly, retaining checksum verification. The final ISO installed successfully. A nonfatal live-root initcpio warning for `/boot/vmlinuz-linux` remains logged; the ISO's selected live kernel was `linux-t2`, and the installed guest booted successfully.

The initial QEMU invocation failed before boot on io_uring allocation. A temporary user-service restriction, `SystemCallFilter=~io_uring_setup` with `SystemCallErrorNumber=EPERM`, selects QEMU's supported epoll fallback. `NoNewPrivileges=yes` and `LimitCORE=0` remain enabled. An earlier preflight omitted the error-number property and produced SIGSYS in its own `qemu-img`; its evidence is retained. No global kernel, authentication, or desktop configuration was changed.

The initial build command, from the isolated sibling ISO checkout, was:

```bash
./bin/omarchy-iso-make --keep-pkg-cache --no-boot-offer --local-source ../omarchy ../omarchy-pkgs
```

The corrected build used the reviewed `../evidence/followup/rebuild-iso-once.sh` through one separately approved sudo invocation per attempt. Its container had a unique name, 16 GiB memory/6 CPU limits, read-only source/recipe mounts, only task-private writable caches, and a 10 GiB host free-space guard. Exact build logs, scripts, checksum audits, and the local harness diff are retained in `../evidence/followup/`; those harness changes are not contribution changes.

The clean full-suite rerun used the following command from the validation workspace (`TASK` denotes that workspace's absolute path):

```bash
systemd-run --user --quiet --wait --pipe --collect \
  --unit=localsend-14480-validation \
  --description='Disposable LocalSend contribution acceptance VM' \
  --property=NoNewPrivileges=yes \
  --property=SystemCallFilter=~io_uring_setup \
  --property=SystemCallErrorNumber=EPERM \
  --property=LimitCORE=0 --property=MemoryMax=16G \
  --working-directory="$TASK/omarchy-iso" \
  /usr/bin/bash ./bin/omarchy-iso-test \
  release/omarchy-2026.10.18-x86_64-local.iso \
  --reuse-base --sync-omarchy ../omarchy --port 41797 --memory 8192 --no-preview
```

The first run omitted `--reuse-base` and performed the fresh installation. The ISO already contained the candidate runtime; `--sync-omarchy` copied tests, not a replacement runtime. The VM was headless, used KVM, four vCPUs/8 GiB RAM, private QMP, localhost-only test SSH, and no VNC listener. No broad acceptance command ran on desk.

### Full graphical suite: executed, not green

Both complete runs exercised all ten test files: **eight passed, two failed**, in **251 seconds** and **246 seconds**. No file was skipped. Passing files were `apps-test.sh`, `cups-test.sh`, `input-methods-test.sh`, `overlay-monitor-test.sh`, `panels-test.sh`, `security-test.sh`, `session-test.sh`, and `system-test.sh`.

- **FAIL:** `menu-test.sh` expects the fifth Style item to open Menu Bar. Current upstream puts Hyprland there; the captured screen shows `looknfeel.lua` opening. The bar-position check is therefore not accepted.
- **FAIL:** `shell-surfaces-test.sh` expects `omarchy-menu` for the Apps route. Current upstream opens the `omarchy-dock-apps` grid, so the test times out and leaves a keyboard-grabbing overlay. Its earlier notification, clipboard, selector, and reminder checks passed; the whole file did not.

These files are unchanged from included quattro `4e059acff2f4e4c4e5a303ce9bc97223097e45eb`; this contribution's menu diff adds only Share Text. The local ISO shortcut smoke had the same stale apps namespace. Correcting that harness expectation and cleanup made **all QMP shortcut/clipboard smoke checks pass**, including the initially failed apps-open and audio-close checks. The two unchanged full-suite failures remain reported, not rewritten as passes.

### Targeted installed LocalSend checks: passed

Independent targeted runs reused the clean base with the same VM command and `--setenv=LOCALSEND_ONLY=1`. The final remaining-picker/notification run also set `--setenv=LOCALSEND_PICKERS_ONLY=1`. These task-local modes skip the already-recorded broad suite; a targeted pass is not a full-suite pass. Guest probes ran through the real installed CLI, real user manager, real portal, packaged LocalSend, and installed notification shell, without the native-session launch adapter.

- **PASS:** the actual Share menu opened the actual composer; multiline Unicode, literal `${HOME}`, `$(touch unwanted)`, quotes, and flag-like contents reached native LocalSend unchanged. The composer/clipboard payload was **59 bytes**; direct CLI `--share` staged **7 bytes**. No `unwanted` file appeared.
- **PASS:** real LocalSend rendered its Selection panel for composer, direct CLI, clipboard, and **191,999-byte** oversized clipboard data. The large route's exact private file contents, 0700 directory/0600 file permissions, and cleanup after the app exited were checked.
- **PASS:** actual GTK portal file and folder selection, with synthetic space-containing paths, produced the expected literal process arguments and rendered **21-byte** selections in LocalSend. The folder's matching row and Select button were activated through the VM's QMP tablet. No device card was activated.
- **PASS:** a real graphical LocalSend process ran in a user service whose description was exactly `Share text with LocalSend`. Manager journal messages contained no `LSVM` synthetic marker. The actual startup-failure unit logged `cannot open display`, exit status **1**, and `exit-code`; the installed shell visibly rendered `Could not share text` / `LocalSend exited with an error`. Its journal and screenshot were inspected.
- **PASS:** actual VM composer Escape cancellation after closing a stale test overlay. The earlier real GTK/native checks cover Cancel, Escape, Ctrl+Enter, blank input, whitespace sensitivity, and direct whitespace-only input; these are not inferred from a window merely opening.

Early supplemental attempts failed because stale broad-suite overlays captured input, a probe used the wrong focus API, `wtype` did not reach the portal despite confirmed window focus, and a scaled OCR check missed an actually visible notification. Their screenshots/logs remain retained. QMP input completed the portal checks; native-resolution OCR plus visual inspection confirmed the same expected notification text. Early black startup-window screenshots are not counted as rendered staging; the accepted checks explicitly wait for the Selection panel. Final composer, file/folder Selection panels, and failure toast were visually inspected.

Text/clipboard and picker/notification results come from separate bounded runs, not one claimed all-green aggregate. Accepted text artifacts are in ISO run `20261017-221622`; final picker/notification artifacts are in `20261017-223408`. Full-suite logs are `../evidence/followup/vm-acceptance-v3.log` and `vm-acceptance-v4.log`; the final picker/notification command exited **0** in `vm-localsend-final.log`. Only synthetic clipboard data was used in the guest; its prior selection was restored where practical, and no host clipboard was used. All disposable overlays were removed after their own VM stopped; the successful base image, ISO, logs, and screenshots remain retained. Final verification found the test unit inactive with `MainPID=0`, both test listener ports closed, and zero remaining disposable overlays.

Fixed descriptions protect systemd's command-derived descriptions. They do **not** hide native message arguments from process inspection or application journal `_CMDLINE`; the desk failure test confirmed that exposure. The installed-VM checks close the earlier Share-menu, portal-picker, real graphical service, and rendered-toast gaps without claiming transmission acceptance.

## Remaining acceptance gaps at the October 17 checkpoint

- **EXECUTED / FAIL:** the full installed graphical suite has the two stale-navigation failures detailed above. It is not green, despite all targeted LocalSend checks passing.
- **ACTION REQUIRED upstream:** translation workflow execution still needs an upstream maintainer's approval. The contributor cannot approve it. Check the latest head after the report push; no held or unexecuted workflow is counted as passing.
- **NOT AUTHORIZED / NOT RUN:** sending to another device. No transmission or reception acceptance is claimed.

Neither PR has been merged.

<details>
<summary>69 shell-test files failing on both original and reconciled trees in this environment</summary>

- `test/shell.d/agent-account-exec-test.sh`
- `test/shell.d/agent-account-test.sh`
- `test/shell.d/ascii-test.sh`
- `test/shell.d/bar-text-color-test.sh`
- `test/shell.d/browser-handoff-test.sh`
- `test/shell.d/browser-policy-dir-test.sh`
- `test/shell.d/channel-sudo-boundary-test.sh`
- `test/shell.d/channel-test.sh`
- `test/shell.d/clipboard-test.sh`
- `test/shell.d/config-test.sh`
- `test/shell.d/default-agent-test.sh`
- `test/shell.d/default-apps-test.sh`
- `test/shell.d/dev-link-test.sh`
- `test/shell.d/dev-unlink-test.sh`
- `test/shell.d/elsewhen-greetings-test.sh`
- `test/shell.d/elsewhen-model-test.sh`
- `test/shell.d/factory-reset-accounts-test.sh`
- `test/shell.d/hermes-cli-test.sh`
- `test/shell.d/hermes-desktop-install-test.sh`
- `test/shell.d/hermes-remove-test.sh`
- `test/shell.d/hw-hybrid-gpu-test.sh`
- `test/shell.d/hw-nvidia-test.sh`
- `test/shell.d/hyprland-binding-conflicts-test.sh`
- `test/shell.d/hyprland-default-config-test.sh`
- `test/shell.d/hyprland-keyboard-layout-test.sh`
- `test/shell.d/hyprland-paths-test.sh`
- `test/shell.d/hyprland-qconsole-test.sh`
- `test/shell.d/hyprland-shutdown-test.sh`
- `test/shell.d/hyprland-startup-cursor-test.sh`
- `test/shell.d/hyprland-workspace-layout-test.sh`
- `test/shell.d/keybindings-menu-test.sh`
- `test/shell.d/kitty-config-test.sh`
- `test/shell.d/launch-browser-test.sh`
- `test/shell.d/legacy-power-udev-rules-migration-test.sh`
- `test/shell.d/locate-test.sh`
- `test/shell.d/menu-images-test.sh`
- `test/shell.d/mise-work-path-test.sh`
- `test/shell.d/monitor-modeless-test.sh`
- `test/shell.d/neovim-remote-yanks-test.sh`
- `test/shell.d/nopasswd-sudo-expiry-test.sh`
- `test/shell.d/openclaw-cli-test.sh`
- `test/shell.d/openclaw-onboard-test.sh`
- `test/shell.d/passwordless-grant-lifecycle-test.sh`
- `test/shell.d/plymouth-set-test.sh`
- `test/shell.d/powerprofiles-set-test.sh`
- `test/shell.d/provision-user-test.sh`
- `test/shell.d/retired-installer-artifacts-migration-test.sh`
- `test/shell.d/screensaver-workspace-test.sh`
- `test/shell.d/security-entrypoint-symlink-test.sh`
- `test/shell.d/security-fingerprint-remove-test.sh`
- `test/shell.d/shell-ipc-socket-test.sh`
- `test/shell.d/shell-shortcuts-test.sh`
- `test/shell.d/snapper-test.sh`
- `test/shell.d/snapper-timeline-leak-test.sh`
- `test/shell.d/sshd-hardening-migration-test.sh`
- `test/shell.d/system-sleep-ownership-migration-test.sh`
- `test/shell.d/terminal-cwd-test.sh`
- `test/shell.d/theme-staging-test.sh`
- `test/shell.d/theme-templates-test.sh`
- `test/shell.d/toggle-input-device-test.sh`
- `test/shell.d/unowned-system-paths-test.sh`
- `test/shell.d/update-disk-space-test.sh`
- `test/shell.d/update-hook-security-test.sh`
- `test/shell.d/update-lock-test.sh`
- `test/shell.d/update-sequence-test.sh`
- `test/shell.d/update-stay-awake-security-test.sh`
- `test/shell.d/update-user-path-test.sh`
- `test/shell.d/webapp-install-escaping-test.sh`
- `test/shell.d/windows-vm-mount-boundary-test.sh`

</details>



## Composer catalog integration, October 19, 2026 EDT

The composer now reads its application/window title, Cancel and Choose device buttons, prompt and shortcut hint through `omarchy-i18n`. Five English `share.text*` keys are added to `cli.json`; other locale catalogs and the translation manifest remain unchanged, following the English-first PR workflow. Missing and empty translations fall back through the existing helper. Translation output is passed as label text without shell evaluation and does not enter the shared message. The CLI catalog-reference check now includes the Python composer, and the real GTK harness explicitly selects this checkout's runtime/catalogs.

Validation on the candidate and unchanged `f7f95b835c241927aef19458a3e9692e96ed3bb1` baseline:

- The new `share-text-i18n-test.sh` first failed two selected-language assertions on the original composer. All four cases pass after the change: all visible labels use a synthetic German fixture, partial/empty translations fall back to English, English is retained, and an unknown language falls back. These execute the real composer and `omarchy-i18n` with isolated catalogs; only GTK is replaced because introspection/display support is unavailable. Cancellation emits no UI text to the sharing payload.
- `share-text-test.sh`: 27 tests, no failures, one GTK/GDK import check skipped; real menu-parser assertion passes. `share-text-gtk-test.sh` skips because GTK/display support is absent. No fresh rendered-UI acceptance is claimed for this localization change; earlier English GUI evidence above remains historical.
- Structural catalog, placeholder and key-reference checks in `I18N_STRUCTURAL=1 bash test/shell.d/i18n-test.sh` pass through the catalog checks. The complete script fails later in unchanged locale generation: this root container has no installed `/usr/share/omarchy/default/i18n/locales.json`. It is not a complete green i18n run. An unprivileged retry was unavailable because changing groups is denied by the execution environment.
- `python3 scripts/i18n-sync.py extract-scan --check`: no candidates, menu catalog current, keybindings catalog current. Python compilation, Bash syntax and `git diff --check` pass. ShellCheck is not installed in this environment.
- Both complete aggregate runs used `I18N_STRUCTURAL=1 ./test/all`. Baseline: 91 failures among 453 shell-test files; candidate: the identical 91 failures among 454 files. Both have skipped checks in 82 files. Both CLI runs stop at the same `theme template mix helper works` assertion. There are no newly failing shell-test files, but neither full suite is green. These results supersede no earlier environment's results.

The identical failing shell-test files are listed below so the failed aggregate run is not mistaken for successful acceptance:

<details>
<summary>Baseline and candidate failures in this environment</summary>

- `test/shell.d/agent-account-copy-test.sh`
- `test/shell.d/agent-account-exec-test.sh`
- `test/shell.d/agent-account-recovery-test.sh`
- `test/shell.d/agent-account-test.sh`
- `test/shell.d/ascii-test.sh`
- `test/shell.d/bar-text-color-test.sh`
- `test/shell.d/battery-status-test.sh`
- `test/shell.d/bind-hold-test.sh`
- `test/shell.d/brave-widevine-test.sh`
- `test/shell.d/browser-handoff-test.sh`
- `test/shell.d/browser-policy-dir-test.sh`
- `test/shell.d/clipboard-test.sh`
- `test/shell.d/config-test.sh`
- `test/shell.d/crash-capture-test.sh`
- `test/shell.d/default-agent-test.sh`
- `test/shell.d/default-apps-test.sh`
- `test/shell.d/dev-link-test.sh`
- `test/shell.d/dev-unlink-test.sh`
- `test/shell.d/dictation-test.sh`
- `test/shell.d/drive-password-test.sh`
- `test/shell.d/elsewhen-greetings-test.sh`
- `test/shell.d/elsewhen-model-test.sh`
- `test/shell.d/factory-reset-accounts-test.sh`
- `test/shell.d/hermes-cli-test.sh`
- `test/shell.d/hermes-desktop-install-test.sh`
- `test/shell.d/hermes-remove-test.sh`
- `test/shell.d/hw-hybrid-gpu-test.sh`
- `test/shell.d/hw-nvidia-test.sh`
- `test/shell.d/hyprland-binding-conflicts-test.sh`
- `test/shell.d/hyprland-default-config-test.sh`
- `test/shell.d/hyprland-floating-workspaces-test.sh`
- `test/shell.d/hyprland-jis-bindings-test.sh`
- `test/shell.d/hyprland-keyboard-layout-test.sh`
- `test/shell.d/hyprland-paths-test.sh`
- `test/shell.d/hyprland-qconsole-test.sh`
- `test/shell.d/hyprland-shutdown-test.sh`
- `test/shell.d/hyprland-startup-cursor-test.sh`
- `test/shell.d/hyprland-window-close-all-test.sh`
- `test/shell.d/hyprland-window-transparency-test.sh`
- `test/shell.d/hyprland-workspace-layout-test.sh`
- `test/shell.d/i18n-test.sh`
- `test/shell.d/input-indicator-test.sh`
- `test/shell.d/keybindings-menu-test.sh`
- `test/shell.d/launch-browser-test.sh`
- `test/shell.d/legacy-power-udev-rules-migration-test.sh`
- `test/shell.d/locale-sudoers-test.sh`
- `test/shell.d/locate-test.sh`
- `test/shell.d/menu-images-test.sh`
- `test/shell.d/menu-keybindings-key-names-test.sh`
- `test/shell.d/menu-plugin-test.sh`
- `test/shell.d/migrate-notify-test.sh`
- `test/shell.d/mise-work-path-test.sh`
- `test/shell.d/monitor-modeless-test.sh`
- `test/shell.d/neovim-remote-yanks-test.sh`
- `test/shell.d/nopasswd-sudo-expiry-test.sh`
- `test/shell.d/openclaw-cli-test.sh`
- `test/shell.d/openclaw-onboard-test.sh`
- `test/shell.d/pacman-templates-test.sh`
- `test/shell.d/passwordless-grant-lifecycle-test.sh`
- `test/shell.d/passwordless-sudo-indicator-test.sh`
- `test/shell.d/pkg-drop-test.sh`
- `test/shell.d/plugin-watcher-reap-test.sh`
- `test/shell.d/plymouth-set-test.sh`
- `test/shell.d/powerprofiles-set-test.sh`
- `test/shell.d/provision-owner-keyboard-test.sh`
- `test/shell.d/provision-user-test.sh`
- `test/shell.d/retired-installer-artifacts-migration-test.sh`
- `test/shell.d/screenrecording-process-test.sh`
- `test/shell.d/screenrecording-test.sh`
- `test/shell.d/screenrecording-wf-audio-test.sh`
- `test/shell.d/screensaver-workspace-test.sh`
- `test/shell.d/security-fingerprint-remove-test.sh`
- `test/shell.d/shell-ipc-socket-test.sh`
- `test/shell.d/shell-shortcuts-test.sh`
- `test/shell.d/sleep-lock-test.sh`
- `test/shell.d/snapper-timeline-leak-test.sh`
- `test/shell.d/sshd-hardening-migration-test.sh`
- `test/shell.d/system-power-test.sh`
- `test/shell.d/system-sleep-ownership-migration-test.sh`
- `test/shell.d/terminal-cwd-test.sh`
- `test/shell.d/theme-set-budget-test.sh`
- `test/shell.d/theme-set-tmux-test.sh`
- `test/shell.d/theme-staging-test.sh`
- `test/shell.d/theme-templates-test.sh`
- `test/shell.d/toggle-input-device-test.sh`
- `test/shell.d/update-lock-test.sh`
- `test/shell.d/update-orphan-test.sh`
- `test/shell.d/update-restart-kernel-test.sh`
- `test/shell.d/update-stay-awake-security-test.sh`
- `test/shell.d/webapp-install-escaping-test.sh`
- `test/shell.d/windows-vm-mount-boundary-test.sh`

</details>

The latest pre-fix upstream translation workflow was awaiting maintainer approval. Publishing this commit does not approve upstream Actions or establish that the updated workflow ran. The localization review thread remains for upstream review.


## Fresh installed-VM localization validation, October 19, 2026 EDT

This is a new run, separate from the October 17 evidence above. GitHub PR metadata, `git ls-remote`, and a fetch into an isolated standalone checkout all identified `dc2ff87b11ba458a059d14233e6698b86ecc22bc` as `Gberfield/omarchy:add-share-text`; a second remote check immediately before VM testing returned the same head. The earlier workspace, ISO, installed base, logs, and screenshots were located at `/home/gabe/Documents/Codex/2026-10-17/complete-the-remaining-live-validation-for` before rebuilding. They were retained without editing their checkouts, base, firmware, or caches.

### Fresh image and installed runtime

`TASK` below is `/home/gabe/Documents/Codex/2026-10-19/complete-graphical-vm-validation-for-my`. Its contribution checkout is `omarchy-validation`. The harness instructions require a fresh ISO for shipped-default changes, including the new English catalog entries, so this run did not rely on test syncing or replace files in an old installed base. It copied the retained ISO builder/package recipes into this task, preserved their symlinks, made private reflinked cache copies, and normalized only the isolated public source tree to Git file modes before packaging. Source mounts were read-only; the build used one host sudo operation and a uniquely named container with 16 GiB/6 CPU limits and a 10 GiB free-space guard.

The builder is `omarchy-iso` `3872d5a3695258944084f975749b4f88b7eced4a` with the retained task-local build fixes, recipes are `f097a2472d364a548130d2bff43614eb9417cda1`, and archiso is `424e78130db2af6c1ceb55b442d7914b1109ff2b`. The successful new ISO is `omarchy-2026.10.20-x86_64.iso`, SHA256 **`5e0570e8b685398e52eb7ff6b62ff5e3a97c8bb823425d4ad83fdb5e89a74e06`**. Its filename follows the builder's date convention; the build and test occurred October 19 EDT. The build exited **0**.

Before the graphical suite, `sha256sum -c /tmp/localsend-runtime.sha256` verified all seven installed files against `dc2ff87`: `bin/omarchy-menu-share`, `bin/omarchy-i18n`, `default/localsend/share-text.py`, the English and German `cli.json` catalogs, `locales.json`, and `plural.jq`. In particular, the installed composer SHA256 is `9e32c8d5f4f97bf19f3185780f68408824b0119d818c6c580a36c27dc9edbbef`, and the English catalog SHA256 is `8c62d8c7b04a2fbbd9b936862fc2d7c2f0c802b9e4aecd3a1fb5fabded946a52`. These were package-installed files under `/usr/share/omarchy`, not the synced test checkout.

Guest versions: LocalSend `1.18.2-1`, GTK `1:3.24.52-2`, PyGObject `3.58.1-1`, systemd `262.1-1`, Hyprland `0.56.2-4`, Quickshell `0.3.2.r7.g2b4501a-1`, and kernel `7.2.8-9-omarchy`. Host QEMU is `11.1.2`. The headless KVM guest had four vCPUs/8 GiB RAM, private QMP, localhost-only SSH, no VNC viewer, and no shared host clipboard or device passthrough. Only this task's VM, `localsend-14480-20261019-validation`, was targeted by lifecycle commands.

### Commands and full graphical results

From `$TASK`:

```bash
sudo -- /usr/bin/bash "$TASK/evidence/rebuild-iso.sh"
bash evidence/run-vm.sh
```

The second script executes the following command after hashing the single new image:

```bash
systemd-run --user --quiet --wait --pipe --collect \
  --unit=localsend-14480-20261019-validation \
  --description='Disposable LocalSend current-head acceptance VM' \
  --property=NoNewPrivileges=yes \
  --property=SystemCallFilter=~io_uring_setup \
  --property=SystemCallErrorNumber=EPERM \
  --property=LimitCORE=0 --property=MemoryMax=16G \
  --working-directory="$TASK/omarchy-iso" \
  /usr/bin/bash ./bin/omarchy-iso-test \
  "$TASK/omarchy-iso/release/omarchy-2026.10.20-x86_64.iso" \
  --sync-omarchy "$TASK/omarchy-validation" --port 41819 --memory 8192 --no-preview
```

There was **no `--reuse-base`**: the installer, first boot, installed-base save, and disposable acceptance overlay all ran. `--sync-omarchy` supplied tests only. The retained task-local harness also performed QMP shortcut/clipboard smoke checks, the installed-file identity checks, and the supplemental probes below. The harness delta and scripts are retained separately from the contribution; acceptance assertions were not weakened or edited.

The full graphical suite exercised all **ten files**, with no file skipped, in **242 seconds**: **seven passed, three failed**. The service journal records the harness exiting **1/FAILURE**. The outer execution session returned **143**; that is not reported as a successful wrapper exit. Complete test output and collected artifacts were retained.

| Acceptance file | New result | Detail |
| --- | --- | --- |
| `apps-test.sh` | PASS | Application launch/close checks |
| `cups-test.sh` | PASS | Service and authorization checks |
| `input-methods-test.sh` | PASS | Input-engine setup/composition checks |
| `menu-test.sh` | FAIL | `menu bar position changes to left` |
| `overlay-monitor-test.sh` | PASS | Monitor removal/recovery checks |
| `panels-test.sh` | FAIL | `weather location is visible` |
| `security-test.sh` | PASS | Guest security checks |
| `session-test.sh` | PASS | Session checks |
| `shell-surfaces-test.sh` | FAIL | `apps menu opens` |
| `system-test.sh` | PASS | Installed system/tool checks |

`menu-test.sh` again navigated to the Hyprland `looknfeel.lua` editor rather than Menu Bar. `shell-surfaces-test.sh` again expected the old menu surface while the screenshot shows the Apps grid. Both are the historical stale-navigation failures. The acceptance runner and all acceptance files are byte-unchanged between the prior `f7f95b835c241927aef19458a3e9692e96ed3bb1` source and `dc2ff87`; `git diff --exit-code` for those paths returned **0**.

`panels-test.sh` is an **additional failure in this run**, not part of the historical two-file result. Its Weather panel opened, then the 30-second `screen_contains "SAN FRANCISCO"` assertion timed out. The retained failure screenshot visibly contains `SAN FRANCISCO` and weather details; a separate native-resolution `tesseract ... --psm 11` reads both `SAN FRANCISCO` and `WIND`. The precise cause of the suite's scaled-OCR mismatch was not isolated. The file remains **FAIL**, and its later panel/navigation assertions were not reached. A weather-journal retrieval attempted after automatic guest shutdown returned SSH connection refused; no journal diagnosis or replacement pass is claimed.

### Current-head LocalSend and localization results

The installed-session supplemental command was:

```bash
OMARCHY_ACCEPTANCE_DIR=/tmp/omarchy-acceptance bash /tmp/localsend-vm-checks.sh
timeout 180 python3 /tmp/localized-gtk.py
```

The first probe was copied from `$TASK/evidence/followup/localsend-vm-checks.sh`; the second from `$TASK/evidence/localized-gtk.py`. Both reached their successful final assertions. They ran with the guest's real Wayland session, user manager, installed shell, packaged LocalSend, and current installed contribution files. No service-execution adapter replaced systemd.

- **PASS:** the actual Share submenu displayed Clipboard, Text, File, Folder, and Receive. Selecting Text opened the actual composer. The English prompt, Cancel/Choose device buttons, and shortcut hint were visually inspected with entered multiline Unicode. Actual `wtype` Ctrl+Enter reached packaged LocalSend; its rendered Selection panel staged the **59-byte** synthetic message. Literal `${HOME}`, `$(touch unwanted)`, quotes, and `--share` matched the expected native `--text` arguments, and no `unwanted` file appeared.
- **PASS:** direct flag-like `--share` and clipboard text also reached rendered native LocalSend selections. A **191,999-byte** synthetic Unicode clipboard staged as a **192.0 KB** file selection. The exact private file bytes, 0700 directory/0600 file modes, and removal of both file and directory after the owned app exited were asserted. No device card was activated.
- **PASS:** the actual graphical text process ran in a real user service with the fixed `Share text with LocalSend` description; systemd manager messages contained no synthetic `LSVM` marker. An independently named real service then failed to start packaged LocalSend on an intentionally nonexistent display: its journal records `cannot open display`, exit **1/FAILURE**, and `exit-code`. The installed shell visibly rendered `Could not share text` / `LocalSend exited with an error`; the dedicated screenshot and journal were inspected. Closing successful staging apps with TERM can also produce failure toasts; those incidental toasts are not substituted for this independently recorded startup failure.
- **PASS:** **16 real GTK cases** cover four isolated catalog/language fixtures—fully translated synthetic German, German with an empty Cancel translation and missing other keys, English, and unknown language—crossed with Ctrl+Enter acceptance, actual Cancel-button activation, Escape, and blank Ctrl+Enter followed by valid acceptance. Every case checked initial/whitespace button sensitivity and that blank Ctrl+Enter kept the dialog open. The real installed composer and `omarchy-i18n` were used, with no GTK replacement. All five label values, including application/window title, matched expectations; accepted stdout exactly matched the multiline Unicode payload and cancellation emitted nothing. UI translations, including literal shell-like text in the synthetic German prompt, never entered the payload.
- **VISUAL SCOPE:** German, mixed fallback, English, and unknown-language screenshots were inspected for the prompt, buttons, hint, Unicode, and clipping. Omarchy's tiled presentation does not display a separate composer title bar in these screenshots; the title and application-name properties were verified on the real GTK objects. GTK keyboard-event checks complement the actual menu/composer `wtype` Ctrl+Enter route; no physical-keyboard or device-transmission acceptance is implied.

The four automated `share-text-i18n-test.sh` cases also passed twice outside the guest: once with the current catalogs and once in a private copied fixture with all five German keys synthetically completed. `share-text-test.sh` passed **27 tests** plus its actual menu-parser assertion. These are separate automated results, not substitutes for the 16 real GTK guest cases. Task-local Bash syntax, Python compilation, and `shellcheck -x -P SCRIPTDIR evidence/followup/localsend-vm-checks.sh` passed. No new aggregate CLI/shell-suite pass is claimed.

### Retained evidence and cleanup

New artifacts are under `$TASK/omarchy-iso/test-runs/omarchy-2026.10.20-x86_64/runs/20261019-210122/`; the ISO and reusable `base.qcow2` remain in the surrounding release/test-runs directories. There are **123 retained PNGs** across the run, including 122 success/failure captures and the native notification capture. Important files include:

- `$TASK/evidence/iso-build.log`, `iso.sha256`, `vm-validation.log`, `vm-service-journal.log`, `full-suite-results.json`, `runtime.sha256`, `guest-versions.txt`, `cleanup.json`, `ledger.json`, `harness-current-run.diff`, and the exact probe/build scripts.
- `runtime-identity.log` and `omarchy-acceptance/localized-gtk-results.json` in the new run directory; the latter contains all 16 distinct case/action results with exact-payload assertions.
- `omarchy-acceptance/success-localsend-share-menu.png`, `success-localsend-composer-entered.png`, `success-localsend-composer.png`, `success-localsend-large-clipboard.png`, `success-localsend-detached-failure-notification.png`, and `success-localized-*.png`.
- `omarchy-acceptance/failure-menu-bar-position-changes-to-left.png`, `failure-weather-location-is-visible.png`, and `failure-apps-menu-opens.png`; the Weather native OCR text is `$TASK/evidence/weather-failure-native-ocr.txt`.

The owned VM was stopped and its disposable `run.qcow2` removed. Final checks found its collected unit absent/inactive with `MainPID=0`, no QEMU PID file, and ports **41819/41820 closed**. The new reusable installed base, ISO, scripts, logs, and screenshots were retained. No host GUI, installed Omarchy files, unrelated VM, or existing worktree was targeted for modification or shutdown. This run did not repeat the historical file/folder portal-picker acceptance, send data to another device, approve upstream workflows, post comments, or merge either PR.

The earlier **8/10** graphical results remain historical. The current-head full-suite result is **7/10**, with all targeted LocalSend/localization checks above passing within their stated scope.
