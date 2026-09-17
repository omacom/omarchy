# wp_viewporter worker-side support — handoff

Branch: `rust-plugin-sandbox-viewporter` (this worktree, based on
`origin/rust-plugin-sandbox`)

Feature commit: `e09acfefbdcd76aecf64eba993d5335b0b429242` (graphics.rs viewporter)
Test rework: `755d2a02bd28428d018a5e54180bc6c3d6d63540` (shared desktop fixture)

## What shipped

Worker-side `wp_viewporter` on the sandboxed private compositor, plus a
deterministic raw-Wayland-client test that proves the transform is honored end
to end (rendering, the input mask, and input hit-testing). No changes to the
renderer, `presentation.rs`, or `controller.rs`.

### `native/ward/src/graphics.rs`

- `use smithay::wayland::viewporter::ViewporterState`
- `_viewporter: ViewporterState::new::<App>(&dh)` created alongside the other
  global states (kept only to hold the `wp_viewporter` global registration
  alive; underscore-prefixed to silence the dead-code warning).
- `smithay::delegate_viewporter!(App);` added beside the other delegates.

Smithay 0.7's rendering path already consumes the double-buffered
`ViewportCachedState` into `SurfaceView { src, dst, offset }`
(`src/backend/renderer/utils/wayland.rs` `SurfaceView::from_states`), and
`render_elements_from_surface_tree` / `under_from_surface_tree` /
`bbox_from_surface_tree` / `contains_point` all operate on that `SurfaceView`.
So once the global is advertised and bound, rendering, the input mask
(`graphics.rs` `mask()`, which iterates `view.dst`/`view.offset`), and input
hit-testing (`graphics.input` via `under_from_surface_tree`) all honor the
user's crop/scale with no further worker changes.

The viewporter protocol is **not** feature-gated in Smithay 0.7.0, so no Cargo
feature was needed.

### Wire semantics (important)

`wp_viewport` has two requests with different numeric types:

- `set_source(x, y, width, height)` — four **wl_fixed** (fixed-point)
  coordinates in surface-local space; these may be fractional and express the
  source **crop** rectangle.
- `set_destination(width, height)` — two **int32** values; these are plain
  integers and express the on-screen **destination size** (the scale). Unset
  with `-1`.

So fractional destination sizes are **not** expressible through
`set_destination`; true fractional scaling would have to come from the
fractional-scale protocol (`wp_fractional_scale`) or by leaving the destination
automatic and relying on fractional source coordinates — the former is the
platform's path (see limitations).

### `native/ward/tests/viewporter.rs` (reworked)

A real Wayland client (this test process speaking the wire protocol) connects
to the in-process `Graphics` compositor on a private socket. Compositor setup,
GBM + GLES readback, and frame acknowledgement are reused from the shared
`tests/support/desktop.rs` fixture (`Desktop::new` + `step`) — no parallel
harness. The test:

1. Binds compositor, shm, `wp_viewporter`, `xdg_wm_base`, and seat; creates a
   `wl_pointer` via `seat.get_pointer`.
2. Attaches a 64x48 ARGB8888 wl_shm buffer whose 32x24 source crop is green and
   whose surround is red, then applies `wp_viewport.set_source((16,8,32,24))`
   (fixed-point crop) and `set_destination((128,96))` (integer scale) — a 4x
   scale whose destination is **larger** than the raw buffer, so hit-testing
   must honor `view.dst` rather than the raw size.
3. Verifies the composited readback is exactly the 128x96 destination rectangle
   centered on the viewport: bounding box `(136,102)–(263,197)`, color count
   `128*96`, zero red pixels (surround excluded by `set_source`), interior
   solid green (only a 1–2px GL linear-filter AA border at the crop edge
   differs).
4. Asserts the input mask covers a point inside the dst rect and not a
   background point (clipping uses `view.dst`).
5. Delivers a **complete press+release** at `(260,190)` — inside the scaled
   region whose raw-buffer x would exceed 64 — and asserts the client received
   it and records **surface-local coordinates** from `wl_pointer.Enter`
   (`surface_x: 124, surface_y: 88` = 260−136, 190−102), proving hit-testing
   reports dst-local coords. A second press+release far outside at
   `(20,150)` resets the `clicked` flag first and runs a synchronization
   window (dispatching + sleeping) before asserting no stray press arrived.

Runs headless with only `OMARCHY_TEST_GRAPHICS=1` (no systemd, no desktop
access); PPM readback dump via `OMARCHY_TEST_SURFACE_FRAMES=<dir>` as in the
other graphics tests.

