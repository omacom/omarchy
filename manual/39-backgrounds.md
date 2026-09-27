# Backgrounds

Every theme ships with its own set of backgrounds, and you can add extras of your own in `~/.config/omarchy/backgrounds/[theme]`. If you want to add an extra background image to, say, the nord theme, you just put the file in `~/.config/omarchy/backgrounds/nord`.

You can do this most easily by going to _Install > Style > Background_ in the Omarchy Menu. That'll bring up the folder where the backgrounds for that theme is stored. Hit `Super + Shift + F` to start another file manager, find your background, copy it over.  Now it'll be included in the choices of backgrounds you can select between using `Super + Ctrl + Space`.

When choosing a background with `Super + Ctrl + Space`, you can adjust the horizontal crop alignment for wide wallpapers using the `Up` and `Down` arrow keys or by clicking the on-screen alignment buttons (`Left`, `25%`, `Center`, `75%`, `Right`). Your chosen alignment is saved per image in `~/.config/omarchy/background-alignments.json` and automatically applied across both your desktop and lock screen. (Video backgrounds are played by the OWE wallpaper engine with standard center framing).

Backgrounds can be videos as well as stills. Drop an `mp4`, `m4v`, `mov`, `webm`, `mkv`, or `avi` file in the same folder and it appears alongside the images. Videos are played by the OWE wallpaper engine. It decodes the video once for all monitors and plays its sound through the default audio output, and it stops playback whenever nothing can see it. The lock screen draws the same decode, muted, through OWE. A video wallpaper still costs far more power than a still one.

You can find a huge collection of cool curated backgrounds on https://github.com/dharmx/walls.

Video backgrounds keep a cached still on the lock screen while playback is paused or unavailable. Animated GIFs play on the desktop and show a still frame on the lock screen.
