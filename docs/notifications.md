# Notifications

The shell is the notification daemon: `shell/plugins/notifications/Service.qml` hosts a Quickshell `NotificationServer` that claims `org.freedesktop.Notifications` on the session bus, so anything that speaks the freedesktop protocol (notify-send, libnotify apps, Chromium web apps) is drawn as a card in a deck at the top-right corner. The end-user view is in `manual/10-notices.md`.

## Files

| File | Role |
|---|---|
| `Service.qml` | The daemon: admission, quiet rules, the scene clock, click routing, IPC, one layer surface per output |
| `Toast.qml`, `DeedButton.qml` | One card and its buttons; a card is positioned by the service and animates nothing itself |
| `Store.js` | Notification snapshots, normalisation, what a stored row keeps, the stored file formats, restore |
| `Markup.js` | Safe body markup, source lifting (`web:app.slack.com`), one-line previews |
| `Detect.js` | Verification codes and links |
| `Security.js` | URL policy, bounds, the sender image path policy, the `omarchy-exec-argv` and glyph checks |
| `Icons.js` | The names a card's icon may go by: site names, symbolic icons |
| `Layout.js` | Pure deck layout: rows in, placements out |
| `Delivery.js` | Quiet rules, ephemeral rules, bar clearance |

The JS modules also load in Node: `test/shell.d/notifications-test.sh` covers them without a compositor, along with the startup cleanup.

## Decks and the scene clock

Each notification gets its own key (`n…`); the sender's id names a slot that `replaces_id` reuses, not an event. Cards group by source: per site for browser notifications (the leading `<a href>` Chromium adds is lifted off and becomes the source, but only from a browser and only for an http(s) href that passes the URL policy), per app name otherwise.

A collapsed deck draws its cards at the front card's height; hovering opens it. While the pointer is on an open deck, new cards are held back for at most 30 seconds. All positions, scales, opacities and heights come from one clock (`Service.at()`): a change snapshots the current state, recomputes the layout, and starts one move for every card. A leaving card keeps its model row until that move finishes.

Live `Notification` objects are kept in a plain JS map (`refs`), never a ListModel role, which would dangle once the server destroys the object. At most 100 are live.

The surface is one fixed-width `WlrLayer.Overlay` window per output (namespace `omarchy-notifications`), input-masked to the deck. It stays mapped while idle, because a layer surface coming and going makes Hyprland re-evaluate focus and drags a scrolling layout's viewport. The exception is a fullscreen window: the surface unmaps over it when nothing is showing so the window can be scanned out directly.

## Toast lifecycle

A card stays at least 5s (low), 8s (normal), or until dismissed (critical), stretched up to 30s by a longer `expire_timeout`. Its time pauses while the deck is open; a content update restarts it. Left-click activates; right-click, middle-click, or the close mark on hover dismisses.

A click tries, in order: the card's `omarchy-exec-argv` command; the sender's `default` action; the sender's window by pid; a window showing the source (exact class, then for a site a browser window whose title names it); the site itself; the first link in the text; `omarchy-hyprland-focus-app` by app name.

## Persistence

The shell keeps its state in `~/.local/state/omarchy/notifications/` (0700), three JSON files it reads with `FileView` once at startup and rewrites whole:

- `live.json`: the rows on screen, oldest first, put back after a shell restart with a 20s grace (critical ones still wait). At most 100.
- `history.json`: closed rows, newest first, each with `closed_ts` and `closed_reason`. Capped at 100 entries and 24 hours. Rows whose reason is `silenced` were held back by Do Not Disturb.
- `quiet.json`: `{ dnd }`.

A card with the `transient` hint is never written to either file, as the hint asks: it is not put back after a restart and leaves no history when it closes. Its sender sends it again when it still applies, as `omarchy-migrate-notify` does at every login.

`Store.persistable` decides what a row keeps: its scalar fields, never images, detected links, or derived text. Text with a verification code is stored only as the redacted placeholder, the click command and glyph included. A live row is cut to 16K characters and a history row, shown as a one-line preview, to 4K. Rows keep `execArgv` and `glyph`, so a card restored after a shell restart clicks through like the live one. Rows are re-checked the same way when read back; a file that is not an array of keyed objects, or is oversized, reads as empty, and a file that does not read back exactly as it would be written is rewritten.

Writes go through one short timer, started (not restarted) by a change, so a burst of arrivals writes each file once and a flood writes at most four times a second; no file is written before it has been read. `FileView` writes atomically, which keeps the mode of the file it replaces, so the files are created at 0600 before anything writes them.

