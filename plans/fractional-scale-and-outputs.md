# Fractional scaling and multiple outputs — proposed geometry contract

Historical worker-only proposal and checkpoint. The later per-output stream implementation supersedes the single-canvas host proposal below; see the [current architecture](../docs/ward-architecture.md#pixels-input-and-context) and [remaining release validation](ward-host-integration.md#order-decisions-and-completion). Installed-VM and physical-monitor acceptance remain unclaimed.

## Integration checkpoint

The worker commits through `1e998ea4` are integrated into `rust-plugin-sandbox`, retaining the host-activation-gated keyboard focus fixes. Independent review reproduced and then verified fixes for integer output resize, rescale buffer allocation, physical-budget checks through both scaling entry points, output bounds, xdg-output logical size, and same-scale layer reconfiguration. The combined tree passes the GPU/Qt activation, focus, surface, shared-runtime and isolation suites, plus fractional/output-wall tests and strict all-target Clippy. A separate actual Quickshell `Variants`/`PanelWindow` experiment passes two outputs, addition of a third with owner resizing, removal, and 1.5-to-2.0 rescaling; private-display captures were inspected.

This is a worker-only milestone behind `graphics`, not completed desktop multi-monitor support. The shared `Viewport` protocol and Qt/QML integration remain integer/single-canvas. The proposed contract below is not implemented or an authorization to enable the feature. Mixed output scales, final desktop placement/lifecycle policy, and live-desktop acceptance remain open. `tests/quickshell_wall.rs` is a synthetic protocol client with configure-driven repaint; its rescale density is supplied by the fixture, while the separate Quickshell experiment exercises the real client.

Branch: `rust-plugin-sandbox-viewporter` (separate worktree). This is a
**proposal** for the smallest host/worker geometry contract that admits two
features the worker currently blocks:

1. **Fractional scaling** — the host places a plugin window at a size that is a
   non-integer multiple of its logical canvas, and wants crisp (not bilinear-
   upscaled) text/vectors at that placement.
2. **Multiple outputs / output changes** — the private compositor advertises
   more than one logical output to the plugin (Quickshell) client, and the host
   can add, remove, or reassign (move / rescale) them at runtime (e.g. the
   plugin spans a hotplugged monitor).

It is written for **ownership coordination**: it fixes the contract that the
shared IPC (`controller.rs`, `session.rs`, `presentation.rs`) and the Qt/C++
bridge (`qt.rs`, `pluginview.cpp`, QML) must adopt, and separates what the
worker (`graphics.rs`) can land and verify first without touching those owned
surfaces. **Nothing in this document has been wired into shared IPC or Qt
yet.** The worker-side capabilities are landed behind the existing `graphics`
feature, verified with private-display fixtures, and the public single-output
`Graphics::new(path, Viewport)` entry point is preserved unchanged so the
product path does not regress during coordination.

## Current contract (baseline)

- `Viewport { width, height, scale }` — a single output. `scale` is an integer
  `1..=4`. `width,height` are **logical** canvas pixels; the exported
  framebuffer is `width*scale × height*scale` (integer scale only).
- Logical space is the **input space**: `graphics.input` validates `x,y`
  against `viewport.width/height`, `under_from_surface_tree` hit-tests in
  logical coordinates, and `Event::Mask` regions are in logical coordinates.
- The host owns placement and input: it maps item→logical via
  `point * viewport.size / item.size` and sends `Control::Input`. The worker
  composes one physical buffer and ships it as two ping-pong GBM DMABUFs; Qt
  imports and displays them. There is one `wl_output`/xdg-output at `(0,0)`.

## Proposed smallest contract

Keep the parts that already work and are proven:

- **Logical input/mask space stays unchanged** — one logical canvas of integer
  `width × height`; pointer/key/wheel and the returned mask are always logical
  canvas coordinates. This is the single biggest reason the change stays small:
  the host mapping `point * logical / item` and the mask math do not change.

Two additive extensions, order preserved.

### 1. Fractional scale (fixed-point, ×120)

Represent the scale as a fixed-point number matching the wire convention of `wp_fractional_scale` (unsigned integer units of 1/120, not `wl_fixed`). Keep a single `scale` u32 field but re-encode it:

- `scale` u32 becomes `scale × 120` (`scale_fixed`). Integer 1.0 → 120,
  1.5 → 180, 2 → 240, 4 → 480. Valid range `[120, 480]`.
- `width`,`height` remain integer **logical**. The **physical buffer** is
  `round(width·scale_fixed/120) × round(height·scale_fixed/120)`.
- The compositor advertises to the plugin client:
  - `wl_output.scale` = the integer floor of the scale (compat; ≥ 1) so legacy
    clients render at the integer part;
  - `wp_fractional_scale.preferred_scale` = `scale_fixed` so scale-aware
    clients (Quickshell when used) render at the precise fractional
    resolution.
- The render path passes the fractional scale into
  `render_elements_from_surface_tree`, so `SurfaceView.dst` stays the integer
  **logical** size while `src`/buffer are fractional — Smithay 0.7's
  `SurfaceView::from_states` already maps fractional `src → integer dst`.

Why the host math is untouched: input and mask are logical; only the exported
pixel density (buffer size) and the per-surface advertised scale change.

IPC wires: `Control::Configure` sends `scale_fixed` instead of integer scale;
`Event::Configured` returns it; `Viewport` keeps three u32 fields so the record
sizes stay identical and existing codec length/validation tests remain valid
(gated on the new range, `pixels()` becomes `round`).

### 2. Multiple outputs (monitor wall, uniform scale)

The worker stays a **single composite buffer** per frame — one logical canvas,
one exported DMABUF pair — but advertises `N` logical outputs that tile the
canvas. Each output is:

```
Output { id: u32, x: i32, y: i32, width: u32, height: u32, scale: u32 /* ×120 */ }
```

- Canvas logical size `Viewport{width,height,…}` is the host-owned spanning
  box; outputs are sub-rects at `(x,y)`. Scale is **uniform across outputs**
  (the monitor-wall / stretched-desktop model), which is exactly what the
  existing one-scale render path supports. Per-output differing scales are a
  second step (Model B) and need separate buffer streams — out of scope here.
- The worker owns one `wl_output`/xdg-output **per entry**, each with its
  geometry `(x,y,size)` and the shared scale. Surfaces **enter** every output
  whose logical rect they intersect and **leave** the rest (Smithay
  `Output::enter/leave`), preserving per-surface `enter/leave` and the
  compositor's scale/geometry events.
- **Output changes** (add, remove, reassign = relocate/rescale) are expressed
  as a new `Configure` carrying the updated output list. The worker:
  - creates/destroys output globals and re-sends geometry/scale for moved ones;
  - reconciles each surface's `enter/leave`;
  - re-emits `wp_fractional_scale.preferred_scale` (and buffer state) where the
    entered-output scale changed;
  - reallocates the composite buffer **only** if the spanning physical size
    changed (`round(canvas·scale)`); otherwise it re-renders in place.
- Input and mask stay logical canvas coordinates, unchanged and valid across
  every output mutation.

IPC wires: `Control::Configure` gains an output list; `Event::Configured`
echoes it back. To keep the record small and bounded, cap outputs (e.g. `≤ 8`)
and require outputs to be within the canvas and non-degenerate. The Qt host
still imports one buffer and maps item→canvas; it additionally forwards the
output list so it can choose which output a plugin span belongs to (its own
arrangement authority).

### Recommended sequencing and ownership

| # | Capability | Worker (`graphics.rs`) | Shared IPC / Qt (coordinate) |
|---|-----------|------------------------|------------------------------|
| 1 | Fractional scale | preferred_scale + fractional render + `round` buffer; land behind `graphics`, verify with fixture | re-encode `scale` as ×120 in `Viewport`, `Control::Configure`, `Event::Configured`; adapt `pixels()` |
| 2 | Multi-output (monitor wall) | N xdg-output, enter/leave, reassign/remove reconcile, uniform scale; land behind `graphics`, verify with fixture | add output list to `Configure`/`Configured`; Qt forwards list; cap at 8 |

Both land worker-side and are verified in the private-display fixtures before
any shared wire or Qt surface changes. The other agent coordinates the shared
IPC record bump and the Qt pluginview changes; the worker changes are
independent and reviewable as commits on this branch.

## Verification plan (private-display fixtures only)

- **Fractional scale**: raw Wayland client sets `wp_fractional_scale` on a
  surface and observes `preferred_scale` == the configured `×120` value;
  composite readback is `round(logical·scale)` and crisp (no bilinear
  upscale); a pointer click at a fractional-scaled point is hit-tested at the
  correct logical coordinate. Assert rendering and input together.
- **Multi-output**: raw client binds `wl_output`/xdg-output and observes
  `enter/leave` + geometry as outputs are added/removed/reassigned; the
  composite remains correct and a pointer event lands in the right logical
  region across each mutation. Assert rendering and input together.

Host-owned placement/input and the bounded-resource limits (surface count,
region count, region/stride validation, fixed output cap) are preserved.

## Out of scope / deferred

- Per-output **differing** scales (Model B: separate buffer streams per
  output) — needs the output-list contract first and Qt presenting N buffers.
- `wp_viewport` destination fractional sizes (destination is integer by
  protocol; crisp fractional scaling goes through `wp_fractional_scale`).
- Popup grabs, context-loss handling (unchanged, pre-existing).

## Implemented (worker-side) and test-observed

### Worker API landed behind `--features graphics`

Fractional and multi-output are both worker-only, added next to the unchanged
integer `configure(Viewport)`; the public single-output `Graphics::new` entry
point and the shared IPC are untouched.

- `configure_scaled(viewport, render_scale, time)` takes an `f64` scale in `[1.0, 4.0]`, such as `1.5`. The compositor advertises `wl_output.scale` as the integer floor and `wp_fractional_scale.preferred_scale` in units of 1/120. The physical buffer is `round(logical × render_scale)`; input/mask stay logical. `tests/fractional.rs` checks rendering, input and preferred scale 180 together.
- `configure_outputs(&[OutputSpec], time)` — `OutputSpec{ x, y, width, height,
  scale_fixed }`; 1..=8 entries, uniform scale, non-degenerate rects. It grows/
  shrinks `wl_output` globals via `create_global` / `remove_global::<App>`,
  syncs each output's integer mode (`round(spec.width × scale)`), location,
  and preferred scale, reconciles every live surface's `enter`/`leave` by
  logical-rect intersection, and reallocates the composite buffer only when the
  spanning physical size changes. Public accessors for fixture assertions:
  `output_count()`, `output_spec(index)`, `output_mode(index)`, `output_global(index)`.

### `tests/multi_output.rs` — a real Wayland client

A raw `wayland-client` (0.31) connects, binds **every** `wl_output` global by
registry name (multi-instance globals need per-name `WlRegistry::bind`;
`GlobalList::bind` binds only the first match), and records `wl_surface.enter/`
`leave` by `ObjectId`. It drives the compositor through three wall shapes and
asserts, in one scenario:

- **Wall A** (two 200×300 outputs, seam at x=200): the centered 100×100 surface
  is `enter`ed on both outputs; composite readback is crisp and correctly
  positioned (green 150×150 at physical (225,150)); a click at logical
  (200,150) is hit-tested at local (50,50).
- **Wall B** (reassign: output 1 moves to (360,0,40,300)): the surface is
  `leave`d on the moved output and stays on output 0.
- **Wall C** (shrink to one 400×300 output): `output_count() == 1` and the
  surface stays `enter`ed on the surviving output.

Timing invariant observed while wiring the test: the fixture consumer drains a
bounded number of frames per `step` and the worker only paints while `dirty`, so
the single informative composited frame must be captured in the same loop
iteration that produces it. The setup loop therefore steps once per iteration
and breaks when both outputs are bound, both `enter` events arrived, **and** a
non-black frame has been captured — never re-arming a second render loop after
the frame is gone.

The client thread is dropped without a `join` (as in `tests/fractional.rs`):
once `stop` is set the client stops round-tripping and process teardown reaps
it, avoiding a `join` while the client may be blocked inside `roundtrip()`.

## Post-integration review fixes (worker-side + tests)

Five reproducible failures found on review of `graphics.rs` (the `16403b1e`
commit) were fixed, and a real-client Quickshell-panel test was added. All fixes
keep the worker-side entry points off the shared integer `Viewport` IPC and
leave the `configure(Viewport)`/presentation contract untouched.

### Worker-side fixes in `src/graphics.rs`

1. **Integer resize updates the output mode.** `configure()` now updates the
   primary (full-canvas) output's `spec` (`x/y/width/height/scale_fixed`) from
   the new viewport, so `sync_outputs()` derives a fresh `wl_output` mode on the
   next render instead of reporting the stale 400×300.
2. **Output-scale change reallocates the presentation buffer.** `configure_outputs()`
   compares the spanning physical canvas (`round(viewport × scale)`) against the
   current buffer size and, when it differs, sets `requested = Some(viewport)` so
   the next `render` reallocs/re-describes a new generation, preserving frame
   ownership exactly as a normal resize does. Same-size reconfigurations (pure
   rect reassignment) skip the realloc. Exposed buffers (e.g. 400×300 → 600×450
   at 1.5×) now follow the scale.
3. **Fractional budget validated on real rounded physical dims.** `configure_scaled()`
   computes `round(width × render_scale) × round(height × render_scale)` and
   validates against the 8192 edge / 8,388,608-pixel budget `before` mutating any
   state, so a 2048×2048 canvas at 4.0 (an 8192×8192, 67M-pixel buffer) is
   rejected atomically rather than silently exceeding the budget.
4. **Output rects validated with overflow-safe arithmetic.** `configure_outputs()`
   rejects any rect with negative origin or whose `x + width`/`y + height`
   (computed in `i64`) exceeds the canvas, and rejects a wall whose physical
   size would exceed the pixel budget, all before mutating wall state.
5. **xdg-output reports logical, not physical, dimensions.** `sync_outputs()`
   now advertises `Scale::Custom { advertised_integer: surface_scale(), fractional:
   render_scale }` instead of `Scale::Integer`, so the wire `wl_output.scale`
   stays integer (ceil/floor as before) while Smithay derives the correct
   `xdg-output.logical_size` (physical / fractional, e.g. 400×300 at 1.5×).

Also fixed while covering the Quickshell panel:

- **`new_layer_surface` no longer discards the requested output.** The handler
  resolves the `Option<WlOutput>` via `Output::from_resource` to a wall index and
  stores it in a `LayerOutput` surface data-map entry, so each layer is pinned to
  the wall output it was created against.
- **Layer geometry is constrained to that output's rect.** `layer_rect()` now
  runs `layer_geometry()` over the layer's output `Rectangle` (falling back to
  the full canvas only for a legacy client), so a bar on output 1 is bottom-
  anchored inside output 1's logical rect rather than centred in / stretched
  over the whole canvas. `layer_geometry` was generalized from a `Viewport` to a
  `Rectangle<i32, Logical>` (its unit test updated for that plus a wall-offset
  case).
