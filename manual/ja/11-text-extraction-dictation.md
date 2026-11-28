# テキスト抽出と音声入力

### テキスト抽出

`Super + Ctrl + PrtScr` を押して、画面上のテキスト抽出する領域を選択します。tesseract オープンソース OCR モデルがその選択範囲をすばやくテキストに変換し、クリップボードに配置します。あとは `Super + V` を押して貼り付けるだけです。

これは、画像のフッターにある住所や、Web サイトの見出しに埋め込まれた電話番号を取得するのにとても便利です。

 ![text-extraction](images/text-extraction.webp)

### 音声入力

新規インストールでは、[Superwhisper](https://superwhisper.com/) がデフォルトの音声入力バックエンドであり、オフラインモデルをダウンロードせずにクラウド処理を使用します。Superwhisper、[Voxtype](https://voxtype.io/)、または [Hex](https://anoma.ly/hex/) は、Omarchy メニューの _Setup > Defaults > Dictation_ から選択します。バックエンドを選択すると、必要に応じてインストールされ、音声入力のデフォルトになります。Voxtype は 150MB を使用する基本的な英語モデルを読み込みます。モデルは `voxtype setup model` で変更し、その他の設定は `~/.config/voxtype/config.toml` で変更します。Superwhisper は設定を開いてクラウド処理かローカル処理かを選択し、OPR がアプリケーションを最新の状態に保ちます。Hex はセットアップ中にオンデバイスの音声モデルをダウンロードし、`hex.service` ユーザーサービスとして実行されます。モデルやその他の設定を変更するには、バーのトレイアイコンから、または `hex` を実行してそのウィンドウを開きます。

`Right Alt` を押し続けるか、`Alt + Space` で切り替えることで音声入力を行い、入力されたテキストはフォーカスされている入力エリアに表示されます。これらのショートカットは選択したバックエンドを使用します。Right Alt は修飾キーの組み合わせの一部として使用された場合も音声入力を開始します。そのような組み合わせには Left Alt を使用してください。Right Alt が AltGr であるキーボードレイアウトでは、そのようなレイアウトに切り替える場合も含め、音声入力するにはそれを単独でしばらく押し続けてください。AltGr を別のキーと一緒に押すと、その文字が入力されます。Alt + Space がデフォルトになる前のインストールでは、プッシュ・トゥ・トーク用の `F9` と切り替え用の `Super + Ctrl + X` が保持され、`~/.config/hypr/bindings.lua` に追加されています。そこではその `Super + Ctrl + X` がエージェントパネルの代わりとなります。それらのキーをアプリケーションとパネルに戻すには、そこで削除してください。

同じショートカットはすべてのバックエンドで機能します。Setup > Defaults > Dictation からバックエンドを選択します。バックエンドインストーラーがそれを設定し、選択を保存します。どれが選択されているか確認するには `omarchy default dictation` を実行します。選択は `~/.config/omarchy/defaults/dictation` に保存されます。新規インストールでは Superwhisper が自動的に選択されます。

Omarchy は選択したバックエンドのデスクトップ統合を自動的に読み込みます。`~/.config/hypr/` に Superwhisper の設定は必要ありません。

カスタムバインディングとスクリプトでは `omarchy dictation start`、`omarchy dictation stop`、`omarchy dictation toggle` を使用できます。選択したバックエンドが録音と文字起こしを処理します。Superwhisper を選択すると、そのネイティブな長押しショートカットが無効になり、ネイティブな切り替えが `Ctrl + Alt + Space` に設定され、Omarchy の録音キーとは分離されます。Superwhisper には少なくとも 1 つのネイティブな録音ショートカットが必要であり、そのキャンセル用ショートカットは引き続き利用できます。

追加のバックエンドは Omarchy を変更せずに統合できます。PATH 上に `omarchy-dictation-<backend>` という名前の実行可能ファイルを用意し、`start`、`stop`、`toggle` を受け付け、すみやかに終了し、失敗時には 0 以外のステータスを返すようにします。そのインストーラーはプロバイダーを設定し、セットアップが成功した後に `omarchy-dictation-use <backend>` を呼び出します。これにより以前のバックエンドが停止し、選択がアトミックに保存されます。`stop` はプロバイダーがアイドル状態または利用できない場合でも成功しなければなりません。バックエンド名には小文字、数字、ハイフンを使用します。セットアップ用に `omarchy-install-dictation-<backend>` を用意します。`omarchy default dictation <backend>` がそれを起動します。そのセレクターを呼び出すために、Omarchy メニュー拡張を通じて Defaults メニュー項目を追加します。オプションのデスクトップ統合は `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` に配置できます。
