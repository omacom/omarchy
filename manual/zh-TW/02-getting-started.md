# 開始使用

Omarchy 使用 ISO 來安裝。你可以選擇全磁碟安裝，也就是接管整個磁碟機；或是空閒空間安裝，也就是把 Omarchy 裝進磁碟機上未配置的空間——這就是與 Windows 或其他作業系統並存雙重開機的方式（請參閱 [雙重開機安裝](50-dual-boot-install.md)——請注意，你必須先在 Windows 中關閉 BitLocker）。無論選哪一種，安裝預設都會使用完整加密，而全磁碟選項會清除所選磁碟機的內容，所以使用現有磁碟機之前，務必先做好備份！

先[下載 Omarchy ISO](https://omarchy.org/)，把它放進 USB 隨身碟（在 Windows 上使用 [Rufus](https://rufus.ie/)，在 Mac 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然後從隨身碟開機。

_你必須在 BIOS 中關閉 Secure Boot 和/或 TPM。你必須關閉這些功能，才能安裝 Omarchy。它們是 Microsoft 為 Windows 和與 Microsoft 有關聯的 Linux 發行版設計的安全機制。_

接著回答設定問題，並像這樣確認：

 ![install-config](images/install-config.webp)

然後選擇要用來安裝的磁碟機，放輕鬆看這場安裝秀進行。在最快的現代機器上，不到一分鐘就能完成；即使是較舊的電腦，也不應該花超過 5 分鐘。

 ![install-done](images/install-done.webp)

現在你準備好使用 Omarchy 了！

### 使用有線或 2.4ghz 鍵盤！

全磁碟加密不允許你在開機時用藍牙鍵盤輸入密碼。就像在 PC 上你沒辦法用藍牙鍵盤進 BIOS 一樣。你需要一把使用 2.4ghz 接收器的鍵盤，或是有線鍵盤（而且延遲表現好太多了！）。我個人非常喜歡 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 為另一位擁有者安裝

如果你是在為別人設定機器——家人、新員工、買家——你不應該代替他們回答個人問題。在安裝程式的第一個畫面（鍵盤選擇）按下 `Ctrl + C`，Omarchy 就會改為提供為另一位擁有者準備機器的選項。系統會立刻安裝，但所有個人設定——鍵盤配置、使用者名稱、密碼——都會延後到機器第一次開機時才進行。磁碟機預設仍然會加密，而新擁有者在第一次開機時選定的密碼，也會同時成為加密密碼。（你已經在使用的機器也可以不用重新安裝就交給別人——請參閱 [重置電腦](48-security.md)。）

### 無人值守安裝

當設定放在第二個磁碟機上交給 ISO 時，它也能完全自行安裝——不需要鍵盤，不需要安裝精靈。這就是把 Omarchy 當作 VM 和整批機器基礎映像檔的做法。請參閱[無人值守安裝](51-unattended-installs.md)。

### 不加密安裝

Omarchy 預設安裝時會加密。對於任何有可能遺失或被偷的電腦來說，這是安全、負責任的選擇。你不會希望任何能接觸到你硬體的人都能取得你的資料！

但在特殊情況下，例如在受保護的電腦上遠端安裝 Omarchy，或是沒有敏感資料、用完即丟的安裝環境，你可能會想不加密安裝。你可以在磁碟格式化確認時按下 `Ctrl + C`，切換成不加密安裝。

### 語言

Omarchy 支援 50 種語言——和 omarchy.org 相同的語言集合——預設是英文。若要切換，請開啟 Omarchy 選單，前往 _設定 > 語言_，或在終端機中執行 `omarchy language <code>`（`omarchy language list` 會顯示代碼）。選單、桌面和 Omarchy 自己的通知會立即切換語言，之後開啟的每個應用程式也會跟著切換。已經開啟的應用程式，重新啟動後就會切換。

### 卡住了需要求助

如果你卡住了，通常可以在[社群 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 頻道找到願意幫忙的人。
