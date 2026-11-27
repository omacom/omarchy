# GUI 应用

## Files

Files（Folio）是图形文件管理器。`Super + Shift + F` 打开它，`Super + Shift + Alt + F` 会打开你终端当前所在的目录，这样能少点很多次鼠标。`Ctrl + L` 让你输入路径，对任意文件按 `Space` 就能全尺寸预览，而不用真正打开它。

插入 U 盘或 SD 卡后，它会自动挂载，直接出现在侧边栏中。要做更进阶的操作——格式化驱动器、检查 SMART 健康状况、创建分区——从应用启动器（`Super + Space`）启动 _Disks_。

加密驱动器在插入时会询问密码。要让某个驱动器自己解锁，用 `sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` 为它添加一个密钥文件，并把那个密钥文件放在 `~/.config/omarchy/drive-keys/<UUID>`，文件名用 `lsblk -dno UUID /dev/sdX1` 为加密分区打印的 UUID，并确保只有你能读取（`chmod 600`）。如果那个密钥文件缺失或被拒绝，系统会照常向你询问密码。

双击会遵循合理的默认设置：图片、视频和音乐在 Omaview 中打开，PDF 在 Document Viewer 中打开，Markdown 在 Omawrite 中打开，纯文本在你的编辑器中打开，默认是 Plain，除非你在 _Setup > Defaults > Editor_ 下选择了其他编辑器。

## Disktree

