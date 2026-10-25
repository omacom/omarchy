# 截图与录屏

屏幕上能抓取的一切，都挂在 Print Screen 键上。单独按这个键是拍照，用修饰键则可以录屏、取色，或者提取某个区域内的文字。如果你的键盘根本没有 Print Screen 键，`Super + Ctrl + Alt + C` 可以截取同样的截图，`Super + Ctrl + C` 则会以菜单形式打开整套功能。

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | 截图 |
| `Super + Ctrl + Alt + C` | 截图 |
| `Alt + Print Screen` | 录屏（或停止正在运行的录制） |
| `Super + Print Screen` | 取色器 |
| `Super + Ctrl + Print Screen` | 从区域中提取文字 |
| `Super + Ctrl + C` | 捕获菜单 |
| `Super + Ctrl + .` | 转码图片或视频 |

## 截图

按 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 会在它的覆盖层出现之前捕获当前聚焦的显示器，所以你在瞄准时不会有任何东西在你手下移位。拖动一个自由形状的区域，点击一个窗口来捕获它，或者点击空白处捕获整个显示器。在绘制之前按 `S` 可以捕获滚动区域。改主意了？再按一次同一个键即可关闭 Omasnap。

选定区域后，Omasnap 会保存截图、将其复制到剪贴板，并显示一个持续 10 秒的预览。使用预览中的图钉按钮或 `Ctrl + P` 可以让它一直留在屏幕上，或者选择 Edit 进行标注。

标注编辑器可以绘制箭头、线条、形状、高亮、编号标记、文本和安全涂抹遮挡；裁剪或挖掉图像的一部分；对其文字进行 OCR；还可以添加背景。在编辑器中，按 `Enter` 可以复制并保存完成的 PNG，按 `Ctrl + C` 可以只复制而不保存，或者按 `Ctrl + S` 可以只保存而不复制。

默认情况下，保存的截图会落在 `~/Pictures/Screenshots`，文件名类似 `screenshot-2026-08-13_14-22-05-firefox.png`。设置 `OMASNAP_SCREENSHOT_DIR` 可以使用其他目录——有关会话环境变量应该放在哪里，参见[FAQ](46-faq.md)。Omasnap 会在保存第一张截图时创建该目录。在 `~/.config/omasnap/omasnap.conf` 中设置 `[output] autosave = false` 可以禁用自动保存。

在终端中，`omarchy screenshot` 会打开同一个覆盖层，你还可以选择它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二个参数为 `copy` 或 `save` 时，会跳过预览并将截图直接发送到该目标。要在输出前编辑，使用 `omarchy screenshot --editor=overlay` 打开全屏编辑器，或使用 `omarchy screenshot --editor=window` 在单独的窗口中打开。

### 用键盘操控选择器

选择界面打开时，你完全不必使用鼠标：

| Key | Function |
| --- | -------- |
| `S` | 切换滚动区域模式 |
| `Super + Arrow keys` | 在 Window 模式下在窗口之间移动 |
| `Return` | 捕获高亮的窗口 |
| `Ctrl + A` | 捕获整个聚焦的显示器 |
| `R` | 恢复本次会话中上次绘制的区域 |
| `Esc` | 关闭 Omasnap |

这些按键绑定仅在 Omasnap 打开时存在，所以它们不会与你自己的配置中的任何内容冲突。

## 屏幕录制

`Alt + Print Screen` 会打开 _Trigger > Capture > Screenrecord_，它会询问你希望音轨里有什么：无音频、桌面音频、桌面加麦克风，或者桌面加麦克风加摄像头。最后一种只有当你真的插了摄像头时才会出现。选好后，Omarchy 的录制选择器会让你拖动一个区域，或者点击一个窗口或显示器。

