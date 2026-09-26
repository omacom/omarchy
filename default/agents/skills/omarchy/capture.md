# Capture and Sharing

Read this before taking screenshots or screen recordings, extracting text from
the screen, or sharing files with other machines.

## Screenshots

```bash
omarchy screenshot                            # Interactive smart-region flow
omarchy capture screenshot region             # Select a region
omarchy capture screenshot windows            # Pick a window
omarchy capture screenshot fullscreen save    # Full screen, straight to disk (no editor)
omarchy capture screenshot scroll             # Capture and stitch a scrolling region
omarchy screenshot --editor=overlay           # Opt into annotation before output
```

The first argument picks the Omasnap mode (`smart|region|windows|fullscreen|scroll`). By default, a capture saves to disk, copies to the clipboard, and shows a preview for 10 seconds. Use the preview's Edit action to annotate, or pass `--editor=overlay` or `--editor=window` to edit before output. A second argument of `copy` or `save` skips the preview and sends the screenshot straight to that destination. Saved screenshots land in `~/Pictures/Screenshots` by default (override with `OMASNAP_SCREENSHOT_DIR`; the legacy `OMARCHY_SCREENSHOT_DIR` is also honored by the Omarchy command). Set `[output] autosave = false` in `~/.config/omasnap/omasnap.conf` to disable automatic saving.

## Screen Recording

```bash
omarchy screenrecord --fullscreen             # Start recording the full screen
# ...exercise whatever you want on film...
omarchy screenrecord --stop-recording         # Stop; prints the saved path
```

Optional flags: `--with-desktop-audio`, `--with-microphone-audio`,
`--with-webcam` (plus `--webcam-device=` and `--webcam-size=`), and
`--resolution=<size>`. Without `--fullscreen` a region picker opens first.
Recordings land in the configured Videos directory (override with
`OMARCHY_SCREENRECORD_DIR`). Resize a live webcam overlay with
`omarchy capture webcam resize <smaller|larger|reset|small|medium|large>`.

If recording fails to start, rerun with `OMARCHY_SCREENRECORD_DEBUG=true` to
collect a log at `$XDG_RUNTIME_DIR/omarchy-screenrecord.log` (or `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/omarchy-screenrecord.log` without a session runtime directory) worth attaching to a bug
report.

## Text Capture (OCR)

```bash
omarchy capture text    # Select a region; extracted text goes to the clipboard
```

## Sharing Files

```bash
omarchy share clipboard               # Share the clipboard via LocalSend
omarchy share file <path...>          # Share files with nearby devices
omarchy share folder <path>           # Share a folder

omarchy tailscale send <machine> <file...>    # Taildrop to a tailnet machine
omarchy tailscale receive [directory]         # Save incoming Taildrop files
```

Shrink large captures before sharing them:

```bash
omarchy transcode <input> [format] [resolution]   # Re-encode pictures/videos for sharing
```
