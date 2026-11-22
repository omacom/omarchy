# Mac サポート

## Apple Silicon向けOmarchy

Apple Silicon向けOmarchyはOmacom公式ソリューションで、Omarchy 4.5で初めてリリースされました。macOSの隣にインストールされ、Macの起動時にどちらかを選択します。

Omarchy Macに関する通知を受け取りましたか？[Omarchy Macからの移行](#coming-from-omarchy-mac)をご覧ください。

次のMacで動作します：

| Mac | チップ |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4以降のMacはまだサポートされていません。M4サポートはedgeチャンネルでテスト中で、次に提供されます。インストーラーは何かを変更する前にあなたのMacをチェックします。

M4以降を含むすべてのApple Silicon Macでは、[Try Omarchy](https://github.com/omacom/try-omarchy)を使って仮想マシンでOmarchyを実行できます。

### 必要なもの

- macOS 15 Sequoia以降と、管理者アカウント
- Omarchy用の空きディスク容量。インストーラーがサイズを提案し、変更もできます。
- Macのバックアップ、電源、インターネット接続。インストールでは数ギガバイトをダウンロードします。

### インストール

macOSからインストールします。[Homebrew](https://brew.sh)でOmarchy Installerをインストールしてください：

```sh
brew install omacom/mac/omarchy
```

または、最新のOmarchy Installerを[リリースページ](https://github.com/omacom/omarchy-mac-installer/releases)からダウンロードして開いてください。

インストーラーはあなたのMacをチェックし、計画を表示し、macOSパーティションを縮小してOmarchy用のスペースを作ります。macOSはディスクに残り、USBドライブは不要です。最初のステージが終わると、macOS Recoveryでセットアップを完了する手順を案内します：シャットダウンし、「Loading startup options」が表示されるまで電源ボタンを長押しし、Omarchyを選択して手順に従ってください。

初回起動時に、Omarchyはディスクを暗号化するパスワードを求めます。リカバリキーはありません：パスワードを忘れると、Omarchyのファイルは復旧できません。

後でOmarchyとmacOSを切り替えるには、シャットダウンしてから、起動オプションが表示されるまで電源ボタンを長押しし、どちらかを選択してください。

### Omarchy Macからの移行

Omarchy MacはApple Silicon向けOmarchyの一部となり、それが動作していたすべてのMacがサポートされています。現在のインストールは動作し続け、システムパッケージも更新されますが、Omarchyの更新はもう提供されません。期限はなく、インプレースアップグレードもありません：バックアップを取り、古いインストールを削除し、新規インストールして、復元します。ステップ2から5はmacOSで行うため、再起動する前にこのページをスマートフォンで開いておいてください。

1. **Omarchyから、Macの外にバックアップしてください。** 古いインストールを削除すると消去され、macOSはOmarchyのディスクを読めません。ホームフォルダーを外付けドライブや別のコンピューターにコピーしてください。SSHキーとGPGキー、ブラウザープロファイル、プッシュしていない作業も含めてください。`pacman -Qqe > ~/packages.txt` でパッケージリストを保存してください。削除もインストールもmacOSのディスクをリサイズするので、macOSもバックアップしてください。
2. **MacをmacOSで起動してください。** シャットダウンし、起動オプションが表示されるまで電源ボタンを長押しし、macOSを選択してください。
3. **[インストール](#installing) のとおりにOmarchy Installerをインストールしてください。**
4. **古いインストールを削除してください。** Omarchy Installerを開き、Installation > Remove Omarchyを選択してください。削除する内容を表示し、スペースをmacOSに返します。インストールを認識できない場合は、ディスクを変更せずに停止します。手作業でパーティションを削除するとmacOSを消してしまうことがあるので、そうするのではなく [Discord](https://discord.gg/tXFUdasqhY) で助けを求めてください。
5. **インストーラーでApple Silicon向けOmarchyをインストールしてください。**
6. **ファイルを復元してください。** 古い設定が新しいデフォルトを上書きすることがあるので、`~/.config` のすべてを新しいデフォルトの上にコピーするのではなく、設定を少しずつ戻してください。

### 知っておくとよいこと

- M1およびM2 MacBookでは、フタを開けるか電源ボタンを押してスリープから復帰してください。
- 質問や問題がある場合：私たちの [Discord](https://discord.gg/tXFUdasqhY) で聞いてください。

[インストーラーのREADME](https://github.com/omacom/omarchy-mac-installer#readme)では、リリースチャンネル、インストーラーの更新、Omarchyの削除について説明しています。

## Intel Mac

簡単なテストでは、2019年製MacBook ProにOmarchyをインストールしただけで36%の性能向上を達成できました。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### MacへのOmarchyのインストール

現時点では、Omarchyは**唯一の**OSとしてインストールされている場合のみサポートしています。インストール中にドライブは消去され、MacOSは起動できなくなります。

希望すれば、後でInternet Recovery経由で復元できます。

このパートでは、すでに[はじめに](02-getting-started.md)を確認し、USBドライブを用意済みであることを前提とします。まだの場合は今すぐ済ませてください。

#### Secure Bootを無効化する

起動可能なUSBとOSを起動するには、AppleのSecure Bootを無効化する必要があります。無効化するには、次の手順を実行してください：

1. Macの電源を切る
2. 電源を入れ、ローディング画面が表示されるまで*すぐに*Command-Rを押し続ける
3. ユーザーを選択し、求められたらパスワードを入力する
4. 復旧画面に入ったら、メニューバーから **Utilities > Startup Security Utility** を選択する
5. 認証を求められたらパスワードを入力する
6. Secure Bootオプションから「No Security」を選択する
7. External Bootオプションから「Allow booting from external or removable media」を選択する

#### インストールを開始する

1. USBドライブを挿入する
2. Macを再起動し、起動デバイスの画面が表示されるまで*すぐに*Optionを押し続ける
3. オレンジ色のEFI Bootデバイスを選択する
4. [通常どおりインストールを進める](02-getting-started.md)

インストーラーはMacのハードウェアを検出し、必要な修正を自動で適用します：Broadcom Wi-Fiドライバーとファームウェア、それが必要なMacBookモデル向けのSPIキーボードドライバー、同じモデル向けのNVMeサスペンド修正です。

### 既知の制限事項

コミュニティのメンバーがこれらの課題の解決策に絶えず取り組んでいるので、これらが問題になる場合は、私たちの [Discord](https://discord.gg/tXFUdasqhY) の #omarchy-on-other に参加し、解決するための最新の方法がないか確認してください。

#### T1チップ搭載デバイス

Apple T1チップは2016年後半に導入され、Touch Bar搭載の第1世代MacBook Proモデルでのみ使われました。
- MacBook Pro 13インチ (2016、Thunderbolt 3ポート2基) – モデル: A1706
- MacBook Pro 13インチ (2016、Thunderbolt 3ポート4基) – モデル: A1708
- MacBook Pro 15インチ (2016) – モデル: A1707

#### 既知の問題

- Touch Barが機能しない
- サウンドが機能しない

#### T2チップ搭載デバイス

Apple T2 Security Chipは2017年に導入されました。T2チップは、2020年に始まったApple silicon (Mシリーズチップ)への移行に伴い廃止されました。

- iMac Pro (2017) – モデル: A1862
- MacBook Pro 13インチ (2018、Thunderbolt 3ポート4基) – モデル: A1989
- MacBook Pro 15インチ (2018) – モデル: A1990
- MacBook Air (Retina、13インチ、2018) – モデル: A1932
- Mac mini (2018) – モデル: A1998
- MacBook Pro 13インチ (2019、Thunderbolt 3ポート2基) – モデル: A2159
- MacBook Pro 13インチ (2019、Thunderbolt 3ポート4基) – モデル: A2178
- MacBook Pro 15インチ (2019) – モデル: A1990
- iMac (Retina 5K、27インチ、2020) – モデル: A2115 (iMac20,1 および iMac20,2)
- MacBook Pro 13インチ (2020、Thunderbolt 3ポート2基) – モデル: A2265
- MacBook Pro 15インチ (2020) – モデル: A1990

これらのモデルでは、インストーラーがパッチ適用済みの `linux-t2` カーネル、T2オーディオ設定、AppleのBroadcom Wi-Fi/Bluetoothファームウェア、`t2fanrd` によるファン制御を自動でセットアップします。Touch Barはカーネル内蔵のBoot Camp風サポートで動作します。

#### iMac Retina 5K (2017)

2017年製27インチiMacにはT2チップがないため、インストーラーは他のIntel Macと同様にセットアップします。

- iMac (Retina 5K、27インチ、2017) – モデル: A1419

#### 既知の問題

- ディスプレイがネイティブの5120×2880で動作しない：パネルは2つのタイルで構成され、標準ドライバーは片方しか点灯させない
- サウンドが機能しない
- 明るさ調整が効かない
- スリープするとマシンがハングする；電源を入れ直すしか復旧できない

このモデル向けのコミュニティ製パッチャーは、ディスプレイ、サウンド、明るさを修正します：[omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
