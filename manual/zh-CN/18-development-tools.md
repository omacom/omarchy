# 开发工具

## 替代编辑器

Omarchy 在新安装中默认搭载 Plain 作为编辑器，并预装了 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一点的东西，可以运行 Omarchy Menu（`Super + Space`），看看 _Install > Editor_ 下的选项。那里列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果你没找到想要的，可以看看 _Install > Package_，看它是不是在某个 Arch 软件包里（如果不在，再试试 _Install > AUR_ 查看 AUR）。

原始的 `vi` 编辑器也开箱可用。运行 `vi filename` 即可在终端中编辑文件。

系统为 `VSCode`、`Cursor`、`VSCodium` 和 `Helix` 提供主题匹配。

你可以在 `Setup > Defaults > Editor` 下设置系统范围的默认编辑器。

## 环境

Omarchy 支持通过 Omarchy Menu（`Super + Space`）的 _Install > Development_ 部分设置一整套开发环境。当然能找到 _Ruby on Rails_，还有 JavaScript 的三大运行时（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等流行的 PHP 框架。哦，还有 Go、Rust、Python、Java、Elixir（附 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。选择非常丰富！

这些环境大多由 [Mise](https://mise.jdx.dev/) 管理。它是一款能让你在同一台机器上安装并运行同一编程语言多个版本的工具。它就像 Ruby 的 rbenv 或 rvm，或 Python 的 virtualenv，但它适用于一大堆不同的环境。

比如要安装 Ruby，你可以运行 `mise use -g ruby`，它会同时安装 Ruby 并将其设为全局默认。或者，如果你的项目有 .ruby-version 文件，你只需在该项目的根目录运行 `mise i` 即可。

## 预装的 CLI 工具

`uv`、Node.js 和 `playwright-cli`（供智能体使用已安装的 Chrome 驱动浏览器）以软件包形式预装，`omarchy update` 会让它们与系统其他部分保持同步。[Hunk](https://github.com/modem-dev/hunk) 以及 GitHub、Basecamp、Cloudflare 和 HEY 的 CLI 在 _Install > CLI_ 下一选即可，[编程智能体](17-ai.md) 则在 _Install > AI > CLI_ 下。

mise 只管理你从 _Install > Development_ 设置的运行时；Omarchy 本身不会通过它安装任何东西。运行 `omarchy update` 即可将它们与 Omarchy 的其余部分一同更新；`mup` 别名则只更新由 mise 管理的工具。要向你自己的配置中添加另一个工具，请使用 `mise use -g <tool>`。

## Docker

[Docker](https://www.docker.com/) 几乎无需介绍。它让你能运行隔离的容器，而 Omarchy 会安装把它用好所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

默认情况下，你的用户*不在* `docker` 组中。该组实际上等同于免密码的 root——组里的任何东西都可以 `docker run -v /:/host` 并接管整台机器——所以否则，一个以你的身份运行的流氓脚本或依赖就只差一条命令便能拿到 root。因此，在命令行中，你要带 `sudo` 运行 Docker（`sudo docker ps`、`sudo docker compose up`），而与守护进程通信的图形工具——Windows VM——会在需要时请求授权。如果你想要回无组配置的便利，并明白其中的取舍，可以从 **Setup > Security > Sudoless Docker** 启用它（或运行 `omarchy-setup-security-sudoless-docker`），它会在发出警告后将你加入 `docker` 组；之后，普通的 `docker` 和 `d` 别名就又能免 `sudo` 使用了。

你可以在 Omarchy 菜单中使用 _Install > Development > Docker DB_ 在 Docker 中设置用于本地开发的常用数据库。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 就是 `gh`，用于从终端处理仓库、issue 和 pull request。当你在 _Setup > Git_ 中选择登录 GitHub 时，它会被安装，或者你也可以从 _Install > CLI > GitHub_ 单独安装它。之后，`gh repo clone org/repo` 即可克隆一个仓库；运行 `gh --help` 探索它的命令。

[Lazygit](https://github.com/jesseduffield/lazygit) 已预装，用于处理 Git 本身。
