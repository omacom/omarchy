# 图形界面

## Files

Files（Folio）是图形文件管理器。`Super + Shift + F` 打开它，`Super + Shift + Alt + F` 则在你的终端当前所在的目录中打开它，能省去大量点击。`Ctrl + L` 让你输入路径，在任意文件上按 `Space` 就能以完整尺寸预览，而无需打开它。

插入 U 盘或 SD 卡后，它会自动挂载，直接出现在侧边栏中。如果要做更复杂的操作——格式化驱动器、检查 SMART 健康状态、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

双击遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，Markdown 在 Omawrite 中打开，纯文本则在你的编辑器中打开，默认为 Plain，除非你在 _Setup > Defaults > Editor_ 下选择了其他编辑器。

## Disktree

当驱动器快满了，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示你的主目录的图形化树状图。较大的方块占用更多空间；用键盘或鼠标进入目录，标记要删除的内容，并在删除任何东西之前检查你的选择。运行 `disktree --disk` 可扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，它使用简单的 Markdown 文件进行存储。

Obsidian 可免费用于所有用途，包括个人、商业和非营利用途。

Obsidian 还提供了一个[用于同步的商业附加服务](https://obsidian.md/sync)，可与 iOS 和 Android 上的移动应用同步。(https://obsidian.md/pricing)。

你用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置下选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有库，没有插件，只有你和文字。

你用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础图像编辑工具，非常适合裁剪、调整大小和其他基本操作。别指望它能替代 Photoshop。不过它确实有 Magic Wand 和图层！

你通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，它能从背景图片中提取颜色，并将其转化为一套完整、协调的主题。这是[打造你自己的主题](43-making-your-own-theme.md)最简单的方法。

你通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你能向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop。不过它是跨平台的，所以你可以在 Windows、macOS、Android、iOS 以及当然还有 Linux 之间互传文件。

你可以在 `Super + Ctrl + S` 上打开 Share 菜单，或在 Omarchy 菜单的 _Trigger > Share_ 下打开。它为你提供四个选项：

- **Clipboard** 将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段传到手机上，不用给自己发邮件。
- **File** 打开文件选择器，你可以一次选择多个文件。
- **Folder** 发送整个目录。
- **Receive** 打开 LocalSend 本体，以便其他设备向你发送内容。

同样的功能也可以从终端使用：`omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路径，就会打开选择器。

你也可以直接从文件管理器发送：在 Files 中右键点击任意选中的内容，用 LocalSend 分享它。

Omarchy 的防火墙默认关闭，只有 LocalSend 的端口例外，所以在全新安装后开箱即用。参见[安全](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一套完整的办公套件，包含文字处理、电子表格、演示文稿、绘图应用等等。它与 Microsoft Office 的文件兼容，所以这是打开那些 Word 文档的好方法。

你通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的幻灯片就是一个单独的 Markdown 文件，图片和视频放在它旁边：在实时预览下方编写每一张幻灯片，拖动幻灯片排序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

你通过应用启动器（`Super + Space`）启动 Hype。在其中按 `?` 可查看所有快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写工具。将你保存的签名、文本和今天的日期放在页面上的任意位置，然后在原文件旁边保存一份已签名的副本。如何操作参见[填写 PDF](27-filling-out-pdfs.md)。

你通过应用启动器（`Super + Space`）启动 Signed，或从文件管理器用它打开 PDF。

## Game Vibes

Game Vibes 位于应用启动器（`Super + Space`）中，是 Omarchy 的小游戏所在地：Checkmate，一款与朋友或内置对手对弈的 3D 国际象棋游戏；Cards，Klondike 纸牌接龙；Death Wish，一款像素级精确的平台游戏，有十个布满尖刺和锯子的房间；以及 Neon Swarm，一款街机射击游戏。每款游戏都是一个单独的网页，会跟随你的主题。用方向键和 `Enter` 选择一款游戏，从游戏的标题画面按 `Esc`，或在暂停时按 `Q`，即可返回列表。它会全屏打开：`Super + F` 使其成为窗口，`Super + W` 关闭它。

你用智能体制作的游戏也会出现在这里：在智能体面板中选择 _Make something cool → Game_ 并描述一款游戏，或点名一款已在 Game Vibes 中的游戏以继续完善它。智能体会将其复制到 `~/Games/vibes`，在那里它归你修改，完成时打开它。你也可以用 `omarchy games vibes copy <game>` 自己复制一份。别人分享的游戏安装起来就像主题一样：选择 _Install > Gaming > Game Vibes_ 并粘贴它的 git 地址，或运行 `omarchy games vibes install <git-repo-url>`。_Remove > Gaming_ 可以再次删除一款游戏，_Update > Game Vibes Games_ 则获取新版本。游戏从网络加载 three.js，所以启动时需要联网。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，它会在浮动窗口中打开。

你用 `Super + Shift + Q` 启动 Omacalc（或者计算器键，如果你的键盘上有的话）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不想通过大型科技集团通信的人来说，都是绝佳的通信选择。

你用 `Super + Shift + G` 启动 Signal。它不是基础安装的一部分，所以你第一次按这个快捷键时，Omarchy 会主动提出为你安装它（它也位于 Omarchy 菜单的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：一个窗口就能查看你的照片、视频和音乐。打开一张照片后，方向键可浏览其所在文件夹的其余内容，`N` 和 `P` 可对任何内容执行相同操作，`Ctrl + M` 则将整个文件夹显示为网格。它也能显示 HEIC、AVIF 和 JPEG XL 照片，并能在任何长内容中从上次中断的地方继续。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中修剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移到回收站（按 `Ctrl + Z` 可将其恢复）。在其中按 `?` 可查看所有快捷键。

你通过应用启动器（`Super + Space`）以 _Media Viewer_ 的身份启动 Omaview，或直接在文件管理器中双击图片、视频或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪器。当你只需要剪掉片段的开头和结尾时，它比启动完整的视频编辑器强多了。

你通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录像器。一次性选好你的摄像头和麦克风，然后按 `Space` 录制，再次按下即可暂停并继续同一次录制。它始终以你摄像头的最高分辨率录制，并配有实时麦克风电平表，让你在开始前检查音量。

停止录制后，它会立即在内置编辑器中打开。双击片段可将其拆分，拖动手柄修剪每一部分，并删除你不需要的部分。然后将其保存为 MP4。你的原始录像会保留，直到你丢弃它，所以你随时可以回来以不同的方式剪辑。

你通过应用启动器（`Super + Space`）启动 Monologue。
