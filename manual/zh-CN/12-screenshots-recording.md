# 截图与录屏

你能从屏幕上抓取的一切，都挂在 Print Screen 键上。单按这个键是拍照，加修饰键则可以录屏、取色，或者提取某个区域里的文字。如果你的键盘根本没有 Print Screen 键，`Super + Ctrl + Alt + C` 可以截出同样的图，`Super + Ctrl + C` 则会把整套功能以菜单形式打开。

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | 截图 |
| `Super + Ctrl + Alt + C` | 截图 |
| `Alt + Print Screen` | 录屏（或停止正在进行的录屏） |
| `Super + Print Screen` | 取色器 |
| `Super + Ctrl + Print Screen` | 从区域中提取文字 |
| `Super + Ctrl + C` | 捕获菜单 |
| `Super + Ctrl + .` | 转码图片或视频 |

## 截图

按下 `Print Screen`（或 `Super + Ctrl + Alt + C`），Omasnap 会在它的覆盖层出现之前就捕获聚焦的显示器，所以当你瞄准时，画面不会在你手下移位。拖出一个自由形状的区域，单击一个窗口来捕获它，或者单击空白处来捕获整个显示器。在绘制之前按 `S`，可以捕获滚动区域。改主意了？再按一次同一个键即可关闭 Omasnap。

选定区域后，Omasnap 会保存捕获内容，将其复制到剪贴板，并显示一条带缩略图的通知，就像保存屏幕录像时一样。选择 Open 在你的图片查看器中查看保存的截图，或选择 Edit 对其进行标注。

标注编辑器可以绘制箭头、线条、形状、高亮、编号标记和文字，还可以添加安全打码；裁剪或挖掉图片的一部分；对其文字进行 OCR；以及添加背景。在编辑器中，按 `Enter` 复制并保存完成的 PNG，按 `Ctrl + C` 只复制不保存，或按 `Ctrl + S` 只保存不复制。

默认情况下，保存的截图会落在 `~/Pictures/Screenshots`，文件名类似 `screenshot-2026-08-13_14-22-05-firefox.png`。设置 `OMASNAP_SCREENSHOT_DIR` 可以使用其他目录——关于会话环境变量应该放在哪里，请参阅[常见问题](46-faq.md)。Omasnap 会在保存第一张截图时创建该目录。在 `~/.config/omasnap/omasnap.conf` 中设置 `[output] autosave = false` 可以禁用自动保存；这样捕获内容就只会被复制，并在一个 10 秒的预览中显示，你可以用它的固定按钮或 `Ctrl + P` 让预览一直留在屏幕上。

从终端运行 `omarchy screenshot` 会打开同一个覆盖层，你还可以选择它的起始模式：`omarchy capture screenshot region`、`windows`、`fullscreen` 或 `scroll`。第二个参数为 `copy` 或 `save` 时，会把截图直接发送到那个目标。要在输出前编辑，使用 `omarchy screenshot --editor=overlay` 打开全屏编辑器，或使用 `omarchy screenshot --editor=window` 在单独的窗口中打开。

### 完全用键盘操作选择器

选择界面打开时，你完全不必使用鼠标：

| Key | Function |
| --- | -------- |
| `S` | 切换滚动区域模式 |
| `Super + Arrow keys` | 在 Window 模式下在窗口之间移动 |
| `Return` | 捕获高亮显示的窗口 |
| `Ctrl + A` | 捕获整个聚焦的显示器 |
| `R` | 恢复本次会话中上次绘制的区域 |
| `Esc` | 关闭 Omasnap |

这些绑定只在 Omasnap 打开时存在，所以它们不会与你自己配置中的任何绑定冲突。

## 录屏

`Alt + Print Screen` 会打开 _Trigger > Capture > Screenrecord_，它会询问你希望音轨里有什么：无音频、桌面音频、桌面加麦克风，或者桌面加麦克风加摄像头。最后一个选项只有在你确实插了摄像头时才会出现。选定一个后，Omarchy 的录制选择器会让你拖出一个区域，或单击一个窗口或显示器。

