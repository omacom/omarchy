# 開発ツール

## 代替エディタ

Omarchy の新規インストールでは Plain がデフォルトのエディタとして標準搭載され、[Neovim](https://neovim.io/) がプリインストールされていますが、もう少し主流で馴染みのあるものがよければ、Omarchy Menu（`Super + Space`）を開いて、_Install > Editor_ の下にある選択肢を確認してください。そこには VSCode、Cursor、Zed、Sublime Text、Helix、Vim、Emacs が並んでいます。目的のものが見つからなければ、_Install > Package_ を確認して Arch パッケージにないか探してください（それでもなければ、_Install > AUR_ で AUR を確認してみてください）。

オリジナルの `vi` エディタもそのまま使えます。ターミナルでファイルを編集するには `vi filename` を実行してください。

テーマのマッチングは `VSCode`、`Cursor`、`VSCodium`、`Helix` 向けに提供されています。

システム全体のデフォルトエディタは `Setup > Defaults > Editor` で設定できます。

## 開発環境

Omarchy は、Omarchy Menu（`Super + Space`）の _Install > Development_ セクションから、実にさまざまな開発環境のセットアップに対応しています。もちろん _Ruby on Rails_ がありますが、JavaScript の主要な 3 つのランタイム（Node.js、Bun、Deno）や、Laravel や Symfony といった人気の PHP フレームワークもあります。ああ、それから Go、Rust、Python、Java、Elixir（Phoenix 付き）、.NET、OCaml、Zig、Clojure、Scala もあります。実に幅広いラインナップです！

これらの環境の大半は [Mise](https://mise.jdx.dev/) で管理されます。1 台のマシンにプログラミング言語の複数のバージョンをインストールして実行できるツールです。Ruby 向けの rbenv や rvm、Python 向けの virtualenv のようなものですが、さまざまな環境で使えます。

たとえば Ruby をインストールするには `mise use -g ruby` を実行します。これで Ruby がインストールされ、グローバルなデフォルトに設定されます。あるいは、プロジェクトに .ruby-version ファイルがある場合は、そのプロジェクトのルートで `mise i` を実行するだけです。

## プリインストールされた CLI ツール

`uv`、Node.js、`playwright-cli`（エージェントがインストール済みの Chrome を使ってブラウザを操作するためのもの）はパッケージとしてインストールされており、`omarchy update` でシステムの他の部分と一緒に最新に保たれます。[Hunk](https://github.com/modem-dev/hunk) と GitHub、Basecamp、Cloudflare、HEY の CLI は _Install > CLI_ からあと一歩で選べますし、[コーディングエージェント](17-ai.md) は _Install > AI > CLI_ にあります。

mise は _Install > Development_ からセットアップしたランタイムだけを管理します。Omarchy が独自に mise 経由で何かをインストールすることはありません。それらを Omarchy の他の部分と一緒に更新するには `omarchy update` を実行してください。`mup` エイリアスは mise で管理されたツールだけを更新します。自分の設定に別のツールを追加するには `mise use -g <tool>` を使ってください。

## Docker

[Docker](https://www.docker.com/) は今さら紹介するまでもないでしょう。分離されたコンテナを実行でき、Omarchy には Docker 自体と [Docker Compose](https://docs.docker.com/compose/) を含め、Docker を快適に使うために必要なものがすべてインストールされます。

デフォルトでは、あなたのユーザーは `docker` グループに属していません。このグループは実質的にパスワードなしの root です。このグループに属するものなら誰でも `docker run -v /:/host` を実行してマシンを乗っ取れます。つまり、あなたとして実行される悪意のあるスクリプトや依存関係が 1 つあるだけで、あとコマンド 1 つで root になれてしまうのです。そのため、コマンドラインでは `sudo` を使って Docker を実行し（`sudo docker ps`、`sudo docker compose up`）、デーモンと通信するグラフィカルツール ― Windows VM ― は必要なときに認可を求めます。トレードオフを理解したうえで、グループなしの手軽さを取り戻したい場合は、**Setup > Security > Sudoless Docker** から有効にするか（または `omarchy-setup-security-sudoless-docker` を実行してください）、警告の後にあなたを `docker` グループに追加します。そうすれば、プレーンな `docker` と `d` エイリアスが再び `sudo` なしで使えるようになります。

ローカル開発でよく使うデータベースは、Omarchy メニューの _Install > Development > Docker DB_ を使って Docker でセットアップできます。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) は `gh` で、ターミナルからリポジトリ、issue、pull request を操作するためのものです。_Setup > Git_ は、そこで GitHub にサインインすることを選ぶとこれをインストールします。単体でインストールしたい場合は _Install > CLI > GitHub_ からどうぞ。その後、`gh repo clone org/repo` でリポジトリをクローンできます。コマンドを調べるには `gh --help` を実行してください。

[Lazygit](https://github.com/jesseduffield/lazygit) は Git 自体を操作するためにプリインストールされています。
