# 開発ツール

## 代替エディター

Omarchy は新規インストール時のデフォルトエディターとして Plain を搭載し、[Neovim](https://neovim.io/) もプリインストールされていますが、もう少し主流で馴染みのあるものがよければ、Omarchy Menu（`Super + Space`）を開いて _Install > Editor_ の下にある選択肢を確認してください。VSCode、Cursor、Zed、Sublime Text、Helix、Vim、Emacs が並んでいます。探しているものが見つからなければ、_Install > Package_ を確認して Arch パッケージにないか探してください（なければ _Install > AUR_ で AUR も確認してください）。

オリジナルの `vi` エディターもそのまま使えます。ターミナルで `vi filename` を実行すればファイルを編集できます。

テーマのマッチングは `VSCode`、`Cursor`、`VSCodium`、`Helix` に対応しています。

システム全体のデフォルトエディターは `Setup > Defaults > Editor` で設定できます。

## 環境

Omarchy では、Omarchy Menu（`Super + Space`）の _Install > Development_ セクションから、数多くの開発環境をセットアップできます。もちろん _Ruby on Rails_ がありますし、JavaScript の主要な 3 つのランタイム（Node.js、Bun、Deno）や、Laravel、Symfony といった人気の PHP フレームワークもあります。ああ、それに Go、Rust、Python、Java、Elixir（Phoenix 付き）、.NET、OCaml、Zig、Clojure、Scala もあります。非常に幅広いラインナップです！

これらの環境の大部分は [Mise](https://mise.jdx.dev/) で管理されます。これは、同じマシンにプログラミング言語の複数のバージョンをインストールして実行できるツールです。Ruby 向けの rbenv や rvm、Python 向けの virtualenv のようなものですが、さまざまな環境で使えます。

たとえば Ruby をインストールするには `mise use -g ruby` を実行します。これで Ruby のインストールとグローバルなデフォルトへの設定の両方が行われます。あるいは、プロジェクトに .ruby-version ファイルがある場合は、そのプロジェクトのルートで `mise i` を実行するだけです。

## プリインストール済みの CLI ツール

`uv`、Node.js、`playwright-cli`（エージェントがインストール済みの Chrome を使ってブラウザを操作するためのもの）はパッケージとしてインストールされており、`omarchy update` でシステムの他部分と一緒に最新状態に保たれます。`ghui`、[Hunk](https://github.com/modem-dev/hunk)、Basecamp、Cloudflare、HEY の CLI は _Install > CLI_ からすぐに選べますし、[コーディングエージェント](17-ai.md) は _Install > AI > CLI_ にあります。

mise が管理するのは _Install > Development_ からセットアップしたランタイムだけです。Omarchy が mise 経由で勝手に何かをインストールすることはありません。`omarchy update` を実行すれば、Omarchy の他の部分と一緒にそれらも更新されます。`mup` エイリアスは mise が管理するツールだけを更新します。自分の設定に別のツールを追加するには `mise use -g <tool>` を使ってください。

## Docker

[Docker](https://www.docker.com/) は今さら紹介するまでもないでしょう。分離されたコンテナーを実行でき、Omarchy には Docker 自体や [Docker Compose](https://docs.docker.com/compose/) など、それをきちんと実行するために必要なものがすべてインストールされます。

デフォルトでは、あなたのユーザーは `docker` グループに *入っていません*。そのグループは実質的にパスワードなしの root です。グループ内のものなら何でも `docker run -v /:/host` でマシンを乗っ取れてしまうため、あなたとして実行される不正なスクリプトや依存関係が 1 つあるだけで、root まであとコマンド 1 つという状態になってしまいます。そのためコマンドラインでは Docker を `sudo` 付きで実行し（`sudo docker ps`、`sudo docker compose up`）、デーモンと通信するグラフィカルツール、つまり Windows VM は、必要なときに認可を求めます。トレードオフを理解したうえで、グループなしの手軽さを取り戻したい場合は、**Setup > Security > Sudoless Docker** から有効化してください（あるいは `omarchy-setup-security-sudoless-docker` を実行してください）。警告のあとにあなたが `docker` グループに追加され、素の `docker` と `d` エイリアスが再び `sudo` なしで使えるようになります。

ローカル開発でよく使うデータベースは、Omarchy メニューの _Install > Development > Docker DB_ から Docker でセットアップできます。

## GitHub CLI

[GitHub CLI](https://cli.github.com/) は `gh` です。ターミナルからリポジトリ、issue、pull request を操作できます。_Setup > Git_ では、そこで GitHub にサインインすることを選ぶとインストールされます。そのあとは `gh repo clone org/repo` でリポジトリを clone できます。`gh --help` を実行すればコマンドを調べられます。

_Install > CLI > GitHub_ では GitHub CLI の `gh` と、pull request 用のターミナルインターフェースである `ghui` がインストールされます。[Lazygit](https://github.com/jesseduffield/lazygit) は Git 自体を操作するためにプリインストールされています。
