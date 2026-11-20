# Plan: Shared output — play one mix on every connected output

## Problem

Omarchy exposes a single default output. A laptop with two pairs of Bluetooth headphones connected can only play through one of them, so two people watching a movie together cannot each wear their own. The audio panel lists every output, but picking one replaces the other.

PipeWire can play the same mix to several sinks at once. The missing piece is a supported way to build and tear down that route, and a click in the audio panel to turn it on.

## Chosen design

A virtual `module-combine-sink` named `omarchy_combined_output`, owned by one new command, exposed as a switch in the audio panel.

- `omarchy-audio-output-combine on|off|toggle|status` creates or removes the sink and selects it as the default.
- The panel shows **Play on all outputs** after the device list whenever two or more real outputs are connected, or whenever sharing is already on. The row has a switch and is a keyboard target like the device rows.
- The command includes every available, physical output: `alsa_output.*` and `bluez_output.*` sinks with at least one available port. Other virtual sinks (EasyEffects, the combined sink itself) are deliberately excluded, since a mix sent into one would route back into the processing graph. Where a speaker tuning is up, its sink stands in for the hardware it fronts, so sharing keeps the tuning.

## Why not other approaches

- **PulseAudio's `module-combine-sink` through `pactl`** is the one that ships with PipeWire's PulseAudio layer today. It is already installed, needs no configuration drop-in, and can be created and destroyed at runtime. The native `libpipewire-module-combine-stream` would need a config file and a PipeWire restart, which drops every application's audio and reconnects Bluetooth devices. Not acceptable for a toggle.
- **`qpwgraph` / `helvum` links** play one application on two outputs, but they are per-stream, do not survive the application reopening, and need another GUI package.
- **Bluetooth multipoint** is a property of the earbuds (two *sources* into one headset), not of the computer, and cannot make two headsets carry the same source.
- **Per-sink volume duplication** in the panel was rejected: the combined sink is its own output with one volume, which is the behavior a person expects from a single "master" slider.

## Architecture

```
application (player, browser, call)
        │
        ▼
omarchy_combined_output  (virtual Audio/Sink, default)
        │  one internal stream per slave
        ├──────────────► bluez_output.<mac>.1  (headset A)
        └──────────────► alsa_output.<card>    (speakers / headset B)
```

- **Creation** (`on`): list available physical sinks, require at least two, remember the current default in `$XDG_RUNTIME_DIR/omarchy-audio-output-combine.previous`, load `module-combine-sink` with `sink_name` and `slaves`, carry the volume and mute of the physical sink the previous output really uses (a speaker tuning is resolved through `omarchy-audio-output-sink`, as the volume keys do), then select it through `omarchy-audio-output-set-default` so playing streams move onto the mix.
- **Removal** (`off`): unload the module by its PulseAudio module id. If the default output was the combined sink, restore the remembered output (or the first remaining physical sink). A default the user changed in the meantime is left alone.
- **State** is the module itself. Presence of the module is "on"; no daemon, no polling, no persistent config. The state file only carries the output to restore.
- **Panel state** comes from PipeWire: the combined sink appears in `Pipewire.nodes`, and the row reads that. No extra process is started while the panel is closed.
- **Device loss**: unloading a slave's module leaves the combined sink alive with the remaining slaves, so unplugging one headset does not silence the other. A device that reconnects later does not rejoin until sharing is toggled off and on; the panel row stays available while sharing is on so it can be turned off.

## Behavior and edge cases

- Fewer than two available outputs: `on` prints a diagnostic and exits non-zero without creating anything. The panel hides the row in that state.
- Already on: `on` is a no-op; `toggle` removes.
- The combiner is excluded from the device rows, so it never appears twice (once as a switch, once as a sink).
- Volume keys and the panel slider act on the combined sink as a master for both devices; each headset's own buttons still control its own level. The mix starts at the volume and mute of the output it replaced, so turning sharing on does not jump to full volume.
- A microphone call moves a headset to the headset profile, which removes its A2DP sink from the mix. Watching a movie never does this; after a call, toggle sharing off and on to rebuild the mix.
- Bluetooth bandwidth is shared by one adapter. Two headsets is the supported case; a third may stutter. Both devices play the same samples from one clock, so there is no drift between them, though each headset adds its own codec latency.

## UX

- Audio panel, under the output list: a row with the speaker glyph, **Play on all outputs**, and a switch. Click the row, press Return on it, or click the switch.
- A toggle that fails says why: the panel keeps the switch on what PipeWire reports and sends a notification with the command's diagnostic.
- The row only exists when it can do something, so the panel stays unchanged on a laptop with one output.
- The combined sink shows up in other applications' output pickers as `omarchy_combined_output`.

## Testing

- `test/shell.d/audio-pactl-test.sh`: the existing `pactl` stub gains module, default-sink, volume and mute state, and answers `get-sink-mute` in a translated form unless the caller asks for the C locale. Cases cover filtering (virtual and unavailable sinks left out, the tuning sink standing in for fronted speakers), creation with the right slave list, idempotent `on`, `status`, removal and restore, the one-output refusal, mute inheritance in a translated session, and copying the speaker level rather than the tuning's when a tuning is selected.
- `test/shell.d/audio-test.sh`: the panel model helpers (`isCombineSink`, `hasCombineSink`, `isShareableSink`, `shareableSinks`) are asserted against plain node shapes.
- `test/shell.d/i18n-test.sh` runs unchanged: one new English shell key, no untranslated literal in QML.
- Visual: open the audio panel with two outputs and check the row, cursor, and switch; capture before/after with `omarchy capture screenshot`.

## Rollout

The feature is inert until two outputs exist. It adds one command, one panel row, one catalog string and one manual sentence, and touches no existing routing. If PipeWire's combine module is unavailable the command fails with a diagnostic instead of changing the default.
