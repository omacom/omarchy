# ブラウザ

Omarchy にはデフォルトのブラウザとして [Google Chrome](https://www.google.com/chrome/) が同梱されている。システムの他の部分に合わせてテーマが適用されており、`Super + Shift + Return`（または `Super + Shift + B`）で開くのがこれで、`Super + Shift + Alt + B` でプライベートウィンドウが開き、すべての[ウェブアプリ](25-web-apps.md)もこの中で動作する。起動するとすぐにブラウザウィンドウが開く。ようこそ画面もサインインの促しもなく、使用統計やクラッシュレポートが Google に送信されることもなく、広告プライバシーに関するプロンプトもオフになっている。同期したくなったら、いつでもプロフィールボタンから Google アカウントにサインインできる。

Chrome が好みでなくても、それに縛られることはない。Omarchy メニューの _Install > Browser_ には、[Chromium](https://www.chromium.org/)（Chrome の元になったプレーンなオープンソースビルド）、Edge、Brave、Brave Origin、Firefox、[Zen](https://zen-browser.app/)、[Ladybird](https://ladybird.org/) がある（Edge は x86 マシンのみ）。1つ選べば、Omarchy がインストールし、ポリシー用ディレクトリをセットアップし、現在のテーマを適用する。

## デフォルトに設定する

ブラウザをインストールしても、デフォルトにはならない。切り替えるには、_Setup > Defaults > Browser_ に移動して1つ選ぶ。現在のデフォルトにはチェックが付いており、まだ持っていないブラウザを選ぶと、先にインストールされる。

ターミナルからはこうだ：

```bash
omarchy default browser firefox
```

引数なしで実行すると、現在のデフォルトを教えてくれる。これにより XDG ハンドラーが設定されるので、従うのは Omarchy のホットキーだけではない。チャットアプリからターミナルコマンドまで、リンクを開くあらゆるものが、選んだブラウザへ向かうようになる。

## Copy URL と Download Video

Chromium 系ブラウザ（Chromium 自体、Chrome、Edge、Brave、Brave Origin）には、Omarchy の拡張機能が3つ付属している。2つはブラウザの外へ出てシステムの残りの部分に働きかけ、1つは WhatsApp を整えるものだ。

**Copy URL** は `Alt + Shift + L` で現在のタブのアドレスをクリップボードに入れる。アドレスバーをクリックしてコピーするより速く、ブラウザではなくシステムのクリップボードを経由するので、Omarchy の通知で確認でき、URL はすぐに[クリップボード履歴](08-unified-clipboard-history.md)や他のすべてのアプリで使えるようになる。クリックする方が好みなら、ツールバーボタンもある。

**Download Video** は `Alt + Shift + D` で、見ているページで再生中の動画を取得する。URL を [yt-dlp](https://github.com/yt-dlp/yt-dlp) に渡すので、YouTube よりはるかに多くのサイトで動作し、ダウンロードは `~/Videos` に保存される。進捗は音量や明るさで使うのと同じオンスクリーンディスプレイに表示され、通知を積み重ねるのではなく、その場で更新される。ファイルを別の場所に保存したい場合は `OMARCHY_YTDLP_DIR` を設定すること。環境変数をどこに書くかは [FAQ](46-faq.md) を参照。

どちらの拡張機能も、小さなネイティブメッセージングホストを通して Omarchy と通信し、これはブラウザと一緒にインストールされる。これがあるから、ウェブページの動画がホームディレクトリにたどり着き、URL がクリップボードマネージャーに入る。通常の拡張機能だけではできないことだ。

**WhatsApp Slim** は WhatsApp Web をシステムテーマに従わせ、ウィンドウが狭いときにチャットリストを折りたたむ。

これらは Chromium 系のみだ。Firefox と Zen には付かない。

## Firefox と Zen

Firefox と Zen は別の系統なので、扱いも異なる。Omarchy は妥当なデフォルトのためのポリシーファイルをインストールし、ネイティブ Wayland モードに切り替える。分数スケーリングやスムーズなトラックパッドスクロールのためには、このモードが望ましい。

上記の Chromium 拡張機能は付かず、Omarchy によるテーマ適用もないので、その部分の体験は自分でセットアップすることになる。

## Ladybird

Ladybird はゼロから書かれたブラウザで、Chromium や Firefox ではなく独自のエンジンを持つ。まだアルファ版なので、まだ動作しないサイトがあると思っておくこと。Omarchy はそのままインストールする。拡張機能なし、テーマなし、ポリシーなしだ。プライベートウィンドウもないので、`Super + Shift + Alt + B` では、閉じると削除される一時プロファイルで開く。[ウェブアプリ](25-web-apps.md) は引き続き Chrome または Chromium で動作する。

## 削除する

Chrome を含め、これらのブラウザはどれも _Remove > Browser_ から削除できる。その場合、リンクは、もう一方がまだインストールされていれば Chrome または Chromium へ向かうようになる。
