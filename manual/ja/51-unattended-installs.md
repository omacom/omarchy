# 無人インストール

Omarchy ISOは、キーボードの前に誰もいなくても自分自身をインストールできます。インストーラーが、設定ファイルを含み`cidata`というラベルの付いた2つ目のドライブを見つけると、それをコピーし、セットアップウィザードを完全にスキップし、完成したシステムへ自動的に再起動します。特別なISOビルドも、追加のブートメニューエントリもありません。そのようなドライブが接続されていなければ何も変わらず、通常のウィザードが表示されます。

これにより、Omarchyは使い捨て開発環境のベースイメージとして最適になります。ProxmoxやPackerでVMを作成し、起動し、離席して、SSHで接続できます。`cidata`はcloud-initの`NoCloud`ラベルです。そのため、一般的な仮想化ツールはすべてそのようなドライブの接続方法をすでに知っています。

## 設定ファイル

ファイルはまさにインストーラー自身のウィザードが書き込むものです。そのため、開始セットを得る最も簡単な方法は、（たとえばVMで）対話型インストールを1回実行し、`/root`に書かれたものをコピーすることです。

| ファイル | 必須 | 目的 |
|------|----------|---------|
| `user_configuration.json` | はい | ディスク、ホスト名、タイムゾーン、キーボード |
| `user_credentials.json` | はい | ユーザー名とパスワードハッシュ |
| `user_full_name.txt` | いいえ | Gitのフルネーム |
| `user_email_address.txt` | いいえ | Gitのメールアドレス |
| `user_encrypt_installation.txt` | いいえ | 設定に`disk_encryption`ブロックが含まれるときは`true` |
| `authorized_keys` | いいえ | SSH公開鍵（1行に1つ） |
| `tailscale_authkey` | いいえ | 初回起動時にtailnetに参加するためのTailscale認証キー |

`user_credentials.json`用のパスワードハッシュは、`openssl passwd -6 "yourpassword"`で生成してください。

`user_credentials.json`の代わりに、`defer-provisioning`という名前の空のファイルを置くこともできます。これにより、対話的にトリガーすることもできる同じ[別の所有者に向けた準備インストール](02-getting-started.md)が実行されます。マシンは個人情報を一切持たずにインストールされ、最初に起動した人がキーボードを選び、ユーザーを作成します。これは、ドライブが誰の認証情報も含むべきではないイメージング用装置向けのモードです。

## SSHアクセス

`authorized_keys`が存在する場合、インストールにより鍵はユーザーの`~/.ssh/authorized_keys`として設定され、`sshd`が有効化され、そのためのファイアウォールが開きます。（標準のOmarchyインストールでは、opensshはサービスが無効でポートが閉じた状態で出荷されます。そのため、無人マシンはそうでなければ到達不能になります。）インストールはあなたの鍵を追加するだけであり、SSHデーモンの他の認証設定を緩めることはありません。

`tailscale_authkey`が存在する場合、代わりにマシンは初回起動時にtailnetに参加します。TailscaleはISOに同梱されたパッケージからインストールされ、ファイアウォールはtailnetインターフェースを許可し、バックグラウンドジョブはマシンが実際にネットワークに接続するとすぐに参加処理を実行し、成功するまで再試行します。1つのドライブイメージで多くのマシンに対応できるよう、再利用可能で事前承認済みの鍵を使ってください。

## cidataドライブを構築する

正しいラベルを持つファイルシステムであれば、何でも動作します。小さなISOが簡単な方法です。

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

次に、Omarchy ISOと並べてVMに接続します。完全なProxmoxの例は次のとおりです。

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

ブート順序でディスクを最初に列挙しているのは意図的なものです。空のディスクは初回起動時にISOへフォールスルーし、その後はインストールされたシステムがディスクから起動します。

## 2つの注意事項

暗号化された無人インストールは完全に無人ではありません。初回起動時に誰かがLUKSパスフレーズを入力しなければなりません。そして、`user_configuration.json`の`disk_encryption`ブロックにはそのパスフレーズが平文で含まれています。そのため、暗号化インストールから構築したcidataドライブは、それが秘密情報であることを認識して扱ってください。
