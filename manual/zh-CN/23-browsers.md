# 浏览器

Omarchy 默认自带 [Google Chrome](https://www.google.com/chrome/) 作为默认浏览器。它的主题与你系统的其他部分保持一致，`Super + Shift + Return` 打开的就是它，每个[网页应用](25-web-apps.md)也都在它里面运行。它会直接打开浏览器窗口：没有欢迎界面或登录提示，不会向 Google 发送使用情况统计数据和崩溃报告，广告隐私提示也已关闭。只要你想同步，仍然可以随时通过个人资料按钮登录你的 Google 账户。

如果 Chrome 不合你的口味，你也不必被它绑住。在 Omarchy 菜单的 _Install > Browser_ 下，你会找到 [Chromium](https://www.chromium.org/)（构建 Chrome 所用的纯粹开源版本）、Edge、Brave、Brave Origin、Firefox 和 [Zen](https://zen-browser.app/)。选一个，Omarchy 就会为你安装它，设置它的策略目录，并将你当前的主题应用到它上面。

## 将某个浏览器设为默认浏览器

安装浏览器并不会把它提升为默认浏览器。等它装到机器上后，进入 _Setup > Defaults > Browser_ 并选择它——菜单只会列出你实际已安装的浏览器，并用对勾标记当前默认浏览器。

在终端里则是：

```bash
omarchy default browser firefox
```

不带任何参数运行它，它会告诉你当前的默认浏览器。这会设置 XDG 处理程序，所以跟随变化的不只是 Omarchy 的快捷键——从聊天应用到终端命令，任何打开链接的操作都会前往你选定的浏览器。

## Copy URL 和 Download Video

Chromium 家族的浏览器（Chromium 本身、Chrome、Edge 和 Brave）自带两个 Omarchy 扩展，它们能跳出浏览器，深入你系统的其他部分。

**Copy URL** 通过 `Alt + Shift + L` 将当前标签页的地址放到你的剪贴板上。这比点击进入地址栏再复制更快，而且由于它走的是系统剪贴板而非浏览器自己的剪贴板，你会收到 Omarchy 的确认通知，该 URL 也会立即出现在[剪贴板历史](08-unified-clipboard-history.md)和所有其他应用中。如果你更喜欢点击，工具栏上也有按钮。

**Download Video** 通过 `Alt + Shift + D` 抓取你正在看的页面上播放的视频。它将 URL 交给 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以它远不止适用于 YouTube，下载的文件会落到 `~/Videos` 中。进度会显示在音量和亮度所使用的同一个屏幕显示中，就地更新，而不是堆积通知。如果你更希望文件去其他地方，请设置 `OMARCHY_YTDLP_DIR`——有关在哪里设置环境变量，请参阅 [FAQ](46-faq.md)。

这两个扩展都通过一个小型原生消息传递主机与 Omarchy 通信，该主机在安装浏览器时一并为你安装。正是这个组件，让网页的视频能最终进入你的主目录，让 URL 能进入你的剪贴板管理器，而这是普通扩展单靠自己做不到的。

这些仅适用于 Chromium 家族。Firefox 和 Zen 没有这些扩展。

## Firefox 和 Zen

Firefox 和 Zen 属于另一个家族，所以它们会得到不同的处理：Omarchy 会为它们安装一个包含合理默认设置的策略文件，并将它们切换到原生 Wayland 模式，这是获得分数缩放和平滑触控板滚动所需要的。

它们没有上面的 Chromium 扩展，也不会由 Omarchy 进行主题化，所以这些部分的体验由你自己来设置。

## 再次移除某个浏览器

这些浏览器中的任何一个，包括 Chrome，都可以在 _Remove > Browser_ 下移除。如果另一个还安装着，链接之后会前往 Chrome 或 Chromium。
