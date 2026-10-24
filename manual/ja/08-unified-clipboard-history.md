# 統合クリップボードと履歴

Linux では通常、ターミナルでコピー＆ペーストするには `Ctrl + Shift + C/V` が、その他の場所では `Ctrl + C/V` が必要です。Linux で生まれ育っていない人には慣れるのが難しいでしょう！ Mac から来た場合の super から ctrl への切り替えも同様です。

Omarchy は（ほぼ）どこでも動く統合クリップボードホットキーでこの両方の問題に取り組んでいます。こちらです：

| ホットキー | コマンド |
| ------- | ----------- |
| Super + C | コピー |
| Super + X | 切り取り |
| Super + V | 貼り付け |
| Super + Ctrl + V | クリップボード履歴 |

_ほとんどのエージェントハーネスは画像の貼り付けに `Ctrl + V` を使いますが、テキストの貼り付けには `Super + V` を使うことに注意してください。_

### クリップボード履歴

クリップボード履歴は Omarchy シェルが提供し、テキストと画像の両方に対応します。`Super + Ctrl + V` で呼び出し、Enter でエントリを選択すると、それがクリップボードに載って `Super + V` で貼り付けられる状態になります。

 ![clipboard-history](images/clipboard-history.webp)

入力を始めるだけで履歴を検索することもできます：

 ![clipboard-history-search](images/clipboard-history-search.webp)