At startup one process makes the directory and those files; a symlink in place of a state file is replaced. Persistence starts no other process. Older layouts' leftovers, which hold old message content, are removed once by migration `1792648436`: 4.0's `<ms>-<id>.json` popups and its `history/` and `images/` directories. It carries 4.0's Do Not Disturb from `~/.local/state/omarchy/notifications.json` into `quiet.json` and removes that file.

## Icons

Icons are resolved in the shell, the way the dock resolves its own, by each card (`Toast.qml`, with the names from `Icons.js`). The first that loads wins:

1. The sender's image: an in-memory `image-data` picture (`image://qsimage/…`), or a local file named by the `image-path` hint.
2. The icon theme (`Quickshell.iconPath`): for a browser notification the site's own names first (`app.slack.com`, then `slack`), then the app's icon hint (or its `desktop-entry` hint), source and name. An icon of your own under one of those names in `~/.local/share/icons/hicolor/` is found here, unless the active theme has its own by that name.
3. The icon of a desktop entry matching the hint, source or app (`DesktopEntries.heuristicLookup`); for a site, only the browser's, since a fuzzy match on a domain label would put Google Contacts on `mail.google.com`.
4. The glyph an Omarchy sender asked for, else the first letter of the source.

An icon named `*-symbolic`, or a file under a `symbolic/` directory, is a one-colour mark and is tinted with the theme's text colour.

A site's icon is never fetched: the site name comes from the notification body and a browser is recognised by its self-asserted app name, so fetching would let any sender make the host contact a server of its choosing.

Images are decoded in the shell process like every other image it draws. A sender's file path (`Security.localImagePath`) must be absolute, at most 1024 characters, free of control characters and of empty, `.` and `..` segments, and not under `/proc`, `/sys`, `/dev` or `/run` and `/var/run` (other than `/run/user/<uid>/`); `file://` URLs are accepted and decoded first. No extension is required, as Chromium's temp files (`/tmp/.org.chromium.Chromium.*/…`) have none. A native sender already runs as you and could read the file itself; a sandboxed one can only name a file for you to see. Images are never persisted, so restored and replayed cards fall back to the source's icon.

## Silencing

Do Not Disturb is a boolean in `quiet.json`, toggled via `omarchy-shell notifications toggleDnd` / `setDnd` / `isDnd`; `omarchy-toggle-notification-silencing` wraps the toggle.

Three kinds of notification get through Do Not Disturb:

- `app_name` = `omarchy-action`: Omarchy's own confirmation toasts for something the user just did.
- urgency critical *and* `app_name` = `notify-send`: bare-CLI emergency alerts. Critical alone is not enough, because chat apps use it to force visibility under their own app name.
- a detected verification code: it was asked for a moment ago and expires in minutes.

Silenced notifications are recorded in history, so `showHistory` can put them back on screen. Ephemeral ones (the `transient` hint, or `app_name` `notify-send`/`omarchy-action`) are dropped.

## Appearance

Notifications have no settings of their own. A new deck lands on the focused display and stays there until it empties. Everything else follows the desktop: text size, the theme's outer gap, the locale's time format. Colours come from the theme's `[notifications]` in `shell.toml`, and corners from Hyprland's `decoration:rounding`.

## The sender contract

`bin/omarchy-notification-send` is the one way Omarchy code sends
notifications — never raw `notify-send`. It calls
`org.freedesktop.Notifications.Notify` directly over the session bus (via
`busctl --user`), so each value is one typed D-Bus parameter and there is no
argv layer that could reinterpret a relayed headline as an option or a hint. Its
flags map onto that call:

| Flag | Becomes | Meaning |
|---|---|---|
| `-g` / `--glyph` | hint `omarchy-glyph` | Nerd Font glyph for the icon slot when no image icon resolves |
| `--exec <program> [args…]` | hint `omarchy-exec-argv` | the click command; consumes the rest of the line, so it comes last. Each word is a discrete argument the shell runs without re-parsing (see below) |
| `--action <label> <program> [words…]` | hint `omarchy-actions` | a button, up to three; the first is also the click. Its words end at the next `--action`, `--with` or `--exec`. Cannot be combined with `--exec` |
| `--with <args…>` | appended to every action | the data the actions act on; consumes the rest of the line, so it comes last |
| `--image` | hint `image-path` | the standard freedesktop image hint |
| `-i` / `--icon` | `app_icon` | themed icon name for the toast |
| `--app-name` | `app_name` | defaults to `omarchy-action` |
| `-u` / `--urgency` | hint `urgency` (byte) | `low`/`normal`/`critical`; defaults to `low` |
| `-t` / `--expire-time` | `expire_timeout` | milliseconds on screen; server default otherwise |
| `--transient` | hint `transient` (boolean) | not restored after a restart or kept in history; for reminders that are sent again whenever they still apply |

