# GUIs

## Files

Files (Nautilus) 是图形文件管理器。`Super + Shift + F` 可以打开它，`Super + Shift + Alt + F` 则会在你的终端当前所在的目录中打开它，这样可以省去大量点击。`Ctrl + L` 可以让你输入路径，在任意文件上按 `Space` 即可快速预览，无需打开任何东西。

插入 U 盘或 SD 卡后，它会被自动挂载，所以会直接显示在侧边栏中。对于更复杂的操作——格式化驱动器、检查 SMART 健康状况、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

双击会遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，Markdown 在 Omawrite 中打开，纯文本则在 _Setup > Default > Editor_ 下选定的编辑器中打开。

## Disktree

当驱动器快满了，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示你的主目录的图形矩形树图。方块越大，占用空间越多；用键盘或鼠标进入目录，标记要删除的内容，并在删除任何东西之前检查你的选择。运行 `disktree --disk` 可以扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件进行存储。

Obsidian 对所有用途都是免费的，包括个人、商业和非营利用途。

Obsidian 还提供了一个用于与 iOS 和 Android 上的移动应用同步的[商业附加组件](https://obsidian.md/sync)。(https://obsidian.md/pricing)。

使用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置中选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有笔记库，没有插件，只有你和文字。

使用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础的图像编辑工具，非常适合裁剪、调整大小和其他基础操作。别指望它是 Photoshop 的替代品。不过它还是有魔棒和图层！

通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图片中提取颜色，并将其转化为完整、协调的主题。这是[制作你自己的主题](43-making-your-own-theme.md)最简单的方法。

通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你可以向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop 一样。不过它是跨平台的，所以你可以与 Windows、macOS、Android、iOS，当然还有 Linux 之间互发文件。

你可以按 `Super + Ctrl + S` 打开 Share 菜单，或在 Omarchy 菜单的 _Trigger > Share_ 下打开它。它为你提供四个选项：

- **Clipboard** 会将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段弄到你的手机上，而无需给自己发电子邮件。
- **File** 会打开一个文件选择器，你可以一次选择多个文件。
- **Folder** 会发送整个目录。
- **Receive** 会打开 LocalSend 本体，以便另一台设备可以向你发送内容。

同样的功能也可以从终端使用，使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路径，就会打开选择器。

你也可以直接从文件管理器发送：在 Nautilus 中右键点击任意选中的内容，然后选择 _Send via LocalSend_。

Omarchy 的防火墙默认是封闭的，只有 LocalSend 的端口例外，所以在全新安装后即可开箱即用地使用此功能。参见[安全性](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包含文字处理器、电子表格、演示文稿、绘图应用等。它与 Microsoft Office 的文件兼容，所以这是打开那些 Word 文档的好方法。

通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的演示文稿是一个单独的 Markdown 文件，其图片和视频就放在旁边：在实时预览下方编写每一张幻灯片，将幻灯片拖动排序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

通过应用启动器（`Super + Space`）启动 Hype。在其中按 `?` 可以查看所有快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写方式。将你保存的签名、文本和今天的日期放在页面的任意位置，然后在原文件旁边保存一份已签名的副本。有关操作方法，参见[填写 PDF](27-filling-out-pdfs.md)。

通过应用启动器（`Super + Space`）启动 Signed，或从文件管理器中使用它打开 PDF。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) 是 Omarchy 自家的 3D 国际象棋游戏。与朋友在同一台电脑上对弈，或与三个等级的内置对手对弈，使用四套精心雕刻的棋子，每套都以自己独特的方式移动：轨道飞行器、雕刻木材与象牙、林地生物和糖果。游戏没有时钟，每走一步都会保存。

通过应用启动器（`Super + Space`）启动 Checkmate。在其中按 `?` 可以查看所有快捷键。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，会在浮动窗口中打开。

使用 `Super + Shift + Q` 启动 Omacalc（如果你的键盘上有计算器键，也可以使用该键）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不愿意通过大型科技集团进行沟通的人来说，都是一个绝佳的沟通选择。

使用 `Super + Shift + G` 启动 Signal。它不在基础安装中，所以你第一次按这个快捷键时，Omarchy 会提供为你安装它（它也位于 Omarchy 菜单的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：用一个窗口查看你的照片、视频和音乐。打开一张照片后，方向键可以浏览其所在文件夹中的其他内容，`N` 和 `P` 可以对任何内容执行此操作，`Ctrl + M` 则将整个文件夹显示为网格。它还支持 HEIC、AVIF 和 JPEG XL 照片，并且对于任何长内容，它都会从你上次中断的地方继续。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中修剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移至 Trash（`Ctrl + Z` 可以将其恢复）。在其中按 `?` 可以查看所有快捷键。

通过应用启动器（`Super + Space`）以 _Media Viewer_ 的名称启动 Omaview，或者直接在文件管理器中双击图片、视频或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪器。当你只需要剪掉片段的开头和结尾时，它比启动一个完整的视频编辑器要好得多。

通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录制器。只需选择一次你的摄像头和麦克风，然后按 `Space` 开始录制，再次按下则暂停并继续同一次录制。它始终以你的摄像头的最高分辨率录制，并配有实时麦克风电平表，以便你在开始前检查你的音量。

停止录制后，它会立即在内置编辑器中打开。双击片段可以将其拆分，拖动控制柄可以修剪每一部分，并删除你不需要的部分。然后将其保存为 MP4。你的原始录像会一直保留，直到你将其丢弃，所以你随时可以回来以不同的方式剪辑。

通过应用启动器（`Super + Space`）启动 Monologue。
