# Backgrounds

Every theme ships with its own set of backgrounds, and you can add extras of your own in `~/.config/omarchy/backgrounds/[theme]`. If you want to add an extra background image to, say, the nord theme, you just put the file in `~/.config/omarchy/backgrounds/nord`.

You can do this most easily by going to _Install > Style > Background_ in the Omarchy Menu. That'll bring up the folder where the backgrounds for that theme is stored. Hit `Super + Shift + F` to start another file manager, find your background, copy it over.  Now it'll be included in the choices of backgrounds you can select between using `Super + Ctrl + W`.

Backgrounds can be videos as well as stills. Drop an `mp4`, `m4v`, `mov`, `webm`, `mkv`, or `avi` file in the same folder and it appears alongside the images. Videos are played by the OWE wallpaper engine. It decodes the video once for all monitors and plays its sound through the default audio output, and it stops playback whenever nothing can see it. A video wallpaper still costs far more power than a still one.

Themes can include a short intro for a still background. For `backgrounds/road.webp`, the matching video lives at `backgrounds/intros/road.mp4`. It plays automatically at boot, when switching to a theme with that background selected, and when choosing that background, then returns to the still. Intro videos stay out of the background picker and never loop.

A still background can also come alive with effects, like the Catppuccin Totoro whose eyes follow your mouse. Effects are described in a small file beside the image: for `backgrounds/totoro.webp`, it lives at `backgrounds/effects/totoro.json`. For eyes, it lists where each eye sits in the image, in the image's own pixels, how large its white and pupil are and what colors they have. The eyes follow the pointer while it is over the desktop and keep looking where it last was when it moves onto a window. The file holds only positions and colors, so a theme from anywhere can ship one. For a background in `~/.config/omarchy/backgrounds/[theme]`, put the file in an `effects` folder there, and the eyes move as soon as you save it. The Catppuccin theme's `backgrounds/effects/1-totoro.json` makes a good starting point for your own, and a mistake in the file is explained in `journalctl --user -t omarchy-shell`.

Turning off _Appearance > Animations_ also turns off background intros, and effects like the Totoro eyes stay still. Omarchy does this by default in a virtual machine. The `omarchy theme bg intro toggle` command can toggle intros separately. Refreshing a theme does not play an intro.

You can find a huge collection of cool curated backgrounds in [dharmx/walls](https://github.com/dharmx/walls).

The lock screen shows a still frame of a video background, the same way it shows a still frame of an animated GIF.
