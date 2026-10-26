# 網路

Omarchy 的網路由 NetworkManager 處理，你可以從[頂部列](05-the-top-bar.md)的網路圖示操作，或使用 `Super + Ctrl + N`。

該面板會掃描 Wi-Fi 網路、顯示訊號強度並進行連線。Ethernet 完全不需要任何設定——插上就能用。如果你更想待在終端機裡，`nmtui` 提供相同的控制功能，另外還有 `omarchy network` 指令群組可用。

## 分享你的 Wi-Fi

不必把一長串密碼唸出聲，只要在連上 Wi-Fi 時執行 _Setup > Network > QR Code_ 就好。畫面上會顯示一個 QR Code，任何手機相機掃描後就能加入。這是那種一旦知道存在，就會比預期更常用到的功能。

如果你真的需要密碼本身，`omarchy network password <interface>` 會把它印出來。

## DNS

Omarchy 會使用你的網路透過 DHCP 發放的 DNS。你可以在 _Setup > Network > DNS_ 下為整台機器覆寫這項設定，Cloudflare 和 Google 都只要點一下就能選用。選擇 _Custom_ 則可輸入你自己的伺服器。

在終端機中，`omarchy dns` 會印出目前的供應商，而 `omarchy dns Cloudflare` 會設定其中一個。

## 鎖定 Wi-Fi 頻段

如果你的路由器把 2.4GHz、5GHz 和 6GHz 放在同一個網路名稱下，你的筆電有時會死守著慢的那個不放。`omarchy network band` 會顯示你目前在哪個頻段，而 `omarchy network band 5` 會把它鎖定。使用 `auto` 可讓它重新自行選擇。

這鎖定的是頻段，而不是特定的存取點，因此你仍可正常在各 AP 之間漫遊。

## 到底有多快？

_Trigger > Speed Test > Network Speed Test_ 會用一對錶盤測量你實際的上傳與下載速度。在終端機中則是 `omarchy network speedtest down` 或 `up`。（那個選單裡旁邊還有一個磁碟速度測試，如果你要測的是另一個瓶頸的話。）

## 防火牆

防火牆預設開啟，並封鎖所有傳入流量，只有一個例外：port 53317，讓 [LocalSend](22-guis.md) 開箱即用。

SSH 是關閉的，直到你用 _Setup > Security > SSHD_ 把它開啟為止；這會啟動該 daemon、開啟 port 22 並限制速率以防範暴力破解，同時授權一把金鑰。Docker 也同樣受到嚴格管控，因此 container 不會不小心把自己暴露到全世界。完整說明請見[安全性](48-security.md)。

## Tailscale

[Tailscale](https://tailscale.com/) 是一個 mesh VPN，讓你透過網際網路連上你所有的電腦和伺服器變得簡單又安全。用 _Install > Service > Tailscale_ 安裝它。

安裝後，頂部列會多出一個 Tailscale 面板，可用來連線和中斷 tailnet、切換帳號，以及選擇 exit node——你自己的機器和 Mullvad 地區都會出現在清單中。它也能瀏覽你的機器，而 Taildrop 就在那裡：選一台機器，按 `s` 傳送檔案給它，或按 `c`、`n` 和 `d` 複製它的 IP、名稱或完整 DNS 名稱。終端機的等效指令是 `omarchy tailscale send <machine> [file...]`，而傳給你的檔案會自動落在 `~/Downloads`。通知你檔案送達的通知會一直等到你點開或關閉它為止，所以當你不在機器旁時送達的檔案，等你回來時仍會在那裡等你處理。

安裝它還會新增一個 Tailscale 管理主控台的 web app。

## 當它停止運作時

重新開機之前，先試著單獨重新啟動出問題的那個部分。_Update > Hardware_ 裡有 Wi-Fi、Bluetooth、Audio 和 Trackpad，重新載入其中一個就能解決大多數「五分鐘前明明還好好的」狀況。請見[疑難排解](45-troubleshooting.md)。
