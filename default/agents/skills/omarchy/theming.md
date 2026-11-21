# Themes, Backgrounds, and Fonts

Read this before changing themes, backgrounds, fonts, theme colors, app icons, or the boot screen.
Making a new theme follows the omarchy-make-theme skill.

## Theme Commands

```bash
omarchy theme list              # Show available themes
omarchy theme current           # Show current theme
omarchy theme set <name>        # Apply theme ("Tokyo Night" and "tokyo-night" both work)
omarchy theme bg next           # Cycle background
omarchy theme bg set <path>     # Use any image or video as the background
omarchy theme bg intro <enable|disable>  # Background intros
omarchy theme install <url>     # Install from git repo
```

Additional user backgrounds for any theme (stock or custom) go in
`~/.config/omarchy/backgrounds/<theme-slug>/`.

A theme installed from a git repo keeps everything but what runs code: its
`*.lua`, terminal configs, and `vscode.json` are regenerated from its
`colors.toml` instead, and named on stderr.

To change how Omarchy themes an app for every theme, write the template rather
than the theme: `~/.config/omarchy/themed/<config-name>.tpl` overrides the
built-in one. See `docs/theming.md` in the Omarchy repo.

## What a Theme Does Not Control

A theme owns color, plus the extras it may ship (`backgrounds/`, `icons.theme`,
`keyboard.rgb`, `unlock.png`, `light.mode`). It does not own app preferences
like terminal opacity or blur. Those live in the app's base config
(`~/.config/foot/foot.ini`, `~/.config/kitty/kitty.conf`,
`~/.config/ghostty/config`, `~/.config/alacritty/alacritty.toml`) and are
global, so they persist across every theme switch. Setting them there to chase
a themed look leaks a per-theme intent into a machine-wide setting.

To make such a setting follow the current theme, drive it from a `theme-set`
hook instead. The hook gets the theme slug in `$1` — lowercased, spaces turned
into hyphens — so it can write a small file the base config already includes:

```bash
# One-time: create the file, and add under [main] in ~/.config/foot/foot.ini:
#   include=~/.config/foot/theme-alpha.ini
touch ~/.config/foot/theme-alpha.ini

cat >~/.config/omarchy/hooks/theme-set.d/50-foot-alpha <<'EOF'
#!/bin/bash
# Translucent terminal for one theme, solid for the rest.
if [[ $1 == "tokyo-night" ]]; then
  printf '[colors-dark]\nalpha=0.80\nalpha-mode=all\n' >~/.config/foot/theme-alpha.ini
else
  : >~/.config/foot/theme-alpha.ini
fi
EOF
chmod +x ~/.config/omarchy/hooks/theme-set.d/50-foot-alpha
```

Omarchy fires the hook after it activates a theme; see [`hooks.md`](hooks.md).

## Customizing a Stock Theme

Never edit stock themes under `/usr/share/omarchy/themes/` — changes are lost
on update. Two safe options:

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
omarchy font set <name>         # Change the monospace font used everywhere
omarchy font cjk [jp|kr|sc|tc|hk|default]  # Glyph forms for Chinese, Japanese, and Korean text
```

`omarchy font list` shows installed Nerd Fonts; a new one comes from the menu's Install > Style > Font, or `omarchy install font <display-name> <package> <family>`.

## App Icons

Icon sets are chosen apart from themes:

```bash
omarchy icons list
omarchy icons set <name>
omarchy icons install <git-repo-url>
```

## Boot Screen and Branding

```bash
omarchy plymouth set by theme <theme>     # Style the boot and disk-unlock screen from a theme
omarchy plymouth reset                    # Back to Omarchy's own
omarchy branding about <image|text|reset> # The logo shown by About (omarchy launch about)
omarchy branding screensaver <image|text|reset>
```
