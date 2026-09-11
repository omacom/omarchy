# Trusted Ward worker runtime

Ward's native build installs its executable and Qt module only. The desktop host supplies any shared worker loader separately, as a trusted runtime directory. Omarchy's adapter lives under `shell/ward-runtime/`; Ward does not copy it or resolve it relative to its executable. This directory split is implemented, while the broader host-effect and product-schema split remains [release work](../plans/ward-host-integration.md).

## Host contract

A runtime root contains a regular `runtime.json` file of at most 4 KiB and a regular executable entry point:

```json
{"version":1,"entryPoint":"worker"}
```

Version 1 accepts exactly these fields. `entryPoint` is one root-relative filename of 1–128 ASCII letters, digits, dots, underscores or hyphens, excluding `.` and `..`. Paths, arguments, interpreters and environment objects are not accepted. Symlink manifests and entry points, nonregular files, nonexecutable entries, missing assets and unsupported versions fail before worker launch. The adapter is responsible for the validity of its remaining imports; an import/startup failure never falls back to loading plugin QML in the host.

The trusted host passes an absolute runtime path to `Session::start_with_runtime` or `Session::start_with_topology_and_runtime`. The native `PluginSession.start` method accepts it as the last argument, after context. An empty/absent selection is supported for custom complete-worker configurations (`sandbox.entryPoint`); shared-worker manifests require explicit selection. A supplied selection is always validated, even for a custom worker, but custom workers do not mount or execute it.

The session thread opens and validates the directory before launching a service. After authenticating the controller, it sends one directory descriptor in the version-1 host-control runtime record (kind 22), before context or presentation configuration. The controller revalidates the manifest and entry point through that descriptor and accepts selection only once, before graphics starts. The normal host session command queue, worker broker and plugin manifest expose no runtime-selection operation. A plugin's own `runtime.json` is just an asset in `/plugin`.

Bubblewrap mounts the selected directory read-only at `/runtime`. The bootstrap applies the existing Landlock/seccomp restrictions before executing `/runtime/<entryPoint>`; entry-point code is trusted adapter code running **inside the worker sandbox**, not a host command. `/runtime/bin` precedes `/usr/bin` in the worker's bounded environment. The generic bootstrap does not set `OMARCHY_PATH`. The selected runtime does not grant host environment inheritance, host sockets, writable host paths or additional capabilities.

The directory descriptor pins directory identity against replacement of its original pathname. It does **not** freeze the directory's contents, pin dynamically linked libraries, or authenticate adapter publishers. Package the executable, native module and adapter as a tested compatible set. Stage adapter updates in fresh versioned directories, keep selected trees unchanged while sessions use them, and select the new tree only for new sessions. Automated publication, old-version retirement and a cross-package release compatibility scheme are not implemented by this preview.

## Omarchy adapter

`omarchy-ward-stage-runtime <new-absolute-directory>` stages only the worker loader, `WidgetView`, `qs.Ward`, shared Commons/Ui, `PluginShellApi`, the sandbox-local helper aliases and the small bootstrap. It refuses existing destinations and writes `runtime.json` last, so a partial staging failure has no selectable manifest. It does not publish an installation, approve a plugin, change config or restart the shell.

The Omarchy bootstrap sets `OMARCHY_PATH=/runtime` inside the already restricted worker, then starts the packaged loader. This preserves the plugin-facing compatibility contract without mounting the desktop source checkout or the host service tree. The host adapter selects `OMARCHY_WARD_RUNTIME` when explicitly configured for development; otherwise it selects `$OMARCHY_PATH/lib/ward-runtime`. Controller selection remains separately configured by `OMARCHY_WARD_HOST` or `$OMARCHY_PATH/lib/omarchy-ward`. The runtime need not be next to the controller, and there is no adjacent-directory fallback.

The host opens the runtime directly and passes its descriptor; selection does not depend on propagating the host process's environment through the systemd user manager. Existing Omarchy host-effect helpers still have their separate controller-side environment requirements. This change does not add the proposed host-exec environment profile or desktop handoffs.

The staged `omarchy-ward-play <local-file> [volume]` helper decodes with FFmpeg inside the worker and feeds Ward's fixed-format PCM playback endpoint. It requires the separate `audioPlayback` selection and does not invoke a host executable on a plugin-supplied file. Microphone and output capture use the separate raw bootstrap operations documented in the [authoring reference](sandboxed-plugin-authoring.md#audio-playback-and-capture). These additions require a matching native Ward build and a newly staged adapter.

Ward itself owns the optional `networkProxy` localhost bridge; the Omarchy loader does not start a second proxy or network namespace. The native bootstrap starts it only when its admitted socket is mounted, after applying worker restrictions. Proxy-aware helpers inherit the private bridge's proxy environment; there is no direct worker Internet access.

## Installed-style verification

Build the matched native executable/module and stage the native files and adapter separately, using fresh directories:

```bash
cargo build --locked --manifest-path native/ward/Cargo.toml --features graphics,qt-bridge
cmake -S native/ward/qt -B /tmp/ward-qt-build -DRUST_TARGET_DIR="$PWD/target"
cmake --build /tmp/ward-qt-build
stage_root=$(mktemp -d /tmp/ward-stage.XXXXXX)
cmake --install /tmp/ward-qt-build --prefix "$stage_root/native"
bin/omarchy-ward-stage-runtime "$stage_root/adapter-v1"
```

Invoke the staging helper from the intended Omarchy development session: its source is the session's authoritative `OMARCHY_PATH`, not an inferred checkout. No default package/setup step installs these files yet.

The private-display adapter suite uses `OMARCHY_TEST_SYSTEMD=1`, `OMARCHY_TEST_GRAPHICS=1`, `OMARCHY_TEST_QT_BRIDGE="$stage_root/native/lib/qml"`, `OMARCHY_TEST_WARD_HOST="$stage_root/native/lib/omarchy-ward"` and `OMARCHY_TEST_WARD_RUNTIME="$stage_root/adapter-v1"` with `bash test/shell.d/ward-integration-test.sh`. Run GPU suites under short wall-clock and explicit memory/swap limits around the outer test process. They do not operate the active desktop and do not replace installed-VM or physical-monitor acceptance.

Ward's `streams` test separately runs a synthetic, non-Omarchy runtime using only source in `native/ward`. It checks explicit host selection, a read-only runtime, absence of worker `OMARCHY_PATH`, malicious bundle runtime-selection assets, mixed-DPI presentation, shared state and hotplug. Omarchy loader, shared-output and documentation tests live in `test/shell.d/fixtures/ward-integration`. Broader native host-effect code and its existing notification-helper test still depend on Omarchy; the directory split alone is not the completed repository-extraction gate.
