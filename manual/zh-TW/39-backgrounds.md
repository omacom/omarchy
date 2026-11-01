# 背景

每個主題都會隨附自己的一組背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中加入你自己的額外背景。舉例來說，如果你想為 nord 主題新增一張背景圖片，只要把檔案放入 `~/.config/omarchy/backgrounds/nord` 即可。

最簡單的做法是，在 Omarchy Menu 中前往 _Install > Style > Background_。這會開啟存放該主題背景的資料夾。按下 `Super + Shift + F` 開啟另一個檔案管理器，找到你的背景，然後將它複製過去。現在你就能用 `Super + Ctrl + W` 在可選的背景中挑選它了。

背景可以是影片，不限於靜態圖片。將 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 檔案放入同一個資料夾，它就會和圖片一起出現。影片由 OWE 桌布引擎播放。它只會為所有螢幕解碼一次影片，並透過預設音訊輸出播放聲音，而且當沒有任何畫面能看到它時，就會停止播放。影片桌布的耗電量仍遠高於靜態桌布。

主題可以為靜態背景包含一段簡短的開場。對於 `backgrounds/road.webp`，對應的影片位於 `backgrounds/intros/road.mp4`。它會在開機時、切換到選用該背景的主題時，以及選擇該背景時自動播放，然後回到靜態圖片。開場影片不會出現在背景選擇器中，也永遠不會循環播放。

關閉 _Appearance > Animations_ 也會關閉背景開場。Omarchy 在虛擬機器中預設就會這麼做。`omarchy theme bg intro toggle` 指令可以獨立切換開場。重新整理主題不會播放開場。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 找到大量精選的酷炫背景。

鎖定畫面會顯示影片背景的靜態畫面，方式與顯示動畫 GIF 的靜態畫面相同。
