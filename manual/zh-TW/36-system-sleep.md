# 系統睡眠

Omarchy 預設啟用暫停功能，完成設定後也會啟用休眠功能，但如果你的機器在使用其中任何一項時遇到問題，你可以將它們關閉。

在 NVIDIA GB10 機器上，例如 DGX Spark 和 ASUS Ascent GX10，暫停和休眠功能都是關閉的，NVIDIA 的 DGX OS 也是如此，因為目前尚未證實睡眠功能能在該硬體上正常運作。那裡不適用暫停切換和休眠設定。若要重新開啟睡眠功能，請用 `sudo rm` 移除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；之後暫停就會重新出現在選單中，休眠也能像在其他機器上一樣進行設定。執行 `sudo omarchy apply hardware --install-user "$USER"` 會把該檔案放回去。

### 電源設定檔

在筆記型電腦上，Omarchy 會分別記住你接上電源時和使用電池時的電源設定檔，並在你插上或拔掉電源時在兩者之間切換。開箱即用時的設定就是接 AC 電源時使用效能模式，使用電池時使用平衡模式。

你可以用 `omarchy powerprofiles list` 查看你的機器提供哪些選項，並用 `omarchy powerprofiles set autodetect power-saver` 設定你目前所處狀態想要使用的設定檔。若要在不拔掉任何東西的情況下設定另一種狀態，請直接指定它：`omarchy powerprofiles set battery power-saver`。不管你選了哪一個，下次進入該狀態時，你拿回來的就會是那個設定檔。

### 切換暫停

你可以從終端機執行 `omarchy toggle suspend` 來切換暫停功能。這只會顯示／隱藏 _系統_（或 `Super + Esc`）底下的選項，然後你就能看看它在你的系統上是否能穩定運作。如果不行，你可以用同一個指令再次將它隱藏起來。

### 切換休眠

你可以從終端機執行 `omarchy hibernation setup` 來設定休眠功能（Apple Silicon Mac 上不提供此功能）。休眠會在你的開機磁碟上建立一個 /swap 子卷，其大小與你的實體 RAM 配置相同，所以請確保你有充足的剩餘空間。在 32GB 的機器上，你永遠需要為這個卷冊預留 32GB 以上的可用空間。休眠功能還需要預設的 Limine 開機載入程式。

設定完成後，你會在 _系統_（或 `Super + Esc`）底下看到休眠選項，然後你就能看看它在你的系統上是否能穩定運作。如果不行，你可以執行 `omarchy hibernation remove` 再次將它移除。
