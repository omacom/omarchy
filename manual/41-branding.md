# Branding

Omarchy allows you to set your company logo or personal image for both the boot unlock, the screensaver, and the about screen.

### Boot unlock

You can use `omarchy plymouth preview` to see what your custom logo and colors would look like. It takes a background color, a text color, a logo png, and a path for the preview image:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Then apply the setup with `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, which will also give the SDDM login screen the same colors and logo. If you want to revert, you can use `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Screensaver

You can change the logo used for the screensaver under _Style > Screensaver_. It's an ASCII logo, so you can edit the text directly, but you can also hand it a png or svg image, and we'll convert that to ASCII. It looks pretty cool.

 ![branding-screensaver](images/branding-screensaver.webp)

The screensaver menu offers these choices:

- **Edit Text** opens `~/.config/omarchy/branding/screensaver.txt` in your editor. Type or paste whatever you like — ASCII art, your name, a rude word. Save and quit, and the screensaver fires up immediately so you can see it.
- **Set From Image** opens a file picker for PNG, JPEG, WebP or SVG, converts it to ASCII, and shows you the result. Logos with a clear silhouette work far better than photos.
- **Set Image Folder** converts a folder of PNG, JPEG or WebP images using the same converter, then plays the resulting text collection.
- **Set Text Folder** selects an existing folder of ASCII or braille `.txt` artworks.
- **Restore Default** puts the Omarchy logo back and clears any collection selection.

**Set From Image** and **Edit Text** also clear the collection selection after conversion or editor launch succeeds. Canceling the picker or a failed conversion leaves the selection unchanged.

#### Text collections

Use **Set Image Folder** to choose a folder, or run:

```bash
omarchy branding screensaver images ~/Pictures/giants
omarchy branding screensaver folder ~/Pictures/screensaver-art
```

Image folders are imported once into `~/.local/share/omarchy/screensavers/import-*`. Files are ordered numerically within their names (`1`, `2`, …, `18`); the generated text collection preserves that order. Each image is converted in colour by default (truecolour quadrant blocks at the converter's 80×26 maximum size); `omarchy-screensaver-import ~/Pictures/giants --mode braille` gives the monochrome style. Source images are unchanged. Run the import again to include later changes; conversion does not run during idle startup. Prior imports are retained so an existing selection is never deleted; you may remove unused import folders yourself.

Batch import accepts up to 128 visible PNG, JPEG or WebP images, with a 20 MiB limit per image. It skips hidden files, subfolders, symlinks and special files. An unsupported or unconvertible image aborts the import and preserves the previous selection. SVG remains available through **Set From Image**.

To configure a text source directly, add a `screensaver` block to `~/.config/omarchy/shell.json` alongside `idle`:

```json
"screensaver": {
  "source": "~/Pictures/screensaver-art"
}
```

The source can be an absolute path or a path starting with `~/`, pointing to either one text file or a directory of `.txt` files. A directory plays in filename order, advancing after each animation finishes and wrapping at the end. Each monitor runs its own animations, so changes are not synchronized between monitors. The existing `idle.screensaver` setting still controls when the screensaver starts.

Collections contain UTF-8 text, including braille and block characters. Convert images with `omarchy transcode ascii` first; `--mode color` keeps their colours. Colour travels as SGR sequences (attributes, 256-colour and truecolour forms with values up to 255) and is the only terminal control allowed: files containing any other escape sequence are skipped, as are empty, invalid, or oversized files. Plain text artwork keeps the effect's own final colours; artwork with colour settles on its colours. Each file may be at most 1 MiB, 128 lines, and 512 visible characters per line after tab expansion. Up to 128 artworks are loaded from a directory with at most 4096 entries. Hidden files, nested directories, symbolic-link entries, and special files are not played. The selected source itself may be a symbolic link.

The collection is copied for playback when the screensaver starts; edits appear the next time it opens. Omarchy never modifies the source. An unavailable or unusable source falls back to your existing screensaver logo. Remove `screensaver.source` to return to the live-editable logo, or choose **Set From Image**, **Edit Text**, or **Restore Default**. These menu actions clear the selection without deleting the collection.

### About screen

**Edit Text**, **Set From Image**, and **Restore Default** are also under _Style > About_ for the _About_ screen you get from the Omarchy menu, and they work identically — the file is `~/.config/omarchy/branding/about.txt`, and the About window pops up after each change. The About art is converted to a smaller size than the screensaver's, since it has to fit in a window rather than fill your display.

While the window is open a glint of green leans across the art every few seconds and then leaves it still again. Your own art gets it too, as long as every character in it is one column wide — anything _Set From Image_ produces is. Art built from emoji or double-width characters stays still instead, and so does the screen if you keep a fastfetch config of your own: a still logo in those cases is the animation keeping out of the way rather than failing, since sliding a glint across them would land the rest of the line in the wrong place.

 ![branding-about](images/branding-about.webp)

### Converting images yourself

Both of the _Set From Image_ options are just calling `omarchy transcode ascii`, which you can run directly if you want control over the conversion:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

It takes `--width` and `--height` in terminal columns and rows, a `--mode` of either `braille` (the default, and much finer) or `block`, a `--threshold` percentage for deciding which pixels count as part of the logo, and `--invert` for when your logo is light on a dark background. If a conversion comes out as a blob, the threshold is usually the knob to turn.

### Words instead of a logo

`omarchy ascii` draws text in Delta Corps Priest 1, the FIGlet font the Omarchy wordmark itself is drawn in, so a screensaver can say something rather than show a picture:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

It takes the text as arguments, or reads it from a pipe when given none. The font carries letters and spaces only — it was drawn without digits or punctuation — so anything else is dropped and named on stderr rather than quietly swallowed.
