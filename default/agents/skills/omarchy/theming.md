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
