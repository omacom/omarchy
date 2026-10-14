# Shell 工具

除了标准的 Linux 工具，Omarchy 还自带一大堆增强的 shell 工具。以下是关键的几个。

## fzf

[fzf](https://junegunn.github.io/fzf/) 通过 `ff` 别名让你模糊查找文件。进入任意目录，输入 `ff`，你就能模糊定位到该目录树中的任何文件，同时在右侧看到你正在缩小范围的文件的预览。

你可以用 `Ctrl + R` 通过 fzf 模糊查找你的命令历史。

当你在 Neovim 中输入 `Space Space` 时，也会用到这个工具。

完整手册可以通过 `man fzf` 找到。

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) 是 cd 的替代品。它会记住你去过的目录，这样下次你就能更轻松地跳过去。比如你执行一次 `cd ~/.config/omarchy`。下次，你只需执行 `cd omarchy`（甚至只是 `cd oma`），Zoxide 就会直接带你到那里。

完整手册可以通过 `man zoxide` 找到。

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) 用 `rg <pattern> <path>` 搜索文件的内容，比如 `rg Controller app/` 可以找到目录 app 中所有提到 `Controller` 的地方。

当你在 Neovim 中输入 `Space S G` 时，也会用到这个工具。

完整手册可以通过 `man rg` 找到。

## eza

[eza](https://eza.rocks/) 是 ls 的替代品。它为你提供信息更丰富、带颜色和图标的目录列表。默认情况下，eza 已被别名为 ls。你还可以用 `lt` 获取两层嵌套的列表。`lsa` 给你包含隐藏文件的列表。而 `lta` 是带隐藏文件的嵌套列表。

完整手册可以通过 `man eza` 找到。

## fd

[fd](https://github.com/sharkdp/fd) 是一个更易用的 `find` 替代品。用 `fd person.rb` 在当前树中找到名为 `person.rb` 的文件。`fd person.rb /` 将搜索整个文件系统。`fd person.rb / -H` 搜索整个文件系统，包括隐藏目录。

完整手册可以通过 `man fd` 找到。

## bat

[bat](https://github.com/sharkdp/bat) 是带语法高亮、行号和分页的 `cat`。运行 `bat somefile.rb`，你就会明白为什么很难再回去了。它还在别处默默为你工作：它是为你的 man 页面着色的工具，也是渲染 `ff` 预览的工具。

完整手册可以通过 `man bat` 找到。

## tldr

[tldr](https://tldr.sh/) 是那些开头三屏都在讲历史、才给你一个示例的 man 页面的解药。`tldr tar` 给你你真正想要的那几个调用方式。

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) 从 YouTube 和数百个其他站点下载视频。`yt-dlp <url>` 将可用的最佳画质下载到当前目录。

完整手册可以通过 `man yt-dlp` 找到。

## try

[try](https://github.com/tobi/try) 让你轻松管理带日期戳目录的编程实验。所有实验都放在 `~/Work/tries` 中，你可以通过 `try` 访问它们。

Omarchy 不会自动将项目的 `bin/` 目录添加到 `PATH`。运行受信任的项目本地工具时使用显式相对路径，例如 `bin/rails` 或 `./bin/dev`。
