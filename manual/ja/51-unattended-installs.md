# 無人インストール

Omarchy ISO は、誰もキーボードの前にいなくても自動でインストールできます。インストーラーが設定ファイルを持つ `cidata` というラベルの付いた 2 台目のドライブを見つけると、そのファイルをコピーし、セットアップウィザードを丸ごとスキップして、完成したシステムへ自動で再起動します。特別な ISO のビルドは不要で、追加のブートメニュー項目もありません。そのようなドライブが接続されていなければ、何も変わらず、通常のウィザードが表示されます。

これにより、Omarchy は使い捨ての開発環境のベースイメージとして最適になります。Proxmox や Packer で VM を作成して起動し、その場を離れれば、あとは SSH で接続するだけです。`cidata` は cloud-init の `NoCloud` ラベルなので、一般的な仮想化ツールはどれも、そのようなドライブの接続方法をすでに知っています。

## 設定ファイル

これらのファイルは、インストーラーのウィザード自身が書き込むものとまったく同じです。そのため、出発点となる一式を手に入れる最も簡単な方法は、対話式インストールを一度実行し（VM 上など）、`/root` に書き込まれたものをコピーすることです。

| ファイル | 必須 | 用途 |
|------|----------|---------|
| `user_configuration.json` | はい | ディスク、ホスト名、タイムゾーン、キーボード |
| `user_credentials.json` | はい | ユーザー名とパスワードハッシュ、および暗号化インストール用の LUKS パスフレーズ |
| `user_encrypt_installation.txt` | いいえ | 設定に `disk_encryption` ブロックが含まれている場合は `true` |
| `authorized_keys` | いいえ | SSH 公開鍵、1 行に 1 つずつ |
| `tailscale_authkey` | いいえ | 初回起動時に tailnet へ参加するための Tailscale 認証キー |

`user_credentials.json` 用のパスワードハッシュは、`openssl passwd -6 "yourpassword"` で生成します。

git コミット用の名前とメールアドレスは、インストールには含まれていません。マシンが起動してから、たとえば SSH 経由で `omarchy setup git --name "Jane Doe" --email jane@example.com` を実行して設定してください。

`user_credentials.json` の代わりに、`defer-provisioning` という名前の空ファイルを入れることもできます。これにより、対話式に起動できるのと同じ[別の所有者のために準備するインストール](02-getting-started.md)が実行されます。マシンは個人情報を一切持たずにインストールされ、最初に起動した人がキーボードを選び、自分のユーザーを作成します。ドライブに誰の認証情報も入れるべきではないイメージング用リグ向けのモードです。

## SSH アクセス

`authorized_keys` がある場合、インストールはそのキーをユーザーの `~/.ssh/authorized_keys` として設定し、`sshd` を有効化して、ファイアウォールで開放します。（標準の Omarchy インストールでは openssh が同梱されていますが、サービスは無効でポートも閉じているため、そうしなければ無人のマシンには到達できません。）インストールが追加するのはあなたのキーだけです。SSH デーモンのその他の認証設定を緩めることはありません。

`tailscale_authkey` がある場合、マシンは代わりに初回起動時に tailnet へ参加します。Tailscale は ISO に同梱されたパッケージからインストールされ、ファイアウォールで tailnet インターフェースが許可され、バックグラウンドジョブがマシンに実際にネットワーク接続ができた時点ですぐに参加処理を実行し、成功するまで再試行します。再利用可能で事前承認済みのキーを使えば、1 つのドライブイメージで多くのマシンに対応できます。

## cidata ドライブの作成

適切なラベルを持つファイルシステムであれば、どれでも動作します。小さな ISO が手軽な方法です。

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

次に、それを VM に Omarchy ISO と一緒に接続します。Proxmox の完全な例を次に示します。

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

ブート順序でディスクを先に挙げているのは意図的です。初回起動時は空のディスクからフォールスルーして ISO から起動し、それ以降はインストールされたシステムがディスクから起動します。

## 2 つの注意点

暗号化した無人インストールは、完全に無人というわけではありません。初回起動時に LUKS パスフレーズを誰かが入力する必要があります。また、そのパスフレーズは `user_credentials.json` のトップレベルに `encryption_password` として置きます。archinstall は `user_configuration.json` の `disk_encryption` ブロックからではなく、そこから読み取ります。したがって、暗号化インストールから作成した cidata ドライブは、それ自体が秘密情報であるものとして扱ってください。
