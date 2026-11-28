# Windows VM

Omarchy 提供一種簡單的方式，讓你在 x86_64 機器上透過 Docker VM 執行 Windows。你可以從 Omarchy 選單（`Super + Space`）使用 _Install > Windows_ 來安裝。

你的機器需要 KVM 虛擬化支援，大多數機器都有——但有時它在 BIOS 裡被關掉了，安裝程式會告訴你是不是這種情況。你還會需要磁碟空間：你分給 Windows 的容量，外加大約 10GB 給映像檔本身。

安裝程式會詢問要分多少 RAM、多少 CPU 核心和多少磁碟空間（64GB 或更多是合理的下限），接著詢問 Windows 使用者名稱和密碼。把這兩欄留空，你就會得到 `docker` / `admin`。下載需要一段時間——10-15 分鐘是正常的——你可以在瀏覽器開啟 `http://127.0.0.1:8006` 追蹤進度。瀏覽器在開啟主控台之前，會要求輸入相同的使用者名稱和密碼。

 ![windows-vm](images/windows-vm.webp)

## 使用方式

安裝完成後，從應用程式啟動器啟動 _Windows_。如果 VM 尚未執行，它會先啟動 VM，然後透過 RDP 以全螢幕連線進去。冷啟動時，給它 15-30 秒。

RDP 工作階段會帶上聲音、你的麥克風和共用剪貼簿，所以在 Linux 和 Windows 之間複製文字就是能直接用。解析度會跟著你的視窗走，Omarchy 也會把你的顯示縮放比例傳遞過去，所以在 HiDPI 螢幕上不會糊成一團。

當你關閉 RDP 視窗，VM 會自動關機。如果你寧願讓它繼續執行——比方說裡面有個東西正在忙著跑——改用 `omarchy windows vm launch --keep-alive` 來啟動。

其餘的控制都在同一個命令上：

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## 分享檔案

你家目錄裡的 `~/Windows` 目錄會自動與 VM 共用。把檔案放在那裡，就能讓 Windows 存取。VM 無法存取你檔案系統的任何其他部分，所以你不用擔心 Windows 那邊有什麼惡意東西。VM 自己的虛擬磁碟位於 `~/.windows`。

這些熟悉的家目錄路徑仍保留在它們各自的檔案系統上。它們也可以是指向你自有目錄的符號連結，當虛擬磁碟放在較大的磁碟機上時，這會很實用。安裝程式測量的是實際包含 `~/.windows` 的檔案系統上的可用空間，不一定是你家目錄所在的檔案系統。

請讓磁碟路徑和共用路徑保持為各自獨立、不重疊的目錄。移除時會刻意清空磁碟目錄，但保留共用目錄。就在刪除之前，Omarchy 會執行一次有界的封閉性檢查；如果該檢查逾時或無法證明這兩棵目錄樹是分開的，Omarchy 會拒絕移除任何東西。

在 VM 啟動之前，Omarchy 會開啟並固定這兩個目錄，然後把確切的目錄 inode bind-mount 到 `/var/lib/omarchy/windows/mounts` 以下每位使用者私有的錨點上。Docker 只能看到那些受 root 保護的錨點。這能保留自訂磁碟位置，同時防止另一個以你的身分執行的處理程序，在特權容器使用已檢查的路徑之前把它偷換掉。既有的磁碟目錄和共用目錄在移轉期間會收緊為模式 `0700`，這樣其他本機帳戶就無法瀏覽其中的內容。

VM 的連接埠只繫結到 localhost，所以你網路上的任何東西都無法連到這台 Windows 機器。網頁主控台也要求輸入已設定的 Windows 使用者名稱和密碼，防止另一個本機帳戶透過連接埠 8006 操作 VM。

## 限制與授權

這套設定沒有 GPU passthrough，所以不適合拿來玩遊戲或剪輯影片。它很適合拿來執行 Microsoft Office，或其他你絕對非有不可的東西。

安裝的版本是 Windows 11 Pro，未啟用。你需要自己的授權金鑰才能使用那些受授權限制的功能。

如果這台電腦出廠時就搭載 Windows，即使安裝了 Omarchy，OEM 金鑰仍留在韌體裡。用 `omarchy windows key` 把它印出來。那把金鑰與這台機器綁定——它能啟用在這台硬體上重裝的 Windows，但通常無法啟用 VM。

稍後你可以執行終端機命令 `omarchy windows vm install` 來變更資源分配，它會根據你的回答重寫 VM 的設定。compose 檔案本身現在位於 `/var/lib/omarchy/windows/docker-compose.yml`，且由 root 擁有——這是故意的，這樣以你的身分執行的處理程序就無法重寫它，並讓特權啟動程序把你的整個磁碟掛載進容器裡。如果你需要手動編輯它（例如掛載 USB 裝置），請用 `sudo` 編輯，並在 [Dockur Windows 專案](https://github.com/dockur/windows) 查看所有選項。

要把整套東西移除掉，從 Omarchy 選單使用 _Remove > Windows_。那會刪除 `~/.windows` 裡的 VM 磁碟和 Windows 內安裝的所有東西，所以先把 VM 裡你需要的任何東西複製出來。你共用的 `~/Windows` 資料夾不會被動到。
