# Neovim

[Neovim](https://neovim.io/) は、1976 年に Bill Joy によって作成された [vi エディタ](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) の現代的な実装です。挿入モードとコマンドモードが分離されたモーダルエディタで、信じられないほど深いキーコマンドセットの一部だけでも覚えれば、ちょっとしたスーパーパワーになります。でも、かなりな学習曲線でもあります！

vim スタイルの編集がまったく初めてなら、YouTube の [ThePrimeagen の Vim As Your Editor シリーズ](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) を見ることをお勧めします。それで基本が学べます。より一般的な主流エディタとは違って、vim で基本的な習熟度に到達するには時間がかかることを知っておいてください。でも一度到達すれば、見返りもより大きくなります。

さて Neovim は基本的に無限に設定可能です。本当に熱中したいなら、自分の Neovim 設定をゼロから作れます。[Typecraft の Neovim をゼロから設定する素晴らしいコース](https://www.youtube.com/watch?v=zHTeCSVAFNY) があります。そして [ThePrimeagen にもコースがあります](https://www.youtube.com/watch?v=w7i4amO_zaE)。

しかし Omarchy には完成した Neovim セットアップ、`omarchy-nvim` パッケージが同梱されており、箱から出してすぐに可能な最良のものを見せられるよう愛情を込めて調整されています。設定を 1 行も書く必要はありません！ [LazyVim](https://www.lazyvim.org/)、Neovim プラグインと設定のディストリビューションをベースにしています。素晴らしいです。

## LazyVim の基本

前述のとおり、この短い入門で vim を教えるつもりはありませんが、LazyVim の基本をいくつかと、移動方法は示せます。

まず、Neovim にはリーダーキーの概念があります。これは基本的にすべてのコマンドへの入口です。LazyVim はそれを `Space` に設定しています。だからそれを押して 1 秒待つと、このようにインラインで説明される大量のオプションが見えます：

私がいつも使う基本コマンドをいくつか紹介します：

- `Space Space` - 現在のディレクトリ内の任意のファイルをあいまい検索。
- `Space S G` - プレビュー付きで grep を使ってすべてのファイルを検索。
- `Space E` - ファイルツリーのオン/オフを切り替える。
- `Ctrl + W W` - ファイルツリーからエディタへ、また戻ってくる。
- `Shift + H` - 開いたタブ（vim ではバッファと呼びます）間を左へ移動。
- `Shift + L` - 開いたタブ間を右へ移動。
- `Space B D` - タブを閉じる。
- `Space B O` - 現在のもの以外のすべてのタブを閉じる。
- `Space G G` - 現在のディレクトリからフローティングペインで LazyGit を起動。
- `Space U W` - ソフトラップを切り替える。

ファイルツリー内にいる間（`Space E` で表示し、`Ctrl + W W` でそちらへ飛ぶ）、`a` で新しいファイル、`A` で新しいディレクトリを追加できます。ツリー内にいる間に `?` を押すとすべてのコマンドが見えます。

基本的な vim 言語を身につけたい場合は、[三部構成の構文](https://world.hey.com/dhh/wonderful-vi-a1d034d3) と、あのかっこいいコンボ技のやり方について書きました！

可能なコマンドはすべて [LazyVim Keymaps ページ](https://www.lazyvim.org/keymaps) で確認できます。

## Neovim の起動

`Super + Shift + N` で Neovim を起動できます（このバインドはデフォルトエディタを起動し、箱から出た状態では Neovim です）が、通常は作業したいディレクトリへ移動し、`n` と入力してターミナルから駆動する方が簡単です。`n` は `nvim` のエイリアスで、デフォルトで現在のディレクトリを開きます。`n myfile.txt` で単一のファイルを開けます。

## sudo 編集に Neovim を使う

スーパーユーザーとしてしか変更できないファイルを編集する必要がある場合は、`sudoedit /etc/sudoers.d/00-sudo-only-file` を実行することで、すべてのプラグインが設定された状態で neovim を使えます。
