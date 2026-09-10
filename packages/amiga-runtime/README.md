# omarchy-amiga runtime component candidate

This directory is source for the runtime component of the intended `omarchy-amiga` bundle, not a published OPR package. The production bundle contract combines the architecture-specific runtime with the minimal Top v1 content pack behind the single native menu install action. The end-user menu installs only `omarchy-amiga` through Omarchy's package helper; it does not run these build commands or separately assemble dependencies. The runtime package and Top release asset still require publication, license review and checksum pinning, so this candidate invents no repository or download URL.

## Independent review still required

The private backend now implements frame protocol 1: restore completion enables a producer generation, unchanged rows retain their source generation, and only a matching texture upload and completed draw can produce a checked OpenGL readback/swap record. The controller requires that record from the freshly truncated owned-child stdout stream, bound to its new random window token; stock completion lines alone never authorize presentation. This avoids another inherited descriptor/control-pipe lifecycle through bubblewrap. Unknown/rejected/mis-sized chunks latch rejection before any frame record, and controller-side diagnostics also override readiness. Missing instrumentation, wrong generation/token, incomplete records and missing frames fail closed under the startup deadline.

This candidate has been freshly built and mechanically exercised on aarch64 with SDL offscreen/software OpenGL, including a valid local test snapshot, unknown CPU chunk, truncation, missing state, no-load, stock binary and capture failure. Native unit tests cover a queued pre-restore upload, mismatched completed draw and actual producer copying of stale rows. These are mechanical framebuffer/protocol checks, not approval of a destination demo scene, whole production, hardware renderer, audio, compositor reveal or automatic idle. The observer does not retain/freeze the frame until compositor reveal; the existing opaque guard and independently checked owned-window geometry remain separate presentation safeguards. Do not commit or publish until a fresh independent review approves this exact diff.

## Pinned sources

| Component | Source | Pin | License |
|---|---|---|---|
| FS-UAE 3.2.35 | https://github.com/FrodeSolheim/fs-uae.git | `4ae7ddaec50b567ed80d71ffbff067cb58e945a3` | GPL-2.0-only; upstream component notices |
| OpenAL Soft 1.25.2 | https://github.com/kcat/openal-soft.git | `b2c48f7718ef3fcf67921a8b6534c4914e328970` | Upstream COPYING and bundled component licenses |
| Relative-pointer adapter, Pulse wrapper and guard | This reviewed Omarchy change | Candidate source revision | Omarchy license |

`build-fs-uae` archives the pinned Git object, not the upstream working tree. It applies `suppress-warning-hud.patch` (opt-in warning HUD suppression, retaining diagnostic logs and renderer identity) and `frame-readiness.patch`, and links `frame-observer.c` directly into FS-UAE. The hooks are custom source instrumentation, not alleged stock dynamic exports. `fs-uae/FRAME_PROTOCOL` must contain `1` and be covered by the runtime integrity manifest; old HUD-only runtimes require a rebuild, not a relabeled manifest. The configure prefix is the stable sandbox path `/opt/amiga/fs-uae`; the output is staged under the requested local prefix. No research directory or build-machine prefix is used by the running emulator. The script refuses a pre-existing build directory rather than silently reusing stale objects.

CMake verifies the exact OpenAL commit and unchanged tracked files, disables runtime dlopen, requires Pulse and disables other real audio backends. It builds for the current toolchain architecture. Native module loading uses a real `file:` URL, so `qmldir` can use a relative plugin location and the whole local-prefix layout relocates together. Do not route it through Quickshell's `qs:@` virtual module URL.

## Maintainer build

