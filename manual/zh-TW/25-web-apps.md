# 網頁應用程式

你可以透過 Omarchy 選單（`Super + Space`）中的 _安裝 > Web App_ 新增自己的網頁應用程式。它會要求你提供應用程式名稱、應用程式 URL，以及圖示 URL（若無法透過 favicon 取得圖示時）。你可以在 [Dashboard Icons](https://dashboardicons.com) 找到許多熱門網頁應用程式的精美 PNG 圖示。

之後，你就能透過應用程式啟動器（`Super + Space`）存取它們，並使用美觀的無邊框網頁應用程式視窗。

如果你想移除某個網頁應用程式，只需前往 Omarchy 選單中的 _移除 > Web App_。

最好先使用一般的瀏覽器登入你所有的帳號，再使用網頁應用程式捷徑。這個精簡的外層框架與 1password 搭配得不太好，所以直接先登入會簡單得多。

這些網頁應用程式的所有鍵盤快捷鍵都可以在 `~/.config/hypr/bindings.lua` 中更改。

當你在網頁應用程式中時，可以使用 `Shift + Alt + L` 將目前的 URL 複製到剪貼簿。

預設情況下，Omarchy 已經隨附一系列預設應用程式：

## HEY

[HEY](https://www.hey.com/) 是一項電子郵件與行事曆服務，對於厭倦 Gmail、Outlook 或 Apple Mail 的人來說，是很棒的替代選擇。它由 [37signals](https://37signals.com/) 打造，而 Omarchy 也源自該公司。

你可以使用 `Super + Shift + E` 啟動 HEY Email，使用 `Super + Shift + Alt + E` 直接撰寫新郵件，並使用 `Super + Shift + C` 啟動 HEY Calendar。

## Basecamp

[Basecamp](https://basecamp.com/) 是一項專案管理服務，能幫助小型團隊更快推進並取得更多進展。你不必再把 Trello、Slack、Asana、Notion 或其他亂七八糟的工具拼湊在一起，Basecamp 讓你把一切集中在一個地方。它由 [37signals](https://37signals.com/) 打造，而 Omarchy 也源自該公司。

你可以使用應用程式啟動器（`Super + Space`）啟動 Basecamp

## ChatGPT

[ChatGPT](https://chatgpt.com) 是全球最受歡迎的 AI 聊天機器人。

你可以使用 `Super + Shift + A` 啟動 ChatGPT。

## Grok

[Grok](https://grok.com) 是 xAI 的聊天機器人。

你可以使用 `Super + Shift + Alt + A` 啟動 Grok。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) 是全球最受歡迎的通訊服務之一，其網頁版是在 Linux 上使用的絕佳選擇。

你可以使用 `Super + Shift + Alt + G` 啟動 WhatsApp。

## Google 應用程式

Google Messages、Google Photos、Google Maps 和 Google Contacts 也都以網頁應用程式的形式隨附。

你可以使用 `Super + Shift + Ctrl + G` 啟動 Google Messages，使用 `Super + Shift + P` 啟動 Google Photos，並使用 `Super + Shift + S` 啟動 Google Maps。Google Contacts 則可透過應用程式啟動器（`Super + Space`）使用。

## X

X 是新聞傳開的地方。

你可以使用 `Super + Shift + X` 啟動 X，並使用 `Super + Shift + Alt + X` 直接撰寫新貼文。

## YouTube

[YouTube](https://youtube.com/) 是全球最受歡迎的影片平台。

你可以使用 `Super + Shift + Y` 啟動 YouTube。

## Zoom

[Zoom](https://zoom.us/) 是美國最受歡迎的視訊聊天系統。在全球各地都有出色的連線品質。而且沒有付費帳號也能舉行 40 分鐘的會議。Omarchy 包裝了 Zoom 的網頁客戶端，Zoom 會議連結會直接在其中開啟。

你可以使用應用程式啟動器（`Super + Space`）啟動 Zoom。

## Discord

[Discord](https://discord.com/) 是大多數遊戲與開源社群聚集的地方，包括 [Omarchy 自己的社群](https://discord.gg/tXFUdasqhY)。

你可以使用應用程式啟動器（`Super + Space`）啟動 Discord。

## Microsoft 應用程式

選擇 _安裝 > 服務 > Microsoft_，即可將 Outlook、Word、Excel、PowerPoint、Teams 和 OneDrive 新增為網頁應用程式。每個應用程式都有自己的啟動器並可直接開啟，使用商用 Microsoft 365 URL 和你現有的瀏覽器設定檔。它們會在與 Omarchy 其他網頁應用程式相同的瀏覽器應用程式視窗中開啟；它們不會安裝獨立的 Teams for Linux 客戶端。

使用 _移除 > 服務 > Microsoft_ 移除整個套裝，或使用 _移除 > Web App_ 移除個別應用程式。你也可以透過 _安裝 > Web App_ 只安裝你想要的應用程式。

若是政府雲或主權雲，請在 `~/.local/share/applications/` 下相關啟動器（例如 `Microsoft Teams.desktop`）的 `Exec=` 行中編輯 URL，使用你的組織提供的 URL。該行中的任何常值 `%` 都要寫成 `%%`。變更會在下次啟動時套用。再次執行套裝安裝程式會將其啟動器取代為預設 URL。

若要讓工作登入保持獨立，請在每個啟動器的 `Exec=` 行附加一個瀏覽器資料目錄：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

將範例目錄取代為你選擇的絕對路徑，並在全部六個啟動器中使用相同的路徑，讓它們共用工作登入。這些網頁應用程式使用 Omarchy 所選的受支援瀏覽器，當預設瀏覽器不受支援時，則會改用 Chrome。
