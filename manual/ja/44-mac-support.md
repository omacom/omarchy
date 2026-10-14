# Macサポート

Omarchyは**Intel Mac**のサポートを内蔵しています。現時点ではいくつかの既知の制限がありますが、それらを理解し問題ないのであれば、Omarchyをインストールすることで古いMacに新たな命を吹き込むことができます。

MシリーズMacへのインストールは現時点では直接サポートされていません。その状況の詳細は、[Discord](https://discord.gg/tXFUdasqhY)の#omarchy-on-otherで確認できます。

簡単なテストでは、2019年のMacBook ProにOmarchyをインストールするだけで36%のパフォーマンス向上が得られました。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### MacにOmarchyをインストールする

Omarchyは現時点では、インストールされた**唯一の**OSであることのみをサポートしています。インストール中、ドライブは消去され、MacOSは起動できなくなります。

必要であれば、後からインターネット復元で復旧できます。

このパートでは、すでに[はじめに](02-getting-started.md)を確認し、USBドライブを用意できているものとして進めます。まだであれば、今すぐ行ってください。

#### セキュアブートを無効化する

起動可能なUSBとOSそのものを起動するには、Appleのセキュアブートを無効化する必要があります。無効化するには、次を行ってください。

1. Macの電源を切ります
2. 電源を入れ、_すぐに_読み込み画面が表示されるまでCommand-Rを押し続けます
3. ユーザーを選択し、求められたらパスワードを入力します
4. 復旧画面に入ったら、メニューバーから**ユーティリティ > 起動セキュリティユーティリティ**を選びます
5. 認証を求められたらパスワードを入力します
6. セキュアブートのオプションから「セキュリティなし」を選びます
7. 外部起動のオプションから「外部メディアまたはリムーバブルメディアからの起動を許可」を選びます

#### インストールを開始する

1. USBドライブを挿入します
2. Macを再起動し、_すぐに_起動デバイスの画面が表示されるまでOptionを押し続けます
3. オレンジ色のEFI Bootデバイスを選択します
4. [通常どおりインストール](02-getting-started.md)を進めます

インストーラーはMacハードウェアを検出し、必要な修正を自動的に適用します。Broadcom Wi-Fiドライバーとファームウェア、必要なMacBookモデル向けのSPIキーボードドライバー、そして同じモデル向けのNVMeサスペンド修正です。

### 既知の制限

コミュニティのメンバーはこれらの課題の解決策に絶えず取り組んでいます。そのため、これらが問題になる場合は、[Discord](https://discord.gg/tXFUdasqhY)の#omarchy-on-otherに参加し、最新の解決方法があるか確認してください。

#### T1チップ搭載デバイス

Apple T1チップは2016年後半に導入され、Touch Barを備えた第1世代MacBook Proモデルでのみ使われました。
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### 既知の問題

- Touch Barが機能しません
- サウンドが機能しません

#### T2チップ搭載デバイス

Apple T2セキュリティチップは2017年に導入されました。T2チップは、2020年に始まったApple silicon（Mシリーズチップ）への移行に伴い廃止されました。

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

これらのモデルでは、インストーラーが自動的にパッチ済みの`linux-t2`カーネル、T2オーディオ設定、AppleのBroadcom Wi-Fi/Bluetoothファームウェア、そして`t2fanrd`によるファン制御を設定します。Touch Barはカーネル内蔵のBoot Camp方式サポートで動作します。
