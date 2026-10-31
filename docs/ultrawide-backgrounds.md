# 32:9 theme backgrounds

Each built-in still background has a same-stem `@32x9.svg` variant for a 5120×1440 display. The aspect-ratio resolver selects it automatically on a 32:9 screen; the background picker and current-background link continue to identify the canonical image.

## Original artwork

The SVG references its source raster directly, centers its complete composition, and scales it proportionally to the canvas height. All 98 composition source rasters are byte unchanged. Normal display resampling applies.

Ethereal's Roadster variant keeps its approved center in `backgrounds/ultrawide/3-roadster-starlight-source.webp`. The canonical Roadster uses the updated image from `quattro`; the companion source keeps the complete 32:9 composition pixel-identical to the reviewed artwork. The provenance manifest records both hashes.

The surrounding scenery lives in separate WebP side panels under each theme's `backgrounds/ultrawide/` directory. Generated scenery generally uses quality 95; revised Gruvbox panels use quality 98, and revised Last Horizon and Ristretto panels use lossless encoding. Keep these relative resources together when copying a theme. The dotted forearms use native SVG circles instead of raster side panels.

Six photo compositions blend the original's edge strips with registered generated context to remove visible scan edges and rectangular joins. Gruvbox 1 and 2 and Ristretto 2 use 64 display pixels on both sides; Last Horizon 4 uses 64 pixels on the right only. Last Horizon 2 and 3 use 256 pixels on both sides to cover the broader vignette in their original images. All widths refer to the 5120×1440 canvas. The masks use smooth opacity ramps and explicit canvas coordinates. Panels extend underneath the complete fade, with integer placement and additional coverage at fractional boundaries. The protected interior is opaque and pixel-exact against a source-only render. Last Horizon 4's left panel and left half are unchanged by this correction. The two dotted-hand variants have the black-edge allowance described below; the remaining 90 compositions preserve the complete original rectangle.

## Extensions

Scenery, photography, textures, and complex illustrations use generative outpainting through Codex's built-in image generator. Each side was generated with the adjacent original as context. Generated source context is discarded except in the six documented edge blends. The corrected panels are aligned to source features and calibrated against matching source regions before assembly.

Uniform backgrounds behind wordmarks and isolated motifs use the original field color. Designs with horizontal color bands continue their source edge colors by row. This preserves the existing typography, symbols, and line work without regenerating them.

The dotted extensions use generated anatomical forearms, bent elbows and partial shoulders, guided by the first generations. Their contours, changing dot sizes, highlights and underside shadows come from the generated anatomy. Stippling is rendered directly at final canvas coordinates. Wrist attachments use the actual first source column's individual dot positions, radii, brightness and spacing, with ordered row correspondence into the existing arm. This preserves both wrist contours without merging rows or leaving isolated underside dots. The wrist correction changes only the 384-pixel outer attachment regions. A later cleanup removes a hanging lobe below the far-left arm by tapering individual dots in the first 288 pixels; both accepted wrists, the right arm and every pixel outside that small underside region remain unchanged.

Completed boundary circles can overlap up to four pixels of empty black source margin. They are drawn above the source within that narrow allowance so the image boundary cannot clip a circle in half. Every original foreground pixel, including antialiased hand dots and the credit, remains unchanged; the protected interior also compares with absolute pixel error zero. The source file, hand placement and fingertip spacing remain unchanged.

Matte Black and Vantablack share the same canonical hand drawing and anatomical extensions.

Painted scenery matches the original interior palette separately from its darker scan edges. Coffee foliage follows the original depth of field. Last Horizon 2 and 3 regenerate the vignetted joins as continuous scenery and bokeh, retaining their protected central compositions. Last Horizon 4's dune descends out of the bottom of the original frame; its right extension continues the sky without adding a disconnected ridge. Missing fine grain in the coffee extensions and Last Horizon 4's right sky is matched to the source's channel covariance with reproducible noise.

[The provenance manifest](assets/ultrawide/provenance.json) records the source hashes, extension methods, and generation prompts. [The gallery](assets/ultrawide/gallery.md) shows all complete 32:9 compositions for review. Boot intro videos retain their existing framing.

## Generation recipe

Prepare a 5120×1440 composition with the original centered at its full proportional height. Split the new space into left and right jobs, each with adjacent source context on a 2560×1440 canvas. Request continuation of the existing scene, lighting, perspective, contours, texture, exposure, and depth of field, with no duplicate focal subjects, text, mirroring, tiling, cropping, or reframing. Register the generated context to the source and match its palette. Extract the outer scenery, retaining only the required underlap for the documented blends, and encode the panels. Reference the original above both panels in the SVG; use a mask only for the explicitly documented edge strips.

Review the assembled composition at native display resolution and in the running Background plugin: restoring the source during assembly can expose a mismatch that was absent in the generator output. Verify protected interiors against a source-only render with the edge mask removed. The gallery includes native-resolution seam and dot details as well as complete compositions.
