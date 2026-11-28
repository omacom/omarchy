# 浏览器

Omarchy 默认自带 [Google Chrome](https://www.google.com/chrome/) 作为默认浏览器。它的主题与系统的其余部分保持一致，`Super + Shift + Return`（或 `Super + Shift + B`）打开的就是它，`Super + Shift + Alt + B` 打开的是它的隐私窗口，所有 [Web 应用](25-web-apps.md) 也都在其中运行。它会直接打开浏览器窗口：没有欢迎界面或登录提示，使用情况统计和崩溃报告不会发送给 Google，广告隐私提示也已关闭。只要你想同步，仍可随时通过个人资料按钮登录你的 Google 账号。

如果 Chrome 不合你的口味，你也不必将就。在 Omarchy 菜单的 _安装 > 浏览器_ 下，你会找到 [Chromium](https://www.chromium.org/)（Chrome 所基于的纯粹开源版本）、Edge、Brave、Brave Origin、Firefox、[Zen](https://zen-browser.app/) 和 [Ladybird](https://ladybird.org/)（Edge 仅限 x86 机器）。选一个，Omarchy 就会安装它、设置它的策略目录，并将你当前的主题应用到它。

## 将某个浏览器设为默认

安装一个浏览器并不会把它提升为默认浏览器。要切换，请前往 _设置 > 默认项 > 浏览器_ 并选择一个。当前默认浏览器会以对勾标记，而选择一个你尚未安装的浏览器会先将它安装好。

在终端中则是：

```bash
omarchy default browser firefox
```

不带参数运行它，它会告诉你当前的默认浏览器。这会设置 XDG 处理程序，所以不只是 Omarchy 的快捷键会随之变化——从聊天应用到终端命令，任何打开链接的操作，都会转到你选择的浏览器。

## 复制 URL 和下载视频

Chromium 家族浏览器（Chromium 本身、Chrome、Edge、Brave 和 Brave Origin）自带三个 Omarchy 扩展：其中两个能从浏览器延伸到系统的其余部分，另一个则负责整理 WhatsApp。

**Copy URL** 可用 `Alt + Shift + L` 将当前标签页的地址放入剪贴板。这比点进地址栏再复制更快，而且由于它走的是系统剪贴板而非浏览器自己的剪贴板，你会收到一条 Omarchy 通知确认此事，该 URL 也会立即出现在[剪贴板历史](08-unified-clipboard-history.md)和所有其他应用中。如果你更喜欢点击，工具栏上也有一个按钮。

**Download Video** 可用 `Alt + Shift + D` 抓取你正在查看的页面上播放的视频。它会将 URL 交给 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以远不止 YouTube 能用，下载的文件会落到 `~/Videos`。进度会显示在音量和亮度所用的同一屏幕显示中，就地更新，而不是堆积通知。如果你想让文件放到别处，可设置 `OMARCHY_YTDLP_DIR`——环境变量应放在哪里，见 [FAQ](46-faq.md)。

这两个扩展都通过一个小型原生消息宿主与 Omarchy 通信，该宿主会随浏览器一起为你安装好。正是这部分让网页上的视频能落到你的主目录、URL 能落到你的剪贴板管理器，而普通扩展单靠自己做不到这些。

**WhatsApp Slim** 让 WhatsApp Web 跟随你的系统主题，并在窗口较窄时折叠其聊天列表。

这些仅限 Chromium 家族。Firefox 和 Zen 无法获得它们。

## Firefox 和 Zen

Firefox 和 Zen 属于另一个家族，所以待遇也不同：Omarchy 会为合理的默认设置安装一个策略文件，并将它们切换到原生 Wayland 模式——这正是实现分数缩放和平滑触控板滚动所需要的。

它们无法获得上面的 Chromium 扩展，也不会由 Omarchy 应用主题，所以体验的那些部分需要你自己设置。

## Ladybird

Ladybird 是一个从零编写的浏览器，拥有自己的引擎，而不是 Chromium 或 Firefox 的引擎。它仍处于 alpha 阶段，所以要有心理准备，有些网站目前还无法正常工作，Omarchy 也会原样安装它：没有扩展，没有主题，没有策略。它也没有隐私窗口，所以 `Super + Shift + Alt + B` 会用一个临时个人资料打开它，该资料会在你关闭时删除。[Web 应用](25-web-apps.md) 会继续在 Chrome 或 Chromium 中运行。

## 再次移除某个浏览器

包括 Chrome 在内的任何这些浏览器，都可在 _移除 > 浏览器_ 下再次卸载。如果 Chrome 或 Chromium 中的另一个仍已安装，链接便会转到它。
