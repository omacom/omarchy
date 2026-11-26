# 網頁應用程式

您可以使用 Omarchy 選單（`Super + Space`）中的 _安裝 > Web App_，來新增您自己的網頁應用程式。它會詢問您應用程式名稱、應用程式 URL，以及圖示 URL（若無法透過 favicon 取得圖示）。您可以在 [Dashboard Icons](https://dashboardicons.com) 找到許多熱門網頁應用程式的精美 PNG 圖示。

之後，您就可以透過應用程式啟動器（`Super + Space`）存取它們，並使用美觀的無邊框網頁應用程式視窗。

如果您想要移除某個網頁應用程式，只要前往 Omarchy 選單中的 _移除 > Web App_ 即可。

最好是在使用網頁應用程式捷徑之前，先用一般的瀏覽器登入您的所有帳號。那個輕量的外框包裝與 1password 的搭配效果不佳，所以先直接登入會簡單得多。

這些網頁應用程式的所有鍵盤快速鍵，都可以在 `~/.config/hypr/bindings.lua` 中變更。

當您身處某個網頁應用程式時，可以使用 `Shift + Alt + L` 將目前的 URL 複製到剪貼簿。

依預設，Omarchy 已經附帶一系列預設應用程式：

## HEY

[HEY](https://www.hey.com/) 是一項電子郵件與行事曆服務，對於厭倦 Gmail、Outlook 或 Apple Mail 的人來說，是一個很好的替代選擇。它由 [37signals](https://37signals.com/) 打造，也就是 Omarchy 的發源地。

您可以使用 `Super + Shift + E` 啟動 HEY Email，使用 `Super + Shift + Alt + E` 直接跳到撰寫新郵件，並使用 `Super + Shift + C` 啟動 HEY Calendar。

## Basecamp

[Basecamp](https://basecamp.com/) 是一項專案管理服務，能幫助小型團隊更快推進、取得更多進展。不必再把 Trello、Slack、Asana、Notion 或其他什麼東西拼湊成一團，用 Basecamp 就能把一切都集中在同一個地方。它由 [37signals](https://37signals.com/) 打造，也就是 Omarchy 的發源地。

您可以使用應用程式啟動器（`Super + Space`）啟動 Basecamp

## ChatGPT

[ChatGPT](https://chatgpt.com) 是全世界最受歡迎的 AI 聊天機器人。

您可以使用 `Super + Shift + A` 啟動 ChatGPT。

## Grok

[Grok](https://grok.com) 是 xAI 的聊天機器人。

您可以使用 `Super + Shift + Alt + A` 啟動 Grok。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) 是全世界最受歡迎的通訊服務之一，而網頁版是 Linux 上的一個絕佳選擇。

您可以使用 `Super + Shift + Alt + G` 啟動 WhatsApp。它會以 Omarchy 的 WhatsApp Slim 擴充功能開啟，讓它跟隨您的主題，並在視窗較窄時收合聊天清單。

## Google 應用程式

Google Messages、Google Photos、Google Maps 和 Google Contacts 也都以網頁應用程式的形式包含在內。

您可以使用 `Super + Shift + Ctrl + G` 啟動 Google Messages，使用 `Super + Shift + P` 啟動 Google Photos，並使用 `Super + Shift + S` 啟動 Google Maps。Google Contacts 則可透過應用程式啟動器（`Super + Space`）使用。

## X

X 是新聞傳出的地方。

您可以使用 `Super + Shift + X` 啟動 X，並使用 `Super + Shift + Alt + X` 直接開始撰寫新貼文。

## YouTube

[YouTube](https://youtube.com/) 是全世界最受歡迎的影音平台。

您可以使用 `Super + Shift + Y` 啟動 YouTube。

## Netflix

[Netflix](https://www.netflix.com/) 在新安裝中以網頁應用程式的形式包含在內。

您可以使用應用程式啟動器（`Super + Space`）啟動 Netflix。

## Zoom

[Zoom](https://zoom.us/) 是美國最受歡迎的視訊聊天系統。在全世界都有很好的連線品質。而且沒有付費帳號也能舉行 40 分鐘的會議。Omarchy 包裝了 Zoom 的網頁用戶端，zoom 會議連結會直接在其中開啟。

您可以使用應用程式啟動器（`Super + Space`）啟動 Zoom。

## Discord

[Discord](https://discord.com/) 是大多數遊戲與開放原始碼社群聚集的地方，包括 [Omarchy 自己的社群](https://discord.gg/tXFUdasqhY)。

您可以使用應用程式啟動器（`Super + Space`）啟動 Discord。

## Microsoft 應用程式

選取 _安裝 > Service > Microsoft_，即可將 Outlook、Word、Excel、PowerPoint、Teams 和 OneDrive 新增為網頁應用程式。每個應用程式都有自己的啟動器，並會直接開啟，使用商用 Microsoft 365 URL 以及您現有的瀏覽器設定檔。它們會在與 Omarchy 其他網頁應用程式相同的瀏覽器應用程式視窗中開啟；它們不會安裝獨立的 Teams for Linux 用戶端。

使用 _移除 > Services > Microsoft_ 移除整個套裝，或使用 _移除 > Web App_ 移除個別應用程式。您也可以只透過 _安裝 > Web App_ 安裝您想要的應用程式。

若是政府或主權雲端，請在 `~/.local/share/applications/` 下相關啟動器的 `Exec=` 行編輯 URL，例如 `Microsoft Teams.desktop`，使用您的組織提供的 URL。在該行中，任何字面上的 `%` 都要寫成 `%%`。變更會在下次啟動時套用。再次執行套裝安裝程式，會以預設 URL 取代其啟動器。

若要讓工作登入保持分開，請在每個啟動器的 `Exec=` 行附加一個瀏覽器資料目錄：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

將範例目錄換成您自行選擇的絕對路徑，並在全部六個啟動器中使用相同的路徑，讓它們共用工作登入。這些網頁應用程式會使用 Omarchy 選取的受支援瀏覽器，當預設瀏覽器不受支援時，則會改用 Chrome。
