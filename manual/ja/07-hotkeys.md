# ホットキー

`Super + K` で主要なキーバインドをすべて確認できます（Tmux のバインドは `Super + Alt + K`、Herdr のバインドは `Super + Ctrl + K`）。

## ホットキーの配置の仕組み

すべてのホットキーは、修飾キーによって決まるプレーンの上に置かれ、各プレーンには1つの役割があります。それによってホットキーが混ざり合うことがなく、たいていはどこに何があるか推測できます。

| プレーン | そこに置かれるもの | 例 |
| --- | --- | --- |
| `Super + key` | システム：ウィンドウ、ワークスペース、レイアウト、コアメニュー | `Super + Space` Omarchy メニュー、`Super + W` ウィンドウを閉じる、`Super + F` フルスクリーン |
| `Super + Shift + key` | アプリ | `Super + Shift + B` ブラウザ、`Super + Shift + E` メール、`Super + Shift + N` エディタ |
| `Super + Ctrl + key` | パネルとシステムメニュー | `Super + Ctrl + A` オーディオ、`Super + Ctrl + N` ネットワーク、`Super + Ctrl + C` キャプチャメニュー |
| `Super + Ctrl + Alt + key` | クイックアクションと通知 | `Super + Ctrl + Alt + T` 時刻を表示、`Super + Ctrl + Alt + B` バッテリー、`Super + Ctrl + Alt + C` スクリーンショット |

ホットキーに `Alt` を加えると、同じもののバリエーションになります。決して無関係なものにはなりません：

- `Super + Shift + B` はブラウザを開きます；`Super + Shift + Alt + B` はプライベートウィンドウを開きます
- `Super + Shift + E` はメールを開きます；`Super + Shift + Alt + E` は新規メールを開始します
- `Super + F` はフルスクリーンになります；`Super + Alt + F` はフル幅になります
- `Super + Ctrl + C` はキャプチャメニューを開きます；`Super + Ctrl + Alt + C` はメニューをスキップしてスクリーンショットを撮ります

ホットキーを追加するときは：

1. 何をするかからプレーンを選び、次にキーを選びます。
2. 場所を作るために既存のホットキーを移動しないでください。適切なプレーン上の空いているキーを探してください。
3. `Alt` は、それがないホットキーのバリエーションにだけ使ってください。

便利だからという理由でこれらのルールを破っているホットキーがいくつかあります。矢印キーや `Tab` との `Shift` はアプリを開くのではなく移動や逆方向への動作をし、`Print`、メディアキー、`Alt + Tab`、`Ctrl + Alt + Del` は他のどこでもそうであるように動作します。これらは例外であって、真似すべきパターンではありません。

デフォルトが合わない場合（たとえば Windows のようにスクリーンショットに `Super + Shift + S` を使いたい場合）は、`~/.config/hypr/bindings.lua` で再設定してください。

