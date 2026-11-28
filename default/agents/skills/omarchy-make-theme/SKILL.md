---
name: omarchy-make-theme
description: >
  Make a new Omarchy theme from a look, mood, or inspiration: a colors.toml palette that every app's colors are generated from, and two to four wallpapers downloaded (never drawn), in ~/.config/omarchy/themes/<slug>/, checked with omarchy agent look theme and then applied. Also covers what a theme shared as a git repo may ship. Use when asked to make, create, or design a theme or color scheme. Switching to, tweaking, or forking an existing theme, backgrounds for one, and fonts belong to the omarchy skill. Triggers: make a theme, new theme, custom theme, color scheme, palette, theme inspired by, publish a theme.
---

# Making an Omarchy Theme

A theme is a directory in `~/.config/omarchy/themes/<slug>/` (the slug becomes the name: `tea-house` shows as "Tea House") with two things in it:

- `colors.toml`, the palette. Omarchy generates every app's colors from it when the theme is applied: terminals, btop, Hyprland borders, Neovim, VS Code, the shell, the keyboard backlight, and the rest (from `$OMARCHY_PATH/default/themed/*.tpl`). Don't write those files; a file the theme ships replaces the generated one, so write one only to override it. (Stock themes ship `neovim.lua` and `vscode.json` because each names a published Neovim or VS Code color scheme of the same name, and `preview.png`, `unlock.png` and `preview-unlock.png`, which are screenshots taken when a theme is published. A new theme has none of them, so it leaves them all out.)
- `backgrounds/`, two to four wallpapers named `1-<name>.jpg`, `2-<name>.jpg`, and so on, each at least 1920x1080.

1. Copy the `colors.toml` of a stock theme with the same `mode` (dark or light) from `/usr/share/omarchy/themes/` and change its values. It must keep every key: `mode`, `accent`, `selection`, `muted`, `background`, `dark_background`, `darker_background`, `lighter_background`, `foreground`, `dark_foreground`, `light_foreground`, `bright_foreground`, `red`, `yellow`, `green`, `cyan`, `blue`, `magenta`, `orange`, `brown`, and `bright_` versions of red through magenta. Keep body text readable: `foreground` on `background` at 7:1 contrast or more, `accent` and the colors at 3:1 or more.
2. Download photographs or artwork for the backgrounds. Never draw them with ImageMagick or code: generated scenes come out as blurry blobs. Wallhaven's API searches wallpapers by short tag and needs no key; `categories=100` keeps to general images (no anime), and `+` joins words:

   ```bash
   mkdir -p /tmp/candidates && cd /tmp/candidates
   for q in lantern+night misty+temple paper+lantern; do
     curl -s "https://wallhaven.cc/api/v1/search?q=$q&categories=100&purity=100&atleast=1920x1080&ratios=landscape&sorting=relevance" \
       | jq -r '.data[:4][].path'
   done | while read -r url; do curl -sLO "$url"; done
   ```

   Use one or two words per query, and change the queries until the results fit. Then look at all the candidates at once, with each file's name under it, and pick by eye. Numbers like brightness can't tell a lantern from a cartoon:

   ```bash
   magick montage -font "$(fc-match -f '%{file}' sans)" -label '%f' /tmp/candidates/* -resize 480x270^ -gravity center -extent 480x270 -geometry +4+4 -tile 4x -depth 8 -quality 85 /tmp/candidates.jpg
   ```

   Open `/tmp/candidates.jpg` and look at it (a JPEG, so a sheet of thirty stays small enough to view). Copy the two to four that fit the theme's mood and colors into `backgrounds/` as `1-<name>.jpg`, `2-<name>.jpg`, and so on.
3. Look at the result before calling it done. `omarchy agent look theme ~/.config/omarchy/themes/<slug>` draws the theme as a desktop (the first background, the bar, a terminal and a window in its colors) without applying it, checks the palette's keys and contrast and the backgrounds' size, and prints the image's path. Open the image, fix every problem it lists and any color that clashes with the background, and run it again until it's clean.
4. When done with the theme, run `omarchy theme set "Name of new theme"`.

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
