/* Desktop outro for omarchy-plymouth-continuity: the reverse outro Plymouth
 * leaves to the desktop when its theme sets [ttfx] Outro=desktop.
 *
 * The plugin publishes, next to its last frame, the effect, seed and phase
 * that frame shows (/run/omarchy-plymouth-handoff.state). The engine is
 * deterministic, so the client rebuilds the same playback, checks that its
 * frame matches the published pixels exactly, and then plays the recorded
 * playback backwards, drawing the grid the way the plugin does. Everything
 * here is pure (no Wayland), so it is unit-tested on its own.
 */
#ifndef OMARCHY_CONTINUITY_OUTRO_H
#define OMARCHY_CONTINUITY_OUTRO_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "../plymouth-ttfx-plugin/state.h"
#include "../plymouth-ttfx-engine/include/ttfx_plymouth.h"

#define CONTINUITY_HANDOFF_PATH "/run/omarchy-plymouth-handoff.state"
#define CONTINUITY_HANDOFF_MAX_BYTES 1024U

typedef struct {
  char effect[64];
  uint64_t seed;
  uint64_t cycle;
  uint64_t step;
  uint32_t background;
  uint32_t foreground;
  bool hold_final;
  uint32_t display_width;
  uint32_t display_height;
  bool outro_desktop;
  unsigned int outro_ms;
} continuity_handoff_t;

/* Parses the plugin's handoff text. False for anything it does not fully
 * understand: another version, engine size, input or a malformed value. A
 * file without the optional display/outro keys parses with outro_desktop
 * false. */
bool continuity_handoff_parse(const char *text, size_t length, continuity_handoff_t *out);
/* Reads and parses `path` (a regular file under CONTINUITY_HANDOFF_MAX_BYTES). */
bool continuity_handoff_read(const char *path, continuity_handoff_t *out);

typedef struct {
  TtfxEngine *engine;
  ttfx_geometry_t geometry; /* logical, as the plugin computed it */
  uint32_t scale; /* physical pixels per logical pixel */
  uint32_t width; /* physical frame size */
  uint32_t height;
  uint32_t background;
  uint32_t foreground;
  unsigned int outro_ms;
  uint32_t calls;
  uint32_t done;
  bool started;
  bool finished;
  /* Physical rectangle the grid covers: the only pixels a frame changes. */
  uint32_t rect_x, rect_y, rect_width, rect_height;
} continuity_outro_t;

/* Rebuilds the playback for `h` at a physical frame size, replaying `extra`
 * draws past the published step, without looking at any frame. */
bool continuity_outro_build(continuity_outro_t *outro, const continuity_handoff_t *h,
                            uint32_t width, uint32_t height, unsigned int extra, const char **why);
/* Paints the exposed frame the plugin's way over the plain background into
 * `xrgb` (0x00RRGGBB words, `stride` pixels per row, physical size). */
void continuity_outro_draw_frame(const continuity_outro_t *outro, uint32_t *xrgb, size_t stride);
/* Rebuilds the playback for `h` and checks it against `frame` (0x00RRGGBB
 * words, `stride` pixels per row, width x height physical). On success the
 * outro is ready to start; on failure *why names the reason and nothing is
 * left allocated. */
bool continuity_outro_prepare(continuity_outro_t *outro, const continuity_handoff_t *h,
                              const uint32_t *frame, uint32_t width, uint32_t height,
                              size_t stride, const char **why);
/* Starts the reverse playback. False when the engine declines. */
bool continuity_outro_begin(continuity_outro_t *outro);
/* Advances the reverse playback to `elapsed_ns` since begin. True when the
 * exposed frame changed. Sets finished once the blank canvas is exposed. */
bool continuity_outro_advance(continuity_outro_t *outro, uint64_t elapsed_ns);
/* Draws the exposed frame's grid into `argb` (premultiplied ARGB8888 words,
 * `stride` pixels per row, physical frame size): the grid rectangle is
 * cleared to transparent, then every cell the plugin would paint is painted
 * opaque. Pixels outside the rectangle are left alone. */
void continuity_outro_render(const continuity_outro_t *outro, uint32_t *argb, size_t stride);
/* Background opacity (255 opaque .. 0) since the outro began: opaque while
 * the reverse playback runs (outro_ms), so the logo dissolves completely on
 * the boot background, then eased to transparent over reveal_ms to uncover
 * the desktop. */
#define CONTINUITY_OUTRO_REVEAL_MS 350U
uint8_t continuity_outro_background_alpha(uint64_t elapsed_ns, unsigned int outro_ms,
                                          unsigned int reveal_ms);
void continuity_outro_free(continuity_outro_t *outro);

#endif
