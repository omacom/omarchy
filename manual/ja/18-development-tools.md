# 開発ツール

## 代替エディター

Omarchy は新しいインストールではデフォルトのエディターとして Plain を搭載し、[Neovim](https://neovim.io/) もプリインストールされていますが、もう少し主流で馴染みのあるものがよければ、Omarchy Menu（`Super + Space`）を開いて _Install > Editor_ の下にある選択肢を見てみてください。VSCode、Cursor、Zed、Sublime Text、Helix、Vim、Emacs がそこに並んでいます。探しているものが見つからなければ、_Install > Package_ を調べて、Arch パッケージにないか確認してみてください（それでもなければ、_Install > AUR_ で AUR を調べてみてください）。

オリジナルの `vi` エディターもそのまま使えます。ターミナルでファイルを編集するには `vi filename` を実行してください。

テーマのマッチングは `VSCode`、`Cursor`、`VSCodium`、`Helix` 向けに提供されています。

システム全体のデフォルトエディターは `Setup > Defaults > Editor` で設定できます。

## 開発環境

Omarchy は Omarchy Menu（`Super + Space`）の _Install > Development_ セクションから、数多くの開発環境のセットアップに対応しています。もちろん _Ruby on Rails_ がありますが、JavaScript の主要な 3 つのランタイム（Node.js、Bun、Deno）も、Laravel や Symfony のような人気の PHP フレームワークもあります。ああ、それに Go、Rust、Python、Java、Elixir（Phoenix 付き）、.NET、OCaml、Zig、Clojure、Scala もあります。実に幅広いラインナップです！

これらの環境の大半は [Mise](https://mise.jdx.dev/) で管理されています。これは、同じマシンにプログラミング言語の複数のバージョンをインストールして実行できるツールです。Ruby 向けの rbenv や rvm、Python 向けの virtualenv のようなものですが、さまざまな環境で使えます。

たとえば Ruby をインストールするには `mise use -g ruby` を実行します。これで Ruby のインストールとグローバルなデフォルトへの設定の両方が行われます。あるいは、プロジェクトに .ruby-version ファイルがある場合は、そのプロジェクトのルートで `mise i` を実行するだけです。

## プリインストール済み CLI ツール

Omarchy では `gh`、`uv`、そしてほとんどの[コーディングエージェント](17-ai.md) のようなツールを [mise の遅延インストール](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools) 経由で利用できます。初めて実行したときに mise がインストールします。その後、コーディングエージェントは実行前に、最大で 4 時間に 1 回だけアップデートを確認します。`gh` や `uv` のような他のツールは、あなたがアップデートするまでインストール済みのバージョンを使い続けます。

デフォルトを確認したり、事前にインストールしたりもできます：

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

`omarchy update` を実行すると、Omarchy の残りの部分と一緒にインストール済みツールもアップデートされます。`mup` エイリアスは mise で管理されているツールだけをアップデートします。自分の設定に別のツールを追加するには `mise use -g <tool>` を使ってください。

Python のセットアップでは mise 経由で `uv` もインストールされます。Python の開発環境を削除しても、`uv` は独立したツールとして利用できるまま残ります。

### 独自のインストールを使う

mise のコマンドは `PATH` 上で `~/.local/bin` より前に来るため、たとえば Claude Code や Cursor 独自のインストーラーで自分でインストールしたツールでも、mise のコピーが実行されます。デスクトップから起動したアプリもシステムパッケージより前に mise のコマンドを見つけるため、`gh` を実行するアプリは、pacman で `github-cli` をインストールしていても mise のコピーを使い、mise は初回にそのコピーをインストールします。代わりに自分のものを使いたい場合は、`~/.config/mise/config.toml` で mise のコピーを無効にしてください。たとえば、Cursor CLI を自分でインストールした場合は次のようにします：

```toml
[settings]
disable_tools = ["cursor-agent"]
```

すでに `[settings]` テーブルがある場合は、そこに項目を追加してください。既存の `disable_tools` リストがある場合は、置き換えるのではなく拡張してください。自分のインストールが `PATH` 上にあることを確認してください。mise のツール名を使ってください。コマンド名と異なる場合があります。たとえば `oh-my-pi` が提供するのは `omp` です。デフォルトエージェントのランチャーも、`~/.local/bin` にあるユーザーがインストールした Cursor や Muse を優先します。

### デフォルトの削除と復元

_Remove > Preinstalls_ は Omarchy のプリインストール済み Web アプリ、TUI、アプリを削除し、`~/.config/mise/miserc.toml` の `ignored_config_paths` に追加することで、mise があなたのユーザー向けの Omarchy のツール宣言をスキップするようにします。_Install > Preinstalls_ はそれらを元に戻し、その行を再び削除します。あなた自身の設定やプロジェクトの `mise.toml` で自分で宣言したツールは、どちらの場合でも動作し続けます。プリインストールを削除した後にデフォルトエージェントを選んだり Python をセットアップしたりすると、そのツールはあなた自身の設定に追加されます。mise の設定はあなたのユーザーにのみ適用され、他のユーザーは各自の選択を保持します。ただしアプリはパッケージなので、削除や復元はマシン上の全員に影響します。

## Docker

[Docker](https://www.docker.com/) の紹介はほとんど不要でしょう。隔離されたコンテナを実行でき、Omarchy は Docker 自体と [Docker Compose](https://docs.docker.com/compose/) を含め、快適に実行するために必要なものをすべてインストールします。

デフォルトでは、あなたのユーザーは `docker` グループに*含まれていません*。そのグループは実質的にパスワードなしの root です。そのグループに属するものは何でも `docker run -v /:/host` を実行してマシンを乗っ取れるため、あなたとして実行される不正なスクリプトや依存関係が 1 つあるだけで、root まであとコマンド 1 つという状態になってしまいます。そのため、コマンドラインでは Docker を `sudo` で実行し（`sudo docker ps`、`sudo docker compose up`）、デーモンと通信するグラフィカルツール ― Windows VM ― は必要なときに認証を求めます。利便性のためにグループなしのセットアップに戻したい場合、そのトレードオフを理解しているなら、**Setup > Security > Sudoless Docker** から有効にする（または `omarchy-setup-security-sudoless-docker` を実行する）ことで、警告の後にあなたが `docker` グループに追加され、再び `sudo` なしでプレーンな `docker` と `d` エイリアスが使えるようになります。

ローカル開発用の一般的なデータベースは、Omarchy メニューの _Install > Development > Docker DB_ を使って Docker でセットアップできます。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) は `gh` として利用でき、ターミナルからリポジトリ、issue、プルリクエストを扱えます。初回利用時にインストールして認証するには `gh auth login` を実行し、リポジトリをクローンするには `gh repo clone org/repo` を実行してください。そのコマンドを調べるには `gh --help` を実行してください。

プルリクエスト向けのターミナルインターフェースには `ghui` を実行してください。mise がこれも初回利用時にインストールします。[Lazygit](https://github.com/jesseduffield/lazygit) は Git 自体を扱うためにプリインストールされています。
