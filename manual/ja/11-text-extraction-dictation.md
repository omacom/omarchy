# テキスト抽出とディクテーション

### テキスト抽出

`Super + Ctrl + PrtScr` を押して、テキスト抽出のための画面領域を選択してください。オープンソースの OCR モデル tesseract がその選択をすぐにテキストに変換し、クリップボードに載せます。あとは `Super + V` を押して貼り付けるだけです。

画像フッターから住所を取り出したり、ウェブサイトの見出しに埋め込まれた電話番号を取り出したりするのにとても役立ちます。

 ![text-extraction](images/text-extraction.webp)

### ディクテーション

新規インストールでは、[Superwhisper](https://superwhisper.com/) がデフォルトのディクテーションバックエンドで、オフラインモデルのダウンロードなしにクラウド処理を使います。Omarchy メニューの _設定 > デフォルト > ディクテーション_ から Superwhisper または [Voxtype](https://voxtype.io/) を選んでください。バックエンドを選択すると、必要ならインストールされ、ディクテーションのデフォルトになります。Voxtype は 150MB の基本英語モデルを読み込みます。`voxtype setup model` でモデルを変更し、その他の設定は `~/.config/voxtype/config.toml` で行います。Superwhisper はクラウドかローカル処理を選ぶ設定を開き、OPR がアプリケーションを最新に保ちます。

`Right Alt` または `F9` を押し続けるか、`Super + Ctrl + X` で切り替えてディクテーションすると、ディクテーションされたテキストがフォーカスされた入力領域に表示されます。これらのショートカットは選択されたバックエンドを使います。Right Alt は修飾キーの組み合わせで使われたときもディクテーションを開始します。そうした組み合わせには Left Alt を使ってください。Right Alt が AltGr になるキーボードレイアウトでは、入力に AltGr を使えるように `F9` を使ってください。

同じショートカットはどちらのバックエンドでも動きます。設定 > デフォルト > ディクテーション からバックエンドを選んでください。バックエンドインストーラーが設定し、選択を保存します。`omarchy default dictation` を実行するとどちらが選択されているか確認できます。選択は `~/.config/omarchy/defaults/dictation` に保存されます。新規インストールでは Superwhisper が自動的に選択されます。

Omarchy は選択されたバックエンドのデスクトップ統合を自動的に読み込みます。`~/.config/hypr/` に Superwhisper の設定は不要です。

カスタムバインドやスクリプトは `omarchy dictation start`、`omarchy dictation stop`、`omarchy dictation toggle` を使えます。選択されたバックエンドが録音と文字起こしを処理します。Superwhisper を選択すると、そのネイティブの長押しショートカットが無効になり、ネイティブのトグルが `Alt + Space` に設定され、Omarchy の録音キーとは別に保たれます。Superwhisper は少なくとも 1 つのネイティブ録音ショートカットを必要とし、そのキャンセルショートカットは引き続き使えます。

追加のバックエンドは Omarchy を変更せずに統合できます。PATH 上に `omarchy-dictation-<backend>` という名前の実行ファイルを用意し、`start`、`stop`、`toggle` を受け付け、迅速に返し、失敗時には非ゼロのステータスを返すようにしてください。そのインストーラーがプロバイダーを設定し、セットアップ成功後に `omarchy-dictation-use <backend>` を呼びます。これにより前のバックエンドが停止し、選択がアトミックに保存されます。`stop` はプロバイダーがアイドルまたは利用不可のときに成功しなければなりません。バックエンド名は小文字、数字、ハイフンを使います。セットアップ用に `omarchy-install-dictation-<backend>` を用意してください。`omarchy default dictation <backend>` がそれを起動します。そのセレクターを呼ぶために、Omarchy メニュー拡張を通してデフォルトメニューエントリを追加してください。オプションのデスクトップ統合は `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` に置けます。
