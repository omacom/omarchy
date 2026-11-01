# 统一剪贴板与历史记录

在 Linux 上，通常你需要在终端里用 `Ctrl + Shift + C/V` 来复制粘贴，在其他地方则用 `Ctrl + C/V`。对没有在 Linux 环境里出生长大的人来说，这真的很难适应！如果你是从 Mac 切换过来的，从 Super 键换到 Ctrl 键也一样别扭。

Omarchy 用统一的剪贴板快捷键解决了这两个问题，（几乎）在任何地方都能用。它们是：

| 快捷键 | 操作 |
| ------- | ----------- |
| Super + A | 全选 |
| Super + C | 复制 |
| Super + X | 剪切 |
| Super + V | 粘贴 |
| Super + Ctrl + V | 剪贴板历史记录 |

_请注意，大多数 agent harness 会用 `Ctrl + V` 粘贴图片，但用 `Super + V` 粘贴文本。_

使用 `Super + A`，然后按 `Super + C`，即可复制当前聚焦的文本框或其他支持 `Ctrl + A` 的应用中的全部内容。在终端里，`Ctrl + A` 是移动到命令行开头，而不是选中其中的文本。

### 剪贴板历史记录

剪贴板历史记录由 Omarchy shell 提供，文本和图片都支持。你可以用 `Super + Ctrl + V` 触发它，用回车键选中条目，然后该条目就会被放入剪贴板，随时可以用 `Super + V` 粘贴。

 ![clipboard-history](images/clipboard-history.webp)

你也可以直接开始打字来搜索历史记录：

 ![clipboard-history-search](images/clipboard-history-search.webp)
