# 字型

Omarchy 預設使用 JetBrainsMono Nerd Font 作為終端機字型與系統字型。

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

你可以透過 Omarchy 選單 (`Super + Space`) 中的 _Appearance > Font_ 選單來變更。這會在所有地方設定等寬字型：終端機、狀態列，以及任何其他需要等寬字型的程式。

你可以透過 Omarchy 選單中的 _Install > Style > Font_ 安裝其他熱門的程式設計字型：Cascadia Mono、Meslo LG Mono、Fira Code、Victor Code、Bitstream Vera Mono 以及 Iosevka 都只需點一下即可安裝，而且都是 Nerd Font 版本，狀態列與終端機中的字圖才能繼續正常運作。安裝其中一款也會將整個系統切換成該字型，你隨時可以在 _Appearance > Font_ 下切換回來。

## 中文、日文與韓文

中文、日文與韓文共用許多字，但其中部分字的寫法各有不同，因此同一個字對一位讀者看起來正確，對另一位讀者卻可能很陌生。在 _Setup > Region > Language_ 下選擇其中一種語言，或選擇其輸入法，便會設定相符的字形形式。若要自行選擇，在終端機中執行 `omarchy font cjk jp`、`kr`、`sc`、`tc` (台灣) 或 `hk` (香港)；`omarchy font cjk default` 則會回復為系統所選的形式，也就是日文字形形式。網頁或文件若以其自身的語言標記文字，以及整個桌面在處於其中一種語言時，都會保留該語言的字形形式。