- **`surface_logical_rect` follows real placement.** It now locates the surface
  (or its nearest root ancestor) in `roots()` and derives its rect from that
  root's on-canvas position rather than always centering it, so `enter`/`leave`
  reconciliation reflects actual geometry. Decoration of my review copy:
  `configure_scaled`, `OutputSpec`, and the tests document the wire scale as
  units of 1/120 and `configure_scaled` as accepting an f64 scale in `[1.0, 4.0]`
  (not 120-based integers).

### `tests/quickshell_wall.rs` — a Quickshell-style panel on the second output

A layer-shell client plays the role of a Quickshell bar: it is created on the
**second** output of a two-output 400×300 canvas at 1.5× (physical 600×450),
renders a 300×60 buffer but describes a 200×40 logical layout via `wp_viewport`
exactly like a HiDPI client, and is bottom-anchored to output 1
(logical [200,400)×[260,300) → physical [300,600)×[390,450)). One scenario
verifies together:

- the panel occupies exactly output 1's bottom region — rows above it in output
  1 and all of output 0 stay black, proving the layer is constrained to its
  requested output (not centred/stretched over the whole canvas);
- fractional sharpness via a **pixel-detail pattern**: four pure RGB vertical
  bands each 50 logical px (75 physical px) wide read back with band boundaries
  exactly at `round(band × 1.5)` and every panel pixel a pure band colour (no
  bilinear bleed);
- adding a third output advertises a third distinct global and re-modes output
  1 to its new physical size; shrinking back to two retires the extra global;
- rescaling the wall to 2.0 updates each output's advertised mode to the rounded
  physical size of its unchanged logical rect (400×600).

The revised client records and acknowledges layer configures, repaints resized buffers, checks post-change pixels and stale-region clearing, and verifies logical pointer coordinates after narrowing its output. The shared readback fixture accepts new physical buffer dimensions after rescaling. Teardown sets `stop`, dispatches while polling `is_finished()`, and requires termination within five seconds before joining; a stuck client fails rather than silently passing.

The review harness lives in a scratch crate that symlinks the ward; the
five failing cases plus this panel test are exercised with
`cargo test --features graphics` (gated on `OMARCHY_TEST_GRAPHICS=1`) and via
`cargo clippy --features graphics --all-targets -- -D warnings`, both clean.
