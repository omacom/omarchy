# 主題

Omarchy 內建二十二套精美主題。你可以透過 Omarchy 選單（`Super + Space`）中的 _外觀 > 主題_ 在這些主題之間選擇，或使用 `Super + Ctrl + T` 直接跳到主題選擇器。

每個主題都會為桌面、終端機、neovim、活動畫面（btop）、Chromium 以及整個 Omarchy shell 設定樣式：頂部列、選單、通知、OSD 和鎖定畫面。（如果是 Obsidian，你必須在應用程式內透過 _外觀 > 主題_ 手動選擇 Omarchy 主題）。

每個主題都有一組背景圖片，你可以使用 `Super + Ctrl + W` 在這些圖片之間選擇。

你可以在 [額外主題頁面](https://omarchy.org/themes/) 找到更多主題，甚至可以 [製作你自己的主題](43-making-your-own-theme.md)。

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

### 應用程式圖示

應用程式啟動器和 dock 中的圖示會以你的主題色彩繪製，因此會隨著主題一起改變。它們來自一套圖示集，你可以在 _外觀 > 圖示_ 下與主題分開選擇，透過每套圖示集的預覽來挑選，方式就和挑選主題一樣：

- _Papercraft_ 是預設值：所有已安裝的內容，都以同一種風格繪製。像 Chrome、HEY 或 YouTube 這類以標誌為人所知的應用程式，會保留其形狀，並換上主題的色彩。
- _Arcade_ 會將相同的應用程式繪製成 8 位元像素藝術，就像老式遊戲主機會呈現的那樣。
- _Original_ 會以每個應用程式的製作者所提供的圖示來顯示它。

你可以使用 _安裝 > 樣式 > 圖示_（或 `omarchy icons install <git url>`）安裝別人製作的圖示集，並在 _移除 > 圖示_ 下再次將它移除。_更新 > 額外圖示_ 會取得你已安裝圖示集的最新版本。

若要製作你自己的圖示集，請將你的圖示放在 `~/.config/omarchy/icons/<name>/` 中，每個應用程式一個檔案，並以該應用程式 `.desktop` 檔案的 `Icon=` 行來命名。以 `.svg` 結尾的檔案會原樣顯示。以 `.svg.tpl` 結尾的檔案會以主題的色彩繪製：在需要填入色彩的位置寫上 `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}` 或 `{{ icon_shadow }}`。位於 `/usr/share/omarchy/icons/papercraft/` 的預設圖示集是個很好的出發點。加入一個 `preview.png` 來在選擇器中顯示你的圖示集；如果沒有，Omarchy 會從你的圖示繪製預覽。若要變更預設圖示集中的單一圖示，請將你的版本放在 `~/.config/omarchy/icons/papercraft/` 中。

### 解鎖畫面

主題也可以擁有自訂的解鎖設計，用於開機解密程序。你可以在 _外觀 > 解鎖_ 下選擇其中一種。它們看起來像這樣：

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
