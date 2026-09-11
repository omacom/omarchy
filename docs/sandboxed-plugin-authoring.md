# Ward plugin authoring (preview)

Ward is Omarchy's isolated plugin security system. This is the developer and coding-agent reference for its sandbox currently implemented on this branch, not the trusted in-process plugin contract. CMake supports an installed native payload, but default packaging and final desktop compatibility gates remain unfinished; see the [development preview](omarchy-shell.md#sandboxed-plugin-development-preview) and [implementation inventory](../plans/sandboxed-plugin-grants.md). Proposed shortcuts are not accepted syntax until implemented.

Ward's product scope is third-party plugins distributed through the Omarchy plugin registry. New `omarchy plugin add` installations from Git URLs or local Git folders default to Ward and require compatible content. Omarchy's own first-party plugins remain in-process; `--yolo` explicitly trusts downloaded code without containment, while `--trusted-local` is limited to local Git folders. `--yes` alone never selects either mode. Host-owned installation records retain identity, source, commit and execution mode separately from capability approval. A `sandbox` installation or native review/approval also retains isolation identity before activation. Removing the declaration, changing the manifest ID, deleting the checkout manually or losing the native runtime cannot turn that installation into trusted QML. Disable retains this identity; successful explicit removal purges it, so a later installation makes a fresh trust decision. Registry-specific ingress/authentication remains unimplemented; recorded URLs and commits are traceability, not publisher authentication.

Isolation/provenance discovery is a dependency for all third-party plugins, including legacy trusted plugins on machines that never use Ward. If `omarchy-plugin-isolation` or installation-state discovery fails, the shell refuses third-party loading and the CLI explains which state is unavailable. Restore the installed helpers and state-directory permissions; missing native packaging alone does not disable this independent discovery helper. Successful native review and approval request a shell rescan, including a follow-up scan when one is already in progress.

Ward's source and tests use synthetic plugins and generic resource fixtures, including for compatibility adapters. Concrete third-party plugin trials are temporary external experiments, not new test harnesses in Omarchy or a plugin repository. Keep their build artifacts outside Ward's target directory and the reviewed plugin bundle. First-party plugins are not sandbox-port targets.

For process boundaries, rendering/input dataflow and resource paths, see the [architecture reference and diagram](ward-architecture.md). Omarchy separately supplies the [trusted worker runtime](ward-runtime.md); a plugin cannot choose that directory or add runtime configuration to its sandbox declaration.

## Start here

A plugin is a Git repository containing `manifest.json`, QML and its scripts/assets. Add `sandbox` to select isolation. Review snapshots the repository; approval binds that revision. Later checkout edits do not change approved code. There are no install scripts, build hooks, post-approval hooks or manifest-driven data-copy hooks. Include already-built assets before review.

```json
{
  "schemaVersion": 1,
  "id": "example.pet",
  "name": "Example Pet",
  "version": "1",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": { "name": "Example Pet", "category": "custom", "defaultSection": "right", "allowMultiple": false },
  "sandbox": {
    "version": 1,
    "requests": {
      "storage": true,
      "notifications": true,
      "settings": { "read": ["volume"], "write": ["volume"] }
    }
  }
}
```

The shared loader requires exactly one `bar-widget` kind with `entryPoints.barWidget`; an own `service` and `overlay` may also be declared with matching keys. These entry points are QML `Item`s. A custom `sandbox.entryPoint` is a separate development route for a complete worker QML configuration, responsible for its own windows and lifecycle. Other shared-loader kinds are rejected.

