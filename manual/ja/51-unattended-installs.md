# 無人インストール

Omarchy ISO は、キーボードの前に誰もいなくても自動でインストールできる。インストーラーが `cidata` というラベルの付いた2台目のドライブに設定ファイルを見つけると、それらをコピーし、セットアップウィザードを完全にスキップし、自動で完成したシステムへ再起動する。特別な ISO ビルドも、余分なブートメニュー項目もいらない。そのようなドライブが接続されていなければ何も変わらず、通常のウィザードが表示される。

これにより Omarchy は使い捨ての開発環境のベースイメージとして優れている。Proxmox や Packer で VM を作成し、起動し、席を外して、SSH で入ればいい。`cidata` は cloud-init の `NoCloud` ラベルなので、一般的な仮想化ツールはすべて、そのようなドライブの接続方法をすでに知っている。

## 設定ファイル

これらのファイルはインストーラー自身のウィザードが書き出すものとまったく同じなので、最初のセットを手に入れる一番簡単な方法は、対話式インストールを1回実行し（たとえば VM で）、`/root` に書き出されたものをコピーすることだ。

| ファイル | 必須 | 目的 |
|------|----------|---------|
| `user_configuration.json` | Yes | ディスク、ホスト名、タイムゾーン、キーボード |
| `user_credentials.json` | Yes | ユーザー名とパスワードハッシュ |
| `user_encrypt_installation.txt` | No | 設定に `disk_encryption` ブロックが含まれている場合に `true` |
| `authorized_keys` | No | SSH 公開鍵、1行に1つ |
| `tailscale_authkey` | No | 初回起動時に tailnet へ参加するための Tailscale 認証キー |

`user_credentials.json` 用のパスワードハッシュは `openssl passwd -6 "yourpassword"` で生成する。

git コミット用の名前とメールアドレスはインストールの一部ではない。マシンが起動したら、たとえば SSH 経由で `omarchy setup git --name "Jane Doe" --email jane@example.com` で設定する。

`user_credentials.json` の代わりに、`defer-provisioning` という名前の空ファイルを入れることもできる。これにより、対話式にも起動できる[別の所有者向けの準備インストール](02-getting-started.md)と同じものが実行される。マシンは個人情報を一切持たずにインストールされ、最初に起動した人が自分のキーボードを選び、自分のユーザーを作成する。ドライブに誰の認証情報も入れるべきではないイメージング用リグ向けのモードだ。

## SSH アクセス

`authorized_keys` が存在する場合、インストールではその鍵をユーザーの `~/.ssh/authorized_keys` として設定し、`sshd` を有効にして、そのためのファイアウォールを開く。（標準の Omarchy インストールでは openssh が同梱されているがサービスは無効でポートも閉じているため、無人マシンはそうしなければ到達不能になってしまう。）インストールでは自分の鍵を追加するだけであり、SSH デーモンの他の認証設定は一切緩めない。

`tailscale_authkey` が存在する場合、その代わりにマシンは初回起動時に tailnet へ参加する。Tailscale は ISO に同梱されたパッケージからインストールされ、ファイアウォールでは tailnet インターフェースが許可され、バックグラウンドジョブがマシンに実際にネットワークがつながり次第参加を実行し、成功するまで再試行する。再利用可能で事前承認済みのキーを使えば、1つのドライブイメージで多くのマシンに対応できる。

## cidata ドライブの構築

正しいラベルが付いたファイルシステムなら何でも使える。小さな ISO が簡単な方法だ。

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

次に、それを Omarchy ISO と一緒に VM に接続する。以下は Proxmox の完全な例だ。

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

ブート順序でディスクを最初に挙げているのは意図的だ。空のディスクは初回起動時に ISO へフォールスルーし、インストールされたシステムはそれ以降ずっとディスクから起動する。

## 2つの注意点

暗号化した無人インストールは完全には無人にならない。初回起動時に LUKS パスフレーズを入力する人が依然として必要だ。そして `user_configuration.json` の `disk_encryption` ブロックにはそのパスフレーズが平文で含まれているので、暗号化したインストールから構築した cidata ドライブは、それ自体が秘密情報であるとして扱え。
