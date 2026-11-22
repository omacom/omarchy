# ホットキー

主要なキーボードバインディングはすべて `Super + K` で確認できる（Tmux のバインディングは `Super + Alt + K`、Herdr のバインディングは `Super + Ctrl + K`）。

## ホットキーの配置の仕組み

すべてのホットキーは、修飾キーで決まるプレーンの上にあり、各プレーンには1つの役割がある。それがホットキーが混ざり合わない理由であり、たいていどこに何があるか推測できる理由でもある。

| プレーン | そこにあるもの | 例 |
| --- | --- | --- |
| `Super + key` | システム：ウィンドウ、ワークスペース、レイアウト、コアメニュー | `Super + Space` Omarchy メニュー、`Super + W` ウィンドウを閉じる、`Super + F` 全画面 |
| `Super + Shift + key` | アプリ | `Super + Shift + B` ブラウザ、`Super + Shift + E` メール、`Super + Shift + N` エディター |
| `Super + Ctrl + key` | パネルとシステムメニュー | `Super + Ctrl + A` オーディオ、`Super + Ctrl + N` ネットワーク、`Super + Ctrl + C` キャプチャメニュー |
| `Super + Ctrl + Alt + key` | クイックアクションと通知 | `Super + Ctrl + Alt + T` 時刻を表示、`Super + Ctrl + Alt + B` バッテリー、`Super + Ctrl + Alt + C` スクリーンショット |

ホットキーに `Alt` を加えると、同じもののバリエーションになる。決して無関係なものにはならない：

- `Super + Shift + B` はブラウザを開く。`Super + Shift + Alt + B` はプライベートウィンドウを開く
- `Super + Shift + E` はメールを開く。`Super + Shift + Alt + E` は新規メールを開始する
- `Super + F` は全画面にする。`Super + Alt + F` は全幅にする
- `Super + Ctrl + C` はキャプチャメニューを開く。`Super + Ctrl + Alt + C` はメニューをスキップしてスクリーンショットを撮る

ホットキーを追加するときは：

1. 何をするかでプレーンを選び、次にキーを選ぶ。
2. 場所を空けるために既存のホットキーを動かさないこと。適切なプレーンで空いているキーを探す。
3. `Alt` は、それがないホットキーのバリエーションにだけ使う。

便利さのために、これらのルールを破るホットキーがいくつかある。`Shift` と矢印キーや `Tab` の組み合わせはアプリを開くのではなく移動や逆方向への切り替えを行い、`Print`、メディアキー、`Alt + Tab`、`Ctrl + Alt + Del` は他のどこでもそうであるように動作する。これらは例外であり、真似すべきパターンではない。

デフォルトが合わない場合（たとえば Windows のようにスクリーンショットに `Super + Shift + S` を使いたい場合）は、`~/.config/hypr/bindings.lua` で割り当てを変更する。

