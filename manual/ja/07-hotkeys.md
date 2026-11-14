# ホットキー

`Super + K` で主要なキーバインドをすべて確認できます（Tmux のバインドは `Super + Alt + K`、Herdr のバインドは `Super + Ctrl + K`）。

## ホットキーの配置の仕組み

すべてのホットキーは修飾キーで決まる平面の上にあり、各平面には1つの役割があります。それによってホットキーが混ざり合わず、たいていはどこに何があるか推測できます。

| 平面 | そこにあるもの | 例 |
| --- | --- | --- |
| `Super + key` | システム：ウィンドウ、ワークスペース、レイアウト、コアメニュー | `Super + Space` Omarchy メニュー、`Super + W` ウィンドウを閉じる、`Super + F` 全画面 |
| `Super + Shift + key` | アプリ | `Super + Shift + B` ブラウザ、`Super + Shift + E` メール、`Super + Shift + N` エディタ |
| `Super + Ctrl + key` | パネルとシステムメニュー | `Super + Ctrl + A` オーディオ、`Super + Ctrl + N` ネットワーク、`Super + Ctrl + C` キャプチャメニュー |
| `Super + Ctrl + Alt + key` | クイックアクションと通知 | `Super + Ctrl + Alt + T` 時刻を表示、`Super + Ctrl + Alt + B` バッテリー、`Super + Ctrl + Alt + C` スクリーンショット |

ホットキーに `Alt` を加えると、同じもののバリエーションになり、決して無関係なものにはなりません：

- `Super + Shift + B` はブラウザを開きます；`Super + Shift + Alt + B` はプライベートウィンドウを開きます
- `Super + Shift + E` はメールを開きます；`Super + Shift + Alt + E` は新規メールを開始します
- `Super + F` は全画面になります；`Super + Alt + F` は全幅になります
- `Super + Ctrl + C` はキャプチャメニューを開きます；`Super + Ctrl + Alt + C` はメニューをスキップしてスクリーンショットを撮ります

ホットキーを追加するとき：

1. 何をするかから平面を選び、次にキーを選びます。
2. 場所を作るために既存のホットキーを動かさないこと。適切な平面で空いているキーを探すこと。
3. `Alt` は、それがないホットキーのバリエーションにだけ使うこと。

便利なため、これらのルールを破るホットキーがいくつかあります。矢印や `Tab` との `Shift` はアプリを開く代わりに移動や逆転を行い、`Print`、メディアキー、`Alt + Tab`、`Ctrl + Alt + Del` は他のどこでもと同じように動作します。これらは例外であり、真似すべきパターンではありません。

デフォルトが気に入らない場合（Windows のようにスクリーンショットに `Super + Shift + S` を使いたい場合など）、`~/.config/hypr/bindings.lua` で再割り当てしてください。

