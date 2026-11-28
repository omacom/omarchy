# 統合クリップボードと履歴

通常、Linux では、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外の場所では `Ctrl + C/V` を使います。生まれも育ちも Linux という人でなければ、これは慣れるのが大変です！ Mac から来た人にとって、Super から Ctrl への切り替えも同様です。

Omarchy は、（ほぼ）どこでも使える統合クリップボードホットキーで、その両方の問題に対処します。以下のとおりです：

| ホットキー | コマンド |
| ------- | ----------- |
| Super + A | すべて選択 |
| Super + C | コピー |
| Super + X | 切り取り |
| Super + V | 貼り付け |
| Super + Ctrl + V | クリップボード履歴 |

_ほとんどの agent harness では画像の貼り付けに `Ctrl + V` を使いますが、テキストの貼り付けには `Super + V` を使うことに注意してください。_

`Super + A` の後に `Super + C` を使うと、フォーカスされているテキストフィールドや、`Ctrl + A` に対応した他のアプリ内のすべてをコピーできます。ターミナルでは、`Ctrl + A` はテキストを選択するのではなく、コマンドラインの先頭へ移動します。

### クリップボード履歴

クリップボード履歴は Omarchy シェルによって提供され、テキストと画像の両方に対応しています。`Super + Ctrl + V` で呼び出して Return で項目を選択すると、それまで使っていたアプリに直接貼り付けられます。`Shift + Return` を使えばクリップボードへコピーだけし、`Alt + Return` で開き、`Delete` で履歴から削除し、`Shift + Delete` で履歴全体を消去できます。

 ![clipboard-history](images/clipboard-history.webp)

入力を始めるだけで履歴を検索することもできます：

 ![clipboard-history-search](images/clipboard-history-search.webp)
