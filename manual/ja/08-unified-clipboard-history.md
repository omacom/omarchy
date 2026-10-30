# 統一クリップボードと履歴

通常、Linuxでは、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が必要で、それ以外の場所では `Ctrl + C/V` を使う。生まれも育ちもLinuxでない人にとっては、慣れるのが大変だ！ Macから移ってきた場合、superからctrlへの切り替えも同様だ。

Omarchyは、(ほぼ)どこでも使える統一クリップボードホットキーで、この2つの問題に対処している。以下の通りだ：

| ホットキー | コマンド |
| ------- | ----------- |
| Super + A | すべて選択 |
| Super + C | コピー |
| Super + X | 切り取り |
| Super + V | 貼り付け |
| Super + Ctrl + V | クリップボード履歴 |

_なお、ほとんどのエージェントハーネスでは、画像の貼り付けには `Ctrl + V` を使い、テキストの貼り付けには `Super + V` を使う。_

`Ctrl + A` に対応しているフォーカス中のテキストフィールドやその他のアプリで、すべてをコピーするには `Super + A` を押し、次に `Super + C` を押す。ターミナルでは、`Ctrl + A` はテキストを選択するのではなく、コマンドラインの先頭へ移動する。

### クリップボード履歴

クリップボード履歴はOmarchy shellによって提供され、テキストと画像の両方に対応している。`Super + Ctrl + V` で呼び出し、returnで項目を選択すると、それがクリップボードに配置され、`Super + V` で貼り付けられるようになる。

 ![clipboard-history](images/clipboard-history.webp)

入力を始めるだけで履歴を検索することもできる：

 ![clipboard-history-search](images/clipboard-history-search.webp)
