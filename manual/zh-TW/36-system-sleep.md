# 系統睡眠

Omarchy 預設啟用暫停與休眠，但如果你的機器在使用其中任何一項時遇到問題，你可以將它們關閉。

在 NVIDIA GB10 機器上，例如 DGX Spark 和 ASUS Ascent GX10，暫停與休眠是關閉的，就像在 NVIDIA 的 DGX OS 中一樣，因為睡眠尚未證實能在該硬體上運作。ASUS Zenbook A16 (UX3607OA) 也是如此，其暫停尚未能讓晶片完全進入睡眠，整夜放著可能會當機。暫停切換與休眠設定在那裡不適用。若要重新開啟睡眠，請用 `sudo rm` 移除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；暫停隨後會回到選單中，休眠也能像在其他機器上一樣設定。執行 `sudo omarchy apply hardware --install-user "$USER"` 會把該檔案放回去。

### 電源設定檔

在筆記型電腦上，Omarchy 會分別記住你插上電源時和使用電池供電時的電源設定檔，並在你插上和拔下電源時在兩者之間切換。開箱即用，這表示 AC 時使用效能模式，電池供電時使用平衡模式。

你可以用 `omarchy powerprofiles list` 查看你的機器提供哪些選項，並用 `omarchy powerprofiles set autodetect power-saver` 設定你想要用於目前所在狀態的選項。若要在不拔下任何東西的情況下設定另一個狀態，請直接指名它：`omarchy powerprofiles set battery power-saver`。不論你選了什麼，下次你處於該狀態時，得到的就會是那個選項。

### 切換暫停

你可以從終端機執行 `omarchy toggle suspend` 來切換暫停。這只會顯示/隱藏 _系統_（或 `Super + Esc`）下的選項，然後你就能看看它在你的系統上是否能穩定運作。如果不行，你可以用同一個指令再次將它隱藏。

### 切換休眠

你可以從終端機執行 `omarchy hibernation setup` 來設定休眠。休眠會在你的開機磁碟上建立一個 /swap 子卷冊，大小等於你的實體 RAM 配置量，所以請確保你有充裕的剩餘空間。在 32GB 的機器上，你永遠會需要為這個卷冊保留 32GB 以上的可用空間。休眠也需要預設的 Limine 開機載入程式。

設定完成後，你會在 _系統_（或 `Super + Esc`）下看到休眠選項，然後你就能看看它在你的系統上是否能穩定運作。如果不行，你可以執行 `omarchy hibernation remove` 再次將它移除。