录制由 gpu-screen-recorder 驱动，它以 60fps 在 GPU 上编码，必要时回退到 CPU。结果是一个位于 `~/Videos` 的 MP4，名为 `screenrecording-2026-08-13_14-22-05.mp4`。设置 `OMARCHY_SCREENRECORD_DIR` 可以更改这个位置——但请注意，与截图目录不同，这个目录必须已经存在，否则录制会拒绝启动。

录制时，栏中会出现一个小指示器。点击它即可停止。你也可以再次按 `Alt + Print Screen` 停止，或者使用 _Trigger > Capture > Screenrecord_ 下的 _Stop Screenrecording_ 条目，它仅在确实有内容正在录制时才会出现。

停止时，它会先做一点整理再把文件交给你：剪掉第一帧，如果有音频，会将其标准化到 -14 LUFS，并将最开头 PipeWire 捕获的爆音静音。然后会出现一个带有录制缩略图的通知。点击它即可在 mpv 中播放该文件。

### 摄像头覆盖层

当你使用摄像头录制时，摄像头会作为一个固定的、裁剪过的人像窗口出现在你所录制内容的右下角。如果它挡住了你需要的东西，可以即时调整它的大小：

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | 让摄像头覆盖层变小 |
| `Super + Alt + ]` | 让摄像头覆盖层变大 |

有三种尺寸——小、中、大——快捷键可以在它们之间切换。中是默认尺寸。它们与录制内容成比例，所以无论你录制的是 1080p 显示器还是 6K 显示器，摄像头在画面中占据的份额都相同。而且如果你录制的是一个区域而不是整个显示器，覆盖层会锚定到该区域的角落而不是显示器的角落，所以它会一直留在画面内。

你也可以直接用 `omarchy-capture-webcam-resize small` 调用它，或者用 `reset` 回到中。

## 文本、QR 码和颜色

`Super + Ctrl + Print Screen` 会选择一个区域并将其文字 OCR 到剪贴板。这一点在[文本提取与听写](11-text-extraction-dictation.md)中有详细介绍。

_Trigger > Capture > QR Code_ 会对 QR 码做同样的事。选择包含该码的区域，解码后的值就会进入剪贴板。它只查找 QR 码——否则密集的屏幕内容很容易误报为条形码。值得知道的是：解码后的值只会进入剪贴板，不会去其他任何地方。它不会被打印出来，不会出现在通知中，并且会被标记为敏感内容，所以不会留在[剪贴板历史](08-unified-clipboard-history.md)中。QR 码经常携带秘密——比如 2FA 设置码背后的 `otpauth://` URI——你不会希望它出现在日志里。粘贴仍然可以正常工作。

`Super + Print Screen`（或 _Trigger > Capture > Color_）会将光标变成吸管。点击屏幕上的任何东西，颜色就会落在剪贴板上。再次按该快捷键可以在不取色的情况下退出。

## 分享前转码

一段 4K 屏幕录制或手机上的一张原始 HEIC 往往太大，没法直接发送。`Super + Ctrl + .`（或 _Trigger > Transcode_）可以解决这个问题。它会提供一个针对 `~/Pictures` 和 `~/Videos` 的模糊文件选择器，然后询问格式和尺寸。

图片会转成 jpg 或 png 的高、中或低档，宽度上限分别为 3160、2160 和 1080 像素。视频会转成 mp4 或动态 gif 的 4k、1080p 或 720p。转换后的文件会写在原文件旁边，名称中带有分辨率——`demo-1080p.mp4`——并且路径会以文件 URI 的形式复制到剪贴板，所以你可以直接将它粘贴到接受文件拖放的应用中。

如果你已经知道自己想要什么，它也可以在终端中使用：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。还有一个 `omarchy transcode ascii`，它会把图像变成 ASCII 艺术——那个主要用于[品牌塑造](41-branding.md)。

## 把它发送到别处

有了文件之后，`Super + Ctrl + S` 会打开 Share 菜单，并通过 LocalSend 将它发送到你网络上的另一台设备。有关这一点，参见[GUIs](22-guis.md)。
