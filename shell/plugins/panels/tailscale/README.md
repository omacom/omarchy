# Tailscale Omarchy Widget

Native Omarchy bar widget for Tailscale.

## Features

- Shows Tailscale connection state in the bar
- Left click opens a keyboard-friendly panel
- Right click toggles Tailscale on/off
- Switch between available Tailscale connections when multiple are available
- Browse machines from `tailscale status --json`
- Copy a machine's Tailscale IP, host name, or DNS name
- Send files to a machine with Taildrop, when the tailnet allows file sharing
- Open the tailnet's HTTPS services and see which of them are answering

## Services

A tailnet can advertise services — `svc:docs`, `svc:wiki` — that resolve inside
it. When this node is granted any that serve HTTPS, the panel grows a second
tab listing them: the URL, the machine currently answering for it, and the
result of a reachability probe (`shed · HTTP 200 · 14 ms`). Clicking a row
opens it in the browser.

Nothing here is configurable, because there is nothing to decide: the tab
exists only while the tailnet advertises services, so a tailnet without them
shows the panel exactly as it always was and never runs a probe. The services
are read out of `tailscale status --json` — the same poll the machine list
already uses, no second daemon call — and probed with one `curl` that checks
them in parallel. Probing follows the panel: with it open, the probe rides
each status refresh; with it closed, at most every five minutes, which is all
the bar icon's dot needs.

## Keyboard shortcuts

Inside the panel:

- `j` / `k` or arrows: move cursor
- `h` / `l` or left/right: switch between machines and services
- `enter` / `space`: activate current row
- `c`: copy selected peer IP, or the selected service URL
- `n`: copy selected peer name
- `d`: copy selected peer DNS name
- `s`: send files to selected peer
- `t`: toggle Tailscale
- `r`: refresh status
- `esc`: close

## Requirements

- `tailscale` CLI on `PATH`
- `wl-copy` for clipboard copy actions
- Taildrop enabled for the tailnet, to send files
- `curl`, to probe services — only used when the tailnet advertises them

## Receiving files

Incoming Taildrop files are saved to `~/Downloads` by the
`omarchy-tailscale-receive` service, which announces each one with a
notification (an image preview when the file is an image, and a click to open
it). The Tailscale service install enables it; `omarchy tailscale receive`
runs the same loop by hand.

## Icon

Renders the Tailscale mark natively as a theme-colored 3×3 dot grid, matching the official SVG silhouette while avoiding tiny-SVG rendering quirks in the bar.

A dot appears in the icon's corner only when a service the tailnet advertises
is not answering, so an unmarked icon means there is nothing to look at. The
login badge wins the corner when both apply.

## Add to the bar

This widget ships as first-party plugin `omarchy.tailscale`. Add it with `omarchy plugin enable omarchy.tailscale`, then place it with `omarchy bar move omarchy.tailscale` if desired.
