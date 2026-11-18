# 图形界面

## 文件

文件 (Nautilus) 是图形化文件管理器。按 `Super + Shift + F` 打开它，按 `Super + Shift + Alt + F` 则会在终端当前所在的目录中打开它，省去大量点击。按 `Ctrl + L` 可以输入路径，在任意文件上按 `Space` 即可快速预览，无需打开任何东西。

插入 U 盘或 SD 卡后会自动挂载，因此它会直接出现在侧边栏中。对于更复杂的操作——格式化驱动器、检查 SMART 健康状况、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

双击会遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，Markdown 在 Omawrite 中打开，纯文本则在 _Setup > Default > Editor_ 下选定的编辑器中打开。

## Disktree

当驱动器被塞满，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示主目录的图形化树图。块越大，占用的空间越多；用键盘或鼠标进入目录，标记要删除的内容，并在删除任何东西之前检查你的选择。运行 `disktree --disk` 可扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件进行存储。

Obsidian 可免费用于所有用途，包括个人、商业和非营利用途。

Obsidian 还提供了一个[用于同步的商业附加组件](https://obsidian.md/sync)，可与 iOS 和 Android 上的移动应用同步。(https://obsidian.md/pricing)。

按 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置中选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有仓库，没有插件，只有你和文字。

按 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础图片编辑工具，非常适合裁剪、调整大小和其他基础操作。就是别指望它能替代 Photoshop。但它照样有魔棒和图层！

通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图片中提取颜色，并将其转化为一套完整、协调的主题。这是[打造你自己的主题](43-making-your-own-theme.md)最简单的方法。

通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你可以向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop。不过它是跨平台的，因此你可以与 Windows、macOS、Android、iOS，以及当然还有 Linux 之间互传文件。

你可以按 `Super + Ctrl + S` 打开 Share 菜单，或在 Omarchy 菜单的 _Trigger > Share_ 下打开。它提供四个选项：

- **Clipboard** 会把你复制的任何内容作为文本文件发送。想把链接或代码片段弄到手机上，又不想给自己发邮件时，它再合适不过了。
- **File** 打开一个文件选择器，你可以一次选择多个文件。
- **Folder** 发送整个目录。
- **Receive** 打开 LocalSend 本体，让其他设备可以向你发送内容。

从终端也能做同样的事，使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路径，就会弹出选择器。

你也可以直接从文件管理器发送：在 Nautilus 中右键点击任意选中的内容，选择 _Send via LocalSend_。

Omarchy 的防火墙默认关闭所有端口，只有 LocalSend 的端口例外，因此在全新安装的系统上，开箱即可使用。参见[安全](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的办公软件包，包含文字处理器、电子表格、演示文稿、绘图应用等。它兼容 Microsoft Office 的文件，因此这是打开那些 Word 文档的绝佳方式。

通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的演示文稿就是一个 Markdown 文件，图片和视频放在它旁边：在实时预览下方编写每一张幻灯片，把幻灯片拖拽排序，然后全屏演示，或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

通过应用启动器（`Super + Space`）启动 Hype。在应用内按 `?` 查看所有快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写工具。把你保存的签名、文本和今天的日期放到页面上的任何位置，然后在原件旁边保存一份已签名的副本。操作方法参见[填写 PDF](27-filling-out-pdfs.md)。

通过应用启动器（`Super + Space`）启动 Signed，或者从文件管理器中用它打开 PDF。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) 是 Omarchy 自家的 3D 国际象棋游戏。在同一台电脑上和朋友对弈，或挑战内置的三个难度等级的对手，使用四套造型精雕细琢、每套都有自己独特走法的棋子：轨道飞行器、雕刻木材与象牙、林地生物和糖果。对局没有计时，每走一步都会保存。

通过应用启动器（`Super + Space`）启动 Checkmate，它在那里列为 Chess。在应用内按 `?` 查看所有快捷键。

## Cards

[Cards](https://github.com/omacom/cards) 是 Omarchy 自家的 Klondike 接龙。每次翻三张牌，过牌轮次不限，有四套牌组系列：一套以你的主题颜色绘制，另外三套各有自己的外观。点击一张牌，再点击它要去的位置，或直接拖拽它，或双击将它送到最佳位置。每走一步都会保存游戏。

通过应用启动器（`Super + Space`）启动 Cards。点击它的名称，或按 `?`，查看所有快捷键。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，会在浮动窗口中打开。

按 `Super + Shift + Q` 启动 Omacalc（如果你的键盘有计算器键，也可以用它）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不想经过科技巨头的人来说，都是绝佳的通讯选择。

按 `Super + Shift + G` 启动 Signal。它不在基础安装中，因此你第一次按下该快捷键时，Omarchy 会主动为你安装它（它也在 Omarchy 菜单的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：一个窗口看完你的照片、视频和音乐。打开一张照片后，用方向键即可浏览所在文件夹中的其他照片，`N` 和 `P` 对任何内容都适用，`Ctrl + M` 则会把整个文件夹以网格形式显示。它还支持显示 HEIC、AVIF 和 JPEG XL 照片，而且对于任何长内容，都能从你上次离开的地方继续。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中裁剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移到回收站（按 `Ctrl + Z` 可将其恢复）。在应用内按 `?` 查看所有快捷键。

通过应用启动器（`Super + Space`）以 _Media Viewer_ 的名称启动 Omaview，或者直接在文件管理器中双击图片、视频或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频裁剪工具。当你只需要剪掉片段的开头和结尾时，用它比启动一整套视频编辑器强多了。

通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简摄像头录制工具。只需选择一次摄像头和麦克风，然后按 `Space` 开始录制，再按一次即可暂停并继续同一段录制。它始终以摄像头的最高分辨率录制，并带有实时麦克风电平表，让你在开始前就能检查音量水平。

结束录制后，它会立即在内置编辑器中打开。双击一个片段将其拆分，拖动手柄裁剪每一部分，并删除你不想要的部分。然后将其保存为 MP4。原始录制文件会一直保留，直到你将其丢弃，因此你随时可以回来换一种剪法。

通过应用启动器（`Super + Space`）启动 Monologue。
