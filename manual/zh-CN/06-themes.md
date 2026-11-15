# 主题

Omarchy 自带二十二款精美的主题。你可以通过 Omarchy 菜单（`Super + Space`）中的 _外观 > 主题_ 在它们之间选择，或者使用 `Super + Ctrl + T` 直接跳转到主题选择器。

每款主题都会为桌面、终端、neovim、活动屏幕（btop）、Chromium 以及整个 Omarchy shell 设置样式：顶栏、菜单、通知、OSD 和锁屏。（对于 Obsidian，你必须在应用内通过 _外观 > 主题_ 手动选择 Omarchy 主题）。

每款主题都有一组背景图片，你可以使用 `Super + Ctrl + W` 在它们之间挑选。

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

应用启动器和程序坞中的图标会以你的主题颜色绘制，因此会随主题一起变化。它们来自一套图标集，你可以在 _外观 > 图标_ 下独立于主题进行挑选：

- _Papercraft_ 是默认选项：所有已安装的内容都以同一种风格绘制。像 Chrome、HEY 或 YouTube 这样以其标志为人熟知的应用，会保留其形状，并采用主题的颜色。
- _Arcade_ 会将相同的应用绘制为 8 位像素艺术风格，就像老式游戏机那样。
- _Original_ 会用每个应用的制作者给它的图标来显示它。

你可以使用 _安装 > 样式 > 图标_（或 `omarchy icons install <git url>`）安装别人制作的图标集，并在 _移除 > 图标_ 下再次将其移除。_更新 > 额外图标_ 会获取你已安装的图标集的最新版本。

要制作你自己的图标集，请将你的图标放在 `~/.config/omarchy/icons/<name>/` 中，每个应用一个文件，并以该应用 `.desktop` 文件的 `Icon=` 行来命名。以 `.svg` 结尾的文件会按原样显示。以 `.svg.tpl` 结尾的文件会以主题的颜色绘制：在需要颜色的位置写入 `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}` 或 `{{ icon_shadow }}`。`/usr/share/omarchy/icons/papercraft/` 中的默认图标集是一个很好的起点。要更改默认图标集中的单个图标，请将你的版本放在 `~/.config/omarchy/icons/papercraft/` 中。

### 解锁界面

主题还可以拥有自定义的解锁设计，用于启动解密过程。你可以在 _外观 > 解锁_ 下选择其中之一。它们看起来像这样：

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
