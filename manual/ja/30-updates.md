# 更新

Omarchy とあなたのパッケージは、Omarchy メニュー（`Super + Space`）の _更新 > Omarchy_ 経由で最新に保たれます。

Omarchy 自体は [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) からの通常の pacman パッケージとしてインストールされているため、更新では [最新の Omarchy リリース](https://github.com/omacom/omarchy/releases) がインストールされ、あなたのシステムを最新と同期させるために保留中のマイグレーションがすべて実行され、すべてのシステムパッケージが [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) と [AUR](https://aur.archlinux.org/)（AUR パッケージをインストールしている場合）から更新されます。

新しいリリースが作成されると、時計の右側に円形の矢印アイコンが現れます。それをクリックすると更新プロセスが開始します。

![update-available](images/update-available.webp)

### 4つのチャネル

Omarchy は stable、RC、edge、dev の4つのチャネルに沿って更新されます。新規インストールは stable チャネルから始まります。これは [公式リリース](https://github.com/omacom/omarchy/releases/) を追跡するとともに、1か月遅れの [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror) を追跡します。そのため、設定変更を必要とする新たな非互換性を、問題を引き起こす前にキャッチできます。

しかし、それらの潜在的な問題を見つける手助けをしたいなら、edge チャネルで運用できます。それにより Omarchy パッケージは最新の開発ビルドを追跡しし続け、Arch パッケージが利用可能になり次第最新へ更新できます。あなたが Linux に経験があり、問題のあるシステムを復旧できる場合にのみそうしてください。

大きな新リリースの前には、RC チャネルを使って最終検証を行います。最終的な仕上げに興味があるなら、Discord の #omarchy-release-candidates で一緒に過ごしてください。

最後に、dev チャネルがあります。これは Omarchy を、edge パッケージと組み合わせて、`~/omarchy` にあるソースコードの git チェックアウトに直接リンクします。あなたが熟練した Linux ユーザーで、Omarchy そのもの上で作業し、破損を許容する意思がある場合にのみこのチャネルを使ってください。

チャネルの切り替えは Omarchy メニューの _更新 > Channel_ で（またはターミナルの `omarchy-channel-set` で）行えます。

### ファームウェア更新

陳腐化するのはあなたのパッケージだけではありません。多くのノートPCと周辺機器は Linux Vendor Firmware Service を通じて BIOS、SSD、ドックのファームウェアを出荷しており、Omarchy メニューの _更新 > Firmware_ は、あなたのハードウェアが待っているものを取得してインストールします。初めて実行したときに `fwupd` がインストールされます。多くのファームウェアは再起動中しか書き込めないため、再起動を求められても驚かないでください。

### 直接 pacman/yay で更新することへの警告

すでに Arch に馴染みがあると、自分で `pacman -Syu` や `yay -Syu` を実行したくなるかもしれませんが、それでは、新しいパッケージとともに Omarchy が実行するスナップショット、マイグレーション、設定更新を見逃してしまいます。そのため Omarchy は直接システムアップグレードを止めて、代わりに `omarchy update` に誘導します。（本当に何をしているか分かっている場合、ガードは単一のトランザクションでそれをバイパスする方法を教えてくれます。）

### 悪い更新をロールバックする

更新を行った後にいつか問題が起こった場合、更新前に撮られたスナップショットにあなたのシステムをロールバックできます。ただ再起動し、ブートローディングメニューで、あなたが更新を開始する前のスナップショットを選んでください。

![bootloader](images/bootloader.webp)

もし何らかで設定ファイルが壊れてしまった場合は、ターミナルの `omarchy reinstall` で Omarchy の再インストールもできます。これによりすべてのデフォルトの Omarchy パッケージが再インストールされ、stable になって新しすぎるパッケージはダウングレードされ、すべての設定ファイルがリセットされます。Omarchy のデフォルトに対するあなたのユーザー設定の変更は、これで上書きされてしまう点に注意してください！
