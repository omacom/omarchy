# Neovim

[Neovim](https://neovim.io/) 是 Bill Joy 早在 1976 年创建的 [vi 编辑器](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) 的现代实现。它是一个模式编辑器，其中插入模式和命令模式是分开的，一旦你只学习了那套极其深奥的按键命令的一个子集，它就是一种超能力。但它也有相当陡峭的学习曲线！

如果你对 vim 风格的编辑完全陌生，我建议你查看 YouTube 上的 [ThePrimeagen 的 Vim As Your Editor 系列](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)。这会教你基础知识。只需知道，与更类似的主流编辑器不同，你需要更长时间才能掌握 vim 的基本熟练程度。但一旦你掌握了，回报也更大。

现在 Neovim 基本上是可以无限配置的。如果你真的想折腾，你可以从头开始创建自己的 Neovim 配置。[Typecraft 有一门很棒的从头设置 Neovim 的课程](https://www.youtube.com/watch?v=zHTeCSVAFNY)。[ThePrimeagen 也有一门](https://www.youtube.com/watch?v=w7i4amO_zaE)。

但 Omarchy 附带了一个完整的 Neovim 设置——`omarchy-nvim` 包——它经过精心调优，展示了开箱即用的最佳效果。无需你编写一行配置！它构建在 [LazyVim](https://www.lazyvim.org/) 之上，后者是 Neovim 插件和配置的发行版。它太棒了。

## LazyVim 基础

如前所述，我不会在这篇简短的介绍中教你 vim，但我可以向你展示 LazyVim 的一些基础知识以及如何四处操作。

首先，Neovim 有 leader 键的概念。这基本上是所有命令的门户。LazyVim 将其设置为 `Space`。所以只需按下它，等待一秒钟，你就会看到一堆像这样内联解释的选项：

以下是我一直使用的一些基本命令：

- `Space Space` - 在当前目录中模糊查找任何文件。
- `Space S G` - 使用带预览的 grep 搜索所有文件。
- `Space E` - 切换文件树开/关。
- `Ctrl + W W` - 在文件树和编辑器之间来回跳转。
- `Shift + H` - 在打开的选项卡（vim 称它们为缓冲区）之间向左移动。
- `Shift + L` - 在打开的选项卡之间向右移动。
- `Space B D` - 关闭选项卡。
- `Space B O` - 关闭除当前选项卡外的所有其他选项卡。
- `Space G G` - 在当前目录的浮动窗格中启动 LazyGit。
- `Space U W` - 切换软换行。

当你在文件树中时（`Space E` 显示，`Ctrl + W W` 跳转到那里），你可以用 `a` 添加新文件，用 `A` 添加新目录。在树中时按 `?` 可查看所有命令。

如果你想掌握基本的 vim 语言，我写过关于[三部分语法](https://world.hey.com/dhh/wonderful-vi-a1d034d3)以及如何完成那些酷炫连招的文章！

你可以在 [LazyVim Keymaps 页面](https://www.lazyvim.org/keymaps)上查看所有可能的命令。

## 启动 Neovim

你可以使用 `Super + Shift + N` 启动 Neovim（该绑定启动你的默认编辑器，开箱即用的是 Neovim），但通常更容易通过终端驱动它：导航到你希望工作的目录并输入 `n`。`n` 是 `nvim` 的别名，它将默认使用当前目录打开。你可以用 `n myfile.txt` 打开单个文件。

## 使用 Neovim 进行 sudo 编辑

如果你需要编辑只能以超级用户身份更改的文件，你可以通过运行 `sudoedit /etc/sudoers.d/00-sudo-only-file` 来使用设置了所有插件的 neovim。
