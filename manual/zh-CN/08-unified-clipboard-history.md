# 统一剪贴板与历史

通常在 Linux 上，你需要在终端中使用 `Ctrl + Shift + C/V` 进行复制粘贴，在其他地方则使用 `Ctrl + C/V`。对于任何不是在 Linux 环境中出生和长大的人来说，这很难适应！如果你来自 Mac，从 super 切换到 ctrl 也同样如此。

Omarchy 用在（几乎）所有地方都有效的统一剪贴板快捷键解决了这两个问题。它们是：

| 快捷键 | 命令 |
| ------- | ----------- |
| Super + C | 复制 |
| Super + X | 剪切 |
| Super + V | 粘贴 |
| Super + Ctrl + V | 剪贴板历史 |

_注意，大多数智能体工具会使用 `Ctrl + V` 粘贴图片，但使用 `Super + V` 粘贴文本。_

### 剪贴板历史

剪贴板历史由 Omarchy shell 提供，适用于文本和图片。你用 `Super + Ctrl + V` 触发它，用回车选择条目，然后该条目就会被放到剪贴板上，准备好用 `Super + V` 粘贴。

 ![clipboard-history](images/clipboard-history.webp)

你也可以通过开始输入来搜索历史：

 ![clipboard-history-search](images/clipboard-history-search.webp)
