# ホットキー

主なキーボードバインディングはすべて `Super + K` で確認できます（Tmuxバインディングは `Super + Alt + K`、Herdrバインディングは `Super + Ctrl + K`）。

## ナビゲーション

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchyメニュー（アプリとその他すべて）    |
| `Super + Alt + Space` | アプリグリッド |
| `Super + Escape` | システムメニュー（サスペンド、再起動など）  |
| `Super + Ctrl + L` | コンピュータをロック |
| `Super + W` or `Super + Q` | ウィンドウを閉じる             |
| `Ctrl + Alt + Del` | すべてのウィンドウを閉じる |
| `Super + T`               | ウィンドウのタイリング/フローティングを切り替え             |
| `Super + J` | ウィンドウの位置を切り替え（水平/垂直） |
| `Super + O`               | ウィンドウをsticky'n'floatingへポップする切り替え |
| `Super + L`               | dwindle、scrolling、floatingレイアウトを順に切り替え |
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
| `Super + Grave` | Quakeコンソールを切り替え |
| `Super + Shift + Grave` | ウィンドウをQuakeコンソールへ移動 |
| `Super + Shift + Ctrl + Arrows` | ウィンドウをその方向のモニターへ移動 |
| `Super + Shift + Alt + Arrows` | ワークスペースをその方向のモニターへ移動 |
| `Super + Arrow`  | 矢印の方向のウィンドウへフォーカスを移動し、画面端ではその側のモニターへ渡る |
| `Super + Shift + Arrow`  | 矢印の方向の別のウィンドウと入れ替える。その側のモニターにあるウィンドウも含む |
| `Super + Minus` | ウィンドウを左へ拡大 |
| `Super + Equal` | ウィンドウを左へ縮小 |
| `Super + Shift + Minus` | ウィンドウを上へ縮小 |
| `Super + Shift + Equal` | ウィンドウを下へ拡大 |
| `Super + Alt + Minus/Equal` | 同じリサイズを小刻みに行う |
| `Super + Ctrl + Minus/Equal` | 同じリサイズを大刻みに行う |
| `Super + Alt + Home` | ウィンドウ幅を保存 |
| `Super + Home` | 保存したウィンドウ幅を復元 |
| `Super + Left Mouse` | ウィンドウをドラッグで移動 |
| `Super + Right Mouse` | ウィンドウをリサイズ |
| `Super + Scroll Wheel` | フォーカス中のモニターのワークスペースをスクロール |
| `Super + G`               | ウィンドウのグルーピングを切り替え      |
| `Super + Alt + G`               | ウィンドウをグルーピングから出す      |
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
| `Ctrl + Alt + Tab`| モニター間でフォーカスを順に移動 |
| `Ctrl + Alt + Shift + Tab`| モニター間でフォーカスを逆順に移動 |

リサイズ用ショートカットは、キーボードに印字された文字に関係なく、物理キー `code:20` と `code:21`（XKB `<AE11>` と `<AE12>`）を使用します。USキーボードではこれらのキーは `-` と `=` で、日本語（JIS）キーボードでは `-` と `^` で、スペイン語キーボードでは `'` と `¡` です。JISでは、`Super + ^` が `Super + Equal` で、`Super + Shift + -`（`=` を入力する）は `Super + Shift + Minus` です。

## システムコントロール

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | オーディオパネル    |
| `Super + Ctrl + B`           | Bluetoothパネル    |
| `Super + Ctrl + N`           | Wi-Fi/ネットワークパネル    |
| `Super + Ctrl + D`           | ディスプレイパネル    |
| `Super + Ctrl + P`           | 電源パネル    |
| `Super + Ctrl + Alt + D`           | カレンダーパネル    |
| `Super + Ctrl + Alt + E`           | 世界時計パネル    |
| `Super + Ctrl + 1-9`           | 位置でバーパネルを切り替え    |
| `Super + Ctrl + S` | 共有メニュー（LocalSend経由） |
| `Super + Ctrl + C` | キャプチャコントロール（スクリーンショット/-録画/ピッカー） |
| `Super + Ctrl + O` | トグルメニュー |
| `Super + Ctrl + H` | ハードウェアメニュー |
| `Super + Ctrl + E` | 絵文字ピッカー |
| `Super + Ctrl + .` | メディアをトランスコード |
| `Super + Shift + Ctrl + A` | AIエージェントを選択 |

## 調整

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 画面の輝度を最大にする |
| `Shift + Brightness Down` | 画面の輝度を最小にする |
| `Alt + Brightness Up/Down` | 正確な1%刻みの輝度変更 |
| `Alt + Volume Up/Down` | 正確な1%刻みの音量変更 |
| `Keyboard Brightness Up/Down` | キーボードバックライトを明るく/暗くする |
| `Keyboard Backlight` | キーボードバックライトのレベルを順に切り替え |
| `Alt + Play` | 次のトラック |
| `Alt + Shift + Play` | 前のトラック |

