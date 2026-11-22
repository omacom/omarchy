# 背景

每个主题都自带一组自己的背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中添加属于你自己的额外背景。如果你想给比如 nord 主题添加一张额外的背景图片，只需把文件放进 `~/.config/omarchy/backgrounds/nord` 即可。

最简单的做法是进入 Omarchy Menu 中的 _Install > Style > Background_。这会打开该主题存放背景的文件夹。按下 `Super + Shift + F` 再启动一个文件管理器，找到你的背景，把它复制过来。现在，它就会包含在你可以用 `Super + Ctrl + W` 进行选择的背景列表中。

背景也可以是视频，而不只是静态图片。将 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 文件放入同一个文件夹，它就会与图片一同显示。视频由 OWE 壁纸引擎播放。它会为所有显示器仅解码一次视频，并通过默认音频输出播放其声音；当没有任何地方能看到它时，它就会停止播放。视频壁纸的耗电量仍然比静态壁纸高得多。

主题可以为静态背景包含一段简短的开场。对于 `backgrounds/road.webp`，与之匹配的视频位于 `backgrounds/intros/road.mp4`。它会在开机时、切换到已选中该背景的主题时以及选择该背景时自动播放，然后返回到静态图片。开场视频不会出现在背景选择器中，也永不循环。

选择 _Appearance > Animations Off_ 也会关闭背景开场。Omarchy 在虚拟机中默认就会这样做。`omarchy theme bg intro toggle` 命令可以单独切换开场。刷新主题不会播放开场。

静态图片还可以有一个循环，也就是同一张图片的一个持续运动的安静版本，位于 `backgrounds/loops/road.mp4`。它会代替静态图片播放，如果有开场，则在开场之后播放，并在动画关闭时停止。使用电池时，会改为显示静态图片；一旦接通电源，循环就会恢复。循环不会出现在背景选择器中。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 中找到大量精心挑选的炫酷背景收藏。

锁屏会显示视频背景的一帧静态画面，就像它显示动画 GIF 的一帧静态画面一样。
