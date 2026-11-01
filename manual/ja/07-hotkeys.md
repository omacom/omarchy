# ホットキー

主なキーボードバインディングはすべて `Super + K` で確認できる（Tmux バインディングは `Super + Alt + K`、Herdr バインディングは `Super + Ctrl + K`）。

## ナビゲーション

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy メニュー（アプリその他すべて） |
| `Super + Alt + Space` | アプリグリッド |
| `Super + Escape` | システムメニュー（サスペンド、再起動など） |
| `Super + Ctrl + L` | コンピュータをロック |
| `Super + W` または `Super + Q` | ウィンドウを閉じる |
| `Ctrl + Alt + Del` | すべてのウィンドウを閉じる |
| `Super + T` | ウィンドウのタイル／フローティングを切り替え |
| `Super + J` | ウィンドウの配置を切り替え（横／縦） |
| `Super + O` | ウィンドウを sticky'n'floating にポップさせる切り替え |
| `Super + L` | dwindle、scrolling、floating レイアウトを順に切り替え |
| `Super + Alt + L` | レイアウトを逆順に切り替え |
| `Super + P` | 疑似ウィンドウスタイルを切り替え（natural v stretch） |
| `Super + F` | フルスクリーンにする |
| `Super + Alt + F` | フル幅にする |
| `Super + Ctrl + F` | ウィンドウ内でフルスクリーンにする |
| `Super + 1/2/3/4` | フォーカス中のモニターの指定ワークスペースへ移動 |
| `Super + Tab` | フォーカス中のモニターの次のワークスペースへ移動 |
| `Super + Shift + Tab` | フォーカス中のモニターの前のワークスペースへ移動 |
| `Super + Ctrl + Tab` | フォーカス中のモニターの以前いたワークスペースへ移動 |
| `Super + Shift + 1/2/3/4` | ウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + Shift + Alt + 1/2/3/4` | 追随せずにウィンドウをフォーカス中のモニターのワークスペースへ移動 |
| `Super + S` | フルスクラッチパッドを切り替え |
| `Super + Alt + S` | ウィンドウをフルスクラッチパッドへ移動 |
| `Super + Grave` | Quake コンソールを切り替え |
| `Super + Shift + Grave` | ウィンドウを Quake コンソールへ移動 |
| `Super + Shift + Ctrl + Arrows` | ウィンドウをその方向のモニターへ移動 |
| `Super + Shift + Alt + Arrows` | ワークスペースをその方向のモニターへ移動 |
| `Super + Arrow` | 矢印方向のウィンドウへフォーカスを移動し、画面端ではその側のモニターへ越える |
| `Super + Shift + Arrow` | 矢印方向の別のウィンドウと入れ替える。その側のモニターにあるウィンドウも含む |
| `Super + Minus` | ウィンドウを左へ拡大 |
| `Super + Equal` | ウィンドウを左へ縮小 |
| `Super + Shift + Minus` | ウィンドウを上へ縮小 |
| `Super + Shift + Equal` | ウィンドウを下へ拡大 |
| `Super + Alt + Minus/Equal` | 同じリサイズを小さいステップで |
| `Super + Ctrl + Minus/Equal` | 同じリサイズを大きいステップで |
| `Super + Alt + Home` | ウィンドウ幅を保存 |
| `Super + Home` | 保存したウィンドウ幅を復元 |
| `Super + Left Mouse` | ウィンドウをドラッグして移動 |
| `Super + Right Mouse` | ウィンドウをリサイズ |
| `Super + Scroll Wheel` | フォーカス中のモニターのワークスペースをスクロール |
| `Super + G` | ウィンドウのグループ化を切り替え |
| `Super + Alt + G` | ウィンドウをグループから出す |
| `Super + Alt + Tab` | グループ内のウィンドウを順に切り替え |
| `Super + Alt + Shift + Tab` | グループ内のウィンドウを逆順に切り替え |
| `Super + Alt + Scroll Wheel` | グループ内のウィンドウを順に切り替え |
| `Super + Alt + 1/2/3/4/5` | グループ内の指定ウィンドウへ移動 |
| `Super + Alt + Arrow` | 矢印方向へウィンドウをグループに入れる。その側のモニターにあるウィンドウも含む |
| `Super + Ctrl + Left/Right` | タイルグループ内のウィンドウ間を移動 |
| `Super + Ctrl + Z` | 画面をズームイン（繰り返すとさらにズーム） |
| `Super + Ctrl + Alt + Z` | 画面を完全にズームアウト |
| `Super + /` | モニターのスケーリング選択肢を順に進む |
| `Super + Alt + /` | モニターのスケーリング選択肢を逆順に戻る |
| `Alt + Tab` | アクティブなワークスペースのウィンドウを順に切り替え |
| `Alt + Shift + Tab` | アクティブなワークスペースのウィンドウを逆順に切り替え |
| `Ctrl + Alt + Tab` | モニター間でフォーカスを順に切り替え |
| `Ctrl + Alt + Shift + Tab` | モニター間でフォーカスを逆順に切り替え |

リサイズのショートカットは、キーボードに印字された文字に関係なく、物理キー `code:20` と `code:21`（XKB の `<AE11>` と `<AE12>`）を使う。US キーボードではこれらのキーは `-` と `=` で、日本の（JIS）キーボードでは `-` と `^` で、スペイン語キーボードでは `'` と `¡` だ。JIS では、`Super + ^` が `Super + Equal` で、`Super + Shift + -`（`=` を入力する）は `Super + Shift + Minus` だ。

