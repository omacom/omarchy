# 開発ツール

## 代替エディタ

Omarchy はデフォルトで [Neovim](https://neovim.io/) を同梱していますが、もっとメインストリームで馴染みのあるものがよければ、Omarchy メニュー（`Super + Space`）を開いて _インストール > Editor_ の選択肢を見てください。VSCode、Cursor、Zed、Sublime Text、Helix、Vim、Emacs が並んでいます。探しているものが見つからなければ、_インストール > Package_ を確認して Arch パッケージにないか探してください（それでもなければ、_インストール > AUR_ で AUR を確認してください）。

元祖 `vi` エディタも最初から使えます。ターミナルでファイルを編集するには `vi filename` を実行してください。

テーマの一致は `VSCode`、`Cursor`、`VSCodium`、`Helix` で提供されています。

システム全体のデフォルトエディタは `設定 > Defaults > Editor` で設定できます。

## 環境

Omarchy は Omarchy メニュー（`Super + Space`）の _インストール > Development_ セクションから、さまざまな開発環境のセットアップをサポートしています。もちろん _Ruby on Rails_ がありますが、JavaScript の3大ランタイム（Node.js、Bun、Deno）はもちろん、Laravel や Symfony のような人気の PHP フレームワークもあります。ああ、それから Go、Rust、Python、Java、Elixir（Phoenix 付き）、.NET、OCaml、Zig、Clojure、Scala もあります。とても幅広い選択肢です！

これらの環境の大半は [Mise](https://mise.jdx.dev/) で管理されています。これは同じマシン上にプログラミング言語の複数バージョンをインストールして実行できるツールです。Ruby における rbenv や rvm、Python における virtualenv のようなものですが、さまざまな環境で動作します。

たとえば Ruby をインストールするには `mise use -g ruby` を実行します。これで Ruby がインストールされ、グローバルデフォルトとして設定されます。あるいは、プロジェクトに .ruby-version ファイルがある場合は、そのプロジェクトのルートで `mise i` を実行するだけです。

## Docker

[Docker](https://www.docker.com/) は改めて説明するまでもないでしょう。分離されたコンテナを実行でき、Omarchy は Docker 本体や [Docker Compose](https://docs.docker.com/compose/) など、それをうまく動かすために必要なものをすべてインストールします。

デフォルトではあなたのユーザーは `docker` グループに*入っていません*。そのグループは実質的にパスワードなしの root です — そのグループに属するものは `docker run -v /:/host` を実行してマシンを乗っ取れます — したがって、あなたとして実行される悪意のあるスクリプトや依存関係が1つあるだけで、root まであと1コマンドという状態になってしまいます。そこでコマンドラインでは Docker を `sudo` で実行し（`sudo docker ps`、`sudo docker compose up`）、デーモンと通信するグラフィカルツール — Windows VM — は必要なときに許可を求めます。グループなしのセットアップの便利さを取り戻したい場合で、そのトレードオフを理解しているなら、**設定 > Security > Sudoless Docker** から有効にしてください（または `omarchy-setup-security-sudoless-docker` を実行してください）。警告の後にあなたが `docker` グループに追加され、プレーンな `docker` と `d` エイリアスが再び `sudo` なしで使えるようになります。

ローカル開発用の一般的なデータベースは、Omarchy メニューの _インストール > Development > Docker DB_ を使って Docker でセットアップできます。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) を使えば GitHub アカウントで認証し、それを使ってプライベートリポジトリをクローンできます。これは遅延ロードされる mise スタブの1つとして組み込まれているため、初めて `gh` を実行したときに自動でインストールされます。認証するには `gh auth login` を実行してください。その後は `gh repo clone org/repo` を使ってプライベートリポジトリをチェックアウトできます。

このコマンドを使って他の GitHub 操作もたくさん実行できます。`gh` を実行すればできることがすべて表示されます。

プルリクエストを TUI で管理するための `ghui` の遅延インストールスタブもあります。さらに git 自体も TUI から操作したいなら、[lazygit](https://github.com/jesseduffield/lazygit) がプリインストールされています。
