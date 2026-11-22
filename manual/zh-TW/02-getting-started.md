# 開始使用

Omarchy 使用 ISO 進行安裝。你可以選擇全磁碟安裝，也就是接管整顆硬碟，或是空閒空間安裝，也就是把 Omarchy 放進硬碟上未配置的空間——這就是與 Windows 或其他作業系統雙重開機的做法（請參閱[雙重開機安裝](50-dual-boot-install.md)——請注意，你需要先在 Windows 中關閉 BitLocker）。無論哪種方式，安裝預設都會使用完整加密，而全磁碟選項會抹除所選硬碟，所以使用現有硬碟前，務必先做好備份！

先[下載 Omarchy ISO](https://omarchy.org/)，把它放進 USB 隨身碟（在 Windows 上使用 [Rufus](https://rufus.ie/)，在 Mac 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然後從隨身碟開機。

_你必須在 BIOS 中關閉 Secure Boot 和／或 TPM。你必須關閉這些功能才能安裝 Omarchy。它們是 Microsoft 為 Windows 和 Microsoft 相關 Linux 發行版設計的安全機制。_

接著回答設定問題，並像這樣確認：

 ![install-config](images/install-config.webp)

然後為安裝選擇一顆硬碟，坐下來看安裝秀進行。在最快的現代機器上，不到一分鐘就能完成，但即使是較舊的電腦，也不應該花超過 5 分鐘。

 ![install-done](images/install-done.webp)

現在你準備好使用 Omarchy 了！

### 使用有線或 2.4ghz 鍵盤！

全磁碟加密不允許你在開機時從藍牙鍵盤輸入密碼。就像你無法使用藍牙鍵盤在 PC 上進入 BIOS 一樣。你需要一把使用 2.4ghz 接收器或傳輸線的鍵盤（而且就延遲而言，傳輸線也好得多！）。我個人很愛 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 為另一位擁有者安裝

如果你是為別人設定機器——家人、新員工、買家——你不應該代替他們回答個人問題。在安裝程式的第一個畫面（鍵盤選擇）按下 `Ctrl + C`，Omarchy 就會提議改為把機器準備給另一位擁有者。系統會立即安裝，但所有個人設定——鍵盤配置、使用者名稱、密碼——都會延後到機器第一次開機時才進行。硬碟預設仍會加密，而新擁有者在第一次開機時選擇的密碼，也會同時成為加密密碼。（已經使用過的機器也可以不用重新安裝就交接——請參閱[重設電腦](48-security.md)。）

### 無人值守安裝

當 ISO 從第二顆硬碟取得設定時，它也可以完全自行安裝——不需要鍵盤，不需要精靈。這是把 Omarchy 當作 VM 和機隊機器基礎映像檔的做法。請參閱[無人值守安裝](51-unattended-installs.md)。

### 無加密安裝

Omarchy 預設安裝時會加密。對於任何可能遺失或被偷的電腦來說，這是安全、負責任的選擇。你不會希望任何能碰到你硬體的人都能取得你的資料！

但在特殊情況下，例如在受保護的電腦上遠端安裝 Omarchy，或是沒有敏感資料、用完即丟的安裝，你可能會想在不加密的情況下安裝。你可以在磁碟格式化確認時按下 `Ctrl + C`，切換成無加密安裝。

### 語言

Omarchy 支援 50 種語言——與 omarchy.org 相同的集合——而 English 是預設語言。若要切換，請開啟 Omarchy 功能表並前往 _Setup > Region > Language_，或在終端機中執行 `omarchy language <code>`（`omarchy language list` 會顯示代碼）。功能表、桌面和 Omarchy 自己的通知會立即變更語言，之後開啟的每個應用程式也會跟著變更。已經開啟的應用程式會在你重新啟動它們後切換。

若要保留語言，但以另一個地區的方式撰寫日期、時間、數字、金錢、單位和紙張大小（例如使用歐洲日期格式和 24 小時制的 English），請在 _Setup > Region > Formats_ 下選擇一個地區，那裡每個選項都會顯示範例，或執行 `omarchy region formats <code>`（`omarchy region formats list` 會顯示代碼）。_Same as language_ 會回到語言本身的格式。與切換語言一樣，它會影響你之後開啟的應用程式。

### 卡住時的求助管道

如果你卡住了，通常可以在[社群 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 頻道找到願意協助的人。
