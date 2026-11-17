# アップデート

Omarchy とインストール済みパッケージは、Omarchy メニュー（`Super + Space`）の _Update > Omarchy_ から最新状態に保てます。

Omarchy 自体は [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) から通常の pacman パッケージとしてインストールされるため、アップデートでは [最新の Omarchy リリース](https://github.com/omacom/omarchy/releases) がインストールされ、保留中のマイグレーションがすべて実行されてシステムが最新版と同期し、[Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) と [AUR](https://aur.archlinux.org/) からすべてのシステムパッケージがアップデートされます（AUR パッケージをインストールしている場合）。

新しいリリースが公開されると、時計の右側に円形の矢印アイコンが表示されます。それをクリックすると、アップデート処理が始まります。

![update-available](images/update-available.webp)

### 4つのチャンネル

Omarchy は stable、RC、edge、dev の4つのチャンネルでアップデートされます。新規インストールでは stable チャンネルから始まります。このチャンネルは [公式リリース](https://github.com/omacom/omarchy/releases/) と、最新版から1か月遅れて追従する [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) を追跡します。そのため、設定の変更が必要な新しい非互換性があっても、人々に問題を引き起こす前に検出できます。

しかし、そうした潜在的な問題を見つける手伝いをしたいなら、edge チャンネルで運用できます。これにより Omarchy パッケージは最新の開発ビルドを追跡し、Arch パッケージも利用可能になり次第すぐに最新版へアップデートできるようになります。経験豊富な Linux ユーザーで、問題が発生したシステムを復旧する方法を知っている場合にのみ、これを選んでください。

メジャーリリースの前には、RC チャンネルを使って最終検証を行います。最終仕上げに協力したい方は、Discord の #omarchy-release-candidates にぜひお越しください。

最後に dev チャンネルがあります。これは edge パッケージと組み合わせて、Omarchy を `~/omarchy` にあるソースコードの git チェックアウトへ直接リンクします。経験豊富な Linux ユーザーで、Omarchy の開発に直接取り組み、破損を許容できる場合にのみ、このチャンネルを使ってください。

チャンネルは Omarchy メニューの _Update > Channel_（またはターミナルで `omarchy-channel-set`）を使って切り替えできます。

### カーネルの切り替え

Omarchy は独自の `linux-omarchy` カーネルで起動しますが、標準の Arch `linux` カーネルやテスト中の実験的ビルドなど、他のカーネルも並べてインストールしておけます。複数のカーネルがある場合、Omarchy メニューの _Update > Kernel_ に一覧が表示され、デフォルトで起動するものの横にチェックマークが付きます。別のものを選んでパスワードを一度入力すれば、次回の再起動後からそれで起動します。他のカーネルはブートメニューに残るため、新しいデフォルトで問題が発生しても手動で選べます。ターミナルでは、現在のデフォルトを確認するには `omarchy-kernel`、インストール済みのものを確認するには `omarchy-kernel list`、切り替えるには `omarchy-kernel set <kernel>` を使います。

### ファームウェアのアップデート

古くなるのはパッケージだけではありません。多くのノートパソコンや周辺機器は、Linux Vendor Firmware Service を通じて BIOS、SSD、ドックのファームウェアを提供しています。Omarchy メニューの _Update > Firmware_ を使えば、ハードウェア向けに用意されているものをすべて取得してインストールできます。初回実行時に `fwupd` がインストールされます。多くのファームウェアは再起動中にしか書き込めないため、再起動を求められても驚かないでください。

BIOS 自体の設定を変更する必要がある場合は、システムメニュー（`Super + Escape`）で `Alt` を押し続けると、_Reboot_ が _Reboot to BIOS_ に変わり、起動時に適切なキーを押すタイミングを計らなくても、ファームウェア設定画面へ直接再起動できます。ターミナルでは `omarchy system firmware` です。

### pacman/yay で直接アップデートすることへの警告

Arch にすでに慣れていると、自分で `pacman -Syu` や `yay -Syu` を実行したくなるかもしれませんが、そうすると Omarchy が新しいパッケージと併せて実行するスナップショット、マイグレーション、設定のアップデートを逃してしまいます。そのため、Omarchy は直接のシステムアップグレードを実際に停止し、代わりに `omarchy update` を使うよう案内します。（自分が何をしているか本当に分かっている場合、そのガードが単一のトランザクションだけ回避する方法を教えてくれます。）

### 問題のあるアップデートのロールバック

アップデート後に問題が発生した場合は、アップデート前に取得したスナップショットへシステムをロールバックできます。再起動して、ブートローダーのメニューからアップデート開始前のスナップショットを選ぶだけです。

![bootloader](images/bootloader.webp)

何らかの理由で設定ファイルが破損してしまった場合は、ターミナルで `omarchy reinstall` を使って Omarchy を再インストールすることもできます。これにより、すべてのデフォルトの Omarchy パッケージが再インストールされ、stable に戻され、新しすぎるパッケージはダウングレードされ、すべての設定ファイルがリセットされます。この操作を行うと、Omarchy のデフォルトに対するユーザー設定の変更はすべて上書きされるので注意してください！
