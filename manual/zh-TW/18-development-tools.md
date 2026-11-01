# 開發工具

## 其他編輯器

Omarchy 預設隨附 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一點的東西，可以開啟 Omarchy Menu（`Super + Space`），查看 _Install > Editor_ 下的選項。那裡列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果找不到你要的，看看 _Install > Package_，確認它是不是在 Arch 套件裡（如果不在，再試試 _Install > AUR_ 查看 AUR）。

原始的 `vi` 編輯器也開箱即用。在終端機執行 `vi filename` 即可編輯檔案。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 提供主題配對功能。

你可以在 `Setup > Defaults > Editor` 下設定全系統預設編輯器。

## 環境

Omarchy 支援透過 Omarchy Menu（`Super + Space`）中的 _Install > Development_ 區段，設定一整套開發環境。你當然會找到 _Ruby on Rails_，也還有 JavaScript 的三大執行環境（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等熱門 PHP 框架。噢，還有 Go、Rust、Python、Java、Elixir（搭配 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。選擇真的非常廣泛！

這些環境大多由 [Mise](https://mise.jdx.dev/) 管理。它是一款讓你能在同一台機器上安裝並執行多個程式語言版本的工具。就像 Ruby 的 rbenv 或 rvm、Python 的 virtualenv，但它能用於一大堆不同的環境。

舉例來說，要安裝 Ruby，你可以執行 `mise use -g ruby`，這會同時安裝 Ruby 並將它設為全域預設。或者，如果你的專案有 .ruby-version 檔案，你只要在該專案的根目錄執行 `mise i` 即可。

## 預先安裝的 CLI 工具

Omarchy 透過 [mise 的延遲安裝](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools)，讓 `gh`、`uv` 以及大多數[程式設計代理](17-ai.md)等工具可供使用。你第一次執行其中一個工具時，mise 會將它安裝。之後的執行會重複使用已安裝的版本；不會在每次啟動時檢查是否有更新。

你也可以查看預設設定，或提前將它們安裝好：

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

執行 `omarchy update` 即可在更新 Omarchy 其餘部分時一併更新已安裝的工具。`mup` 別名則只更新由 mise 管理的工具。若要將另一個工具加入你自己的設定，請使用 `mise use -g <tool>`。

Python 設定也會透過 mise 安裝 `uv`。移除 Python 開發環境後，`uv` 仍會作為獨立工具保留可用。

### 使用你自己安裝的版本

mise 的命令在 `PATH` 中排在 `~/.local/bin` 之前，所以即使是你自己安裝的工具，例如用 Claude Code 或 Cursor 自己的安裝程式裝的，執行的仍然會是 mise 的版本。從桌面啟動的應用程式也會在系統套件之前找到 mise 的命令，所以一個執行 `gh` 的應用程式，拿到的會是 mise 的版本，就算你用 pacman 安裝了 `github-cli` 也一樣，而且 mise 會在第一次執行時安裝那個版本。若要改用你自己的版本，請在 `~/.config/mise/config.toml` 中停用 mise 的版本。例如，如果你自己安裝了 Cursor CLI：

```toml
[settings]
disable_tools = ["cursor-agent"]
```

如果你已經有 `[settings]` 表格，請把該項目加在那裡；如果已有 `disable_tools` 清單，請擴充它，而不是直接取代。請確定你安裝的版本有在 `PATH` 上。請使用 mise 工具名稱，它可能與其命令不同：例如 `oh-my-pi` 提供的是 `omp`。預設 agent 啟動器也會優先使用 `~/.local/bin` 中由使用者自行安裝的 Cursor 或 Muse。

### 移除與還原預設值

_Remove Preinstalls_ 會讓 mise 對你的使用者略過 Omarchy 的工具宣告，做法是將它們加入 `~/.config/mise/miserc.toml` 中的 `ignored_config_paths`。_Restore Preinstalls_ 則會再次移除那一行。你自己宣告的工具，無論是在你自己的設定中，還是在專案的 `mise.toml` 中，無論如何都會繼續運作。如果你移除預先安裝項目後，選擇了預設 agent 或設定了 Python，該工具就會加入你自己的設定中。兩者都只適用於你的使用者；這台機器上的其他使用者會保留他們自己的選擇。

## Docker

[Docker](https://www.docker.com/) 幾乎不需要介紹。它讓你能執行隔離的容器，而 Omarchy 會安裝讓它順暢運作所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

預設情況下，你的使用者*不在* `docker` 群組中。該群組實際上等同於免密碼的 root——群組中的任何東西都能執行 `docker run -v /:/host` 並接管整台機器——所以若非如此，一個以你的身分執行的惡意指令碼或相依套件，就只差一條命令便能取得 root。因此在命令列上，你要用 `sudo` 執行 Docker（`sudo docker ps`、`sudo docker compose up`），而與 daemon 通訊的圖形工具——例如 Windows VM——會在需要時要求授權。如果你想要回無群組設定的便利性，並且了解其中的取捨，請從 **Setup > Security > Sudoless Docker** 啟用它（或執行 `omarchy-setup-security-sudoless-docker`），它會在顯示警告後將你加入 `docker` 群組；之後一般的 `docker` 和 `d` 別名就能再次不需 `sudo` 使用。

你可以使用 Omarchy 選單中的 _Install > Development > Docker DB_，在 Docker 中為本機開發設定常用的資料庫。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 可透過 `gh` 使用，讓你在終端機處理儲存庫、issue 和 pull request。執行 `gh auth login` 即可在首次使用時安裝它並進行驗證，然後執行 `gh repo clone org/repo` 來複製儲存庫。執行 `gh --help` 即可探索它的命令。

若要以終端機介面處理 pull request，請執行 `ghui`；mise 同樣會在首次使用時安裝它。[Lazygit](https://github.com/jesseduffield/lazygit) 已預先安裝，讓你能操作 Git 本身。
