# 商業應用程式／服務

Omarchy 大多專注於提供免費的開放原始碼軟體，但對這點並不迷信。有時候最好的解決方案就是商業產品，這完全沒問題。以下是我們提供簡易安裝方式的一些選項。

## 1Password

將密碼保存在密碼管理器中，是一種最佳實踐。如果是與團隊協作，這就更重要了。而 [1password](https://1password.com/) 是一個很好的解決方案，它還附帶了一個命令列工具，可將金鑰查詢整合到指令碼中。

使用 `Super + Shift + /` 啟動 1Password。如果尚未安裝，該快速鍵會先啟動安裝程序（也可以從 Omarchy 選單中使用 _Install > Service > 1Password_）。安裝程式還會一併安裝 1Password 命令列工具，並為 Chrome 和 Chromium 設定 1Password 擴充功能；重新啟動瀏覽器即可載入它。

## Bitwarden

[Bitwarden](https://bitwarden.com/) 是密碼管理器領域的開放原始碼替代方案，免費方案足以滿足大多數個人使用需求。從 Omarchy 選單中使用 _Install > Service > Bitwarden_ 安裝它，該安裝程式也會一併安裝 Bitwarden 命令列工具。

## Spotify

[Spotify](https://spotify.com/) 是全球最受歡迎的串流音樂服務。Omarchy 以 Web 應用程式的形式提供它，具備完整的播放器、媒體鍵和 Spotify Connect，但不支援離線下載。使用 `Super + Shift + M` 啟動它。

## Slack

[Slack](https://slack.com/) 是許多團隊溝通聊天的地方，不論是公司內部或是與外部合作夥伴。從 Omarchy 選單中使用 _Install > Service > Slack_ 安裝它，安裝完成後就會立即開啟。

## Notion

[Notion](https://www.notion.com/) 是一個用於筆記、文件和專案的工作空間。從 Omarchy 選單中使用 _Install > Service > Notion_ 安裝它的桌面應用程式。

## WeChat

[WeChat](https://www.wechat.com/) 是中國大多數人都在使用的訊息應用程式，用於聊天、通話，並與居住在那裡的任何人保持聯繫。從 Omarchy 選單中使用 _Install > Service > WeChat_，即可安裝 Tencent 的官方 Linux 客戶端，安裝完成後就會立即開啟。它僅適用於 x86 電腦。

## Dropbox

[Dropbox](https://www.dropbox.com/) 是在不同機器之間同步檔案，同時在雲端保存備份的好方法。若要設定它，請從 Omarchy 選單中選取 _Install > Service > Dropbox_。它會在工具列中新增一個 Dropbox 圖示：點擊該圖示登入，然後使用同一個面板檢查您的儲存空間並開啟最近同步的檔案。

## Tailscale

[Tailscale](https://tailscale.com/) 是一款網格 VPN，讓您透過網際網路安全且極其簡單地存取您所有的電腦和伺服器。若要設定它，請從 Omarchy 選單中選取 _Install > Service > Tailscale_。

它會在工具列中獲得一個面板、一個用於管理主控台的 Web 應用程式，以及用於在您的機器之間傳送檔案的 Taildrop——請參閱 [networking](35-networking.md)。

## ONCE

[ONCE](https://once.com/) 是 37signals 的軟體系列，採一次買斷方式，您可以將其執行在自己的伺服器上，例如 Campfire 聊天系統。從 Omarchy 選單中選取 _Install > Service > ONCE_ 來安裝它，安裝後會啟用它的背景服務，並帶您進入 ONCE 終端機介面以便從那裡繼續操作。

## NordVPN

[NordVPN](https://nordvpn.com/) 是一項標準 VPN 服務，可讓您的流量從全球大多數地區退出。若要設定它，請從 Omarchy 選單中選取 _Install > Service > NordVPN_。在它要求重新開機之後，執行 `nordvpn login` 進行驗證。
