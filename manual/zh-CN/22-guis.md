# 图形界面

## Files

Files (Nautilus) 是图形文件管理器。`Super + Shift + F` 可以打开它，`Super + Shift + Alt + F` 则会在你的终端当前所在的目录中打开它，这样能省去大量点击。`Ctrl + L` 让你输入路径，在任意文件上按 `Space` 就能快速预览，无需打开任何东西。

插入 U 盘或 SD 卡后会自动挂载，所以它会直接出现在侧边栏中。对于更复杂的操作——格式化驱动器、检查 SMART 健康状况、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

双击遵循合理的默认设置：图片在 imv 中打开，视频在 mpv 中打开，PDF 在 Document Viewer 中打开，纯文本在 Neovim 中打开。

## Disktree

当驱动器满了，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示你的主目录的图形化树状图。块越大，占用空间越多；用键盘或鼠标进入目录，标记要删除的内容，在删除任何东西之前先检查你的选择。运行 `disktree --disk` 可以扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件进行存储。

Obsidian 适用于所有用途，包括个人、商业和非营利用途，全部免费。

Obsidian 还提供[用于同步的商业附加组件](https://obsidian.md/sync)，可与 iOS 和 Android 上的移动应用同步。(https://obsidian.md/pricing)。

你可以用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置下选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有仓库，没有插件，只有你和文字。

你可以用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础的图像编辑工具，非常适合裁剪、调整大小和其他基础操作。别指望它能替代 Photoshop。但它依然有 Magic Wand 和图层！

你可以通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图片中提取颜色，并将其转化为完整、协调一致的主题。这是[打造你自己的主题](43-making-your-own-theme.md)最简单的方法。

你可以通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop。不过它是跨平台的，所以你可以在 Windows、macOS、Android、iOS，当然还有 Linux 之间互发文件。

你可以用 `Super + Ctrl + S` 打开 Share 菜单，或在 Omarchy 菜单的 _Trigger > Share_ 下打开。它为你提供四个选项：

- **Clipboard** 将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段弄到手机上，不用给自己发邮件。
- **File** 打开文件选择器，你可以一次选择多个文件。
- **Folder** 发送整个目录。
- **Receive** 打开 LocalSend 本体，这样其他设备就能向你发送东西。

在终端中也可以用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]` 做同样的事情。省略路径，你就会得到选择器。

你也可以直接从文件管理器发送：在 Nautilus 中右键点击任意选中的内容，选择 _Send via LocalSend_。

Omarchy 的防火墙默认关闭，LocalSend 的端口除外，所以这在全新安装时开箱即用。参见[安全](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包含文字处理、电子表格、演示文稿、绘图应用等等。它兼容 Microsoft Office 的文件，所以这是打开那些 Word 文档的绝佳方式。

你可以通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的幻灯片是一个单独的 Markdown 文件，图片和视频就放在它旁边：在实时预览下方编写每一张幻灯片，拖动幻灯片调整顺序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

你可以通过应用启动器（`Super + Space`）启动 Hype。在里面按 `?` 查看每个快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写工具。把你保存的签名、文本和今天的日期放在页面上的任意位置，然后在原件旁边保存一份已签名的副本。有关操作方法，参见[填写 PDF](27-filling-out-pdfs.md)。

你可以通过应用启动器（`Super + Space`）启动 Signed，或从文件管理器中用它打开 PDF。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，会在浮动窗口中打开。

你可以用 `Super + Shift + Q` 启动 Omacalc（如果你的键盘有计算器键，也可以用那个键）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不想通过大型科技集团的人来说，都是一个绝佳的通信选择。

你可以用 `Super + Shift + G` 启动 Signal。它不属于基础安装的一部分，所以你第一次按下那个组合键时，Omarchy 会主动为你安装它（它也位于 Omarchy 菜单的 _Install > Service_ 下）。

## mpv

[mpv](https://mpv.io/) 是一款简单、快速的媒体播放器，几乎可以播放来自任何来源的任何内容。非常适合看视频。

你可以通过应用启动器（`Super + Space`）启动 mpv，或直接在文件管理器中双击视频。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪工具。当你只需要剪掉片段的开头和结尾时，它比启动一个完整的视频编辑器要好得多。

你可以通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录制工具。选择一次你的摄像头和麦克风，然后按 `Space` 录制，再按一次暂停并继续同一段录制。它始终以你摄像头的最高分辨率录制，并带有实时麦克风电平表，这样你在开始前就可以检查音量。

停止录制后，它会立即在内置编辑器中打开。双击片段将其分割，拖动手柄修剪每一部分，并删除你不想要的部分。然后将其保存为 MP4。你的原始录制会保留，直到你丢弃它，所以你随时可以回来以不同的方式剪辑。

你可以通过应用启动器（`Super + Space`）启动 Monologue。