Use a clean Arch build environment. Build prerequisites include the C/C++ toolchain, Git, CMake, Ninja, pkg-config, Autoconf/Automake/Libtool, Qt 6 Core/Gui/Qml development files, Wayland and wayland-protocols, Pulse development files and FS-UAE's upstream build dependencies. The locally inspected FS-UAE runtime links glib2, libGL, libpng, SDL2, libX11, zlib and libmpeg2 in addition to the normal C/C++ runtimes and private OpenAL. The Qt module links Qt6Gui/Qml/Network/Core and Wayland. Private OpenAL links libpulse, libdbus and libatomic. Declare the actual Arch package dependencies after building in the target clean chroot; never repair SONAME mismatches with symlinks or bundle glibc.

From the Omarchy repository:

```bash
git clone https://github.com/kcat/openal-soft.git ../openal-soft
git -C ../openal-soft checkout --detach b2c48f7718ef3fcf67921a8b6534c4914e328970
git clone https://github.com/FrodeSolheim/fs-uae.git ../fs-uae
prefix=$(realpath -m ../amiga-prefix)
cmake -S packages/amiga-runtime -B ../amiga-native-build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$prefix" -DOPENAL_SOURCE="$(realpath ../openal-soft)"
cmake --build ../amiga-native-build -j3
cmake --install ../amiga-native-build
bash packages/amiga-runtime/build-fs-uae ../fs-uae ../amiga-fs-uae-build "$prefix"
python3 packages/amiga-runtime/write-runtime-manifest.py "$prefix/lib/omarchy-amiga-runtime"
```

For a distribution package, configure CMake with `/usr` and use `DESTDIR="$pkgdir"` at install. Pass `"$pkgdir/usr"` as the FS-UAE script's output prefix; its internal runtime prefix remains `/opt/amiga/fs-uae`. After every runtime artifact is staged, run `python3 packages/amiga-runtime/write-runtime-manifest.py "$pkgdir/usr/lib/omarchy-amiga-runtime"`; the generated manifest binds the target architecture and every executable/library/QML integrity root used by readiness. Install the component license texts produced by both build paths. Do not install the separate FS-UAE application globally or replace `/usr/bin/fs-uae`. Before release, include the complete corresponding patched FS-UAE source under its GPL obligations and finish the third-party license/redistribution review; this source recipe is not a claim that an OPR review has occurred.

The resulting package owns only:

```text
/usr/lib/omarchy-amiga-runtime/
  fs-uae/bin/fs-uae
  fs-uae/share/...
  fs-uae/SOURCE_REVISION
  fs-uae/FRAME_PROTOCOL
  audio/libopenal.so.1
  audio/libamiga-pulse.so
  guard/Guard.qml
  guard/AmigaInput/qmldir
  guard/AmigaInput/libamigainput.so
  bin/gl-probe
  runtime-manifest.json
  controller/state.py, runtime.py, pack.py, ...
/usr/share/licenses/omarchy-amiga-runtime/...
```

The `omarchy-amiga` bundle is the only menu-installed package. It must depend on the target-native runtime plus `bubblewrap` and `libpulse`, and its install transaction must stage and verify the minimal Top v1 archive before merging additions into `~/Wallpapers/AMIGA`. The runtime component must declare its complete native dependencies, including Quickshell/Qt compatibility and software-rendering support. The package never removes user media, and a failed readiness check never changes the selected mode.

## Source-only review without installing the desktop

The build commands above produce a local prefix; they do not select a screensaver, deploy an idle service or start an emulator. Media is deliberately absent from this repository. Without a separately obtained, redistribution-reviewed Top archive and destination-compatible states, maintainers can run the synthetic/controller/QML tests but cannot reproduce a real demo preview or a successful menu install. No one-click fresh install is claimed.

For the controller regression suite, run the following Bash commands from the checkout. Bubblewrap, Python, Node and the normal Omarchy test dependencies must be installed. Namespace creation must succeed; never retry these process-lifecycle fixtures outside the sandbox. This masks home and runtime sockets, clears the environment and makes the checkout read-only. Optional sibling package repositories are exposed read-only because baseline tests inspect them.

