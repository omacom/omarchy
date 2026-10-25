# 背景

每個主題都附帶自己的一組背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 加入你自己的額外背景。舉例來說，如果你想為 nord 主題新增一張額外的背景圖片，只要把檔案放到 `~/.config/omarchy/backgrounds/nord` 即可。

最簡單的做法是前往 Omarchy Menu 中的 _Install > Style > Background_。這會開啟存放該主題背景的資料夾。按下 `Super + Shift + F` 開啟另一個檔案管理器，找到你的背景，然後複製過去。現在它就會出現在你可以用 `Super + Ctrl + W` 切換選擇的背景選項中。

背景除了靜態圖片，也可以使用影片。將 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 檔案放入同一個資料夾，它就會與圖片一起出現。影片由 OWE 桌布引擎播放。它會為所有螢幕只解碼一次影片，並透過預設音訊輸出播放聲音，而且在沒有任何畫面能看到它時停止播放。影片桌布的耗電量仍然遠高於靜態桌布。

主題可以為靜態背景包含一段短短的開場影片。對於 `backgrounds/road.webp`，對應的影片位於 `backgrounds/intros/road.mp4`。它會在開機時以及切換到已選用該背景的主題時自動播放，然後回到靜態圖片。開場影片不會出現在背景選擇器中，也永遠不會循環播放。

關閉 _Appearance > Animations_ 也會關閉背景開場影片。Omarchy 在虛擬機器中預設就會這麼做。`omarchy theme bg intro toggle` 命令可以單獨切換開場影片。重新整理主題或在同一個主題內選擇其他背景，不會播放開場影片。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 找到大量精心挑選的酷背景收藏。

鎖定畫面會顯示影片背景的靜態畫面，就像它顯示動畫 GIF 的靜態畫面一樣。
