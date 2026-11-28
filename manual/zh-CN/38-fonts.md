# 字体

Omarchy 默认将 JetBrainsMono Nerd Font 用作终端字体和系统字体。

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

你可以通过 Omarchy 菜单（`Super + Space`）中的 _外观 > 字体_ 菜单更改此设置。这会设置各处的等宽字体：终端、状态栏，以及任何其他需要它的地方。

你可以通过 Omarchy 菜单中的 _安装 > 风格 > 字体_ 安装其他流行的编程字体：Cascadia Mono、Meslo LG Mono、Fira Code、Victor Code、Bitstream Vera Mono 和 Iosevka 都只需一键即可安装，均为其 Nerd Font 版本，因此状态栏和终端中的字形仍可正常工作。安装其中一款还会将整个系统切换到该字体，你也可以随时在 _外观 > 字体_ 下切换回来。

## 中文、日文和韩文

中文、日文和韩文共享许多汉字，但其中一些汉字的字形画法不同，因此同一个汉字对一位读者来说看起来没问题，对另一位读者来说却显得陌生。在 _设置 > 区域 > 语言_ 下选择其中一种语言，或选择其输入法，即可设置与之匹配的字形。如果你想自行选择，在终端中运行 `omarchy font cjk jp`、`kr`、`sc`、`tc`（台湾）或 `hk`（香港）；`omarchy font cjk default` 则恢复为系统的选择，也就是日文字形。网页或文档中标记了自身语言的文本，以及整个桌面处于这些语言之一时，都会保持该语言的字形。
