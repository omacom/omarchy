# 更新

Omarchy 與你的套件可透過 Omarchy 選單中的 _Update > Omarchy_（`Super + Space`）保持在最新狀態。

Omarchy 本身是以一般的 pacman 套件形式，從 [Omarchy 套件儲存庫](https://github.com/omacom-io/omarchy-pkgs) 安裝，因此更新時會安裝 [最新的 Omarchy 版本](https://github.com/omacom/omarchy/releases)，執行所有待處理的遷移，讓你的系統與最新版本同步，並從 [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) 與 [AUR](https://aur.archlinux.org/) 更新所有系統套件（如果你有安裝任何 AUR 套件）。

當新版本發布時，時鐘右側會出現一個圓形箭頭圖示。點擊它，更新程序就會開始。

![update-available](images/update-available.webp)

### 四個頻道

Omarchy 透過四個頻道更新：stable、RC、edge 和 dev。新安裝會從 stable 頻道開始，該頻道追蹤 [官方版本](https://github.com/omacom/omarchy/releases/)，以及落後最新版本一個月的 [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror)，如此我們就能在任何需要變更設定的新不相容問題造成大家困擾之前，先行發現。

但如果你想協助找出這些潛在問題，可以使用 edge 頻道。這會讓你的 Omarchy 套件追蹤最新的開發版本，並讓你在 Arch 套件一推出時就能更新到最新版。只有在你經驗豐富、熟悉 Linux，而且知道如何復原出問題的系統時，才應該這樣做。

在任何新的主要版本發布之前，我們會使用 RC 頻道進行最終驗證。如果你有興趣協助做最後的打磨，歡迎來 Discord 的 #omarchy-release-candidates 頻道一起參與。

最後還有 dev 頻道，它會將 Omarchy 直接連結到 `~/omarchy` 中原始碼的 git checkout，並搭配 edge 套件。只有在你是有經驗的 Linux 使用者、直接參與 Omarchy 開發，且願意容忍損壞時，才應該使用這個頻道。

你可以使用 Omarchy 選單中的 _Update > Channel_ 在各頻道之間切換（或在終端機中使用 `omarchy channel set <stable|rc|edge|dev>`，並以 `omarchy channel current` 查看你目前所在的位置）。

### 切換核心

Omarchy 使用它自己的 `linux-omarchy` 核心開機，但你可以在旁邊同時安裝並保留其他核心，例如原廠 Arch 的 `linux` 核心，或你正在測試的實驗版本。當不只安裝一個核心時，Omarchy 選單中的 _Update > Kernel_ 會列出它們，並在預設開機的那個旁邊打勾。選另一個，輸入一次密碼，它就會在下次重新啟動後開機。其他核心仍會保留在開機選單中，所以如果新的預設核心讓你遇到麻煩，你還是可以手動選一個。有關終端機操作，`omarchy kernel` 可查看目前的預設核心，`omarchy kernel list` 可查看已安裝的核心，`omarchy kernel set <kernel>` 則用來切換。

### 韌體更新

會過期的不只有你的套件。許多筆記型電腦和周邊設備會透過 Linux Vendor Firmware Service 提供 BIOS、SSD 和擴充座韌體，而 Omarchy 選單中的 _Update > Firmware_ 會取得並安裝你的硬體正在等待的所有更新。它會在你第一次執行時安裝 `fwupd`。許多韌體只能在重新啟動期間寫入，所以如果被要求重新啟動，不要感到意外。

當你需要變更 BIOS 本身的設定時，在系統選單（`Super + Escape`）中按住 `Alt`，_Reboot_ 就會變成 _Reboot to BIOS_，它會直接重新啟動並進入韌體設定，而不必在開機時抓準時機按下正確的按鍵。在終端機中，這是 `omarchy system firmware`。

### 關於直接用 pacman/yay 更新的警告

如果你已經熟悉 Arch，你可能會想自己直接執行 `pacman -Syu` 或 `yay -Syu`，但如果你這樣做，你將錯過 Omarchy 隨同新套件一起執行的快照、遷移和設定更新。這就是為什麼 Omarchy 實際上會停止直接的系統升級，並引導你改用 `omarchy update`。（如果你真的知道你在做什麼，這個防護機制會告訴你如何僅針對單次交易繞過它。）

### 還原有問題的更新

如果你在更新後遇到任何問題，你可以將系統還原到更新前所拍攝的快照。只要重新啟動，並在開機載入選單中選取你在開始更新前拍攝的快照即可。

![bootloader](images/bootloader.webp)

如果不知何故你的設定檔已損壞，你也可以在終端機中使用 `omarchy reinstall` 執行 Omarchy 重新安裝。這將重新安裝所有預設的 Omarchy 套件，將你切換到 stable（在 Apple Silicon 上為 edge），降級任何過新的套件，並重設所有設定檔。請注意，這麼做將會覆寫你對 Omarchy 預設值所做的所有使用者設定變更！
