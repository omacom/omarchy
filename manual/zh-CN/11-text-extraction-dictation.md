# 文字提取与听写

### 文字提取

按下 `Super + Ctrl + PrtScr`，在屏幕上选择一个区域进行文字提取。tesseract 开源 OCR 模型随后会迅速将所选内容转换为文字，并放入剪贴板。然后你只需按下 `Super + V` 即可粘贴。

这对于抓取图片页脚中的地址，或嵌入在网站标题中的电话号码非常有帮助。

 ![text-extraction](images/text-extraction.webp)

### 听写

在全新安装中，[Superwhisper](https://superwhisper.com/) 是默认的听写后端，使用云端处理，无需下载离线模型。通过 Omarchy 菜单中的 _Setup > Defaults > Dictation_ 选择 Superwhisper、[Voxtype](https://voxtype.io/) 或 [Hex](https://anoma.ly/hex/)。选择某个后端会在需要时将其安装，并使其成为听写的默认后端。Voxtype 会加载一个占用 150MB 的基础英文模型；使用 `voxtype setup model` 更改模型，并通过 `~/.config/voxtype/config.toml` 修改其他设置。Superwhisper 会打开其设置，让你选择云端或本地处理，OPR 则负责保持该应用更新。Hex 会在设置过程中下载其设备端语音模型，并以 `hex.service` 用户服务的形式运行；从栏的托盘图标打开其窗口，或运行 `hex`，即可更改模型和其他设置。

你按住 `Right Alt` 进行听写，或用 `Alt + Space` 切换听写，听写出的文字会出现在当前聚焦的输入区域中。这些快捷键会使用所选的后端。Right Alt 在修饰键组合中使用时也会启动听写；这类组合请使用 Left Alt。在 Right Alt 为 AltGr 的键盘布局上，使用 `Alt + Space`，以便保留 AltGr 用于输入。在 Alt + Space 成为默认方式之前的安装会保留 `F9` 用于按住说话、`Super + Ctrl + X` 用于切换，这些已添加到 `~/.config/hypr/bindings.lua`，其中该 `Super + Ctrl + X` 会取代 agents 面板的位置；在那里移除它们，即可将这些按键还给应用程序和该面板。

相同的快捷键适用于每一个后端。通过 Setup > Defaults > Dictation 选择你的后端。后端安装程序会对其进行配置并保存所选内容。运行 `omarchy default dictation` 查看当前选择的是哪一个。所选内容保存在 `~/.config/omarchy/defaults/dictation` 中。全新安装会自动选择 Superwhisper。

Omarchy 会自动加载所选后端的桌面集成。在 `~/.config/hypr/` 中无需进行任何 Superwhisper 配置。

自定义绑定和脚本可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所选后端负责录音和转录。选择 Superwhisper 会禁用其原生按住快捷键，并将其原生切换快捷键设置为 `Ctrl + Alt + Space`，使其与 Omarchy 的录音按键分开。Superwhisper 要求至少保留一个原生录音快捷键，其取消快捷键仍保持可用。

其他后端无需更改 Omarchy 即可集成。在 PATH 上提供一个名为 `omarchy-dictation-<backend>` 的可执行文件，它接受 `start`、`stop` 和 `toggle`，并迅速返回，失败时返回非零状态。其安装程序会配置提供方，并在设置成功后调用 `omarchy-dictation-use <backend>`。这会停止上一个后端，并原子地保存所选内容；当提供方处于空闲或不可用状态时，`stop` 必须成功。后端名称使用小写字母、数字和连字符。提供 `omarchy-install-dictation-<backend>` 用于设置；`omarchy default dictation <backend>` 会启动它。通过 Omarchy 菜单扩展添加一个 Defaults 菜单条目，以调用该选择器。可选的桌面集成可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` 中。
