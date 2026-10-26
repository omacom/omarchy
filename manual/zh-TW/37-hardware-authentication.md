# 硬體驗證

### 指紋驗證

許多筆記型電腦都配備了指紋感應器可用於驗證。你可以在 Omarchy 選單（`Super + Space`）中執行 _Setup > Security > Fingerprint_，在 Omarchy 中使用這項功能。

這會安裝指紋套件、擷取你的指紋並進行驗證，之後你就可以使用指紋從鎖定畫面解鎖（可用 `Super + Ctrl + L` 觸發）、進入 sudo 模式，以及授權系統提示。

鎖定畫面關閉顯示器後，感應器會休眠以節省電力，因此在觸摸它之前，請先使用任意按鍵或觸控板喚醒螢幕。

當筆記型電腦上蓋關閉時，指紋提示會自動略過，讓你直接進入密碼提示，而不必等待一個你碰不到的感應器。如果你需要在沒有感應器的外接鍵盤上操作，只需在 `sudo` 期間出現指紋提示時按下 `CTRL + C` 即可。

你可以在 Omarchy 選單中的 _Remove > Security > Fingerprint_ 移除指紋驗證。

### Fido2 驗證

如果你使用 Fido2 裝置，你可以在 Omarchy 選單（`Super + Space`）中使用 _Setup > Security > Fido2_ 將它設定為 `sudo` 驗證方式。不過，它涵蓋 `sudo` 和系統授權提示，但不包括解鎖你的電腦。

你可以在 Omarchy 選單中的 _Remove > Security > Fido2_ 移除 fido2 驗證。
