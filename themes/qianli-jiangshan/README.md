# Qianli Jiangshan · 千里江山

A blue-green Omarchy theme inspired by Wang Ximeng’s *A Thousand Li of Rivers and Mountains* (千里江山图, 1113). Mineral-blue peaks, jade water, aged silk, and ink become a quiet dark palette for everyday work.

![Qianli Jiangshan artwork and palette study](preview.png)

*Artwork and palette study; live Omarchy desktop verification is pending. This image is not a desktop capture.*

## Design

Deep ink-blue surfaces keep the landscape luminous. Warm silk-colored text softens the contrast, while jade highlights make focus and selections clear. Cinnabar, ochre, and muted violet give diagnostics and terminal output distinct roles without overpowering the blue-green foundation.

| Role | Color | Inspiration |
| --- | --- | --- |
| Background | `#101f23` | Ink in the mountain folds |
| Foreground | `#dad7bf` | Light on aged silk |
| Accent | `#6fc3b5` | Jade-green water |
| Blue | `#7bb4d5` | Mineral-blue peaks |
| Green | `#98b77e` | Malachite slopes |
| Yellow | `#c5a868` | Warm ochre |
| Red | `#e39484` | Cinnabar seals |

The theme uses Omarchy’s native `colors.toml` palette and `Yaru-prussiangreen` icons. Omarchy generates its terminal, editor, browser, and shell themes from this palette; no app-specific overrides or executable theme files are needed. Designed for Omarchy 4 / Quattro.

## Color method

The palette follows [OKSolar’s](https://meat.io/oksolar) approach of balancing colors in [OKLab](https://bottosson.github.io/posts/oklab/). The six normal ANSI hues plus orange share a target lightness of **0.742509**; the six bright hues share **0.813115**. Each target is the original tier’s mean lightness, minimizing squared OKLab displacement while retaining the original hue and chroma before sRGB rounding. The regular tier’s lightness spread falls from 0.08235 to **0.00225**, so blue and yellow have similar visual weight.

Selection, muted text, and brown are adjusted together to minimize their squared lightness changes under a 4.6:1 continuous contrast target. All syntax hues and muted text exceed **4.5:1** against the selection background after 8-bit sRGB rounding. OKLab balances approximate perceived lightness; linearized sRGB luminance separately verifies text contrast. The ink backgrounds, warm primary text, jade accent, and painting crops retain their original colors.

## Wallpapers

Four carefully framed views of the supplied painting sections, each **3840 × 2160**, in WebP format:

| Wallpaper | Composition |
| --- | --- |
| [Azure Summits](backgrounds/1-azure-summits.webp) | Layered mineral-blue mountains and sheltered valleys; the default view |
| [River Crossing](backgrounds/2-river-crossing.webp) | A long bridge between mountains, with open silk above |
| [High Ridge](backgrounds/3-high-ridge.webp) | A soaring peak above a dense green foothill landscape |
| [Distant Shores](backgrounds/4-distant-shores.webp) | Quiet water and distant islands, with generous open space |

These are faithful crops, with color-managed conversion to sRGB and proportional Lanczos resampling. The source scans are 1600 pixels high, so these are 4K output files rather than native 4K scans. No new scenery, recoloring, sharpening, or generative processing was added. The reference scans and full master painting are not distributed.

## Install

The repository is currently prepared locally and has not been published. After publication at the planned URL:

```bash
omarchy theme install https://github.com/xguot/omarchy-qianli-jiangshan-theme
```

For a local checkout whose root contains this README and `colors.toml`, copy it into your user themes and select it:

```bash
mkdir -p "$HOME/.config/omarchy/themes/qianli-jiangshan"
cp -R colors.toml icons.theme preview.png backgrounds README.md LICENSE "$HOME/.config/omarchy/themes/qianli-jiangshan/"
omarchy theme set qianli-jiangshan
```

Choose another wallpaper from Omarchy’s background picker. Omarchy controls fonts, spacing, and window behavior; this theme changes the palette, icons, and artwork.

## Validation

The official registry validator passes local content validation with no errors or warnings. Omarchy’s focused template checks pass in a disposable Linux container, and all 20 generated app configurations have resolved palette placeholders; their TOML and JSON outputs parse successfully. This validates configuration generation, not a running desktop or a published GitHub repository.

Foreground text measures **11.63:1** contrast against the main background; muted text measures **6.79:1**. Selected terminal text measures **9.68:1**, and the lowest named semantic color measures **5.59:1** against the lighter background. Syntax colors and muted text retained over the selection background measure at least **4.56:1**. These measurements describe the palette; they do not replace application testing.

A running Omarchy desktop is still required to verify the bar, menu, terminal, editor, notifications, and lock screen together before release.

## Artwork and attribution

**Wang Ximeng (王希孟), *A Thousand Li of Rivers and Mountains* (千里江山图), 1113.** Ink and color on silk, handscroll, 51.3 × 1191.5 cm. Collection: The Palace Museum, Beijing. This theme is an independent tribute and is not affiliated with the museum.

The supplied scans exactly match these Wikimedia Commons files (verified by SHA-1):

| Source | Commons rights statement | Used for |
| --- | --- | --- |
| [Section 1][section-1], uploaded by Dale1 stolaf | CC0 1.0 | Azure Summits, River Crossing |
| [Section 1c][section-c], uploaded by Eugene a | Public-domain artwork / PD-Art reproduction | High Ridge |
| [Section 1e][section-e], uploaded by Eugene a | Public-domain artwork / PD-Art reproduction | Distant Shores |

Commons identifies the historical painting as public domain. Section 1 carries a [CC0 1.0 dedication](https://creativecommons.org/publicdomain/zero/1.0/); the other two file pages carry public-domain and faithful reproduction notices. Credit for the painting remains with Wang Ximeng; the source pages document the reproductions’ provenance and rights statements.

Theme palette, documentation, and preview layout are available under the [MIT license](LICENSE). That license does not claim ownership of, or replace the rights statements for, the historical artwork. Attribution is retained here and in `LICENSE`, which Omarchy includes with marketplace installations.

## Theme conventions

Prepared against the [official theme guide](https://omarchy.org/manual/making-your-own-theme/) and [theme registry requirements](https://github.com/omacom/omarchy-theme-registry). Registry submission uses its [Submit a theme issue form](https://github.com/omacom/omarchy-theme-registry/issues/new?template=submit-theme.yml); the registry bot validates the repository and opens the listing PR.

[section-1]: https://commons.wikimedia.org/wiki/File:A_Thousand_Li_of_Rivers_and_Mountains_Section_1.jpg
[section-c]: https://commons.wikimedia.org/wiki/File:1c_Wang_Ximeng._A_Thousand_Li_of_Rivers_and_Mountains._%2851,3x1191,5cm%291113._%28section%29_Palace_museum,_Beijing.jpg
[section-e]: https://commons.wikimedia.org/wiki/File:1e_Wang_Ximeng._A_Thousand_Li_of_Rivers_and_Mountains._%2851,3x1191,5cm%291113._%28section%29_Palace_museum,_Beijing.jpg