## アプリの起動

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Return`           | ターミナル    |
| `Super + Alt + Return` | Tmuxターミナル |
| `Super + Ctrl + Return` | Herdr（エージェントマネージャー） |
| `Super + Shift + Return`           | ブラウザ    |
| `Super + Shift + Alt + B`           | ブラウザ（プライベート/シークレット）    |
| `Super + Shift + F`           | ファイルマネージャー    |
| `Super + Shift + Alt + F`           | ターミナルのcwdでファイルマネージャー    |
| `Super + Shift + M`           | 音楽（Spotify）    |
| `Super + Shift + Alt + M`           | 音楽（cliamp）    |
| `Super + Shift + /`           | パスワードマネージャー（1password）    |
| `Super + Shift + Q`           | 電卓（Omacalc）    |
| `Super + Shift + T`           | アクティビティ（btop）    |
| `Super + Shift + N`           | エディター（Neovim）  |
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
| `Super + Shift + Alt + X`           | Xの投稿作成 |
| `Super + Shift + Y`           | YouTube |

バインディングの変更/追加は `~/.config/hypr/bindings.lua` で行います。

## ユニバーサルクリップボード

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A` に対応するアプリですべて選択    |
| `Super + C`           | コピー    |
| `Super + X`           | 切り取り（ターミナルでは不可）    |
| `Super + V`           | 貼り付け    |
| `Super + Ctrl + V`           | クリップボードマネージャー    |

通常Linuxでは、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外では `Ctrl + C/V` を使います。Omarchyのこれらの統合クリップボードホットキーは、どこでも機能します。

## キャプチャ

| ホットキー              | 機能                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | スクリーンショット                      |
| `Super + Ctrl + Alt + C`            | スクリーンショット（同じ撮影。Print Screenキーのないキーボード用） |
| `Super + Ctrl + C` | キャプチャメニュー |
| `Alt + Print Screen`            | 画面録画                     |
| `Super + Print Screen` | カラーピッカー |
| `Super + Ctrl + Print Screen` | テキストを抽出してクリップボードへ |
| `Super + Alt + [` | 録画中にウェブカメラのオーバーレイを小さくする |
| `Super + Alt + ]` | 録画中にウェブカメラのオーバーレイを大きくする |
| `Alt + Shift + L` | ウェブアプリまたはChromiumから現在のURLをコピー |
| `Alt + Shift + D` | 現在のページの動画を `~/Videos` へダウンロード |
| `Super + Ctrl + X` | 音声入力を開始/停止（_セットアップ > デフォルト > Dictation_ が必要） |
| `Right Alt` / `F9` | プッシュトゥトーク音声入力（VoxtypeまたはSuperwhisperが必要） |

画面録画では、このホットキーを押すとまずどの音声を使うか尋ねられ、その後録画が始まります。もう一度押すと停止します。詳細は[スクリーンショットと録画](12-screenshots-recording.md)を参照してください。

すべてのキャプチャオプションは、Omarchyメニュー（`Super + Space`）の _トリガー > キャプチャ_ からも利用できます。

## 通知

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + ,` | 最新の通知に対応：開く、唯一のボタンを押す、選択肢から選ぶ、選択肢がない場合は閉じる  |
| `Super + Shift + ,` | すべての通知を閉じる |
| `Super + Ctrl + ,` | キーボードで通知を操作  |
| `Super + Alt + ,` | 最新の通知を閉じる  |
| `Super + Shift + Alt + ,` | 通知履歴を開く  |
| `Super + Ctrl + Alt + ,` | 通知のサイレンスを切り替え  |

## スタイル

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 新しいテーマを選択（`Super + Ctrl + Shift + Space` でも可） |
| `Super + Ctrl + W` | テーマの背景を選択（`Super + Ctrl + Space` でも可） |
| `Super + Backspace` | ウィンドウの透明度を切り替え |
| `Super + Ctrl + Backspace` | 単一ウィンドウの正方形アスペクトを切り替え |

追加の背景画像は `~/.config/omarchy/backgrounds/<theme name>` にあります。Omarchyメニューの _インストール > スタイル > 背景_ からも利用できます。

すべてのスタイルオプションは、Omarchyメニュー（`Super + Space`）の _スタイル_ からも利用できます。

## 切り替え

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | アイドル時のロックを切り替え |
| `Super + Ctrl + Delete` | ノートパソコンのディスプレイのオン/オフを切り替え |
| `Super + Ctrl + Alt + Delete` | ノートパソコンのディスプレイのミラーリングを切り替え |
| `Super + Shift + Space` | トップバーを切り替え  |
| `Shift + Mute` | 次のオーディオ出力へ切り替え |
| `Shift + Play` | 次のメディアソースへ切り替え |
| `Super + Shift + Backspace` | ウィンドウのギャップを切り替え |
| `Super + Ctrl + Alt + F` | フルスクリーンデスクトップを切り替え（トップバー + ウィンドウのギャップ） |

## リマインダー

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | リマインダーを設定  |
| `Super + Ctrl + Alt + R` | すべてのリマインダーを表示  |
| `Super + Ctrl + Shift + R` | すべてのリマインダーを消去  |

## お知らせ

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 時刻を通知として表示  |
| `Super + Ctrl + Alt + B` | バッテリーを通知として表示  |
| `Super + Ctrl + Alt + W` | 天気通知を切り替え  |

## Tmux

プレフィックスキーは `Ctrl + Space` です（`Ctrl + B` も使えます）。これらのバインディングは `~/.config/tmux/tmux.conf` で変更できます。

### ペイン

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + v` | 横にペインを分割（垂直） |
| `Prefix + h` | 下にペインを分割（水平） |
| `Prefix + x` | ペインを終了 |
| `Prefix + z` | ペインのズームを切り替え（全画面） |
| `Alt + Enter` | 下にペインを分割（プレフィックスなし） |
| `Alt + Shift + Enter` | 横にペインを分割（プレフィックスなし） |
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
| `Alt + Shift + Arrow Left/Right` | ウィンドウを左/右へ移動 |

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

