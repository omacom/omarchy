# 图形界面

## Files

Files (Nautilus) 是图形文件管理器。用 `Super + Shift + F` 打开它，用 `Super + Shift + Alt + F` 则会在你的终端当前所在的目录中打开它，能省去大量点击。`Ctrl + L` 让你可以输入路径，在任意文件上按 `Space` 就能快速预览，无需打开任何东西。

插入 USB 闪存盘或 SD 卡后，它会自动挂载，直接显示在侧边栏中。如果要做更复杂的操作——格式化驱动器、检查 SMART 健康状况、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

双击会遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，纯文本在 Neovim 中打开。

## Disktree

当驱动器快满了，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示你主目录的图形化树状图。块越大，占用的空间越多；用键盘或鼠标进入目录，标记要删除的内容，并在删除任何东西之前检查你的选择。运行 `disktree --disk` 可以扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件进行存储。

Obsidian 免费用于所有用途，包括个人、商业和非营利用途。

Obsidian 还提供了一个用于与 iOS 和 Android 上的移动应用同步的[商业附加组件](https://obsidian.md/sync)。(https://obsidian.md/pricing)。

用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置中选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有库，没有插件，只有你和文字。

用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础的图片编辑工具，非常适合裁剪、调整大小和其他基本操作。只是别指望它是 Photoshop 的替代品。但它仍然有 Magic Wand 和图层！

通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图片中提取颜色，并将它们变成一个完整、协调的主题。这是[制作你自己的主题](43-making-your-own-theme.md)最简单的方法。

通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你可以向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop 一样。不过它是跨平台的，所以你可以与 Windows、macOS、Android、iOS，当然还有 Linux 之间互发文件。

你可以用 `Super + Ctrl + S` 打开 Share 菜单，或者在 Omarchy 菜单中选择 _Trigger > Share_。它会给你四个选项：

- **Clipboard** 会将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段传到手机上，不用给自己发电子邮件。
- **File** 会打开文件选择器，你可以一次选择多个文件。
- **Folder** 会发送整个目录。
- **Receive** 会打开 LocalSend 本身，以便其他设备可以向你发送内容。

在终端中也可以做同样的事情，使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路径，就会打开选择器。

你也可以直接从文件管理器发送：在 Nautilus 中右键点击任意选中的内容，然后选择 _Send via LocalSend_。

Omarchy 的防火墙默认处于封闭状态，只有 LocalSend 的端口例外，因此在全新安装后即可开箱即用地使用。参见[安全](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包含文字处理、电子表格、演示文稿、绘图应用等。它与 Microsoft Office 的文件兼容，所以这是打开那些 Word 文档的一个好方法。

通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的幻灯片就是一个单独的 Markdown 文件，图片和视频放在它旁边：在实时预览下方编写每一张幻灯片，拖动幻灯片调整顺序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

通过应用启动器（`Super + Space`）启动 Hype。在里面按 `?` 可以查看所有快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家极简的 PDF 签名和填写工具。将你保存的签名、文字和今天的日期放到页面上的任意位置，然后在原文件旁边保存一份已签名的副本。有关操作方法，请参见[填写 PDF](27-filling-out-pdfs.md)。

通过应用启动器（`Super + Space`）启动 Signed，或者从文件管理器中用它打开 PDF。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，会在浮动窗口中打开。

用 `Super + Shift + Q` 启动 Omacalc（如果你的键盘有计算器键，也可以用那个键）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不想通过大型科技集团通信的人来说，都是一个很好的选择。

用 `Super + Shift + G` 启动 Signal。它不包含在基础安装中，所以你第一次按下这个快捷键时，Omarchy 会主动提出为你安装它（也可以在 Omarchy 菜单的 _Install > Service_ 中找到它）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：一个窗口就能看你的照片、视频和音乐。打开一张照片后，用方向键可以浏览其所在文件夹中的其他内容，`N` 和 `P` 对任何内容都可以这样浏览，`Ctrl + M` 会将整个文件夹显示为网格。它也能显示 HEIC、AVIF 和 JPEG XL 照片，并且对于任何长内容，都能从你上次离开的地方继续。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中裁剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移到废纸篓（按 `Ctrl + Z` 可以将其恢复）。在里面按 `?` 可以查看所有快捷键。

通过应用启动器（`Super + Space`）以 _Media Viewer_ 的名称启动 Omaview，或者直接在文件管理器中双击图片、视频或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频裁剪工具。当你只需要剪掉片段的开头和结尾时，它比启动一个完整的视频编辑器要方便得多。

通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录像工具。只需选择一次摄像头和麦克风，然后按 `Space` 开始录制，再按一次即可暂停并继续同一段录制。它始终以你摄像头的最高分辨率录制，并带有实时麦克风电平表，让你在开始前检查音量。

停止录制后，它会立即在内置编辑器中打开。双击片段可以将其拆分，拖动手柄可以裁剪每一部分，并删除你不想要的部分。然后将其保存为 MP4。你的原始录像会一直保留，直到你将其丢弃，所以你随时可以回来以不同的方式剪辑。

通过应用启动器（`Super + Space`）启动 Monologue。
