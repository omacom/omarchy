# 开发工具

## 替代编辑器

Omarchy 在新安装中默认搭载 Plain 作为编辑器，并预装了 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一点的选择，可以打开 Omarchy Menu (`Super + Space`)，查看 _Install > Editor_ 下的选项。那里列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果你没找到想要的，可以去看看 _Install > Package_，看看它是不是在某个 Arch 软件包里（如果不在，再试试 _Install > AUR_ 查看 AUR）。

原版 `vi` 编辑器也开箱即用。运行 `vi filename` 即可在终端中编辑文件。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 都提供主题匹配。

你可以在 `Setup > Defaults > Editor` 下设置系统范围的默认编辑器。

## 开发环境

Omarchy 支持通过 Omarchy Menu (`Super + Space`) 的 _Install > Development_ 部分设置一大批开发环境。你当然能找到 _Ruby on Rails_，还有 JavaScript 的三大主流运行时（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等流行的 PHP 框架。哦，还有 Go、Rust、Python、Java、Elixir（带 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。选择真的非常丰富！

这些环境中的大多数都由 [Mise](https://mise.jdx.dev/) 管理。它是一个让你在同一台机器上安装和运行同一编程语言的多个版本的工具。它就像 Ruby 的 rbenv 或 rvm、Python 的 virtualenv，但它能用于一大堆不同的环境。

比如要安装 Ruby，你可以运行 `mise use -g ruby`，它会安装 Ruby 并将其设置为全局默认版本。或者，如果你的项目有 .ruby-version 文件，你只需在该项目的根目录运行 `mise i` 即可。

## 预装的 CLI 工具

`uv`、Node.js 和 `playwright-cli`（供 agent 使用已安装的 Chrome 驱动浏览器）已作为软件包安装，`omarchy update` 会让它们与系统的其他部分保持最新。`ghui`、[Hunk](https://github.com/modem-dev/hunk)，以及 Basecamp、Cloudflare 和 HEY 的 CLI，只需在 _Install > CLI_ 下选一下就能装上，而[编程 agent](17-ai.md) 则在 _Install > AI > CLI_ 下。

mise 只管理你从 _Install > Development_ 设置的运行时；Omarchy 本身不会通过它安装任何东西。运行 `omarchy update` 即可将它们与 Omarchy 的其他部分一起更新；`mup` 别名则只更新由 mise 管理的工具。要向你自己的配置中添加另一个工具，请使用 `mise use -g <tool>`。

## Docker

[Docker](https://www.docker.com/) 几乎不需要任何介绍。它让你运行隔离的容器，而 Omarchy 安装了良好运行它所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

默认情况下，你的用户*不*属于 `docker` 组。这个组实际上等同于免密 root——组里的任何东西都可以 `docker run -v /:/host` 并接管整台机器——所以一个以你的身份运行的流氓脚本或依赖项，否则离 root 就只差一条命令。因此在命令行中，你要用 `sudo` 运行 Docker（`sudo docker ps`、`sudo docker compose up`），而与守护进程通信的图形工具——Windows VM——会在需要时请求授权。如果你想恢复无组设置的便利，并理解其中的取舍，可以从 **Setup > Security > Sudoless Docker** 启用它（或运行 `omarchy-setup-security-sudoless-docker`），它会在发出警告后将你加入 `docker` 组；然后普通的 `docker` 和 `d` 别名就又可以不用 `sudo` 使用了。

你可以使用 Omarchy 菜单中的 _Install > Development > Docker DB_ 在 Docker 中设置本地开发常用的数据库。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 也就是 `gh`，用于从终端处理仓库、issue 和 pull request。当你选择在 _Setup > Git_ 中登录 GitHub 时，它会在那里安装它，然后 `gh repo clone org/repo` 就可以克隆一个仓库。运行 `gh --help` 即可探索它的命令。

_Install > CLI > GitHub_ 会安装 GitHub CLI，也就是 `gh`，以及 `ghui`，一个用于 pull request 的终端界面。[Lazygit](https://github.com/jesseduffield/lazygit) 已预装，用于处理 Git 本身。
