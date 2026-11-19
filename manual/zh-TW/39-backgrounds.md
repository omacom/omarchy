# 背景

每個主題都附帶自己的一組背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中加入額外的背景。如果你想為例如 nord 主題加入一張額外的背景圖片，只要把檔案放進 `~/.config/omarchy/backgrounds/nord` 即可。

最簡單的做法是，在 Omarchy Menu 中前往 _Install > Style > Background_。這會開啟存放該主題背景的資料夾。按下 `Super + Shift + F` 啟動另一個檔案管理器，找到你的背景，再把它複製過去。現在，它就會出現在你可以使用 `Super + Ctrl + W` 選擇的背景選項之中。

背景也可以是影片，不僅限於靜態圖片。將 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 檔案放進同一個資料夾，它就會和圖片一起出現。影片由 OWE wallpaper engine 播放。它只為所有顯示器解碼一次影片，並透過預設音訊輸出播放其聲音，而且在沒有任何畫面能看到它時，就會停止播放。影片桌布消耗的電力仍然遠高於靜態桌布。

主題可以為靜態背景加入一段簡短的開場影片。對於 `backgrounds/road.webp`，對應的影片位於 `backgrounds/intros/road.mp4`。它會在開機時、切換到選用了該背景的主題時，以及選擇該背景時自動播放，然後回到靜態圖片。開場影片不會出現在背景選擇器中，也永遠不會循環播放。

關閉 _Appearance > Animations_ 也會關閉背景開場影片。Omarchy 在虛擬機器中預設就會這麼做。`omarchy theme bg intro toggle` 指令可以單獨切換開場影片。重新整理主題不會播放開場影片。

靜態圖片也可以有一段循環影片，也就是同一張圖片持續移動的安靜版本，位於 `backgrounds/loops/road.mp4`。它會取代靜態圖片播放，如果有開場影片，則在開場影片之後播放，並在動畫關閉時停止。循環影片不會出現在背景選擇器中，而且和任何影片背景一樣，耗電量都比靜態圖片高。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 找到大量精選的酷炫背景收藏。

鎖定畫面會顯示影片背景的一個靜止畫面，就像它顯示動畫 GIF 的一個靜止畫面一樣。
