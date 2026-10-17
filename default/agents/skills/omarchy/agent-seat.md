# The Agent Seat

Use the agent seat whenever a task needs a graphical app: clicking through a web page, filling a form, checking how a UI renders, reading what is on screen. Never drive the user's desktop with `ydotool`, `wtype`, raw `hyprctl` or `grim` on their session; those move the user's cursor, type into whatever the user has focused, and capture their private windows. When a task needs a window the user already has open outside the seat, ask the user to do it or to open what you need on the seat instead.

Apps started on the agent seat are real windows on the seat's own workspace (10 unless the user moved it), outlined in orange. You drive them with your own pointer and keyboard, which reach nothing else, while the user keeps working. The user can also use these windows with their own mouse and keyboard at the same time. The apps are sandboxed: their own home and their own private session bus, no access to the user's windows, screen, keyring, portals or files, and no GPU. An app can read the user's clipboard only while the user's keyboard is in it and the user acted last, so your own paste gets nothing and your copies never reach the user's clipboard; but a page you opened can read what the user copied as soon as they click or type into its window. The apps share the host's network, so they reach the internet and every service listening on the user's localhost.

## Workflow

Read controls by name first; look at pixels only when there is nothing to read.

```bash
window=$(omarchy agent seat run --cdp chromium https://omarchy.org)   # prints the agent window number
omarchy agent seat state "$window"                               # drawn yet? popups? who acted last?
omarchy agent seat ui "$window"                                  # its controls: role "name" = value @x,y [states]
omarchy agent seat click-ui "$window" "button:Save"              # click a control by name
omarchy agent seat type "$window" "hello" --key enter
omarchy agent seat ui "$window" --find "textbox:Search"          # read it back to verify
omarchy agent seat screenshot "$window"                          # prints a PNG path; read it
```

1. `state` first: whether the app has drawn, its open popups, its size and scale, and whose input it saw last (`focus.owner`). If the user is typing in it (`user_keyboard`), leave that window alone.
2. `ui` lists what the app shows from its accessibility tree: one control per line, indented under its container, with its centre in the same pixels `pointer` takes. `--json` gives the same as objects (`role`, `name`, `value`, `states`, `x`, `y`, `box`); `--find <name>` or `--find <role>:<name>` resolves one control and exits 1 listing the candidates when several match.
3. `click-ui <window> <name>` clicks a control by its full name: an exact name, then a case-insensitive one. It never clicks a control whose name only contains what you gave (`Delete` for "Delete account and data"); it lists those and exits 1, so rerun it with the full name as `ui` prints it. Narrow an ambiguous name with its role, as `ui` prints it (`"push button:OK"`, or just `button:OK`). In a page, a control under a sticky header or a dialog is marked covered and refused: scroll it clear or dismiss what covers it, then try again. `--double` and `--button right` work as in `pointer`. Nameless fields are reached by role alone when there is one: `click-ui 1 text:`. Roles are the app's own words: GTK and Qt say `push button`, `text`, `check box`; web pages say `button`, `textbox`, `link`.
4. After acting, run `ui` again and check the value or state you expected (`= "clicked"`, `[checked]`, `[focused]`). That is the verification; it costs no image.
5. Screenshot only when `ui` exits 2 (the app has no tree: Wine, games, canvases, Electron launched without `--cdp`), when a control is missing or unnamed, or to confirm something visual. Coordinates from `ui` and from a screenshot are the same pixels, so you can mix them.

