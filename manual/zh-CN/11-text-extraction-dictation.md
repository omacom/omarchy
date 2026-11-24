# 文本提取与听写

### 文本提取

按 `Super + Ctrl + PrtScr` 选择屏幕上的一个区域进行文本提取。随后，开源 OCR 模型 tesseract 会迅速将所选内容转换为文本并放入剪贴板。然后只需按 `Super + V` 即可粘贴。

这对于抓取图片页脚中的地址或网站标题中嵌入的电话号码非常有帮助。

 ![text-extraction](images/text-extraction.webp)

### 听写

在全新安装中，[Superwhisper](https://superwhisper.com/) 是默认的听写后端，使用云端处理，无需下载离线模型。通过 Omarchy 菜单中的 _Setup > Defaults > Dictation_ 选择 Superwhisper、[Voxtype](https://voxtype.io/) 或 [Hex](https://anoma.ly/hex/)。选择某个后端后，如有需要会安装它，并将其设为听写的默认后端。Voxtype 会加载一个基础英语模型，占用 150MB；使用 `voxtype setup model` 更改模型，并通过 `~/.config/voxtype/config.toml` 更改其他设置。Superwhisper 会打开其设置以选择云端或本地处理，OPR 会保持该应用程序更新。Hex 会在设置期间下载其设备端语音模型，并以 `hex.service` 用户服务的形式运行；从栏的托盘图标打开其窗口，或运行 `hex` 来更改模型和其他设置。

按住 `Right Alt` 进行听写，或用 `Alt + Space` 切换听写，听写出的文本会出现在当前聚焦的输入区域中。这些快捷键使用所选的后端。在修饰键组合中使用 `Right Alt` 时也会启动听写；此类组合请使用 Left Alt。在 `Right Alt` 为 AltGr 的键盘布局上，包括你切换到的此类布局，单独按住它片刻即可听写；AltGr 与另一个键同时按下时仍会输入其字符。在 `Alt + Space` 成为默认方式之前的安装会保留 `F9` 用于按住说话，并保留 `Super + Ctrl + X` 用于切换，这些都已添加到 `~/.config/hypr/bindings.lua`，其中该 `Super + Ctrl + X` 取代了 agents 面板；在那里移除它们，即可将这些按键归还给应用程序和该面板。

相同的快捷键适用于每个后端。通过 Setup > Defaults > Dictation 选择你的后端。后端安装程序会对其进行配置并保存选择。运行 `omarchy default dictation` 查看当前选择的是哪一个。选择保存在 `~/.config/omarchy/defaults/dictation` 中。全新安装会自动选择 Superwhisper。

Omarchy 会自动加载所选后端的桌面集成。在 `~/.config/hypr/` 中无需任何 Superwhisper 配置。

自定义绑定和脚本可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所选后端负责录音和转录。选择 Superwhisper 后会禁用其原生按住快捷键，并将其原生切换快捷键设置为 `Ctrl + Alt + Space`，使其与 Omarchy 的录音按键保持分离。Superwhisper 至少需要一个原生录音快捷键，其取消快捷键保持可用。

其他后端无需更改 Omarchy 即可集成。在 PATH 上提供一个名为 `omarchy-dictation-<backend>` 的可执行文件，它接受 `start`、`stop` 和 `toggle`，并迅速返回，失败时返回非零状态。其安装程序会配置提供者，并在设置成功后调用 `omarchy-dictation-use <backend>`。这会停止之前的后端并原子地保存选择；当提供者处于空闲或不可用状态时，`stop` 必须成功。后端名称使用小写字母、数字和连字符。提供 `omarchy-install-dictation-<backend>` 用于设置；`omarchy default dictation <backend>` 会启动它。通过 Omarchy 菜单扩展添加一个 Defaults 菜单条目来调用该选择器。可选的桌面集成可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` 中。
