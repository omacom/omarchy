# ブランディング

Omarchy では、ブート時のロック解除画面、スクリーンセーバー、About 画面のそれぞれに、会社のロゴや個人の画像を設定できる。

### ブート時のロック解除

`omarchy plymouth preview` を使えば、カスタムロゴと色がどのように見えるかを確認できる。背景色、文字色、ロゴの png、プレビュー画像のパスを指定する：

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

その後、`omarchy plymouth set '#1d2021' '#ebdbb2' logo.png` で設定を適用する。これにより、SDDM ログイン画面にも同じ色とロゴが反映される。元に戻したい場合は `omarchy plymouth reset` を使える。

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### スクリーンセーバー

スクリーンセーバーに使うロゴは _Appearance > Branding > Screensaver_ で変更できる。これは ASCII ロゴなので、テキストを直接編集できるが、png や svg 画像を渡せば、ASCII に変換もできる。かなりかっこいい。

 ![branding-screensaver](images/branding-screensaver.webp)

このメニューには 3 つの項目がある：

- **Edit Text** は `~/.config/omarchy/branding/screensaver.txt` をエディタで開く。好きなものを入力したり貼り付けたりすればいい — ASCII アート、自分の名前、下品な言葉でも。保存して終了すると、すぐにスクリーンセーバーが起動して確認できる。
- **Set From Image** は png または svg 用のファイルピッカーを開き、ASCII に変換して結果を表示する。はっきりしたシルエットのロゴの方が、写真よりずっとうまくいく。
- **Restore Default** は Omarchy のロゴに戻す。

### About 画面

同じ 3 つのオプションは、Omarchy メニューから開く _About_ 画面用に _Appearance > Branding > About_ にもあり、動作はまったく同じだ — ファイルは `~/.config/omarchy/branding/about.txt` で、変更のたびに About ウィンドウが表示される。About のアートは、ディスプレイ全体を埋めるのではなくウィンドウ内に収めなければならないため、スクリーンセーバー用より小さいサイズに変換される。

ウィンドウが開いている間、数秒ごとに明るい白い光の帯がアートを斜めに横切って傾き、また静止した状態に戻る。自分のアートにもこの効果が付く。ただし、アート内のすべての文字が 1 列幅である場合に限る — _Set From Image_ で生成されるものはすべてそうなっている。絵文字や全角文字で作られたアートは代わりに静止したままになるし、自分用の fastfetch 設定を使っている場合も画面は静止する。これらの場合にロゴが静止しているのは、アニメーションが失敗しているのではなく、邪魔をしないように控えているためだ。きらめきを横切らせると、行の残りの部分が間違った位置に来てしまうからだ。

 ![branding-about](images/branding-about.webp)

### 自分で画像を変換する

_Set From Image_ の 2 つのオプションはどちらも、単に `omarchy transcode ascii` を呼び出しているだけなので、変換を自分でコントロールしたい場合は直接実行できる：

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

ターミナルの列数と行数で指定する `--width` と `--height`、 `braille`（デフォルトで、はるかに細かい）または `block` のどちらかを指定する `--mode`、どのピクセルをロゴの一部とみなすかを決めるパーセンテージの `--threshold`、そしてロゴが暗い背景に明るい色で描かれている場合のための `--invert` を受け付ける。変換結果が塊のようになってしまったら、たいていは threshold を調整すればいい。

### ロゴの代わりに言葉を使う

`omarchy ascii` は、Omarchy のワードマーク自体が描かれている FIGlet フォント Delta Corps Priest 1 でテキストを描くので、スクリーンセーバーに絵ではなく何か言葉を表示させることができる：

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

テキストを引数として受け取るか、引数がなければパイプから読み取る。このフォントは文字とスペースだけを収録している — 数字や句読点なしで描かれた — ので、それ以外のものは黙って飲み込まれるのではなく、削除されて stderr に名前が出力される。