Unknown flags are a hard error, not a silent pass-through: `--exec` and `--action` are the only doors to a command, and there is no generic option pass-through to smuggle one through.

The defaults are the point: an unadorned `omarchy-notification-send "Done"`
is a low-urgency user-action toast that pops through DND and is treated as
ephemeral noise when silenced.

The click command is deliberately not a libnotify action. An action keeps the
sender blocked waiting for `ActionInvoked`, and dies unanswered whenever the
shell restarts underneath it — the installer toasts restart the shell as their
first act. Carrying the command as a hint means the shell executes the click
itself (detached, so the command outlives the shell process) from the copy it
keeps with the popup, which the persistence files preserve: a restored toast
clicks through exactly like a live one, and oneshot senders can exit
immediately. For third-party clients the click falls back to the libnotify
`default` action while the sender is alive, then to focusing the sender's
window by class via `omarchy-hyprland-focus-app` — chat apps rarely register
an action and just expect click-to-jump.

### Click commands are argv, never shell strings

`--exec` consumes the rest of the line as the click command:

```bash
omarchy-notification-send "Download complete" "$title" --exec mpv -- "$file"
```

The caller's shell has already split those words into discrete arguments, and a
quoted argument (`"$file"`) stays one argument even with spaces. On the shell
side they are run through `Util.execArgv`, which invokes `bash -lc 'exec "$@"'`
with the arguments as **positional parameters** — never interpolated into the
script text. bash expands `"$@"` without re-tokenizing or re-evaluating it, so a
value carrying data an attacker controls — a downloaded video's title, a
received filename, a crashed process's name — is only ever a single argument and
can never be reparsed as a command. The login shell keeps the PATH and session
environment that GUI click targets (the screenshot editor, mpv, xdg-open) expect.

The critical rule: **the splitting must happen at the call site, not inside the
tool.** Passing a single quoted string (`--exec "mpv $title"`) and letting the
tool whitespace-split it would hand argument boundaries to whoever controls the
string's content — a title with a space could inject an extra option or program.
So `--exec` refuses a lone quoted-string argument and points at the unquoted
form. There is no "take a command string and sanitize it" path; that is the
escaping trap (string-concatenated SQL) the yt-dlp title RCE exploited.

The shell fails closed on a malformed argv hint (it must be a JSON array of
strings whose program is present and not a leading-dash option) rather than
running anything it can't validate. A caller can still deliberately name a shell
as the program (`--exec sh -c …`), but that runs code because the *developer*
wrote it, not because attacker data became a command — a reviewable red flag
(greppable as `--exec sh`/`--exec bash`), not an injection. Insulating against a
native same-user process is out of scope: it already runs with your privileges
and needs no notification to execute code. What is fully closed is untrusted
*content* — web notifications can't set the exec hint at all, and any relayed
title/filename is confined to inert argument data.

The sender keeps that last part true structurally rather than leaving it to each
caller. Because it calls `Notify` directly, the headline and description are
typed string parameters — a relayed value like `--hint=…` or `-rf` is the
summary or body, never an option or a hint, and there is no argv/option layer
(no `notify-send`) left to reinterpret it. `--exec` is the only thing that can
build the `omarchy-exec-argv` hint. (The leading `--` on the `busctl` call is a
belt for `busctl`'s own getopt, which would otherwise read a dash-leading value
as a `busctl` option; the summary/body themselves are never parsed as options.)

### Buttons

`--action` adds a button that runs a command, the way `--exec` makes the card click run one:

```bash
omarchy-notification-send "Screen recording saved" "$name" \
  --action "Play" mpv -- \
  --action "Show in folder" nautilus --select \
  --with "$filename"
```

The two halves follow the click-command rule. An action's own words are literals written at the call site, so they can end at the next `--action`, `--with` or `--exec` without being mistaken for data. Untrusted data goes once, after `--with`, which takes the rest of the line and is appended to every action's argv: a filename that reads `--action` stays part of the filename. Options go before the first `--action`, as anything after it is an action's word.

