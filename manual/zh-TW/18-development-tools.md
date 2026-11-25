# 開發工具

## 替代編輯器

Omarchy 在新安裝時以 Plain 作為預設編輯器，並預先安裝了 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉一點的選擇，可以開啟 Omarchy Menu（`Super + Space`），查看 _安裝 > 編輯器_ 下的選項。那裡列有 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果你找不到想要的，看看 _安裝 > 套件_，確認它是不是在某個 Arch 套件裡（如果不在，試試 _安裝 > AUR_ 來查 AUR）。

原始的 `vi` 編輯器也開箱即用。在終端機裡執行 `vi filename` 就能編輯檔案。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 都提供主題配對功能。

你可以在 `Setup > Defaults > Editor` 下設定全系統的預設編輯器。

## 開發環境

Omarchy 支援透過 Omarchy Menu（`Super + Space`）的 _安裝 > 開發_ 區段，設定各式各樣的開發環境。你當然會找到 _Ruby on Rails_，還有 JavaScript 的三大主要執行環境（Node.js、Bun、Deno），以及 Laravel 和 Symfony 等熱門 PHP 框架。哦，還有 Go、Rust、Python、Java、Elixir（附 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。選擇非常豐富！

這些環境大多由 [Mise](https://mise.jdx.dev/) 管理。它是一款讓你在同一台機器上安裝並執行某個程式語言多個版本的工具。它就像 Ruby 的 rbenv 或 rvm、Python 的 virtualenv，但適用於一大堆不同的環境。

舉例來說，要安裝 Ruby，你可以執行 `mise use -g ruby`，這會同時安裝 Ruby，並將它設為全域預設值。或者，如果你的專案裡有 .ruby-version 檔案，你只要在該專案的根目錄執行 `mise i` 就行了。

## 預先安裝的 CLI 工具

`uv`、Node.js 和 `playwright-cli`（供 agent 使用已安裝的 Chrome 來操控瀏覽器）會以套件形式安裝，`omarchy update` 會讓它們與系統其他部分一起保持在最新狀態。`ghui`、[Hunk](https://github.com/modem-dev/hunk)，以及 Basecamp、Cloudflare 和 HEY 的 CLI，只要到 _安裝 > CLI_ 下點選就能取得，而[程式撰寫代理程式](17-ai.md)則在 _安裝 > AI > CLI_ 下。

mise 只管理你從 _安裝 > 開發_ 設定好的執行環境；Omarchy 本身不會透過它安裝任何東西。執行 `omarchy update` 就能把它們與 Omarchy 其他部分一起更新；`mup` 別名則只更新由 mise 管理的工具。若要把另一個工具加入你自己的設定，請使用 `mise use -g <tool>`。

## Docker

[Docker](https://www.docker.com/) 幾乎不需要介紹。它讓你能執行隔離的容器，而 Omarchy 安裝了讓它順暢運作所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

預設情況下，你的使用者 *不在* `docker` 群組裡。該群組實際上就等於免密碼的 root —— 裡面的任何東西都能執行 `docker run -v /:/host` 並接管整台機器 —— 所以只要有一個以你的身分執行的惡意指令稿或相依套件，原本就只需要一道命令便能取得 root。因此在命令列上，你要用 `sudo` 來執行 Docker（`sudo docker ps`、`sudo docker compose up`），而與 daemon 通訊的圖形工具 —— Windows VM —— 會在需要時向你請求授權。如果你想要回免群組設定的便利，也明白其中的取捨，可以從 **設定 > 安全性 > Sudoless Docker** 啟用它（或執行 `omarchy-setup-security-sudoless-docker`），它會在顯示警告後把你加入 `docker` 群組；之後，單純的 `docker` 和 `d` 別名就能再次不需 `sudo` 直接運作。

你可以使用 Omarchy 選單中的 _安裝 > 開發 > Docker DB_，在 Docker 裡設定本機開發常用的資料庫。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 就是 `gh`，用來從終端機處理儲存庫、issue 和 pull request。當你在 _設定 > Git_ 裡選擇登入 GitHub 時，它就會安裝好，接著 `gh repo clone org/repo` 就能複製一個儲存庫。執行 `gh --help` 來探索它的命令。

_安裝 > CLI > GitHub_ 會安裝 GitHub CLI，也就是 `gh`，同時還有 `ghui`，一個用來處理 pull request 的終端機介面。[Lazygit](https://github.com/jesseduffield/lazygit) 則已預先安裝，用來處理 Git 本身的操作。
