# 商業應用程式/服務

Omarchy 主要專注於提供免費、開放原始碼軟體，但並不教條。有時候最佳解決方案就是商業產品，那也完全沒問題。以下是我們提供簡易安裝方式的一些選項。

## 1Password

將密碼保存在密碼管理器中是最佳做法。如果您與團隊合作，更是如此。而 [1password](https://1password.com/) 是很棒的解決方案，它還附帶命令列工具，可將金鑰查詢整合到 script 中。

您可以使用 `Super + Shift + /` 啟動 1Password。如果尚未安裝，該快捷鍵會先啟動安裝（您也可以從 Omarchy 選單使用 _Install > Service > 1Password_）。安裝程式也會一併安裝 1Password 命令列工具，並為 Chrome 和 Chromium 設定 1Password 擴充功能；重新啟動您的瀏覽器以載入它。

## Bitwarden

[Bitwarden](https://bitwarden.com/) 是密碼管理器領域的開放原始碼替代方案，其免費方案涵蓋了大多數個人用途。從 Omarchy 選單使用 _Install > Service > Bitwarden_ 來安裝它，它也會一併帶來 Bitwarden 命令列工具。

## Spotify

[Spotify](https://spotify.com/) 是世界上最受歡迎的串流音樂服務。Omarchy 將其以 web app 形式提供，讓您擁有完整的播放器、媒體鍵和 Spotify Connect，但不支援離線下載。使用 `Super + Shift + M` 啟動它。

## Slack

[Slack](https://slack.com/) 是許多團隊聊天的地方，包括公司內部以及與外部協作者之間。從 Omarchy 選單使用 _Install > Service > Slack_ 來安裝它，它會在準備好後立即開啟。

## Notion

[Notion](https://www.notion.com/) 是用於筆記、文件和專案的工作空間。從 Omarchy 選單使用 _Install > Service > Notion_ 來安裝其桌面應用程式。

## Dropbox

[Dropbox](https://www.dropbox.com/) 是在機器之間同步檔案，同時在雲端保留備份的好方法。若要設定它，請從 Omarchy 選單選擇 _Install > Service > Dropbox_。它會在列上新增一個 Dropbox 圖示：點按它以登入，然後使用同一個面板來檢查您的儲存空間並開啟最近同步的檔案。

## Tailscale

[Tailscale](https://tailscale.com/) 是一種網狀 VPN，讓透過網際網路安全存取您所有的電腦和伺服器變得超級簡單。若要設定它，請從 Omarchy 選單選擇 _Install > Service > Tailscale_。

它會在列上獲得一個面板、一個用於管理主控台的 web app，以及用於在您的機器之間傳送檔案的 Taildrop — 請參閱[網路](35-networking.md)。

## ONCE

[ONCE](https://once.com/) 是 37signals 的軟體系列，買一次就能在您自己的伺服器上執行，例如 Campfire 聊天系統。從 Omarchy 選單選擇 _Install > Service > ONCE_ 來安裝它，它會啟用其背景服務，並將您帶入 ONCE 終端機介面，讓您從那裡接手。

## NordVPN

[NordVPN](https://nordvpn.com/) 是標準的 VPN 服務，可讓您從世界各地大多數地區出站您的流量。若要設定它，請從 Omarchy 選單選擇 _Install > Service > NordVPN_。在它要求的重新開機之後，執行 `nordvpn login` 進行身分驗證。
