# Fonts

Omarchy uses JetBrainsMono Nerd Font as both the terminal and system font by default.

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

You can change this through the _Appearance > Font_ menu in the Omarchy menu (`Super + Space`). That sets the monospace font everywhere: the terminal, the bar, and anything else that asks for it.

You can install other popular programming fonts via _Install > Style > Font_ in the Omarchy menu: Cascadia Mono, Meslo LG Mono, Fira Code, Victor Code, Bitstream Vera Mono, and Iosevka are all one click away, in their Nerd Font versions so the glyphs in the bar and terminal keep working. After installing one, pick it under _Appearance > Font_.

## Terminal font size

The terminal font is 9pt by default. To make only the terminal bigger or smaller, run `omarchy terminal font size 12` (any whole size from 6 to 24), `omarchy terminal font size` to see the current one, and `omarchy terminal font size reset` to go back to 9pt. It changes Alacritty, Ghostty, Kitty, and Foot together and leaves the bar, menus, and apps alone. Running terminals pick it up right away, except Foot, which needs a new window.

To scale text across the whole desktop instead, use `omarchy display text size` (see [Monitors](33-monitors.md)). That sets the terminal too, in proportion with everything else, so run `omarchy terminal font size` after it if you want the terminal to differ.

## Chinese, Japanese, and Korean

Chinese, Japanese, and Korean share many characters but draw some of them differently, so the same character looks right to one reader and foreign to another. Picking one of these languages under _Setup > Language_, or its input method, sets the matching forms. To choose them yourself, run `omarchy font cjk jp`, `kr`, `sc`, `tc` (Taiwan), or `hk` (Hong Kong) in a terminal; `omarchy font cjk default` goes back to the system's choice, which is Japanese forms. Text a web page or document marks with its own language, and the whole desktop while it is in one of these languages, keeps that language's forms.