## 移動

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy メニュー（アプリとその他すべて）    |
| `Super + Alt + Space` | アプリグリッド |
| `Super + Escape` | システムメニュー（サスペンド、再起動など）  |
| `Super + Ctrl + L` | コンピュータをロック |
| `Super + W` or `Super + Q` | ウィンドウを閉じる             |
| `Ctrl + Alt + Del` | すべてのウィンドウを閉じる |
| `Super + K` | すべてのホットキーを表示 |
| `Super + Alt + K` | tmux のホットキーを表示 |
| `Super + Ctrl + K` | herdr のホットキーを表示 |
| `Super + M` | ウィンドウをドックに最小化 |
| `Super + T`               | ウィンドウのタイリング／フローティングを切り替え             |
| `Super + J` | ウィンドウ位置を切り替え（水平／垂直） |
| `Super + O`               | ウィンドウを sticky'n'floating にする切り替え |
| `Super + L`               | dwindle、scrolling、floating レイアウトを順に切り替え |
| `Super + Alt + L`         | レイアウトを逆順に切り替え |
| `Super + P`               | pseudo ウィンドウスタイルを切り替え（natural 対 stretch） |
| `Super + F`                 | 全画面にする              |
| `Super + Alt + F`                 | 全幅にする              |
| `Super + Ctrl + F`                 | ウィンドウ内で全画面にする              |
| `Super + 1…9/0`         | フォーカス中のモニターで特定のワークスペースへ移動（0 は 10） |
| `Super + Tab` | フォーカス中のモニターで次のワークスペースへ移動 |
| `Super + Shift + Tab` | フォーカス中のモニターで前のワークスペースへ移動 |
| `Super + Ctrl + Tab` | フォーカス中のモニターで以前のワークスペースへ移動 |
| `Super + Shift + 1…9/0` | ウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + Shift + Alt + 1…9/0` | 追随せずにウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + S` | フル scratchpad を切り替え |
| `Super + Alt + S` | ウィンドウをフル scratchpad へ移動 |
| `Super + Grave` | Quake コンソールを切り替え |
| `Super + Shift + Grave` | ウィンドウを Quake コンソールへ移動 |
| `Super + Shift + Ctrl + Arrows` | ウィンドウをその方向のモニターへ移動 |
| `Super + Shift + Alt + Arrows` | ワークスペースをその方向のモニターへ移動 |
| `Super + Arrow`  | 矢印の方向のウィンドウへフォーカスを移動し、画面の端ではその側のモニターへ越える |
| `Super + Shift + Arrow`  | 矢印の方向の別のウィンドウと入れ替える。その側のモニターにあるウィンドウも含む |
| `Super + Minus` | ウィンドウを左へ広げる |
| `Super + Equal` | ウィンドウを左へ縮める |
| `Super + Shift + Minus` | ウィンドウを上へ縮める |
| `Super + Shift + Equal` | ウィンドウを下へ広げる |
| `Super + Alt + Minus/Equal` | 同じリサイズをより細かいステップで |
| `Super + Ctrl + Minus/Equal` | 同じリサイズをより大きなステップで |
| `Super + Alt + Home` | ウィンドウ幅を保存 |
| `Super + Home` | 保存したウィンドウ幅を復元 |
| `Super + Left Mouse` | ウィンドウをドラッグして移動 |
| `Super + Right Mouse` | ウィンドウをリサイズ |
| `Super + Scroll Wheel` | フォーカス中のモニターのワークスペースをスクロール |
| `Super + G`               | ウィンドウのグルーピングを切り替え      |
| `Super + Alt + G`               | ウィンドウをグルーピングから外す      |
| `Super + Alt + Tab`               | グループ内のウィンドウを順に切り替え      |
| `Super + Alt + Shift + Tab`               | グループ内のウィンドウを逆順に切り替え      |
| `Super + Alt + Scroll Wheel` | グループ内のウィンドウを順に切り替え |
| `Super + Alt + 1/2/3/4/5`               | グループ内の特定のウィンドウへ移動      |
| `Super + Alt + Arrow`  | 矢印の方向へウィンドウをグループに入れる。その側のモニターにあるウィンドウも含む |
| `Super + Ctrl + Left/Right`  | タイリンググループ内のウィンドウ間を移動 |
| `Super + Ctrl + Z` | 画面をズームイン（繰り返すとさらに拡大） |
| `Super + Ctrl + Alt + Z` | 画面を完全にズームアウト |
| `Super + /` | モニターのスケーリング選択肢を次へ進める |
| `Super + Alt + /` | モニターのスケーリング選択肢を前へ戻す |
| `Alt + Tab` | アクティブなワークスペースのウィンドウを順に切り替え |
| `Alt + Shift + Tab` | アクティブなワークスペースのウィンドウを逆順に切り替え |
| `Ctrl + Alt + Tab`| モニター間を順にフォーカス切り替え |
| `Ctrl + Alt + Shift + Tab`| モニター間を逆順にフォーカス切り替え |
| `Super + I` | 入力言語を切り替え（複数のレイアウトまたは入力方式がある場合） |
| `Super + Shift + I` | 入力言語を元に戻す |

