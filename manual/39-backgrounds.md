# Backgrounds

Every theme ships with its own set of backgrounds, and you can add extras of your own in `~/.config/omarchy/backgrounds/[theme]`. If you want to add an extra background image to, say, the nord theme, you just put the file in `~/.config/omarchy/backgrounds/nord`.

You can do this most easily by going to _Install > Style > Background_ in the Omarchy Menu. That'll bring up the folder where the backgrounds for that theme is stored. Hit `Super + Shift + F` to start another file manager, find your background, copy it over.  Now it'll be included in the choices of backgrounds you can select between using `Super + Ctrl + Space`.

Backgrounds can be videos as well as stills. Drop an `mp4`, `m4v`, `mov`, `webm`, `mkv`, or `avi` file in the same folder and it appears alongside the images. Videos are played by the OWE wallpaper engine. It decodes the video once for all monitors and plays its sound through the default audio output, and it stops playback whenever nothing can see it. The lock screen draws the same decode, muted, through OWE. A video wallpaper still costs far more power than a still one.

A still background can also have an intro: a short video that plays once when you log in and whenever you switch to that background, and that ends on the still itself. Put it in an `intros` folder next to the still and give it the same name, so `~/.config/omarchy/backgrounds/nord/intros/city.mp4` plays before `~/.config/omarchy/backgrounds/nord/city.webp`. A theme's own backgrounds can have intros too: put the intro in `~/.config/omarchy/backgrounds/[theme]/intros` under the name of the theme's background file. At login the intro starts right away and fades into the background at the end. When you switch to the background, it shows first and then fades into the intro. So start the video on its first scene rather than fading up from black, and finish it on a frame that matches the still. Intros are skipped when animations are turned off. Run `omarchy theme bg intro` to watch the current background's intro again.

You can find a huge collection of cool curated backgrounds on https://github.com/dharmx/walls.

Video backgrounds keep a cached still on the lock screen while playback is paused or unavailable. Animated GIFs play on the desktop and show a still frame on the lock screen.