## ナビゲーション

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy メニュー（アプリなどすべて）    |
| `Super + Alt + Space` | アプリグリッド |
| `Super + Escape` | システムメニュー（サスペンド、再起動など）  |
| `Super + Ctrl + L` | コンピュータをロック |
| `Super + W` or `Super + Q` | ウィンドウを閉じる             |
| `Ctrl + Alt + Del` | すべてのウィンドウを閉じる |
| `Super + T`               | ウィンドウのタイル／フローティングを切り替え             |
| `Super + J` | ウィンドウ位置を切り替え（水平／垂直） |
| `Super + O`               | ウィンドウを sticky'n'floating にポップする切り替え |
| `Super + L`               | dwindle、scrolling、floating レイアウトを順に切り替え |
| `Super + Alt + L`         | レイアウトを逆順に切り替え |
| `Super + P`               | 疑似ウィンドウスタイルを切り替え（natural v stretch） |
| `Super + F`                 | 全画面にする              |
| `Super + Alt + F`                 | 全幅にする              |
| `Super + Ctrl + F`                 | ウィンドウ内で全画面にする              |
| `Super + 1/2/3/4`         | フォーカス中のモニターの特定のワークスペースへ移動 |
| `Super + Tab` | フォーカス中のモニターの次のワークスペースへ移動 |
| `Super + Shift + Tab` | フォーカス中のモニターの前のワークスペースへ移動 |
| `Super + Ctrl + Tab` | フォーカス中のモニターの以前のワークスペースへ移動 |
| `Super + Shift + 1/2/3/4` | ウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + Shift + Alt + 1/2/3/4` | 追従せずにウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + S` | フルスクラッチパッドを切り替え |
| `Super + Alt + S` | ウィンドウをフルスクラッチパッドへ移動 |
| `Super + Grave` | Quake コンソールを切り替え |
| `Super + Shift + Grave` | ウィンドウを Quake コンソールへ移動 |
| `Super + Shift + Ctrl + Arrows` | ウィンドウをその方向のモニターへ移動 |
| `Super + Shift + Alt + Arrows` | ワークスペースをその方向のモニターへ移動 |
| `Super + Arrow`  | 矢印の方向のウィンドウへフォーカスを移動し、画面の端ではその側のモニターへ渡る |
| `Super + Shift + Arrow`  | 矢印の方向の別のウィンドウと入れ替え、その側のモニター上にあるものも含む |
| `Super + Minus` | ウィンドウを左へ拡大 |
| `Super + Equal` | ウィンドウを左へ縮小 |
| `Super + Shift + Minus` | ウィンドウを上へ縮小 |
| `Super + Shift + Equal` | ウィンドウを下へ拡大 |
| `Super + Alt + Minus/Equal` | 同じリサイズをより小さいステップで |
| `Super + Ctrl + Minus/Equal` | 同じリサイズをより大きいステップで |
| `Super + Alt + Home` | ウィンドウ幅を保存 |
| `Super + Home` | 保存したウィンドウ幅を復元 |
| `Super + Left Mouse` | ウィンドウをドラッグして移動 |
| `Super + Right Mouse` | ウィンドウをリサイズ |
| `Super + Scroll Wheel` | フォーカス中のモニターのワークスペースをスクロール |
| `Super + G`               | ウィンドウのグループ化を切り替え      |
| `Super + Alt + G`               | ウィンドウをグループ化から外す      |
| `Super + Alt + Tab`               | グループ内のウィンドウを順に切り替え      |
| `Super + Alt + Shift + Tab`               | グループ内のウィンドウを逆順に切り替え      |
| `Super + Alt + Scroll Wheel` | グループ内のウィンドウを順に切り替え |
| `Super + Alt + 1/2/3/4/5`               | グループ内の特定のウィンドウへ移動      |
| `Super + Alt + Arrow`  | 矢印の方向へウィンドウをグループに入れ、その側のモニター上にあるものも含む |
| `Super + Ctrl + Left/Right`  | タイルグループ内のウィンドウ間を移動 |
| `Super + Ctrl + Z` | 画面をズームイン（繰り返すとさらにズーム） |
| `Super + Ctrl + Alt + Z` | 画面を完全にズームアウト |
| `Super + /` | モニターのスケーリング選択肢を前方へ進む |
| `Super + Alt + /` | モニターのスケーリング選択肢を後方へ進む |
| `Alt + Tab` | アクティブなワークスペースのウィンドウを前方へ順に切り替え |
| `Alt + Shift + Tab` | アクティブなワークスペースのウィンドウを後方へ順に切り替え |
| `Ctrl + Alt + Tab`| モニター間のフォーカスを前方へ順に切り替え |
| `Ctrl + Alt + Shift + Tab`| モニター間のフォーカスを後方へ順に切り替え |

リサイズのショートカットは、キーボードに印字された文字に関係なく、物理キー `code:20` と `code:21`（XKB の `<AE11>` と `<AE12>`）を使います。US キーボードではこれらのキーは `-` と `=` で、日本語（JIS）キーボードでは `-` と `^` で、スペイン語キーボードでは `'` と `¡` です。JIS では、`Super + ^` は `Super + Equal` であり、`Super + Shift + -`（`=` を入力する）は `Super + Shift + Minus` です。

