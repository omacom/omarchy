# GUI 应用

## Files

Files (Folio) 是图形文件管理器。`Super + Shift + F` 打开它，而 `Super + Shift + Alt + F` 会在你的终端当前所在的目录中打开它，能省去大量点击。`Ctrl + L` 让你输入路径，在任意文件上按 `Space` 即可全尺寸预览，而无需打开它。

插入 U 盘或 SD 卡后，它会被自动挂载，所以会直接出现在侧边栏中。对于更复杂的操作——格式化驱动器、检查 SMART 健康状况、创建分区——请从应用启动器（`Super + Space`）启动 _Disks_。

双击会遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，Markdown 在 Omawrite 中打开，纯文本则在 _Setup > Default > Editor_ 下选定的编辑器中打开。

## Disktree

当驱动器满了，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示你的主目录的图形化树状图。越大的块占用越多空间；用键盘或鼠标深入目录，标记要删除的内容，并在移除任何内容之前检查你的选择。运行 `disktree --disk` 可扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件进行存储。

Obsidian 可免费用于所有用途，包括个人、商业和非营利用途。

Obsidian 还提供[用于同步的商业附加组件](https://obsidian.md/sync)，可与 iOS 和 Android 上的移动应用同步。(https://obsidian.md/pricing)。

你用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置下选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有库，没有插件，只有你和文字。

你用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础图像编辑工具，非常适合裁剪、调整大小和其他基本操作。只是别指望它能替代 Photoshop。但它还是有魔棒和图层！

你通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图片中提取颜色，并将其转化为一套完整、协调的主题。这是[制作你自己的主题](43-making-your-own-theme.md)最简单的方法。

你通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你可以向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop 一样。不过，它是跨平台的，所以你可以与 Windows、macOS、Android、iOS，以及当然还有 Linux 之间互传文件。

你可以用 `Super + Ctrl + S` 打开 Share 菜单，或在 Omarchy 菜单的 _Trigger > Share_ 下打开。它为你提供四个选项：

- **Clipboard** 将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段传到你的手机上，而不必给自己发邮件。
- **File** 打开文件选择器，你可以一次选择多个文件。
- **Folder** 发送整个目录。
- **Receive** 打开 LocalSend 本身，以便其他设备可以向你发送内容。

同样的功能也可以从终端使用：`omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路径，就会打开选择器。

你也可以直接从文件管理器发送：在 Files 中右键点击任意选区，即可通过 LocalSend 分享它。

Omarchy 的防火墙默认关闭，但 LocalSend 的端口除外，所以在全新安装后这开箱即用。请参阅[安全](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包含文字处理器、电子表格、演示文稿、绘图应用等等。它与 Microsoft Office 的文件兼容，所以这是打开那些 Word 文档的好方法。

你通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的幻灯片是一个单独的 Markdown 文件，其图片和视频位于它旁边：在实时预览下方编写每一张幻灯片，将幻灯片拖到合适的位置，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

你通过应用启动器（`Super + Space`）启动 Hype。在里面按 `?` 查看每个快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写方式。将你保存的签名、文本和今天的日期放在页面上的任意位置，然后在原文件旁边保存一份已签名的副本。有关方法，请参阅[填写 PDF](27-filling-out-pdfs.md)。

你通过应用启动器（`Super + Space`）启动 Signed，或者从文件管理器中用它打开 PDF。

## Game Vibes

Game Vibes 位于应用启动器（`Super + Space`）中，是 Omarchy 的小游戏所在地：Checkmate，一款与朋友或内置对手对弈的 3D 国际象棋游戏；Cards，Klondike 接龙；以及 Neon Swarm，一款街机射击游戏。每个游戏都是一个单独的网页，并会跟随你的主题。用方向键和 `Enter` 选择一个游戏，从游戏的标题画面按 `Esc`，或在暂停时按 `Q`，即可返回列表。它会全屏打开：`Super + F` 可将其变为窗口，`Super + W` 可将其关闭。

你用 agent 制作的游戏也会显示在这里：在 agents 面板中选择 _Make something cool → Game_ 并描述一个，或者命名一个已经在 Game Vibes 中的游戏以便继续处理它。agent 会将它复制到 `~/Games/vibes`，在那里你可以自行修改它，并在完成后打开它。你也可以用 `omarchy games vibes copy <game>` 自己进行复制。其他人分享的游戏像主题一样安装：选择 _Install > Gaming > Game Vibes_ 并粘贴其 git 地址，或运行 `omarchy games vibes install <git-repo-url>`。_Remove > Gaming_ 可再次将其移除，_Update > Game Vibes Games_ 可获取新版本。游戏从网络加载 three.js，所以它们需要网络连接才能启动。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，它会在一个浮动窗口中打开。

你用 `Super + Shift + Q` 启动 Omacalc（如果你的键盘有计算器键，也可以用那个键）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不愿通过大型科技集团进行沟通的人来说，都是一个很好的沟通选择。

你用 `Super + Shift + G` 启动 Signal。它不是基础安装的一部分，所以你第一次按这个快捷键时，Omarchy 会提供为你安装它的选项（它也在 Omarchy 菜单的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：一个窗口即可查看你的照片、视频和音乐。打开一张照片后，方向键可浏览其所在文件夹中的其他照片，`N` 和 `P` 可对任何内容执行相同操作，`Ctrl + M` 则将整个文件夹显示为网格。它也能显示 HEIC、AVIF 和 JPEG XL 照片，并能从任何长内容的断点处继续播放。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中修剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移至 Trash（`Ctrl + Z` 可将其恢复）。在里面按 `?` 查看每个快捷键。

你通过应用启动器（`Super + Space`）以 _Media Viewer_ 的身份启动 Omaview，或者只需在文件管理器中双击图片、视频或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪器。当你只需要剪掉片段的开头和结尾时，它胜过启动一个完整的视频编辑器。

你通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简摄像头录制器。选择一次你的摄像头和麦克风，然后按 `Space` 录制，再次按 `Space` 暂停并恢复同一次录制。它始终以你摄像头的最高分辨率录制，并带有实时麦克风电平表，以便你在开始前检查你的音量。

停止录制后，它会立即在内置编辑器中打开。双击片段可将其拆分，拖动手柄可修剪每一部分，并移除你不想要的部分。然后将其保存为 MP4。你的原始录制会保留，直到你将其丢弃，所以你随时可以回来以不同的方式剪辑它。

你通过应用启动器（`Super + Space`）启动 Monologue。
