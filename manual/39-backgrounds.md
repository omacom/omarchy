# Backgrounds

Every theme ships with its own set of backgrounds, and you can add extras of your own in `~/.config/omarchy/backgrounds/[theme]`. If you want to add an extra background image to, say, the nord theme, you just put the file in `~/.config/omarchy/backgrounds/nord`.

You can do this most easily by going to _Install > Style > Background_ in the Omarchy Menu. That'll bring up the folder where the backgrounds for that theme is stored. Hit `Super + Shift + F` to start another file manager, find your background, copy it over.  Now it'll be included in the choices of backgrounds you can select between using `Super + Ctrl + W`.

Backgrounds can be videos as well as stills. Drop an `mp4`, `m4v`, `mov`, `webm`, `mkv`, or `avi` file in the same folder and it appears alongside the images. Videos are played by the OWE wallpaper engine. It decodes the video once for all monitors and plays its sound through the default audio output, and it stops playback whenever nothing can see it. A video wallpaper still costs far more power than a still one.

Themes can include a short intro for a still background. For `backgrounds/road.webp`, the matching video lives at `backgrounds/intros/road.mp4`. It plays automatically at boot, when switching to a theme with that background selected, and when choosing that background, then returns to the still. Intro videos stay out of the background picker and never loop.

Turning off _Appearance > Animations_ also turns off background intros. Omarchy does this by default in a virtual machine. The `omarchy theme bg intro toggle` command can toggle intros separately. Refreshing a theme does not play an intro.

A 360° photo works as a background too. Omarchy shows it as a view into the scene and turns that view as you switch workspaces, 36° for each one, so the ten workspaces go once around and workspace 10 sits beside workspace 1. It recognises a 360° photo by the Photo Sphere (GPano) metadata that 360° cameras and phones write, on an image twice as wide as it is tall. The same metadata's initial view heading, pitch and horizontal field of view set where workspace 1 looks and how much of the scene fits on the screen. To use a 360° image without that metadata, such as one from [Poly Haven](https://polyhaven.com/hdris), tag it once with `exiv2` (install it with `omarchy-pkg-add exiv2` if it is missing):

```bash
exiv2 -M"reg GPano http://ns.google.com/photos/1.0/panorama/" -M"set Xmp.GPano.ProjectionType equirectangular" -M"set Xmp.GPano.InitialHorizontalFOVDegrees 100" panorama.jpg
```

Turning off _Appearance > Animations_ makes the view jump to each workspace instead of turning. The lock screen and the background picker show a 360° photo flat.

You can find a huge collection of cool curated backgrounds in [dharmx/walls](https://github.com/dharmx/walls).

The lock screen shows a still frame of a video background, the same way it shows a still frame of an animated GIF.
