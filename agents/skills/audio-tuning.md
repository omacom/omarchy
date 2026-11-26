# Speaker Tunings

Read this before authoring or modifying laptop speaker tunings under `default/audio/tunings/`. Architecture details live in [`docs/audio-tuning.md`](../../docs/audio-tuning.md).

## Author in Omarchy's Native Format

Always build and test tunings directly through `omarchy-audio-tuning` rather than dropping a standalone config into `~/.config/pipewire/filter-chain.conf.d/` or registering a WirePlumber smart filter.

- Standalone `filter-chain.conf.d/` fragments and WirePlumber smart filters appear as a second output in Quickshell's audio panel alongside the raw hardware sink, and bypass `omarchy-audio-sink-availability` and `omarchy-audio-output-sink`.
- Each laptop tuning lives in `default/audio/tunings/<vendor>-<model>/` with two files: `tuning.conf` (metadata, hardware match, provenance, and electrical metrics) and `filter-chain.conf` (the PipeWire graph with `@SPEAKER_SINK@` as its target placeholder).
- Install `lsp-plugins-lv2` and `omarchy-audio-tuner` with `omarchy-pkg-add lsp-plugins-lv2 omarchy-audio-tuner` before testing or verifying.
- Apply and iterate locally with `omarchy-audio-tuning on --force`, then verify `omarchy-audio-tuning status` and confirm `omarchy-audio-sink-availability` reports the physical speaker sink as `0` (hidden) and `omarchy_speaker_tuning` as `1`.

## Required Graph Contract

- Wire left and right biquad chains explicitly rather than letting PipeWire duplicate a mono graph; the final limiter is stereo and must track both channels together so bass transients do not shift the stereo image.
- End every graph in `lsp-plugins-lv2` (`http://lsp-plug.in/plugins/lv2/limiter_stereo`) with `"alr" = 0` and `"boost" = 0` (both default to enabled and cause level-dependent tonal drift), `"th" = 0.891` (`-1.0 dBFS`), and `"g_in"` tuned for clean headroom.
- Keep the exact node names and pinning properties: `capture.props` must set `node.name = "omarchy_speaker_tuning"` and `media.class = Audio/Sink` (`node.description = "Laptop Speakers"`), and `playback.props` must set `node.name = "omarchy_speaker_tuning_output"`, `node.passive = true`, `target.object = "@SPEAKER_SINK@"`, `node.dont-move = true`, `node.dont-fallback = true`, and `node.linger = true`.
- Gate narrowly in `tuning.conf`: prefer `match_sku` (exact DMI `product_sku`, case-insensitive) over `match_dmi`, and use `match_command` when firmware or package preconditions also apply. Leave dots unescaped in `sink_pattern` because it is passed to `awk` as a string.

## Measuring with a Microphone

When designing a tuning acoustically (no Windows reference curve to copy):

- **Neutralize USB microphone onboard DSP first.** Microphones like the Shure MV7+ (`14ed:1019`) ship with onboard DSP (Auto Level, Denoiser, Popper Stopper, HPF, Compressor, Limiter, Reverb, Tone) and hardware mute that are invisible to ALSA and PipeWire and will silently corrupt measurements. Grant `hidraw` access with a udev rule (`SUBSYSTEM=="hidraw", ATTRS{idVendor}=="14ed", ATTRS{idProduct}=="1019", MODE="0660", TAG+="uaccess"`), back up the user's current state, and switch to Manual mode with all DSP disabled and `Tone = 0` before sweeping.
- **Self-check deconvolution and capture THD alongside frequency response.** Farina exponential sine sweeps (ESS) with impulse windowing capture room-rejected frequency response and 2nd/3rd harmonic THD in one pass; always assert that the inverse filter deconvolves the raw digital sweep flat (`0.00 ± 0.05 dB`) before trusting acoustic data. Measure Left, Right, and Stereo separately and power-average L+R so slight mic offset does not create stereo comb-filtering artifacts.
- **Protect the mechanical excursion knee.** Use the bass THD curve (from ESS or `omarchy-audio-tuner mic-sweep`) to locate where distortion takes off and place a 4th-order high-pass filter right above it rather than boosting frequencies the drivers cannot reproduce cleanly.
- **Account for uncalibrated dynamic vocal mic coloration.** A cardioid vocal mic like the MV7+ has a mild upper-mid presence lift (~3–5 kHz) and tapers above ~10–12 kHz; never blindly chase top-octave mic roll-off with extreme treble boost. Cut sharp cabinet/grille resonances narrow, keep positive boosts wide (`Q <= 2.2`) so the tuning holds across head movement, and re-measure acoustically after applying the EQ to confirm both target tracking and clean bass THD.
- **Pass `--from` explicitly on classic HDA laptops.** `omarchy-audio-tuner capture`'s default monitor auto-detection regex only matches SoundWire/UCM sinks (`sof_sdw`/`HiFi`), so on HDA sinks like `alsa_output.pci-0000_00_1f.3.analog-stereo` pass `--from <sink>.monitor`.

## Silent Electrical Verification

Every `tuning.conf` must record four measured electrical metrics before review: `magnitude_rms_db`, `bass_group_delay_swing_ms`, `limiter_headroom_db`, and `dynamic_range_delta_lu`.

- Measure silently and independently of speaker volume by loading a 48 kHz `module-null-sink` and running a temporary copy of `default/audio/filter-chain-host.conf` + your `filter-chain.conf` with `@SPEAKER_SINK@` replaced by the null sink name.
- Run `omarchy-audio-tuner capture --from <null-sink>.monitor` on both the null sink and the temporary tuning sink, then `analyse` and `delta` to measure the live graph's electrical transfer function. Verify as a sanity check that the graph matches its own analytical RBJ biquad design (~0.00 dB RMS), and report `magnitude_rms_db` against the intended reference or target curve (for a reference-fitted tuning, the deviation from that reference; for a ground-up voicing, document the target/design comparison clearly in `tuning.conf`).
- Compute `bass_group_delay_swing_ms` (max minus min group delay across 30–300 Hz) from the biquad coefficients.
- Feed a synthetic hot master (pink noise soft-clipped to `-0.1 dBFS` peaks) through the temporary tuning sink into the null sink and measure `limiter_headroom_db` (worst-case peak vs `-1.0 dBFS` threshold) and `dynamic_range_delta_lu` (LRA delta) with `ffmpeg -af volumedetect,ebur128`.

## Shipping and Tests

- Add a SKU-gated migration with `omarchy-dev-add-migration --no-edit` following [`agents/skills/migrations.md`](migrations.md): exit `0` when the hardware does not match, exit `75` if `$OMARCHY_PATH/default/audio/tunings/<slug>/tuning.conf` is not installed yet, run `omarchy-pkg-add lsp-plugins-lv2`, check `pactl info >/dev/null 2>&1` and exit `75` if no audio session is running (so TTY/SSH updates defer cleanly to the next graphical login), skip with exit `0` if EasyEffects is active (preserving the user's existing DSP setup instead of blocking updates), and apply `omarchy-audio-tuning on`.
- Run the focused audio and migration tests before opening a PR: `test/shell.d/audio-test.sh`, `test/shell.d/audio-output-sink-test.sh`, `test/shell.d/audio-pactl-test.sh`, `test/shell.d/migrate-notify-test.sh`, and `test/shell.d/migrate-scope-test.sh`.
