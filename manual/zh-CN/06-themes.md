# 主题

Omarchy 自带二十二个精美的主题。你可以在 Omarchy 菜单（`Super + Space`）里通过 _Appearance > Theme_ 在它们之间选择，或者使用 `Super + Ctrl + T` 直接跳到主题选择器。

每个主题都会为桌面、终端、neovim、活动屏幕（btop）、Chromium 以及整个 Omarchy shell 定制样式：顶部栏、菜单、通知、OSD 和锁屏。（对于 Obsidian，你必须在应用内通过 _Appearance > Themes_ 手动选择 Omarchy 主题）。

主题带有一组背景图片，你可以使用 `Super + Ctrl + W` 在它们之间挑选。

你可以在[更多主题页面](https://omarchy.org/themes/)找到更多主题，甚至可以[制作你自己的主题](43-making-your-own-theme.md)。

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

### 应用图标

应用启动器和 dock 中的图标会以你的主题配色绘制，因此会随主题一起变化。它们来自某个图标集，你可以在 _Appearance > Icons_ 下与主题分开选择，通过每个图标集的预览来挑选，方式和挑选主题一样：

- _Papercraft_ 是默认图标集：所有预装的内容都以同一种风格绘制。像 Chrome、HEY 或 YouTube 这样以其标志为人所知的应用，会保留其形状，并换上主题的配色。
- _Arcade_ 将相同的应用绘制成 8 位像素艺术风格，就像老式游戏机那样。
- _Original_ 以每个应用的制作者为其提供的图标来显示每个应用。

你可以通过 _Install > Style > Icons_（或 `omarchy icons install <git url>`）安装别人制作的图标集，并在 _Remove > Icons_ 下将其再次移除。_Update > Extra Icons_ 会获取你已安装的图标集的最新版本。

要制作你自己的图标集，把你的图标放在 `~/.config/omarchy/icons/<name>/` 中，每个应用一个文件，以该应用的 `.desktop` 文件中的 `Icon=` 行命名。以 `.svg` 结尾的文件会按原样显示。以 `.svg.tpl` 结尾的文件会以主题的配色绘制：在需要填写颜色的位置写上 `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}` 或 `{{ icon_shadow }}`。`/usr/share/omarchy/icons/papercraft/` 中的默认图标集是一个很好的起点。添加一个 `preview.png`，以便在选择器中展示你的图标集；如果没有，Omarchy 会根据你的图标绘制预览。要更改默认图标集中的单个图标，把你的版本放在 `~/.config/omarchy/icons/papercraft/` 中。

### 解锁设计

主题还可以有自定义的解锁设计，用于启动解密过程。你可以在 _Appearance > Unlock_ 下选择其中之一。它们看起来是这样的：

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
