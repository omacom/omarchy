# テキスト抽出とディクテーション

### テキスト抽出

`Super + Ctrl + PrtScr` を押して、画面上の領域を選択してテキストを抽出する。すると tesseract オープンソース OCR モデルが、その選択範囲をすばやくテキストに変換してクリップボードに配置する。あとは `Super + V` を押して貼り付けるだけだ。

これは、画像フッターから住所を取得したり、ウェブサイトの見出しに埋め込まれた電話番号を取得したりするのに非常に役立つ。

 ![text-extraction](images/text-extraction.webp)

### ディクテーション

新規インストールでは、[Superwhisper](https://superwhisper.com/) がデフォルトのディクテーションバックエンドとなり、オフラインのモデルダウンロードなしでクラウド処理を使用する。Omarchy メニューの _Setup > Defaults > Dictation_ から Superwhisper または [Voxtype](https://voxtype.io/) を選択する。バックエンドを選択すると、必要に応じてインストールされ、ディクテーションのデフォルトになる。Voxtype は 150MB の容量を使う基本的な英語モデルを読み込む。モデルは `voxtype setup model` で変更し、その他の設定は `~/.config/voxtype/config.toml` から変更する。Superwhisper は設定を開いてクラウド処理またはローカル処理を選択でき、OPR がアプリケーションを最新の状態に保つ。

`Right Alt` を押し続けるか、`Alt + Space` で切り替えることでディクテーションを行い、ディクテーションしたテキストはフォーカスされている入力エリアに表示される。これらのショートカットは選択されたバックエンドを使用する。Right Alt は修飾キーの組み合わせで使用した場合もディクテーションを開始する。そうした組み合わせには Left Alt を使う。Right Alt が AltGr になるキーボードレイアウトでは、AltGr を入力に使えるように保つため、`Alt + Space` を使う。Alt + Space がデフォルトになる前にインストールした環境では、プッシュトゥトーク用の `F9` と切り替え用の `Super + Ctrl + X` が維持され、`~/.config/hypr/bindings.lua` に追加されている。それらのキーをアプリケーションに返すには、そこで削除する。

同じショートカットはどちらのバックエンドでも動作する。Setup > Defaults > Dictation からバックエンドを選択する。バックエンドのインストーラーがそれを設定し、選択を保存する。`omarchy default dictation` を実行すると、どちらが選択されているか確認できる。選択は `~/.config/omarchy/defaults/dictation` に保存される。新規インストールでは Superwhisper が自動的に選択される。

Omarchy は選択されたバックエンドのデスクトップ統合を自動的に読み込む。`~/.config/hypr/` に Superwhisper の設定は不要だ。

カスタムバインディングとスクリプトでは `omarchy dictation start`、`omarchy dictation stop`、`omarchy dictation toggle` を使える。選択されたバックエンドが録音と文字起こしを処理する。Superwhisper を選択すると、そのネイティブな長押しショートカットは無効化され、ネイティブな切り替えは `Ctrl + Alt + Space` に設定され、Omarchy の録音キーとは分離される。Superwhisper には少なくとも 1 つのネイティブな録音ショートカットが必要であり、キャンセル用ショートカットは引き続き利用できる。

追加のバックエンドは Omarchy を変更せずに統合できる。PATH 上に `omarchy-dictation-<backend>` という名前の実行可能ファイルを用意し、`start`、`stop`、`toggle` を受け付けて速やかに戻り、失敗時にはゼロ以外のステータスを返すようにする。そのインストーラーはプロバイダーを設定し、セットアップが成功した後に `omarchy-dictation-use <backend>` を呼び出す。これにより以前のバックエンドが停止し、選択がアトミックに保存される。プロバイダーがアイドル状態または利用できない場合でも、`stop` は成功しなければならない。バックエンド名には小文字、数字、ハイフンを使う。セットアップ用に `omarchy-install-dictation-<backend>` を用意する。`omarchy default dictation <backend>` がそれを起動する。Omarchy メニュー拡張を通じて Defaults メニュー項目を追加し、そのセレクターを呼び出すようにする。オプションのデスクトップ統合は `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` に配置できる。
