# Tailscale Omarchy Widget

Native Omarchy bar widget for Tailscale.

## Features

- Shows Tailscale connection state in the bar
- Left click opens a keyboard-friendly panel
- Right click toggles Tailscale on/off
- Switch between available Tailscale connections when multiple are available
- Browse machines using their Tailscale machine names, matching the admin console
- Optionally show offline machines, dimmed and labeled below the online ones
- Copy a machine's Tailscale IP, machine name, or full DNS name
- Send files to a machine with Taildrop, when the tailnet allows file sharing

## Machine names and offline peers

Names follow the editable machine name in the Tailscale admin console (the first label of `DNSName`). The OS hostname is used only when a DNS name is unavailable. This applies to this device, peer rows, tailnet exit nodes, and copied machine names; Mullvad region labels are unchanged.

Turn on **Show offline peers** beside the **Machines** heading, or press `o` while the panel is open. The toggle saves the `showOfflinePeers` widget setting. You can also set it from the command line:

```bash
omarchy bar set omarchy.tailscale showOfflinePeers true --json
```

The setting defaults to off and applies immediately, without waiting for a refresh. Online machines appear first; each group is sorted by machine name. Offline machines are labeled **Offline** and remain available for copying names and addresses. File sending and exit-node selection remain online-only.

The corresponding bar entry option in `~/.config/omarchy/shell.json` is `"showOfflinePeers": true`.

## Keyboard shortcuts

Inside the panel:

- `j` / `k` or arrows: move cursor
- `enter` / `space`: activate current row
- `c`: copy selected peer IP
- `n`: copy selected peer name
- `d`: copy selected peer DNS name
- `s`: send files to selected peer
- `t`: toggle Tailscale
- `o`: show or hide offline peers
- `r`: refresh status
- `esc`: close

## Requirements

- `tailscale` CLI on `PATH`
- `wl-copy` for clipboard copy actions
- Taildrop enabled for the tailnet, to send files

## Receiving files

Incoming Taildrop files are saved to `~/Downloads` by the
`omarchy-tailscale-receive` service, which announces each one with a
notification (an image preview when the file is an image, and a click to open
it). The Tailscale service install enables it; `omarchy tailscale receive`
runs the same loop by hand.

## Icon

Renders the Tailscale mark natively as a theme-colored 3×3 dot grid, matching the official SVG silhouette while avoiding tiny-SVG rendering quirks in the bar.

## Add to the bar

This widget ships as first-party plugin `omarchy.tailscale`. Add it with `omarchy plugin enable omarchy.tailscale`, then place it with `omarchy bar move omarchy.tailscale` if desired.
