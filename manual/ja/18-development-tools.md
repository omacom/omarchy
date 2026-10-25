# 開発ツール

## 別のエディタ

Omarchy はデフォルトで [Neovim](https://neovim.io/) を搭載していますが、もう少し主流で馴染みのあるものがよければ、Omarchy Menu（`Super + Space`）を開いて、_Install > Editor_ の下にある選択肢を確認できます。VSCode、Cursor、Zed、Sublime Text、Helix、Vim、Emacs がそこに並んでいます。探しているものが見つからなければ、_Install > Package_ を確認して、Arch パッケージにないか見てみてください（それでもなければ、_Install > AUR_ で AUR を確認してください）。

元の `vi` エディタも最初から使えます。ターミナルでファイルを編集するには `vi filename` を実行してください。

テーマのマッチングは `VSCode`、`Cursor`、`VSCodium`、`Helix` に対応しています。

システム全体のデフォルトエディタは `Setup > Defaults > Editor` で設定できます。

## 環境

Omarchy は、Omarchy Menu（`Super + Space`）の _Install > Development_ セクションから、数多くの開発環境のセットアップに対応しています。もちろん _Ruby on Rails_ もありますが、JavaScript の主要な 3 つのランタイム（Node.js、Bun、Deno）も、Laravel や Symfony といった人気の PHP フレームワークもあります。ああ、それに Go、Rust、Python、Java、Elixir（Phoenix 付き）、.NET、OCaml、Zig、Clojure、Scala もあります。実に幅広いラインナップです！

これらの環境の大半は [Mise](https://mise.jdx.dev/) で管理されています。これは、同じマシン上にプログラミング言語の複数のバージョンをインストールして実行できるツールです。Ruby 向けの rbenv や rvm、Python 向けの virtualenv のようなものですが、さまざまな環境に対応しています。

たとえば Ruby をインストールするには `mise use -g ruby` を実行します。これで Ruby のインストールと、グローバルデフォルトとしての設定の両方が行われます。あるいは、プロジェクトに .ruby-version ファイルがある場合は、そのプロジェクトのルートで `mise i` を実行するだけです。

## プリインストールされた CLI ツール

Omarchy は、`gh`、`uv`、そして大半の[コーディングエージェント](17-ai.md)といったツールを、[mise の遅延インストール](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools)を通じて利用できるようにしています。初めて実行したときに、mise がそれをインストールします。2 回目以降の実行ではインストール済みのバージョンを再利用します。起動のたびにアップデートを確認することはありません。

デフォルトを確認したり、事前にインストールしたりもできます。

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

インストール済みのツールを Omarchy の他の部分と一緒にアップデートするには `omarchy update` を実行してください。`mup` エイリアスは mise で管理されているツールだけをアップデートします。自分の設定に別のツールを追加するには、`mise use -g <tool>` を使ってください。

Python のセットアップでは、mise を通じて `uv` もインストールされます。Python 開発環境を削除しても、`uv` は独立したツールとして引き続き使えます。

### 自分でインストールしたものを使う

mise のコマンドは `PATH` 上で `~/.local/bin` より前に来るため、たとえば Claude Code や Cursor 独自のインストーラーで自分でインストールしたツールでも、依然として mise のコピーが実行されます。デスクトップから起動したアプリも、システムパッケージより前に mise のコマンドを見つけるため、`gh` を実行するアプリは、pacman で `github-cli` をインストールしていても mise のコピーを使います。そして mise は初回にそのコピーをインストールします。代わりに自分のものを使うには、`~/.config/mise/config.toml` で mise のコピーを無効化してください。たとえば、Cursor CLI を自分でインストールした場合は次のようになります。

```toml
[settings]
disable_tools = ["cursor-agent"]
```

すでに `[settings]` テーブルがある場合は、そこにこのエントリを追加してください。既存の `disable_tools` リストがある場合は、それを置き換えるのではなく拡張してください。自分のインストールが `PATH` 上にあることを確認してください。mise のツール名を使ってください。これはコマンド名と異なる場合があります。たとえば、`oh-my-pi` は `omp` を提供します。デフォルトエージェントのランチャーも、`~/.local/bin` にユーザーがインストールした Cursor や Muse を優先します。

### デフォルトの削除と復元

_Remove Preinstalls_ を使うと、`~/.config/mise/miserc.toml` の `ignored_config_paths` に追加することで、mise があなたのユーザー向けの Omarchy のツール宣言をスキップするようになります。_Restore Preinstalls_ を使うと、その行が再び削除されます。自分の設定やプロジェクトの `mise.toml` で自分で宣言したツールは、どちらの場合でも引き続き動作します。プリインストールを削除した後にデフォルトエージェントを選んだり Python をセットアップしたりすると、そのツールは自分の設定に追加されます。どちらもあなたのユーザーにのみ適用されます。マシン上の他のユーザーは、それぞれ自分の選択を維持します。

## Docker

[Docker](https://www.docker.com/) は、今さら紹介するまでもないでしょう。隔離されたコンテナを実行でき、Omarchy は Docker 本体や [Docker Compose](https://docs.docker.com/compose/) など、快適に実行するために必要なものすべてをインストールします。

デフォルトでは、あなたのユーザーは `docker` グループに*入っていません*。そのグループは実質的にパスワードなしの root です。そのグループに入っているものは何でも `docker run -v /:/host` を実行してマシンを乗っ取ることができるため、あなたとして実行される不正なスクリプトや依存関係が 1 つあるだけで、root まであとコマンド 1 つという状態になってしまいます。そこで、コマンドラインでは Docker を `sudo` 付きで実行し（`sudo docker ps`、`sudo docker compose up`）、デーモンと通信するグラフィカルツール、つまり Windows VM は、必要なときに認可を求めます。グループなしのセットアップの便利さを取り戻したい方で、そのトレードオフを理解している場合は、**Setup > Security > Sudoless Docker** から有効化するか（あるいは `omarchy-setup-security-sudoless-docker` を実行するか）、警告の後にあなたを `docker` グループに追加できます。そうすれば、プレーンな `docker` と `d` エイリアスが再び `sudo` なしで動作します。

Omarchy メニューの _Install > Development > Docker DB_ を使えば、ローカル開発向けの一般的なデータベースを Docker でセットアップできます。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) は、ターミナルからリポジトリ、issue、プルリクエストを扱うための `gh` として利用できます。初回利用時のインストールと認証を行うには `gh auth login` を実行し、次にリポジトリをクローンするには `gh repo clone org/repo` を実行してください。コマンドを調べるには `gh --help` を実行してください。

プルリクエスト向けのターミナルインターフェースには、`ghui` を実行してください。これも初回利用時に mise がインストールします。Git 自体を扱うための [Lazygit](https://github.com/jesseduffield/lazygit) はプリインストールされています。
