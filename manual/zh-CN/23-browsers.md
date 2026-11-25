# 浏览器

Omarchy 默认自带 [Google Chrome](https://www.google.com/chrome/) 作为默认浏览器。它已适配主题，与系统的其余部分保持一致，`Super + Shift + Return`（或 `Super + Shift + B`）打开的就是它，`Super + Shift + Alt + B` 则打开隐私窗口，所有 [网页应用](25-web-apps.md) 也都在它里面运行。它会直接打开浏览器窗口：没有欢迎界面或登录提示，不会向 Google 发送使用情况统计和崩溃报告，广告隐私提示也已关闭。只要你想同步，随时仍可通过个人资料按钮登录你的 Google 账户。

如果 Chrome 不合你的口味，你也不必被它绑住。在 Omarchy 菜单的 _安装 > 浏览器_ 下，你会找到 [Chromium](https://www.chromium.org/)（构建 Chrome 所基于的纯净开源版本）、Edge、Brave、Brave Origin、Firefox 和 [Zen](https://zen-browser.app/)（Edge 仅适用于 x86 机器）。选一个，Omarchy 就会安装它、设置好它的策略目录，并将你当前的主题应用到它上。

## 将某个浏览器设为默认

安装浏览器并不会把它提升为默认浏览器。要切换，请前往 _设置 > 默认应用 > 浏览器_ 并选择一个。当前默认浏览器会以对勾标记，选择一个你尚未安装的浏览器会先安装它。

在终端中运行：

```bash
omarchy default browser firefox
```

不带参数运行它，它会告诉你当前的默认浏览器。这会设置 XDG 处理程序，所以不只是 Omarchy 的快捷键会跟着变——从聊天应用到终端命令，任何打开链接的操作都会前往你选择的浏览器。

## Copy URL 和 Download Video

Chromium 家族浏览器（Chromium 本身、Chrome、Edge、Brave 和 Brave Origin）附带三个 Omarchy 扩展：其中两个能突破浏览器、联动到你系统的其余部分，还有一个负责优化 WhatsApp。

**Copy URL** 通过 `Alt + Shift + L` 将当前标签页的地址放到你的剪贴板上。这比点进地址栏再复制更快，而且因为它经由系统剪贴板而非浏览器的剪贴板，你会收到一条 Omarchy 通知确认操作，URL 也会立即出现在 [统一剪贴板历史](08-unified-clipboard-history.md) 和其他每个应用中。如果你更喜欢点击，工具栏上也有一个按钮。

**Download Video** 通过 `Alt + Shift + D` 抓取你正在查看的页面上播放的视频。它将 URL 交给 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以它远不止适用于 YouTube，下载内容会落到 `~/Videos` 中。进度会显示在与音量和亮度相同的屏幕显示中，就地更新，而不是堆积通知。如果你想让文件放到别处，请设置 `OMARCHY_YTDLP_DIR`——环境变量应放在何处请参阅 [FAQ](46-faq.md)。

这两个扩展都通过一个小型原生消息传递宿主与 Omarchy 通信，该宿主会随浏览器一同为你安装。正是这个组件，让网页上的视频最终能进入你的主目录，让 URL 能进入你的剪贴板管理器，而这正是普通扩展单独无法做到的。

**WhatsApp Slim** 让 WhatsApp Web 跟随你的系统主题，并在窗口较窄时折叠其聊天列表。

这些仅适用于 Chromium 家族。Firefox 和 Zen 无法获得它们。

## Firefox 和 Zen

Firefox 和 Zen 属于不同的家族，因此处理方式也不同：Omarchy 会为它们安装一个策略文件以设定合理的默认设置，并将它们切换到原生 Wayland 模式，这正是你在分数缩放和平滑触控板滚动时所需要的。

它们无法获得上述 Chromium 扩展，也不会由 Omarchy 进行主题适配，所以体验的那些部分需要你自己设置。

## 再次移除某个浏览器

这些浏览器中的任意一个，包括 Chrome，都可以在 _移除 > 浏览器_ 下卸载。如果另一个浏览器仍已安装，链接随后会前往 Chrome 或 Chromium。
