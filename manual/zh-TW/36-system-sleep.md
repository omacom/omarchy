# 系統睡眠

Omarchy 預設啟用暫停，休眠則在設定完成後啟用，但如果你的機器在任一功能上遇到問題，你可以將它們關閉。

在 NVIDIA GB10 機器上，例如 DGX Spark 和 ASUS Ascent GX10，暫停和休眠都會關閉，就像 NVIDIA 的 DGX OS 一樣，因為睡眠尚未證明能在該硬體上正常運作。ASUS Zenbook A16 (UX3607OA) 也是如此，它的暫停尚未能讓晶片完全進入睡眠，隔夜可能會當機。暫停切換和休眠設定不適用於這些機器。若要重新開啟睡眠，請用 `sudo rm` 移除 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`；Suspend 接著會回到選單，休眠也能像在其他機器上一樣設定。執行 `sudo omarchy apply hardware --install-user "$USER"` 會將該檔案放回。

### 電源設定檔

在筆記型電腦上，Omarchy 會分別記住你插電時和用電池運作時的電源設定檔，並在你插上或拔除電源時在兩者之間切換。開箱即用，這表示 AC 時使用 performance，電池時使用 balanced。

你可以透過 `omarchy powerprofiles list` 查看你的機器提供哪些選項，並透過 `omarchy powerprofiles set autodetect power-saver` 設定你目前狀態想要的那一個。若要在不拔除任何東西的情況下設定另一個狀態，請直接指定它：`omarchy powerprofiles set battery power-saver`。你所選擇的，就是你下次處於該狀態時會得到的設定。

### 切換暫停

你可以從終端機執行 `omarchy toggle suspend` 來切換暫停。這只會顯示／隱藏 _System_（或 `Super + Esc`）下的選項，然後你可以看看它在你的系統上是否能穩定運作。如果不行，你可以用同一個指令再次將它隱藏。

### 切換休眠

你可以從終端機執行 `omarchy hibernation setup` 來設定休眠（Apple Silicon Mac 上不提供此功能）。休眠會在你的開機磁碟上建立一個大小與你的實體 RAM 配置量相同的 /swap 子卷，所以請確保你有充足的空間可供使用。在 32GB 的機器上，你永遠需要為這個卷保留 32GB 以上的可用空間。休眠也需要預設的 Limine 開機載入程式。

設定完成後，你會在 _System_（或 `Super + Esc`）下看到休眠選項，然後你可以看看它在你的系統上是否能穩定運作。如果不行，你可以執行 `omarchy hibernation remove` 再次將它移除。
