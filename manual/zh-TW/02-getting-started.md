# 開始使用

Omarchy 使用 ISO 安裝。你可以選擇整顆磁碟安裝，接管整顆磁碟機；或是可用空間安裝，將 Omarchy 裝入磁碟機的未配置空間——你就是這樣與 Windows 或其他作業系統並存雙重開機的（參見[雙重開機安裝](50-dual-boot-install.md)——請注意，你需要先在 Windows 中關閉 BitLocker）。無論哪一種，安裝預設都會進行完整加密，而且整顆磁碟選項會清除所選磁碟機的內容，所以使用現有磁碟機前，請務必先備份！

先[下載 Omarchy ISO](https://omarchy.org/)，將它寫入 USB 隨身碟（在 Windows 上使用 [Rufus](https://rufus.ie/)，在 Mac 上使用 [balenaEtcher](https://etcher.balena.io/)，在 Linux 上使用 [caligula](https://github.com/ifd3f/caligula)），然後從隨身碟開機。

_你必須在 BIOS 中關閉 Secure Boot 和／或 TPM。你必須關閉這些功能才能安裝 Omarchy。它們是 Microsoft 為 Windows 以及與 Microsoft 有關聯的 Linux 發行版設計的安全機制。_

接著回答設定問題，並像這樣確認：

 ![install-config](images/install-config.webp)

接著選擇安裝用的磁碟機，然後坐下來欣賞安裝秀吧。在最快的現代機器上，不到一分鐘就能完成；即使是較舊的電腦，也不應該花超過 5 分鐘。

 ![install-done](images/install-done.webp)

現在你準備好開始用 Omarchy 了！

### 使用有線或 2.4ghz 鍵盤！

完整磁碟加密在開機時不允許你用藍牙鍵盤輸入密碼。就像你無法在 PC 上用藍牙鍵盤進入 BIOS 一樣。你需要一把使用 2.4ghz 接收器的鍵盤，或是有線鍵盤（無論如何，延遲表現都好得多！）。我個人非常喜愛 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)！

### 為另一位擁有者安裝

如果你是在為別人設定機器——家人、新員工、買家——你不應該替他們回答個人問題。在安裝程式的第一個畫面（鍵盤選擇）按下 `Ctrl + C`，Omarchy 就會改為提供為另一位擁有者準備機器的選項。系統會立即安裝，但所有個人設定——鍵盤配置、使用者名稱、密碼——都會延後到機器首次開機時才進行。磁碟機仍預設加密，而新擁有者在首次開機時選定的密碼，也會同時成為加密密碼。（你已經在使用的機器也可以不重新安裝就交接——參見[重設電腦](48-security.md)。）

### 無人值守安裝

當第二顆磁碟機上提供設定時，這個 ISO 也能完全自行安裝——不需要鍵盤、不需要精靈。這就是將 Omarchy 作為 VM 與機群機器的基礎映像檔的做法。參見[無人值守安裝](51-unattended-installs.md)。

### 不加密的安裝

Omarchy 預設以加密方式安裝。對於任何可能遺失或被竊的電腦，這是安全、負責任的選擇。你不會希望任何能接觸到你硬體的人都能取得你的資料！

但在特殊情況下，例如在受保護電腦上遠端安裝 Omarchy，或是安裝不含敏感資料、用完即丟的系統，你可能會想不加密安裝。你可以在磁碟格式化確認畫面按下 `Ctrl + C`，切換為不加密的安裝。

### 語言

Omarchy 支援 50 種語言——與 omarchy.org 相同的語言組合——並以英文為預設語言。若要切換，請開啟 Omarchy 選單並前往 _設定 > 地區 > 語言_，或在終端機中執行 `omarchy language <code>`（`omarchy language list` 會顯示語言代碼）。選單、桌面與 Omarchy 自己的通知會立即切換語言，之後開啟的每個應用程式也會跟著切換。已經開啟的應用程式則會在你重新啟動它們後切換。

若要保留語言，但以另一個地區的方式呈現日期、時間、數字、金額、單位與紙張大小（例如使用英文，但採用歐洲日期格式與 24 小時制），請在 _設定 > 地區 > 格式_ 下選擇地區，每個選項都會顯示範例，或執行 `omarchy region <code>`（`omarchy region list` 會顯示地區代碼）。_與語言相同_ 會回到該語言本身的格式。如同切換語言，這也會套用到你之後開啟的應用程式。

### 卡住時求助

如果你卡住了，通常可以在[社群 Discord](https://omarchy.org/discord) 的 _#omarchy-help_ 頻道中找到願意協助的人。
