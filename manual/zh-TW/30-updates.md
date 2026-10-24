# 更新

Omarchy 及其套件透過 Omarchy 選單（`Super + Space`）中的 _更新 > Omarchy_ 保持最新狀態。

Omarchy 本身是以來自 [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs) 的一般 pacman 套件安裝的，所以一次更新會安裝[最新的 Omarchy 版本](https://github.com/omacom/omarchy/releases)，執行任何待處理的遷移，讓你的系統與最新版保持同步，並從 [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror) 和 [AUR](https://aur.archlinux.org/)（如果你已安裝任何 AUR 套件）更新所有系統套件。

當新版本發布時，會在時鐘右側出現一個圓圈箭頭圖示。按一下它，更新流程就會開始。

![update-available](images/update-available.webp)

### 四個頻道

Omarchy 沿著四個頻道更新：stable、RC、edge 和 dev。新安裝從 stable 頻道開始，它追蹤[官方版本](https://github.com/omacom/omarchy/releases/)，以及落後最新版本一個月的[穩定版 Omarchy Arch 鏡像](https://github.com/omacom-io/omarchy-mirror)，這樣我們就能在任何需要更改設定的新不相容性給人們帶來問題之前，將其攔截下來。

但如果你想幫忙發現這些潛在問題，你可以執行 edge 頻道。這會讓你的 Omarchy 套件追蹤最新的開發版本，並讓你一有最新的 Arch 套件就能更新。你只應在你有 Linux 經驗、且知道如何復原出現問題的系統時才這樣做。

在任何新的主要版本發布之前，我們會使用 RC 頻道進行最終驗證。如果你有興趣幫忙最後的潤飾，來 Discord 的 #omarchy-release-candidates 一起聊天。

最後，還有 dev 頻道，它將 Omarchy 直接連結到 `~/omarchy` 中原始碼的 git 副本，並結合 edge 套件。你只應在你是有經驗的 Linux 使用者、直接在 Omarchy 上工作、且願意容忍損壞時才使用這個頻道。

你可以使用 Omarchy 選單中的 _更新 > Channel_（或終端機中的 `omarchy-channel-set`）在頻道之間切換。

### 韌體更新

你的套件不是唯一會過時的東西。許多筆記型電腦和周邊設備會透過 Linux Vendor Firmware Service 提供 BIOS、SSD 和擴充基座韌體，而 Omarchy 選單中的 _更新 > Firmware_ 會擷取並安裝你的硬體正在等待的任何更新。它會在你第一次執行時安裝 `fwupd`。許多韌體只能在重新開機期間寫入，所以被要求重新開機時不要感到驚訝。

### 關於直接使用 pacman/yay 更新的警告

如果你已經熟悉 Arch，你可能會想自己執行 `pacman -Syu` 或 `yay -Syu`，但如果你這樣做，你會錯過 Omarchy 隨新套件一起執行的快照、遷移和設定更新。這就是為什麼 Omarchy 實際上會阻止直接的系統升級，並改為指引你使用 `omarchy update`。（如果你真的知道自己在做什麼，該防護會告訴你如何為單一交易繞過它。）

### 還原不良更新

如果你在完成更新後遇到問題，你可以將系統還原到更新前擷取的快照。只要重新啟動，並在開機載入選單中選取你開始更新之前的快照即可。

![bootloader](images/bootloader.webp)

如果你的設定檔不知何故已損壞，你也可以使用終端機中的 `omarchy reinstall` 執行 Omarchy 重新安裝。這會重新安裝所有預設的 Omarchy 套件，將你置於 stable 頻道、降級任何過於新的套件，並重設所有設定檔。請注意，你對 Omarchy 預設值的全部使用者設定變更都會在此過程中被覆寫！