录制运行在 gpu-screen-recorder 上，它在 GPU 上以 60fps 编码，必要时回退到 CPU。结果是一个位于 `~/Videos` 的 MP4，名为 `screenrecording-2026-08-13_14-22-05.mp4`。设置 `OMARCHY_SCREENRECORD_DIR` 可以更改这一点——但要注意，与截图目录不同，这个目录必须已经存在，否则录制会拒绝开始。

录制时，栏里会出现一个小指示器。单击它即可停止。你也可以再次按 `Alt + Print Screen` 停止，或者使用 _Trigger > Capture > Screenrecord_ 下的 _Stop Screenrecording_ 条目，该条目只在确实有内容正在录制时才会出现。

停止时会先做一点整理，然后才把文件交给你：第一帧会被修剪掉，如果有音频，它会被归一化到 -14 LUFS，最开头 PipeWire 捕获的爆音会被静音。然后会出现一条带录像缩略图的通知。单击它可以在 mpv 中播放该文件。

### 摄像头浮窗

当你带着摄像头录制时，摄像头会以一个固定的、裁剪过的竖版窗口出现在你所录制内容的右下角。如果它正好挡住了你需要的东西，可以即时调整它的大小：

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | 让摄像头浮窗变小 |
| `Super + Alt + ]` | 让摄像头浮窗变大 |

共有三个尺寸——小、中、大——快捷键会在它们之间步进。中是默认值。它们与录制内容成比例，所以无论你录制的是 1080p 显示器还是 6K 显示器，摄像头都会占画面相同的份额。而且如果你录制的是一个区域而不是整个显示器，浮窗会锚定到那个区域的角落，而不是显示器的角落，所以它会一直留在画面内。

你也可以直接用 `omarchy-capture-webcam-resize small` 调用它，或者用 `reset` 回到中。

## 文本、QR 码和颜色

`Super + Ctrl + Print Screen` 会选择一个区域，并对它进行 OCR 后放入剪贴板。这在[文本提取与听写](11-text-extraction-dictation.md)中有完整介绍。

_Trigger > Capture > QR Code_ 对 QR 码做同样的事。选择包含该码的区域，解码后的值就会进入剪贴板。它只查找 QR 码——否则密集的屏幕内容很容易误报为条形码。有一点值得知道：解码后的值只会进入剪贴板，不会去其他任何地方。它不会被打印出来，不会出现在通知里，并且会被标记为敏感内容，所以不会留在[剪贴板历史](08-unified-clipboard-history.md)中。QR 码经常携带秘密——比如 2FA 设置码背后的 `otpauth://` URI——你不会希望那种东西出现在日志里。粘贴仍然可以正常工作。

`Super + Print Screen`（或 _Trigger > Capture > Color_）会把光标变成吸管。在屏幕上单击任何东西，颜色就会落在剪贴板上。再次按该快捷键可以在不取色的情况下退出。

## 分享前转码

一段 4K 屏幕录像或手机里的原始 HEIC 往往太大，没法直接发送。`Super + Ctrl + .`（或 _Trigger > Transcode_）可以解决这个问题。它会为你提供一个覆盖 `~/Pictures` 和 `~/Videos` 的模糊文件选择器，然后询问格式和大小。

图片可以转到 jpg 或 png，可选高、中、低，它们会把宽度上限分别设为 3160、2160 和 1080 像素。视频可以转到 mp4 或动态 gif，可选 4k、1080p 或 720p。转换后的文件会写在原始文件旁边，分辨率会体现在文件名中——`demo-1080p.mp4`——并且路径会以文件 URI 的形式复制到剪贴板，这样你就可以直接把它粘贴到接受文件拖放的应用中。

它也可以从终端工作，如果你已经知道自己想要什么：`omarchy transcode ~/Videos/demo.mov mp4 1080p`。还有 `omarchy transcode ascii`，它会把图片变成 ASCII 艺术图——那个主要是给[品牌](41-branding.md)用的。

## 发送到别处

拿到文件后，`Super + Ctrl + S` 会打开 Share 菜单，并通过 LocalSend 把它发送到你网络上的另一台设备。相关内容请参阅[图形界面应用](22-guis.md)。
