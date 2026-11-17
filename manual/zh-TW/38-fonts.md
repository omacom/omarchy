# 字型

Omarchy 預設使用 JetBrainsMono Nerd Font 同時作為終端機與系統字型。

 ![fonts-jetbrainsmono](images/fonts-jetbrainsmono.webp)

你可以透過 Omarchy 選單（`Super + Space`）中的 _外觀 > 字型_ 選單變更這項設定。這會在所有地方設定等寬字型：終端機、狀態列，以及任何其他需要等寬字型的地方。

你可以透過 Omarchy 選單中的 _安裝 > 樣式 > 字型_ 安裝其他熱門的程式設計字型：Cascadia Mono、Meslo LG Mono、Fira Code、Victor Code、Bitstream Vera Mono 和 Iosevka 都只要點一下就能安裝，而且都是 Nerd Font 版本，因此狀態列和終端機中的字形圖示能繼續正常運作。安裝其中一款後，在 _外觀 > 字型_ 底下選取它。

## 中文、日文與韓文

中文、日文與韓文共用許多漢字，但其中有些字的寫法不同，因此同一個字對某一種語言的讀者看來正確，對另一種語言的讀者看來卻很陌生。在 _設定 > 語言_ 底下選取其中一種語言，或選取它的輸入法，就會設定對應的字型形式。若要自行選擇，在終端機中執行 `omarchy font cjk jp`、`kr`、`sc`、`tc`（台灣）或 `hk`（香港）；`omarchy font cjk default` 會回到系統的選擇，也就是日文字型形式。網頁或文件以其自身語言標記的文字，以及整個桌面在處於其中一種語言時，都會保留該語言的字型形式。
