# Shared plugin runtime

Plugin entry points declare `required property var runtime`. Omarchy supplies it before initialization, in both Ward and explicit YOLO mode. The same sandbox-native QML and scripts run in the same worker in either mode; only permission selection changes.

## Execution modes

| Plugin | Default installation | Explicit YOLO installation |
| --- | --- | --- |
| Declares `sandbox` | Ward worker with individually selected permissions | Same Ward worker with all permissions declared by the reviewed revision selected |
| No `sandbox` declaration | Best-effort Ward worker with no resource permissions | Explicitly trusted in-process compatibility path |

Sandbox-native YOLO is **not unrestricted host execution**. Named commands still match declared argument-tree leaves; filesystem protection, scoped HTTP, executable verification and supported-integration constraints still apply. `/bootstrap` remains the real broker, not a no-op or arbitrary-command passthrough. Unsupported or conflicting declarations fail admission. Both modes need the native Ward runtime.

Legacy code without a declaration may lose features or fail to load in its restrictive default worker. Explicit legacy YOLO runs arbitrary same-account code; its scoped facade and local-job cleanup are conveniences, not containment. It does not require native Ward. First-party plugins remain unchanged.

Host-owned installation records select execution mode independently of downloaded metadata. A manifest edit, missing runtime, declined permission or failed startup cannot promote code to trusted execution. Updates retain the execution class but do not approve a new revision: review and approve again, using `--all-declared` when desired. Explicit removal ends an installation and purges its private saved data; it is not a data-preserving mode switch.

## Required runtime and owned jobs

```qml
import QtQuick

Item {
  required property var runtime
  property var refreshJob: null

  function refresh() {
    if (refreshJob) return
    refreshJob = runtime.exec("packages", ["-Qdtq"], {
      onFinished: result => {
        refreshJob = null
        if (result.status === "completed" && result.exitCode === 0
            && typeof result.stdout === "string")
          console.log(result.stdout)
      }
    })
  }
}
```

Here `packages` is a name in `sandbox.requests.exec`, not an executable path. Arguments are literal strings and must match a selected complete leaf. There is no executable-basename interception or fallback to local execution.

Use `runtime.runLocal([runtime.bundlePath + "/scripts/fetch", "--refresh"], options)` for a bundled script or local tool. Local work remains inside the worker in both sandbox-native modes. It can use ordinary local filesystem paths and environment variables. A nested QML service receives its owner's runtime explicitly: `Service { runtime: root.runtime }`.

The runtime belongs to its entry's lifetime. Jobs are foreground-owned, not detached; unloading that entry or stopping its worker cancels its outstanding work. Each completed job invokes `options.onFinished(result)` and emits `finished(result)` once, then destroys itself. Clear saved job references in that callback. Use `job.cancel()` for explicit cancellation. Jobs also expose `running`, `processId`, `write(text)`, `closeStdin()` and `signal(number)`; options support `stdin`, `keepStdin` and `onStarted(job)`. Bound cancellation does not undo effects already delivered to another service.

Local and named-command results use version 1 records: `status: "completed"` plus `exitCode` or `signal`, `stdout` and `stderr`. Application exit failure is distinct from `denied`, `failed`, `timed_out` or `unavailable`; explicit job cancellation reports `cancelled`. Streams are bounded to 2 MiB each and preserve binary data as `{"base64":"..."}`. Do not turn a failed package query into a successful zero count, or blindly retry a mutation after an unknown outcome. See the [full result contract](sandboxed-plugin-authoring.md#machine-readable-operation-results).

## QML versus scripts

QML uses named `runtime.exec(name, argv, options)` calls. Scripts running locally inside the worker call the broker directly:

```bash
#!/bin/bash
/bootstrap --exec gh api notifications
/bootstrap --json --exec gh auth status
```

For example, QML starts a bundled GitHub aggregation script with `runLocal`; that script uses `/bootstrap --exec gh` for its individual host GitHub calls, including calls from parallel child scripts. The aggregation script itself is not executed on the host. This division is identical in sandbox-native Ward and YOLO.

Ordinary Quickshell `Process` remains possible for low-level worker-local work, but the public runtime removes its usual process/collector/completion boilerplate. There is no public `Plugin.Process` wrapper.

## Paths and operations

| Runtime member | Meaning |
| --- | --- |
| `bundlePath` | Read-only `/plugin` in a worker; installed checkout for trusted legacy code. Relative QML asset URLs are usually preferable. |
| `dataPath` | Private plugin home; persistent only when storage is selected, otherwise temporary. Trusted legacy local jobs receive a private home too. |
| `statePath`, `cachePath`, `configPath` | Home-relative private XDG paths. |
| `runtimePath` | Private session directory for transient files and local IPC. |
| `filesystemPath(name)` | Selected worker mount, or empty string when unavailable. |
| `grants` | Admitted worker permissions, or the trusted legacy convenience projection. Not authority to bypass the host. |

Use `runtime.notify(title, body, options)`, `openUrl(url, options)`, `http(request, options)` and `play(localPath, volume, options)` for explicit operations. URL options may select `mode: "browser"` or `"webapp"`. HTTP uses the same named-scope request contract as `/bootstrap --http`. Playback locally decodes into the admitted PCM endpoint. Microphone, output capture and playback are distinct permissions.

Own settings remain available through `shell.updateEntryInline` or script-side `/bootstrap --settings`. `qs.Ward.Desktop` and `shell.desktopGeometry` provide detached, permission-filtered observations. Plugin code does not probe private socket paths to infer availability.

Custom complete-worker `sandbox.entryPoint` configurations are a separate low-level route and do not mount this shared QML adapter. Use ordinary shared `Item` entry points for this runtime. The compatibility backend for explicitly trusted legacy code supplies local jobs, private paths and operations, but no declared named host commands; adding a sandbox declaration requires a worker installation.