タッチパッドでは、3本指と4本指のスワイプでワークスペースの切り替え、ウィンドウの移動、メニューと Quake コンソールの表示ができる。ジェスチャーは[キーボード、マウス、トラックパッド](34-keyboard-mouse-trackpad.md)を参照。

リサイズのショートカットは、キーボードに印刷された文字に関係なく、物理キー `code:20` と `code:21`（XKB の `<AE11>` と `<AE12>`）を使う。US キーボードではこれらのキーは `-` と `=` で、日本語（JIS）キーボードでは `-` と `^`、スペイン語キーボードでは `'` と `¡` である。JIS では、`Super + ^` が `Super + Equal` であり、`Super + Shift + -`（`=` を入力する）は `Super + Shift + Minus` である。

## システムコントロール

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | オーディオパネル    |
| `Super + Ctrl + B`           | Bluetooth パネル    |
| `Super + Ctrl + N`           | Wifi／ネットワークパネル    |
| `Super + Ctrl + D`           | ディスプレイパネル    |
| `Super + Ctrl + P`           | 電源パネル    |
| `Super + Ctrl + X`           | Agents パネル    |
| `Super + Ctrl + Alt + X`           | ローカルモデルパネル    |
| `Super + Ctrl + Alt + D`           | カレンダーパネル    |
| `Super + Ctrl + Alt + E`           | 世界時計パネル    |
| `Super + Ctrl + 1-9`           | 位置でバーのパネルを切り替え    |
| `Super + Ctrl + S` | 共有メニュー（LocalSend 経由） |
| `Super + Ctrl + C` | キャプチャコントロール（スクリーンショット／録画／ピッカー） |
| `Super + Ctrl + O` | メニューを切り替え |
| `Super + Ctrl + H` | ハードウェアメニュー |
| `Super + Ctrl + E` | 絵文字ピッカー |
| `Super + Ctrl + .` | メディアをトランスコード |
| `Super + Shift + Ctrl + A` | デフォルトのエージェントを起動 |
| `Power` key | システムメニュー |
| `Super + Shift + Copilot` key | Omarchy メニュー |

## 調整

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 画面の輝度を最大にする |
| `Shift + Brightness Down` | 画面の輝度を最小にする |
| `Alt + Brightness Up/Down` | 1%単位の細かい輝度変更 |
| `Alt + Volume Up/Down` | 1%単位の細かい音量変更 |
| `Keyboard Brightness Up/Down` | キーボードバックライトを明るく／暗く |
| `Keyboard Backlight` | キーボードバックライトのレベルを順に切り替え |
| `Ctrl + Brightness Up/Down` | 専用キーのないキーボードでキーボードバックライトを明るく／暗く |
| `Mic Mute` | マイクをミュート |
| `Shift + Mute` | オーディオ出力を切り替え |
| `Touchpad Toggle` | タッチパッドのオン／オフを切り替え |
| `Display` key | ワークスペースレイアウトを順に切り替え |
| `Alt + Play` | 次のトラック |
| `Alt + Shift + Play` | 前のトラック |

