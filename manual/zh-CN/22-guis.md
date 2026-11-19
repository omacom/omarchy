# GUIs

## Files

Files (Nautilus) 是图形文件管理器。`Super + Shift + F` 打开它，`Super + Shift + Alt + F` 则在你的终端当前所在的目录中打开它，这能省去大量点击。`Ctrl + L` 让你输入路径，在任何文件上按 `Space` 就能快速预览，而无需打开任何东西。

插上 USB 闪存盘或 SD 卡后，它会自动挂载，所以会直接出现在侧边栏中。对于更复杂的操作——格式化驱动器、检查 SMART 健康状况、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

双击遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，Markdown 在 Omawrite 中打开，纯文本则在 _设置 > 默认 > 编辑器_ 下选定的编辑器中打开。

## Disktree

当驱动器满了，而你完全不知道是什么在占用空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会显示你主目录的图形化树状图。较大的块占用更多空间；用键盘或鼠标进入目录，标记要删除的内容，并在删除任何内容之前检查你的选择。运行 `disktree --disk` 可扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件进行存储。

Obsidian 可免费用于所有用途，包括个人、商业和非营利用途。

Obsidian 还提供了一个[用于同步的商业附加组件](https://obsidian.md/sync)，可与 iOS 和 Android 上的移动应用配合使用。(https://obsidian.md/pricing)。

你使用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置下选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有库，没有插件，只有你和文字。

你使用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础图像编辑工具，非常适合裁剪、调整大小和其他基础操作。只是别指望它是 Photoshop 的替代品。但它还是有魔棒和图层！

你通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图像中提取颜色，并将它们变成完整、协调的主题。这是[制作你自己的主题](43-making-your-own-theme.md)最简单的方法。

你通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你可以向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop 一样。不过，它是跨平台的，所以你可以与 Windows、macOS、Android、iOS，当然还有 Linux 之间互传文件。

你可以在 `Super + Ctrl + S` 上打开共享菜单，或者在 Omarchy 菜单的 _触发器 > 共享_ 下打开。它为你提供四个选项：

- **剪贴板**将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段传到你的手机上，而不用给自己发电子邮件。
- **文件**打开文件选择器，你可以在其中一次选择多个文件。
- **文件夹**发送整个目录。
- **接收**打开 LocalSend 本身，以便另一台设备可以向你发送内容。

同样的功能也可以从终端使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]` 实现。省略路径后，你会看到选择器。

你也可以直接从文件管理器发送：在 Nautilus 中右键点击任何选定内容，然后选择 _通过 LocalSend 发送_。

Omarchy 的防火墙默认关闭，但 LocalSend 的端口除外，所以这在全新安装时开箱即用。参见[安全](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包含文字处理、电子表格、演示文稿、绘图应用等。它与 Microsoft Office 的文件兼容，所以这是打开那些 Word 文档的好方法。

你通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的演示文稿是一个单独的 Markdown 文件，其图像和视频放在旁边：在实时预览下方编写每张幻灯片，将幻灯片拖到合适的顺序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

你通过应用启动器（`Super + Space`）启动 Hype。在里面按 `?` 查看每个快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写方式。将你保存的签名、文本和今天的日期放在页面的任何位置，然后在原件旁边保存一份已签名的副本。有关如何操作，参见[填写 PDF](27-filling-out-pdfs.md)。

你通过应用启动器（`Super + Space`）启动 Signed，或者从文件管理器用它打开 PDF。

## Game Vibes

Game Vibes 位于应用启动器（`Super + Space`）中，是 Omarchy 的小游戏所在地：Checkmate，一款与朋友或内置对手对弈的 3D 国际象棋游戏；Cards，Klondike 纸牌接龙；以及 Neon Swarm，一款街机射击游戏。每个游戏都是一个遵循你主题的单个网页。用方向键和 `Enter` 选择一个，从游戏的标题画面按 `Esc` 或在暂停时按 `Q` 返回列表。它以全屏打开：`Super + F` 使其成为窗口，`Super + W` 关闭它。

你用智能体制作的游戏也会出现在这里：在智能体面板中选择 _做点酷的东西 → 游戏_ 并描述一个，或者说出 Game Vibes 中已有的一个游戏名称以继续制作它。智能体会将其复制到 `~/Games/vibes`，在那里它归你更改，并在完成后打开它。你可以使用 `omarchy games vibes copy <game>` 自己制作该副本。别人分享的游戏安装起来就像主题一样：选择 _安装 > 游戏 > Game Vibes_ 并粘贴其 git 地址，或者运行 `omarchy games vibes install <git-repo-url>`。_删除 > 游戏_ 可再次删除一个，_更新 > Game Vibes 游戏_ 可获取新版本。游戏从网络加载 three.js，所以它们需要连接才能启动。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，它在浮动窗口中打开。

你使用 `Super + Shift + Q` 启动 Omacalc（或者计算器键，如果你的键盘有的话）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对于任何不愿意通过大型科技集团公司进行通信的人来说，它是一个出色的通信选择。

你使用 `Super + Shift + G` 启动 Signal。它不是基础安装的一部分，所以你第一次按下该快捷键时，Omarchy 会主动提出为你安装它（它也位于 Omarchy 菜单的 _安装 > 服务_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：一个窗口即可查看你的照片、视频和音乐。打开一张照片后，方向键可浏览其文件夹中的其余照片，`N` 和 `P` 对任何内容都有此功能，`Ctrl + M` 将整个文件夹显示为网格。它还显示 HEIC、AVIF 和 JPEG XL 照片，并会在任何长内容中从你上次离开的地方继续。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中修剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移至回收站（`Ctrl + Z` 可将其恢复）。在里面按 `?` 查看每个快捷键。

你通过应用启动器（`Super + Space`）以 _媒体查看器_ 的身份启动 Omaview，或者直接在文件管理器中双击图片、视频或歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪器。当你只需要剪掉片段的开头和结尾时，它胜过启动一个完整的视频编辑器。

你通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录像机。选择你的摄像头和麦克风一次，然后按 `Space` 录制，再次按下则暂停并继续同一段录制。它始终以你摄像头的最高分辨率录制，并配有实时麦克风电平表，以便你在开始前检查电平。

停止录制后，它会立即在内置编辑器中打开。双击片段将其拆分，拖动手柄修剪每个部分，并删除你不想要的部分。然后将其保存为 MP4。你的原始录像会保留，直到你将其丢弃，所以你随时可以回来以不同的方式剪辑它。

你通过应用启动器（`Super + Space`）启动 Monologue。
