# 截图与录屏

你能从屏幕上抓取的一切，都挂在 Print Screen 键上。单独按这一个键是截图，配合修饰键则可以录屏、取色，或提取某个区域内的文字。如果你的键盘根本没有 Print Screen 键，`Super + Ctrl + Alt + C` 可以截取同样的截图，`Super + Ctrl + C` 则会以菜单形式打开整套功能。

| 快捷键 | 功能 |
| ------ | -------- |
| `Print Screen` | 截图 |
| `Super + Ctrl + Alt + C` | 截图 |
| `Alt + Print Screen` | 录屏（或停止正在进行的录制） |
| `Super + Print Screen` | 取色器 |
| `Super + Ctrl + Print Screen` | 从区域中提取文字 |
| `Super + Ctrl + C` | 捕获菜单 |
| `Super + Ctrl + .` | 转码图片或视频 |

## 截图

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 会在其覆盖层出现之前就捕获当前聚焦的显示器，因此你瞄准时画面不会有任何移位。拖拽出一个自由形状的区域、点击某个窗口将其捕获，或点击空白处捕获整个显示器。在开始绘制前按 `S`，可以捕获滚动区域。改主意了？再按一次同一个键即可关闭 Omasnap。

选好区域后，Omasnap 会保存捕获内容、将其复制到剪贴板，并显示一条带缩略图的通知，就像保存屏幕录制时一样。选择 Open 在图片查看器中查看已保存的截图，或选择 Edit 对其进行标注。

标注编辑器可以绘制箭头、线条、形状、高亮、编号标记、文字和安全遮盖；裁剪或抠出图片的一部分；对文字进行 OCR；以及添加背景。在编辑器中，按 `Enter` 复制并保存完成后的 PNG，按 `Ctrl + C` 只复制不保存，或按 `Ctrl + S` 只保存不复制。

已保存的截图默认落在 `~/Pictures/Screenshots`，文件名形如 `screenshot-2026-08-13_14-22-05-firefox.png`。设置 `OMASNAP_SCREENSHOT_DIR` 可以改用其他目录——在哪里设置会话环境变量，见[常见问题](46-faq.md)。Omasnap 会在保存第一张截图时创建该目录。在 `~/.config/omasnap/omasnap.conf` 中设置 `[output] autosave = false` 可以禁用自动保存；这样捕获内容只会被复制，并显示一个 10 秒的预览，你可以用其图钉按钮或 `Ctrl + P` 让它一直留在屏幕上。

在终端里，`omarchy screenshot` 会打开同样的覆盖层，你还可以选择它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二个参数 `copy` 或 `save` 会把截图直接发送到对应目的地。要在输出前先编辑，使用 `omarchy screenshot --editor=overlay` 打开全屏编辑器，或使用 `omarchy screenshot --editor=window` 在单独的窗口中打开。

### 用键盘操控选择器

当选择界面打开时，你完全不必用鼠标：

| 键 | 功能 |
| --- | -------- |
| `S` | 切换滚动区域模式 |
| `Super + Arrow keys` | 在 Window 模式下在窗口之间移动 |
| `Return` | 捕获高亮的窗口 |
| `Ctrl + A` | 捕获完整的当前聚焦显示器 |
| `R` | 恢复本次会话中上次绘制的区域 |
| `Esc` | 关闭 Omasnap |

这些绑定只在 Omasnap 打开时存在，因此不会与你自己的配置中的任何绑定冲突。

## 屏幕录制

`Alt + Print Screen` 会打开 _Trigger > Capture > Screenrecord_，它会询问你希望音轨里包含什么：无音频、桌面音频、桌面加麦克风，或桌面加麦克风加网络摄像头。最后一项只有在你确实插了摄像头时才会出现。选好后，Omarchy 的录制选择器会让你拖拽出一个区域，或点击某个窗口或显示器。

