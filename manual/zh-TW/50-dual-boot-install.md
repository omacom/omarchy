# 雙重開機安裝

你可以將 Omarchy 安裝到單一分割區，與 Windows 或其他安裝並存。

這種安裝方式預設仍會為該分割區提供 LUKS 加密，因此實際上與整顆磁碟安裝沒有不同，只需要磁碟上有可用空間即可。

## 在 Windows 上騰出空間

若要與 Windows 並存安裝，請在開始功能表中輸入 `disk management`，並選取 **建立並格式化硬碟分割區** 選項。

 ![dual-boot-1](images/dual-boot-1.webp)

找到適當的分割區，按右鍵，然後選擇 **壓縮磁碟區**。

![dual-boot-2](images/dual-boot-2.webp)

 輸入你想要壓縮的容量。請注意，這將是你未來 Omarchy 安裝的大小，包含開機分割區。

 ![dual-boot-3](images/dual-boot-3.webp)

完成後，你應該會看到類似這樣的畫面，其中 50GB 的區塊就是我們在本範例中要安裝 Omarchy 的位置。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安裝 Omarchy

Omarchy 的安裝流程實際上與一般安裝相同。選取磁碟後，你會看到 **使用可用空間安裝** 選項。選取該選項，以避免清除整顆磁碟。

 ![dual-boot-5](images/dual-boot-5.webp)

確認一切看起來都正確，然後像平常一樣等待安裝完成。在這裡，你也可以選擇不安裝加密（不建議），就像整顆磁碟安裝一樣。
 ![dual-boot-6](images/dual-boot-6.webp)

## 將其他安裝加入開機載入程式

完成 Omarchy 安裝後，你會注意到 Limine 開機載入程式現在已成為預設。你也可以藉此將 Windows 等其他安裝的選項加入 Limine。

若要加入其他作業系統，請執行 `limine-scan`，並依照提示將你想要的項目加入 Limine 設定。開機選單預設為隱藏，並會在一秒後啟動 Omarchy。若要選擇 Windows 或其他項目，請在 Limine 啟動時立即按下任意鍵；選單出現後，使用方向鍵選取項目並按下 Enter。如果 Omarchy 在你按下按鍵前就已啟動，請重新開機再試一次。

## Bitlocker

請務必注意，這種安裝方式與 Bitlocker 不相容，因為它加密的是整顆磁碟，而不只是分割區。如果你遇到錯誤，指出 Bitlocker 已啟用，請開機進入 Windows，前往 **設定 -> 隱私權與安全性 -> 裝置加密**，並關閉 Bitlocker。解密磁碟可能需要一段時間。

 ![dual-boot-7](images/dual-boot-7.webp)

## 重新安裝 Windows

如果這台電腦出廠時隨附 Windows，其產品金鑰會儲存在韌體中。執行 `omarchy windows key` 即可將其印出，這樣你日後若在這台機器上重新安裝 Windows，就能再次啟用 Windows。
