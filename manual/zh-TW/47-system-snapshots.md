# 系統快照

我們在每次 Omarchy 更新時都會自動建立快照，但如果你想自行建立，可以使用 `omarchy-snapshot create`。

若要開機進入快照並還原，請從 Limine 開機載入程式中選取該快照。（如果你目前是直接開機進入 Omarchy 解密畫面，必須先透過 BIOS 將 Limine 選為開機選項。）

在該畫面中，根據日期和版本選擇你想開機進入的快照。建立快照當時的 Omarchy 版本可以在左下角看到。

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

進入系統後，會跳出一則通知，告訴你目前正處於可開機快照中，點按該通知即可開始還原程序。或者，你也可以使用 `omarchy-snapshot restore`。

 ![snapshots-restore](images/snapshots-restore.webp)

這會還原你的根檔案系統，但不會還原 `/home`。因此，它適合用來回復出問題的系統更新，卻無法復原遺失的個人檔案。

這也意味著你的 `~/.config` 目錄會保持原狀。所以，如果你回復到某個程式庫或應用程式的較舊版本，而它以新格式儲存設定檔，你就必須自行手動處理。

Omarchy 自身關於哪些遷移已執行過的紀錄也是如此：它位於你的家目錄中，因此還原後仍會保留。在建立快照之後執行過的遷移仍會被標記為已完成，即使它們對根檔案系統所做的變更已被回復，而且下一次 `omarchy update` 也不會再次執行它們。因此，如果你在還原後再次更新，發現先前某次更新已設定好的內容仍然缺失，原因很可能就在這裡。

_備註：本功能僅適用於使用 Limine 開機載入程式的安裝，自 Omarchy 2.0 起已是預設值。如果是使用 GRUB 或 systemd-boot，就無法使用。_

### 跳過開機選單

如果你從不使用開機選單，只想讓電腦直接進入解密畫面，請在 Omarchy 選單中執行 _Setup > Direct Boot_。這會新增一個直接指向 Omarchy 的 EFI 項目，讓韌體直接開機進入 Omarchy，不會停在 Limine。

代價就是開頭提到的那一點：開啟直接開機後，若要進入快照，必須先從 BIOS 開機選單中選取 Limine。再次執行 _Setup > Direct Boot_ 即可移除該項目，恢復透過 Limine 開機。某些韌體不喜歡自訂 EFI 項目，所以此設定會拒絕在 American Megatrends 和 Apple 韌體上執行。