`tests/support/desktop.rs` was extended minimally: `Frame::pixels()` and
`Frame::size()`, plus `Desktop::mask()` backed by a captured `Event::Mask`
during `step()`. A module-level `#![allow(dead_code)]` covers the fixture
methods unused by a given test crate (each consumer uses a different subset).

## Verification (run on this worktree)

All regressions use private-display fixtures (private `XDG_RUNTIME_DIR`,
`WAYLAND_DISPLAY=wayland` in that runtime). The supervised worker is spawned
via the user systemd session but connects only to the in-process private
compositor; the live desktop compositor is never touched.

- `tests/viewporter.rs` — passed, `OMARCHY_TEST_GRAPHICS=1` only, no systemd.
  Ran 5 consecutive times, all green, ~0.37s each.
- `tests/surfaces.rs` — passed, `OMARCHY_TEST_GRAPHICS=1
  OMARCHY_TEST_SYSTEMD=1` (spawns a Quickshell worker on the private display).
- `tests/qt.rs` — passed, additionally `OMARCHY_TEST_QT_BRIDGE=<built qml dir>`.
  The QML module (`Omarchy.Ward` with `PluginView`) must be built from
  this worktree's `qt/CMakeLists.txt` against the staticlib built with
  `--features graphics,qt-bridge` (a stale cache from other activation work did
  not register `PluginView`).
- `tests/activation.rs` — passed (2 tests), same opt-ins as `qt.rs`.
- `cargo fmt --check` — clean.
- `cargo clippy --all-features --all-targets -- -D warnings` — clean (the
  `-Wmaybe-uninitialized` C++ notices from generated cxxbridge code are build
  diagnostics, not Rust clippy lints, and don't fail the check).
- `cargo build` (no features) and `cargo test --features graphics` — green.

## Remaining limitations / next steps for the other agent

### Upgrade this handoff

This branch's earlier docs commit referenced a pre-rebase SHA and an outdated
verification claim; this revision supersedes it.

### True fractional scaling (unfinished)

`set_destination` takes **integer** dimensions, so fractional on-screen sizes
are not expressible there. The compositor position/resize path is integer, and
Smithay's `SurfaceView`/renderer here are centered on integer logical pixels.
Quickshell currently reaches viewport only via integer-scale / adapted-content
paths. True fractional scaling needs:

- A fractional-scale policy pass (whether surfaces advertise
  `wp-fractional-scale` and downscale at presentation, or the worker renders at
  fractional size some other way).
- Working out what the host-facing IPC (in `presentation.rs` `Region` u32
  pixel rects) should carry for fractional surfaces, and whether the shared
  viewport/IPC contract (controller → worker `Viewport{width,height,scale}`,
  and the returned `Mask`/`Region`) needs fractional extents.

### Multiple outputs (unfinished)

The compositor is a single private display; `Viewport` is one size/scale pair
and `xdg-output` is one logical output. Multi-output requires the shared
viewport/IPC contract to become a list of outputs so the worker can advertise
correct per-output geometry/scale to Qt. Not started — deliberately left for
the platform/IPC owner (the other agent) to spec before implementing, since it
changes `controller.rs` and `presentation.rs` together with `graphics.rs`.

### Deferred (unchanged, out of scope here)

- Fractional-scale wire protocol (`wp_fractional_scale`) not examined/addressed.
- Popup grabs, context-loss handling — already marked non-shipping.

## Integration requirements for the other agent

- No new renderer/abstraction framework; Smithay facilities only. Do **not**
  adopt PR #8956's approach.
- The viewporter global is registered unconditionally with the other globals in
  `graphics.rs` `Graphics::new`; no feature flag.
- The raw-client test needs the existing `[dev-dependencies]`:
  `wayland-client = "0.31.10"` and
  `wayland-protocols = { version = "0.32.13", features = ["client"] }`
  (locked in `Cargo.lock`). The fixture client (`run_client`, `noop!`, `fill`)
  is a useful building block if the shared harness grows.
- To run the Qt/activation regression, build the QML module from this
  worktree's `qt/CMakeLists.txt` (`cmake -DRUST_TARGET_DIR=<cargo target>
  -DRUST_PROFILE=debug`) after `cargo build --features graphics,qt-bridge`,
  and point `OMARCHY_TEST_QT_BRIDGE` at the generated directory.
- This worktree/branch is separate from the other agent's activation work in
  the original checkout; base the PR on `jacob-vincent-mink:quattro` (never
  upstream), not on this branch.
