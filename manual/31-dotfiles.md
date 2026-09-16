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

If you end up making a lot of changes to tweak your own setup, it's a good idea to backup all these dotfiles. [Stow is a great way to do that](https://www.youtube.com/watch?v=NoFiYOqnC4o).

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
| `post-update` | During `omarchy update`, after packages and migrations |
| `pre-refresh-pacman` | Before `omarchy refresh pacman` re-syncs the package config |
| `theme-set` | After a theme change (theme name in `$1`) |
| `font-set` | After a font change (font name in `$1`) |
| `battery-low` | When the battery gets low (percentage in `$1`) |

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

If you end up making a mess of the configurations, you can always revert them to the defaults via _Update > Config_ in the Omarchy menu. Or by running `omarchy reinstall configs` to reset everything.

## Preference history and sharing

Choose **Setup > Preferences** to start keeping local history. If you already use Stow, chezmoi, yadm, or symlinked configuration files, Dots stands down so your existing manager stays in charge. Nothing is uploaded or applied automatically.

**System > Preferences** provides Save Snapshot, Review Changes, Local History, and Restore a File. Restoring a file saves its current version first, so a restore can itself be undone. History lives on this computer; use a home-folder backup to protect it from disk failure.

To share preferences, choose **Create a private GitHub repository** in **Setup > Preferences** (requires signing in with `gh auth login`), or use an existing private Git repository. Choose that same repository on each computer. Use its SSH URL and make sure SSH access already works. The terminal equivalent is `omarchy dots setup --repo git@github.com:you/private-preferences.git`. A local bare Git repository also works. No cloud-backup account is required.

On the computer with the settings you want, choose **Publish Settings**, review the file diff, and confirm. On another computer, choose **Apply Settings**. Your current files are saved locally before anything is replaced. Independent edits are merged. When the same setting changed in both places, no files are applied: choose **Resolve Conflicts**, review each file, choose this machine's version or the shared version, then **Continue Update**. To keep both versions' ideas, choose one, apply, edit the result, and publish it. **Cancel Update** leaves your local edits in place; it also undoes an interrupted application when those files have not been edited again.

If someone published since your last pull, publishing stops and asks you to apply shared settings first. Removing a shared file is a change too: deletion travels to the other computer when it has no conflicting local edit. The preview shows additions, changes, and deletions. `omarchy dots pull --dry-run` previews without changing your preferences.

The shared list is deliberately small: `.bashrc`, `.XCompose`, keybindings, look-and-feel, shell layout, menu extensions, and selected terminal, prompt, tmux, and btop settings. Monitor, input, autostart, and main Hyprland configuration have local history but never travel between computers. Installed plugins, themes, wallpaper files, credentials, browser profiles, and session snapshots are not published. References in shared preferences still require the referenced applications and themes to be installed on the receiving computer. Use compatible Omarchy versions on both machines; Dots does not translate old configuration formats.

Only those audited files can be tracked. Review their contents before publishing: a shell configuration can still contain a token or a machine-specific path you put there. Use a private repository. Published preferences have their own history; your automatic recovery snapshots never leave this computer. Local file permissions are restricted when applying shared preferences.

For terminal use: `omarchy dots snapshot`, `log`, `diff`, `push`, `pull`, and `status`. `omarchy dots restore .bashrc --at <snapshot>` restores a version from Local History. Resolve with `omarchy dots resolve <file> --take ours` or `--take theirs`, then `omarchy dots continue`. `omarchy dots abort` cancels a pending update. `--yes` on push, pull, or restore skips its confirmation for scripts.
