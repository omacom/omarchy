# 更新

Omarchy 和你的套件會透過 Omarchy 選單中的 _Update > Omarchy_（`Super + Space`）保持在最新狀態。

Omarchy 本身是以一般的 pacman 套件形式，從 [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) 安裝的，因此更新時會安裝 [最新的 Omarchy 版本](https://github.com/omacom/omarchy/releases)，執行所有待處理的遷移，讓你的系統與最新版同步，並從 [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) 和 [AUR](https://aur.archlinux.org/) 更新所有系統套件（如果你有安裝任何 AUR 套件的話）。

有新版本推出時，你的時鐘右側會出現一個圓形箭頭圖示。點一下它，更新程序就會開始。

![update-available](images/update-available.webp)

### 四個更新通道

Omarchy 會沿著四個更新通道更新：stable、RC、edge 和 dev。新安裝的系統會從 stable 通道開始，它會追蹤 [官方版本](https://github.com/omacom/omarchy/releases/)，以及落後最新版一個月的 [stable Omarchy Arch 鏡像站](https://github.com/omacom-io/omarchy-mirror)，這樣我們就能在任何需要調整設定的新不相容問題給大家帶來麻煩之前，先把它們抓出來。

但如果你想幫忙找出那些潛在問題，你可以改用 edge 通道。這會讓你的 Omarchy 套件追蹤最新的開發版組建，也讓你能在 Arch 套件一推出時就更新到最新版。只有在你熟悉 Linux，而且知道如何復原出問題的系統時，才應該這樣做。

在任何重大新版本推出之前，我們會使用 RC 通道做最後驗證。如果你有興趣幫忙做最後的打磨，歡迎來 Discord 的 #omarchy-release-candidates 頻道一起閒聊。

最後還有 dev 通道，它會將 Omarchy 直接連結到 `~/omarchy` 中原始碼的 git checkout，並搭配 edge 套件。只有在你是經驗豐富的 Linux 使用者、正在直接開發 Omarchy，而且願意容忍系統損壞時，才應該使用這個通道。

你可以使用 Omarchy 選單中的 _Update > Channel_（或在終端機執行 `omarchy-channel-set`）來切換通道。

### 切換核心

Omarchy 會用它自己的 `linux-omarchy` 核心開機，但你可以把其他核心跟它一起安裝著，像是 Arch 原廠的 `linux` 核心，或是你正在測試的實驗版組建。當系統中有不只一個核心時，Omarchy 選單中的 _Update > Kernel_ 會列出它們，並在預設開機的那個旁邊打勾。選另一個，輸入一次密碼，它就會在下次重新開機後啟動。其他核心仍會留在開機選單中，所以如果新的預設核心給你帶來麻煩，你還是可以手動選一個來開機。在終端機中，`omarchy-kernel` 可以查看目前的預設核心，`omarchy-kernel list` 可以查看已安裝的核心，`omarchy-kernel set <kernel>` 則可以切換核心。

### 韌體更新

會過期的不只有你的套件。許多筆記型電腦和周邊設備會透過 Linux Vendor Firmware Service 提供 BIOS、SSD 和擴充基座韌體，而 Omarchy 選單中的 _Update > Firmware_ 會取得並安裝你的硬體正在等待的任何更新。第一次執行時，它會安裝 `fwupd`。許多韌體只能在重新開機期間寫入，所以如果系統要求你重新開機，別感到意外。

### 關於直接使用 pacman/yay 更新的警告

如果你已經熟悉 Arch，你可能會想直接自己執行 `pacman -Syu` 或 `yay -Syu`，但如果你這樣做，你就會錯過 Omarchy 會連同新套件一起執行的快照、遷移和設定更新。這就是為什麼 Omarchy 會直接擋下直接的系統升級，並引導你改用 `omarchy update`。（如果你真的知道自己在做什麼，這道防護會告訴你如何僅針對單次交易繞過它。）

### 還原有問題的更新

如果你在更新後遇到任何問題，你可以將系統還原到更新前拍攝的快照。只要重新開機，並在開機載入選單中選取你在開始更新之前的那個快照即可。

![bootloader](images/bootloader.webp)

如果你的設定檔不知怎麼損毀了，你也可以在終端機使用 `omarchy reinstall` 重新安裝 Omarchy。這會重新安裝所有預設的 Omarchy 套件，將你切回 stable 並降級任何過新的套件，還會重設所有設定檔。請注意，這樣做會覆寫你對 Omarchy 預設值所做的所有使用者設定變更！