## アプリの起動

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Return`           | ターミナル    |
| `Super + Alt + Return` | Tmux ターミナル |
| `Super + Ctrl + Return` | Herdr（エージェントマネージャー） |
| `Super + Shift + Return` or `Super + Shift + B`  | ブラウザ    |
| `Super + Shift + Alt + B`           | ブラウザ（プライベート／シークレット）    |
| `Super + Shift + F`           | ファイルマネージャー    |
| `Super + Shift + Alt + F`           | ターミナルの cwd でファイルマネージャー    |
| `Super + Shift + M`           | 音楽（Spotify）    |
| `Super + Shift + Alt + M`           | 音楽（cliamp）    |
| `Super + Shift + /`           | パスワードマネージャー（1password）    |
| `Super + Shift + Q` or `Calculator` key  | 計算機（Omacalc）    |
| `Super + Shift + D`           | Docker（lazydocker、インストール後）    |
| `Super + Shift + T`           | アクティビティ（btop）    |
| `Super + Shift + N`           | エディター（Plain、または選択したデフォルト）  |
| `Super + Shift + C`           | カレンダー（[HEY](https://hey.com/)）  |
| `Super + Shift + E`           | メール（[HEY](https://hey.com/)）  |
| `Super + Shift + Alt + E`           | 新規メール（[HEY](https://hey.com/)）  |
| `Super + Shift + A`           | デフォルトのエージェント、選択するまでは ChatGPT |
| `Super + Shift + Alt + A`           | AI（Grok）  |
| `Super + Shift + G`           | メッセンジャー（Signal）  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | メッセンジャー（WhatsApp）  |
| `Super + Shift + Ctrl + G`           | メッセンジャー（Google）  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | 執筆（Omawrite）  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X（新規投稿） |
| `Super + Shift + Y`           | YouTube |

バインディングの変更／追加は `~/.config/hypr/bindings.lua` で行う。

## ユニバーサルクリップボード

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` に対応するアプリですべて選択    |
| `Super + C`           | コピー    |
| `Super + X`           | 切り取り（ターミナルでは不可）    |
| `Super + V`           | 貼り付け    |
| `Super + Ctrl + V`           | クリップボードマネージャー    |

Linux では通常、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外では `Ctrl + C/V` が必要だ。これらの Omarchy のユニバーサルクリップボードのホットキーは、どこでも機能する。

## キャプチャ

| ホットキー              | 機能                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | スクリーンショット                      |
| `Super + Ctrl + Alt + C`            | スクリーンショット（同じ撮影、Print Screen キーのないキーボード用） |
| `Super + Ctrl + C` | キャプチャメニュー |
| `Alt + Print Screen`            | 画面録画                     |
| `Super + Shift + Ctrl + Alt + C` | メニューをスキップして音声なしで画面録画（もう一度押すと停止） |
| `Super + Print Screen` | カラーピッカー |
| `Super + Ctrl + Print Screen` | テキストを抽出してクリップボードへ |
| `Super + Alt + [` | 録画中にウェブカメラのオーバーレイを小さくする |
| `Super + Alt + ]` | 録画中にウェブカメラのオーバーレイを大きくする |
| `Alt + Shift + L` | ウェブアプリまたはブラウザから現在の URL をコピー |
| `Alt + Shift + D` | 現在のページの動画を `~/Videos` にダウンロード |
| `Alt + Space` | ディクテーションを開始／停止（_Setup > Defaults > Dictation_ が必要） |
| `Right Alt` | 押し続けてディクテーション（_Setup > Defaults > Dictation_ が必要） |

画面録画では、このホットキーを押すとまずどの音声を使うか尋ねられ、次に録画が始まる。もう一度押すと停止する。詳細は[スクリーンショットと録画](12-screenshots-recording.md)を参照。

すべてのキャプチャオプションは、Omarchy メニュー（`Super + Space`）の _Trigger > Capture_ からも利用できる。

