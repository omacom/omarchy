# 统一剪贴板与历史记录

通常在 Linux 上，你需要在终端里用 `Ctrl + Shift + C/V` 复制粘贴，在其他地方则用 `Ctrl + C/V`。对任何不是在 Linux 里土生土长的人来说，这都很难习惯！如果你是从 Mac 迁移过来的，从 Super 切换到 Ctrl 同样如此。

Omarchy 用几乎随处可用的统一剪贴板快捷键解决了这两个问题。它们是：

| 快捷键 | 命令 |
| ------- | ----------- |
| Super + A | 全选 |
| Super + C | 复制 |
| Super + X | 剪切 |
| Super + V | 粘贴 |
| Super + Ctrl + V | 剪贴板历史记录 |

_请注意，大多数 agent harness 会用 `Ctrl + V` 粘贴图片，但用 `Super + V` 粘贴文本。_

先用 `Super + A`，再用 `Super + C`，即可复制已聚焦的文本字段或任何其他支持 `Ctrl + A` 的应用中的全部内容。在终端中，`Ctrl + A` 会将光标移动到命令行开头，而不是选中其文本。

### 剪贴板历史记录

剪贴板历史记录由 Omarchy shell 提供，文本和图片都支持。用 `Super + Ctrl + V` 触发它，然后用回车键选中条目，即可直接粘贴到你刚才所在的应用中。用 `Shift + Return` 只将其复制到剪贴板，用 `Alt + Return` 将其打开，用 `Delete` 将其从历史记录中删除，用 `Shift + Delete` 清空全部历史记录。

 ![clipboard-history](images/clipboard-history.webp)

你也可以直接开始输入来搜索历史记录：

 ![clipboard-history-search](images/clipboard-history-search.webp)