## システムコントロール

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | オーディオパネル |
| `Super + Ctrl + B` | Bluetooth パネル |
| `Super + Ctrl + N` | Wi-Fi/ネットワークパネル |
| `Super + Ctrl + D` | ディスプレイパネル |
| `Super + Ctrl + P` | 電源パネル |
| `Super + Ctrl + Alt + D` | カレンダーパネル |
| `Super + Ctrl + Alt + E` | 世界時計パネル |
| `Super + Ctrl + 1-9` | 位置でバーパネルを切り替え |
| `Super + Ctrl + S` | 共有メニュー（LocalSend 経由） |
| `Super + Ctrl + C` | キャプチャコントロール（スクリーンショット/録画/ピッカー） |
| `Super + Ctrl + O` | メニューを切り替え |
| `Super + Ctrl + H` | ハードウェアメニュー |
| `Super + Ctrl + E` | 絵文字ピッカー |
| `Super + Ctrl + .` | メディアをトランスコード |
| `Super + Shift + Ctrl + A` | AI エージェントを選ぶ |

## 調整

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 画面の明るさを最大に |
| `Shift + Brightness Down` | 画面の明るさを最小に |
| `Alt + Brightness Up/Down` | 正確な 1% の明るさ変更 |
| `Alt + Volume Up/Down` | 正確な 1% の音量変更 |
| `Keyboard Brightness Up/Down` | キーボードバックライトを明るく／暗く |
| `Keyboard Backlight` | キーボードバックライトのレベルを順に切り替え |
| `Alt + Play` | 次のトラック |
| `Alt + Shift + Play` | 前のトラック |