## システムコントロール

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | オーディオパネル    |
| `Super + Ctrl + B`           | Bluetooth パネル    |
| `Super + Ctrl + N`           | Wi-Fi／ネットワークパネル    |
| `Super + Ctrl + D`           | ディスプレイパネル    |
| `Super + Ctrl + P`           | 電源パネル    |
| `Super + Ctrl + X`           | Agents パネル    |
| `Super + Ctrl + Alt + D`           | カレンダーパネル    |
| `Super + Ctrl + Alt + E`           | 世界時計パネル    |
| `Super + Ctrl + 1-9`           | 位置でバーパネルを切り替え    |
| `Super + Ctrl + S` | 共有メニュー（LocalSend 経由） |
| `Super + Ctrl + C` | キャプチャコントロール（スクリーンショット／録画／ピッカー） |
| `Super + Ctrl + O` | メニューを切り替え |
| `Super + Ctrl + H` | ハードウェアメニュー |
| `Super + Ctrl + E` | 絵文字ピッカー |
| `Super + Ctrl + .` | メディアをトランスコード |
| `Super + Shift + Ctrl + A` | AI エージェントを選択 |

## 調整

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 画面の明るさを最大に |
| `Shift + Brightness Down` | 画面の明るさを最小に |
| `Alt + Brightness Up/Down` | 1%単位の細かい明るさ変更 |
| `Alt + Volume Up/Down` | 1%単位の細かい音量変更 |
| `Keyboard Brightness Up/Down` | キーボードバックライトを明るく／暗く |
| `Keyboard Backlight` | キーボードバックライトのレベルを順に切り替え |
| `Alt + Play` | 次のトラック |
| `Alt + Shift + Play` | 前のトラック |

## アプリの起動

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Return`           | ターミナル    |
| `Super + Alt + Return` | Tmux ターミナル |
| `Super + Ctrl + Return` | Herdr（エージェントマネージャー） |
| `Super + Shift + Return`           | ブラウザ    |
| `Super + Shift + Alt + B`           | ブラウザ（プライベート／シークレット）    |
| `Super + Shift + F`           | ファイルマネージャー    |
| `Super + Shift + Alt + F`           | ターミナルの cwd でファイルマネージャー    |
| `Super + Shift + M`           | 音楽（Spotify）    |
| `Super + Shift + Alt + M`           | 音楽（cliamp）    |
| `Super + Shift + /`           | パスワードマネージャー（1password）    |
| `Super + Shift + Q`           | 計算機（Omacalc）    |
| `Super + Shift + T`           | アクティビティ（btop）    |
| `Super + Shift + N`           | エディタ（Neovim）  |
| `Super + Shift + C`           | カレンダー（[HEY](https://hey.com/)）  |
| `Super + Shift + E`           | メール（[HEY](https://hey.com/)）  |
| `Super + Shift + Alt + E`           | 新規メール（[HEY](https://hey.com/)）  |
| `Super + Shift + A`           | AI（ChatGPT）  |
| `Super + Shift + Alt + A`           | AI（Grok）  |
| `Super + Shift + G`           | メッセンジャー（Signal）  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | メッセンジャー（WhatsApp）  |
| `Super + Shift + Ctrl + G`           | メッセンジャー（Google）  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | 執筆（Omawrite）  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

バインドの変更／追加は `~/.config/hypr/bindings.lua` で行います。

## ユニバーサルクリップボード

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` に対応するアプリですべて選択    |
| `Super + C`           | コピー    |
| `Super + X`           | 切り取り（ターミナルでは不可）    |
| `Super + V`           | 貼り付け    |
| `Super + Ctrl + V`           | クリップボードマネージャー    |

通常 Linux では、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外では `Ctrl + C/V` が必要です。これらの Omarchy のユニバーサルクリップボードホットキーはどこでも動作します。

## キャプチャ

