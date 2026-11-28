# 主題

Omarchy 內建二十三款精美主題。你可以透過 Omarchy Menu（`Super + Space`）中的 _外觀 > 主題_ 在這些主題之間切換，或使用 `Super + Ctrl + T` 直接跳至主題選擇器。

每個主題都會為桌面、終端機、neovim、活動畫面 (btop)、你的瀏覽器（Chrome、Chromium、Edge 或 Brave），以及整個 Omarchy shell 套用樣式：頂部列、選單、通知、OSD 和鎖定畫面。（至於 Obsidian，你必須在應用程式內透過 _外觀 > 主題_ 手動選取 Omarchy 主題）。

主題有一組背景圖片，你可以使用 `Super + Ctrl + W` 在其中挑選。

你可以在[額外主題頁面](https://omarchy.org/themes/)找到更多主題，甚至可以[打造你自己的主題](43-making-your-own-theme.md)。

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

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### 應用程式圖示

應用程式啟動器和 dock 中的圖示會以你的主題色彩繪製，因此會隨著主題一起改變。它們來自圖示集，圖示集要在 _外觀 > 圖示_ 下與主題分開挑選，透過每組圖示集的預覽來選，就像挑選主題一樣：

- _Papercraft_ 是預設值：所有預先安裝的內容，都以同一種風格繪製。以標誌聞名的應用程式，如 Chrome、HEY 或 YouTube，會保留其形狀並套用主題的色彩。
- _Arcade_ 會將相同的應用程式繪製成 8 位元像素藝術，就像舊款遊戲主機會呈現的那樣。
- _Original_ 會以製作者提供的圖示顯示每個應用程式。

你可以使用 _安裝 > 樣式 > 圖示_（或 `omarchy icons install <git url>`）安裝別人製作的圖示集，並在 _移除 > 圖示_ 下再次將它移除。_更新 > 額外圖示_ 會擷取你已安裝之圖示集的最新版本。

若要製作你自己的圖示集，請將圖示放在 `~/.config/omarchy/icons/<name>/`，每個應用程式一個檔案，並以應用程式 `.desktop` 檔案的 `Icon=` 行來命名。以 `.svg` 結尾的檔案會以原樣顯示。以 `.svg.tpl` 結尾的檔案會以主題的色彩繪製：在需要填入色彩的位置寫入 `{{ icon_main }}`、`{{ icon_mark }}`、`{{ icon_paper }}`、`{{ icon_body }}`、`{{ icon_edge }}`、`{{ icon_ink }}` 或 `{{ icon_shadow }}`。位於 `/usr/share/omarchy/icons/papercraft/` 的預設圖示集是很好的出發點。加入 `preview.png` 即可在選擇器中顯示你的圖示集；若沒有，Omarchy 會從你的圖示繪製預覽。若要變更預設圖示集中的單一圖示，請將你的版本放在 `~/.config/omarchy/icons/papercraft/`。

### 開機與登入

電腦啟動時要求你輸入磁碟密碼的畫面，以及登入畫面，也會跟隨主題。每次你切換主題時，它們都會套用該主題的背景、文字、強調色和紅色，因此不需要另外挑選一套解鎖設計。在 Apple Silicon Mac 上，無論使用哪個主題，磁碟密碼畫面都會保持 Omarchy 的預設外觀。
