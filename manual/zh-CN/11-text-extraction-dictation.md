# 文本提取与听写

### 文本提取

按下 `Super + Ctrl + PrtScr`，在屏幕上选择一个区域进行文本提取。tesseract 开源 OCR 模型随后会迅速将所选内容转换为文本，并放入剪贴板。然后你只需按下 `Super + V` 即可粘贴。

这对于抓取图片页脚中的地址，或网站标题中嵌入的电话号码非常有帮助。

 ![text-extraction](images/text-extraction.webp)

### 听写

在全新安装中，[Superwhisper](https://superwhisper.com/) 是默认的听写后端，使用云端处理，无需下载离线模型。通过 Omarchy 菜单中的 _Setup > Defaults > Dictation_ 选择 Superwhisper、[Voxtype](https://voxtype.io/) 或 [Hex](https://anoma.ly/hex/)。选择一个后端后，如有需要便会安装它，并将其设为听写的默认后端。Voxtype 会加载一个基础英语模型，占用 150MB；使用 `voxtype setup model` 更改模型，并通过 `~/.config/voxtype/config.toml` 修改其他设置。Superwhisper 会打开其设置，让你选择云端处理或本地处理，OPR 会保持该应用程序为最新状态。Hex 会在设置过程中下载其设备端语音模型，并作为 `hex.service` 用户服务运行；从栏的托盘图标打开它的窗口，或运行 `hex`，即可更改模型和其他设置。

按住 `Right Alt` 进行听写，或使用 `Alt + Space` 切换开关，听写的文本就会出现在当前聚焦的输入区域中。这些快捷键会使用所选的后端。Right Alt 在修饰键组合中使用时也会启动听写；这类组合请使用 Left Alt。在 Right Alt 是 AltGr 的键盘布局上，使用 `Alt + Space`，以便继续使用 AltGr 输入字符。在 Alt + Space 成为默认方式之前安装的系统，会保留 `F9` 用于按住说话、`Super + Ctrl + X` 用于切换，这些都添加在 `~/.config/hypr/bindings.lua` 中；在那里删除它们，即可把这些按键还给应用程序。

相同的快捷键适用于每个后端。通过 Setup > Defaults > Dictation 选择你的后端。后端安装程序会配置它并保存选择。运行 `omarchy default dictation` 查看当前选择的是哪一个。选择保存在 `~/.config/omarchy/defaults/dictation` 中。全新安装会自动选择 Superwhisper。

Omarchy 会自动加载所选后端的桌面集成。无需在 `~/.config/hypr/` 中进行任何 Superwhisper 配置。

自定义绑定和脚本可以使用 `omarchy dictation start`、`omarchy dictation stop` 和 `omarchy dictation toggle`。所选后端负责录音和转写。选择 Superwhisper 会禁用其原生的按住快捷键，并将其原生切换快捷键设为 `Ctrl + Alt + Space`，使其与 Omarchy 的录音按键分开。Superwhisper 要求至少保留一个原生录音快捷键，其取消快捷键仍然可用。

其他后端无需修改 Omarchy 即可集成。在 PATH 上提供一个名为 `omarchy-dictation-<backend>` 的可执行文件，它接受 `start`、`stop` 和 `toggle`，并迅速返回，失败时返回非零状态。它的安装程序会配置提供方，并在设置成功后调用 `omarchy-dictation-use <backend>`。这会停止之前的后端，并以原子方式保存选择；当提供方处于空闲或不可用状态时，`stop` 必须成功。后端名称使用小写字母、数字和连字符。提供 `omarchy-install-dictation-<backend>` 用于设置；`omarchy default dictation <backend>` 会启动它。通过 Omarchy 菜单扩展添加一个 Defaults 菜单条目，以调用该选择器。可选的桌面集成可以放在 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` 中。
