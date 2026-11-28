# 截图与录屏

屏幕上能抓取的一切都挂在 Print Screen 键上。单独按这个键是拍照，加上修饰键则可以录屏、取色，或提取区域内的文字。如果你的键盘根本没有 Print Screen 键，`Super + Ctrl + Alt + C` 可以拍出同样的截图，`Super + Ctrl + C` 则会以菜单形式打开整套功能。

| 快捷键 | 功能 |
| ------ | -------- |
| `Print Screen` | 截图 |
| `Super + Ctrl + Alt + C` | 截图 |
| `Alt + Print Screen` | 录屏（或停止正在运行的录制） |
| `Super + Print Screen` | 取色器 |
| `Super + Ctrl + Print Screen` | 从区域中提取文字 |
| `Super + Ctrl + C` | 捕获菜单 |
| `Super + Ctrl + .` | 转码图片或视频 |

## 截图

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 会在它的覆盖层出现之前捕获聚焦的显示器，所以你瞄准时画面不会在你手下移位。拖出一个自由形状的区域，点击一个窗口来捕获它，或点击空白处来捕获整个显示器。在绘制之前按 `S`，可以捕获滚动区域。改主意了？再按一次同一个键即可关闭 Omasnap。

选择区域后，Omasnap 会保存捕获内容，将其复制到剪贴板，并显示一条带缩略图的通知，就像保存好的屏幕录制那样。选择 Open 可以在图片查看器中查看保存的截图，或选择 Edit 对其进行标注。

标注编辑器可以绘制箭头、线条、形状、高亮、编号标记、文字和安全打码；裁剪或挖去图片的一部分；OCR 识别其中的文字；以及添加背景。在编辑器中，按 `Enter` 复制并保存完成的 PNG，按 `Ctrl + C` 只复制不保存，或按 `Ctrl + S` 只保存不复制。

保存的截图默认落在 `~/Pictures/Screenshots`，名称如 `screenshot-2026-08-13_14-22-05-firefox.png`。设置 `OMASNAP_SCREENSHOT_DIR` 可以使用其他目录——有关会话环境变量应放在哪里，请参阅[常见问题](46-faq.md)。Omasnap 会在保存第一张截图时创建该目录。在 `~/.config/omasnap/omasnap.conf` 中设置 `[output] autosave = false` 可以禁用自动保存；此后捕获内容只会被复制，并在一个预览中显示 7 秒，你可以用它的固定按钮或 `Ctrl + P` 让它一直留在屏幕上。

在终端中，`omarchy screenshot` 会打开同一个覆盖层，你还可以选择它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二个参数为 `copy` 或 `save` 时，会把截图直接发送到那个目的地。要在输出前编辑，请使用 `omarchy screenshot --editor=overlay` 打开全屏编辑器，或使用 `omarchy screenshot --editor=window` 打开一个单独的窗口。

### 用键盘操控选择器

选择界面打开时，你完全不必使用鼠标：

| 键 | 功能 |
| --- | -------- |
| `S` | 切换滚动区域模式 |
| `Super + Arrow keys` | 在 Window 模式下在窗口之间移动 |
| `Return` | 捕获高亮的窗口 |
| `Ctrl + A` | 捕获整个聚焦的显示器 |
| `R` | 恢复本次会话中上次绘制的区域 |
| `Esc` | 关闭 Omasnap |

这些绑定只在 Omasnap 打开时存在，所以它们不会与你自己配置中的任何内容冲突。

## 屏幕录制

`Alt + Print Screen` 会打开 _Trigger > Capture > Screenrecord_，它会询问你希望音轨里有什么：无音频、桌面音频、桌面加麦克风，或桌面加麦克风加摄像头。最后一项只有在你确实插了摄像头时才会出现。选好一项后，Omarchy 的录制选择器会让你拖出一个区域，或点击一个窗口或显示器。

录制在 gpu-screen-recorder 上运行，它以 60fps 在 GPU 上编码，必要时回退到 CPU；在它不支持的 GPU 上，例如 Apple Silicon 的，Omarchy 改用 wf-recorder 录制。结果是一个位于 `~/Videos` 的 MP4，名为 `screenrecording-2026-08-13_14-22-05.mp4`。设置 `OMARCHY_SCREENRECORD_DIR` 可以更改这一点——但请注意，与截图目录不同，这个目录必须已经存在，否则录制会拒绝启动。