## アプリの起動

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Return` | ターミナル |
| `Super + Alt + Return` | Tmux ターミナル |
| `Super + Ctrl + Return` | Herdr（エージェントマネージャー） |
| `Super + Shift + Return` | ブラウザ |
| `Super + Shift + Alt + B` | ブラウザ（プライベート／シークレット） |
| `Super + Shift + F` | ファイルマネージャー |
| `Super + Shift + Alt + F` | ターミナルの cwd でファイルマネージャー |
| `Super + Shift + M` | 音楽（Spotify） |
| `Super + Shift + Alt + M` | 音楽（cliamp） |
| `Super + Shift + /` | パスワードマネージャー（1password） |
| `Super + Shift + Q` | 電卓（Omacalc） |
| `Super + Shift + T` | アクティビティ（btop） |
| `Super + Shift + N` | エディタ（Neovim） |
| `Super + Shift + C` | カレンダー（[HEY](https://hey.com/)） |
| `Super + Shift + E` | メール（[HEY](https://hey.com/)） |
| `Super + Shift + Alt + E` | 新規メール（[HEY](https://hey.com/)） |
| `Super + Shift + A` | AI（ChatGPT） |
| `Super + Shift + Alt + A` | AI（Grok） |
| `Super + Shift + G` | メッセンジャー（Signal） |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | メッセンジャー（WhatsApp） |
| `Super + Shift + Ctrl + G` | メッセンジャー（Google） |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | 執筆（Omawrite） |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X Compose |
| `Super + Shift + Y` | YouTube |

バインディングの変更／追加は `~/.config/hypr/bindings.lua` で行う。

## ユニバーサルクリップボード

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + A` | `Ctrl + A` に対応するアプリですべて選択 |
| `Super + C` | コピー |
| `Super + X` | 切り取り（ターミナルでは不可） |
| `Super + V` | 貼り付け |
| `Super + Ctrl + V` | クリップボードマネージャー |

Linux では通常、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外では `Ctrl + C/V` を使う。これらの Omarchy 統一クリップボードホットキーはどこでも使える。

## キャプチャ

| ホットキー | 機能 |
| ------------------- | ------------------------------ |
| `Print Screen` | スクリーンショット |
| `Super + Ctrl + Alt + C` | スクリーンショット（同じもの。Print Screen キーがないキーボード用） |
| `Super + Ctrl + C` | キャプチャメニュー |
| `Alt + Print Screen` | 画面録画 |
| `Super + Print Screen` | カラーピッカー |
| `Super + Ctrl + Print Screen` | テキストを抽出してクリップボードへ |
| `Super + Alt + [` | 録画中にウェブカメラオーバーレイを小さくする |
| `Super + Alt + ]` | 録画中にウェブカメラオーバーレイを大きくする |
| `Alt + Shift + L` | webapp または Chromium から現在の URL をコピー |
| `Alt + Shift + D` | 現在のページの動画を `~/Videos` にダウンロード |
| `Alt + Space` | ディクテーションを開始／停止（_Setup > Defaults > Dictation_ が必要） |
| `Right Alt` | 押している間ディクテーション（_Setup > Defaults > Dictation_ が必要） |

画面録画では、ホットキーを押すとまずどの音声を使うか聞かれ、それから録画が開始する。もう一度押すと停止する。詳細は [スクリーンショットと録画](12-screenshots-recording.md) を参照。

すべてのキャプチャオプションは、Omarchy メニュー（`Super + Space`）の _Trigger > Capture_ からもアクセスできる。

