# Windows VM

Omarchy 提供了一種透過 Docker VM 執行 Windows 的簡單方式。你可以使用 Omarchy 選單（`Super + Space`）中的 _安裝 > Windows_ 來安裝它。

你的機器需要為此啟用 KVM 虛擬化，大多數機器都有——但它有時在 BIOS 中被關閉，安裝程式會告訴你是否如此。你還需要磁碟空間：你要給 Windows 的空間，再加上映像本身約 10GB。

安裝程式會詢問要交出多少 RAM、多少 CPU 核心和多少磁碟空間（64GB 或更多是合理的下限），然後詢問 Windows 使用者名稱和密碼。將它們留空，你會得到 `docker` / `admin`。下載需要一段時間——10-15 分鐘是正常的——你可以在瀏覽器中追蹤進度，網址是 `http://127.0.0.1:8006`. 瀏覽器在開啟主控台前會提示輸入相同的使用者名稱和密碼。

 ![windows-vm](images/windows-vm.webp)

## 使用它

一旦安裝完成，從應用程式啟動器啟動 _Windows_。那會在 VM 尚未執行時啟動它，並透過 RDP 全螢幕連接你。在冷啟動時給它 15-30 秒。

RDP 工作階段會傳輸聲音、你的麥克風和共享剪貼簿，所以在 Linux 和 Windows 之間複製文字直接就能運作。解析度會跟隨你的視窗，Omarchy 會傳入你的顯示器縮放，所以它在 HiDPI 螢幕上不會是一團模糊。

當你關閉 RDP 視窗時，VM 會自動關機。如果你寧願讓它繼續執行——比如說你在裡面有東西正在運作——改用 `omarchy windows vm launch --keep-alive` 啟動它。

其餘的控制都在同一個命令上：

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## 共享檔案

你家目錄中的目錄 `~/Windows` 會自動與 VM 共享。如果你想讓檔案能被 Windows 存取，就把它們放在那裡。VM 無法存取你檔案系統的任何其他部分，所以你不會受到 Windows 端任何惡意東西的侵害。它自己的虛擬磁碟位於 `~/.windows`。

這些熟悉的家目錄路徑會留在各自的檔案系統上。它們也可以是連到你所擁有的目錄的符號連結，當虛擬磁碟位於較大的磁碟機上時，這很方便。安裝程式測量的是實際包含 `~/.windows` 的檔案系統上的可用空間，而不一定是包含你家目錄的檔案系統。

請保持磁碟路徑和共享路徑為分離、互不重疊的目錄。移除作業會有意清空磁碟目錄，但保留共享目錄。在刪除之前，Omarchy 會立即執行一個有界的包容性檢查，如果該檢查逾時或無法證明這兩棵樹是分離的，就拒絕移除任何東西。

在 VM 啟動之前，Omarchy 會開啟並釘住這兩個目錄，然後將確切的目錄 inode 以綁定掛載的方式掛到 `/var/lib/omarchy/windows/mounts` 下方的私人每使用者錨點上。Docker 只會看到那些受 root 保護的錨點。這保留了自訂磁碟位置，同時防止另一個以你身分執行的處理程序在特權容器使用已檢查的路徑之前把它掉包。現有的磁碟和共享目錄在遷移期間會收緊為模式 `0700`，使其他本機帳戶無法瀏覽其內容。

VM 的連接埠僅綁定到 localhost，所以你網路上的任何東西都無法觸及這台 Windows 機器。網頁主控台還會要求已設定的 Windows 使用者名稱和密碼，防止另一個本機帳戶透過連接埠 8006 驅動 VM。

## 限制和授權

這個設定沒有 GPU 直通，所以它不適合遊戲或影片編輯。它是執行 Microsoft Office 或你絕對必須擁有的其他任何東西的好方法。

安裝的版本是 Windows 11 Pro，未啟用。你需要自己的授權金鑰才能使用受限功能。

如果這台電腦出廠時附帶 Windows，即使安裝了 Omarchy 之後，OEM 金鑰仍然在韌體中。用 `omarchy windows key` 將它印出。該金鑰與這台機器綁定——它會啟用在這台硬體上重新安裝的 Windows，但通常不會啟用 VM。

你日後可以重新執行 `omarchy-windows-vm install` 來更改資源分配，它會根據你的回答重寫 VM 的設定。compose 檔案本身現在位於 `/var/lib/omarchy/windows/docker-compose.yml` 並由 root 擁有——這是刻意的，這樣一個以你身分執行的處理程序就無法重寫它，並讓特權啟動流程把你整個磁碟掛載進容器。如果你需要手動編輯它（例如要掛載 USB 裝置），用 `sudo` 編輯它，並在 [Dockur Windows 專案](https://github.com/dockur/windows)上查看所有選項。

要擺脫整個東西，使用 Omarchy 選單中的 _移除 > Windows_。那會刪除 VM 的磁碟及其所有資料，所以要先確保任何你在乎的東西都已從 `~/Windows` 中取出來。
