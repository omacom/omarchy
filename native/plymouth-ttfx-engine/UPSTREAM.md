# Vendored TTFX engine

Downstream integration: Andrés Villagrán <andres@villagranquiroz.cl>. Upstream source retains its own LICENSE and NOTICE; this attribution does not replace third-party authorship.

## Immutable source

- Upstream repository: `https://github.com/omacom/ttfx`.
- Release: `v0.5.1`, commit `14ed2742596f0056b13e25d14a83ea851adc2294`.
- Immutable source archive: `https://codeload.github.com/omacom/ttfx/tar.gz/14ed2742596f0056b13e25d14a83ea851adc2294`.
- Archive SHA-256: `7e85db252242bcee8a95adbbd001c88d4b6ac737ea2441200c8a13bf7cf24d19`.

The import contains `Cargo.toml`, `Cargo.lock`, `LICENSE`, `NOTICE`, `README.md` and `src/`. Upstream documentation, CI, Nix, benchmark, oracle and integration-test assets are not packaged. 0.5.0 removed the assembly engine (and with it the `asm` feature and `build.rs`), so nothing architecture-specific is vendored; the earlier pin of the unmerged AArch64 assembly port (omacom/ttfx#40) is gone.

`vendor/ttfx-provenance.json` records the archive digest, upstream and downstream SHA-256 for every imported file, the local patch digest, the bridge lockfile digest, and the complete registry dependency closure. `tests/vendor-provenance.py` verifies it; with `--write --upstream-archive PATH` it regenerates the manifest after a re-import.

The bridge lockfile changes TTFX 0.3.2 → 0.5.1 and adds `unicode-width` 0.2.2, the version upstream's own lockfile pins. The other 28 registry packages and their vendored checksums are unchanged.

## Exact downstream delta

`vendor/ttfx-plymouth.patch` is the complete patch against the pinned upstream source, checkable with `git apply --check` in an extracted archive. It was carried forward from the 0.4.0 import by a three-way merge; only `src/engine/terminal.rs` needed a manual resolution, where upstream's new differential-output test and the embedded-dimensions test now sit side by side. It changes 40 source files:

- `src/engine/terminal.rs`: expose structured composited cells and skip terminal-size discovery when fixed embedded dimensions are supplied; retain a failing-probe regression test. Upstream's resize and differential redraw logic is intact.
- `src/engine/ctx.rs`: opt-in structured output without ANSI frame construction, opt-in final-text band mapping, and a structured-frame regression test.
- `src/utils/graphics.rs`: restore the five-band final-text mapper and its geometry regression, using upstream's contiguous coordinate-color map.
- All 37 effect implementations: route their final-text mapping through that opt-in helper, including matrix, rain, and synthgrid. Transient gradients and orbittingvolley's launcher gradient keep their original mappings. CLI defaults are unchanged.

The bridge owns first-frame creation, bounded top-to-bottom RGBA/style/glyph snapshots, virtual frame time, loader background propagation, retained terminal frames, explicit deterministic reset, panic containment, and the canonical decrypt gradient. The terminal logo's 19 nonempty rows remain the five exact colors `d0fdd9`, `a8fcba`, `82fb9c`, `539e65`, `2b5037` in bands `4,3,4,3,5`. `ttfx_engine_draw_logo` is the plugin's single playback entry point: loop mode restarts seamlessly at the tape boundary, one-time mode holds the final frame, and reverse mode plays the recorded playback backwards to the blank canvas. `ttfx_engine_record_history` (opt-in, bounded, decimating keyframe record that only reads exposed frames) and `ttfx_engine_begin_reverse` prepare that reverse outro; without them forward playback is byte-identical. The older C entry points are unchanged; `ttfx_engine_step`'s legacy `out_looped` name reports completion, not an implicit reset.

## Call path and architectures

The embedded call path is `Engine::create/step` → `EffectCommand::build_effect` → `Effect::next_frame` on upstream's original engine → structured terminal cells. Upstream 0.5's `fx` engine (flat primitives, with x86-64 and AArch64 NEON paths) is what the `ttfx` binary offers each run first (`fx::effects::build` → `fx::run::run_effect`); that runner owns tty output and completion and is not a resumable structured-cell API, so the bridge does not call it. The bridge is plain Rust on every architecture: x86-64 and AArch64 build the same code.

Switching to the `fx` engine would need create/step/snapshot/reset/free primitives with host-owned timing and no tty/output/signal side effects, the same final-text bands and retained completion, and parity tests against the original engine.

## Reproducible validation

Run from this directory:

```bash
cargo test --locked --offline
cargo test --locked --offline -p ttfx --lib
cargo clippy --locked --offline --all-targets -- -D warnings
python3 tests/vendor-provenance.py
bash tests/embedded-smoke.sh
bash tests/self-contained.sh
```

The embedded smoke test links the real optimized static library and uses strace to reject tty discovery, subprocesses, sleeping, signal setup, and ANSI output. The self-contained test copies only source, builds with an empty CARGO_HOME and target directory (`--locked --offline --profile plymouth`), and links and runs the C smoke against that library.

These are host-side checks, not boot acceptance.

## Quattro integration

The source integration is ported onto `omacom/omarchy` `quattro` commit `6194f4606c585da8b839b87df9120b7d796afedf`. The package default remains the stock script renderer until a trusted native module is activated transactionally; branding refreshes preserve valid installed native playback and fall back to script if the module is absent. The current upstream late-display fallback script is retained. See `docs/plymouth-ttfx.md` for provisioning, optional desktop handoff, and validation boundaries.
