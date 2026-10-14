# GUI

## Files

Files (Nautilus) 是图形文件管理器。`Super + Shift + F` 打开它，`Super + Shift + Alt + F` 则在你的终端当前所在的目录打开它，这省了好多点击。`Ctrl + L` 让你输入路径，在任何文件上按 `Space` 可在不用打开任何东西的情况下快速预览。

插入 U 盘或 SD 卡后，它会被自动挂载，所以它直接就出现在侧边栏中。对于更复杂的事情——格式化驱动器、检查 SMART 健康状况、创建分区——从应用程序启动器（`Super + Space`）启动 _Disks_。

双击遵循合理的默认设置：图片在 imv 中打开，视频在 mpv 中打开，PDF 在 Document Viewer 中打开，纯文本在 Neovim 中打开。

## Disktree

当驱动器快满了而你完全不知道什么在占用空间时，从应用程序启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它显示你主目录的图形树图。较大的块占用更多空间；用键盘或鼠标进入目录，标记应该删除的内容，并在删除任何东西之前检查你的选择。运行 `disktree --disk` 扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用程序，它使用简单的 Markdown 文件进行存储。

Obsidian 对所有用途免费，包括个人、商业和非营利用途。

Obsidian 还提供了一个[用于同步的商业附加功能](https://obsidian.md/sync)，带有 iOS 和 Android 上的移动应用。(https://obsidian.md/pricing)。

你用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置下选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有库，没有插件，只有你和文字。

你用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一个基本的图像编辑工具，非常适合裁剪、调整大小和其他基本操作。只是不要指望它能替代 Photoshop。但它仍有魔棒和图层！

你通过应用程序启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一个主题应用程序，可以从背景图像提取颜色并将它们变成一个完整、协调的主题。这是[制作你自己的主题](43-making-your-own-theme.md)最简单的方法。

你通过应用程序启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你将文件发送到同一网络上运行该应用的其他设备，就像 Apple 的 AirDrop。不过它是跨平台的，所以你可以与 Windows、macOS、Android、iOS，当然还有 Linux 之间互发文件。

你可以在 `Super + Ctrl + S` 或 Omarchy 菜单中的 _Trigger > Share_ 下打开分享菜单。它为你提供四个选项：

- **Clipboard** 将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段弄到手机上，而不用给自己发邮件。
- **File** 打开一个文件选择器，你可以一次选择几个。
- **Folder** 发送整个目录。
- **Receive** 打开 LocalSend 本体，这样另一台设备可以向你发送东西。

从终端用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]` 也能做同样的事情。省略路径，你会得到选择器。

你也可以直接从文件管理器发送：右键点击 Nautilus 中的任何选区并选择 _Send via LocalSend_。

Omarchy 的防火墙默认关闭，仅 LocalSend 的端口例外，所以这在全新安装时开箱即用。见[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包含文字处理、电子表格、演示文稿、绘图应用等等。它与 Microsoft Office 的文件兼容，所以这是打开那些 Word 文档的好方法。

你通过应用程序启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的演示文稿是一个单独的 Markdown 文件，图片和视频放在它旁边：在实时预览下方写每一张幻灯片，拖动幻灯片调整顺序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

你通过应用程序启动器（`Super + Space`）启动 Hype。在其中按 `?` 查看每个快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的签署 PDF 并填写它们的极简方法。将你保存的签名、文本和今天的日期放在页面上的任何地方，然后在原件旁边保存一份已签署的副本。方法见[填写 PDF](27-filling-out-pdfs.md)。

你通过应用程序启动器（`Super + Space`）启动 Signed，或者从文件管理器用它打开 PDF。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，在浮动窗口中打开。

你用 `Super + Ctrl + Q`（或者计算器键，如果你的键盘有的话）启动 Omacalc。

## Signal

[Signal](https://signal.org/) 是端到端加密消息的先驱，对于任何不想通过大型科技集团的人来说，都是一个很好的沟通选择。

你用 `Super + Shift + G` 启动 Signal。它不是基础安装的一部分，所以你第一次按下那个快捷键时，Omarchy 会提议为你安装它（它也在 Omarchy 菜单的 _Install > Service_ 下）。

## mpv

[mpv](https://mpv.io/) 是一个简单、快速的媒体播放器，几乎可以播放来自任何来源的任何内容。非常适合看视频。

你通过应用程序启动器（`Super + Space`）启动 mpv，或者直接在文件管理器中双击视频。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪器。当你只需要剪掉一段视频的开头和结尾时，它比启动完整的视频编辑器要好。

你通过应用程序启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录像机。选择你的摄像头和麦克风一次，然后按 `Space` 开始录制，再按一次暂停和恢复同一段录制。它始终以你的摄像头的最高分辨率录制，并带有一个实时麦克风电平表，这样你可以在开始之前检查你的电平。

停止录制后，它会立即在内置编辑器中打开。双击剪辑可将其拆分，拖动手柄修剪每个片段，并删除你不需要的部分。然后将其保存为 MP4。你的原始录像会被保留，直到你放弃它，所以你随时可以回来以不同的方式剪辑它。

你通过应用程序启动器（`Super + Space`）启动 Monologue。