The outer manifest follows the [ordinary manifest reference](omarchy-shell.md#plugin-manifest). All entry-point values are safe paths **relative to the repository root**, such as `Widget.qml` or `ui/Overlay.qml`: no absolute paths, variables, URLs or traversal. Files must exist. Reviewed bundles are limited to 64 MiB, 4,096 entries and 16 directory levels; symlinks, hardlinked files and special files are rejected. Root `.git` data is excluded.

## Two resources, not four unrelated directories

The plugin owns two resources: **the bundle it ships** and **the data it writes**. Each has a path for local sandboxed code and a path usable by an explicitly approved host command. The current `OMARCHY_PLUGIN_*` variable names obscure that distinction: they are host-command paths, not local data/asset roots.

| Resource | Local sandbox path | Host-command path | Relationship |
| --- | --- | --- | --- |
| Shipped bundle: QML, scripts, images, sounds | `/plugin` (read-only) | `$OMARCHY_PLUGIN_PATH` | Omarchy automatically stages a host-visible copy of the approved bundle when exec access is granted |
| Mutable data: saves and generated files | `$HOME` (`/home/plugin`) | `$OMARCHY_PLUGIN_DATA` | With storage granted, these name **the same directory**, mounted under different paths—not two copies |

### DATA is the host path of the sandbox's home

With storage granted, Omarchy sets `OMARCHY_PLUGIN_DATA` to the host directory `$XDG_STATE_HOME/omarchy/plugins/<id>` (default `~/.local/state/omarchy/plugins/<id>`), and mounts **that very directory** at `/home/plugin` inside the worker. The worker's `HOME` is `/home/plugin`; it is never the desktop user's home.

These are two ways to address one saved file:

```text
Sandbox code:   $HOME/save.json
               /home/plugin/save.json

Host command:  $OMARCHY_PLUGIN_DATA/save.json
               <host state home>/omarchy/plugins/<id>/save.json
```

Write it using `$HOME` inside the sandbox. Only if a host command needs that file do you pass the corresponding DATA path through an approved exec request. HOME and DATA identify the same persistent directory; authors must not construct the machine-specific host storage path themselves. At exec preparation, the broker snapshots selected DATA input files into sealed descriptors so a later worker rename or symlink cannot redirect the command's read.

These paths are not audio-specific. Any approved host command can receive a shipped file through PATH or a saved/generated file through DATA, provided its selected exec leaf admits that argument. For example, an image tool could read a generated image through DATA; a player could read a shipped sound through PATH. The distinction is the file's owner and lifetime, not which command reads it.

Without storage granted, `$HOME` instead names a fresh 32 MiB temporary filesystem and `OMARCHY_PLUGIN_DATA` is absent. Successful writing therefore does not prove persistence: check `grants.storage`. A plugin that stores data entirely inside its own sandbox **still requests storage** when that data must survive restart; it does not use `/plugin` for persistence.

Storage is keyed by plugin id, not revision. Updates preserve saves; revocation removes access but retains data; regranting reconnects the same identity to those files. Explicit plugin removal permanently deletes this private data along with the checkout, security records and reviewed snapshots. It does not delete host files accessed through filesystem or exec grants. The host directory has mode 0700. No persistent disk quota is enforced yet; bound caches and remove obsolete generated files yourself. Existing data from an unsandboxed plugin is not automatically imported from the desktop user's home.

Worker-local XDG suffixes are preserved exactly: `$HOME/.local/state/pet/save.json` corresponds to `$OMARCHY_PLUGIN_DATA/.local/state/pet/save.json`, **not** `$OMARCHY_PLUGIN_DATA/save.json`.

### When an author uses `/plugin`

`/plugin` is where sandboxed code reads the approved bundle. **It is never writable storage.** You often need not spell it out in QML: `Qt.resolvedUrl("assets/pet.png")` resolves relative to the QML file, which itself lives under `/plugin`. Use an explicit `/plugin/...` path when a bundled script or worker-local tool needs a bundle-root-relative filename.

For example, `["/bin/bash", "/plugin/scripts/save.sh"]` starts a bundled script inside the sandbox. The script might read `/plugin/defaults/save.json` and write `$HOME/save.json`. Neither action is a host exec request. Ordinary Quickshell `Process` calls and bundled native modules inherit the sandbox restrictions.

For an explicitly approved host command, `/plugin/sounds/chime.wav` would be the wrong argument: `/plugin` is a mount in the worker's filesystem, not in the host command's filesystem. Pass `$OMARCHY_PLUGIN_PATH/sounds/chime.wav` instead. New audio integrations should use the dedicated `audioPlayback` grant and sandbox-local `omarchy-ward-play` helper described below; that path needs neither host execution nor host asset staging.

`OMARCHY_PLUGIN_PATH` exists when exec access is admitted. Its value names a fresh controller-owned copy of the reviewed bundle, not the editable checkout. Removed assets do not carry over from another revision, and the service manager removes temporary staging when the controller stops, including abnormal exits. Never cache this host path across launches.

Both `OMARCHY_PLUGIN_*` variables contain host-side absolute paths. Their values are **not additional mounts accessible to local `FileView`, `cp`, `open()` or QML image loading**. To create a save path in QML use `Quickshell.env("HOME") + "/save.json"`; in Bash use `"$HOME/save.json"`. JSON and QML strings do not perform shell variable expansion.

### Paths in the manifest

Entry points are repository-relative: `"barWidget": "ui/Widget.qml"`, not `/plugin/ui/Widget.qml` and not a variable. Shipped assets need no filesystem grant. For persistent saves request `storage`, with no data-directory path in the manifest. Only exec argument constraints use `$OMARCHY_PLUGIN_PATH/...` or `$OMARCHY_PLUGIN_DATA/...`, because those constraints describe arguments to a host command.

Access to unrelated user files is separate: declare a named `filesystem` request with its host `path`, `target` (`file` or `directory`) and `access` (`read` or `readwrite`). The user allows or denies that exact request; approval never asks the user to supply a path. An approved directory is available locally at `/grants/<name>/...`; an approved file is `/grants/<name>`. That mount path has no automatic host-command translation. `/tmp` and `$XDG_RUNTIME_DIR` (`/run/plugin`) are temporary. File access does not authorize connecting to host pathname sockets in saved data or declared folders.

Selected folders cannot expose Ward's actual store, signing keys, private session runtime or credential roots, including enclosing directories and resolved aliases. Writable grants also cannot overlap host configuration, local program/state/data roots or the configured Omarchy/native runtime. Select a separate data folder, not the desktop home or a control tree. These checks run at approval and again at admission, including for older signed approvals. A valid signature is not permission to mount an authority directory.

Those overlap checks resolve the selected root and its ancestors; they do not recursively audit every descendant inode. A same-account host process could hardlink a protected file into an otherwise permitted folder. Signing-key link counts receive separate checks, but arbitrary descendant hardlinks are not generally detected. Creating those aliases requires host authority outside the worker boundary; defending against a compromised same-account host process is not this model's promise.

### How files get into DATA

There is no separate DATA staging action. The host creates the persistent directory when a storage-granted worker launches and mounts it at `$HOME`. Anything the plugin writes there is immediately in the same directory addressed by `$OMARCHY_PLUGIN_DATA` for host commands.

Leave read-only defaults in the bundle. If a mutable copy is needed, initialize it on first use inside the worker without overwriting an existing save:

```bash
#!/bin/bash
set -euo pipefail

if [[ ! -e $HOME/save.json ]]; then
  cp -- /plugin/defaults/save.json "$HOME/save.json"
fi
```

Initialize once in the owning service before concurrent writers start. For ongoing updates use atomic replacement and a data-format version; never copy defaults over retained saves on every update. Request `"storage": { "required": true }` if operation without persistence would be misleading. With optional storage, handle a declined grant: disable persistence-dependent features or explain that files are temporary.

Writing locally needs no exec grant. Only a host command consuming the file needs its own selected exec permission. Do not copy the bundle into DATA merely for host asset access; PATH staging serves that purpose already.

### Path tokens in exec declarations and calls

The exec matcher substitutes only the two plugin path tokens. It resolves candidate arguments and `exact.value`, `oneOf.values` and `text.prefix` constraints. It does not interpolate regex patterns or arbitrary manifest fields. `$HOME`, `${OMARCHY_PLUGIN_DATA}`, `~`, command substitutions and embedded `--file=$OMARCHY_PLUGIN_DATA/x` are not this token syntax. Supply a path as its own argument beginning with the exact `$OMARCHY_PLUGIN_DATA` or `$OMARCHY_PLUGIN_PATH` token.

Prefer literal tokens so plugin code need not know a machine-specific host path:

```bash
/bootstrap --exec player --volume 0.5 '$OMARCHY_PLUGIN_PATH/sounds/chime.wav'
```

The single quotes deliberately prevent Bash expansion. In a QML `Process.command` argv array use `"$OMARCHY_PLUGIN_PATH/sounds/chime.wav"`. Reading `Quickshell.env("OMARCHY_PLUGIN_PATH")` and appending the suffix also works, but only as an exec argument. Neither form grants authority; the entire argv must match a selected leaf. A host command's own `$HOME` is the desktop user's home, not `/home/plugin`.

Token-relative `.`/`..`, empty components and traversal are rejected. This lexical check is not a host-filesystem sandbox or a promise about symlinks created in writable data. An approved CLI retains its own account, configuration, filesystem and network authority; constrain arguments accordingly. Prefer exact shipped filenames to open-ended text prefixes. Host asset staging is an implementation detail, not a stable path to cache across launches.

A text prefix naming the bare PATH or DATA root matches that directory and its descendants, not a sibling whose name begins with the same bytes. Ordinary filename prefixes beneath the root retain text-prefix semantics.

DATA arguments are regular read-only file inputs: the broker opens beneath the selected root without symlinks, hardlinks or nested mounts, copies at most 64 MiB total per request, seals the copies and passes inherited `/proc/self/fd/N` names to the command. Both token and absolute DATA spellings receive this treatment. Directories, special files, output destinations and tools requiring a filename extension or sibling-relative files are not supported by this contract. PATH remains the immutable reviewed bundle. Copying a concurrently edited file may capture mixed plugin-authored bytes, but cannot change the pinned source into another file; the command must still treat those bytes as untrusted input. This does not sandbox the approved command's own configuration, dependencies or semantics.

## Sandbox manifest schema

This is the complete current `sandbox` request vocabulary. Unknown fields inside `sandbox`, requests and request objects are rejected. Omitted request fields default to denied/not requested. Declaration is not approval. The serialized manifest and saved approval are each limited to 64 KiB, which can bind before count limits.

`sandbox` contains `version: 1`, required `requests: { ... }`, and optional `entryPoint`. Atomic requests use `true` for **optional**, `false` for not requested, or `{ "required": true }` for required. `{}` and `{ "required": false }` also request optional access. Required access still needs explicit approval; missing required grants prevent activation.

| `sandbox.requests` key | Accepted shape | Meaning and selection |
| --- | --- | --- |
| `storage` | Atomic request | Persistent private home; `--allow-storage` |
| `network` | Atomic request | Broad host network namespace, including local services; `--allow-network`. Cannot be granted together with scoped HTTP or the public proxy |
| `networkProxy` | Atomic request | Public-destination HTTP/CONNECT streaming proxy; `--allow-network-proxy`. Includes opaque TCP tunnels and data transmission, not per-URL scope enforcement |
| `notifications` | Atomic request | Text-only notifications; `--allow-notifications` |
| `audioPlayback` | Atomic request | Play audio on the default output; `--allow-audio-playback`. No recording |
| `microphone` | Atomic request | Record the default input, including a user-selected virtual source; `--allow-microphone` |
| `audioCapture` | Atomic request | Record the default output monitor, including other applications' audio; `--allow-audio-capture` |
| `desktopGeometry` | Atomic request | Read-only all-output/workspace/window geometry; `--allow-desktop-geometry`. No titles, content or compositor control |
| `openUrls` | Atomic request | HTTP(S) browser/webapp handoff; `--allow-open-urls`. Can transmit data without worker networking |
| `media` | `{ "service": "org.mpris.MediaPlayer2.Name", "required": false }` | Filtered access to the declared existing MPRIS player; allow with `--allow-media`. No user-supplied service or wildcard |
| `filesystem` | Array of `{ "name": "notes", "path": "$HOME/Notes", "target": "directory", "access": "read", "required": false }` | Up to 256 unique names. `target` defaults to `directory`; `file` selects one exact file. `access` defaults to `read`; `readwrite` permits both. `write` alone is rejected. Allow a `read` declaration with `--read notes`; allow a `readwrite` declaration with `--write notes`. The two are not interchangeable |
| `settings` | `{ "read": ["volume"], "write": ["volume"], "required": false }` | Independent exact top-level keys of own inline settings; `--read-setting` and `--write-setting`. Lists default empty, combined limit 256 |
| `http` | Names mapped to `{ "scope": { ... }, "required": false }` | Up to 32 scopes; individually selected by `--http name` |
| `exec` | Names mapped to `{ "executable": "/usr/bin/tool", "tree": { ... }, "required": ["leaf"] }` | Up to 16 installed executables; selected by `--exec name:leaf`. `required` defaults empty. No execution-time cutoff. Legacy `lifetime: "request"` and `"plugin"` values are accepted and revision-bound but have identical caller-owned execution behavior |

Identifiers for resource names, settings and leaves are 1–96 ASCII characters: start with a letter or digit, then letters, digits, `.`, `_` or `-`; `..` is forbidden. Settings additionally exclude `id`, `sandbox`, `__proto__`, `constructor` and `prototype`. Each key covers its whole JSON value, not a nested path. Read does not imply write, nor write imply read. There is no all-settings wildcard, system-settings namespace, application-account provider or arbitrary host-command permission.

### Declarative permission review

Every permission decision is allow or deny. The manifest supplies the parameters; neither a user-entered path nor a user-entered service may replace them at approval. The graphical reviewer selects required permissions in the draft and displays them as static rows labeled Required, without switches; optional permissions have toggles, initially off. Nothing is granted until the user selects **Enable**, which approves the displayed revision and selections before activation. **Deny & Remove** rejects the plugin as a whole. The CLI can still omit required grants, but native activation refuses to start without them. Optional permissions remain independent and the plugin must handle their absence. Mark a permission required when the plugin's core function cannot work honestly without it, not merely because a feature uses it.

Filesystem `path` is an absolute path or begins with one of `$HOME/`, `$XDG_CONFIG_HOME/`, `$XDG_DATA_HOME/`, `$XDG_STATE_HOME/` or `$XDG_CACHE_HOME/`, resolved in the host's environment before approval. An unset XDG root uses its ordinary home-relative default. No shell expansion, arbitrary environment variables, `~`, traversal or glob/regex file selection is supported. Wildcard characters in a path are literal filename characters, not patterns. Review shows the declared path and its resolved host location. Approval binds the exact resolved target, file/directory kind and access; it cannot substitute another resource, widen read access to writes or downgrade a readwrite declaration to read-only. Allow the complete declaration or deny it.

A directory request exposes its admitted subtree, not only filenames the plugin happens to use. An exact-file request does not expose its parent directory, but replacing that file atomically changes its identity and requires reapproval. For a changing status file, a declared read-only status directory supports atomic replacement and file watching; review must plainly disclose that whole directory. Revocation cannot undo reads or completed writes.

Network permissions also have fixed, disclosed meanings. `network` is broad host networking, including local services, and has no domain, method or path parameters. `networkProxy` allows any public destination and TCP port through the proxy, including opaque bidirectional CONNECT tunnels; it is not restricted to the endpoints a plugin normally uses. To request enforceable origins, methods, paths, query fields and body constraints, use named `http` scopes. Selecting a public proxy alongside an HTTP scope does not make the proxy subject to that scope. Do not describe either broad permission as an API allowlist.

An exec selection is one complete tree branch. Review must show its executable and complete argument constraints, including exact shell text after `bash -c` when declared. The graphical reviewer labels the type **Host command** and shows the full command pattern in an attached **Command** disclosure: executable, literal arguments, `[alternative|alternative]` choices and bounded typed/regex arguments in order. Quoted literals preserve spaces, empty arguments and control characters. Matcher placeholders describe admitted arguments; they are not executable shell syntax. Internal grant and leaf names are not user-facing descriptions of authority. Pattern arguments use the bounded whole-argument regex contract below; filesystem requests do not inherit regex support from exec.

### Audio playback and capture

These are three independent, revision-bound permissions. None implies either of the others, networking, media-player publication, device enumeration, routing changes or control of other applications. A missing or false field in `/run/plugin/grants.json` means denied; selecting a grant does not itself start an audio stream.

Ward exposes one-way sample streams, not the desktop's PipeWire/PulseAudio socket. All streams use signed 16-bit little-endian PCM, 48,000 frames per second, two interleaved channels (left, right), with no container header. Decode media files, apply volume and encode recordings inside the worker. Ward's trusted host backend uses fixed `pw-cat` playback/record invocations; plugin-supplied filenames, URLs, formats, device names and PipeWire properties never become host arguments.

| Worker operation | Direction and lifetime |
| --- | --- |
| `/bootstrap --audio-playback` | Read PCM from stdin, play on the default output, and wait for drain after EOF. Exit zero means the backend completed, not that a physical speaker was audible |
| `/bootstrap --microphone` | Write PCM from the default input to stdout until the caller stops |
| `/bootstrap --audio-capture` | Write PCM from the default output's monitor to stdout until the caller stops |
| `omarchy-ward-play <local-file> [volume]` | Shared-runtime convenience helper: decode a local regular file with FFmpeg inside the sandbox and feed playback. Volume defaults to 1 and accepts 0–1 with up to three decimal places |

For a bundled effect, use a QML `Process.command` such as `["omarchy-ward-play", Qt.resolvedUrl("sounds/chime.wav").toString().replace(/^file:\/\//, ""), "0.5"]`. The filename is sandbox-local, not an `OMARCHY_PLUGIN_PATH` host token. This needs `audioPlayback`, not a host-exec request. Ordinary decoder/player processes remain subject to the worker sandbox. Continuous players may send PCM directly instead of using the file helper. Keep a player in the plugin's one shared service, not in each bar placement.

Playback is limited to two simultaneous streams per plugin; microphone and output capture each permit one. The combined maximum is four, with at most eight stream-start attempts per second. Each stream has a 16 KiB userspace relay buffer plus bounded kernel/audio-server buffers and backpressure. All jobs share the controller's existing memory, task and CPU limits. Active streaming has no ten-second request deadline; finite playback has a three-second drain bound after EOF reaches the backend. A busy endpoint rejects a new stream rather than queuing unbounded work.

These raw streaming operations do not support `--json`. Admission failures and backend failures return nonzero. A capture stream is indefinite: unexpected backend EOF is an unavailable outcome, not a successful finite recording. Stop the capture process when the desired recording is complete; closing its connection stops its host stream. Stopping/revoking the plugin or losing its controller stops every stream. Revocation cannot retract samples already captured, saved or transmitted, or audio already delivered for playback.

Input/output selection belongs to the host's session manager and routing policy. `microphone` follows the default input, which can be a virtual source selected by the user; it is not a promise that samples originate from a particular physical microphone. `audioCapture` requests sink-monitor capture rather than source capture and covers the default output, not every output simultaneously. Host routing can change what these streams hear. No plugin-controlled source/sink selector is exposed.

The existing `media` grant controls one already-running MPRIS player. Neither it nor `audioPlayback` permits publishing a new player to desktop media controls. The existing scoped HTTP broker is also separate: it buffers bounded responses and is not a continuous HTTP/CONNECT proxy for media players. Do not substitute the broad network grant when a restricted streaming-network contract is required.

### Public streaming proxy

`networkProxy` is a separate atomic request, selected with `--allow-network-proxy`. It provides long-lived public-destination connections while leaving the worker in its private network namespace. It is broader than a named HTTP scope: any public destination and TCP port may be selected, and CONNECT is an opaque bidirectional TCP tunnel. Ward does not inspect TLS or enforce HTTP methods, paths or bodies inside that tunnel. Plugins can send data through this permission. It grants neither host credentials nor access to loopback, private, link-local, reserved or other denied address classes. It cannot be combined with broad `network`, which would bypass those restrictions.

The bootstrap starts a bounded localhost bridge at `http://127.0.0.1:18765` inside the existing private namespace, after applying the worker restrictions. It sets lowercase and uppercase `http_proxy`, `https_proxy` and `all_proxy`, with empty `no_proxy`. Proxy-aware sandboxed tools can use those variables; tools that ignore them cannot reach the Internet directly. The worker receives TLS trust roots for its own HTTPS validation, not the host's resolver, network namespace or audio sockets. No nested namespace or extra capability is needed.

The host accepts absolute-form HTTP GET/HEAD with no request body, or CONNECT with an explicit host and port. Each ordinary HTTP connection carries exactly one request, with a rewritten Host and `Connection: close`; proxy authorization and fixed hop-by-hop fields are not forwarded. Redirects are returned to the client, which must make a new proxy request. Every new connection resolves again on the host, rejects the entire result if any of at most sixteen distinct addresses is disallowed, checks that routing does not point back to the host, then connects to that validated numeric address without a second DNS lookup. IPv4-mapped, NAT64, 6to4 and other non-public/transition address forms are conservatively rejected. This is destination-class filtering, not a claim that a public server is trustworthy or cannot itself relay traffic.

There are eight concurrent connections and eight starts per second per plugin. Headers are capped at 16 KiB; setup, including DNS and route lookup, has a ten-second watchdog. Streaming has no total body-size or duration cap, but ends after sixty seconds without relay progress. Each relay uses two fixed 16 KiB buffers with backpressure, plus kernel buffers, under the existing controller/worker resource limits. Disconnect, stop, revocation and controller loss terminate owned connections. Data already sent cannot be retracted. The proxy wire protocol is HTTP, not the bootstrap JSON operation protocol; an HTTP 403 is a denied destination, and an HTTP 503 means proxy capacity was unavailable.

Named `http` grants retain their existing API-call limits and exact scope matching. A plugin may request both when it needs both interfaces, but the public proxy is broader public-network authority and must be disclosed as such; an HTTP scope does not constrain connections made through the proxy. Audio playback remains separately selected.

### Exec tree schema

This is current syntax, not the proposed flat argv form. A node has optional `end` (a unique leaf name) and `next` (array, default empty). A step is `{ "arg": <constraint>, "then": <node> }`. A selected `end` permits the complete argv ending there only, not trailing arguments or descendants. Empty dead-end nodes are invalid.

| Matcher | Shape and semantics |
| --- | --- |
| Exact | `{ "kind": "exact", "value": "status" }`: one literal argument |
| Alternatives | `{ "kind": "oneOf", "values": ["0.25", "0.5"] }`: 1–32 distinct literals |
| Integer | `{ "kind": "integer", "min": 1, "max": 100 }`: unsigned 64-bit range, decimal digits without sign or leading zero except `0` |
| Text | `{ "kind": "text", "prefix": "query=", "min": 6, "max": 128 }`: literal prefix and UTF-8 byte bounds on the **whole** argument |
| Pattern | `{ "kind": "pattern", "value": "/threads/[0-9]+", "max": 64 }`: bounded whole-argument regex, not a substring |

Limits: 32 arguments, 8 KiB per argument, 64 KiB combined argv, 512 nodes and 64 KiB serialized tree. NUL is rejected. Regex source is capped at 4 KiB, nesting at 32 and compiled automata at 64 KiB; backreferences/lookaround are unsupported. Text bounds with a path prefix apply to the final resolved host path, not the token. This complete exec request permits one shipped sound:

```json
{
  "executable": "/usr/bin/pw-play",
  "tree": {
    "next": [{
      "arg": { "kind": "exact", "value": "--volume" },
      "then": { "next": [{
        "arg": { "kind": "exact", "value": "0.5" },
        "then": { "next": [{
          "arg": { "kind": "exact", "value": "$OMARCHY_PLUGIN_PATH/sounds/chime.wav" },
          "then": { "end": "chime" }
        }] }
      }] }
    }]
  }
}
```

Place it at `sandbox.requests.exec.player`; select with `--exec player:chime`. Executable paths must be absolute, contain no traversal and resolve to an installed regular executable. Symlink aliases are supported: the declared path remains the invocation name (`argv[0]`), while approval pins the resolved executable's bytes. Each launch resolves the path again and executes a sealed copy only if its bytes still match; changing the binary requires reapproval. This does not pin libraries, configuration or descendants. The matcher cannot infer CLI safety. Never permit arbitrary shell programs, GraphQL documents or CLI flags merely to shorten a declaration.

Host jobs preserve host user/group mappings and run a sealed executable copy inside a child cgroup under the controller's resource limits. They do not add a filesystem or user-namespace sandbox to the approved CLI. For a shebang script, the interpreter receives a `/proc/self/fd/...` script path, so scripts that locate adjacent files through `$0` need explicit paths. Normal exit, cancellation and owner death terminate remaining job-group processes; cleanup waits for the kernel's empty-group event with a one-second bound. Effects handed to another host service are still outside that cleanup.

Executable verification and sealing run outside the compositor/input loop, within the same two exec slots and controller resource limits. Preparation performs no execution and holds no approval lock. Immediately before spawning the sealed snapshot, the broker checks live authority, selected arguments and executable identity again under the approval lock. A canceled or timed-out preparation retains its slot until verification finishes, then discards the snapshot; cancellation cannot create an unbounded set of verification threads. Preparation has a ten-second watchdog, separate from execution, which has no duration cutoff. Keyboard repeat handling is unchanged: slow executable hashing no longer delays delivery of a key release.

Every approved foreground command may run while its requesting helper and plugin remain alive; stopping either cancels the whole job group. There is no execution-duration cutoff in the broker, guardian or reply forwarder. Legacy `lifetime` values remain accepted and bound to existing manifests/grants for compatibility, but neither imposes a deadline. Executable preparation still has its separate watchdog, output remains limited to 2 MiB per stream, and long jobs occupy the same two concurrent exec slots. This is not detached execution: stdout/stderr and final status arrive when the command ends, and a parent that exits still loses its descendants. Use a separate QML `Process` for a long-running session and communicate readiness through its deliberately scoped status interface. No additional environment, sockets, devices or filesystem authority is implied.

### HTTP scope schema

Each scope requires `origin`, `method`, `path`; optional `subtree` defaults false, `query` defaults empty, `body` absent/null means no body. `origin` is one canonical HTTP(S) origin without trailing slash. Methods: `GET`, `HEAD`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`. GET/HEAD cannot declare a body.

`path` is an exact canonical absolute URL path, optionally containing `*` for one nonempty segment. For a subtree set `subtree: true` with a trailing-slash path and no `*`. Percent-encoded paths, ambiguous normalization, credentials and fragments are unsupported. Query values may be percent encoded; matching compares decoded strings.

`query` maps keys to `{ "required": false, "value": <field> }`. Unknown/duplicate keys are denied. Query fields permit only exact strings or bounded strings. `body` maps keys to fields; supplied JSON must have exactly those keys, with no implicit extra fields.

| HTTP field | Shape |
| --- | --- |
| Exact JSON | `{ "kind": "exact", "value": <any JSON value> }` |
| String | `{ "kind": "string", "max": 256 }` |
| String or null | `{ "kind": "nullableString", "max": 256 }` |
| Exact-field object | `{ "kind": "object", "fields": { "name": <field> } }` |

Limits: 64 query keys, 256 fields per object, validator nesting depth 4, string/exact-value bounds up to 64 KiB, URL 4 KiB, scope path 2 KiB, total request 64 KiB. The broker owns TLS and does not inherit cookies, proxies or host credentials, nor automatically follow redirects. Domain origins reject private/special resolved addresses; literal IP origins explicitly select an address. This is separate from granting an authenticated host CLI.

## Runtime interfaces

Read `/run/plugin/grants.json`, not the manifest, to discover admitted access. This read-only projection contains booleans for atomic grants, `null` or a selected service for `media`, selected maps for `filesystem`/`http`/`exec`, and `settings.read`/`settings.write` arrays. Filesystem entries expose only `access`/`target`; exec entries expose only `selected`/`lifetime`, not host paths, inode pins, executable digests or argument trees. `grants.storage` controls persistence; `grants.exec.<name>.selected` lists admitted leaves. Modifying a local copy changes no authority.

| Operation | Worker interface | Limits/semantics |
| --- | --- | --- |
| Host CLI | `/bootstrap --exec <name> <argv...>`; shared alias `omarchy-ward-exec` | Literal argv, binary stdout/stderr, CLI exit status. Host cwd `/`, EOF stdin, no caller-selected environment. Two concurrent jobs, no execution-duration cutoff, 2 MiB each stdout/stderr. Caller disconnect, plugin stop and revocation cancel the job. Forwarder may retry explicit not-started busy/rate-limit replies for up to 120 seconds; never block the UI thread |
| HTTP | `/bootstrap --http [metadata-file]`; alias `omarchy-ward-http` | One JSON stdin request: `scope`, `method`, `url`, optional `body`. Raw response on stdout; optional status/selected-header JSON in a worker-local file. 2 MiB response body, twelve concurrent jobs, ten-second deadline. Check HTTP status separately from transport success |
| Notification | `/bootstrap --notify <title> <body>` | Title 1–160 bytes, body up to 2,048 bytes, constrained controls, no actions/images. Fixed plugin identity; two deliveries per 30 seconds |
| Open link | `/bootstrap --open-url browser <url>` or `... webapp <url>` | HTTP(S) up to 2,048 bytes, no whitespace/controls/backslashes; two deliveries per 30 seconds. Success means launch accepted, not page loaded |
| Shared link aliases | `omarchy-launch-browser <url>`, `omarchy-launch-webapp <url>` | Exactly one URL argument; denial produces shared-runtime feedback |
| Save own settings | Own shell API's `updateEntryInline(id, patch)`; low-level `/bootstrap --settings '<JSON object>'` | Widgets reach the API through `bar.shell`; service/overlay Items receive `shell`. Only selected writable keys. Host merges without deleting unselected values. Shared API acceptance queues a save, not durable confirmation; rejected saves restore host values and show feedback |
| Observe desktop layout | Own shell API's read-only `desktopGeometry` property | Requires `desktopGeometry` selection; detached live geometry or `null`. No compositor socket, handles or commands |
| Existing player | MPRIS through the worker's filtered `DBUS_SESSION_BUS_ADDRESS` | Exact selected player at `/org/mpris/MediaPlayer2`: property Get/GetAll, introspection, Next/Previous/Pause/PlayPause/Stop/Play/Seek/SetPosition and PropertiesChanged/Seeked. No Properties.Set, OpenUri, Raise, Quit, arbitrary bus access or player publication |

The bounded request brokers in this table share a 32-connections-per-second admission ceiling. Audio and the streaming proxy have their separately documented eight-starts-per-second limits. Revocation cancels owned jobs and stops the worker but cannot undo completed writes or retract effects delegated to other host services.

### Approved grants are signed into the record

The review turns a request into durable authority: approval signs `{ id, revision, enabled, grants }` with ed25519, and every read verifies that signature before trusting grants. Changes to signed approval content require a new signature; runtime state (`epoch`, `active_unit`) is excluded, so stopping can retain the existing signature without opening the private key. Hand-editing a grant record fails closed at dispatch and launch. The private key is `secrets/signing.key` (0600); filesystem grants cannot expose it or its enclosing store. This is not hardware-backed or an independent human boundary: a compromised same-account host process can still read and use the key.

Revocation persists a denial marker and attempts service stop before signing the disabled record. A signing/publication failure returns an error but retains denial; a missing private key cannot leave the previous approval admissible or prevent the stop attempt. After repairing the store, explicit recovery or a repeated disable completes the disabled record. A failure to write denial still attempts stop but cannot claim durable success. Neither mechanism retracts completed effects.

If the approval record or verification key is unreadable or corrupt, emergency teardown discovers generated systemd services and matches their live main process to the exact store and plugin ID before stopping them. It does not trust unit names or grants from damaged records, and does not stop other plugins or another store's same-ID plugin. Denial and the damaged record remain; revocation/removal still returns an error until the metadata is repaired. Discovery failures cannot be reported as successful cleanup.

### Machine-readable operation results

Prefix a direct bootstrap operation with `--json` to receive one versioned JSON record on stdout, including the operation's output. There is no result file or extra pipe:

```text
/bootstrap --json --exec player --volume 0.5 '$OMARCHY_PLUGIN_PATH/sounds/chime.wav'
/bootstrap --json --http
```

The HTTP command still reads its request from stdin; JSON mode includes response headers and body in the record and accepts no metadata-file argument. Notification, settings and open-link commands accept the same prefix. Internal worker/controller/management modes do not. No extra permission is granted by requesting JSON. Quickshell can use `Process` with `StdioCollector` and parse the complete stdout using `JSON.parse(text)` in `onStreamFinished`; catch parsing failures as unknown outcomes. No native QML adapter is needed.

Every complete record contains `version: 1` and `status`:

| `status` | Meaning |
| --- | --- |
| `completed` | The command returned an outcome, HTTP returned a response, or the notification/settings/link helper acknowledged delivery. This does **not** mean application success |
| `denied` | Ward rejected the operation's grant or selected arguments/scope; the requested operation was not started |
| `invalid` | Malformed or unsupported request; the requested operation was not started |
| `busy`, `rate_limited` | Capacity/admission rejection; this attempt was not started |
| `failed` | Operational failure, including executable verification, launch, transport or output delivery. Not a grant denial; effects may already have occurred |
| `timed_out` | No completed outcome within the deadline; effects may already have occurred |
| `unavailable` | Admission snapshot, broker connection or a valid reply was unavailable; do not assume the operation never ran |

A completed command adds `exitCode` or `signal`, plus `stdout` and `stderr`; a completed HTTP response adds `httpStatus`, the selected `headers` map and `body`. Output values are strings when the original bytes are valid UTF-8 (including escaped controls), otherwise objects of the form `{ "base64": "..." }` using standard padded Base64. Bytes are never replaced or silently discarded. Existing 2 MiB per-stream/body bounds apply before encoding; JSON escaping or Base64 can enlarge the encoded record. Child output cannot impersonate a Ward status because it is serialized as data inside the record, not appended alongside it.

For example, `{"version":1,"status":"completed","exitCode":1,"stdout":"","stderr":"invalid input"}` means the host command ran and exited 1, while `{"version":1,"status":"denied"}` means Ward refused it. HTTP 403 is `completed` with `httpStatus: 403`, not Ward `denied`. In JSON mode, helper exit 0 means a `completed` outcome was emitted, even for command exit 1 or HTTP 403; Ward errors return exit 1. Inspect the record's application exit/status separately. Delivery acknowledgement does not prove a browser loaded a page or a notification was seen.

Without `--json`, raw mode is unchanged: binary stdout/stderr and the command's exit code (128 + signal for signal termination), raw HTTP body with the optional metadata file, and exit 1 for HTTP status >= 400 or Ward errors. Raw exit 1 alone cannot classify the failure. Shared aliases retain this raw behavior; use `/bootstrap --json ...` directly for structured results.

Missing, empty, partial, unknown-version or unknown-status results are **unknown outcomes**, not permission denial or proof that nothing happened. Writing stdout can fail after an external effect. Never blindly retry `failed`, `timed_out`, `unavailable` or an unknown outcome for a mutation. The exec forwarder already retries only explicit not-started busy/rate-limit conditions for up to 120 seconds. The read-only grants snapshot lets the caller identify intentionally absent broker sockets, but the host still rechecks live approval on every request.

### Read-only desktop geometry

Request `"desktopGeometry": true` for optional access or `"desktopGeometry": { "required": true }` when the plugin cannot operate without it. The CLI requires explicit selection; the graphical reviewer starts optional access off and represents required access with a static Required row, without granting either until **Enable**. The grant exposes the whole supported layout, not only the plugin's own output; it is meaningful desktop observation even without window titles. Storage, networking, settings and drawing do not imply this grant.

Widgets read `bar.shell.desktopGeometry`; service/overlay Items read `shell.desktopGeometry`. Custom worker configurations may watch `geometry` in `/context/state.json`. The host publishes detached scalar snapshots through the existing read-only context mount; there is no worker query endpoint or write operation. Check `/run/plugin/grants.json`'s `desktopGeometry` boolean to distinguish declined access from a selected grant whose geometry is currently unavailable. Both expose `null`, not invented zero rectangles or a partial desktop.

| Field | Contents |
| --- | --- |
| `viewport` | Opaque ID of the active panel's output, or the host's first presentation output when no panel owner is selected |
| `outputs` | `{ id, rect, scale, reserved, activeWorkspaces }`; `reserved` is `[left, top, right, bottom]`; active workspaces may include the normal and visible special workspace |
| `workspaces` | `{ id, output }`; `output` is an output ID or `null` |
| `windows` | `{ id, workspace, rect, mapped, hidden, fullscreen }`; `workspace` is a workspace ID or `null` |
| Each `rect` | `{ x, y, width, height }` in global logical pixels, preserving negative positions and fractional values |

Output extents use Quickshell's logical screen dimensions, not unscaled monitor pixel dimensions. `scale` describes the output's compositor scale. To draw relative to a private output, use `Desktop.monitorFor(screen)` and subtract its `x`/`y` from global positions. `viewport` alone describes only the currently selected output, not every widget's output. The host still controls placement; this observation grant does not place a worker on every output or authorize moving host windows. Window rectangles are observations, not an occlusion map or a guarantee that every point is visible.

IDs are opaque positive integers tied to the host object's lifetime. Moving a window or changing its workspace preserves its ID; a closed window's compositor address can be reused without reusing the exported ID. Do not persist IDs across host restarts. Output/workspace names, window titles, app IDs, process IDs, raw compositor addresses and content are not exported.

One shared host observer requests window refreshes every 100 ms and monitor/workspace refreshes every second while isolated plugins are active. Quickshell bounds each model to one in-flight refresh. Snapshots reflect its latest cached models, not an atomic cross-model query or a real-time deadline. Malformed, incomplete or oversized projections become unavailable. Bounds are 32 outputs, 256 workspaces, 256 windows and 48 KiB serialized geometry within the existing 64 KiB total context limit; the host drops the whole geometry snapshot if it cannot fit alongside settings/theme/panel state. There is no silent truncation. Revocation stops the worker; it cannot retract geometry already read.

#### Explicit desktop adapter

Shared-runtime plugins may `import qs.Ward` and use `Desktop` for a small, read-only compatibility view. It reads the admitted permission itself: `Desktop.granted` reports the geometry selection, and `Desktop.available` additionally requires a usable snapshot. Plugins need not read the grants file or pass geometry through their service to use this adapter.

`Desktop.monitorFor(screen)` accepts any current private `Quickshell.screens` object and returns its associated observed output's `id`, global logical `x`/`y`, logical `width`/`height`, `scale`, `activeWorkspace: { id }` (or `null`) and `lastIpcObject: { reserved }`. Private presentation IDs and observed IDs are different namespaces; the host supplies their grant-filtered association. The active workspace is the normal workspace, matching the original read interface; use the full snapshot for the complete active-workspace list. Unavailable, retired or unrecognized screens return `null`.

`Desktop.toplevels.values` exposes `{ address, workspace, lastIpcObject }` for each observed window. Here `address` is a stringified **opaque Ward ID**, not a compositor address; `workspace` is `{ id }` or `null`; `lastIpcObject` contains only `at: [x, y]`, `size: [width, height]`, `mapped`, `hidden` and `fullscreen`. Without available geometry, the list is empty. Subscribe to `Desktop.changed` to rebuild observations; refresh requests and timers are unnecessary because Ward publishes updates.

This is an explicit adapter, not a replacement or shadow import for `Quickshell.Hyprland`. It provides no raw events, titles, application identifiers, compositor socket, dispatch, focus or other window-control methods. These compatibility-shaped objects are local snapshots, not live host QObjects or extra authority.

The shared runtime provides packaged `qs.Commons`/`qs.Ui`, detached live theme/style/settings, widget `bar`/`settings` properties and own-service/panel operations. Widgets reach the own shell API through `bar.shell`; service/overlay Items may declare `shell`, `manifest` and `omarchyPath` properties for injection. The API's `serviceFor(id)`, `summon`, `hide`, `toggle` and `isPluginOpen` are scoped to this plugin. Panels expose `open(payloadJson)`, `close()` and `opened`; the host manages input/dismissal, including closing private panels when the screensaver appears. This lifecycle policy sends no raw compositor events to workers and needs no observation grant. These are not access to other plugins, desktop config, authentication objects or compositor sockets. Worker `OMARCHY_PATH` names the restricted runtime, not the desktop source checkout.

Helpers, bundled scripts, timers, local IPC and computation need no separate execution permission. Their external effects still need grants. Rendering includes the selected GPU render node, not screen capture, audio output, microphone access, arbitrary devices, desktop observations, package mutation or host execution. Unsupported families are tracked in the [grant inventory](../plans/sandboxed-plugin-grants.md); do not invent manifest fields or use broad exec grants as undocumented substitutes.

### Host-owned bar placement

`omarchy plugin enable <id>` places a shared widget in its manifest's default section. The ordinary `--section`, `--index`, `--before` and `--after` options select another slot; `omarchy bar move` moves an enabled slot. Every configured bar placement receives its own widget instance, sharing one worker and one service. Keep polling, playback, timers and durable writers in that service rather than a widget that may have several instances. Custom complete-worker entry points retain their separate preview route.

Initial placement is provisional: the shell saves enable intent only after native content is presented. A failed startup, or one that presents no content within eight seconds, stops and reports an error without replacing the previous saved placement/settings. Approval remains available for retry; repair and re-review changed code before enabling again. This startup deadline does not apply to an already-started session during output changes. Provisional slots are not writable saved settings entries.

The private display exposes admitted outputs through ordinary `Quickshell.screens` and `Variants`. Output scales may differ, including fractional scales; each output has its own presentation buffers. There are at most eight outputs and 32 widget placements. Placement and output IDs are session-local, not values to persist.

Only one own panel is active per plugin. A widget click selects its placement and output; keyboard/IPC summon selects the focused host monitor, with a deterministic available-output fallback. An unspecified private layer-shell output follows the activated output. Switching ownership closes the prior presentation, and unplugging its output dismisses it and releases input while the service continues. A surviving widget can reopen it. Losing all outputs keeps the service running without visible/input surfaces.

Closed plugins are clipped to their own visible bar slots by default, even after a prior panel activation. Only a real own-slot gesture or explicit host summon authorizes a panel and keyboard focus. A worker's reported open state and layer-shell exclusive-focus requests do not grant that authority.

Roaming requires a user-controlled Omarchy entry setting: `sandboxPresentation: { "overlayMode": "visual", "overlayOutputs": "all" }` permits pixels without pointer input. `overlayMode: "pointer"` additionally permits pointer input, but never keyboard focus; `"none"` is the default. `overlayOutputs` selects `"owner"` (the active output or first available output) or `"all"`; selecting all outputs alone does not enable roaming. These are host configuration, not `sandbox.requests` fields or writable plugin settings. Existing roaming plugins require explicit host opt-in to the appropriate mode. Presentation permission and `desktopGeometry` observation remain independent.

The bar loads only a host-owned spacer. The worker reports preferred dimensions bounded to 1,024 logical pixels per axis; the host allocates a rectangle and supplies bar orientation and thickness through read-only context. The shared runtime mirrors that allocation in its private bar window, so existing widget and panel anchors follow host placement. This is own-surface allocation, not desktop observation, and needs no geometry grant. Size reports cannot place host windows, reserve screen space or acquire focus. The host clips input over a visible bar to the worker's own slot, so a full-screen private panel cannot swallow clicks on neighboring widgets. Hidden bars suppress the widget without stopping its service or own overlays.

Inline settings remain in the marked native entry. The host sends selected settings to the worker, but gives both stock and trusted replacement bars only the native entry's identity and marker. Fields such as `type`, `exec` and `source` therefore remain inert plugin data and cannot turn a native slot into a legacy host command or QML module. Component lifetimes belong to the shell rather than the first bar that instantiates them.

`bar.showTooltip(target, text)` and `hideTooltip(target)` use the shared bar styling and 400 ms hover delay, including all four edges and output-bounded plain-text wrapping. The target must belong to the private bar and expose `tooltipHovered`, as `WidgetButton` already does. Tooltips are input-transparent and clear on departure or bar hiding. While a panel is closed, pixels outside the host's own slot require explicit visual roaming permission; a private tooltip does not bypass that clip. Pointer departure preserves a focused panel and active drag; it is not a request for keyboard dismissal. Installed-VM and physical mixed-monitor acceptance remain distinct from private-display fixture coverage.

The shared `Panel.switchPanel(direction)` can request the previous or next configured bar panel. It sends only a direction through the existing authenticated UI channel; it cannot name another plugin, inspect its state or execute a command. The trusted host permits at most one matching request within one second of a real Tab or Shift-Tab/Backtab key press in this plugin's focused panel, without Control, Alt or Meta. Another key press, mouse press, focus loss, dismissal or stop clears that opportunity. The host bar chooses the neighboring target. This is host-owned keyboard navigation, not a cross-plugin lifecycle grant. A true return from the shared callback means the intent was queued, not that navigation occurred; unsolicited requests are ignored.

Focused keyboard events carry the host-resolved key symbol as well as the scan code, so another layout or a Unicode virtual keyboard is not reinterpreted as US keys. The private keymap is reconstructed only from symbols already delivered to that plugin's host item; the worker receives neither a compositor connection nor keyboard events from other applications. Scan codes pair presses and releases, and modifier keys retain their normal role. This key-event bridge does not add host clipboard access or an input-method/preedit protocol.

## Review and development

Use `omarchy plugin validate ./my-plugin` for ordinary validation, then `omarchy plugin add <git-url>` and `omarchy plugin review <id> --json`. Review performs native sandbox validation, runs no plugin code and returns the immutable revision. Ordinary validation alone does not prove native admission will succeed.

Approve that exact revision with selected flags, then enable separately (replace the revision placeholder):

```text
omarchy plugin approve example.pet --revision <sha256> --allow-storage --read-setting volume --write-setting volume
omarchy plugin enable example.pet
```

`--yes` skips terminal confirmation, not revision binding or grant selection; agents need authority for that approval. `omarchy plugin review <id> --ui` opens the same workflow. Missing required access prevents activation. `stop` halts a running instance without disconnecting its approval — it is the non-destructive predecessor to a re-approval, which requires no active instance (the old path forced a destructive `revoke` first). `disable` revokes and stops; `update` changes the checkout but does not approve it. Re-review and reapprove changed code. Never remove `sandbox` to work around startup failure.

`remove` is a complete uninstall, not another spelling of disable: it confirms controller shutdown and deletes the checkout, private saved data, approvals, snapshots, isolation markers and installation provenance. Original source repositories and files accessed through grants are left alone. A later installation starts with fresh trust and permissions. Removing an installed plugin cannot silently succeed when its controller record is unverifiable or cleanup fails. Staged reviews instead use an ephemeral snapshot; closing or denying one discards its temporary checkout without leaving native identity or history behind.

On a stock machine without the native executable, disable/remove can proceed only when the configured native store is demonstrably absent. Existing, symlinked or inaccessible state requires restoring the native runtime for safe cleanup: an absent executable is not proof that nothing was previously approved.

Keep this reference, parsing/enforcement, CLI/reviewer selection and tests synchronized. Examples must pass the native parser. See the [test guide](testing.md). GPU fixtures need short wall-clock and explicit memory/swap limits around the outer test process as well as worker limits; do not leave capture loops running between interactions.