## ナビゲーション

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy メニュー（アプリとその他すべて）    |
| `Super + Alt + Space` | アプリグリッド |
| `Super + Escape` | システムメニュー（サスペンド、再起動など）  |
| `Super + Ctrl + L` | コンピュータをロック |
| `Super + W` or `Super + Q` | ウィンドウを閉じる             |
| `Ctrl + Alt + Del` | すべてのウィンドウを閉じる |
| `Super + K` | すべてのホットキーを表示 |
| `Super + Alt + K` | tmux ホットキーを表示 |
| `Super + Ctrl + K` | herdr ホットキーを表示 |
| `Super + M` | ウィンドウをドックに最小化 |
| `Super + T`               | ウィンドウのタイル／フローティングを切り替え             |
| `Super + J` | ウィンドウの位置を切り替え（水平／垂直） |
| `Super + O`               | ウィンドウを sticky'n'floating にポップする切り替え |
| `Super + L`               | dwindle、scrolling、floating レイアウトを順に切り替え |
| `Super + Alt + L`         | レイアウトを逆順に切り替え |
| `Super + P`               | 疑似ウィンドウスタイルを切り替え（natural v stretch） |
| `Super + F`                 | フルスクリーンにする              |
| `Super + Alt + F`                 | フル幅にする              |
| `Super + Ctrl + F`                 | ウィンドウ内でフルスクリーンにする              |
| `Super + 1…9/0`         | フォーカス中のモニターで特定のワークスペースへジャンプ（0 は 10） |
| `Super + Tab` | フォーカス中のモニターで次のワークスペースへジャンプ |
| `Super + Shift + Tab` | フォーカス中のモニターで前のワークスペースへジャンプ |
| `Super + Ctrl + Tab` | フォーカス中のモニターで以前のワークスペースへジャンプ |
| `Super + Shift + 1…9/0` | ウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + Shift + Alt + 1…9/0` | ウィンドウをフォーカス中のモニターのワークスペースへ移動（追従しない） |
| `Super + S` | フルスクラッチパッドを切り替え |
| `Super + Alt + S` | ウィンドウをフルスクラッチパッドへ移動 |
| `Super + the key above Tab` (grave on US layouts) | Quake コンソールを切り替え |
| `Super + Shift + the key above Tab` (grave on US layouts) | ウィンドウを Quake コンソールへ移動 |
| `Super + Shift + Ctrl + Arrows` | ウィンドウをその方向のモニターへ移動 |
| `Super + Shift + Alt + Arrows` | ワークスペースをその方向のモニターへ移動 |
| `Super + Arrow`  | 矢印の方向のウィンドウへフォーカスを移動し、画面の端ではその側のモニターへ渡る |
| `Super + Shift + Arrow`  | ウィンドウを矢印の方向の別のウィンドウと入れ替え、その側のモニター上のものも含む |
| `Super + Minus` | ウィンドウを左へ拡大 |
| `Super + Equal` | ウィンドウを左へ縮小 |
| `Super + Shift + Minus` | ウィンドウを上へ縮小 |
| `Super + Shift + Equal` | ウィンドウを下へ拡大 |
| `Super + Alt + Minus/Equal` | より小さなステップで同じリサイズ |
| `Super + Ctrl + Minus/Equal` | より大きなステップで同じリサイズ |
| `Super + Alt + Home` | ウィンドウ幅を保存 |
| `Super + Home` | 保存したウィンドウ幅を復元 |
| `Super + Left Mouse` | ウィンドウをドラッグして移動 |
| `Super + Right Mouse` | ウィンドウをリサイズ |
| `Super + Scroll Wheel` | フォーカス中のモニターでワークスペースをスクロール |
| `Super + G`               | ウィンドウのグルーピングを切り替え      |
| `Super + Alt + G`               | ウィンドウをグルーピングから出す      |
| `Super + Alt + Tab`               | グルーピング内のウィンドウを順に切り替え      |
| `Super + Alt + Shift + Tab`               | グルーピング内のウィンドウを逆順に切り替え      |
| `Super + Alt + Scroll Wheel` | グルーピング内のウィンドウを順に切り替え |
| `Super + Alt + 1/2/3/4/5`               | グルーピング内の特定のウィンドウへジャンプ      |
| `Super + Alt + Arrow`  | ウィンドウを矢印の方向のグルーピングへ移動し、その側のモニター上のものも含む |
| `Super + Ctrl + Left/Right`  | タイルグループ内のウィンドウ間を移動 |
| `Super + Ctrl + Z` | 画面をズームイン（繰り返すとさらにズーム） |
| `Super + Ctrl + Alt + Z` | 画面を完全にズームアウト |
| `Super + /` | モニターのスケーリングオプションを前へ進める |
| `Super + Alt + /` | モニターのスケーリングオプションを後ろへ戻す |
| `Alt + Tab` | アクティブなワークスペースのウィンドウを前方向に順に切り替え |
| `Alt + Shift + Tab` | アクティブなワークスペースのウィンドウを後ろ方向に順に切り替え |
| `Ctrl + Alt + Tab`| モニター間でフォーカスを前方向に順に切り替え |
| `Ctrl + Alt + Shift + Tab`| モニター間でフォーカスを後ろ方向に順に切り替え |
| `Super + I` | 入力言語を切り替え（複数のレイアウトまたは入力方式がある場合） |
| `Super + Shift + I` | 入力言語を逆方向に切り替え |

タッチパッドでは、3本指と4本指のスワイプでワークスペースの切り替え、ウィンドウの移動、メニューと Quake コンソールの表示ができます；ジェスチャーについては [キーボード、マウス、トラックパッド](34-keyboard-mouse-trackpad.md) を参照してください。

リサイズには 0 の右にある2つのキーを使います。キーボードに何が印字されているかは関係ありません：US キーボードでは `-` と `=`、デンマーク語とスウェーデン語では `+` と `´`、ノルウェー語では `+` と `\`、ドイツ語では `ß` と `´`、スペイン語では `'` と `¡`、日本語（JIS）では `-` と `^` です。`Super + K` では、あなたのキーボードに印字されているとおりに表示されます。JIS では、`Super + ^` は `Super + Equal` であり、`Super + Shift + -`（`=` を入力します）は `Super + Shift + Minus` です。モニターのスケーリングとパスワードマネージャーは `/` を使います；Shift を押さないと `/` を入力できないレイアウト（ほとんどのヨーロッパのレイアウトがそうです）では、代わりに右 Shift の左にあるキーを使います（デンマーク語とドイツ語では `-`）。

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
| `Super + Ctrl + 1-9`           | 位置によってバーパネルを切り替え    |
| `Super + Ctrl + S` | 共有メニュー（LocalSend 経由） |
| `Super + Ctrl + C` | キャプチャコントロール（スクリーンショット／録画／ピッカー） |
| `Super + Ctrl + O` | トグルメニュー |
| `Super + Ctrl + H` | ハードウェアメニュー |
| `Super + Ctrl + E` | 絵文字ピッカー |
| `Super + Ctrl + .` | メディアをトランスコード |
| `Super + Shift + Ctrl + A` | デフォルトのエージェントを開始 |
| `Power` key | システムメニュー |
| `Super + Shift + Copilot` key | Omarchy メニュー |

