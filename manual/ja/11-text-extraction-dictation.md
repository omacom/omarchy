# テキスト抽出と音声入力

### テキスト抽出

`Super + Ctrl + PrtScr` を押すと、画面上の領域を選択してテキストを抽出できます。オープンソースの OCR モデルである tesseract が、その選択範囲をすばやくテキストに変換してクリップボードに配置します。あとは `Super + V` を押して貼り付けるだけです。

画像のフッターから住所を取得したり、ウェブサイトの見出しに埋め込まれた電話番号を取得したりするのに非常に便利です。

 ![text-extraction](images/text-extraction.webp)

### 音声入力

新規インストールでは、[Superwhisper](https://superwhisper.com/) がデフォルトの音声入力バックエンドとなり、オフラインモデルのダウンロードなしでクラウド処理を使用します。Omarchy メニューの _Setup > Defaults > Dictation_ から、Superwhisper、[Voxtype](https://voxtype.io/)、[Hex](https://anoma.ly/hex/) のいずれかを選択できます。バックエンドを選択すると、必要に応じてインストールされ、音声入力のデフォルトになります。Voxtype は 150MB の基本的な英語モデルを読み込みます。モデルは `voxtype setup model` で変更し、その他の設定は `~/.config/voxtype/config.toml` で変更します。Superwhisper では設定画面が開き、クラウド処理かローカル処理かを選択できます。また、OPR によってアプリケーションが最新の状態に保たれます。Hex はセットアップ時にオンデバイスの音声モデルをダウンロードし、`hex.service` ユーザーサービスとして動作します。モデルやその他の設定を変更するには、バーのトレイアイコンからウィンドウを開くか、`hex` を実行してください。

`Right Alt` を押し続けるか、`Alt + Space` で切り替えることで音声入力ができ、音声入力したテキストはフォーカス中の入力エリアに表示されます。これらのショートカットは選択したバックエンドを使用します。修飾キーの組み合わせで Right Alt を使用した場合も音声入力が開始されます。そのような組み合わせには Left Alt を使用してください。Right Alt が AltGr になっているキーボードレイアウトでは、`Alt + Space` を使用することで、AltGr をタイピングに使える状態を維持できます。Alt + Space がデフォルトになる前にインストールされた環境では、プッシュトゥトーク用の `F9` と切り替え用の `Super + Ctrl + X` が保持され、`~/.config/hypr/bindings.lua` に追加されます。これらのキーをアプリケーションに戻すには、そこで削除してください。

同じショートカットがすべてのバックエンドで動作します。バックエンドは Setup > Defaults > Dictation から選択してください。バックエンドのインストーラーが設定を行い、選択を保存します。`omarchy default dictation` を実行すると、どれが選択されているかを確認できます。選択は `~/.config/omarchy/defaults/dictation` に保存されます。新規インストールでは Superwhisper が自動的に選択されます。

Omarchy は選択したバックエンドのデスクトップ統合を自動的に読み込みます。`~/.config/hypr/` で Superwhisper の設定は不要です。

カスタムバインディングやスクリプトでは `omarchy dictation start`、`omarchy dictation stop`、`omarchy dictation toggle` を使用できます。選択したバックエンドが録音と文字起こしを処理します。Superwhisper を選択すると、ネイティブのホールドショートカットが無効になり、ネイティブの切り替えが `Ctrl + Alt + Space` に設定され、Omarchy の録音キーとは分離されます。Superwhisper には少なくとも1つのネイティブ録音ショートカットが必要であり、キャンセル用ショートカットは引き続き利用できます。

追加のバックエンドは Omarchy を変更せずに統合できます。PATH 上に `start`、`stop`、`toggle` を受け付け、速やかに戻り、失敗時にはゼロ以外のステータスを返す `omarchy-dictation-<backend>` という名前の実行可能ファイルを用意してください。そのインストーラーはプロバイダーを設定し、セットアップが成功した後に `omarchy-dictation-use <backend>` を呼び出します。これにより以前のバックエンドが停止し、選択がアトミックに保存されます。`stop` はプロバイダーがアイドル状態または利用できない場合でも成功しなければなりません。バックエンド名には小文字、数字、ハイフンを使用します。セットアップ用に `omarchy-install-dictation-<backend>` を用意してください。`omarchy default dictation <backend>` がそれを起動します。Omarchy メニュー拡張機能を通じて Defaults メニュー項目を追加し、そのセレクターを呼び出せるようにしてください。オプションのデスクトップ統合は `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua` に配置できます。
