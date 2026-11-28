# 主题

Omarchy 自带二十三款精美的主题。你可以通过 Omarchy Menu（`Super + Space`）中的 _Appearance > Theme_ 在它们之间进行选择，也可以使用 `Super + Ctrl + T` 直接跳转到主题选择器。

每款主题都会为桌面、终端、neovim、活动屏幕（btop）、你的浏览器（Chrome、Chromium、Edge 或 Brave）以及整个 Omarchy shell 设置样式：顶栏、菜单、通知、OSD 和锁屏。（对于 Obsidian，你必须在应用内通过 _Appearance > Themes_ 手动选择 Omarchy 主题）。

每款主题都有一组背景图片，你可以使用 `Super + Ctrl + W` 在它们之间进行选择。

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### 应用图标

应用启动器和程序坞中的图标会以你的主题颜色绘制，因此会随主题一起变化。它们来自一个图标集，你可以在 _Appearance > Icons_ 下与主题分开选择，通过每套图标集的预览来挑选，方式与挑选主题相同：

- _Papercraft_ 是默认选项：所有已安装的应用都以统一风格绘制。像 Chrome、HEY 或 YouTube 这样以其标志为人所知的应用，会保留其形状，并采用主题的颜色。
- _Arcade_ 会将相同的应用绘制为 8 位像素艺术，如同老式游戏机那样。
- _Original_ 会以应用制作者提供的图标显示每个应用。

你可以通过 _Install > Style > Icons_（或 `omarchy icons install <git url>`）安装别人制作的图标集，并再次在 _Remove > Icons_ 下将其移除。_Update > Extra Icons_ 会获取你已安装的图标集的最新版本。

要制作你自己的图标集，请将你的图标放在 `~/.config/omarchy/icons/<name>/` 中，每个应用一个文件，以该应用 `.desktop` 文件的 `Icon=` 行命名。以 `.svg` 结尾的文件会原样显示。以 `.svg.tpl` 结尾的文件会以主题的颜色绘制：在需要填写颜色的位置写入 `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}` 或 `{{ icon_shadow }}`。位于 `/usr/share/omarchy/icons/papercraft/` 的默认图标集是一个很好的起点。添加一个 `preview.png` 即可在选择器中显示你的图标集；如果没有，Omarchy 会根据你的图标绘制一个预览。要更改默认图标集中的单个图标，请将你的版本放在 `~/.config/omarchy/icons/papercraft/` 中。

### 启动与登录

计算机启动时要求输入驱动器密码的屏幕以及登录屏幕，也会跟随主题。每次切换主题时，它们都会采用该主题的背景、文字、强调色和红色，因此无需单独挑选解锁界面设计。在 Apple Silicon Macs 上，无论使用何种主题，驱动器密码屏幕都会保留 Omarchy 的默认外观。
