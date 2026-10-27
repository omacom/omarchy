# 網頁應用程式

你可以使用 Omarchy 選單（`Super + Space`）中的 _安裝 > Web App_ 加入你自己的網頁應用程式。它會詢問你應用程式名稱、應用程式 URL，以及圖示 URL（如果它無法透過 favicon 取得的話）。你可以在 [Dashboard Icons](https://dashboardicons.com) 上為許多熱門網頁應用程式取得很棒的 PNG 圖示。

然後它們就可以透過應用程式啟動器（`Super + Space`）存取，並使用漂亮的無框網頁應用程式視窗。

如果你想移除某個網頁應用程式，只要前往 Omarchy 選單中的 _移除 > Web App_ 即可。

最好在使用網頁應用程式快捷鍵之前，先使用一般瀏覽器登入你所有的帳戶。那層薄薄的包裝外框與 1password 配合得不好，所以先直接登入比較容易。

這些網頁應用程式的所有鍵盤快捷鍵都可以在 `~/.config/hypr/bindings.lua` 中更改。

當你在網頁應用程式中時，你可以用 `Shift + Alt + L` 將目前的 URL 複製到剪貼簿。

預設情況下，Omarchy 已經附帶了一系列預設應用程式：

## HEY

[HEY](https://www.hey.com/) 是一個電子郵件和行事曆服務，對於厭倦了 Gmail、Outlook 或 Apple Mail 的人來說是一個很好的替代品。它由 Omarchy 發源地 [37signals](https://37signals.com/) 製作。

你可以用 `Super + Shift + E` 啟動 HEY Email，用 `Super + Shift + Alt + E` 直接跳到撰寫新電子郵件，並用 `Super + Shift + C` 啟動 HEY Calendar。

## Basecamp

[Basecamp](https://basecamp.com/) 是一個專案管理服務，幫助小型團隊更快行動並取得更多進展。你不必把 Trello、Slack、Asana、Notion 或其他什麼的大雜燴拼湊在一起，有了 Basecamp 你就能在一個地方擁有一切。它由 Omarchy 發源地 [37signals](https://37signals.com/) 製作。

你可以使用應用程式啟動器（`Super + Space`）啟動 Basecamp

## ChatGPT

[ChatGPT](https://chatgpt.com) 是世界上最受歡迎的 AI 聊天機器人。

你可以用 `Super + Shift + A` 啟動 ChatGPT。

## Grok

[Grok](https://grok.com) 是 xAI 的聊天機器人。

你可以用 `Super + Shift + Alt + A` 啟動 Grok。

## WhatsApp

[WhatsApp](https://www.whatsapp.com/) 是世界上最受歡迎的訊息服務之一，而網頁版對 Linux 來說是一個很好的選擇。

你可以用 `Super + Shift + Alt + G` 啟動 WhatsApp。

## Google 應用程式

Google Messages、Google Photos、Google Maps 和 Google Contacts 也都作為網頁應用程式包含在內。

你可以用 `Super + Shift + Ctrl + G` 啟動 Google Messages，用 `Super + Shift + P` 啟動 Google Photos，並用 `Super + Shift + S` 啟動 Google Maps。Google Contacts 可透過應用程式啟動器（`Super + Space`）使用。

## X

X 是新聞爆發的地方。

你可以用 `Super + Shift + X` 啟動 X，並用 `Super + Shift + Alt + X` 直接開始撰寫新貼文。

## YouTube

[YouTube](https://youtube.com/) 是世界上最受歡迎的影片平台。

你可以用 `Super + Shift + Y` 啟動 YouTube。

## Zoom

[Zoom](https://zoom.us/) 是美國最受歡迎的視訊聊天系統。在全球範圍內都有很好的連線。而且沒有付費帳戶也可以舉行 40 分鐘的會議。Omarchy 包裝了 Zoom 的網頁用戶端，zoom 會議連結會直接在其中開啟。

你使用應用程式啟動器（`Super + Space`）啟動 Zoom。

## Discord

[Discord](https://discord.com/) 是大多數遊戲和開源社群聚集的地方，包括 [Omarchy 自己的社群](https://discord.gg/tXFUdasqhY)。

你使用應用程式啟動器（`Super + Space`）啟動 Discord。

## Microsoft 應用程式

選取 _安裝 > Service > Microsoft_ 可將 Outlook、Word、Excel、PowerPoint、Teams 和 OneDrive 加入為網頁應用程式。每個應用程式都有自己的啟動器並直接開啟，使用商業版 Microsoft 365 URL 和你現有的瀏覽器設定檔。它們與 Omarchy 的其他網頁應用程式一樣，在相同的瀏覽器應用程式視窗中開啟；它們不會安裝獨立的 Teams for Linux 用戶端。

用 _移除 > Service > Microsoft_ 移除整個套裝，或用 _移除 > Web App_ 移除個別應用程式。你也可以透過 _安裝 > Web App_ 只安裝你想要的應用程式。

對於政府或主權雲端，請在 `~/.local/share/applications/` 下相關啟動器（例如 `Microsoft Teams.desktop`）的 `Exec=` 行中編輯 URL，使用你的組織提供的 URL。該行中任何字面的 `%` 都寫成 `%%`。變更會在下次啟動時生效。再次執行套裝安裝程式會以預設 URL 取代其啟動器。

為了將工作登入保持分離，將一個瀏覽器資料目錄附加到每個啟動器的 `Exec=` 行：

```ini
Exec=omarchy-launch-webapp "https://teams.cloud.microsoft/" --user-data-dir=/absolute/path/to/work-browser-profile
```

將範例目錄替換為你選擇的絕對路徑，並對全部六個啟動器使用相同的路徑，以便在它們之間共享工作登入。這些網頁應用程式使用 Omarchy 所選的受支援瀏覽器，當預設瀏覽器不受支援時，會退回使用 Chromium。
