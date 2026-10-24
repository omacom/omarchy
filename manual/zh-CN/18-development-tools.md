# 开发工具

## 其他编辑器

Omarchy 默认自带 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一点的选择，可以打开 Omarchy 菜单（`Super + Space`），在_安装 > Editor_下查看选项。那里列有 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果没找到想要的，可以看看_安装 > Package_，看它是否在某个 Arch 软件包里（如果没有，再试试_安装 > AUR_查看 AUR）。

原版的 `vi` 编辑器也是开箱即用的。运行 `vi filename` 即可在终端里编辑文件。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 提供主题匹配。

你可以在 `Setup > Defaults > Editor` 下设置系统级默认编辑器。

## 开发环境

Omarchy 支持通过 Omarchy 菜单（`Super + Space`）的_安装 > Development_部分设置一大堆开发环境。你当然能找到 _Ruby on Rails_，还有 JavaScript 的三大运行时（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等流行的 PHP 框架。哦，还有 Go、Rust、Python、Java、Elixir（带 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。选择非常丰富！

这些环境大多由 [Mise](https://mise.jdx.dev/) 管理。它是一个让你在同一台机器上安装和运行编程语言多个版本的工具。就像 Ruby 的 rbenv 或 rvm、Python 的 virtualenv，只不过它适用于一大堆不同的环境。

比如要安装 Ruby，你可以运行 `mise use -g ruby`，它会安装 Ruby 并将其设为全局默认。或者，如果你的项目有 .ruby-version 文件，你只需在该项目的根目录运行 `mise i`即可。

## Docker

[Docker](https://www.docker.com/) 几乎无需介绍。它让你运行隔离的容器，Omarchy 安装了运行它所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

默认情况下，你的用户*不*在 `docker` 组中。这个组实际上等同于免密码的 root——组内任何东西都能执行 `docker run -v /:/host` 并接管整台机器——所以一个以你的身份运行的流氓脚本或依赖，否则一条命令就能拿到 root。因此在命令行里你用 `sudo` 运行 Docker（`sudo docker ps`、`sudo docker compose up`），而与守护进程通信的图形工具——Windows 虚拟机——会在需要时请求授权。如果你想恢复无组设置的便利并理解其中的取舍，可以从 **Setup > Security > Sudoless Docker** 启用它（或运行 `omarchy-setup-security-sudoless-docker`），它会在发出警告后将你加入 `docker` 组；之后普通的 `docker` 和 `d` 别名就又能不用 `sudo` 工作了。

你可以使用 Omarchy 菜单中的_安装 > Development > Docker DB_，在 Docker 中设置本地开发常用的数据库。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 让你用 GitHub 账户认证并用它克隆私有仓库。它被接为 mise 的延迟加载存根之一，所以你第一次运行 `gh` 时，它会自行安装。要认证，运行 `gh auth login`。然后你就可以用 `gh repo clone org/repo` 检出私有仓库。

你还可以用这个命令执行一大堆其他 GitHub 操作。运行 `gh` 就能看到所有可用的功能。

还有一个延迟安装的 `ghui` 存根，可以在 TUI 中管理你的拉取请求。如果你也想从 TUI 驱动 git 本身，[lazygit](https://github.com/jesseduffield/lazygit) 已预装。
