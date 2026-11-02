# 雙重開機安裝

你可以將 Omarchy 安裝到單一分割區，與 Windows 或其他安裝並存。

這種安裝方式預設仍會為該分割區提供 LUKS 加密，所以實際上與全磁碟安裝沒有不同，只是需要磁碟上有可用空間。

## 在 Windows 上騰出空間

若要與 Windows 並存安裝，請在開始功能表中輸入 `disk management`，並選取 **Create and format hard disk partitions** 選項。

 ![dual-boot-1](images/dual-boot-1.webp)

找到適當的分割區，按一下右鍵，然後選取 **Shrink Volume**。

![dual-boot-2](images/dual-boot-2.webp)

輸入你想要壓縮的磁碟區大小。請注意，這將會是你未來 Omarchy 安裝的大小，其中包含開機分割區。

 ![dual-boot-3](images/dual-boot-3.webp)

完成後，你應該會看到類似這樣的畫面，其中 50GB 的區段就是我們在本範例中要安裝 Omarchy 的位置。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安裝 Omarchy

Omarchy 的安裝流程實際上與一般安裝相同。選取磁碟後，你會看到 **Free space install** 選項。選取該選項可避免清除整顆磁碟。

 ![dual-boot-5](images/dual-boot-5.webp)

確認一切都正確無誤，然後等待安裝如常完成。在這裡，你也可以像全磁碟安裝一樣選擇不加密安裝（不建議）。
 ![dual-boot-6](images/dual-boot-6.webp)

## 將其他安裝加入開機載入程式

完成 Omarchy 安裝後，你會注意到 Limine 開機載入程式現在已成為預設。透過它，你也可以為 Windows 等其他安裝將選項加入 Limine。

若要加入其他作業系統，請執行 `limine-scan`，並依照提示將想要的項目加入你的 Limine 設定。開機選單預設會保持隱藏，並在一秒後啟動 Omarchy。若要選擇 Windows 或其他項目，請在 Limine 一啟動時按下任意鍵；選單出現時，使用方向鍵選取項目，然後按下 Enter。如果你在按鍵之前 Omarchy 就已啟動，請重新開機再試一次。如果你已開啟 _Setup > Direct Boot_，韌體會完全跳過 Limine，因此請從 BIOS 開機選單中選取 Limine，或再次執行 _Setup > Direct Boot_ 以移除該項目。

## Bitlocker

請務必注意，這種安裝方式與 Bitlocker 不相容，因為它加密的是整顆磁碟機，而不只是分割區。如果你遇到指出已啟用 Bitlocker 的錯誤，請開機進入 Windows，前往 **Settings -> Privacy & Security -> Device encryption**，並將 Bitlocker 關閉。解密磁碟機可能需要一段時間。

 ![dual-boot-7](images/dual-boot-7.webp)