## 調整

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 画面の明るさを最大に |
| `Shift + Brightness Down` | 画面の明るさを最小に |
| `Alt + Brightness Up/Down` | 1%単位の正確な明るさ変更 |
| `Alt + Volume Up/Down` | 1%単位の正確な音量変更 |
| `Keyboard Brightness Up/Down` | キーボードバックライトを明るく／暗く |
| `Keyboard Backlight` | キーボードバックライトのレベルを順に切り替え |
| `Ctrl + Brightness Up/Down` | 専用キーのないキーボードでキーボードバックライトを明るく／暗く |
| `Mic Mute` | マイクをミュート |
| `Shift + Mute` | オーディオ出力を切り替え |
| `Touchpad Toggle` | タッチパッドのオン／オフ |
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
| `Super + Shift + Q` or `Calculator` key  | 電卓（Omacalc）    |
| `Super + Shift + D`           | Docker（lazydocker、インストール後）    |
| `Super + Shift + T`           | アクティビティ（btop）    |
| `Super + Shift + N`           | エディタ（Plain、または選択したデフォルト）  |
| `Super + Shift + C`           | カレンダー（[HEY](https://hey.com/)）  |
| `Super + Shift + E`           | メール（[HEY](https://hey.com/)）  |
| `Super + Shift + Alt + E`           | 新規メール（[HEY](https://hey.com/)）  |
| `Super + Shift + A`           | デフォルトのエージェント、または選択するまでは ChatGPT |
| `Super + Shift + Alt + A`           | AI（Grok）  |
| `Super + Shift + G`           | メッセンジャー（Signal）  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | メッセンジャー（WhatsApp）  |
| `Super + Shift + Ctrl + G`           | メッセンジャー（Google）  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | ライティング（Omawrite）  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X（新規投稿） |
| `Super + Shift + Y`           | YouTube |

バインドの変更／追加は `~/.config/hypr/bindings.lua` で行います。

## ユニバーサルクリップボード

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` に対応するアプリで全選択    |
| `Super + C`           | コピー    |
| `Super + X`           | カット（ターミナルでは不可）    |
| `Super + V`           | ペースト    |
| `Super + Ctrl + V`           | クリップボードマネージャー    |

通常 Linux では、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外では `Ctrl + C/V` が必要です。これらの Omarchy の統合クリップボードホットキーはどこでも動作します。

## キャプチャ

| ホットキー              | 機能                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | スクリーンショット                      |
| `Super + Ctrl + Alt + C`            | スクリーンショット（同じ撮影、Print Screen キーのないキーボード向け） |
| `Super + Ctrl + C` | キャプチャメニュー |
| `Alt + Print Screen`            | 画面録画                     |
| `Super + Shift + Ctrl + Alt + C` | 音声なしの画面録画、メニューをスキップ（もう一度押すと停止） |
| `Super + Print Screen` | カラーピッカー |
| `Super + Ctrl + Print Screen` | クリップボードへのテキスト抽出 |
| `Super + Alt + [` | 録画中にウェブカメラオーバーレイを小さくする |
| `Super + Alt + ]` | 録画中にウェブカメラオーバーレイを大きくする |
| `Alt + Shift + L` | ウェブアプリまたはブラウザから現在の URL をコピー |
| `Alt + Shift + D` | 現在のページの動画を `~/Videos` にダウンロード |
| `Alt + Space` | ディクテーションの開始／停止（_Setup > Defaults > Dictation_ が必要） |
| `Right Alt` | 押し続けてディクテーション（_Setup > Defaults > Dictation_ が必要） |

画面録画では、ホットキーを押すとまずどの音声が欲しいか尋ねられ、それから録画が開始します。もう一度押すと停止します。詳細については [スクリーンショットと録画](12-screenshots-recording.md) を参照してください。

すべてのキャプチャオプションは、Omarchy メニュー（`Super + Space`）の _Trigger > Capture_ からもアクセスできます。

## 通知

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + ,` | 最新の通知に作用する：開くか、その唯一のボタンを押すか、その選択肢から選ぶか、どれもない場合は閉じる  |
| `Super + Shift + ,` | すべての通知を閉じる |
| `Super + Ctrl + ,` | キーボードで通知を制御 |
| `Super + Alt + ,` | 最新の通知を閉じる  |
| `Super + Shift + Alt + ,` | 通知履歴を開く  |
| `Super + Ctrl + Alt + ,` | 通知のサイレンスを切り替え  |

## スタイル

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 新しいテーマを選ぶ（`Super + Ctrl + Shift + Space` でも可） |
| `Super + Ctrl + W` | テーマの背景を選ぶ（`Super + Ctrl + Space` でも可） |
| `Super + Backspace` | ウィンドウの透明度を切り替え |
| `Super + Ctrl + Backspace` | 単一ウィンドウの正方形アスペクトを切り替え |

追加の背景画像は `~/.config/omarchy/backgrounds/<theme name>` にあります。Omarchy メニューの _Install > Style > Background_ からも利用できます。

すべてのスタイルオプションは、Omarchy メニュー（`Super + Space`）の _Appearance_ からもアクセスできます。

## トグル

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | アイドル時のロックを切り替え |
| `Super + Ctrl + Delete` | ラップトップディスプレイのオン／オフを切り替え |
| `Super + Ctrl + Alt + Delete` | ラップトップディスプレイのミラーリングを切り替え |
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
| `Super + Ctrl + Alt + W` | 天気を通知として切り替え  |

## Tmux

プレフィックスキーは `Ctrl + Space` です（`Ctrl + B` も動作します）。これらのバインドは `~/.config/tmux/tmux.conf` で変更できます。

### ペイン

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + v` | ペインを横に分割（垂直） |
| `Prefix + h` | ペインを下に分割（水平） |
| `Prefix + x` | ペインを終了 |
| `Prefix + z` | ペインのズームを切り替え（フルスクリーン） |
| `Alt + Enter` | ペインを下に分割（プレフィックスなし） |
| `Alt + Shift + Enter` | ペインを横に分割（プレフィックスなし） |
| `Alt + Escape` | ペインを終了（プレフィックスなし） |
| `Ctrl + Alt + Arrows` | ペイン間を移動 |
| `Ctrl + Alt + Shift + Arrows` | ペインをリサイズ |

### ウィンドウ

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + c` | 新しいウィンドウ |
| `Prefix + k` | ウィンドウを終了 |
| `Prefix + r` | ウィンドウの名前を変更 |
| `Alt + 1-9` | 特定のウィンドウへ移動 |
| `Alt + Arrow Left/Right` | ウィンドウ間を移動 |
| `Alt + Shift + Arrow Left/Right` | ウィンドウを左／右へ移動 |

### セッション

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + C` | 新しいセッション |
| `Prefix + K` | セッションを終了 |
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
| `v` | 選択を開始（コピーモード内） |
| `y` | 選択をコピー（コピーモード内） |

### 一般

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + q` | 設定を再読み込み |
| `Prefix + ?` | Tmux キーバインドを表示 |
| `Prefix + :` | コマンドプロンプト |

### Tmux レイアウト関数

これらの関数は Tmux セッション内で実行しなければなりません。

| コマンド | 機能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | エディタ、AI、ターミナルによる開発レイアウトを作成 |
| `tdlm <ai> [<second_ai>]` | サブディレクトリごとに開発レイアウトを作成 |
| `tsl <count> <command>` | マルチペインのスウォームレイアウトを作成 |

## Ghostty ターミナル

Ghostty ターミナルは、Omarchy メニューの _Install > Terminal_ でインストールします。

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
| `Ctrl + Left mouse` | ブラウザでリンクを開く |

## ファイルマネージャー

| ホットキー              | 機能                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | パスへ移動                     |
| `Space`               | ファイルをプレビュー（矢印で移動） |
| `Alt + Up`       | 親フォルダへ上がる        |

## Neovim（lazyvim 付き）

### ナビゲーション

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `Space`                    | コマンドオプションを表示            |
| `Space Space`              | ファジー検索でファイルを開く      |
| `Space E`                  | サイドバーを切り替え                  |
| `Space G G`                | git コントロールを表示               |
| `Space S G`                | ファイル内容を検索             |
| `Ctrl + W W`               | サイドバーとエディタ間をジャンプ |
| `Ctrl + Left/right arrow`  | サイドバーのサイズを変更          |
| `Shift + H`                      | 左のファイルタブへ移動             |
| `Shift + L`                      | 右のファイルタブへ移動            |
| `Space B D`                | ファイルタブを閉じる                  |

### サイドバー内

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `A`                        | 親ディレクトリに新しいファイルを追加      |
| `Shift + A`                | 親ディレクトリに新しいサブディレクトリを追加    |
| `D`                        | ハイライトされたファイル／ディレクトリを削除     |
| `M`                        | ハイライトされたファイル／ディレクトリを移動       |
| `R`                        | ハイライトされたファイル／ディレクトリの名前を変更     |
| `?`                        | すべてのコマンドのヘルプを表示      |

[LazyVim で設定されたすべての Neovim ホットキーを見る](https://www.lazyvim.org/keymaps)。

## クイック絵文字

`Super + Ctrl + E` を使うと、選択をクリップボードに入れる完全な絵文字ピッカーを表示できます。またはこれらのクイックアクセスオプションも使えます。

| ホットキー       | EM | ヒント       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smile      |
| `Shift + CapsLock M C` | 😂 | cry        |
| `Shift + CapsLock M L` | 😍 | love       |
| `Shift + CapsLock M V` | ✌️ | victory    |
| `Shift + CapsLock M H` | ❤️ | heart      |
| `Shift + CapsLock M Y` | 👍 | yes        |
| `Shift + CapsLock M N` | 👎 | no         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | wish       |
| `Shift + CapsLock M R` | 🤘 | rock       |
| `Shift + CapsLock M K` | 😘 | kiss       |
| `Shift + CapsLock M E` | 🙄 | eyeroll    |
| `Shift + CapsLock M I` | 😉 | wink       |
| `Shift + CapsLock M P` | 🙏 | pray |
| `Shift + CapsLock M D` | 🤤 | drool      |
| `Shift + CapsLock M M` | 💰 | money      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | toast      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | greeting |
| `Shift + CapsLock M A` |💪 | arm |
| `Shift + CapsLock M B` |🤯 | blowing |

## クイック補完

| ホットキー       | 補完       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | あなたの名前（セットアップ時に入力したもの）  |
| `Shift + CapsLock Space E` | あなたのメール（セットアップ時に入力したもの）  |

`~/.XCompose` を編集して自分のものを追加できます。その後、ターミナルで `omarchy restart xcompose` を実行すると変更が反映されます。
