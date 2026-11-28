# Apps: Defaults, Launchers, and Installing

Read this before changing which app opens something, adding a web app or TUI launcher, or installing or removing software.

## Default Applications

| Role | Default | Change it with |
|------|---------|----------------|
| Terminal | foot | `omarchy default terminal <alacritty\|foot\|ghostty\|kitty>` |
| Browser | Google Chrome | `omarchy default browser <chromium\|chrome\|brave\|brave-origin\|edge\|firefox\|zen>` |
| Editor (GUI and `$EDITOR`) | Plain | `omarchy default editor <plain\|code\|cursor\|zed\|sublime_text\|helix\|vim\|emacs\|nvim>` |
| Dictation | Superwhisper | `omarchy default dictation <superwhisper\|voxtype\|hex>` |
| Coding agent | chosen at first use | `omarchy default agent <claude\|codex\|opencode\|pi\|...>` |
| Files | Folio | `xdg-mime default <app>.desktop inode/directory`, and rebind Super+Shift+F, which always opens Folio |
| Images, video, music | Omaview | `xdg-mime default <app>.desktop <mimetype>` |
| PDF | Papers | `xdg-mime default <app>.desktop application/pdf` |
| Markdown | Omawrite | `xdg-mime default <app>.desktop text/markdown` |
| Email links | HEY web app | `xdg-mime default <app>.desktop x-scheme-handler/mailto` |

Each `omarchy default` command prints the current choice when run without an argument, and the same choices are in the menu under Setup > Defaults. `omarchy install terminal <name>` installs a terminal and switches to it; `omarchy install browser <name>` only installs, so change the browser with `omarchy default browser <name>`, which installs a missing one first. The terminal is reached through `xdg-terminal-exec` (`$TERMINAL`), and every editor through `omarchy-launch-editor` (`$EDITOR`), so bindings and scripts that use those follow the choice.

`xdg-mime default` writes `~/.config/mimeapps.list`, which overrides Omarchy's defaults in `/usr/share/applications/mimeapps.list`. Leave `~/.config/hyprland-mimeapps.list` alone: it routes web links through `omarchy-browser.desktop`, which opens them in whichever browser is the default.

Omarchy also ships Omacalc, Omacut (video trimming), Hype (presentations), Monologue (webcam recording), Signed (PDF signing), Obsidian, LibreOffice, Pinta, LocalSend, Fantasi (image and media models), Flowtunes (endless music from the local music model), btop (Activity), and the HEY, ChatGPT and Grok web apps. `omarchy menu keybindings --print` shows which of them have hotkeys.

## Web Apps and TUIs

A web app opens a site in its own browser window with its own launcher entry; a TUI launcher opens a terminal program in its own window. Both write a `.desktop` file to `~/.local/share/applications/`, so they show in the app launcher:

```bash
omarchy webapp install "YouTube" https://youtube.com https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png
omarchy webapp remove YouTube
omarchy tui install "Disk Usage" "dust" float <icon-url-or-name>   # window style: float or tile
omarchy tui remove "Disk Usage"
```

Run either without arguments for an interactive prompt. To put one on a key, use the `{ webapp = ... }` or `{ tui = ... }` binding forms in [`hyprland.md`](hyprland.md).

## Installing and Removing Software

```bash
omarchy pkg add <pkg...>          # From the Arch and Omarchy repos
omarchy pkg aur add <pkg...>      # From the AUR
omarchy pkg drop <pkg...>         # Remove packages
omarchy pkg install / pkg remove  # Fuzzy pickers for browsing what to add or remove
```

Curated installers set an app up the Omarchy way (theme, defaults, launcher), and most have a matching `omarchy remove ...`:

```bash
omarchy install browser firefox
omarchy install editor vscode          # Also helix, zed, emacs
omarchy install dev-env ruby           # node, python, go, rust, elixir, ... (via mise)
omarchy install service tailscale      # Also 1password, dropbox, signal, nordvpn, sunshine, ...
omarchy install gaming steam           # Also lutris, heroic, retroarch, geforce-now, xbox-cloud, ...
omarchy install docker dbs             # A database in Docker
omarchy remove preinstalls             # Drop the preinstalled web apps, TUIs and apps, with their hotkeys
omarchy install preinstalls            # Bring them back
```

`omarchy install --help` and `omarchy remove --help` list them all; the menu's Install and Remove sections hold the same.