录制时，栏中会出现一个小指示器。点击它即可停止。你也可以再次按 `Alt + Print Screen` 停止，或使用 _Trigger > Capture > Screenrecord_ 下的 _Stop Screenrecording_ 条目停止，它只在确实有内容正在录制时才会出现。

停止时，它会在把文件交给你之前做一点整理：第一帧会被修剪掉，如果有音频，它会被标准化到 -14 LUFS，并且 PipeWire 在最开始捕获到的爆音会被静音。然后会出现一条带录制缩略图的通知。选择 _Open_ 可以在 Omaview 中播放该文件，或选择 _Cut_ 在 Omacut 中修剪它。

### 摄像头覆盖层

当你用摄像头录制时，摄像头会以一个固定的、裁剪过的人像窗口出现在你正在录制的任何内容的右下角。如果它正挡在你需要的东西上面，可以即时调整它的大小：

| 快捷键 | 功能 |
| ------ | -------- |
| `Super + Alt + [` | 让摄像头覆盖层变小 |
| `Super + Alt + ]` | 让摄像头覆盖层变大 |

共有三种尺寸——小、中、大——快捷键可以在它们之间步进。中是默认尺寸。它们与录制内容成比例，所以无论你录制的是 1080p 显示器还是 6K 显示器，摄像头在画面中占的份额都相同。而且如果你录制的是一个区域而不是整个显示屏，覆盖层会锚定到那个区域的角落而不是显示器的角落，所以它会一直留在画面内。

你也可以用 `omarchy-capture-webcam-resize small` 直接调用它，或用 `reset` 回到中尺寸。

## 文字、QR 码和颜色

`Super + Ctrl + Print Screen` 会选择一个区域并通过 OCR 将其识别到剪贴板。这一点在[文本提取与听写](11-text-extraction-dictation.md)中有完整介绍。

_Trigger > Capture > QR Code_ 对 QR 码做同样的事。选择包含该码的区域，解码后的值就会进入剪贴板。它只查找 QR 码——否则密集的屏幕内容很容易误报为条形码。值得知道的是：解码后的值只会进入剪贴板，不去其他任何地方。它不会被打印出来，不会出现在通知中，并且会被标记为敏感内容，所以不会留在[剪贴板历史](08-unified-clipboard-history.md)中。QR 码经常携带秘密——例如 2FA 设置码背后的 `otpauth://` URI——你不会希望它出现在日志里。粘贴仍然可以正常工作。

`Super + Print Screen`（或 _Trigger > Capture > Color_）会把光标变成吸管。点击屏幕上的任何东西，颜色就会落在剪贴板上。再次按该快捷键可以在不取色的情况下退出。

## 分享前转码

4K 屏幕录制或手机上的一张原始 HEIC 往往太大了，没法直接发送。`Super + Ctrl + .`（或 _Trigger > Transcode_）可以解决这个问题。它会为你提供一个覆盖 `~/Pictures` 和 `~/Videos` 的模糊文件选择器，然后询问格式和尺寸。

图片会转为 jpg 或 png，可选高、中、低，它们会把宽度上限分别设为 3160、2160 和 1080 像素。视频会转为 mp4 或动态 gif，可选 4k、1080p 或 720p。转换后的文件会写在原文件旁边，名称中带有分辨率——`demo-1080p.mp4`——并且路径会以文件 URI 的形式复制到剪贴板，所以你可以把它直接粘贴到接受文件拖放的应用中。

如果你已经知道自己想要什么，它也可以在终端中工作：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。还有一个 `omarchy transcode ascii`，它会把图片转成 ASCII 艺术——那个主要用于[品牌](41-branding.md)。

## 把它发送到某处

拿到文件后，`Super + Ctrl + S` 会打开 Share 菜单，并通过 LocalSend 把它发送到你网络上的另一台设备。有关这一点，请参阅 [GUIs](22-guis.md)。