| ホットキー              | 機能                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | スクリーンショット                      |
| `Super + Ctrl + Alt + C`            | スクリーンショット（同じ撮影、Print Screen キーがないキーボード用） |
| `Super + Ctrl + C` | キャプチャメニュー |
| `Alt + Print Screen`            | 画面録画                     |
| `Super + Print Screen` | カラーピッカー |
| `Super + Ctrl + Print Screen` | テキスト抽出してクリップボードへ |
| `Super + Alt + [` | 録画中にウェブカメラのオーバーレイを小さくする |
| `Super + Alt + ]` | 録画中にウェブカメラのオーバーレイを大きくする |
| `Alt + Shift + L` | ウェブアプリまたはブラウザから現在の URL をコピー |
| `Alt + Shift + D` | 現在のページの動画を `~/Videos` にダウンロード |
| `Alt + Space` | ディクテーションを開始／停止（_Setup > Defaults > Dictation_ が必要） |
| `Right Alt` | 押している間ディクテーション（_Setup > Defaults > Dictation_ が必要） |

画面録画では、ホットキーを押すとまずどのオーディオが欲しいか尋ねられ、次に録画が開始します。もう一度押すと停止します。詳細は [スクリーンショットと録画](12-screenshots-recording.md) を参照してください。

すべてのキャプチャ選択肢は、Omarchy メニュー（`Super + Space`）の _Trigger > Capture_ からもアクセスできます。

## 通知

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + ,` | 最新の通知に対応する：開くか、唯一のボタンを押すか、選択肢から選ぶか、どれもない場合は閉じる  |
| `Super + Shift + ,` | すべての通知を閉じる |
| `Super + Ctrl + ,` | キーボードで通知を操作  |
| `Super + Alt + ,` | 最新の通知を閉じる  |
| `Super + Shift + Alt + ,` | 通知履歴を開く  |
| `Super + Ctrl + Alt + ,` | 通知のサイレントを切り替え  |

## スタイル

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 新しいテーマを選択（`Super + Ctrl + Shift + Space` でも可） |
| `Super + Ctrl + W` | テーマの背景を選択（`Super + Ctrl + Space` でも可） |
| `Super + Backspace` | ウィンドウの透明度を切り替え |
| `Super + Ctrl + Backspace` | 単一ウィンドウの正方形アスペクトを切り替え |

追加の背景画像は `~/.config/omarchy/backgrounds/<theme name>` にあります。Omarchy メニューの _Install > Style > Background_ からも利用できます。

すべてのスタイル選択肢は、Omarchy メニュー（`Super + Space`）の _Style_ からもアクセスできます。

## 切り替え

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | アイドル時のロックを切り替え |
| `Super + Ctrl + Delete` | ノートパソコンのディスプレイのオン／オフを切り替え |
| `Super + Ctrl + Alt + Delete` | ノートパソコンのディスプレイのミラーリングを切り替え |
| `Super + Shift + Space` | トップバーを切り替え  |
| `Shift + Mute` | 次のオーディオ出力へ切り替え |
| `Shift + Play` | 次のメディアソースへ切り替え |
| `Super + Shift + Backspace` | ウィンドウギャップを切り替え |
| `Super + Ctrl + Alt + F` | フルスクリーンデスクトップを切り替え（トップバー＋ウィンドウギャップ） |

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
| `Super + Ctrl + Alt + W` | 天気を通知として切り替え表示  |

## Tmux

プレフィックスキーは `Ctrl + Space` です（`Ctrl + B` も動作します）。これらのバインドは `~/.config/tmux/tmux.conf` で変更できます。

### ペイン

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + v` | ペインを横に分割（垂直） |
| `Prefix + h` | ペインを下に分割（水平） |
| `Prefix + x` | ペインを終了 |
| `Prefix + z` | ペインのズームを切り替え（全画面） |
| `Alt + Enter` | ペインを下に分割（プレフィックスなし） |
| `Alt + Shift + Enter` | ペインを横に分割（プレフィックスなし） |
| `Alt + Escape` | ペインを終了（プレフィックスなし） |
| `Ctrl + Alt + Arrows` | ペイン間を移動 |
| `Ctrl + Alt + Shift + Arrows` | ペインをリサイズ |

