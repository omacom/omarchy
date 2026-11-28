# 系統快照

每次 Omarchy 更新時，我們都會自動建立快照，但如果你想建立自己的快照，可以使用 `omarchy-snapshot create`。

你如何開機並還原快照，取決於你的機器啟動時使用的開機載入程式。新的 UEFI 安裝使用 systemd-boot；較舊的安裝與 BIOS 機器使用 Limine。`omarchy-boot-backend` 會告訴你你使用的是哪一個。

## 使用 systemd-boot

在 Omarchy 選單中選擇 _System > Snapshots_，然後選擇你想開機進入的快照。機器會重新啟動並進入該快照一次。或者在機器啟動時按住 Space，即可看到開機選單，其中每個快照都依最新在前排序，並列出其 Omarchy 版本與日期。

快照開機時，上面會有一層暫時層，所以你可以照常使用它，但你做的任何變更都會在下次重新啟動時消失。若要保留它，就讓它成為你的系統：點選你登入時出現的通知、選擇 _System > Snapshots > Restore This Snapshot_，或執行 `omarchy-snapshot restore`。還原會在機器重新啟動時進行。還原前的系統會以 _Before restore_ 的形式留在開機選單中，而 `omarchy-snapshot restore backup` 會將它還原回來。

從終端機：

- `omarchy-snapshot list` 列出你可以開機進入的快照；
- `omarchy-snapshot boot 12` 重新啟動並進入快照 12 一次；
- `omarchy-snapshot restore 12` 會在下次重新啟動時讓快照 12 成為系統，而 `omarchy-snapshot restore --cancel` 會在那次重新啟動前讓你改變主意。

## 使用 Limine

若要開機並還原快照，你要從 Limine 開機載入程式中選擇它。開機選單預設保持隱藏，所以在 Limine 啟動時一開始就按任意鍵，即可將它叫出來。

在該畫面中，根據日期與版本選擇你想開機進入的快照。快照當時的 Omarchy 版本可以在左下角看到。

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

當你進入後，會跳出一個通知，通知你正處於一個可開機的快照中，如果你點選它，就會開始還原程序。或者，你也可以使用 `omarchy-snapshot restore`。

 ![snapshots-restore](images/snapshots-restore.webp)

## 還原涵蓋的範圍

還原會帶回你的根檔案系統，但不會帶回你的 `/home`。所以它適用於還原一個損壞的系統更新，但不適用於找回遺失的個人檔案。

這也表示你的 `~/.config` 目錄會保持原樣。所以如果你要回退到一個函式庫或應用程式的較早版本，而它以新格式儲存設定檔，你就必須手動處理這個問題。

Omarchy 自己記錄哪些遷移已經執行過的紀錄也是如此：它位於你的家目錄中，所以會在還原後保留下來。在快照建立後執行過的遷移仍會標記為已完成，即使它們對根檔案系統所做的變更已被回退，而且下一次 `omarchy update` 不會再次執行它們。所以如果你在還原後再次更新，而某個先前更新已設定好的東西仍然缺失，那很可能就是原因。