## 通知

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + ,` | 最新の通知に対応する：開く、唯一のボタンを押す、選択肢から選ぶ、選択肢がない場合は閉じる |
| `Super + Shift + ,` | すべての通知を閉じる |
| `Super + Ctrl + ,` | キーボードで通知を操作する |
| `Super + Alt + ,` | 最新の通知を閉じる |
| `Super + Shift + Alt + ,` | 通知履歴を開く |
| `Super + Ctrl + Alt + ,` | 通知のサイレンスを切り替え |

## スタイル

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 新しいテーマを選ぶ（`Super + Ctrl + Shift + Space` でも可） |
| `Super + Ctrl + W` | テーマの背景を選ぶ（`Super + Ctrl + Space` でも可） |
| `Super + Backspace` | ウィンドウの透明度を切り替え |
| `Super + Ctrl + Backspace` | 単一ウィンドウの正方形アスペクトを切り替え |

追加の背景画像は `~/.config/omarchy/backgrounds/<theme name>` にある。Omarchy メニューの _Install > Style > Background_ からも利用できる。

すべてのスタイルオプションは、Omarchy メニュー（`Super + Space`）の _Style_ からもアクセスできる。

## 切り替え

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | アイドル時のロックを切り替え |
| `Super + Ctrl + Delete` | ラップトップディスプレイのオン／オフを切り替え |
| `Super + Ctrl + Alt + Delete` | ラップトップディスプレイのミラーリングを切り替え |
| `Super + Shift + Space` | トップバーを切り替え |
| `Shift + Mute` | 次の音声出力へ切り替え |
| `Shift + Play` | 次のメディアソースへ切り替え |
| `Super + Shift + Backspace` | ウィンドウギャップを切り替え |
| `Super + Ctrl + Alt + F` | フルスクリーンデスクトップを切り替え（トップバー + ウィンドウギャップ） |

## リマインダー

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | リマインダーを設定 |
| `Super + Ctrl + Alt + R` | すべてのリマインダーを表示 |
| `Super + Ctrl + Shift + R` | すべてのリマインダーをクリア |

## 通知表示

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 時刻を通知で表示 |
| `Super + Ctrl + Alt + B` | バッテリーを通知で表示 |
| `Super + Ctrl + Alt + W` | 天気の通知表示を切り替え |

## Tmux

プレフィックスキーは `Ctrl + Space`（`Ctrl + B` も使える）。これらのバインディングは `~/.config/tmux/tmux.conf` で変更できる。

### ペイン

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Prefix + v` | ペインを横に分割（縦分割） |
| `Prefix + h` | ペインを下に分割（横分割） |
| `Prefix + x` | ペインを終了 |
| `Prefix + z` | ペインズームを切り替え（フルスクリーン） |
| `Alt + Enter` | ペインを下に分割（プレフィックスなし） |
| `Alt + Shift + Enter` | ペインを横に分割（プレフィックスなし） |
| `Alt + Escape` | ペインを終了（プレフィックスなし） |
| `Ctrl + Alt + Arrows` | ペイン間を移動 |
| `Ctrl + Alt + Shift + Arrows` | ペインをリサイズ |

### ウィンドウ

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Prefix + c` | 新しいウィンドウ |
| `Prefix + k` | ウィンドウを終了 |
| `Prefix + r` | ウィンドウ名を変更 |
| `Alt + 1-9` | 指定のウィンドウへ移動 |
| `Alt + Arrow Left/Right` | ウィンドウ間を移動 |
| `Alt + Shift + Arrow Left/Right` | ウィンドウを左／右へ移動 |

### セッション

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Prefix + C` | 新しいセッション |
| `Prefix + K` | セッションを終了 |
| `Prefix + R` | セッション名を変更 |
| `Prefix + N` | 次のセッション |
| `Prefix + P` | 前のセッション |
| `Alt + Arrow Up/Down` | セッション間を移動 |
| `Prefix + s` | セッション一覧 |
| `Prefix + d` | セッションからデタッチ |

