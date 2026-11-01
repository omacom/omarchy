# 系統睡眠

Omarchy 預設會啟用暫停和休眠，但如果你的機器在使用這兩者時有任何問題，你可以將它們關閉。

在 NVIDIA GB10 機器上，例如 DGX Spark 和 ASUS Ascent GX10，暫停和休眠是關閉的，就如同在 NVIDIA 的 DGX OS 中一樣，因為睡眠功能尚未證實能在該硬體上運作。那裡不適用暫停切換和休眠設定。若要重新開啟睡眠功能，請用 `sudo rm` 移除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；Suspend 然後就會重新出現在選單中，而休眠也可以像在其他機器上一樣設定。執行 `sudo omarchy apply hardware --install-user "$USER"` 會把該檔案放回去。

### 電源設定檔

在筆記型電腦上，Omarchy 會分別記住你接上電源時和以電池運行時的電源設定檔，並在你插上和拔除電源時在兩者之間切換。開箱即用地，這表示在 AC 電源時為 performance，在電池上則為 balanced。

你可以用 `omarchy powerprofiles list` 查看你的機器提供哪些選項，並用 `omarchy powerprofiles set autodetect power-saver` 設定你想要在目前狀態下使用的那一個。若要在不拔除任何電源的情況下設定另一個狀態，請直接指定它：`omarchy powerprofiles set battery power-saver`。無論你挑選哪一個，下次你處於該狀態時，就會得到那個設定。

### 切換暫停

你要切換暫停，請在終端機中執行 `omarchy toggle suspend`。這只是會顯示／隱藏 _System_（或 `Super + Esc`）底下的該選項，之後你就可以看看它在你的系統上是否能穩定運作。如果不能，你可以用同一個指令再把它隱藏起來。

### 切換休眠

你要設定休眠，請在終端機中執行 `omarchy hibernation setup`。休眠會在你的開機磁碟機上建立一個 /swap 子卷，其大小與你實體 RAM 的容量相同，所以請確定你有足夠的剩餘空間。在 32GB 的機器上，你永遠需要有 32GB 以上的可用空間給這個卷。休眠還要求使用預設的 Limine 開機引導程式。

設定完成後，你會在 _System_（或 `Super + Esc`）底下看到 hibernate 選項，之後你就可以看看它在你的系統上是否能穩定運作。如果不能，你可以執行 `omarchy hibernation remove` 再將它移除。
