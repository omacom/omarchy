# 字体

Omarchy 默认使用 JetBrainsMono Nerd Font 作为终端字体和系统字体。

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

你可以通过 Omarchy 菜单（`Super + Space`）中的 _Appearance > Font_ 菜单更改它。这会将等宽字体设置到所有位置：终端、状态栏，以及其他任何需要它的地方。

你可以通过 Omarchy 菜单中的 _Install > Style > Font_ 安装其他流行的编程字体：Cascadia Mono、Meslo LG Mono、Fira Code、Victor Code、Bitstream Vera Mono 和 Iosevka 都只需一次点击即可安装，而且都是它们的 Nerd Font 版本，因此状态栏和终端中的字形图标可以继续工作。安装其中一款后，在 _Appearance > Font_ 下选择它。

## 中文、日文和韩文

中文、日文和韩文共用许多汉字，但其中一些汉字的书写方式不同，因此同一个字符对一位读者来说看起来正确，对另一位读者来说却显得陌生。在 _Setup > Region > Language_ 下选择其中一种语言，或者选择它的输入法，就会设置与之匹配的字形。如果你想亲自选择它们，在终端中运行 `omarchy font cjk jp`、`kr`、`sc`、`tc`（台湾）或 `hk`（香港）；`omarchy font cjk default` 会恢复到系统的选择，也就是日文字形。网页或文档用自身语言标记的文本，以及整个桌面处于这些语言之一时，都会保持该语言的字形。
