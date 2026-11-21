# Backgrounds

Every theme ships with its own set of backgrounds, and you can add extras of your own in `~/.config/omarchy/backgrounds/[theme]`. If you want to add an extra background image to, say, the nord theme, you just put the file in `~/.config/omarchy/backgrounds/nord`.

You can do this most easily by going to _Install > Style > Background_ in the Omarchy Menu. That'll bring up the folder where the backgrounds for that theme is stored. Hit `Super + Shift + F` to start another file manager, find your background, copy it over.  Now it'll be included in the choices of backgrounds you can select between using `Super + Ctrl + W`.

Backgrounds can be videos as well as stills. Drop an `mp4`, `m4v`, `mov`, `webm`, `mkv`, or `avi` file in the same folder and it appears alongside the images. Videos are played by the OWE wallpaper engine. It decodes the video once for all monitors and plays its sound through the default audio output, and it stops playback whenever nothing can see it. A video wallpaper still costs far more power than a still one.

Themes can include a short intro for a still background. For `backgrounds/road.webp`, the matching video lives at `backgrounds/intros/road.mp4`. It plays automatically at boot, when switching to a theme with that background selected, and when choosing that background, then returns to the still. Intro videos stay out of the background picker and never loop.

Choosing _Appearance > Animations Off_ also turns off background intros. Omarchy does this by default in a virtual machine. The `omarchy theme bg intro toggle` command can toggle intros separately. Refreshing a theme does not play an intro.

A theme's backgrounds can also rotate on their own. `omarchy theme bg rotate on` turns that on, `omarchy theme bg rotate off` turns it off, and `omarchy theme bg interval 30` sets how many minutes to wait between changes, from 1 to 1440. While rotation is on, the background advances to the next one in the theme every interval. The same controls sit at the bottom of the background picker.

A still can also have a loop, a quiet version of the same picture that keeps moving, at `backgrounds/loops/road.mp4`. It plays in the still's place, after its intro if it has one, and stops when animations are turned off. On battery, the still shows instead, and the loop comes back once you plug in. Loops stay out of the background picker.

You can find a huge collection of cool curated backgrounds in [dharmx/walls](https://github.com/dharmx/walls).

The lock screen shows a still frame of a video background, the same way it shows a still frame of an animated GIF.
