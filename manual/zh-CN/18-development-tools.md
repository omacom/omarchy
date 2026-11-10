# 开发工具

## 替代编辑器

Omarchy 默认自带 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一点的东西，可以运行 Omarchy Menu（`Super + Space`），查看 _Install > Editor_ 下的选项。那里列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果你没找到想要的，去看看 _Install > Package_，看看它是不是在某个 Arch 软件包里（如果不在，再试试 _Install > AUR_ 查看 AUR）。

原版 `vi` 编辑器也开箱即用地可用。运行 `vi filename` 即可在终端中编辑文件。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 提供主题匹配功能。

你可以在 `Setup > Defaults > Editor` 下设置系统范围的默认编辑器。

## 环境

Omarchy 支持通过 Omarchy Menu（`Super + Space`）的 _Install > Development_ 部分设置一整套开发环境。当然，你会找到 _Ruby on Rails_，但也有 JavaScript 的全部三大运行时（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等流行的 PHP 框架。哦，还有 Go、Rust、Python、Java、Elixir（带 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。选择非常广泛！

这些环境中的大多数都由 [Mise](https://mise.jdx.dev/) 管理。它是一款能让你在同一台机器上安装和运行某个编程语言的多个版本的工具。它就像 Ruby 的 rbenv 或 rvm，或者 Python 的 virtualenv，但它适用于一大堆不同的环境。

例如，要安装 Ruby，你可以运行 `mise use -g ruby`，它既会安装 Ruby，也会将其设置为全局默认版本。或者，如果你的项目有一个 .ruby-version 文件，你只需在该项目的根目录运行 `mise i`。

## 预装的 CLI 工具

Omarchy 通过 [mise 的延迟安装](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools)，提供诸如 `gh`、`uv` 以及大多数[编码智能体](17-ai.md)等工具。第一次运行其中某个工具时，mise 会安装它。后面的运行会复用已安装的版本；它们不会在每次启动时都检查更新。

你也可以查看默认配置，或提前安装它们：

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

运行 `omarchy update` 可随 Omarchy 的其余部分一起更新已安装的工具。`mup` 别名仅更新 mise 管理的工具。要将另一个工具添加到你自己的配置中，请使用 `mise use -g <tool>`。

Python 设置也会通过 mise 安装 `uv`。移除 Python 开发环境后，`uv` 仍会作为独立工具可用。

### 使用你自己的安装

mise 的命令位于 `PATH` 上 `~/.local/bin` 之前，所以对于你自己安装的工具，例如用 Claude Code 或 Cursor 自带的安装程序安装的工具，运行的仍然是 mise 的副本。从桌面启动的应用也会在系统软件包之前找到 mise 的命令，所以某个运行 `gh` 的应用，得到的会是 mise 的副本，即使你已经用 pacman 安装了 `github-cli`，而且 mise 会在第一次时安装那个副本。要改用你自己的副本，请在 `~/.config/mise/config.toml` 中禁用 mise 的副本。例如，如果你自己安装了 Cursor CLI：

```toml
[settings]
disable_tools = ["cursor-agent"]
```

如果你已经有一个 `[settings]` 表，请将该条目添加到那里；请扩展现有的 `disable_tools` 列表，而不是替换它。确保你的安装位于 `PATH` 上。使用 mise 工具名称，它可能与其命令不同：例如，`oh-my-pi` 提供 `omp`。默认智能体启动器也会优先使用 `~/.local/bin` 中用户安装的 Cursor 或 Muse。

### 移除和恢复默认值

_Remove Preinstalls_ 会让 mise 跳过 Omarchy 针对你的用户的工具声明，做法是将它们添加到 `~/.config/mise/miserc.toml` 中的 `ignored_config_paths`。_Restore Preinstalls_ 则会再次移除那一行。无论哪种情况，你自己声明的工具，无论是在你自己的配置中还是在某个项目的 `mise.toml` 中，都会继续工作。如果你移除预装项后选择了默认智能体或设置了 Python，该工具会被添加到你自己的配置中。两者都仅适用于你的用户；这台机器上的其他用户保留他们自己的选择。

## Docker

[Docker](https://www.docker.com/) 几乎无需介绍。它允许你运行隔离的容器，而 Omarchy 安装了出色运行它所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

默认情况下，你的用户*不*在 `docker` 组中。该组实际等同于无密码的 root —— 组中的任何东西都可以执行 `docker run -v /:/host` 并接管这台机器 —— 因此，一个以你的身份运行的流氓脚本或依赖，否则离 root 就只差一条命令。所以在命令行上，你要用 `sudo` 运行 Docker（`sudo docker ps`、`sudo docker compose up`），而与守护进程通信的图形工具 —— Windows VM —— 在需要时会请求授权。如果你想要恢复无组设置的便利，并理解其中的取舍，请从 **Setup > Security > Sudoless Docker** 启用它（或运行 `omarchy-setup-security-sudoless-docker`），它会在发出警告后将你添加到 `docker` 组；之后，普通的 `docker` 和 `d` 别名就又可以不用 `sudo` 运行了。

你可以在 Omarchy 菜单中使用 _Install > Development > Docker DB_，在 Docker 中为本地开发设置常用数据库。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 以 `gh` 的形式提供，用于从终端处理仓库、问题和拉取请求。运行 `gh auth login` 在首次使用时安装它并完成身份验证，然后运行 `gh repo clone org/repo` 克隆一个仓库。运行 `gh --help` 探索它的命令。

对于拉取请求的终端界面，运行 `ghui`；mise 也会在首次使用时安装它。[Lazygit](https://github.com/jesseduffield/lazygit) 已预装，用于处理 Git 本身。
