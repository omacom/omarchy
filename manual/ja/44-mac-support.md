# Mac サポート

Omarchy には **Intel Mac** 向けのサポートが組み込まれています。現時点では既知の制限がいくつかありますが、それを把握し、問題ないのであれば、古い Mac に Omarchy を入れて新たな命を吹き込めます。

M シリーズ Mac へのインストールは、現時点では直接サポートされていないことに注意してください。その状況については、[Discord](https://discord.gg/tXFUdasqhY) の #omarchy-on-other で詳しく確認できます。

簡単なテストでは、2019 年製 MacBook Pro に Omarchy をインストールしただけで、36% のパフォーマンス向上を達成できました。

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac に Omarchy をインストールする

Omarchy は現時点では、インストールされる**唯一**の OS であることのみをサポートしています。インストール中にドライブは消去され、MacOS は二度と起動できなくなります。

後で Internet Recovery 経由で復元することは可能です。

このパートでは、すでに [はじめに](02-getting-started.md) を確認し、USB ドライブの準備ができているものとして進めます。まだの場合は、今すぐ準備してください。

#### Secure Boot を無効にする

起動可能な USB と OS の両方を起動するには、Apple の Secure Boot を無効にする必要があります。無効にするには、次を実行してください:

1. Mac の電源を切る
2. 電源を入れ、ロード画面が表示されるまで*すぐに* Command-R を押し続ける
3. ユーザーを選択し、求められたらパスワードを入力する
4. 復旧画面に入ったら、メニューバーから **Utilities > Startup Security Utility** を選択する
5. 認証を求められたらパスワードを入力する
6. Secure Boot オプションから "No Security" を選択する
7. External Boot オプションから "Allow booting from external or removable media" を選択する

#### インストールを開始する

1. USB ドライブを挿入する
2. Mac を再起動し、起動デバイスの画面が表示されるまで*すぐに* Option を押し続ける
3. オレンジ色の EFI Boot デバイスを選択する
4. [通常どおりインストール](02-getting-started.md) を進める

インストーラーは Mac ハードウェアを検出し、必要な修正を自動的に適用します: Broadcom Wi-Fi ドライバーとファームウェア、必要な MacBook モデル向けの SPI キーボードドライバー、それらのモデル向けの NVMe サスペンド修正です。

### 既知の制限事項

コミュニティのメンバーがこれらの課題の解決策に常に取り組んでいます。これらが問題になる場合は、[Discord](https://discord.gg/tXFUdasqhY) の #omarchy-on-other に参加し、最新の解決方法がないか確認してください。

#### T1 チップ搭載デバイス

Apple T1 チップは 2016 年後半に導入され、Touch Bar 搭載の初代 MacBook Pro モデルでのみ使用されました。
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – モデル: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – モデル: A1708
- MacBook Pro 15-inch (2016) – モデル: A1707

#### 既知の問題

- Touch Bar が機能しない
- サウンドが機能しない

#### T2 チップ搭載デバイス

Apple T2 セキュリティチップは 2017 年に導入されました。T2 チップは、2020 年から始まった Apple silicon (M シリーズチップ) への移行に伴い廃止されました。

- iMac Pro (2017) – モデル: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – モデル: A1989
- MacBook Pro 15-inch (2018) – モデル: A1990
- MacBook Air (Retina, 13-inch, 2018) – モデル: A1932
- Mac mini (2018) – モデル: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – モデル: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – モデル: A2178
- MacBook Pro 15-inch (2019) – モデル: A1990
- iMac (Retina 5K, 27-inch, 2020) – モデル: A2115 (iMac20,1 および iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – モデル: A2265
- MacBook Pro 15-inch (2020) – モデル: A1990

これらのモデルでは、インストーラーがパッチ適用済みの `linux-t2` カーネル、T2 オーディオ設定、Apple の Broadcom Wi-Fi/Bluetooth ファームウェア、`t2fanrd` によるファン制御を自動的にセットアップします。Touch Bar は、カーネルに組み込まれた Boot Camp 形式のサポートで動作します。

#### iMac Retina 5K (2017)

2017 年製 27 インチ iMac には T2 チップが搭載されていないため、インストーラーは他の Intel Mac と同様にセットアップします。

- iMac (Retina 5K, 27-inch, 2017) – モデル: A1419

#### 既知の問題

- ディスプレイがネイティブ解像度 5120×2880 で動作しない: パネルは 2 つのタイルで構成されており、標準ドライバーでは片方しか点灯しない
- サウンドが機能しない
- 輝度調整が効かない
- スリープするとマシンがハングする; 電源を入れ直すしか復旧できない

このモデル向けのコミュニティパッチャーがディスプレイ、サウンド、輝度を修正します: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3)。