## 通知

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + ,` | 最新の通知に対応する：開くか、その唯一のボタンを押すか、選択肢から選ぶか、選択肢がない場合は閉じる  |
| `Super + Shift + ,` | すべての通知を閉じる |
| `Super + Ctrl + ,` | キーボードで通知を操作  |
| `Super + Alt + ,` | 最新の通知を閉じる  |
| `Super + Shift + Alt + ,` | 通知履歴を開く  |
| `Super + Ctrl + Alt + ,` | 通知のサイレントを切り替え  |

## スタイル

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 新しいテーマを選ぶ（`Super + Ctrl + Shift + Space` でも可） |
| `Super + Ctrl + W` | テーマの背景を選ぶ（`Super + Ctrl + Space` でも可） |
| `Super + Backspace` | ウィンドウの透明度を切り替え |
| `Super + Ctrl + Backspace` | 単一ウィンドウの正方形アスペクトを切り替え |

追加の背景画像は `~/.config/omarchy/backgrounds/<theme name>` にある。Omarchy メニューの _Install > Style > Background_ からも利用できる。

すべてのスタイルオプションは、Omarchy メニュー（`Super + Space`）の _Appearance_ からも利用できる。

## 切り替え

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | アイドル時のロックを切り替え |
| `Super + Ctrl + Delete` | ノートパソコンのディスプレイのオン／オフを切り替え |
| `Super + Ctrl + Alt + Delete` | ノートパソコンのディスプレイのミラーリングを切り替え |
| `Super + Shift + Space` | トップバーを切り替え  |
| `Shift + Mute` | 次のオーディオ出力へ切り替え |
| `Shift + Play` | 次のメディアソースへ切り替え |
| `Super + Shift + Backspace` | ウィンドウのギャップを切り替え |
| `Super + Ctrl + Alt + F` | フルスクリーンデスクトップを切り替え（トップバー＋ウィンドウのギャップ） |

## リマインダー

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | リマインダーを設定  |
| `Super + Ctrl + Alt + R` | すべてのリマインダーを表示  |
| `Super + Ctrl + Shift + R` | すべてのリマインダーをクリア  |

## お知らせ

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 時刻を通知として表示  |
| `Super + Ctrl + Alt + B` | バッテリーを通知として表示  |
| `Super + Ctrl + Alt + W` | 天気を通知として表示する切り替え  |

## Tmux

プレフィックスキーは `Ctrl + Space`（`Ctrl + B` も機能する）。これらのバインディングは `~/.config/tmux/tmux.conf` で変更できる。

### ペイン

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + v` | ペインを横に分割（垂直） |
| `Prefix + h` | ペインを下に分割（水平） |
| `Prefix + x` | ペインをキル |
| `Prefix + z` | ペインのズームを切り替え（全画面） |
| `Alt + Enter` | ペインを下に分割（プレフィックスなし） |
| `Alt + Shift + Enter` | ペインを横に分割（プレフィックスなし） |
| `Alt + Escape` | ペインをキル（プレフィックスなし） |
| `Ctrl + Alt + Arrows` | ペイン間を移動 |
| `Ctrl + Alt + Shift + Arrows` | ペインをリサイズ |

### ウィンドウ

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + c` | 新しいウィンドウ |
| `Prefix + k` | ウィンドウをキル |
| `Prefix + r` | ウィンドウの名前を変更 |
| `Alt + 1-9` | 特定のウィンドウへ移動 |
| `Alt + Arrow Left/Right` | ウィンドウ間を移動 |
| `Alt + Shift + Arrow Left/Right` | ウィンドウを左／右へ移動 |

### セッション

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + C` | 新しいセッション |
| `Prefix + K` | セッションをキル |
| `Prefix + R` | セッションの名前を変更 |
| `Prefix + N` | 次のセッション |
| `Prefix + P` | 前のセッション |
| `Alt + Arrow Up/Down` | セッション間を移動 |
| `Prefix + s` | セッションを一覧表示 |
| `Prefix + d` | セッションからデタッチ |

