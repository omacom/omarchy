# Neovim

[Neovim](https://neovim.io/) は、Bill Joy がはるか昔の1976年に生み出した [viエディター](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) のモダンな実装だ。挿入モードとコマンドモードが分かれたモーダルエディターで、信じられないほど奥深いキーコマンド群のほんの一部を覚えただけでも、ちょっとしたスーパーパワーになる。でも学習曲線もかなり急だ！

vim流の編集が完全に初めてなら、YouTubeの [ThePrimeagenのVim As Your Editorシリーズ](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) をチェックすることをおすすめする。基本を教えてくれるはずだ。ただ知っておいてほしいのは、より主流でよくあるエディターとは違って、vimで基本的な操作に習熟するには時間がかかるということだ。でも一度できるようになれば、その見返りも大きい。

さて、Neovimは基本的に無限にカスタマイズできる。本気でやり込みたいなら、自分のNeovim設定をゼロから作ることもできる。[TypecraftによるNeovimをゼロからセットアップする素晴らしいコース](https://www.youtube.com/watch?v=zHTeCSVAFNY) がある。そして [ThePrimeagenにも同じようなコースがある](https://www.youtube.com/watch?v=w7i4amO_zaE)。

でもOmarchyには、完全なNeovimセットアップ — `omarchy-nvim` パッケージ — が同梱されていて、箱から出してすぐに何ができるのか、その最良の姿を見せられるよう愛情を込めて調整されている。設定を一行も書く必要なしに！ これはNeovimプラグインと設定のディストリビューションである [LazyVim](https://www.lazyvim.org/) の上に構築されている。最高だ。

## LazyVimの基本

述べた通り、この短い紹介でvimを教えるつもりはないが、LazyVimの基本をいくつかと、操作方法は示せる。

まず、Neovimにはリーダーキーという考え方がある。これは基本的に、すべてのコマンドへの入口だ。LazyVimではそれが `Space` に設定されている。だからそれを押して1秒待つだけで、こんな風にたくさんの選択肢がインラインで説明付きで表示される：

私がいつも使っている基本コマンドをいくつか挙げる：

- `Space Space` - 現在のディレクトリ内の任意のファイルをあいまい検索する。
- `Space S G` - プレビュー付きでgrepを使ってすべてのファイルを検索する。
- `Space E` - ファイルツリーのオン/オフを切り替える。
- `Ctrl + W W` - ファイルツリーとエディターの間を行ったり来たりする。
- `Shift + H` - 開いているタブ（vimではバッファと呼ぶ）の間を左へ移動する。
- `Shift + L` - 開いているタブの間を右へ移動する。
- `Space B D` - タブを閉じる。
- `Space B O` - 現在のタブ以外のすべてのタブを閉じる。
- `Space G G` - 現在のディレクトリからフローティングペインでLazyGitを起動する。
- `Space U W` - ソフト折り返しを切り替える。

ファイルツリーにいるとき（`Space E` で表示し、`Ctrl + W W` でそこへ移動する）、`a` で新しいファイル、`A` で新しいディレクトリを追加できる。ツリーにいる間に `?` を押せば、すべてのコマンドが見られる。

vimの基本言語を身につけたいなら、私が書いた [三部構成の構文](https://world.hey.com/dhh/wonderful-vi-a1d034d3) と、あのすごいコンボ技の決め方について読んでみてほしい！

可能性のあるすべてのコマンドは [LazyVim Keymapsページ](https://www.lazyvim.org/keymaps) で見られる。

## Neovimの起動

`Super + Shift + N` はデフォルトエディターを起動する。新規インストールではそれはPlainだ。代わりにNeovimを起動させたいなら、_Setup > Defaults > Editor_ でNeovimを選ぶこと。でもたいていは、作業したいディレクトリへ移動して `n` と入力して、ターミナルから使うほうが簡単だ。`n` は `nvim` のエイリアスで、デフォルトで現在のディレクトリを開く。`n myfile.txt` で単一のファイルを開ける。

## sudo編集にNeovimを使う

スーパーユーザーとしてしか変更できないファイルを編集する必要があるなら、`sudoedit /etc/sudoers.d/00-sudo-only-file` を実行すること。デフォルトエディターが開くので、そこでプラグイン全部入りのNeovimを使いたいなら、_Setup > Defaults > Editor_ でNeovimを設定すること。
