# 背景

每個主題都隨附自己的一組背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中加入額外的背景。舉例來說，如果你想為 nord 主題新增一張背景圖片，只要把檔案放進 `~/.config/omarchy/backgrounds/nord` 即可。

最簡單的做法是前往 Omarchy Menu 中的 _Install > Style > Background_。這會開啟存放該主題背景的資料夾。按下 `Super + Shift + F` 開啟另一個檔案管理員，找到你的背景，把它複製過去。現在它就會出現在你使用 `Super + Ctrl + W` 切換背景時的選項中。

沒有自己背景的主題，會得到一張由其配色繪製而成的背景：以主題的強調色在背景色上繪製的 Omarchy logo。加入你自己的背景即可取代它。

背景也可以是影片，而不只是靜態圖片。把 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 檔案放進同一個資料夾，它就會和圖片一起出現。影片由 OWE wallpaper engine 播放。它只會為所有螢幕解碼一次影片，並透過預設音訊輸出來播放聲音，而且只要沒有任何地方看得到它，就會停止播放。影片背景耗費的電力還是比靜態背景高得多。

主題可以為靜態背景附上一段短短的開場影片。對於 `backgrounds/road.webp`，對應的影片位於 `backgrounds/intros/road.mp4`。它會在開機時、切換到選用該背景的主題時，以及選取該背景時自動播放，之後再回到靜態圖片。開場影片不會出現在背景選擇器中，也永不循環播放。

選擇 _Appearance > Animations Off_ 也會關閉背景開場影片。Omarchy 在虛擬機器中預設就會這麼做。`omarchy theme bg intro toggle` 指令可以單獨切換開場影片。重新整理主題時不會播放開場影片。

靜態圖片也可以有一段循環影片，也就是同一張圖片持續緩緩動著的安靜版本，位於 `backgrounds/loops/road.mp4`。它會取代靜態圖片播放；如果該圖片有開場影片，則會在開場之後播放；動畫關閉時就會停止。使用電池供電時，會改為顯示靜態圖片，接上電源後循環影片就會回來。循環影片不會出現在背景選擇器中。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 找到大量精選的酷背景收藏。

鎖定畫面會顯示影片背景的一格靜止畫面，就像它顯示動畫 GIF 的一格靜止畫面一樣。