### コピーモード（viスタイル）

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + [` | コピーモードに入る |
| `v` | 選択を開始（コピーモード中） |
| `y` | 選択範囲をコピー（コピーモード中） |

### 一般

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Prefix + q` | 設定を再読み込み |
| `Prefix + ?` | Tmuxキーバインディングを表示 |
| `Prefix + :` | コマンドプロンプト |

### Tmuxレイアウト関数

これらの関数はTmuxセッション内で実行する必要があります。

| コマンド | 機能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | エディター、AI、ターミナルを備えた開発レイアウトを作成 |
| `tdlm <ai> [<second_ai>]` | サブディレクトリごとに開発レイアウトを作成 |
| `tsl <count> <command>` | マルチペインのswarmレイアウトを作成 |

## Ghosttyターミナル

Ghosttyターミナルは、Omarchyメニューの _インストール > ターミナル_ を使ってインストールします。

| ホットキー                  | 機能              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 下に新しいスプリット |
| `Ctrl + Shift + O` | 横に新しいスプリット |
| `Ctrl + Alt + Arrows` | スプリット間を移動 |
| `Super + Ctrl + Shift + Arrows` | スプリットを10行分リサイズ |
| `Super + Ctrl + Shift + Alt + Arrows` | スプリットを100行分リサイズ |
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

## Neovim（LazyVim使用時）

### ナビゲーション

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `Space`                    | コマンドの選択肢を表示            |
| `Space Space`              | あいまい検索でファイルを開く      |
| `Space E`                  | サイドバーを切り替え                  |
| `Space G G`                | gitコントロールを表示               |
| `Space S G`                | ファイル内容を検索             |
| `Ctrl + W W`               | サイドバーとエディター間を移動 |
| `Ctrl + Left/right arrow`  | サイドバーのサイズを変更          |
| `Shift + H`                      | 左のファイルタブへ移動             |
| `Shift + L`                      | 右のファイルタブへ移動            |
| `Space B D`                | ファイルタブを閉じる                  |

### サイドバー使用時

| ホットキー                   | 機能                        |
| ------------------------ | ------------------------------- |
| `A`                        | 親ディレクトリに新しいファイルを追加      |
| `Shift + A`                | 親ディレクトリに新しいサブディレクトリを追加    |
| `D`                        | ハイライトされたファイル/ディレクトリを削除     |
| `M`                        | ハイライトされたファイル/ディレクトリを移動       |
| `R`                        | ハイライトされたファイル/ディレクトリの名前を変更     |
| `?`                        | すべてのコマンドのヘルプを表示      |

[LazyVimが設定するすべてのNeovimホットキーを参照](https://www.lazyvim.org/keymaps)。

## クイック絵文字

`Super + Ctrl + E` を使うと、選択内容をクリップボードに入れる完全な絵文字ピッカーを表示できます。あるいは、これらのクイックアクセスオプションも使えます。

| ホットキー       | EM | ヒント       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 微笑み      |
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
| `Shift + CapsLock M E` | 🙄 | 呆れ    |
| `Shift + CapsLock M I` | 😉 | ウインク       |
| `Shift + CapsLock M P` | 🙏 | 祈り |
| `Shift + CapsLock M D` | 🤤 | よだれ      |
| `Shift + CapsLock M M` | 💰 | お金      |
| `Shift + CapsLock M X` | 🎉 | お祝い |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | 乾杯      |
| `Shift + CapsLock M O` |👌 | OK |
| `Shift + CapsLock M G` |👋 | 挨拶 |
| `Shift + CapsLock M A` |💪 | 腕 |
| `Shift + CapsLock M B` |🤯 | 衝撃 |

## クイック補完

| ホットキー       | 補完       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | あなたの名前（セットアップ時に入力したもの）  |
| `Shift + CapsLock Space E` | あなたのメール（セットアップ時に入力したもの）  |

自分のものをさらに追加するには、`~/.XCompose` を編集し、ターミナルで `omarchy-restart-xcompose` を実行して変更を反映させます。
