# Dotfiles

Omarchy is primarily configured through the so-called dotfiles that live in `~/.config`. Those are considered your files for your changes. The files that live in `/usr/share/omarchy` belong to Omarchy itself, and you shouldn't be messing with those. If you need to change anything in `/usr/share/omarchy`, you should be overwriting the value in `~/.config` instead.

The key configs can be edited straight from the Omarchy menu (`Super + Space`), like _Setup > Monitors_, _Setup > Keybindings_, _Setup > Input_, and _Setup > Config > [file]_. When you do it this way, any process that needs restarting after config edits automatically will be after you quit the editor (Neovim by default — `:wq`, remember! — but you can change that via _Setup > Defaults > Editor_).

Here's a list of the key files in `~/.config` and what they control:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | The main Hyprland config. Loads the Omarchy defaults plus your override files below. [Learn more about Hyprland configs](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | Your own keybindings and overrides of the defaults. |
| `~/.config/hypr/monitors.lua` | Controls your monitors, resolution, and position. |
| `~/.config/hypr/input.lua` | Controls your keyboard layout, mouse, and trackpad settings. |
| `~/.config/hypr/looknfeel.lua` | Controls gaps, borders, animations, and the rest of the look. |
| `~/.config/hypr/autostart.lua` | Controls extra processes started with the session. |
| `~/.config/omarchy/shell.json` | Controls the Omarchy shell: bar position, layout, and widgets, plus screensaver, lock, and idle timings. |
| `~/.config/foot/foot.ini` | Controls your terminal (foot is the default). |
| `~/.XCompose` | Defines your quick-access emoji and name/email autocomplete. Make sure to run `omarchy-restart-xcompose` after making changes. |

### Going back to an earlier version

Omarchy saves the history of these files, along with `~/.bashrc`, your terminal configs, `~/.config/omarchy/hooks`, and a few more, every time you change them. You keep editing them where they are; [mise](https://mise.jdx.dev/dotfiles.html) saves each version in the background.

If an edit, an agent, or an update made a mess, go to _Setup > Dots > Restore File_, pick the file, and pick the version to go back to. Restoring saves the current version first, so you can change your mind again. _Setup > Dots > Last Change_ shows exactly what the last update or config reset changed in your files.

From the terminal, that's `omarchy dots restore`, `omarchy dots diff`, and `omarchy dots log` to list the saved versions.

### Using the same setup on several machines

Your tweaks can follow you to another machine through a private Git repository. On the machine you've set up the way you like, go to _Setup > Dots > Push_ (or run `omarchy dots push`). The first time, it creates a private GitHub repository for you if you're signed in with `gh auth login`, or takes the URL of any private Git repository.

On the other machine, go to _Setup > Dots > Pull_ (or run `omarchy dots pull <url>`) and give it the same repository. The files that differ get the repository's version, and this machine's version is saved first, so _Restore File_ brings back anything you wanted to keep. After that, push and pull whenever you want to bring the machines in line. Nothing is shared until you push.

Each machine keeps its own `~/.config/hypr/monitors.lua`, since your laptop's screen layout has no business on your desktop.

Every saved version is pushed, so keep secrets like API keys out of these files (`~/.bashrc` and your hooks are the usual culprits). Dots refuses to push a version that looks like it holds a token or key, and tells you which file and line. Removing a secret from a file doesn't remove it from earlier versions, so rotate it and clear that history first. When Omarchy creates the repository for you, it also runs `gh auth setup-git`, which makes `gh` your git credential helper for github.com. If you already manage your dotfiles with Stow, chezmoi, or yadm, Omarchy leaves dots off; turn them on anyway with `omarchy dots enable --force`, or off with `omarchy dots disable`.

### Starting your own apps with the session

If you want something to run every time you log in — a sync daemon, a chat app, your own script — put it in `~/.config/hypr/autostart.lua`:

```lua
o.launch_on_start("my-service")
```

That starts the command as part of the session, so it's properly cleaned up when you log out again.

### Running scripts on system events

Omarchy fires hooks at a handful of moments, and you can hang your own scripts off them. They live in `~/.config/omarchy/hooks/<event>.d/`, one directory per event, and every executable file in there runs when the event happens:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | Right after the desktop has started |
| `post-update` | Near the end of `omarchy update`, after packages, migrations, and service restarts, before mise tools are updated |
| `pre-refresh-pacman` | After `omarchy refresh pacman` re-syncs the package config, before it updates packages; a channel switch runs it during that same refresh step |
| `theme-set` | After a theme change (theme name in `$1`) |
| `font-set` | After a font change (font name in `$1`) |
| `battery-low` | When the battery gets low (percentage in `$1`) |

The `pre-refresh-pacman` hook is where custom repositories or `IgnorePkg` lines belong, since it runs before the package transaction. Both update-related hooks run as your user after Omarchy clears its cached sudo authorization, so a hook that uses `sudo` needs its own authorization and may ask for your password.

Each of those directories already holds a `.sample` file showing the shape of a hook — drop the `.sample` from the name to put it to work. To install a script you've written elsewhere, use `omarchy hook install post-boot ~/my-hook`, which copies it in and makes it executable.

### Adding your own menu entries

The Omarchy menu (`Super + Space`) can be extended with your own rows by editing `~/.config/omarchy/extensions/omarchy-menu.jsonc`. Entries are keyed by a dotted id, and the id is what places them in the tree, so `personal` shows up on the root menu and `personal.notes` shows up inside it:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

Reuse an existing id and you override that row instead of adding a new one. The file ships with all the available fields documented as comments.

### Adding your own shell exports, functions, and aliases

Omarchy ships with a bunch of ergonomic aliases and helpful functions, but it's very common to want to add your own. You should add both aliases, functions, and exports in `~/.bashrc`. This file will not be overwritten on updates. If you want to change any of the Omarchy defaults, you can also safely add them here.

### Changing internal Omarchy files

Look, this is your computer. You can do whatever you want with it, but I would advise against making changes to the files in `/usr/share/omarchy` directly. They belong to the Omarchy pacman package, so your changes will simply be overwritten on the next update. You're better off just overwriting any default values you don't like in the `~/.config/*` folder instead.

You can change just about everything that way, like the default keybindings. Just edit `~/.config/hypr/bindings.lua` to, say, replace [Obsidian](https://obsidian.md/) with [Joplin](https://joplinapp.org/) (install with `omarchy-pkg-add joplin-bin`):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind` removes the existing binding before adding its replacement. It takes the same arguments as `o.bind`, including launch helpers and binding options. Use `o.bind` to add a binding, or `hl.unbind` to remove one without replacing it.

If you insist on hacking on the internal Omarchy files, switch to the dev channel via _Update > Channel > Dev_. That links Omarchy to a git checkout of the source code in `~/omarchy`, which you're free to change to your heart's content. Ain't nobody here to tell you what to do!

### Resetting any changes

If you end up making a mess of the configurations, you can always revert them to the defaults via _Update > Config_ in the Omarchy menu. Or by running `omarchy reinstall configs` to reset everything. Changed your mind after a reset? _Update > Config > Restore Previous_ takes a file back to the version you had.
