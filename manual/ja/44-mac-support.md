# Mac サポート

## Apple Silicon 向け Omarchy

Apple Silicon 向け Omarchy は Omacom の公式ソリューションで、Omarchy 4.5 で初めてリリースされました。macOS の隣にインストールされ、Mac の起動時にどちらかを選択します。

Omarchy Mac に関する通知を受け取りましたか？[Omarchy Mac から移行する場合](#coming-from-omarchy-mac)をご覧ください。

以下の Mac で動作します：

| Mac | チップ |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 以降の Mac はまだサポートされていません。M4 のサポートは edge チャンネルでテスト中であり、次に提供されます。インストーラーは何かを変更する前に Mac をチェックします。

M4 以降を含むすべての Apple Silicon Mac では、[Try Omarchy](https://github.com/omacom/try-omarchy)を使って仮想マシンで Omarchy を実行できます。

### 必要なもの

- macOS 15 Sequoia 以降、および管理者アカウント
- Omarchy 用の空きディスク容量。インストーラーがサイズを提案し、変更できます。
- Mac のバックアップ、電源、インターネット接続。インストールでは数ギガバイトをダウンロードします。

### インストール

macOS からインストールします。[Homebrew](https://brew.sh)で Omarchy Installer をインストールします：

```sh
brew install omacom/mac/omarchy
```

または、[リリースページ](https://github.com/omacom/omarchy-mac-installer/releases)から最新の Omarchy Installer をダウンロードして開きます。

インストーラーは Mac をチェックし、計画を表示し、macOS パーティションを縮小して Omarchy 用のスペースを確保します。macOS はディスクに残り、USB ドライブは不要です。第1段階が完了すると、macOS Recovery でセットアップを完了する手順を案内します：シャットダウンし、「起動オプションを読み込み中」と表示されるまで電源ボタンを長押しし、Omarchy を選択して手順に従います。

初回起動時に、Omarchy はディスクを暗号化するパスワードを求めます。リカバリキーはありません：パスワードを忘れると、Omarchy ファイルは復旧できません。

後で Omarchy と macOS を切り替えるには、シャットダウンし、起動オプションが表示されるまで電源ボタンを長押しして、どちらかを選択します。

### Omarchy Mac から移行する場合

Omarchy Mac は現在 Apple Silicon 向け Omarchy の一部となっており、それを実行していたすべての Mac がサポートされています。現在のインストールは動作し続け、そのシステムパッケージも更新されますが、Omarchy の更新はもう提供されません。期限もインプレースアップグレードもありません：バックアップし、古いインストールを削除し、新規インストールして、復元します。ステップ2から5は macOS で行うため、再起動する前にこのページをスマートフォンで開いてください。

1. **Omarchy から、Mac の外にバックアップします。** 古いインストールを削除すると消去され、macOS は Omarchy ディスクを読み取れません。ホームフォルダーを外付けドライブまたは別のコンピューターにコピーしてください。SSH キーと GPG キー、ブラウザープロファイル、プッシュしていない作業も含めます。`pacman -Qqe > ~/packages.txt` でパッケージリストを保存します。削除とインストールのどちらもディスクのサイズを変更するため、macOS もバックアップしてください。
2. **Mac を macOS で起動します。** シャットダウンし、起動オプションが表示されるまで電源ボタンを長押しし、macOS を選択します。
3. **Omarchy Installer をインストールします。** [インストール](#installing)で示した手順に従ってください。
4. **古いインストールを削除します。** Omarchy Installer を開き、Installation > Remove Omarchy を選択します。削除される内容が表示され、スペースが macOS に返されます。インストールを認識できない場合は、ディスクを変更せずに停止します。手動でパーティションを削除すると macOS を消去する恐れがあるため、そうするのではなく [Discord](https://discord.gg/tXFUdasqhY) で助けを求めてください。
5. **Apple Silicon 向け Omarchy をインストールします。** インストーラーを使用します。
6. **ファイルを復元します。** 古い設定が新しいデフォルトを上書きする可能性があるため、`~/.config` 全体をコピーするのではなく、設定を少しずつ戻してください。

### 知っておくとよいこと

- M1 および M2 MacBook では、蓋を開けるか電源ボタンを押してスリープから復帰します。
- 質問や問題がある場合：[Discord](https://discord.gg/tXFUdasqhY) でお問い合わせください。

[インストーラーの README](https://github.com/omacom/omarchy-mac-installer#readme) では、リリースチャンネル、インストーラーの更新、Omarchy の削除について説明しています。

## Intel Mac

簡単なテストでは、2019年製 MacBook Pro に Omarchy をインストールするだけで36%のパフォーマンス向上を達成できました。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac への Omarchy のインストール

Omarchy は現時点では**唯一**の OS としてインストールされることのみをサポートしています。インストール中にドライブは消去され、MacOS は起動できなくなります。

後で Internet Recovery 経由で復元することはできます。

このパートでは、すでに[はじめに](02-getting-started.md)を確認し、USB ドライブの準備ができているものとします。まだの場合は今すぐ行ってください。

#### Secure Boot を無効にする

ブータブル USB および OS を起動するには、Apple の Secure Boot を無効にする必要があります。無効にするには、以下を実行してください：

1. Mac の電源を切ります
2. 電源を入れ、ローディング画面が表示されるまで_直ちに_ Command-R を押し続けます
3. ユーザーを選択し、求められた場合はパスワードを入力します
4. リカバリ画面に入ったら、メニューバーから **ユーティリティ > 起動セキュリティユーティリティ** を選択します
5. 求められた場合はパスワードを入力して認証します
6. Secure Boot オプションから「セキュリティなし」を選択します
7. 外部起動オプションから「外部メディアまたはリムーバブルメディアからの起動を許可」を選択します

#### インストールを開始する

1. USB ドライブを挿入します
2. Mac を再起動し、起動デバイスの画面が表示されるまで_直ちに_ Option を押し続けます
3. オレンジ色の EFI Boot デバイスを選択します
4. [通常どおりインストール](02-getting-started.md)を進めます

インストーラーは Mac ハードウェアを検出し、必要な修正を自動的に適用します：Broadcom Wi-Fi ドライバーとファームウェア、Broadcom 1570 を搭載したマシン向けの FaceTime HD カメラドライバー（インストーラーはオフラインで動作するため、そのファームウェアは Mac がオンラインになってから Apple からダウンロードされます）、必要な MacBook モデル向けの SPI キーボードドライバー、および同じモデル向けの NVMe サスペンド修正です。

### 既知の制限事項

コミュニティのメンバーはこれらの課題の解決策に常に取り組んでいます。これらが問題になる場合は、[Discord](https://discord.gg/tXFUdasqhY) の #omarchy-on-other に参加し、解決するための最新の方法がないか確認してください。

#### FaceTime HD カメラ

カメラドライバーは、Mac がハイバネーションする際に読み込まれているとマシンをハングさせるため、先にアンロードされます。アプリがカメラを開いている間はアンロードできないため、ハイバネーションはそのアプリ名を示す通知とともにキャンセルされます：アプリを閉じて再度ハイバネーションしてください。これには、バッテリー残量が危機的になった際の自動ハイバネーション、およびサスペンドしてからハイバネーションする動作も含まれます。これはサスペンドする前に拒否されます。通常のサスペンドは、カメラが開いている間、通知なしでドライバー自体によって拒否されます。

カメラのファームウェアは Apple からダウンロードされるため、カメラは Mac がオンラインになって初めて動作します。ダウンロードは起動時に開始され、ネットワークに問題がある間は15分ごとに再試行されます。Apple のファイルが変更されている場合は停止し、Omarchy の更新を待ちます。カメラが表示されない場合は、`journalctl -u facetimehd-firmware-fetcher` が理由を示し、`sudo systemctl restart facetimehd-firmware-fetcher` が再試行し、ダウンロードが完了したのにカメラがまだ表示されない場合は再起動するとドライバーが読み込まれます。

#### T1 チップ搭載デバイス

Apple T1 チップは2016年後半に導入され、Touch Bar 搭載の第1世代 MacBook Pro モデルでのみ使用されました。
- MacBook Pro 13インチ (2016、Thunderbolt 3 ポート2基) – モデル: A1706
- MacBook Pro 13インチ (2016、Thunderbolt 3 ポート4基) – モデル: A1708
- MacBook Pro 15インチ (2016) – モデル: A1707

#### 既知の問題

- Touch Bar が機能しません
- サウンドが機能しません

#### T2 チップ搭載デバイス

Apple T2 Security Chip は2017年に導入されました。T2 チップは、2020年に始まった Apple silicon (Mシリーズチップ) への移行に伴い廃止されました。

- iMac Pro (2017) – モデル: A1862
- MacBook Pro 13インチ (2018、Thunderbolt 3 ポート4基) – モデル: A1989
- MacBook Pro 15インチ (2018) – モデル: A1990
- MacBook Air (Retina、13インチ、2018) – モデル: A1932
- Mac mini (2018) – モデル: A1998
- MacBook Pro 13インチ (2019、Thunderbolt 3 ポート2基) – モデル: A2159
- MacBook Pro 13インチ (2019、Thunderbolt 3 ポート4基) – モデル: A2178
- MacBook Pro 15インチ (2019) – モデル: A1990
- iMac (Retina 5K、27インチ、2020) – モデル: A2115 (iMac20,1 および iMac20,2)
- MacBook Pro 13インチ (2020、Thunderbolt 3 ポート2基) – モデル: A2265
- MacBook Pro 15インチ (2020) – モデル: A1990

これらのモデルでは、インストーラーはパッチ適用済みの `linux-t2` カーネル、T2 オーディオ設定、Apple の Broadcom Wi-Fi/Bluetooth ファームウェア、および `t2fanrd` によるファン制御を自動的にセットアップします。Touch Bar はカーネルに組み込まれた Boot Camp 方式のサポートで動作します。

#### iMac Retina 5K (2017)

2017年製27インチ iMac には T2 チップがないため、インストーラーは他の Intel Mac と同様にセットアップします。

- iMac (Retina 5K、27インチ、2017) – モデル: A1419

#### 既知の問題

- ディスプレイがネイティブ解像度5120×2880で動作しません：パネルは2つのタイルで構成されており、標準ドライバーは1つしか点灯させません
- サウンドが機能しません
- 輝度コントロールが効きません
- スリープするとマシンがハングします。電源を入れ直すことでのみ復旧します

このモデル向けのコミュニティ製パッチャーがディスプレイ、サウンド、輝度を修正します：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)
