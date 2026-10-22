# 系統快照

我們會在每次 Omarchy 更新時自動建立快照，但如果你想建立自己的快照，可以使用 `omarchy-snapshot create`。

要開機並還原快照，你要從 Limine 開機載入程式中選取它。（如果你目前是直接開機進入 Omarchy 解密畫面，你需要先透過 BIOS 選擇 Limine 作為開機選項）。

在那個畫面上，根據日期和版本選擇你想開機進入的快照。快照建立當時的 Omarchy 版本會顯示在左下角。

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

當你進入系統後，會跳出一個通知，告訴你正身處一個可開機快照中，如果你點選它，就會開始還原流程。或者，你也可以使用 `omarchy-snapshot restore`。

 ![snapshots-restore](images/snapshots-restore.webp)

這會還原你的根檔案系統，但不會還原你的 `/home`。所以它適用於還原壞掉的系統更新，但不適用於救回遺失的個人檔案。

這也意味著你的 `~/.config` 目錄會保持原樣。所以如果你回滾到較舊版本的函式庫或應用程式，而它以新格式儲存設定檔，你就得自己手動處理這件事。

_注意：這個功能只適用於使用 Limine 開機載入程式的安裝，自 Omarchy 2.0 起這一直是預設值。如果你使用的是 GRUB 或 systemd-boot，就無法使用。_

### 跳過開機選單

如果你從來不碰開機選單，只想讓機器直接進入解密畫面，在 Omarchy 選單中執行 _設定 > 直接開機_。這會加入一個直接指向 Omarchy 的 EFI 項目，讓韌體直接從它開機，不在 Limine 停下來。

代價就是一開始提到的那個：開啟直接開機後，要進入快照就意味著得先從你的 BIOS 開機選單中選取 Limine。再次執行 _設定 > 直接開機_ 即可移除該項目，回到透過 Limine 開機。有些韌體不喜歡自訂 EFI 項目，所以這個設定會拒絕在 American Megatrends 和 Apple 韌體上執行。
