# 網路

Omarchy 的網路由 NetworkManager 處理，你可以從[選單列](05-the-top-bar.md)的網路圖示操作，或使用快捷鍵 `Super + Ctrl + W`。

該面板會掃描 Wi-Fi 網路、顯示訊號強度並進行連線。乙太網路則完全不用設定——插上就能用。如果你比較喜歡留在終端機裡，`nmtui` 提供相同的控制功能，另外還有 `omarchy network` 指令群組。

## 分享你的 Wi-Fi

不用再大聲唸出一長串密碼，只要在連上 Wi-Fi 時執行 _設定 > 網路 > QR 碼_，螢幕上就會出現一個 QR 碼，任何手機相機掃描後即可加入。一旦你知道有這個功能，就會發現自己比預期更常用到它。

如果你真的需要密碼本身，`omarchy network password <interface>` 會把它印出來。

## DNS

Omarchy 使用你的網路透過 DHCP 提供的 DNS。你可以在 _設定 > 網路 > DNS_ 為整台機器覆寫這個設定，Cloudflare 和 Google 都只要點一下即可。選擇 _自訂_ 可以輸入你自己的伺服器。

在終端機中，`omarchy dns` 會印出目前的提供者，`omarchy dns Cloudflare` 則可設定提供者。

## 鎖定 Wi-Fi 頻段

如果你的路由器把 2.4GHz、5GHz 和 6GHz 放在同一個網路名稱下，你的筆電有時會賴在慢的那個頻段上。`omarchy network band` 會顯示你目前所在的頻段，`omarchy network band 5` 則可將它鎖定。使用 `auto` 可讓它重新自動選擇。

這是鎖定頻段而不是特定的基地台，所以你還是可以正常在不同 AP 之間漫遊。

## 速度有多快？

_觸發 > 測速 > 網路測速_ 會用一對儀表量測你實際的上傳與下載速度。在終端機中則是 `omarchy network speedtest down` 或 `up`。（同一個選單裡旁邊還有磁碟測速，如果你正在測量另一個瓶頸的話。）

## 防火牆

防火牆預設開啟，並阻擋所有傳入流量，只有一例外：連接埠 53317，讓 [LocalSend](22-guis.md) 開箱即用。

SSH 預設關閉，直到你用 _設定 > 安全性 > SSHD_ 將它開啟，它會啟動守護程式、開啟連接埠 22（並以速率限制防止暴力破解），以及授權一把金鑰。Docker 也被鎖得很緊，所以容器不會不小心把自己暴露給全世界。完整說明請參閱[安全性](48-security.md)。

## Tailscale

[Tailscale](https://tailscale.com/) 是一個網狀 VPN，讓你透過網際網路連到所有電腦和伺服器變得簡單又安全。用 _安裝 > 服務 > Tailscale_ 安裝它。

安裝後，選單列會多出一個 Tailscale 面板，可連接和中斷 tailnet、切換帳號，以及挑選出口節點——你自己的機器和 Mullvad 的地區都會出現在清單中。它也能瀏覽你的機器，而 Taildrop 就在這裡：選一台機器，按 `s` 傳送檔案給它，或按 `c`、`n` 和 `d` 複製它的 IP、名稱或完整 DNS 名稱。終端機的等效指令是 `omarchy tailscale send <machine> [file...]`，而別人傳給你的檔案會自動落在 `~/Downloads`。宣佈檔案到達的通知會一直等到你點開或關閉它，所以在你離開機器時送達的檔案，回來時還在那裡等你處理。

安裝它也會加上一個 Tailscale 管理主控台的 web app。

## 當它停止運作時

重新開機之前，先試著單獨重新啟動出問題的那個部分。_更新 > 硬體_ 有 Wi-Fi、藍牙、音訊和觸控板，重新載入其中之一可以解決大多數「五分鐘前還好好的」狀況。請參閱[疑難排解](45-troubleshooting.md)。
