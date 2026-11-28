# 開始使用

Omarchy 使用 ISO 檔安裝。你可以在全磁碟安裝與可用空間安裝之間選擇：全磁碟安裝會佔用整台磁碟機，可用空間安裝則會把 Omarchy 裝進磁碟機上未配置的空間——這就是與 Windows 或其他作業系統並存雙重開機的做法（參見[雙重開機安裝](50-dual-boot-install.md)——請注意，你必須先在 Windows 中關閉 BitLocker）。無論選哪一種，安裝預設都會全磁碟加密，而且全磁碟選項會清除所選磁碟機，所以如果用的是既有的磁碟機，務必先備份！

在 Apple Silicon Mac 上，則是改從 macOS 安裝，不需要 ISO 或 USB 隨身碟。參見[適用於 Apple Silicon 的 Omarchy](44-mac-support.md#omarchy-for-apple-silicon)。

先[下載 Omarchy ISO](https://omarchy.org/)，把它放進 USB 隨身碟（在 Windows 上用 [Rufus](https://rufus.ie/)、在 Mac 上用 [balenaEtcher](https://etcher.balena.io/)，或在 Linux 上用 [caligula](https://github.com/ifd3f/caligula)），然後從隨身碟開機。

_你必須在 BIOS 中關閉 Secure Boot 及／或 TPM。必須關閉這些功能才能安裝 Omarchy。它們是 Microsoft 為 Windows 以及與 Microsoft 關係密切的 Linux 發行版設計的安全機制。_

接著回答設定問題，並像這樣確認：

 ![install-config](images/install-config.webp)

然後選一台要安裝的磁碟機，坐下來看安裝秀開始。最快的現代機器不到一分鐘就能完成，即使是較舊的電腦也不應該超過 5 分鐘。

 ![install-done](images/install-done.webp)

現在你準備好 Omarchy 了！

### 請使用有線或 2.4ghz 鍵盤！

全磁碟加密不允許你在啟動時用 Bluetooth 鍵盤輸入密碼。就像你沒辦法用 Bluetooth 鍵盤在 PC 上進 BIOS 一樣。你需要一把使用 2.4ghz 接收器或連接線的鍵盤（而且連接線的延遲表現好太多了！）。我個人超愛 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 為另一位擁有者安裝

如果你是在為別人設定機器——家人、新員工、買家——你不應該代替他們回答個人問題。在安裝程式的第一個畫面（鍵盤選擇）按下 `Ctrl + C`，Omarchy 就會提議改為把機器準備給另一位擁有者。系統會立即安裝，但所有個人設定——鍵盤配置、使用者名稱、密碼——都會延到機器首次開機時才進行。磁碟機預設仍然會加密，新擁有者在那次首次開機時選定的密碼，也會同時成為加密密碼。（已經在使用的機器也可以不用重新安裝就交接——參見[重設電腦](48-security.md)。）

### 無人值守安裝

把設定放在第二台磁碟機上交給 ISO，它也能完全自行安裝——不需要鍵盤、不需要精靈。這就是把 Omarchy 當作 VM 和大量部署機器基礎映像檔的做法。參見[無人值守安裝](51-unattended-installs.md)。

### 無加密安裝

Omarchy 預設會加密安裝。對任何可能遺失或被偷的電腦來說，這是安全又負責任的選擇。你不會想讓任何能碰到你硬體的人都能取得你的資料！

但在特殊情況下，像是在受保護的電腦上遠端安裝 Omarchy，或沒有敏感資料、用完即丟的安裝，你可能會想不加密安裝。你可以在磁碟格式化確認畫面按下 `Ctrl + C`，切換為無加密安裝。

### 語言

Omarchy 支援 50 種語言——與 omarchy.org 相同的一組——預設是英文。若要切換，打開 Omarchy 選單並前往 _Setup > Region > Language_，或在終端機執行 `omarchy language <code>`（`omarchy language list` 會顯示代碼）。選單、桌面和 Omarchy 自己的通知會立即切換語言，之後打開的每個應用程式也會跟著切換。已經打開的應用程式則會在你重新啟動它們後切換。

若想保留語言，但讓日期、時間、數字、金錢、單位和紙張大小改用另一地區的寫法（例如用英文搭配歐洲日期格式和 24 小時制），可在 _Setup > Region > Formats_ 下選一個地區，每個選項都會顯示範例，或執行 `omarchy region formats <code>`（`omarchy region formats list` 會顯示代碼）。_Same as language_ 會回到該語言自己的格式。和切換語言一樣，它只會影響之後打開的應用程式。

### 卡住時求助

如果你卡住了，通常可以在[社群 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 頻道找到願意幫忙的人。
