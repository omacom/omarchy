# 硬體驗證

### 指紋驗證

許多筆記型電腦都配備指紋感測器來進行驗證。你可以在 Omarchy 選單（`Super + Space`）中執行 _Setup > Security > Fingerprint_，來搭配 Omarchy 使用這項功能。

那會開啟一個全螢幕指紋圖像，並隨著你觸碰感測器而逐漸填滿。在背後，Omarchy 會安裝指紋套件、採集你的指紋、進行驗證，完成後你就能使用指紋從鎖定畫面解鎖（你可以用 `Super + Ctrl + L` 觸發）、進入 sudo 模式，以及授權系統提示。

一旦鎖定畫面關閉顯示器，感測器就會休眠以節省電力，因此在觸碰它之前，先用任意按鍵或觸控板喚醒螢幕。

當你的筆記型電腦上蓋關閉時，指紋提示會自動略過，讓你直接進入密碼提示，而不必等待一個你碰不到的感測器。如果你需要在沒有感測器的外接鍵盤上工作，只需在 `sudo` 期間提示輸入指紋時，按下 `CTRL + C` 即可。

你可以在 Omarchy 選單的 _Remove > Security > Fingerprint_ 下移除指紋驗證。

### Fido2 驗證

如果你使用的是 Fido2 裝置，你可以使用 Omarchy 選單（`Super + Space`）中的 _Setup > Security > Fido2_，將它設定為 `sudo` 驗證方式。它涵蓋 `sudo` 與系統授權提示，但不包含解鎖你的電腦。

你可以在 Omarchy 選單的 _Remove > Security > Fido2_ 下移除 fido2 驗證。