### コピーモード（vi スタイル）

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + [` | コピーモードに入る |
| `v` | 選択を開始（コピーモード中） |
| `y` | 選択をコピー（コピーモード中） |

### 全般

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + q` | 設定をリロード |
| `Prefix + ?` | Tmux のキーバインディングを表示 |
| `Prefix + :` | コマンドプロンプト |

### Tmux レイアウト関数

これらの関数は Tmux セッション内で実行する必要がある。

| コマンド | 機能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | エディター、AI、ターミナルで開発レイアウトを作成 |
| `tdlm <ai> [<second_ai>]` | サブディレクトリごとに開発レイアウトを作成 |
| `tsl <count> <command>` | 複数ペインの swarm レイアウトを作成 |

## Ghostty ターミナル

Ghostty ターミナルは、Omarchy メニューの _Install > Terminal_ を使ってインストールする。

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 下に新しい分割 |
| `Ctrl + Shift + O` | 横に新しい分割 |
| `Ctrl + Alt + Arrows` | 分割間を移動 |
| `Super + Ctrl + Shift + Arrows` | 分割を10行分リサイズ |
| `Super + Ctrl + Shift + Alt + Arrows` | 分割を100行分リサイズ |
| `Ctrl + Shift + T` | 新しいタブ  |
| `Ctrl + Shift + Arrows` | タブ間を移動 |
| `Alt + Numbers` | 特定のタブへ移動 |
| `Shift + Pg Up/Down` | 履歴をスクロール |
| `Ctrl + Left mouse` | リンクをブラウザで開く |

## ファイルマネージャー

| ホットキー              | 機能                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | パスへ移動                     |
| `Space`               | ファイルをプレビュー（矢印で移動） |
| `Alt + Up`       | 親フォルダへ上がる        |

## Neovim（lazyvim 使用）

### 移動

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `Space`                    | コマンドオプションを表示            |
| `Space Space`              | あいまい検索でファイルを開く      |
| `Space E`                  | サイドバーを切り替え                  |
| `Space G G`                | git コントロールを表示               |
| `Space S G`                | ファイル内容を検索             |
| `Ctrl + W W`               | サイドバーとエディター間をジャンプ |
| `Ctrl + Left/right arrow`  | サイドバーのサイズを変更          |
| `Shift + H`                      | 左のファイルタブへ移動             |
| `Shift + L`                      | 右のファイルタブへ移動            |
| `Space B D`                | ファイルタブを閉じる                  |

### サイドバー内では

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `A`                        | 親ディレクトリに新しいファイルを追加      |
| `Shift + A`                | 親ディレクトリに新しいサブディレクトリを追加    |
| `D`                        | ハイライトされたファイル／ディレクトリを削除     |
| `M`                        | ハイライトされたファイル／ディレクトリを移動       |
| `R`                        | ハイライトされたファイル／ディレクトリの名前を変更     |
| `?`                        | すべてのコマンドのヘルプを表示      |

[LazyVim で設定された Neovim のホットキーをすべて見る](https://www.lazyvim.org/keymaps)。

## クイック絵文字

`Super + Ctrl + E` を使うと、選択をクリップボードに入れる完全な絵文字ピッカーを表示できる。または、これらのクイックアクセスオプションを使うこともできる。

| ホットキー       | EM | ヒント       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 笑顔      |
| `Shift + CapsLock M C` | 😂 | 泣く        |
| `Shift + CapsLock M L` | 😍 | 愛       |
| `Shift + CapsLock M V` | ✌️ | 勝利    |
| `Shift + CapsLock M H` | ❤️ | ハート      |
| `Shift + CapsLock M Y` | 👍 | はい        |
| `Shift + CapsLock M N` | 👎 | いいえ         |
| `Shift + CapsLock M F` | 🖕 | ファック       |
| `Shift + CapsLock M W` | 🤞 | 願い       |
| `Shift + CapsLock M R` | 🤘 | ロック       |
| `Shift + CapsLock M K` | 😘 | キス       |
| `Shift + CapsLock M E` | 🙄 | 目を回す    |
| `Shift + CapsLock M I` | 😉 | ウインク       |
| `Shift + CapsLock M P` | 🙏 | 祈る |
| `Shift + CapsLock M D` | 🤤 | よだれ      |
| `Shift + CapsLock M M` | 💰 | お金      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | 乾杯      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | あいさつ |
| `Shift + CapsLock M A` |💪 | 腕 |
| `Shift + CapsLock M B` |🤯 | 爆発 |

## クイック補完

| ホットキー       | 補完       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | あなたの名前（セットアップ時に入力したもの）  |
| `Shift + CapsLock Space E` | あなたのメールアドレス（セットアップ時に入力したもの）  |

`~/.XCompose` を編集してさらに自分のものを追加でき、その後ターミナルで `omarchy restart xcompose` を実行すると変更が反映される。
