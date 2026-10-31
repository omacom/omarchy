# Fonts

Omarchy uses JetBrainsMono Nerd Font as both the terminal and system font by default.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

You can change this through the _Appearance > Font_ menu in the Omarchy menu (`Super + Space`). That sets the monospace **family** everywhere: the terminal, the bar, and anything else that asks for it.

Terminal **size** is per machine, so a laptop and a desktop can share the rest of the config. `omarchy display text size` (and `omarchy font size` for the terminal only) writes overlay files on this computer (`~/.config/ghostty/local`, plus the same idea for Kitty, Foot, and Alacritty). The bar's type scale is `[font] base-size` in `~/.config/omarchy/shell.toml`.

You can install other popular programming fonts via _Install > Style > Font_ in the Omarchy menu: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono, and Iosevka are all one click away, in their Nerd Font versions so the glyphs in the bar and terminal keep working. After installing one, pick it under _Appearance > Font_.

## Chinese, Japanese, and Korean

Chinese, Japanese, and Korean share many characters but draw some of them differently, so the same character looks right to one reader and foreign to another. Picking one of these languages under _Setup > Language_, or its input method, sets the matching forms. To choose them yourself, run `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taiwan), or `hk` (Hong Kong) in a terminal; `omarchy font cjk default` goes back to the system's choice, which is Japanese forms. Text a web page or document marks with its own language, and the whole desktop while it is in one of these languages, keeps that language's forms.
