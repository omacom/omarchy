# アップデート

Omarchy とあなたのパッケージは、Omarchy メニュー（`Super + Space`）の _Update > Omarchy_ から最新の状態に保てます。

Omarchy 自体は [Omarchy パッケージリポジトリ](https://github.com/omacom-io/omarchy-pkgs) から通常の pacman パッケージとしてインストールされるので、アップデートでは [最新の Omarchy リリース](https://github.com/omacom/omarchy/releases) がインストールされ、あなたのシステムを最新に同期するために保留中の移行がすべて実行され、[Omarchy Arch ミラー](https://github.com/omacom-io/omarchy-mirror) と [AUR](https://aur.archlinux.org/) からすべてのシステムパッケージがアップデートされます（AUR パッケージをインストールしている場合）。

新しいリリースが出ると、時計の右側に円形の矢印アイコンが表示されます。それをクリックすれば、アップデート処理が始まります。

![update-available](images/update-available.webp)

### 4つのチャンネル

Omarchy は stable、RC、edge、dev という4つのチャンネルでアップデートされます。新規インストールは stable チャンネルから始まります。これは [公式リリース](https://github.com/omacom/omarchy/releases/) に追従し、最新から1か月遅れで運用されている [stable な Omarchy Arch ミラー](https://github.com/omacom-io/omarchy-mirror) も使います。そのため、設定変更が必要な新しい非互換性が、人々に問題を引き起こす前に把握できます。

しかし、そうした潜在的な問題を見つけるのに協力したいなら、edge チャンネルで運用できます。そうすれば、Omarchy パッケージは最新の開発ビルドに追従し続け、最新の Arch パッケージが利用可能になったらすぐにアップデートできます。Linux の経験があり、問題が起きたシステムを復旧する方法を知っている場合にだけ、これを行ってください。

新しいメジャーリリースの前には、RC チャンネルを使って最終検証を行います。最終仕上げに協力したいなら、Discord の #omarchy-release-candidates に来て一緒に過ごしましょう。

最後に dev チャンネルがあります。これは `~/omarchy` にあるソースコードの git チェックアウトに Omarchy を直接結びつけ、edge パッケージと組み合わせたものです。Linux の経験豊富なユーザーで、Omarchy を直接開発していて、破損を許容できる場合にだけ、このチャンネルを使ってください。

チャンネルは Omarchy メニューの _Update > Channel_ で切り替えられます（ターミナルでは `omarchy channel set <stable|rc|edge|dev>`、現在のチャンネルを確認するには `omarchy channel current` です）。

### カーネルの切り替え

Omarchy は独自の `linux-omarchy` カーネルで起動しますが、標準の Arch `linux` カーネルや、テスト中の実験的ビルドのように、他のカーネルを並べてインストールしておくこともできます。複数ある場合、Omarchy メニューの _Update > Kernel_ に一覧が表示され、デフォルトで起動するものの横にチェックが付きます。別のものを選び、パスワードを1回入力すれば、次回再起動後にそれで起動します。他のカーネルはブートメニューに残るので、新しいデフォルトで問題が起きても手動で選べます。ターミナルでは、現在のデフォルトを確認するには `omarchy kernel`、インストールされているものを確認するには `omarchy kernel list`、切り替えるには `omarchy kernel set <kernel>` です。

### ファームウェアのアップデート

古くなるのはパッケージだけではありません。多くのノートパソコンや周辺機器は、Linux Vendor Firmware Service を通じて BIOS、SSD、ドックのファームウェアを配信しています。Omarchy メニューの _Update > Firmware_ を使えば、あなたのハードウェア向けに待機しているものをすべて取得してインストールできます。初回実行時には `fwupd` がインストールされます。多くのファームウェアは再起動中にしか書き込めないので、再起動を求められても驚かないでください。

BIOS 自体の設定を変更する必要があるときは、システムメニュー（`Super + Escape`）で `Alt` を押したままにすると、_Reboot_ が _Reboot to BIOS_ に変わり、起動時に適切なキーを押すタイミングを計らなくても、ファームウェア設定画面へまっすぐ再起動します。ターミナルでは `omarchy system firmware` です。

### pacman/yay を直接使ったアップデートに関する警告

すでに Arch に慣れているなら、自分で `pacman -Syu` や `yay -Syu` を実行したくなるかもしれません。しかしそうすると、Omarchy が新しいパッケージと一緒に実行するスナップショット、移行、設定のアップデートを逃してしまいます。だからこそ Omarchy は、直接のシステムアップグレードを実際に停止し、代わりに `omarchy update` へ誘導します。（本当に自分が何をしているか分かっているなら、そのガードが1回のトランザクションだけ回避する方法を教えてくれます。）

### 問題のあるアップデートのロールバック

アップデート後に問題が起きたら、アップデート前に取得されたスナップショットへシステムをロールバックできます。再起動して、アップデートを開始する前のブートローダーメニューでそのスナップショットを選ぶだけです。

![bootloader](images/bootloader.webp)

何らかの理由で設定ファイルが破損してしまった場合は、ターミナルで `omarchy reinstall` を使って Omarchy の再インストールも行えます。これにより、すべてのデフォルトの Omarchy パッケージが再インストールされ、stable（Apple Silicon では edge）に戻され、新しすぎるパッケージはダウングレードされ、すべての設定ファイルがリセットされます。これを行うと、Omarchy のデフォルトに対してあなたが行ったユーザー設定の変更はすべて上書きされるので注意してください！
