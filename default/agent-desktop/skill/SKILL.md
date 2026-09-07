---
name: agent-desktop
description: Open and control apps in an on-demand Hyprland desktop for browser and GUI tasks, with screenshots and input kept separate from the user's desktop.
---

# Agent desktop

Use the `hypr-desktop` MCP tools when available. Otherwise call the same tools through `agent-desktop tool NAME 'JSON_ARGUMENTS'`. The helper reads the local endpoint and token; do not print credentials or build a separate client.

Each claim opens an ordinary window containing a separate desktop. It does not take initial focus. Host configuration may choose a monitor. Tell the user before claiming; the server also sends desktop notifications. This separates GUI input and browser profiles, not filesystem permissions or arbitrary shell access.

## Open an app

1. Call `claim` with an `owner` describing the task.
2. Use the exact `structuredContent.handle` on every subsequent call. A desktop number is not a handle. Tell the user which desktop opened.
3. Call `open` with that handle and a command array. Use Brave or Chromium for browser tasks; `open` assigns a separate browser profile.
4. Call `observe` and inspect the image. If loading, call `wait` briefly and observe again. A successful launch does not prove the app loaded.

```sh
agent-desktop tool claim '{"owner":"check the settings page"}'
agent-desktop tool open '{"handle":"RETURNED_HANDLE","command":["brave","https://example.com"]}'
agent-desktop tool observe '{"handle":"RETURNED_HANDLE","scale":0.5}'
```

Replace `RETURNED_HANDLE` with the returned value. The shell helper saves screenshots to a private temporary directory and prints the image path. Open that image before interacting.

If authentication is required, ask the user to click the desktop window and log in. Do not copy cookies or credentials from their usual browser profile.

## Interact

| Tool | Arguments after `handle` | Effect |
|---|---|---|
| `observe` | optional `scale: 0.5` | Screenshot, windows and new `frame_id` |
| `click` | `frame_id`, `x`, `y`, optional `button` | Click a visible target |
| `move` | `frame_id`, `x`, `y` | Move the cursor |
| `scroll` | `frame_id`, `x`, `y`, `dy` | Scroll at a visible position |
| `type` | `text` | Type into the focused field |
| `key` | `combo`, e.g. `ctrl+l` or `Return` | Press a key combination |
| `windows` | none | Inspect mapped windows |
| `wait` | `ms`, maximum 30000 | Wait for a transition |
| `run` | `command`, optional `timeout_ms` | Run a shell command inside the desktop |

Coordinates always use 2560×1440 pixels. Multiply coordinates seen in a half-scale screenshot by two. Coordinate tools require the latest `frame_id`; observe again after navigation, scrolling or other visual changes. Never guess a target you have not seen.

Launch apps with `open`, not `run`. In particular, browsers can hand a new launch to an existing browser on the user's real desktop unless `open` supplies the separate profile. Do not use bare `agent-desktop start`, `env`, `run`, `wtype` or real-session Hyprland dispatches to bypass ownership.

## Cleanup and errors

Release every desktop you claimed after saving task outputs, including on failure:

```sh
agent-desktop tool release '{"handle":"RETURNED_HANDLE"}'
agent-desktop tool status '{}'
```

Release stops that desktop and its managed apps. Never release someone else's handle or use `stop all`. If the user asks to keep one open, retain its handle and explain that 30 minutes without an agent call triggers idle cleanup. User mouse activity does not renew the lease. Calls such as `windows` renew it during intentional waits.

A tool error or nonzero exit means failure. An expired handle cannot be revived; claim again only if work remains. If release fails, retain the handle and retry once after inspecting the error, then report any remaining desktop. An unreachable endpoint is not permission to start a competing server. Inspect `journalctl --user -u hypr-desktop` and ask the user to check setup if necessary.

These tools capture the nested desktop only. Capturing or controlling the user's real screen is a separate task and requires their authorization.