### ウィンドウ

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + c` | 新規ウィンドウ |
| `Prefix + k` | ウィンドウを終了 |
| `Prefix + r` | ウィンドウ名を変更 |
| `Alt + 1-9` | 特定のウィンドウへ移動 |
| `Alt + Arrow Left/Right` | ウィンドウ間を移動 |
| `Alt + Shift + Arrow Left/Right` | ウィンドウを左／右へ移動 |

### セッション

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + C` | 新規セッション |
| `Prefix + K` | セッションを終了 |
| `Prefix + R` | セッション名を変更 |
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

### 一般

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + q` | 設定をリロード |
| `Prefix + ?` | Tmux のキーバインドを表示 |
| `Prefix + :` | コマンドプロンプト |

### Tmux レイアウト関数

これらの関数は Tmux セッション内で実行する必要があります。

| コマンド | 機能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | エディタ、AI、ターミナルを使った開発レイアウトを作成 |
| `tdlm <ai> [<second_ai>]` | サブディレクトリごとに開発レイアウトを作成 |
| `tsl <count> <command>` | マルチペインの swarm レイアウトを作成 |

## Ghostty ターミナル

Ghostty ターミナルは、Omarchy メニューの _Install > Terminal_ を使ってインストールします。

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 下に新規分割 |
| `Ctrl + Shift + O` | 横に新規分割 |
| `Ctrl + Alt + Arrows` | 分割間を移動 |
| `Super + Ctrl + Shift + Arrows` | 分割を10行分リサイズ |
| `Super + Ctrl + Shift + Alt + Arrows` | 分割を100行分リサイズ |
| `Ctrl + Shift + T` | 新規タブ  |
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

## Neovim (w/ lazyvim)

### ナビゲーション

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `Space`                    | コマンド選択肢を表示            |
| `Space Space`              | ファジー検索でファイルを開く      |
| `Space E`                  | サイドバーを切り替え                  |
| `Space G G`                | git コントロールを表示               |
| `Space S G`                | ファイル内容を検索             |
| `Ctrl + W W`               | サイドバーとエディタ間を移動 |
| `Ctrl + Left/right arrow`  | サイドバーのサイズを変更          |
| `Shift + H`                      | 左のファイルタブへ移動             |
| `Shift + L`                      | 右のファイルタブへ移動            |
| `Space B D`                | ファイルタブを閉じる                  |

### サイドバー使用中

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `A`                        | 親ディレクトリに新規ファイルを追加      |
| `Shift + A`                | 親ディレクトリに新規サブディレクトリを追加    |
| `D`                        | ハイライトされたファイル／ディレクトリを削除     |
| `M`                        | ハイライトされたファイル／ディレクトリを移動       |
| `R`                        | ハイライトされたファイル／ディレクトリの名前を変更     |
| `?`                        | すべてのコマンドのヘルプを表示      |

[LazyVim で設定された Neovim のホットキーをすべて見る](https://www.lazyvim.org/keymaps)

## クイック絵文字

`Super + Ctrl + E` を使うと、選択をクリップボードに入れる完全な絵文字ピッカーを表示できます。または、これらのクイックアクセス選択肢も使えます。

| ホットキー       | EM | ヒント       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 笑顔      |
| `Shift + CapsLock M C` | 😂 | 泣き顔        |
| `Shift + CapsLock M L` | 😍 | 大好き       |
| `Shift + CapsLock M V` | ✌️ | 勝利    |
| `Shift + CapsLock M H` | ❤️ | ハート      |
| `Shift + CapsLock M Y` | 👍 | はい        |
| `Shift + CapsLock M N` | 👎 | いいえ         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | 願い       |
| `Shift + CapsLock M R` | 🤘 | ロック       |
| `Shift + CapsLock M K` | 😘 | キス       |
| `Shift + CapsLock M E` | 🙄 | あきれ顔    |
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
| `Shift + CapsLock M B` |🤯 | 衝撃 |

## クイック補完

| ホットキー       | 補完       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | あなたの名前（セットアップ時に入力したもの）  |
| `Shift + CapsLock Space E` | あなたのメール（セットアップ時に入力したもの）  |

`~/.XCompose` を編集してさらに追加でき、ターミナルで `omarchy-restart-xcompose` を実行すると変更が反映されます。
