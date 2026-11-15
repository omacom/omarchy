# Themes, Backgrounds, and Fonts

Read this before changing themes, backgrounds, fonts, or theme colors.

## Theme Commands

```bash
omarchy theme list              # Show available themes
omarchy theme current           # Show current theme
omarchy theme set <name>        # Apply theme ("Tokyo Night" and "tokyo-night" both work)
omarchy theme bg next           # Cycle background
omarchy theme install <url>     # Install from git repo
```

## Making a New Theme

A theme is a directory in `~/.config/omarchy/themes/<slug>/` (the slug becomes the name: `tea-house` shows as "Tea House") with two things in it:

- `colors.toml`, the palette. Omarchy generates every app's colors from it when the theme is applied: terminals, btop, Hyprland borders, Neovim, VS Code, the shell, the keyboard backlight, and the rest (from `$OMARCHY_PATH/default/themed/*.tpl`). Don't write those files; a file the theme ships replaces the generated one, so write one only to override it.
- `backgrounds/`, two to four wallpapers named `1-<name>.jpg`, `2-<name>.jpg`, and so on, each at least 1920x1080.

1. Copy the `colors.toml` of a stock theme with the same `mode` (dark or light) from `/usr/share/omarchy/themes/` and change its values. It must keep every key: `mode`, `accent`, `selection`, `muted`, `background`, `dark_background`, `darker_background`, `lighter_background`, `foreground`, `dark_foreground`, `light_foreground`, `bright_foreground`, `red`, `yellow`, `green`, `cyan`, `blue`, `magenta`, `orange`, `brown`, and `bright_` versions of red through magenta. Keep body text readable: `foreground` on `background` at 7:1 contrast or more, `accent` and the colors at 3:1 or more.
2. Download photographs or artwork for the backgrounds. Never draw them with ImageMagick or code: generated scenes come out as blurry blobs. Wallhaven's API searches wallpapers by short tag, and needs no key:

   ```bash
   curl -s 'https://wallhaven.cc/api/v1/search?q=lantern+night&categories=110&purity=100&atleast=1920x1080&ratios=landscape&sorting=relevance' \
     | jq -r '.data[].path' | head -10
   curl -sLo backgrounds/1-lanterns.jpg '<one of those paths>'
   ```

   Use one or two words per query (`lantern night`, `misty forest`), and try a few queries. Open every downloaded image and look at it; keep only the ones that fit the theme's mood and colors, and delete the rest.
3. Look at the result before calling it done: the backgrounds with the palette's colors beside them. Fix any color that clashes with the backgrounds.
4. When done with the theme, run `omarchy theme set "Name of new theme"`.

Additional user backgrounds for any theme (stock or custom) go in
`~/.config/omarchy/backgrounds/<theme-slug>/`.

## What a Theme Installed From a Repo May Not Contain

A theme the user wrote by hand in `~/.config/omarchy/themes` is unrestricted, as
are Omarchy's own themes. From a theme cloned by `omarchy theme install`, Omarchy
drops only what runs code: any `*.lua` (Hyprland requires a theme's
`hyprland.lua` and `gum_env.lua` at login, Neovim loads `neovim.lua` at startup),
the terminal configs `alacritty.toml`, `foot.ini`, `ghostty.conf` and
`kitty.conf` (each names the program the terminal launches), and `vscode.json`
(names a VS Code extension to install). Those are regenerated from `colors.toml`
through `$OMARCHY_PATH/default/themed/*.tpl`, and named on stderr.

Everything else a cloned theme ships is kept, including `btop.theme`,
`chromium.theme`, `helix.toml`, `keyboard.rgb` and `shell.toml`.
Omarchy tells a cloned theme from the user's own by the `.git` directory a clone
leaves behind.

To change how Omarchy themes an app for every theme, write the template rather
than the theme: `~/.config/omarchy/themed/<config-name>.tpl` overrides the
built-in one. See `docs/theming.md` in the Omarchy repo.

## Customizing a Stock Theme

Never edit stock themes under `/usr/share/omarchy/themes/` — changes are lost
on update. Two safe options:

Both write into `~/.config/omarchy/themes`, where a theme the user wrote is
unrestricted — the list above applies only to a theme cloned from a repo.

**Overlay (preferred for small tweaks):** create a user theme directory with
the SAME slug containing only the files you want to change. When the theme is
applied, the stock theme is copied first and your files win on top:

```bash
mkdir -p ~/.config/omarchy/themes/catppuccin
cp /usr/share/omarchy/themes/catppuccin/colors.toml ~/.config/omarchy/themes/catppuccin/
# Edit the copied colors.toml, then re-apply:
omarchy theme set catppuccin
```

**Fork:** copy the whole stock theme under a new name for a fully independent
variant:

```bash
cp -r /usr/share/omarchy/themes/catppuccin ~/.config/omarchy/themes/catppuccin-custom
# Edit ~/.config/omarchy/themes/catppuccin-custom/, then:
omarchy theme set catppuccin-custom
```

## Fonts

```bash
omarchy font list               # Available fonts
omarchy font current            # Current font
omarchy font set <name>         # Change font
```
