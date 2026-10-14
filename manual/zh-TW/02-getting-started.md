# 開始使用

Omarchy 是透過 ISO 安裝的。你可以選擇完整磁碟安裝，將整個磁碟全部接管；或是可用空間安裝，將 Omarchy 裝進磁碟上未配置的空間——這就是與 Windows 或其他作業系統並存雙重開機的方式（請參閱[雙重開機安裝](50-dual-boot-install.md)——請注意，你需要先在 Windows 中關閉 BitLocker）。無論選擇哪種方式，安裝預設都會使用完整加密，而完整磁碟選項會清除所選磁碟的全部內容，所以使用現有磁碟前，務必先備份！

先[下載 Omarchy ISO](https://omarchy.org/)，把它寫入 USB 隨身碟（在 Mac/Windows 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然後從隨身碟開機。

_你必須在 BIOS 中關閉 Secure Boot 和／或 TPM。你必須關閉它們，才能安裝 Omarchy。它們是為 Windows 和與 Microsoft 有關聯的 Linux 發行版而設計的 Microsoft 安全機制。_

接著回答設定問題，並像這樣確認它們：

 ![install-config](images/install-config.webp)

然後選擇要安裝的磁碟，坐下來看安裝好戲上場。在最快的現代機器上，不到一分鐘就能完成；即使是較舊的電腦，也不應該超過 5 分鐘。

 ![install-done](images/install-done.webp)

現在你已準備好 Omarchy 了！

### 使用有線或 2.4ghz 鍵盤！

完整磁碟加密不允許你在啟動時用 Bluetooth 鍵盤輸入密碼。就像你不能用 Bluetooth 鍵盤在 PC 上進入 BIOS 一樣。你需要一把使用 2.4ghz 接收器或連接線的鍵盤（無論如何，這對延遲也好得多！）。我個人非常喜歡 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 為另一位擁有者安裝

如果你正在為別人設定機器——家人、新員工、買家——你就不應該代替他們回答個人問題。在安裝程式的第一個畫面（鍵盤選擇）按 `Ctrl + C`，Omarchy 就會提供改為另一位擁有者準備機器的選項。系統會立即安裝，但所有個人設定——鍵盤配置、使用者名稱、密碼——都會延後，直到機器第一次開機時才進行。磁碟依舊預設加密，新擁有者在第一次開機時選擇的密碼也會同時成為加密密碼。（你已經在使用中的機器也可以不重新安裝就交接——請參閱[重設電腦](48-security.md)。）

### 無人值守安裝

當透過第二個磁碟把設定交給 ISO 時，它也能完全自行安裝——不需要鍵盤，也不需要精靈。這就是把 Omarchy 當作 VM 和機隊機器的基礎映像來使用的方法。請參閱[無人值守安裝](51-unattended-installs.md)。

### 不加密的安裝

Omarchy 預設安裝時會加密。對於任何有可能遺失或被偷的電腦來說，這都是安全且負責任的選擇。你絕不希望任何能接觸到你硬體的人都能取得你的資料！

但在特殊情況下，例如在受保護的電腦上遠端安裝 Omarchy，或是沒有敏感資料的拋棄式安裝，你可能會想不加密安裝。你可以在磁碟格式化確認畫面上按 `Ctrl + C`，切換到不加密的安裝方式。

### 語言

Omarchy 支援 50 種語言——與 omarchy.org 相同的一組語言——預設為英文。若要切換，請開啟 Omarchy 選單並前往 _Setup > Language_，或在終端機中執行 `omarchy language <code>`（`omarchy language list` 會顯示各語言代碼）。選單、桌面和 Omarchy 自己的通知會立即切換語言，之後你開啟的每個應用程式也會跟著切換。已經開啟的應用程式，重新啟動後就會切換。

### 卡住時的求助管道

如果你卡住了，通常可以在[社群 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 頻道找到願意幫忙的人。
