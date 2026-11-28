# Omarchy.Ttfx

`TtfxLogo`, a Qt Quick item that plays the Omarchy wordmark with the TTFX engine in `native/plymouth-ttfx-engine`: the same engine, effects and logo as the native Plymouth renderer in #18522, here for the QML boot splash (`default/splash/ui/AnimatedLogo.qml`).

It draws on the CPU, one image the size of the logo, so it runs on Qt Quick's software backend, as the splash does in the initramfs with no Mesa. Only cells that changed since the last frame are redrawn, and the image is shown one pixel per device pixel.

## Timing

The engine advances at a fixed 240 ticks per second with two draws per tick (the Plymouth renderer's contract), measured from a monotonic clock, not counted in frames: a display at any refresh shows the latest state, and a late frame catches up, a quarter of a second at most. One engine advance runs per presented frame, and none once a one-time or reverse playback has ended, or while the item is hidden or has no size.

## Properties

- `effect`: a name from `effects.txt`, `decrypt` by default. An unknown one leaves `ready` false.
- `seed`: a decimal unsigned 64-bit number; empty for the Plymouth renderer's seed.
- `mode`: `TtfxLogo.Loop`, `TtfxLogo.OneTime` (holds the last frame) or `TtfxLogo.Reverse` (plays the recorded playback backwards to a blank canvas over `reverseDuration` ms).
- `stepsPerTick`: 2 by default; more speeds a playback up.
- `color`: cells the effect leaves uncoloured. Effects such as Decrypt colour their own cells.
- `background`: what the logo is drawn on. The engine blends towards it, and changing it starts the effect again.
- `running`, `ready`, `complete`, the `finished()` signal and `restart()`.

## Building

    cmake -S native/ttfx-qml -B /var/tmp/ttfx-qml-build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
    cmake --build /var/tmp/ttfx-qml-build
    DESTDIR="$pkgdir" cmake --install /var/tmp/ttfx-qml-build

Cargo builds the engine offline from its vendored crates (`--locked --offline --profile plymouth`), and the plugin links it statically, so the module is one shared object, `libttfxqml.so`, with its `qmldir`, installed at Qt's QML path (`/usr/lib/qt6/qml/Omarchy/Ttfx`). Needs Qt 6.5 or later, CMake and Rust.

A package that ships it should rebuild the boot images when it is installed, upgraded or removed (`omarchy-update-boot-splash`), since the splash's image copies the module.

## Testing

    bash native/ttfx-qml/tests/run.sh [screenshot.png]

Builds the module with its smoke test (`tests/smoke.cpp`, `tests/smoke.qml`) and runs it offscreen on the software backend: Decrypt must start, draw, reach its end and then ask for no more frames, an unknown effect must not start, and an item with a negative size must neither crash nor animate. The engine's own tests are in `native/plymouth-ttfx-engine` (`cargo test --locked --offline`).
