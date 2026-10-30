# シェルツール

標準の Linux ツールに加え、Omarchy には強化されたシェルツールも多数同梱されています。主なものを紹介します。

## fzf

[fzf](https://junegunn.github.io/fzf/) は `ff` エイリアスでファイルのあいまい検索を提供します。任意のディレクトリへ移動して `ff` と入力すれば、そのツリー内の任意のファイルまであいまい検索でたどり着け、右側には絞り込んでいるファイルのプレビューが表示されます。

`Ctrl + R` を使えば、fzf でコマンド履歴をあいまい検索できます。

このツールは Neovim で `Space Space` と入力したときにも使われます。

完全なマニュアルは `man fzf` で確認できます。

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide) は cd の置き換えです。過去にいたディレクトリを記憶しているので、次回はより簡単にジャンプできます。たとえば一度 `cd ~/.config/omarchy` を実行したとします。次回は `cd omarchy`（あるいは `cd oma` だけでも）とすれば、Zoxide が直接そこへ連れて行ってくれます。

完全なマニュアルは `man zoxide` で確認できます。

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep) は `rg <pattern> <path>` を使ってファイルの内容を検索します。たとえば `rg Controller app/` とすれば、ディレクトリ app 内の `Controller` の言及をすべて見つけられます。

このツールは Neovim で `Space S G` と入力したときにも使われます。

完全なマニュアルは `man rg` で確認できます。

## eza

[eza](https://eza.rocks/) は ls の置き換えです。より多くの情報、色、アイコン付きのディレクトリ一覧を表示します。デフォルトでは eza は ls としてエイリアスされています。`lt` を使えば2階層のネスト一覧が得られます。`lsa` は隠しファイルを含む一覧を表示します。そして `lta` は隠しファイルを含むネスト一覧です。

完全なマニュアルは `man eza` で確認できます。

## fd

[fd](https://github.com/sharkdp/fd) は使いやすい `find` の置き換えです。`fd person.rb` で現在のツリー内にある `person.rb` というファイルを見つけます。`fd person.rb /` はファイルシステム全体を検索します。`fd person.rb / -H` は隠しディレクトリを含めてファイルシステム全体を検索します。

完全なマニュアルは `man fd` で確認できます。

## bat

[bat](https://github.com/sharkdp/bat) はシンタックスハイライト、行番号、ページャ機能付きの `cat` です。`bat somefile.rb` を実行すれば、なぜ戻れなくなるか分かるでしょう。それは他の場所でも静かに働いています。man ページに色を付けているのも、`ff` のプレビューを描画しているのも bat です。

完全なマニュアルは `man bat` で確認できます。

## tldr

[tldr](https://tldr.sh/) は、例を1つ示す前に3画面分も歴史から始まる man ページへの解毒剤です。`tldr tar` とすれば、本当に欲しかった数少ない呼び出し例が得られます。

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp) は YouTube や他の何百ものサイトから動画をダウンロードします。`yt-dlp <url>` は利用可能な最高画質を現在のディレクトリに取得します。

完全なマニュアルは `man yt-dlp` で確認できます。

## try

[try](https://github.com/tobi/try) は、日付スタンプ付きディレクトリでプログラミング実験を簡単に管理できるようにします。すべての実験は `~/Work/tries` に存在し、`try` でアクセスできます。

Omarchy はプロジェクトの `bin/` ディレクトリを自動で `PATH` に追加しません。信頼できるプロジェクトローカルのツールは、`bin/rails` や `./bin/dev` のような明示的な相対パスで実行してください。