- Chromium and Electron apps: launch them with `--cdp` (`omarchy agent seat run --cdp chromium https://omarchy.org`). `ui` then reads the page through the DevTools protocol, which names links, buttons and fields far better than their accessibility bridge, and clicks still go through your own pointer. It covers the page only: the browser's own toolbar, tabs and bubbles need a screenshot. Without `--cdp` they publish no tree at all, unless started with accessibility forced on (`omarchy agent seat run /usr/bin/env ACCESSIBILITY_ENABLED=1 chromium ...`), which also names the toolbar and tabs but runs slower on heavy pages.
- When several browser windows or tabs on the seat show the same title, `omarchy agent seat ui <window>` cannot tell which page is in the window. It exits 1 with a numbered list, one page per line as `N. <title> — <url>`, and a last line asking for `--page`. Pick the page you meant by its URL and rerun with `--page N`, using its number from the list, or `--page <part of its URL>`; for a click, `omarchy agent seat click-ui <window> <query> --page N`. The numbers follow DevTools' target ids, so they stay the same between calls while the same pages are open. A selector that matches no page, or several, is also an error that lists the pages again. You can pass `--page` even when nothing is ambiguous; it only narrows the choice. `--page N` also picks between two windows of one GTK or Qt app with the same title, which `ui` numbers the same way when the seat's keyboard focus doesn't settle it. When a browser window has a side panel or docked DevTools, `ui` marks the page's controls unverified and `click-ui` refuses them; click by coordinates from a screenshot instead.
- `pointer` actions: `move <x> <y>`, `click <x> <y> [--button left|right|middle] [--double]`, `drag <x1> <y1> <x2> <y2>`, `scroll <x> <y> <dy> [<dx>]` (positive `dy` scrolls down, in wheel notches). Use them for what has no name: canvases, drags, scrolling.
- Screenshots include menus and popups, even ones that open outside the window, and work while the seat's workspace is hidden. Coordinates follow the last screenshot, so take a fresh one, or run `ui` again, after anything that opens or moves a popup.
- `type` takes text and `--key` combos in any order: `--key ctrl+l`, `--key enter`, `--key esc`, `--key tab`, `--key ctrl+shift+t`. Text is limited to what the user's keyboard layout can type. Click the field first (`click-ui 1 text:`) so the keys land in it.
- `omarchy agent seat windows` lists every seat window as JSON: window, app_id, title, size, popups.
- Every seat app shares one home, `~/.local/state/omarchy/agent-seat/home`, separate from the user's and kept when apps exit and across `omarchy agent seat stop`: cookies, logins and settings persist from earlier runs, so a site is logged out only until someone signs in on the seat, and a browser may offer to restore its last pages. Never assume a clean profile, and don't delete that directory unless the user asks. Apps under `~/.local/opt` and similar are fine: `omarchy agent seat run ~/.local/bin/chatgpt`. A program outside `/usr` gets only its own file, plus its directory when that is an app bundle (with `lib`, `resources`, `resources.pak` or `AppRun` beside it). A wrapper script that runs something elsewhere needs that place shared with `--share-ro`.

## When you need the user

Logins, captchas, two-factor prompts and anything else that needs the user's own hands: ask them to jump to the seat (`Super + Ctrl + Alt + A`) and do it in the agent window, then wait for them to say they're done. Don't act in the same window while they work in it: an app has one focus, so whoever acts last takes it. Other agent windows are fine.

## Your files

The sandbox sees none of the user's files unless you share them: `--share <path>` read-write, `--share-ro <path>` read-only, repeatable, each at the same path inside. `omarchy agent seat run --share ~/Projects/site chromium ~/Projects/site/index.html`. The seat asks nothing about this itself; sharing is part of your command, so your own permission rules decide it, the same as for files you touch directly. Share only what the app needs. The seat refuses shares that would undo the sandbox: `/`, the user's home or `/tmp` as a whole, `$XDG_RUNTIME_DIR` and `/run/user`, `/proc`, `/dev`, any directory holding one of those, and anything inside `~/.config`, `~/.ssh`, `~/.gnupg` or `~/.local/share/keyrings`, including where those link to.

## Limits

- No clipboard of your own, file pickers, audio or GPU inside the sandbox. Apps draw in software; one that refuses to run without a GPU (most game engines, Vulkan apps) can't run on the seat.
- `ui` is only as good as the app's accessibility: GTK and Qt name most controls; custom-drawn widgets, icon-only buttons without labels and canvases show up unnamed or not at all. GTK 4 popover contents can sit a few pixels off; their controls still click. A tree can also be stale for a moment after a click, so wait briefly before reading it back.
- The network is the host's: a page in an agent app can reach the user's local services (databases, dev servers, browser debugging ports). Don't open a debugging port in an agent app unless the task needs it, since everything on the machine can reach it too; `--cdp` opens one, so use it for pages you need to read, not by habit.
- Without `--share`, the sandbox cannot see the user's files. Anything the app downloads lands under `~/.local/state/omarchy/agent-seat/home`.
- `omarchy agent seat stop` closes every app on the seat; `omarchy agent seat status` shows whether it is running.

How the seat works, and why it refuses what it refuses: see `docs/agent-seat.md` in the Omarchy repo.
