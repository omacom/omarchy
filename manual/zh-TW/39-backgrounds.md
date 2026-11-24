# 背景

每個主題都附帶自己的一組背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中加入你自己的額外背景。如果你想為 nord 主題多加一張背景圖片，只要把檔案放進 `~/.config/omarchy/backgrounds/nord` 就好。

最簡單的做法，是在 Omarchy Menu 中前往 _Install > Style > Background_。這樣就會開啟存放該主題背景的資料夾。按下 `Super + Shift + F` 開啟另一個檔案管理員，找到你的背景，再把它複製過去。現在它就會出現在你可以用 `Super + Ctrl + W` 選擇切換的背景選項中。

背景除了可以是靜態圖片，也可以是影片。把 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 檔案放進同一個資料夾，它就會和圖片一起出現。影片由 OWE 桌布引擎播放。它會為所有螢幕只解碼一次影片，並透過預設音訊輸出來播放聲音，而且只要沒有任何東西看得到它，就會停止播放。影片桌布耗費的電力仍然遠比靜態桌布多得多。

主題可以為靜態背景包含一段簡短的開場影片。對於 `backgrounds/road.webp`，對應的影片位於 `backgrounds/intros/road.mp4`。它會在開機時、切換到選用該背景的主題時，以及選擇該背景時自動播放，然後回到靜態圖片。開場影片不會出現在背景選擇器中，也永遠不會循環播放。

選擇 _Appearance > Animations Off_ 也會關閉背景開場影片。Omarchy 在虛擬機器中預設就會這麼做。`omarchy theme bg intro toggle` 指令可以單獨切換開場影片。重新整理主題不會播放開場影片。

靜態圖片也可以有循環影片，也就是同一張圖片持續移動的安靜版本，位於 `backgrounds/loops/road.mp4`。它會取代靜態圖片的位置播放；如果有開場影片，則在開場影片之後播放，並在動畫關閉時停止。使用電池時，會改為顯示靜態圖片，插上電源後循環影片就會回來。循環影片不會出現在背景選擇器中。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 中找到大量精心挑選的酷背景收藏。

鎖定畫面會顯示影片背景的靜態畫格，就像它顯示動畫 GIF 的靜態畫格一樣。
