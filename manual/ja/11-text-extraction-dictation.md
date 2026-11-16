# テキスト抽出と音声入力

### テキスト抽出

`Super + Ctrl + PrtScr` を押して、画面上の範囲を選択し、テキストを抽出します。オープンソースの OCR モデルである tesseract が、その選択範囲をすばやくテキストに変換してクリップボードに配置します。あとは `Super + V` を押して貼り付けるだけです。

画像のフッターにある住所や、Webサイトの見出しに埋め込まれた電話番号を取り出すのにとても便利です。

 ![text-extraction](images/text-extraction.webp)

### 音声入力

新規インストールでは、[Superwhisper](https://superwhisper.com/) がデフォルトの音声入力バックエンドであり、オフラインモデルをダウンロードせずにクラウド処理を使用します。Omarchy メニューの _Setup > Defaults > Dictation_ から、Superwhisper、[Voxtype](https://voxtype.io/)、[Hex](https://anoma.ly/hex/) のいずれかを選択します。バックエンドを選択すると、必要であればインストールされ、音声入力のデフォルトになります。Voxtype は 150MB の基本的な英語モデルを読み込みます。モデルは `voxtype setup model` で変更し、その他の設定は `~/.config/voxtype/config.toml` で変更します。Superwhisper では設定を開いてクラウド処理かローカル処理かを選択でき、OPR がアプリケーションを最新の状態に保ちます。Hex はセットアップ中にデバイス上の音声モデルをダウンロードし、`hex.service` ユーザーサービスとして動作します。モデルやその他の設定を変更するには、バーのトレイアイコンからウィンドウを開くか、`hex` を実行します。

`Right Alt` を押し続けるか、`Alt + Space` で切り替えることで音声入力を行い、音声入力したテキストはフォーカスされている入力エリアに表示されます。これらのショートカットは選択したバックエンドを使用します。Right Alt は修飾キーの組み合わせで使った場合も音声入力を開始します。そのような組み合わせには Left Alt を使用してください。Right Alt が AltGr になるキーボードレイアウトでは、`Alt + Space` を使用して、AltGr を入力に使える状態に保ってください。Alt + Space がデフォルトになる前からのインストールでは、プッシュトゥトーク用の `F9` と切り替え用の `Super + Ctrl + X` が保持され、`~/.config/hypr/bindings.lua` に追加されています。そこでは、その `Super + Ctrl + X` がエージェントパネルの代わりになっています。それらのキーをアプリケーションとパネルに戻すには、そこで削除してください。

同じショートカットがすべてのバックエンドで機能します。Setup > Defaults > Dictation からバックエンドを選択してください。バックエンドのインストーラーがそれを設定し、選択を保存します。どれが選択されているか確認するには、`omarchy default dictation` を実行します。選択は `~/.config/omarchy/defaults/dictation` に保存されます。新規インストールでは Superwhisper が自動的に選択されます。

Omarchy は選択したバックエンドのデスクトップ統合を自動的に読み込みます。`~/.config/hypr/` に Superwhisper の設定は必要ありません。

カスタムバインディングやスクリプトでは、`omarchy dictation start`、`omarchy dictation stop`、`omarchy dictation toggle` を使用できます。選択したバックエンドが録音と文字起こしを処理します。Superwhisper を選択すると、そのネイティブな長押しショートカットが無効になり、ネイティブな切り替えが `Ctrl + Alt + Space` に設定され、Omarchy の録音キーとは分離された状態に保たれます。Superwhisper には少なくとも 1 つのネイティブな録音ショートカットが必要であり、そのキャンセル用ショートカットは引き続き利用できます。

追加のバックエンドは、Omarchy を変更することなく統合できます。PATH 上に `omarchy-dictation-<backend>` という名前の実行ファイルを用意し、`start`、`stop`、`toggle` を受け付けて速やかに戻り、失敗した場合は 0 以外のステータスを返すようにしてください。そのインストーラーはプロバイダーを設定し、セットアップが成功した後に `omarchy-dictation-use <backend>` を呼び出します。これにより、以前のバックエンドが停止し、選択がアトミックに保存されます。プロバイダーがアイドル状態であるか利用できない場合でも、`stop` は成功しなければなりません。バックエンド名には小文字、数字、ハイフンを使用します。セットアップ用に `omarchy-install-dictation-<backend>` を用意します。`omarchy default dictation <backend>` でそれが起動します。そのセレクターを呼び出すために、Omarchy メニュー拡張を通じて Defaults メニュー項目を追加してください。オプションのデスクトップ統合は `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` に配置できます。
