# Neovim

[Neovim](https://neovim.io/) 是 [vi 编辑器](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) 的现代实现，后者由 Bill Joy 早在 1976 年创建。它是一款模式编辑器，插入模式和命令模式彼此分离；一旦你学会了那套深不见底的按键命令哪怕只是其中一小部分，它都有点像一种超能力。但它的学习曲线也确实相当陡！

如果你完全没接触过 vim 风格的编辑，我推荐你去 YouTube 上看看 [ThePrimeagen 的 Vim As Your Editor 系列](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)。它会教你基础知识。只是要知道，与那些彼此更相似的主流编辑器不同，你用 vim 达到基本熟练需要更长时间。但一旦学会，回报也更大。

如今 Neovim 基本上可以无限配置。如果你真的想玩疯了，你可以从零开始创建你自己的 Neovim 配置。有一门很棒的课程是 [Typecraft 从零设置 Neovim](https://www.youtube.com/watch?v=zHTeCSVAFNY)。[ThePrimeagen 也有一门](https://www.youtube.com/watch?v=w7i4amO_zaE)。

但 Omarchy 附带了一套完整的 Neovim 配置——`omarchy-nvim` 包——经过精心调校，开箱即用地展示最佳可能性。无需你写一行配置！它构建在 [LazyVim](https://www.lazyvim.org/) 之上，后者是一个 Neovim 插件和配置发行版。它太棒了。

## LazyVim 基础

如上所述，我不会在这篇简短介绍中教你 vim，但我可以向你展示 LazyVim 的一些基础知识，以及如何四处操作。

首先，Neovim 有 leader 键的概念。那基本上是通往所有命令的门户。LazyVim 已将其设置为 `Space`。所以就按下它，等一秒钟，你就会看到一堆选项像这样内联解释：

下面是一些我一直在用的基本命令：

- `Space Space` - 在当前目录中模糊查找任意文件。
- `Space S G` - 使用 grep 搜索所有文件并带预览。
- `Space E` - 开关文件树。
- `Ctrl + W W` - 在文件树和编辑器之间来回跳跃。
- `Shift + H` - 在打开的标签页之间向左移动（vim 称它们为 buffers）。
- `Shift + L` - 在打开的标签页之间向右移动。
- `Space B D` - 关闭一个标签页。
- `Space B O` - 关闭除当前标签页外的所有其他标签页。
- `Space G G` - 从当前目录在浮动窗格中启动 LazyGit。
- `Space U W` - 切换软换行。

当你在文件树中时（用 `Space E` 显示，用 `Ctrl + W W` 跳过去），你可以用 `a` 添加新文件，或用 `A` 添加新目录。在文件树中按 `?` 查看所有命令。

如果你想掌握基本的 vim 语言，我写过关于[三段式语法](https://world.hey.com/dhh/wonderful-vi-a1d034d3)以及如何使出那些帅气的连招的内容！

你可以在 [LazyVim Keymaps 页面](https://www.lazyvim.org/keymaps) 查看所有可能的命令。

## 启动 Neovim

`Super + Shift + N` 会启动你的默认编辑器，在新安装中它就是 Plain；在 _Setup > Defaults > Editor_ 下选择 Neovim，即可让它改为启动 Neovim。但通常从终端驱动它更容易：导航到你想工作的目录并输入 `n`。`n` 是 `nvim` 的别名，它默认会使用当前目录打开。你可以用 `n myfile.txt` 打开单个文件。

## 使用 Neovim 进行 sudo 编辑

如果你需要编辑只有超级用户才能更改的文件，运行 `sudoedit /etc/sudoers.d/00-sudo-only-file`。它会打开你的默认编辑器，所以如果你想在那里使用 Neovim 及其所有插件，就在 _Setup > Defaults > Editor_ 下设置 Neovim。
