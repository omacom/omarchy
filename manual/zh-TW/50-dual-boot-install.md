# 雙重開機安裝

你可以把 Omarchy 安裝到單一分割區中，與 Windows 或其他安裝並存。

這種安裝方法仍然預設為該分割區提供 LUKS 加密，所以它實際上與全磁碟安裝沒有差別，只需要磁碟上有可用空間即可。

## 在 Windows 上騰出空間

要安裝在 Windows 旁邊，在開始選單中輸入 `disk management`，然後選擇 **Create and format hard disk partitions** 這個選項。

 ![dual-boot-1](images/dual-boot-1.webp)

找到適當的分割區，按右鍵，並選擇 **Shrink Volume**。

![dual-boot-2](images/dual-boot-2.webp)

 輸入你想縮小磁碟區的容量。請注意，這將是你未來 Omarchy 安裝的大小，包括開機分割區在內。

 ![dual-boot-3](images/dual-boot-3.webp)

完成後，你應該會看到類似這樣的畫面，其中 50GB 的區段就是我們在這個範例中用來安裝 Omarchy 的地方。

 ![dual-boot-4](images/dual-boot-4.webp)

## 安裝 Omarchy

Omarchy 的安裝流程實際上與平常一樣。選好磁碟後，你會看到 **Free space install** 這個選項。選取該選項以避免抹除整個磁碟。

 ![dual-boot-5](images/dual-boot-5.webp)

確認一切無誤後，像平常一樣等待安裝完成。在這裡，你也可以像全磁碟安裝一樣選擇不加密安裝（不建議）。
 ![dual-boot-6](images/dual-boot-6.webp)

## 將其他安裝加入開機載入程式

當你完成 Omarchy 安裝後，你會發現 Limine 開機載入程式現在是預設值。有了它，你也可以為其他安裝（例如 Windows）在 Limine 中加入選項。

怎麼做呢，執行 `limine-scan` 並按照提示將你想要的項目加到你的 limine 設定中。然後當你開機時，你會看到平常用來進 Omarchy 的選項，以及 Windows Boot Manager 或其他選項。

## Bitlocker

需要注意的是，這種安裝方法與 Bitlocker 不相容，因為 Bitlocker 加密的是整個磁碟，而不只是分割區。如果你遇到一則錯誤，指出 Bitlocker 已啟用，請開機進入 Windows，前往 **Settings -> Privacy & Security -> Device encryption**，並關閉 Bitlocker。磁碟解密可能需要一些時間。

 ![dual-boot-7](images/dual-boot-7.webp)
