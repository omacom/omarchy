# 开发工具

## 替代编辑器

Omarchy 在新安装中默认配备 Plain 编辑器，并预装了 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一点的东西，可以运行 Omarchy Menu（`Super + Space`），看看 _Install > Editor_ 下的选项。那里列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果你没找到想要的，可以瞧瞧 _Install > Package_，看看它是不是在某个 Arch 软件包里（如果不在，再试试 _Install > AUR_ 查看 AUR）。

原版的 `vi` 编辑器也开箱即用。运行 `vi filename` 即可在终端中编辑文件。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 提供主题匹配。

你可以在 `Setup > Defaults > Editor` 下设置系统范围的默认编辑器。

## 环境

Omarchy 支持通过 Omarchy Menu（`Super + Space`）的 _Install > Development_ 部分设置一大堆开发环境。你当然会找到 _Ruby on Rails_，还有 JavaScript 的三大主要运行时（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等流行的 PHP 框架。哦，还有 Go、Rust、Python、Java、Elixir（搭配 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。选择非常丰富！

这些环境中的绝大多数都由 [Mise](https://mise.jdx.dev/) 管理。它是一个让你在同一台机器上安装和运行某个编程语言的多个版本的工具。它就像 Ruby 的 rbenv 或 rvm，或者 Python 的 virtualenv，但它能用于一大堆不同的环境。

比如说，要安装 Ruby，你可以运行 `mise use -g ruby`，它既会安装 Ruby，也会将其设置为全局默认版本。或者，如果你的项目有一个 .ruby-version 文件，你只需在该项目的根目录运行 `mise i` 即可。

## 预装的 CLI 工具

Omarchy 通过 [mise 的延迟安装](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) 提供 `gh`、`uv` 等工具，以及大多数[编程智能体](17-ai.md)。你第一次运行其中某个工具时，mise 会安装它。之后，编程智能体在运行前会检查更新，最多每四小时一次；`gh` 和 `uv` 等其他工具则会复用已安装的版本，直到你更新为止。

你也可以查看这些默认工具，或者提前安装它们：

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

运行 `omarchy update` 可以在更新 Omarchy 其余部分的同时更新已安装的工具。`mup` 别名则只更新 mise 管理的工具。要把另一个工具添加到你自己的配置中，请使用 `mise use -g <tool>`。

Python 设置也会通过 mise 安装 `uv`。移除 Python 开发环境后，`uv` 仍会作为一个独立工具保留。

### 使用你自己的安装

mise 的命令在 `PATH` 中排在 `~/.local/bin` 之前，所以即便你自己安装了某个工具，例如用 Claude Code 或 Cursor 自己的安装程序安装的，运行的仍然是 mise 的副本。从桌面启动的应用也会在系统软件包之前找到 mise 的命令，所以一个运行 `gh` 的应用会得到 mise 的副本，即使你已经用 pacman 安装了 `github-cli`，而且 mise 会在第一次时安装那个副本。要改用你自己的版本，请在 `~/.config/mise/config.toml` 中禁用 mise 的副本。例如，如果你自己安装了 Cursor CLI：

```toml
[settings]
disable_tools = ["cursor-agent"]
```

如果你已经有一个 `[settings]` 表，就把这一项加在那里；扩展现有的 `disable_tools` 列表，而不是替换它。确保你的安装在 `PATH` 上。使用 mise 的工具名称，它可能与它的命令不同：例如 `oh-my-pi` 提供的是 `omp`。默认智能体启动器也优先使用 `~/.local/bin` 中由用户安装的 Cursor 或 Muse。

### 删除和恢复默认项

_Remove > Preinstalls_ 会移除 Omarchy 预装的 web 应用、TUI 和应用，并让 mise 为你的用户跳过 Omarchy 的工具声明，具体做法是把它们添加到 `~/.config/mise/miserc.toml` 的 `ignored_config_paths` 中。_Install > Preinstalls_ 会把它们带回来，并再次移除那一行。你自己声明的工具，无论是在你自己的配置中还是在某个项目的 `mise.toml` 中，两种情况下都会继续工作。如果你在移除预装项后选择了一个默认智能体或设置了 Python，那个工具会被添加进你自己的配置中。这个 mise 设置只适用于你的用户，其他用户会保留他们自己的选择；不过这些应用都是软件包，所以移除或恢复它们会改变机器上每个人的这些应用。

## Docker

[Docker](https://www.docker.com/) 几乎不需要任何介绍。它让你运行隔离的容器，而 Omarchy 会安装把它运行好所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

默认情况下，你的用户*不在* `docker` 组中。这个组实际上等同于免密码 root——组里的任何东西都可以 `docker run -v /:/host` 并接管机器——所以一个以你的身份运行的流氓脚本或依赖，否则只需一条命令就能拿到 root。因此，在命令行上你要用 `sudo` 运行 Docker（`sudo docker ps`，`sudo docker compose up`），而与守护进程通信的图形工具——Windows VM——会在需要时请求授权。如果你想恢复无组设置的便利，并理解其中的取舍，可以从 **Setup > Security > Sudoless Docker** 启用它（或运行 `omarchy-setup-security-sudoless-docker`），它会在发出警告后把你加入 `docker` 组；之后，普通的 `docker` 和 `d` 别名又可以不用 `sudo` 工作了。

你可以使用 Omarchy 菜单中的 _Install > Development > Docker DB_ 在 Docker 中设置本地开发常用的数据库。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 以 `gh` 的形式提供，用于从终端处理仓库、issue 和 pull request。运行 `gh auth login` 可以在首次使用时安装它并完成身份验证，然后运行 `gh repo clone org/repo` 克隆一个仓库。运行 `gh --help` 探索它的命令。

至于 pull request 的终端界面，运行 `ghui`；mise 也会在首次使用时安装它。[Lazygit](https://github.com/jesseduffield/lazygit) 已预装，用于处理 Git 本身。