The buttons ride as the `omarchy-actions` hint (`[{"label", "argv"}]`, each argv checked like `omarchy-exec-argv`), and the first action's argv is also set as the click command. Like the click, they are not libnotify actions: the shell runs them itself and stores them with the row, so the sender exits at once and a card restored after a shell restart, or brought back from history, keeps its buttons. The card shows them as a bar along its bottom edge while it is the front card of its deck, or, once a deck is open, only while it is the card hovered or selected.

## Helper commands

- `omarchy-notification-wait [timeout]` — polls until the shell answers IPC
  *and* has claimed the bus name. Anything sending near session start or a
  shell restart uses it, or the toast is sent into the void.
- `omarchy-notification-dismiss <summary>` — dismiss by summary substring,
  used by the first-run toasts once their action has been clicked.
- `omarchy-notification-time` / `-battery` — the hotkey notices: one-line
  low-urgency glyph toasts wrapping `date` and `omarchy-battery-status`.
- `omarchy-notification-weather` — despite the name, not a sender: it toggles
  the `omarchy.weather` shell panel.

Keybindings live in `default/hypr/bindings/utilities.lua`: `Super+comma` variants map to the IPC methods `dismissOne`, `dismissAll`, `invokeLast`, `showHistory` (put the last few back on screen), `keyboard`, and the silencing toggle.

`keyboard` (`Super+Ctrl+comma`) is the only way the notifications take the keyboard: a card that grabbed focus as it arrived would swallow whatever you were typing. It selects the newest card and opens its deck, and the surface on that display takes exclusive keyboard focus. Arrows (or `j`/`k`, `Tab`) move through the cards deck by deck, `1`–`9` press a button in `Delivery.deeds` order (the card numbers them), `Enter` clicks the card, `Delete` dismisses it and selects the next, and `Escape`, any choice, or ten idle seconds end it. While it lasts the deck stays open and new cards wait, as under the pointer. `invokeAction <n>` presses button `n` on the newest card without the mode.

The `notifications` IPC target also answers `ping` (used by `omarchy-notification-wait`), `dismiss <summary>`, `count`, and two for scripts and visual checks: `expand` (open the deck and hover its front card, as the pointer would) and `probe` (what the daemon thinks is true).

## How subsystems plug in

Everything goes through the same sender contract, so the pieces are small:

- **Low battery** — `omarchy-battery-low` sends a normal toast that expires after 30 seconds (paused, like any card, while the deck is open) and runs the `battery-low` hook. Not critical: a critical toast never expires and comes back on every shell start, so the warning would outlive the charger going in. As an `omarchy-action` toast it still gets through Do Not Disturb.
- **Crash capture** — `omarchy-crash-watch` follows the systemd-coredump
  journal stream and announces each crashed program (deduped per minute) as a
  critical toast whose click runs `omarchy-agent-crash` (via `--exec`, so a
  hostile process name stays a discrete argument). It waits for the
  server first: a shell crash takes the notification server down with it, and
  that crash is the one most worth reporting.
- **Pending migrations** — `omarchy-migrate-notify` (from its user service
  after `graphical-session.target`) waits for the server, then sends a
  critical toast whose click opens a terminal running `omarchy-migrate`,
  falling back to printing in the terminal if the hand-off fails.

## Reminders

Reminders ride on notifications rather than being their own daemon.
`bin/omarchy-reminder <minutes> [message]` creates a transient systemd user
timer via `systemd-run --user --collect --on-active=<minutes>m` under the
unit name `omarchy-reminder-<minutes>m-<epoch>`; the timer's payload sends the
reminder toast, deletes its message file, and refreshes the bar indicator.
Custom messages are stashed in `$XDG_RUNTIME_DIR/omarchy-reminders/<unit>.message`
since a unit name cannot carry arbitrary text. `--collect` means fired timers
leave nothing behind.

The state therefore lives entirely in systemd: `show` and `clear` enumerate
`systemctl --user list-timers "omarchy-reminder-*.timer"` — `show` as a
summary toast, `show --json` as the JSON the bar's Reminder indicator polls
(refreshed by the same `omarchy-shell -q omarchy.indicators refresh` call the
timers and mutations make). `omarchy-reminder -i` summons the
`omarchy.reminders` overlay (`shell/plugins/reminders/ReminderFlow.qml`), a
two-step minutes/message prompt that shells back out to `omarchy-reminder` to
do the setting.