### コピーモード（vi スタイル）

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Prefix + [` | コピーモードに入る |
| `v` | 選択を開始（コピーモード中） |
| `y` | 選択をコピー（コピーモード中） |

### 全般

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Prefix + q` | 設定をリロード |
| `Prefix + ?` | Tmux キーバインディングを表示 |
| `Prefix + :` | コマンドプロンプト |

### Tmux レイアウト関数

これらの関数は Tmux セッション内で実行する必要がある。

| コマンド | 機能 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | エディタ、AI、ターミナルで開発レイアウトを作成 |
| `tdlm <ai> [<second_ai>]` | サブディレクトリごとに開発レイアウトを作成 |
| `tsl <count> <command>` | マルチペインの swarm レイアウトを作成 |

## Ghostty ターミナル

Ghostty ターミナルは、Omarchy メニューの _Install > Terminal_ を使ってインストールする。

| ホットキー | 機能 |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 下に新しい分割を作成 |
| `Ctrl + Shift + O` | 横に新しい分割を作成 |
| `Ctrl + Alt + Arrows` | 分割間を移動 |
| `Super + Ctrl + Shift + Arrows` | 分割を 10 行分リサイズ |
| `Super + Ctrl + Shift + Alt + Arrows` | 分割を 100 行分リサイズ |
| `Ctrl + Shift + T` | 新しいタブ |
| `Ctrl + Shift + Arrows` | タブ間を移動 |
| `Alt + Numbers` | 指定のタブへ移動 |
| `Shift + Pg Up/Down` | 履歴をスクロール |
| `Ctrl + Left mouse` | リンクをブラウザで開く |

## ファイルマネージャー

| ホットキー | 機能 |
| ------------------- | ------------------------------ |
| `Ctrl + L` | パスへ移動 |
| `Space` | ファイルをプレビュー（矢印で移動） |
| `Alt + Up` | 親フォルダへ上がる |

## Neovim (w/ lazyvim)

### ナビゲーション

| ホットキー | 機能 |
| ------------------------ | ------------------------------- |
| `Space` | コマンドオプションを表示 |
| `Space Space` | あいまい検索でファイルを開く |
| `Space E` | サイドバーを切り替え |
| `Space G G` | git コントロールを表示 |
| `Space S G` | ファイル内容を検索 |
| `Ctrl + W W` | サイドバーとエディタ間を移動 |
| `Ctrl + Left/right arrow` | サイドバーのサイズを変更 |
| `Shift + H` | 左のファイルタブへ移動 |
| `Shift + L` | 右のファイルタブへ移動 |
| `Space B D` | ファイルタブを閉じる |

### サイドバー使用中

| ホットキー | 機能 |
| ------------------------ | ------------------------------- |
| `A` | 親ディレクトリに新しいファイルを追加 |
| `Shift + A` | 親ディレクトリに新しいサブディレクトリを追加 |
| `D` | ハイライトされたファイル／ディレクトリを削除 |
| `M` | ハイライトされたファイル／ディレクトリを移動 |
| `R` | ハイライトされたファイル／ディレクトリの名前を変更 |
| `?` | すべてのコマンドのヘルプを表示 |

[LazyVim が設定する Neovim ホットキーをすべて見る](https://www.lazyvim.org/keymaps)。

## クイック絵文字

`Super + Ctrl + E` を使うと完全な絵文字ピッカーが表示され、選択したものがクリップボードに入る。またはこれらのクイックアクセスオプションも使える。

| ホットキー | EM | ヒント |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 笑顔 |
| `Shift + CapsLock M C` | 😂 | 泣く |
| `Shift + CapsLock M L` | 😍 | 愛 |
| `Shift + CapsLock M V` | ✌️ | 勝利 |
| `Shift + CapsLock M H` | ❤️ | ハート |
| `Shift + CapsLock M Y` | 👍 | はい |
| `Shift + CapsLock M N` | 👎 | いいえ |
| `Shift + CapsLock M F` | 🖕 | ファック |
| `Shift + CapsLock M W` | 🤞 | 願い |
| `Shift + CapsLock M R` | 🤘 | ロック |
| `Shift + CapsLock M K` | 😘 | キス |
| `Shift + CapsLock M E` | 🙄 | 白目 |
| `Shift + CapsLock M I` | 😉 | ウインク |
| `Shift + CapsLock M P` | 🙏 | 祈り |
| `Shift + CapsLock M D` | 🤤 | よだれ |
| `Shift + CapsLock M M` | 💰 | お金 |
| `Shift + CapsLock M X` | 🎉 | お祝い |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | 乾杯 |
| `Shift + CapsLock M O` | 👌 | OK |
| `Shift + CapsLock M G` | 👋 | あいさつ |
| `Shift + CapsLock M A` | 💪 | 腕 |
| `Shift + CapsLock M B` | 🤯 | ぶっ飛び |

## クイック補完

| ホットキー | 補完 |
| ------------ | ---------- |
| `Shift + CapsLock Space Space` | — (mdash) |
| `Shift + CapsLock Space N` | あなたの名前（セットアップ時に入力したもの） |
| `Shift + CapsLock Space E` | あなたのメールアドレス（セットアップ時に入力したもの） |

自分用にもっと追加するには `~/.XCompose` を編集し、ターミナルで `omarchy-restart-xcompose` を実行して変更を反映させる。
