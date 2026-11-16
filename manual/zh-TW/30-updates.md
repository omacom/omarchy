# 更新

Omarchy 與你的套件會透過 Omarchy 選單（`Super + Space`）中的 _Update > Omarchy_ 保持在最新狀態。

Omarchy 本身是以一般的 pacman 套件形式，從 [Omarchy 套件儲存庫](https://github.com/omacom-io/omarchy-pkgs) 安裝的，因此一次更新會安裝 [最新的 Omarchy 發行版](https://github.com/omacom/omarchy/releases)、執行任何尚未完成的遷移，讓你的系統與最新版本同步，並從 [Omarchy Arch 鏡像站](https://github.com/omacom-io/omarchy-mirror) 與 [AUR](https://aur.archlinux.org/) 更新所有系統套件（如果你有安裝任何 AUR 套件的話）。

有新版本發行時，時鐘右側會出現一個圓形箭頭圖示。點一下它，更新程序就會開始。

![update-available](images/update-available.webp)

### 四個頻道

Omarchy 透過四個頻道更新：stable、RC、edge 和 dev。新安裝的系統會從 stable 頻道開始，它追蹤 [官方發行版](https://github.com/omacom/omarchy/releases/)，以及 [stable Omarchy Arch 鏡像站](https://github.com/omacom-io/omarchy-mirror)，後者會比最新版本落後一個月，這樣我們就能在任何需要修改設定的新版不相容問題給使用者造成麻煩之前，先把它抓出來。

但如果你想幫忙找出那些潛在問題，你可以改用 edge 頻道。這會讓你的 Omarchy 套件追蹤最新的開發版組建，並讓你在最新 Arch 套件一推出時就能更新。只有在你熟悉 Linux，而且知道如何復原出問題的系統時，才應該這麼做。

在任何新的主要版本發行之前，我們會用 RC 頻道做最後驗證。如果你有興趣幫忙做最後的打磨，歡迎到 Discord 上的 #omarchy-release-candidates 頻道來聊聊。

最後是 dev 頻道，它會把 Omarchy 直接連結到 `~/omarchy` 中以 git 檢出的原始碼，並搭配 edge 套件。只有在你是經驗豐富的 Linux 使用者、直接參與 Omarchy 開發，而且願意容忍系統損壞時，才應該使用這個頻道。

你可以使用 Omarchy 選單中的 _Update > Channel_ 來切換頻道（或在終端機中執行 `omarchy-channel-set`）。

### 切換核心

Omarchy 會以它自己的 `linux-omarchy` 核心開機，但你可以同時安裝其他核心，例如 Arch 原廠的 `linux` 核心，或你正在測試的實驗版組建。當有一個以上核心時，Omarchy 選單中的 _Update > Kernel_ 會列出它們，並在預設開機的那個旁邊打勾。選另一個、輸入一次密碼，它就會在下次重新啟動後開機。其他核心會留在開機選單中，所以如果新的預設核心給你惹了麻煩，你還是可以手動選一個。在終端機中，用 `omarchy-kernel` 查看目前的預設核心，用 `omarchy-kernel list` 查看已安裝的核心，用 `omarchy-kernel set <kernel>` 進行切換。

### 韌體更新

會過期的不只是你的套件。許多筆電和周邊裝置會透過 Linux Vendor Firmware Service 提供 BIOS、SSD 和擴充基座韌體，而 Omarchy 選單中的 _Update > Firmware_ 會取得並安裝你的硬體正在等待的任何韌體。第一次執行時，它會安裝 `fwupd`。許多韌體只能在重新開機時寫入，所以被要求重新開機時不要感到意外。

當你需要更改 BIOS 本身的設定時，在系統選單（`Super + Escape`）中按住 `Alt`，_Reboot_ 就會變成 _Reboot to BIOS_，它會直接重新啟動進入韌體設定，不用在開機時搶按正確的按鍵。在終端機中，指令是 `omarchy system firmware`。

### 關於直接用 pacman/yay 更新的警告

如果你已經熟悉 Arch，你可能會忍不住自己直接執行 `pacman -Syu` 或 `yay -Syu`，但如果你這麼做，就會錯過 Omarchy 在更新套件時一併執行的快照、遷移和設定更新。這就是為什麼 Omarchy 實際上會阻止直接進行系統升級，改而指引你使用 `omarchy update`。（如果你真的知道自己在做什麼，這道防護會告訴你如何就單次交易繞過它。）

### 還原有問題的更新

如果你更新後遇到任何問題，你可以將系統還原到更新前建立的快照。只要重新啟動，並在開機載入選單中選擇你開始更新之前的快照就可以了。

![bootloader](images/bootloader.webp)

如果你的設定檔因故損壞，你也可以在終端機中使用 `omarchy reinstall` 重新安裝 Omarchy。這會重新安裝所有預設的 Omarchy 套件、把你切回 stable、降級任何版本過新的套件，並重設所有設定檔。請注意，這麼做會覆寫你對 Omarchy 預設值所做的所有使用者設定變更！
