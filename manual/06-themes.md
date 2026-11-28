# Themes

Omarchy comes with twenty-three beautiful themes. You can select between them via _Appearance > Theme_ in the Omarchy Menu (`Super + Space`) or hop directly to the theme selector using `Super + Ctrl + T`.

Each theme styles the desktop, terminal, neovim, activity screen (btop), your browser (Chrome, Chromium, Edge or Brave), and the entire Omarchy shell: top bar, menu, notifications, OSD, and the lock screen. (For Obsidian, you must manually select the Omarchy theme via _Appearance > Themes_ inside the app).

Themes have a set of background images that you can pick between using `Super + Ctrl + W`.

You can find even more themes on [the extra themes page](https://omarchy.org/themes/) or even [make your own theme](43-making-your-own-theme.md).

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### App icons

The icons in the app launcher and dock are drawn in the colors of your theme, so they change along with it. They come from an icon set, which you pick separately from the theme under _Appearance > Icons_, from previews of each set, the same way you pick a theme:

- _Papercraft_ is the default: everything that comes installed, drawn in one style. Apps known by their logo, like Chrome, HEY, or YouTube, keep its shape and take on the theme's colors.
- _Arcade_ draws the same apps as 8-bit pixel art, like an old game console would.
- _Original_ shows every app with the icon its maker gave it.

You can install an icon set someone else has made with _Install > Style > Icons_ (or `omarchy icons install <git url>`), and remove it again under _Remove > Icons_. _Update > Extra Icons_ fetches the latest version of the sets you have installed.

To make your own, put your icons in `~/.config/omarchy/icons/<name>/`, one file per app, named after the `Icon=` line of the app's `.desktop` file. A file ending in `.svg` is shown as it is. A file ending in `.svg.tpl` is drawn in the theme's colors: write `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` or `{{ icon_shadow }}` where a color goes. The default set in `/usr/share/omarchy/icons/papercraft/` is a good place to start from. Add a `preview.png` to show your set in the picker; without one, Omarchy draws a preview from your icons. To change a single icon of the default set, put your version in `~/.config/omarchy/icons/papercraft/`.

### Boot and login

The screen that asks for your drive password when the computer starts, and the login screen, follow the theme too. Every time you switch themes, they pick up its background, text, accent, and red colors, so there's no separate unlock design to pick. On Apple Silicon Macs, the drive password screen keeps Omarchy's default look whatever the theme.
