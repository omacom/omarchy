# 背景

每个主题都自带一组背景，你也可以在 `~/.config/omarchy/backgrounds/[theme]` 中添加自己的额外背景。例如，如果你想为 nord 主题添加一张额外的背景图片，只需将文件放入 `~/.config/omarchy/backgrounds/nord` 即可。

最简单的做法是进入 Omarchy Menu 中的 _Install > Style > Background_。这将打开该主题的背景存放文件夹。按 `Super + Shift + F` 启动另一个文件管理器，找到你的背景，将其复制过去。现在，它就会出现在你可以使用 `Super + Ctrl + W` 切换选择的背景选项中。

背景也可以是视频，而不只是静态图片。将 `mp4`、`m4v`、`mov`、`webm`、`mkv` 或 `avi` 文件放入同一个文件夹，它就会与图片一起出现。视频由 OWE 壁纸引擎播放。它会为所有显示器一次性解码视频，并通过默认音频输出播放声音，而且当没有任何内容能看到它时，它会停止播放。视频壁纸的耗电量仍然远高于静态壁纸。

主题可以为静态背景包含一段简短的开场。对于 `backgrounds/road.webp`，对应的视频位于 `backgrounds/intros/road.mp4`。它会在开机时、切换到选中了该背景的主题时，以及选择该背景时自动播放，然后返回到静态图片。开场视频不会出现在背景选择器中，也永不循环播放。

关闭 _Appearance > Animations_ 也会关闭背景开场。Omarchy 在虚拟机中默认会这样做。`omarchy theme bg intro toggle` 命令可以单独切换开场。刷新主题不会播放开场。

静态图片还可以有一个循环，即同一个画面的安静版本，会持续动下去，位于 `backgrounds/loops/road.mp4`。它会取代静态图片播放，如果有开场，则在开场之后播放，并在关闭动画时停止。使用电池供电时，会改为显示静态图片，插上电源后循环就会回来。循环不会出现在背景选择器中。

你可以在 [dharmx/walls](https://github.com/dharmx/walls) 中找到大量精选的炫酷背景。

锁屏会显示视频背景的一个静态帧，就像它显示动态 GIF 的一个静态帧一样。