录制由 gpu-screen-recorder 驱动，它在 GPU 上以 60fps 编码，不得已时才回退到 CPU。录制结果是位于 `~/Videos` 的 MP4，名为 `screenrecording-2026-08-13_14-22-05.mp4`。设置 `OMARCHY_SCREENRECORD_DIR` 可以更改这个位置——但请注意，与截图目录不同，这个目录必须已经存在，否则录制会拒绝启动。

录制期间，栏里会出现一个小指示器。点击它即可停止。你也可以再次按 `Alt + Print Screen` 停止，或使用 _Trigger > Capture > Screenrecord_ 下的 _Stop Screenrecording_ 条目停止，该条目只在确实有内容正在录制时才会出现。

停止时会先做一点整理再把文件交给你：第一帧会被裁掉，如果有音频，它会被标准化到 -14 LUFS，开头最前面的 PipeWire 捕获爆音会被静音。然后会出现一条带录制缩略图的通知。点击它即可在 Omaview 中播放该文件。

### 网络摄像头覆盖层

用网络摄像头录制时，摄像头会以一个固定的、裁剪过的竖版窗口出现在你正在录制内容的右下角。如果它挡住了你需要的东西，可以随时调整它的大小：

| 快捷键 | 功能 |
| ------ | -------- |
| `Super + Alt + [` | 让网络摄像头覆盖层变小 |
| `Super + Alt + ]` | 让网络摄像头覆盖层变大 |

一共有三种尺寸——小、中、大——快捷键会在它们之间逐级切换。中是默认尺寸。它们与录制画面成比例，因此无论你录制的是 1080p 显示器还是 6K 显示器，摄像头在画面中占据的比例都相同。而且如果你录制的是一个区域而不是整个显示屏，覆盖层会锚定到该区域的角落而不是显示器的角落，因此它会一直留在画面内。

你也可以直接用 `omarchy-capture-webcam-resize small` 调用它，或用 `reset` 回到中尺寸。

## 文字、QR 码和颜色

`Super + Ctrl + Print Screen` 会选择一个区域并对其进行 OCR 后放入剪贴板。这在[文本提取与听写](11-text-extraction-dictation.md)中有完整介绍。

_Trigger > Capture > QR Code_ 对 QR 码做同样的事。选择包含该码的区域，解码后的值就会进入剪贴板。它只查找 QR 码——否则密集的屏幕内容很容易被误认成条形码。有一点值得知道：解码后的值只会进入剪贴板，不会去任何其他地方。它不会被打印出来，不会出现在通知里，并且会被标记为敏感内容，因此不会留存在[剪贴板历史](08-unified-clipboard-history.md)中。QR 码经常携带机密——比如 2FA 设置码背后的 `otpauth://` URI——你不会希望那种东西出现在日志里。粘贴仍然可以正常使用。

`Super + Print Screen`（或 _Trigger > Capture > Color_）会把光标变成吸管。点击屏幕上的任何东西，该颜色就会进入剪贴板。再按一次快捷键可以退出而不取色。

## 分享前先转码

一段 4K 屏幕录制，或手机上的一张原始 HEIC，往往大到没法直接发送。`Super + Ctrl + .`（或 _Trigger > Transcode_）可以解决这个问题。它会为你提供一个覆盖 `~/Pictures` 和 `~/Videos` 的模糊文件选择器，然后询问你想要的格式和尺寸。

图片会转为 jpg 或 png，并提供高、中、低三档，宽度上限分别为 3160、2160 和 1080 像素。视频会转为 mp4 或动态 gif，并提供 4k、1080p 或 720p。转换后的文件会写在原文件旁边，文件名中带有分辨率——`demo-1080p.mp4`——其路径会以文件 URI 的形式复制到剪贴板，因此你可以直接把它粘贴到接受文件拖放的应用中。

它也可以在终端里使用，如果你已经知道自己想要什么：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。还有一个 `omarchy transcode ascii`，它会把图片转成 ASCII 艺术图——那个主要是给[品牌打造](41-branding.md)用的。

## 把它发送到别处

拿到文件后，`Super + Ctrl + S` 会打开 Share 菜单，并通过 LocalSend 把它发送到你网络上的另一台设备。详见[图形界面](22-guis.md)。
