# 開發工具

## 其他編輯器

Omarchy 新安裝時以 Plain 作為預設編輯器，也預先安裝了 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一點的選擇，可以開啟 Omarchy Menu (`Super + Space`)，看看 _安裝 > 編輯器_ 底下的選項。那裡列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果找不到你想要的，去看看 _安裝 > 套件_，確認它是不是在 Arch 套件裡（如果不在，就試試 _安裝 > AUR_ 來查 AUR）。

原始的 `vi` 編輯器也開箱即用。在終端機執行 `vi filename` 就能編輯檔案。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 都提供主題配對功能。

你可以在 `Setup > Defaults > Editor` 設定全系統預設編輯器。

## 環境

Omarchy 支援透過 Omarchy Menu (`Super + Space`) 的 _安裝 > 開發_ 區段設定一大堆開發環境。你當然會找到 _Ruby on Rails_，還有 JavaScript 的三大主要執行環境（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等熱門 PHP 框架。喔，還有 Go、Rust、Python、Java、Elixir（搭配 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。選擇非常齊全！

這些環境大多由 [Mise](https://mise.jdx.dev/) 管理。它是一款能讓你在同一台機器上安裝並執行多個程式語言版本的工具。它就像 Ruby 的 rbenv 或 rvm，或 Python 的 virtualenv，但適用於一大堆不同的環境。

舉例來說，要安裝 Ruby，你可以執行 `mise use -g ruby`，這樣既會安裝 Ruby，也會把它設為全域預設版本。或者，如果你的專案有 .ruby-version 檔案，你只要在該專案的根目錄執行 `mise i` 就好。

## 預先安裝的 CLI 工具

Omarchy 透過 [mise 的延遲安裝](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) 提供 `gh`、`uv` 和大多數[程式編碼 agent](17-ai.md) 等工具。你第一次執行其中一個工具時，mise 就會安裝它。程式編碼 agent 接著會在執行前檢查更新，最多每四小時一次；其他工具如 `gh` 和 `uv`，則會沿用已安裝的版本，直到你更新為止。

你也可以查看這些預設工具，或提前先安裝好：

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

執行 `omarchy update` 就能連同 Omarchy 一起更新已安裝的工具。`mup` 別名只會更新 mise 管理的工具。若要把其他工具加入你自己的設定，請使用 `mise use -g <tool>`。

Python 設定也會透過 mise 安裝 `uv`。移除 Python 開發環境後，`uv` 仍可作為獨立工具使用。

### 使用你自己的安裝版本

mise 的指令在 `PATH` 中排在 `~/.local/bin` 之前，所以就算你用 Claude Code 或 Cursor 自己的安裝程式自行安裝了某個工具，實際執行的仍會是 mise 的版本。從桌面啟動的應用程式也會在系統套件之前找到 mise 的指令，所以某個會執行 `gh` 的應用程式，就算你用 pacman 安裝了 `github-cli`，拿到的仍是 mise 的版本，而且 mise 會在第一次執行時安裝那個版本。若要改用你自己的版本，請在 `~/.config/mise/config.toml` 中停用 mise 的版本。例如，如果你自行安裝了 Cursor CLI：

```toml
[settings]
disable_tools = ["cursor-agent"]
```

如果你已經有 `[settings]` 表格，就把這筆項目加在那裡；請擴充現有的 `disable_tools` 清單，不要直接取代它。請確認你的安裝版本位於 `PATH` 上。請使用 mise 工具名稱，它可能和它的指令不同：例如 `oh-my-pi` 提供的是 `omp`。預設 agent 啟動器也會優先使用位於 `~/.local/bin` 中、由使用者自行安裝的 Cursor 或 Muse。

### 移除與還原預設項目

_移除 > 預先安裝項目_ 會移除 Omarchy 預先安裝的 web apps、TUI 和應用程式，並讓 mise 略過 Omarchy 為你的使用者所做的工具宣告，做法是把它們加入 `~/.config/mise/miserc.toml` 中的 `ignored_config_paths`。_安裝 > 預先安裝項目_ 會把它們帶回來，並再次移除那一行。無論哪種情況，你自己宣告的工具（在你自己的設定中，或在專案的 `mise.toml` 中）都能繼續運作。如果你移除預先安裝項目後選擇預設 agent 或設定 Python，該工具會被加入你自己的設定中。這項 mise 設定只適用於你的使用者，其他使用者仍保留他們自己的選擇；不過這些應用程式是套件，所以移除或還原它們會影響機器上的所有人。

## Docker

[Docker](https://www.docker.com/) 幾乎不需要多做介紹。它能讓你執行隔離的容器，而 Omarchy 會安裝讓它順暢運作所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

你的使用者預設*不在* `docker` 群組中。那個群組實際上就等於免密碼的 root——群組中的任何東西都能執行 `docker run -v /:/host` 並接管整台機器——所以只要有一個以你的身分執行的惡意指令碼或相依套件，它離 root 就只差一條指令。因此在指令列上，請用 `sudo` 執行 Docker（`sudo docker ps`、`sudo docker compose up`），而與 daemon 通訊的圖形工具（Windows VM）會在需要時要求授權。如果你想要回免群組設定的方便性，也了解其中的取捨，請從 **設定 > 安全性 > 免 sudo 的 Docker** 啟用它（或執行 `omarchy-setup-security-sudoless-docker`），它會在顯示警告後把你加入 `docker` 群組；之後一般的 `docker` 和 `d` 別名就能再次不需 `sudo` 使用。

你可以使用 Omarchy 選單中的 _安裝 > 開發 > Docker DB_，在 Docker 中設定本機開發常用的資料庫。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 可透過 `gh` 使用，讓你在終端機處理儲存庫、issue 和 pull request。執行 `gh auth login`，它會在第一次使用時安裝並完成驗證，接著執行 `gh repo clone org/repo` 來 clone 一個儲存庫。執行 `gh --help` 就能探索它的指令。

若想用終端機介面處理 pull request，請執行 `ghui`；mise 也會在第一次使用時安裝它。[Lazygit](https://github.com/jesseduffield/lazygit) 已預先安裝，用於處理 Git 本身。
