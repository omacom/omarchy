# 開發工具

## 其他編輯器

Omarchy 新安裝預設搭載 Plain 作為預設編輯器，並預先安裝 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一點的東西，你可以開啟 Omarchy Menu（`Super + Space`），查看 _Install > Editor_ 下的選項。那裡列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果你找不到想要的，看看 _Install > Package_，看它是不是在某個 Arch 套件裡（如果不在，試試 _Install > AUR_ 檢查 AUR）。

原始的 `vi` 編輯器也開箱即用。在終端機執行 `vi filename` 就能編輯檔案。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 提供主題配對功能。

你可以在 `Setup > Defaults > Editor` 設定全系統預設編輯器。

## 環境

Omarchy 支援透過 Omarchy Menu（`Super + Space`）的 _Install > Development_ 區段設定一整套開發環境。你當然會找到 _Ruby on Rails_，還有 JavaScript 的三大主要執行環境（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等熱門 PHP 框架。哦，還有 Go、Rust、Python、Java、Elixir（連 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。選擇非常廣泛！

這些環境大多由 [Mise](https://mise.jdx.dev/) 管理。這個工具讓你能在同一台機器上安裝並執行程式語言的多個版本。它有點像 Ruby 的 rbenv 或 rvm，或 Python 的 virtualenv，但它能用在許多不同的環境上。

舉例來說，要安裝 Ruby，你會執行 `mise use -g ruby`，這會同時安裝 Ruby 並將它設為全域預設。或者，如果你的專案有 .ruby-version 檔案，你只要在該專案的根目錄執行 `mise i` 就好。

## 預先安裝的 CLI 工具

`uv`、Node.js 和 `playwright-cli`（供 agents 操作瀏覽器，使用已安裝的 Chrome）會以套件形式預先安裝，而 `omarchy update` 會讓它們與系統其他部分保持最新。[Hunk](https://github.com/modem-dev/hunk) 以及 GitHub、Basecamp、Cloudflare 和 HEY 的 CLI 都在 _Install > CLI_ 下，點一下就能裝，而[編碼 agents](17-ai.md) 則在 _Install > AI > CLI_ 下。

mise 只管理你從 _Install > Development_ 設定的執行環境；Omarchy 本身不會透過它安裝任何東西。執行 `omarchy update` 就能連同 Omarchy 其他部分一起更新它們；`mup` 這個 alias 則只更新 mise 管理的工具。若要把其他工具加到你自己的設定中，使用 `mise use -g <tool>`。

## Docker

[Docker](https://www.docker.com/) 幾乎不需要介紹。它讓你能執行隔離的容器，而 Omarchy 會安裝讓它好好運行所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

預設情況下，你的使用者*不*在 `docker` 群組中。那個群組實際上等同於免密碼的 root——其中任何東西都可以執行 `docker run -v /:/host` 並接管整台機器——所以一個以你的身分運行的惡意指令碼或相依套件，否則只要一個指令就能取得 root。因此在命令列上，你要用 `sudo` 執行 Docker（`sudo docker ps`、`sudo docker compose up`），而與 daemon 通訊的圖形工具——Windows VM——會在需要時要求授權。如果你想要重新享有免 sudo 的方便，並了解其中的取捨，可以從 **Setup > Security > Sudoless Docker** 啟用它（或執行 `omarchy-setup-security-sudoless-docker`），它會在警告後將你加入 `docker` 群組；之後一般的 `docker` 和 `d` 這個 alias 就能再次不加 `sudo` 使用。

你可以使用 Omarchy 選單中的 _Install > Development > Docker DB_，在 Docker 中設定本機開發常用的資料庫。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 就是 `gh`，用來在終端機中處理儲存庫、issues 和 pull requests。當你在 _Setup > Git_ 選擇登入 GitHub 時，它會安裝它，或者你可以從 _Install > CLI > GitHub_ 單獨安裝它。接著 `gh repo clone org/repo` 就能複製一個儲存庫；執行 `gh --help` 探索它的指令。

[Lazygit](https://github.com/jesseduffield/lazygit) 已預先安裝，用來操作 Git 本身。
