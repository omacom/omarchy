# 雙重開機安裝

你可以將 Omarchy 安裝在單一分割區上，與 Windows 或其他安裝並存。

這種安裝方式預設仍會為該分割區提供 LUKS 加密，因此實際上與全磁碟安裝沒有差別，只需要磁碟上有可用空間即可。

## 在 Windows 上騰出空間

若要與 Windows 並存安裝，請在開始功能表中輸入 `disk management`，並選取 **建立並格式化硬碟分割區** 選項。

 ![dual-boot-1](images/dual-boot-1.webp)

找到適當的分割區，按右鍵，然後選擇 **壓縮磁碟區**。

![dual-boot-2](images/dual-boot-2.webp)

 輸入你想要壓縮的量。請注意，這將是你未來 Omarchy 安裝的大小，包含開機分割區。

 ![dual-boot-3](images/dual-boot-3.webp)

完成後，你應該會看到類似這樣的畫面，其中 50GB 的區塊就是我們在這個範例中要安裝 Omarchy 的位置。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安裝 Omarchy

Omarchy 的安裝過程實際上與一般安裝相同。選取磁碟後，你會看到 **Free space install** 選項。選取該選項，以避免清空整個磁碟。

 ![dual-boot-5](images/dual-boot-5.webp)

確認一切都沒問題，然後像平常一樣等待安裝完成。在這裡，你也可以像全磁碟安裝一樣，選擇以未加密方式安裝（不建議）。
 ![dual-boot-6](images/dual-boot-6.webp)

## 將其他安裝加入開機載入器

完成 Omarchy 安裝後，你會發現 Limine 開機載入器現在已是預設值。有了它，你也可以為 Windows 等其他安裝，將選項加入 Limine。

若要加入其他作業系統，請執行 `limine-scan`，並依照提示將你想要的項目加入你的 Limine 設定。開機選單預設會保持隱藏，並在一秒後啟動 Omarchy。若要選擇 Windows 或其他項目，請在 Limine 一開始時立即按任意鍵；選單出現時，使用方向鍵選取項目並按 Enter。如果你在按鍵之前 Omarchy 就已啟動，請重新開機再試一次。

## Bitlocker

請注意，這種安裝方式與 Bitlocker 不相容，因為它加密的是整個磁碟機，而不只是分割區。如果你遇到錯誤，指出 Bitlocker 已啟用，請開機進入 Windows，前往 **Settings -> Privacy & Security -> Device encryption**，並將 Bitlocker 切換為關閉。解密磁碟機可能需要一些時間。

 ![dual-boot-7](images/dual-boot-7.webp)
