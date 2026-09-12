# Reactive backgrounds

Catppuccin Latte includes an optional **Circuit City** background (`05-circuit-city.png`). Claude Code activity lights the rosewater tower and circuit; Codex activity lights the lavender tower and circuit. The central hub combines both channels. More concurrent sessions and recent progress increase brightness. Lights fade over 1.8 seconds and go out at idle. Quattro Futures remains Latte's first/default background.

Select Circuit City in the normal background picker. Other backgrounds remain static. The lock screen and background-picker thumbnails show the unlit image.

## Activity signal

This visualizes **recent local agent-turn activity**, including tool work, rather than billing totals or an exact count of in-flight network requests. It reads Claude Code transcripts under `~/.claude/projects` and Codex rollouts under `~/.codex/sessions`. Clients that do not write these logs are not covered. It makes no API calls, reads no credentials, and emits only provider names, active-session counts, and bounded brightness values; transcript contents and filenames never leave the collector.

Existing files are tailed once per second; new sessions are discovered every five seconds. Completion and cancellation markers clear activity on the next sample. Sessions with no recognized progress for 120 seconds expire conservatively, including crashed sessions. A silent request longer than that can appear idle until another event arrives. If the collector stops reporting, the renderer clears its signal after four seconds. Older or changed transcript formats may appear idle or take the expiry period to settle.

At most 64 recently modified session files are tracked, with at most 1 MiB read per file per sample. Only one collector runs across all monitors, only for a valid reactive background with a visible output. It stops when the wallpaper changes, every output is fullscreen, the session is locked/screensaving, or battery power saver is active. Individual fullscreen outputs suppress their effects. Fixed GPU paths animate opacity only; there is no continuous idle animation, full-screen blur buffer, or video decoder.

## Light-map format

Put a data-only JSON file next to an image, named `<image filename>.reactive.json`. Coordinates use the original image's pixel dimensions; the renderer applies the same centered aspect-crop transform as the image. No theme-supplied QML or scripts are executed.

```json
{
  "version": 1,
  "width": 1672,
  "height": 940,
  "lights": [
    {
      "channel": "codex",
      "color": "#7287fd",
      "width": 2,
      "path": "M 100 100 L 100 400"
    }
  ]
}
```

Channels are `claude`, `codex`, and `combined`. Colors are six-digit hex values. Widths are 0.5–12 source pixels. The parser accepts at most 32 paths, 2,048 characters per path, image dimensions up to 8,192, and a 64 KiB JSON document. Missing or invalid sidecars leave the image static. Paths use [Qt's SVG path support](https://doc.qt.io/qt-6/qml-qtquick-pathsvg.html), rendered with [Qt Quick Shapes](https://doc.qt.io/qt-6/qml-qtquick-shapes-shape.html).

## Reproducible preview

With Circuit City selected, run:

```bash
omarchy shell background-activity preview
```

This runs a 25-second idle → Claude → both → high activity → idle cycle, visibly labeled **SIMULATED ACTIVITY**. It neither changes usage records nor sends agent requests. Live monitoring resumes afterward. To end it early:

```bash
omarchy shell background-activity stopPreview
```

## Artwork

`themes/catppuccin-latte/backgrounds/05-circuit-city.png` was generated with the built-in image-generation tool at 1672 × 940 pixels. Its architectural light channels are illuminated by the adjacent JSON light map. The base image is preserved as generated. Final generation prompt:

> Use case: stylized-concept. Asset type: 16:9 premium desktop wallpaper for Catppuccin Latte, an AI-reactive city background's quiet idle state. Create a spectacular refined futuristic architectural miniature city / Formula 1 circuit control-grid, Westworld opening-title precision, viewed obliquely from above, no labels or UI. Composition: a broad smooth elliptical elevated racetrack encircles a small island city in the lower two thirds, one elegant tall tower on the left and one on the right, with thin recessed vertical light channels, a circular energy hub centered within the track, warm ivory ceramic buildings, subtle gardens, tiny trees, pastel lilac glass. Graphite blue-grey terrain and misty warm grey sky, daytime with deep soft shadows, muted, warm and welcoming, not nighttime. Palette tightly matched to Catppuccin Latte: chalk #eff1f5, pale rosewater #dc8a78, muted lavender #7287fd, mist #ccd0da, slate #4c4f69, soft sage accents. Sophisticated realistic 3D architectural render, intricate materials, immense depth, restrained futuristic elegance. Important: all artificial lights are OFF, recessed track-edge strips and tower channels are clearly visible but unlit, no glowing bloom anywhere: software will animate illumination over the architecture. Make the track and a few clean tower light strips easy to trace as smooth paths. High-end editorial composition with air around architecture, no people, no text, no logos, no neon rainbow or cyberpunk clutter. Wide landscape 3840x2160 if possible.