当驱动器满了，而你完全不知道什么在吃掉空间时，从应用启动器（`Super + Space`）启动 [Disktree](https://github.com/tobi/disktree)。它会以图形树图显示你的主目录。块越大，占用的空间越多；用键盘或鼠标进入目录，标记要删除的内容，并在删除任何东西之前检查你的选择。运行 `disktree --disk` 可扫描整个磁盘。

## Obsidian

[Obsidian](https://obsidian.md/) 是一款免费且高度可扩展的笔记应用，使用简单的 Markdown 文件来存储。

Obsidian 适用于所有用途，包括个人、商业和非营利使用，都是免费的。

Obsidian 还提供[用于同步的商业附加组件](https://obsidian.md/sync)，可与 iOS 和 Android 上的移动应用同步。(https://obsidian.md/pricing)。

用 `Super + Shift + O` 启动 Obsidian。要使用主题同步，你必须在设置下选择 `Omarchy` 主题。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) 是 Omarchy 自家的极简 Markdown 写作应用。没有库，没有插件，只有你和文字。

用 `Super + Shift + W` 启动 Omawrite。

## Pinta

[Pinta](https://www.pinta-project.com/) 是一款基础图片编辑工具，非常适合裁剪、调整大小和其他基础处理。别指望它是 Photoshop 的替代品。但它还是有魔棒和图层！

通过应用启动器（`Super + Space`）启动 Pinta。

## Aether

[Aether](https://github.com/bjarneo/aether) 是一款主题应用，可以从背景图片中提取颜色，并将其转化为一套完整、协调的主题。这是[制作你自己的主题](43-making-your-own-theme.md)最简单的方法。

通过应用启动器（`Super + Space`）启动 Aether。

## LocalSend

[LocalSend](https://localsend.org/) 让你可以向同一网络上运行该应用的其他设备发送文件，就像 Apple 的 AirDrop。它是跨平台的，所以你可以与 Windows、macOS、Android、iOS，以及当然还有 Linux 之间互传文件。

你可以用 `Super + Ctrl + S` 打开分享菜单，或在 Omarchy 菜单的 _Trigger > Share_ 下打开。它会给你四个选项：

- **Clipboard** 将你复制的任何内容作为文本文件发送。非常适合把链接或代码片段传到手机上，不用给自己发邮件。
- **File** 打开一个文件选择器，你可以一次选择多个文件。
- **Folder** 发送整个目录。
- **Receive** 打开 LocalSend 本体，这样其他设备就能向你发送东西。

在终端中也能做同样的事，使用 `omarchy share clipboard`、`omarchy share file [path]` 和 `omarchy share folder [path]`。省略路径，就会打开选择器。

你也可以直接从文件管理器发送：在 Files 中右键点击任意选中的内容，用 LocalSend 分享它。

Omarchy 的防火墙默认关闭，只开放了 LocalSend 的端口，所以这在全新安装上开箱即用。参见 [security](48-security.md)。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) 是一个完整的办公套件，包括文字处理、电子表格、演示文稿、绘图应用等等。它兼容 Microsoft Office 的文件，所以这是打开那些 Word 文档的好方法。

通过应用启动器（`Super + Space`）启动 LibreOffice。

## Hype

[Hype](https://github.com/omacom/hype) 是 Omarchy 自家的极简演示应用。你的演示文稿是一个单独的 Markdown 文件，图片和视频放在它旁边：在实时预览下方编写每一张幻灯片，把幻灯片拖拽排列顺序，然后全屏演示或导出为 PDF 和 PowerPoint。它甚至会采用你的 Omarchy 主题。

通过应用启动器（`Super + Space`）启动 Hype。在里面按 `?` 查看每个快捷键。

## Signed

[Signed](https://github.com/omacom/signed) 是 Omarchy 自家的极简 PDF 签名和填写工具。把你保存的签名、文本和今天的日期放在页面上的任意位置，然后在原文件旁边保存一份签名后的副本。操作方法参见 [Filling out PDFs](27-filling-out-pdfs.md)。

通过应用启动器（`Super + Space`）启动 Signed，或从文件管理器用它打开一个 PDF。

## Game Vibes

Game Vibes 位于应用启动器（`Super + Space`）中，是 Omarchy 小游戏的家：Checkmate，一款与朋友或内置对手对弈的 3D 国际象棋游戏；Cards，Klondike 纸牌；Death Wish，一款像素精确的平台游戏，有十个满是尖刺和锯子的房间；以及 Neon Swarm，一款街机射击游戏。每一个都是一个单独的网页，并会遵循你的主题。用方向键和 `Enter` 选择一个，从游戏的标题画面按 `Esc` 或在暂停时按 `Q` 返回列表。它会全屏打开：`Super + F` 让它变成窗口，`Super + W` 关闭它。

你用智能体制作的游戏也会出现在这里：在智能体面板中选择 _Make something cool → Game_ 并描述一个，或说出一个已经在 Game Vibes 中的游戏名称来继续完善它。智能体会把它复制到 `~/Games/vibes`，在那里它归你修改，完成时打开它。你可以自己用 `omarchy games vibes copy <game>` 进行复制。别人分享的游戏安装起来像主题一样：选择 _Install > Gaming > Game Vibes_ 并粘贴它的 git 地址，或运行 `omarchy games vibes install <git-repo-url>`。_Remove > Gaming_ 可以再次删除一个，_Update > Game Vibes Games_ 则获取新版本。游戏从网络加载 three.js，所以它们需要网络连接才能启动。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) 是 Omarchy 自家的极简计算器，会在浮动窗口中打开。

用 `Super + Shift + Q` 启动 Omacalc（如果你的键盘有计算器键，也可以用它）。

## Signal

[Signal](https://signal.org/) 是 E2E 加密消息的先驱，对任何不想通过大型科技集团的人来说，都是一个绝佳的通讯选择。

用 `Super + Shift + G` 启动 Signal。它不在基础安装中，所以你第一次按那个快捷键时，Omarchy 会提议为你安装它（它也在 Omarchy 菜单的 _Install > Service_ 下）。

## Omaview

[Omaview](https://github.com/omacom/omaview) 是 Omarchy 自家的极简图片查看器和媒体播放器：一个窗口看你的照片、视频和音乐。打开一张照片后，用方向键可以浏览其文件夹中的其他内容，`N` 和 `P` 对任何内容都能这么做，`Ctrl + M` 会把整个文件夹显示为网格。它也能显示 HEIC、AVIF 和 JPEG XL 照片，并能在长内容中从你上次停下的地方继续。

按 `F` 全屏，按 `E` 在 Omasnap 中编辑图片或在 Omacut 中修剪视频，按 `Ctrl + P` 打印图片，按 `Delete` 将文件移到回收站（`Ctrl + Z` 将其恢复）。在里面按 `?` 查看每个快捷键。

通过应用启动器（`Super + Space`）以 _Media Viewer_ 启动 Omaview，或直接在文件管理器中双击一张图片、一段视频或一首歌曲。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) 是 Omarchy 自家的极简视频修剪工具。当你需要做的只是剪掉片段的开头和结尾时，它比启动一个完整的视频编辑器要好得多。

通过应用启动器（`Super + Space`）启动 Omacut。

## Monologue

[Monologue](https://github.com/omacom/monologue) 是 Omarchy 自家的极简网络摄像头录制工具。只需选择一次你的摄像头和麦克风，然后按 `Space` 开始录制，再次按下则暂停和恢复同一次录制。它始终以你摄像头的最高分辨率录制，并配有实时麦克风电平表，让你在开始前检查音量。

停止录制后，它会立即在内置编辑器中打开。双击一个片段将其拆分，拖动手柄修剪每一部分，并删除你不需要的部分。然后将其保存为 MP4。你的原始录制会保留，直到你丢弃它，所以你随时可以回来换一种方式剪辑。

通过应用启动器（`Super + Space`）启动 Monologue。
