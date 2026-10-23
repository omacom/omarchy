# 開發工具

## 其他編輯器

Omarchy 預設附帶 [Neovim](https://neovim.io/)，但如果你想要更主流、更熟悉的選擇，可以開啟 Omarchy 選單（`Super + Space`），查看 _安裝 > Editor_ 下的選項。那裡列出了 VSCode、Cursor、Zed、Sublime Text、Helix、Vim 和 Emacs。如果找不到想要的，看看 _安裝 > Package_，確認它是否在某個 Arch 套件裡（如果沒有，試試 _安裝 > AUR_ 查 AUR）。

原始的 `vi` 編輯器也開箱即用。執行 `vi filename` 即可在終端機中編輯檔案。

`VSCode`、`Cursor`、`VSCodium` 和 `Helix` 都支援主題配對。

你可以在 `設定 > 預設值 > Editor` 設定全系統的預設編輯器。

## 開發環境

Omarchy 可透過 Omarchy 選單（`Super + Space`）的 _安裝 > Development_ 區段設定一大票開發環境。當然有 _Ruby on Rails_，也有 JavaScript 的三大執行階段（Node.js、Bun、Deno），以及 Laravel、Symfony 等熱門 PHP 框架。喔，還有 Go、Rust、Python、Java、Elixir（搭配 Phoenix）、.NET、OCaml、Zig、Clojure 和 Scala。選擇非常豐富！

這些環境大多由 [Mise](https://mise.jdx.dev/) 管理。它讓你在同一台機器上安裝並執行某個程式語言的多個版本。就像 Ruby 的 rbenv 或 rvm、Python 的 virtualenv，但它適用於一大堆不同的環境。

舉例來說，要安裝 Ruby，執行 `mise use -g ruby`，它會安裝 Ruby 並將其設為全域預設。或者，如果你的專案有 .ruby-version 檔案，只要在專案根目錄執行 `mise i` 即可。

## Docker

[Docker](https://www.docker.com/) 幾乎不需要介紹。它讓你執行隔離的容器，而 Omarchy 會安裝好好執行它所需的一切，包括 Docker 本身和 [Docker Compose](https://docs.docker.com/compose/)。

預設情況下，你的使用者*不在* `docker` 群組中。該群組實際上等於免密碼的 root——群組中的任何東西都能執行 `docker run -v /:/host` 並接管整台機器——所以否則一個以你身分執行的惡作劇指令碼或相依套件，就只差一條命令便能取得 root。因此在命令列上你用 `sudo` 執行 Docker（`sudo docker ps`、`sudo docker compose up`），而與 daemon 對話的圖形工具——例如 Windows VM——在需要時會要求授權。如果你想恢復無群組設定的便利並了解其中取捨，可以從 **設定 > Security > Sudoless Docker** 啟用（或執行 `omarchy-setup-security-sudoless-docker`），它會在警告後把你加入 `docker` 群組；之後普通的 `docker` 和 `d` 別名就又能不加 `sudo` 使用了。

你可以在 Omarchy 選單中使用 _安裝 > Development > Docker DB_，在 Docker 中設定常見的本地開發資料庫。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) 讓你以 GitHub 帳戶驗證身分，並用它複製私人儲存庫。它接入了 mise 的延遲載入 stub 機制，所以你第一次執行 `gh` 時，它會自行安裝。要驗證身分，執行 `gh auth login`。然後你就能用 `gh repo clone org/repo` 取出私人儲存庫。

你還能用這個命令執行許多其他 GitHub 操作。只要執行 `gh` 就能看到所有可能的操作。

還有一個延遲安裝的 `ghui` stub，可在 TUI 中管理你的 pull request。另外也預先安裝了 [lazygit](https://github.com/jesseduffield/lazygit)，如果你也想在 TUI 中驅動 git 本身的話。
