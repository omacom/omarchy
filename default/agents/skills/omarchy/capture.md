# Capture and Sharing

Use this guide for screenshots, screen recordings, OCR, transcoding, LocalSend,
and Taildrop. Captures can contain private information: inspect the selected
region or resulting file and obtain confirmation before transmitting it.

## Screenshots

```bash
omarchy screenshot                            # Interactive smart-region flow
omarchy capture screenshot region             # Select a region
omarchy capture screenshot windows            # Pick a window
omarchy capture screenshot fullscreen save    # Save the full screen without the preview
omarchy capture screenshot scroll             # Capture and stitch a scrolling region
omarchy screenshot --editor=overlay           # Annotate before output
```

The first screenshot argument selects the Omasnap mode: `smart`, `region`,
`windows`, `fullscreen`, or `scroll`. By default a capture saves to disk,
copies to the clipboard, and shows a preview for 10 seconds whose Edit action
annotates it; `--editor=overlay` or `--editor=window` edits before output. A
second argument of `copy` or `save` skips the preview and sends the screenshot
straight to that destination. Files land in `~/Pictures/Screenshots` by
default; `OMASNAP_SCREENSHOT_DIR` overrides it, and the Omarchy command also
honors the legacy `OMARCHY_SCREENSHOT_DIR`. Set `[output] autosave = false` in
`~/.config/omasnap/omasnap.conf` to disable automatic saving.

A screenshot is complete when the output exists or is present on the clipboard,
the intended content is visible, and unrelated sensitive content is excluded.

## Screen Recording

```bash
omarchy screenrecord --fullscreen
# Exercise the behavior to capture.
omarchy screenrecord --stop-recording
```

Without `--fullscreen`, recording starts with a region picker. Optional flags
include `--with-desktop-audio`, `--with-microphone-audio`, `--with-webcam`,
`--webcam-device=`, `--webcam-size=`, and `--resolution=`. Recordings land in
the configured Videos directory; `OMARCHY_SCREENRECORD_DIR` overrides it.

Resize a live webcam overlay with:

```bash
omarchy capture webcam resize <smaller|larger|reset|small|medium|large>
```

A recording is complete when recording has stopped, the printed output file
exists, and playback contains the requested interval with the intended audio
and webcam tracks.

If startup fails, rerun with `OMARCHY_SCREENRECORD_DEBUG=true`; diagnostics are
written to `$XDG_RUNTIME_DIR/omarchy-screenrecord.log`, or
`${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/omarchy-screenrecord.log`
without a session runtime directory.

## Text Capture

```bash
omarchy capture text
```

OCR is complete when the intended region's text is on the clipboard and a
sample confirms the extraction is usable.

## Sharing Files

```bash
omarchy share clipboard
omarchy share file <path...>
omarchy share folder <path>

omarchy tailscale send <machine> <file...>
omarchy tailscale receive [directory]
```

Reduce large captures before sharing when appropriate:

```bash
omarchy transcode <input> [format] [resolution]
```

Sharing is complete when the user has approved the exact content and recipient,
the transfer command succeeds, and receipt is confirmed on the destination. If
the destination cannot be inspected, report receipt as unverified.