```bash
repo=$(pwd -P)
args=(--unshare-all --die-with-parent --new-session --ro-bind / / --proc /proc --dev /dev
  --tmpfs /tmp --tmpfs /run --tmpfs /home --ro-bind "$repo" /tmp/work --chdir /tmp/work
  --dir /tmp/tools --ro-bind "$(readlink -f "$(command -v node)")" /tmp/tools/node
  --clearenv --setenv PATH /tmp/tools:/usr/bin:/bin --setenv HOME /tmp
  --setenv LANG C.UTF-8 --setenv PYTHONDONTWRITEBYTECODE 1
  --setenv ROOT /tmp/work --setenv OMARCHY_PATH /tmp/work)
for namespace in pid user mnt net; do
  args+=(--setenv "OMARCHY_TEST_HOST_$namespace" "$(readlink "/proc/self/ns/$namespace")")
done
for sibling in omarchy-pkgs omarchy-iso; do
  if [[ -d $repo/../$sibling ]]; then
    args+=(--ro-bind "$(realpath "$repo/../$sibling")" "/tmp/$sibling")
  fi
done
bwrap "${args[@]}" bash test/shell.d/screensaver-test.sh
bwrap "${args[@]}" python3 test/shell.d/fixtures/amiga_qml_test.py
bwrap "${args[@]}" ./test/all
```

The QML replay additionally requires QtTest's `qmltestrunner`. These commands do not run the package emulator smoke, expose a Wayland/Pulse socket, or start a desktop. Compare aggregate failures with a clean checkout of the same base revision in the same namespace environment; do not stash an active dirty checkout. The candidate's baseline comparison is recorded in the PR, not interpreted as an all-green suite.

## Native frame-protocol tests

Each child accepts one immutable restore. Its internal generation is 1; navigation gets a new process, fresh log and unpredictable token rather than reusing that generation as a global identity. Records have the exact prefix `OMARCHY_FRAME_V1 <32-lowercase-hex-token>` followed, in order, by `protocol 1`, `restored 1`, and `frame 1 <positive-sequence> <width> <height> <16-hex-FNV1a64>`. An `error <reason>` record always rejects. The fingerprint covers the bottom-up RGB readback; it is a frame identity, not a magic approved-scene checksum. `OMARCHY_FRAME_CAPTURE` optionally writes a top-down PPM for isolated diagnostics and fails closed on write failure. Production does not set a capture path or store frame images.

After defining the namespace arguments in the source-test recipe above and building the pinned backend, run these native units in that same boundary. They compile the shipped observer against a real offscreen OpenGL context and the producer test against the actual patched upstream source. The producer test substitutes only single-threaded mutex transport. These units require no snapshot or media and do not claim emulation compatibility.

```bash
source=$(realpath ../amiga-fs-uae-build/source)
bwrap "${args[@]}" --ro-bind "$source" /tmp/fs-source \
  --setenv SDL_VIDEODRIVER offscreen --setenv LIBGL_ALWAYS_SOFTWARE 1 bash -c '
  set -euo pipefail
  package=/tmp/work/packages/amiga-runtime
  cc -std=c11 -Wall -Wextra -Werror "$package/frame-observer.c" "$package/test-frame-observer.c" $(pkg-config --cflags --libs sdl2 gl) -o /tmp/frame-observer-test
  OMARCHY_FRAME_TOKEN=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa OMARCHY_FRAME_STATE=/mechanical /tmp/frame-observer-test > /tmp/frame-events
  python3 -c '\''from pathlib import Path; text=Path("/tmp/frame-events").read_text(); assert " frame " not in text.split("CHECKPOINT incomplete-draw-rejected")[0]; assert text.count(" frame ") == 1; assert " frame 1 12 64 48 " in text; print(text)'\''
  cc -DHAVE_CONFIG_H -ffunction-sections -fdata-sections -I/tmp/fs-source -I/tmp/fs-source/libfsemu/include -I/tmp/fs-source/libfsemu/src/emu "$package/test-frame-buffer.c" $(pkg-config --cflags --libs glib-2.0) -Wl,--gc-sections -o /tmp/frame-buffer-test
  /tmp/frame-buffer-test
'
```

