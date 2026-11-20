# 背景

每個主題都附帶自己的一組背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中加入你自己的額外背景。如果你想為例如 nord 主題加入一張額外的背景圖片，只要把檔案放進 `~/.config/omarchy/backgrounds/nord` 就好。

最簡單的做法是前往 Omarchy Menu 中的 _Install > Style > Background_。這會開啟存放該主題背景的資料夾。按下 `Super + Shift + F` 開啟另一個檔案管理員，找到你的背景，把它複製過去。現在它就會出現在你可以用 `Super + Ctrl + W` 選擇的背景選項中。

背景也可以是影片，不只是靜態圖片。把 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 檔案放進同一個資料夾，它就會和圖片一起出現。影片由 OWE 桌布引擎播放。它會為所有螢幕將影片解碼一次，並透過預設音訊輸出播放聲音，而且在沒有任何地方看得到它時停止播放。影片桌布耗費的電力仍遠高於靜態桌布。

主題可以為靜態背景加入一段短短的開場。對於 `backgrounds/road.webp`，對應的影片位於 `backgrounds/intros/road.mp4`。它會在開機時、切換到已選取該背景的主題時，以及選擇該背景時自動播放，然後回到靜態圖片。開場影片不會出現在背景選擇器中，也永不循環播放。

關閉 _Appearance > Animations_ 也會關閉背景開場。Omarchy 在虛擬機器中預設就會這麼做。`omarchy theme bg intro toggle` 指令可以單獨切換開場。重新整理主題不會播放開場。

靜態圖片也可以有循環影片，也就是同一張圖片持續緩慢移動的安靜版本，位於 `backgrounds/loops/road.mp4`。它會取代靜態圖片播放，若有開場則在開場之後播放，並在關閉動畫時停止。使用電池時，會改為顯示靜態圖片，插上電源後循環影片就會回來。循環影片不會出現在背景選擇器中。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 找到大量精心挑選的酷炫背景收藏。

鎖定畫面會顯示影片背景的靜態畫面，就像顯示動畫 GIF 的靜態畫面一樣。
