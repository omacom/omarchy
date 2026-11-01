# 浏览器

Omarchy 默认自带 [Chromium](https://www.chromium.org/) 作为默认浏览器。它是普通的开源构建，经过主题化以匹配你的系统其他部分，也是 `Super + Shift + Return` 打开的浏览器，也是每个[网页应用](25-web-apps.md)运行的地方。

如果 Chromium 不合你的口味，你也不会被它困住。在 Omarchy 菜单的 _安装 > Browser_ 下，你会找到 Chrome、Edge、Brave、Brave Origin、Firefox 和 [Zen](https://zen-browser.app/)。选择一个，Omarchy 会安装它，设置其策略目录，并将你当前的主题应用到它上面。

## 将某个浏览器设为默认

安装浏览器不会提升它。一旦它在机器上，进入 _Setup > Defaults > Browser_ 并选择它——菜单只列出你实际已安装的浏览器，并用一个勾号标记当前的默认浏览器。

从终端执行是：

```bash
omarchy default browser firefox
```

不带参数运行它，它会告诉你当前的默认浏览器。这设置了 XDG 处理程序，所以不只是 Omarchy 的快捷键会跟随——任何打开链接的东西，从聊天应用到终端命令，都会去到你选择的浏览器。

## 复制 URL 和下载视频

Chromium 家族的浏览器（Chromium 本身、Chrome、Edge 和 Brave）带有两个 Omarchy 扩展，它们能走出浏览器进入你的系统其他部分。

**Copy URL** 用 `Alt + Shift + L` 将当前标签页的地址放到你的剪贴板上。这比点进地址栏并复制要快，而且因为它经过系统剪贴板而非浏览器的剪贴板，你会得到一个 Omarchy 通知确认它，并且该 URL 会立即在[剪贴板历史](08-unified-clipboard-history.md)和每个其他应用中可用。如果你更喜欢点击，也有一个工具栏按钮。

**Download Video** 用 `Alt + Shift + D` 抓取你正在看的页面上播放的视频。它将 URL 交给 [yt-dlp](https://github.com/yt-dlp/yt-dlp)，所以它适用于远不止 YouTube 的站点，下载会落到 `~/Videos` 中。进度会显示在与音量和亮度相同的屏幕显示中，就地更新，而不是堆积通知。如果你想让文件去别处，设置 `OMARCHY_YTDLP_DIR`——有关在哪里放置环境变量，见 [FAQ](46-faq.md)。

这两个扩展都通过一个小型原生消息主机与 Omarchy 通信，它会随浏览器一起为你安装。这是让网页视频最终落到你的主目录、让 URL 最终落到你的剪贴板管理器中的部件，而普通的扩展靠自己是做不到这一点的。

这些仅适用于 Chromium 家族。Firefox 和 Zen 没有它们。

## Firefox 和 Zen

Firefox 和 Zen 是另一个家族，所以它们得到的待遇不同：Omarchy 为合理的默认设置安装一个策略文件，并将它们切换到原生 Wayland 模式，这正是你想要的分数缩放和流畅的触控板滚动。

它们没有上面的 Chromium 扩展，也不会被 Omarchy 主题化，所以这些体验部分需要你自己设置。

## 再次删除某个浏览器

你在这里安装的任何东西都可以在 _移除 > Browser_ 下删除。Chromium 不在该列表中——它是基础系统的一部分。
