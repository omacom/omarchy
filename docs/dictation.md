# Dictation

`omarchy voxtype install` installs Voxtype and seeds new configurations with English transcription, clipboard paste, and the shell's Atreyu-style visuals. Existing configurations keep their model, language, output, and OSD preferences. The local Whisper `base.en` model remains available as a fallback.

On a Vulkan-capable machine, the installer also attempts to install `voxtype-cohere-vulkan` and download the Cohere Transcribe 03-2026 Q4_K_M GGUF (1.56 GB). The download is verified against its SHA256 before use. A time-limited spoken transcription probe must recover the expected words using a hardware Vulkan device before Cohere is selected. CPU-only machines, software Vulkan renderers, missing packages, failed downloads, insufficient GPU memory, and unsuccessful probes retain Whisper. This is a setup/startup check, not a guarantee against later driver failures.

## Local Cohere helper

The helper is packaged from `omacom/omarchy-pkgs/pkgbuilds/voxtype-cohere-vulkan`. It uses `transcribe-cpp` in a separate process to avoid conflicting with Whisper's ggml library. Voxtype 1.0.1's existing OpenAI-compatible client talks to `127.0.0.1:8178`; despite the Voxtype transport name `remote`, inference and audio remain on the machine. No Voxtype fork or cloud account is needed.

`omarchy voxtype cohere enable` downloads, verifies, probes, and starts the helper, then adds a managed systemd drop-in. `omarchy voxtype cohere disable` removes that drop-in and restores the engine configured in `~/.config/voxtype/config.toml`. Both commands reject changes while dictation is active. Enabling requires the helper package to be installed first. User-written systemd overrides can supersede the managed drop-in.

The managed daemon launcher uses Cohere only after the service reports ready on Vulkan. If startup fails, it starts Voxtype with the configured fallback. The cloud API key environment variable is removed when using the local endpoint. The helper logs device and timing metadata, not speech or transcript contents.

Cohere inputs longer than 35 seconds are split near quiet intervals into bounded segments, using every sample once. This addresses omitted middle passages seen in long single-pass recordings. Boundaries can still affect individual words and punctuation. The helper accepts up to 120 seconds of mono 16 kHz PCM16 WAV, although Omarchy's default recording limit remains 60 seconds.

## Shell visuals

The first-party `omarchy.voxtype` service watches `$XDG_RUNTIME_DIR/voxtype/state` and consumes measured peaks from `voxtype-audio-bridge` while recording. It uses Atreyu's **Mirrored spectrum** for recording and its **Bumper** for transcription, with the focused monitor's bottom-edge glow. Theme accent marks recording; theme orange marks transcription. Captions say “Listening…” and “Transcribing…”. The surface takes no input, has no keyboard focus, and unmaps after fading to idle.

`~/.config/voxtype/omarchy-osd` opts into the shell visuals. New installs create this marker and disable Voxtype's separate OSD process. Existing installs can opt in by setting `[osd] enabled = false` in their Voxtype config, creating the marker, and restarting `voxtype.service`. Remove the marker to hide the shell visuals. The `osd_suppressed` marker from `voxtype record start --no-osd` is respected, so tools such as Atreyu can own their recording UI.

Presentation components are adapted from Atreyu commit `d9a426fffdf4f1b9ab2f6980d2e8ab79111ccf40`. Its MIT license is preserved in `shell/plugins/voxtype/LICENSE.atreyu`. No Atreyu agent, broker, or speech provider is installed by this integration.
