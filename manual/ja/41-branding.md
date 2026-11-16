# ブランディング

Omarchy では、ブート時のロック解除、スクリーンセーバー、About 画面のそれぞれに、会社のロゴや個人の画像を設定できます。

### ブート時のロック解除

`omarchy plymouth preview` を使うと、カスタムロゴと配色がどのように見えるかを確認できます。背景色、テキストの色、ロゴの png、そしてプレビュー画像のパスを指定します。

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

次に `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` で設定を適用します。これにより、SDDM ログイン画面にも同じ配色とロゴが使われます。元に戻したい場合は `omarchy plymouth reset` を使えます。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### スクリーンセーバー

スクリーンセーバーに使われるロゴは、_外観 > ブランディング > スクリーンセーバー_ で変更できます。これは ASCII ロゴなので、テキストを直接編集できますが、png や svg 画像を渡すこともでき、その場合は ASCII に変換します。なかなかクールです。

 ![branding-screensaver](images/branding-screensaver.webp)

このメニューには 3 つの項目があります。

- **テキストを編集** は `~/.config/omarchy/branding/screensaver.txt` をエディターで開きます。好きなものを入力または貼り付けてください — ASCII アート、自分の名前、下品な言葉でも構いません。保存して終了すると、すぐにスクリーンセーバーが起動するので、確認できます。
- **画像から設定** は png や svg 用のファイルピッカーを開き、ASCII に変換して結果を表示します。輪郭がはっきりしたロゴは、写真よりもはるかにうまくいきます。
- **デフォルトに戻す** は Omarchy のロゴに戻します。

### About 画面

同じ 3 つのオプションは、Omarchy メニューから開く _About_ 画面用に _外観 > ブランディング > About_ にもあり、まったく同じように動作します。ファイルは `~/.config/omarchy/branding/about.txt` で、変更のたびに About ウィンドウがポップアップ表示されます。About 用のアートは、ディスプレイ全体を埋めるのではなくウィンドウ内に収める必要があるため、スクリーンセーバー用よりも小さいサイズに変換されます。

ウィンドウが開いている間、数秒ごとに緑色のきらめきがアートを斜めに横切り、その後また静止します。あなた自身のアートにも同じ効果が付きます。ただし、その中のすべての文字が 1 列幅である場合に限ります — _画像から設定_ で生成されるものはすべてそうです。絵文字や全角文字で作られたアートは静止したままになります。自分用の fastfetch 設定を保持している場合も、画面は静止します。これらの場合にロゴが静止しているのは、アニメーションが失敗しているのではなく、邪魔をしないように控えているためです。それらに対してきらめきを滑らせると、行の残りの部分がずれた位置に表示されてしまうからです。

 ![branding-about](images/branding-about.webp)

### 自分で画像を変換する

2 つの _画像から設定_ オプションは、どちらも単に `omarchy transcode ascii` を呼び出しているだけなので、変換を自分で制御したい場合は直接実行できます。

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

`--width` と `--height` はターミナルの列数と行数で指定し、`--mode` は `braille`（デフォルトで、はるかに細かい）か `block` のいずれか、`--threshold` はどのピクセルをロゴの一部とみなすかを決めるパーセンテージ、そして `--invert` はロゴが暗い背景の上に明るい色で描かれている場合に使います。変換結果が塊のようになってしまったら、たいていは threshold を調整すれば直ります。

### ロゴの代わりに言葉を使う

`omarchy ascii` は、Omarchy のワードマーク自体が描かれている FIGlet フォントである Delta Corps Priest 1 でテキストを描くので、スクリーンセーバーに絵ではなく言葉を表示させることもできます。

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

テキストは引数として受け取り、引数がなければパイプから読み取ります。このフォントに含まれるのは文字とスペースだけです — 数字や句読点なしで描かれています — そのため、それ以外のものは静かに飲み込まれるのではなく、削除され、stderr にその旨が出力されます。
