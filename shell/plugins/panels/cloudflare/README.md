# Cloudflare Omarchy Widget

Native Omarchy bar widget for the Cloudflare CLI (`cf`), laid out after the dashboard's account home.

## Features

- Shows whether `cf` is signed in: the Cloudflare mark carries a warning badge when it is signed out or its token is rejected
- Left click opens a keyboard-friendly panel; right click opens the dashboard; middle click refreshes
- Lists the account's **Workers** first, most recently deployed at the top
- Lists the account's **Domains** below them, with their plan, calling out any that are paused or not yet active
- Opens a Worker into its own view, after the dashboard's Worker page: invocations, CPU time, and errors over the last 24 hours with a sparkline each, and its last 10 versions with the live one marked, in a list that scrolls on its own while the header and metrics stay put
- Opens any domain or Worker in the dashboard from its row button, copies a domain's zone ID, and copies a Worker's `workers.dev` URL (or its name when it has none)
- Switches between accounts when the login reaches more than one
- Signs in with `cf auth login` when signed out

## Keyboard shortcuts

Inside the panel:

- `j` / `k` or arrows: move cursor
- `h` / `l` or left / right: switch account
- `enter` / `space` or `o`: open the selected domain in the dashboard, or step into the selected Worker (sign in, when signed out)
- `c`: copy the selected zone ID or Worker URL
- in a Worker's view: `h`, left, or `backspace` to go back; `o` to open it in the dashboard; `c` to copy the selected version ID
- `r`: refresh
- `esc`: close

## Requirements

- `cf` on `PATH` (preinstalled by Omarchy through a mise wrapper)
- `wl-copy` for clipboard copy actions

## How it works

`Service.qml` runs `cf auth whoami` when the panel opens and every `refreshIntervalSec` (5 minutes by default, since each call reaches the Cloudflare API). `cf` exits 0 whether or not you are signed in, so `Model.js` reads the state from its JSON. Once signed in, `cf workers list` and `cf zones list` run side by side for the selected account, which `cf` takes from `CLOUDFLARE_ACCOUNT_ID`. Each section keeps its last good list and shows its own error if its call fails.

A Worker's view loads when it is opened and is kept for a minute. Its versions come from `cf workers versions list` and `cf workers deployments list`, which says which version is live. Its metrics come from Workers Logs through `cf observability telemetry query`, so they need Workers Logs turned on for that Worker, and they can differ slightly from the dashboard's own analytics. The query leaves `granularity` unset: the API reads it as a bucket size, and a small value asks for thousands of buckets and times out. Canceled requests and dropped response streams are visitors leaving, so they are not counted as errors.

Commands run with `NO_COLOR=1` and `FORCE_COLOR` unset, because `cf` otherwise colors its JSON output.

## Add to the bar

This widget ships as first-party plugin `omarchy.cloudflare`. **Install > Service > Cloudflare** enables it, or add it with `omarchy plugin enable omarchy.cloudflare`, then place it with `omarchy bar move omarchy.cloudflare` if desired.