The separate real-emulator matrix needs a legally held destination-compatible state, private writable scratch state/base directories and exact media mounts, all inside the same verified namespace. Require a successful parsed frame record and independently verify PPM dimensions and fingerprint for the valid state; require no accepted frame for an unknown CPU chunk, truncated/missing state, omitted load-state, stock executable and failed capture. Use only registered subprocesses and pidfd cleanup, including bounded escalation for upstream's truncated-state hang. Keep test-state bytes and resulting images outside Git.

## Hardware-first rendering and presentation titles

The optional package now includes `bin/gl-probe`, built with SDL2 and libGL. The controller defaults to `OMARCHY_AMIGA_RENDERER=auto`: enumerate accessible render nodes, mount one exact render node (never card/input nodes or the whole device directory), and initialize a hidden SDL/Wayland desktop GL context inside the actual emulator sandbox. `/sys` is read-only for Mesa device discovery. Renderer names containing llvmpipe, softpipe, software, swrast or SwiftShader are not hardware. A missing node, failed context initialization or software-only probe selects the logged software fallback. `hardware` fails closed instead; `software` is a debugging override. No host renderer environment is inherited through the cleared sandbox environment. Probe termination uses registered subprocess handles and pidfds.

The renderer selection is recorded in `session.json`; FS-UAE keeps its actual OpenGL renderer log. The native guard uses the existing shell renderer, without changing or restarting that shell; a shell already running a software backend cannot be changed per Loader. Standalone scoped validation used the same compiled guard with OpenGL QRhi and proved Apple M2 Pro rendering for both processes. Do not infer the native desktop shell backend from emulator acceleration.

Production titles come from the checksum-bound catalog, never directory names. IPC passes them as separate arguments and QML renders `Text.PlainText`. Each fresh presentation arms an independent five-second title timer; it starts only once owned ScreencopyView content arrives. The title appears above the two-second audio/navigation hint. Audio acknowledgements restart only the control hint. Transition cover cancels the previous title; the next fresh restored child arms it again.

## Validation

Use the outer reviewed namespace runner, not raw lifecycle tests on a development desktop. `test/shell.d/screensaver-test.sh` exercises Python and native menu/guard/lock logic. `test/shell.d/fixtures/amiga_qml_test.py` replays the actual guard handlers and timer under QtTest. `test/shell.d/fixtures/amiga_package_test.py` expects `AMIGA_TEST_PREFIX` to name a read-only locally installed prefix available inside that outer namespace; it loads the actual compiled Qt module, exercises the compiled Pulse wrapper against a deliberately fake next connector and executes an explicitly audio-disabled, no-media FS-UAE offscreen boot. No fake connector is installed or used by production.

The package smoke is not a demo rendering or audible M test. An offscreen Qt platform has no Quickshell PanelWindow backend, so complete Overlay/menu presentation needs a separately authorized isolated Wayland desktop. Validate destination state restoration and successive manual navigation independently; the current pack has no verified ending contract and does not automatically advance. Re-run audible M tests with the finished package's exact Pulse stream, not a default sink or microphone capture.

Earlier aarch64/Qt 6.11.2 and x86_64 Kuyen runtime checks predate the frame-protocol change. Only the new aarch64 FS-UAE build has fresh native frame-gate verification; the installed runtimes and their manifests were deliberately left unchanged. The x86_64 frame-protocol build and live destination integration remain unverified. Reproducible here means pinned sources and explicit build/install steps, not byte-for-byte reproducibility across toolchains. The sustained-load thermal question on Kuyen remains unresolved and CPU/thermal investigation is explicitly deferred; do not infer long-duration thermal acceptance from the bounded renderer/menu checks.
