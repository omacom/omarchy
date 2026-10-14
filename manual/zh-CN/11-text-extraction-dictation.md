# 文本提取与听写

### 文本提取

按 `Super + Ctrl + PrtScr` 选择屏幕上的一个区域进行文本提取。tesseract 开源 OCR 模型随后会快速将该选区转换为文本并将其放到剪贴板上。然后你只需按 `Super + V` 粘贴即可。

这对于从图片页脚中抓取地址或网站标题中嵌入的电话号码非常有帮助。

 ![text-extraction](images/text-extraction.webp)

### 听写

在全新安装时，[Superwhisper](https://superwhisper.com/) 是默认的听写后端，使用云端处理，无需下载离线模型。通过 Omarchy 菜单中的_设置 > 默认项 > 听写_选择 Superwhisper 或 [Voxtype](https://voxtype.io/)。选择后端会在需要时安装它，并将其设为听写的默认后端。Voxtype 会加载一个占用 150MB 的基础英语模型；用 `voxtype setup model` 更改模型，并通过 `~/.config/voxtype/config.toml` 更改其他设置。Superwhisper 会打开其设置以选择云端或本地处理，OPR 会保持该应用更新。

你通过按住 `Right Alt` 或 `F9` 进行听写，或者用 `Super + Ctrl + X` 切换，听写的文本将出现在聚焦的输入区域中。这些快捷键使用所选后端。Right Alt 在修饰键组合中使用时也会开始听写；对于那些组合，请使用 Left Alt。在 Right Alt 即 AltGr 的键盘布局上，请使用 `F9` 以使 AltGr 仍可用于打字。

相同的快捷键适用于任一后端。通过设置 > 默认项 > 听写选择你的后端。后端安装程序会配置它并保存选择。运行 `omarchy default dictation` 可查看选择了哪一个。选择保存在 `~/.config/omarchy/defaults/dictation` 中。全新安装会自动选择 Superwhisper。

Omarchy 会自动加载所选后端的桌面集成。`~/.config/hypr/` 中不需要 Superwhisper 配置。

自定义绑定和脚本可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所选后端处理录音和转录。选择 Superwhisper 会禁用其原生按住快捷键，并将其原生切换设置为 `Alt + Space`，使其与 Omarchy 的录制键分开。Superwhisper 至少需要一个原生录制快捷键，其取消快捷键仍然可用。

其他后端无需更改 Omarchy 即可集成。提供一个在 PATH 上名为 `omarchy-dictation-<backend>` 的可执行文件，接受 `start`、`stop` 和 `toggle` 并立即返回，失败时状态为非零。其安装程序配置提供商，并在成功设置后调用 `omarchy-dictation-use <backend>`。这会停止上一个后端并原子地保存选择；当提供商空闲或不可用时，`stop` 必须成功。后端名称使用小写字母、数字和连字符。为设置提供 `omarchy-install-dictation-<backend>`；`omarchy default dictation <backend>` 会启动它。通过 Omarchy 菜单扩展添加一个默认项菜单条目以调用该选择器。可选的桌面集成可位于 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`。
