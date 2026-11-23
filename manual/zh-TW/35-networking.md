# 網路

Omarchy 的網路由 NetworkManager 處理，你可以從[頂部列](05-the-top-bar.md)中的網路圖示操作，或是按下 `Super + Ctrl + N`。

該面板會掃描 Wi-Fi 網路、顯示訊號強度，並進行連線。乙太網路完全不需要任何設定 — 插上線就能用。如果你比較想待在終端機裡，`nmtui` 提供相同的控制功能，另外也有 `omarchy network` 指令群組。

## 分享你的 Wi-Fi

不用把一長串密碼唸出來，只要連著 Wi-Fi 時執行 _Setup > Network > QR Code_。畫面上就會出現一個 QR code，任何手機相機掃一下就能加入。知道了有這個功能之後，你會發現自己用它的次數比預想中還多。

如果你真的需要密碼本身，`omarchy network password <interface>` 會把它列印出來。

## DNS

Omarchy 會使用你的網路透過 DHCP 發放的 DNS。你可以在 _Setup > Network > DNS_ 為整台機器覆寫這個設定，Cloudflare 和 Google 都只要點一下就能選用。選 _Custom_ 則可輸入你自己的伺服器。

在終端機中，`omarchy dns` 會列印目前的供應商，而 `omarchy dns Cloudflare` 則可設定一個。

## 固定 Wi-Fi 頻段

如果你的路由器把 2.4GHz、5GHz 和 6GHz 放在同一個網路名稱下，你的筆電有時會死守著慢的那個不放。`omarchy network band` 會顯示你目前所在的頻段，而 `omarchy network band 5` 則可將它固定。使用 `auto` 就能讓它重新自動選擇。

這固定的是頻段，而不是某個特定的存取點，所以你依然可以在各個 AP 之間正常漫遊。

## 到底有多快？

_Trigger > Speed Test > Network Speed Test_ 會用一對錶盤測量你實際的上傳與下載速度。在終端機中則是 `omarchy network speedtest down` 或 `up`。它測量的是連往 Omarchy 自家服務的速度，而且只計算它自己的測試傳輸。其他的下載可能會搶頻寬，但不會被計入測速結果。（如果你想測的是另一個瓶頸，那個選單裡它旁邊還有一個磁碟速度測試。）

## 防火牆

防火牆預設開啟，並阻擋所有連入流量，只有一個例外：53317 埠，好讓 [LocalSend](22-guis.md) 開箱即用。

SSH 是關閉的，直到你用 _Setup > Security > SSHD_ 把它開啟為止；那會啟動守護程序、開啟 22 埠並對其進行速率限制以防止暴力破解，還會授權一把金鑰。Docker 也同樣受到嚴格管制，所以容器不會不小心把自己暴露到全世界面前。完整的來龍去脈請見[安全性](48-security.md)。

## Tailscale

[Tailscale](https://tailscale.com/) 是一個網狀 VPN，讓你透過網際網路連上你所有的電腦和伺服器變得簡單又安全。用 _Install > Service > Tailscale_ 來安裝它。

安裝後，頂部列會多出一個 Tailscale 面板，可以連線和中斷 tailnet、切換帳號，以及選擇出口節點 — 你自己的機器和 Mullvad 地區都會出現在清單中。它也能瀏覽你的機器，而 Taildrop 就住在那裡：選一台機器，按 `s` 就能把檔案傳給它，或按 `c`、`n` 和 `d` 來複製它的 IP、名稱或完整 DNS 名稱。終端機的等效指令是 `omarchy tailscale send <machine> [file...]`，而別人傳給你的檔案會自動落到 `~/Downloads`。通知你有檔案抵達的那則通知會一直等到你點開或將它關閉為止，所以即使檔案是在你離開機器時送到的，你回來時它也還在那裡等你回應。

安裝它還會新增一個 Tailscale 管理主控台的網頁應用程式。

## 當它罷工時

在重開機之前，先試著單獨重啟出問題的那個部分。_Update > Hardware_ 裡有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新載入其中一個，就能解決大多數「五分鐘前明明還好好的」的狀況。請見[疑難排解](45-troubleshooting.md)。
