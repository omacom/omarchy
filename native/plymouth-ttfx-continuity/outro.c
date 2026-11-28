#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include "outro.h"

#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "../plymouth-ttfx-plugin/embedded-logo.h"
#include "../plymouth-ttfx-plugin/glyph-atlas.generated.h"

/* Same constants as the plugin (plugin.c): engine size and rate, steps per
 * draw while the outro plays, and the size of the forward-playback record. */
#define OUTRO_ENGINE_WIDTH 162U
#define OUTRO_ENGINE_HEIGHT 20U
#define OUTRO_ENGINE_FPS 240U
#define OUTRO_STEPS_PER_TICK 2U
#define OUTRO_HISTORY_FRAMES 128U
#define OUTRO_HISTORY_BYTES ((size_t)4U * 1024U * 1024U)
/* A held final frame is reached well inside this many draws. */
#define OUTRO_MAX_REPLAY_DRAWS 20000U

/* ---- handoff ---- */

static bool parse_u64(const char *text, size_t length, unsigned int base, uint64_t *out)
{
  uint64_t value = 0;

  if (length == 0 || length > 20)
    return false;
  for (size_t i = 0; i < length; i++) {
    char ch = text[i];
    unsigned int digit;
    if (ch >= '0' && ch <= '9')
      digit = (unsigned int)(ch - '0');
    else if (base == 16 && ch >= 'a' && ch <= 'f')
      digit = (unsigned int)(ch - 'a') + 10U;
    else
      return false;
    if (value > (UINT64_MAX - digit) / base)
      return false;
    value = value * base + digit;
  }
  *out = value;
  return true;
}

static bool value_is(const char *value, size_t length, const char *expected)
{
  return strlen(expected) == length && memcmp(value, expected, length) == 0;
}

bool continuity_handoff_parse(const char *text, size_t length, continuity_handoff_t *out)
{
  continuity_handoff_t h = {0};
  unsigned int seen = 0;
  enum {
    SEEN_VERSION = 1U << 0,
    SEEN_EFFECT = 1U << 1,
    SEEN_SEED = 1U << 2,
    SEEN_CYCLE = 1U << 3,
    SEEN_STEP = 1U << 4,
    SEEN_SIZE = 1U << 5,
    SEEN_RATE = 1U << 6,
    SEEN_COLORS = 1U << 7,
    SEEN_INPUT = 1U << 8,
    SEEN_PLAYBACK = 1U << 9
  };
  unsigned int width_height = 0, rate = 0, colors = 0;
  size_t position = 0;

  if (text == NULL || out == NULL || length == 0 || length >= CONTINUITY_HANDOFF_MAX_BYTES)
    return false;
  while (position < length) {
    const char *line = text + position;
    const char *end = memchr(line, '\n', length - position);
    const char *equals;
    size_t line_length, key_length, value_length;
    const char *value;
    uint64_t number;

    if (end == NULL)
      return false;
    line_length = (size_t)(end - line);
    position += line_length + 1U;
    equals = memchr(line, '=', line_length);
    if (equals == NULL)
      return false;
    key_length = (size_t)(equals - line);
    value = equals + 1;
    value_length = line_length - key_length - 1U;
#define KEY(name) (key_length == sizeof(name) - 1U && memcmp(line, name, key_length) == 0)
    if (KEY("version")) {
      if (!value_is(value, value_length, "2"))
        return false;
      seen |= SEEN_VERSION;
    } else if (KEY("effect")) {
      if (value_length == 0 || value_length >= sizeof(h.effect))
        return false;
      for (size_t i = 0; i < value_length; i++) {
        char ch = value[i];
        if (!((ch >= 'a' && ch <= 'z') ||
              (i > 0 && ((ch >= '0' && ch <= '9') || ch == '-'))))
          return false;
      }
      memcpy(h.effect, value, value_length);
      h.effect[value_length] = '\0';
      seen |= SEEN_EFFECT;
    } else if (KEY("seed")) {
      if (!parse_u64(value, value_length, 10, &h.seed))
        return false;
      seen |= SEEN_SEED;
    } else if (KEY("cycle")) {
      if (!parse_u64(value, value_length, 10, &h.cycle))
        return false;
      seen |= SEEN_CYCLE;
    } else if (KEY("step")) {
      if (!parse_u64(value, value_length, 10, &h.step) ||
          h.step > TTFX_HANDOFF_MAX_STEP)
        return false;
      seen |= SEEN_STEP;
    } else if (KEY("width") || KEY("height")) {
      if (!parse_u64(value, value_length, 10, &number) ||
          number != (KEY("width") ? OUTRO_ENGINE_WIDTH : OUTRO_ENGINE_HEIGHT))
        return false;
      if (++width_height == 2)
        seen |= SEEN_SIZE;
    } else if (KEY("fps") || KEY("speed")) {
      if (!parse_u64(value, value_length, 10, &number) ||
          number != (KEY("fps") ? OUTRO_ENGINE_FPS : OUTRO_STEPS_PER_TICK))
        return false;
      if (++rate == 2)
        seen |= SEEN_RATE;
    } else if (KEY("background") || KEY("foreground")) {
      if (value_length != 6 || !parse_u64(value, value_length, 16, &number))
        return false;
      if (KEY("background"))
        h.background = (uint32_t)number;
      else
        h.foreground = (uint32_t)number;
      if (++colors == 2)
        seen |= SEEN_COLORS;
    } else if (KEY("input")) {
      if (!value_is(value, value_length, "embedded-logo-v2"))
        return false;
      seen |= SEEN_INPUT;
    } else if (KEY("playback")) {
      if (value_is(value, value_length, "hold-final"))
        h.hold_final = true;
      else if (!value_is(value, value_length, "continuous"))
        return false;
      seen |= SEEN_PLAYBACK;
    } else if (KEY("display")) {
      const char *x = memchr(value, 'x', value_length);
      uint64_t w, hh;
      if (x == NULL || !parse_u64(value, (size_t)(x - value), 10, &w) ||
          !parse_u64(x + 1, value_length - (size_t)(x - value) - 1U, 10, &hh) ||
          w == 0 || hh == 0 || w > TTFX_CAPTURE_MAX_WIDTH || hh > TTFX_CAPTURE_MAX_HEIGHT)
        return false;
      h.display_width = (uint32_t)w;
      h.display_height = (uint32_t)hh;
    } else if (KEY("outro")) {
      if (value_is(value, value_length, "desktop"))
        h.outro_desktop = true;
      else if (!value_is(value, value_length, "plymouth"))
        return false;
    } else if (KEY("outro_ms")) {
      if (!parse_u64(value, value_length, 10, &number) ||
          number < TTFX_OUTRO_MIN_MS || number > TTFX_OUTRO_MAX_MS)
        return false;
      h.outro_ms = (unsigned int)number;
    }
    /* Unknown keys are ignored: newer plugins may add some. */
#undef KEY
  }
  if (seen != (SEEN_VERSION | SEEN_EFFECT | SEEN_SEED | SEEN_CYCLE | SEEN_STEP | SEEN_SIZE | SEEN_RATE | SEEN_COLORS | SEEN_INPUT | SEEN_PLAYBACK))
    return false;
  if (h.outro_desktop && (h.display_width == 0 || h.outro_ms == 0))
    return false;
  *out = h;
  return true;
}

bool continuity_handoff_read(const char *path, continuity_handoff_t *out)
{
  char text[CONTINUITY_HANDOFF_MAX_BYTES];
  struct stat st;
  ssize_t got;
  int fd = open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK);

  if (fd < 0)
    return false;
  if (fstat(fd, &st) != 0 || !S_ISREG(st.st_mode) || st.st_size <= 0 ||
      st.st_size >= (off_t)sizeof(text)) {
    close(fd);
    return false;
  }
  got = read(fd, text, sizeof(text));
  close(fd);
  return got == st.st_size && continuity_handoff_parse(text, (size_t)got, out);
}

/* ---- drawing (mirrors draw_grid in plugin.c) ---- */

static uint32_t rgba_over_rgb(uint32_t rgba, uint32_t background)
{
  uint32_t alpha = rgba & 0xffU;
  uint32_t inverse = 255U - alpha;
  uint32_t red = ((((rgba >> 24U) & 0xffU) * alpha) +
                  (((background >> 16U) & 0xffU) * inverse) + 127U) /
      255U;
  uint32_t green = ((((rgba >> 16U) & 0xffU) * alpha) +
                    (((background >> 8U) & 0xffU) * inverse) + 127U) /
      255U;
  uint32_t blue = ((((rgba >> 8U) & 0xffU) * alpha) +
                   ((background & 0xffU) * inverse) + 127U) /
      255U;
  return (red << 16U) | (green << 8U) | blue;
}

static size_t glyph_atlas_index(uint32_t codepoint)
{
  if (codepoint >= 33U && codepoint <= 126U)
    return (size_t)(codepoint - 33U);
  if (codepoint >= 174U && codepoint <= 451U)
    return 94U + (size_t)(codepoint - 174U);
  if (codepoint >= 9472U && codepoint <= 9598U)
    return 372U + (size_t)(codepoint - 9472U);
  if (codepoint >= 9608U && codepoint <= 9631U)
    return 499U + (size_t)(codepoint - 9608U);
  return (size_t)('?' - 33);
}

typedef struct {
  uint32_t *pixels;
  size_t stride;
  uint32_t width, height, scale;
  uint32_t alpha_bits; /* 0xff000000 for ARGB targets, 0 for XRGB */
} canvas_t;

/* A logical rectangle, scaled like Plymouth's device-scaled pixel buffer. */
static void fill(const canvas_t *canvas, long x, long y, unsigned long width, unsigned long height,
                 uint32_t rgb)
{
  long x0 = x * (long)canvas->scale, y0 = y * (long)canvas->scale;
  long x1 = (x + (long)width) * (long)canvas->scale;
  long y1 = (y + (long)height) * (long)canvas->scale;
  uint32_t word = canvas->alpha_bits | (rgb & 0xffffffU);

  if (x0 < 0)
    x0 = 0;
  if (y0 < 0)
    y0 = 0;
  if (x1 > (long)canvas->width)
    x1 = (long)canvas->width;
  if (y1 > (long)canvas->height)
    y1 = (long)canvas->height;
  for (long row = y0; row < y1; row++) {
    uint32_t *line = canvas->pixels + (size_t)row * canvas->stride;
    for (long column = x0; column < x1; column++)
      line[column] = word;
  }
}

static void draw_glyph(const canvas_t *canvas, long cx, long cy, unsigned long cw, unsigned long ch,
                       uint32_t codepoint, uint32_t color)
{
  const uint8_t *rows = &ttfx_decrypt_glyph_atlas[glyph_atlas_index(codepoint) * TTFX_GLYPH_HEIGHT];

  for (unsigned int glyph_y = 0U; glyph_y < TTFX_GLYPH_HEIGHT; glyph_y++) {
    uint8_t bits = rows[glyph_y];
    unsigned int glyph_x = 0U;
    unsigned long top = glyph_y * ch / TTFX_GLYPH_HEIGHT;
    unsigned long bottom = (glyph_y + 1U) * ch / TTFX_GLYPH_HEIGHT;
    if (bottom <= top)
      continue;
    while (glyph_x < TTFX_GLYPH_WIDTH) {
      unsigned int run_start;
      unsigned long left, right;
      while (glyph_x < TTFX_GLYPH_WIDTH && (bits & (uint8_t)(1U << glyph_x)) == 0U)
        glyph_x++;
      if (glyph_x == TTFX_GLYPH_WIDTH)
        break;
      run_start = glyph_x;
      while (glyph_x < TTFX_GLYPH_WIDTH && (bits & (uint8_t)(1U << glyph_x)) != 0U)
        glyph_x++;
      left = run_start * cw / TTFX_GLYPH_WIDTH;
      right = glyph_x * cw / TTFX_GLYPH_WIDTH;
      if (right <= left)
        continue;
      fill(canvas, cx + (long)left, cy + (long)top, right - left, bottom - top, color);
    }
  }
}

static void draw_cells(const continuity_outro_t *o, const canvas_t *canvas)
{
  const ttfx_geometry_t *g = &o->geometry;
  const TtfxCell *cells = NULL;
  size_t count = 0;
  uint32_t width = 0, height = 0;

  if (ttfx_engine_cells(o->engine, &cells, &count, &width, &height) != TTFX_STATUS_OK)
    return;
  for (unsigned int row = 0U; row < g->rows; row++) {
    for (unsigned int column = 0U; column < g->columns; column++) {
      size_t index = (size_t)row * width + column;
      unsigned int left = ttfx_geometry_x_edge(g, column);
      unsigned int right = ttfx_geometry_x_edge(g, column + 1U);
      long cx = (long)g->grid_x + (long)left;
      long cy = (long)(g->grid_y + row * g->cell_height);
      unsigned long cw = right - left, ch = g->cell_height;
      const TtfxCell *cell;
      uint32_t cell_background = o->background, foreground = o->foreground;
      bool has_foreground, has_background;

      if (index >= count || cw == 0U || ch == 0U)
        continue;
      cell = &cells[index];
      has_foreground = (cell->flags & TTFX_CELL_FG) != 0U;
      has_background = (cell->flags & TTFX_CELL_BG) != 0U;
      if (has_background)
        cell_background = rgba_over_rgb(cell->bg_rgba, o->background);
      if (has_foreground)
        foreground = rgba_over_rgb(cell->fg_rgba, cell_background);
      if ((cell->flags & TTFX_CELL_REVERSE) != 0U) {
        uint32_t swapped = cell_background;
        cell_background = foreground;
        foreground = swapped;
        has_background = true;
        has_foreground = true;
      }
      if (has_background)
        fill(canvas, cx, cy, cw, ch, cell_background);
      if (cell->codepoint != 0x20U && cell->codepoint != 0U && has_foreground &&
          (cell->flags & TTFX_CELL_HIDDEN) == 0U) {
        unsigned long half = ch / 2U;
        if (cell->codepoint == 0x2580U) {
          ch = half;
        } else if (cell->codepoint == 0x2584U) {
          cy += (long)half;
          ch -= half;
        } else if (cell->codepoint != 0x2588U) {
          draw_glyph(canvas, cx, cy, cw, ch, cell->codepoint, foreground);
          continue;
        }
        if (ch > 0U)
          fill(canvas, cx, cy, cw, ch, foreground);
      }
    }
  }
}

/* ---- playback ---- */

void continuity_outro_free(continuity_outro_t *o)
{
  if (o == NULL)
    return;
  ttfx_engine_free(o->engine);
  *o = (continuity_outro_t){0};
}

static bool replay_draw(continuity_outro_t *o, uint32_t mode, bool *finished)
{
  uint8_t looped = 0, done = 0;
  if (ttfx_engine_draw_logo(o->engine, mode, &looped, &done) != TTFX_STATUS_OK)
    return false;
  *finished = done != 0;
  return true;
}

/* Compares the grid rectangle of `frame` with the exposed engine frame drawn
 * the plugin's way over the background. */
static bool grid_matches(const continuity_outro_t *o, const uint32_t *frame, size_t stride,
                         uint32_t *scratch)
{
  canvas_t canvas = {.pixels = scratch, .stride = o->rect_width, .width = o->rect_width, .height = o->rect_height, .scale = o->scale, .alpha_bits = 0};
  continuity_outro_t shifted = *o;

  for (size_t i = 0; i < (size_t)o->rect_width * o->rect_height; i++)
    scratch[i] = o->background;
  /* Draw relative to the rectangle's origin. */
  shifted.geometry.grid_x = 0;
  shifted.geometry.grid_y = 0;
  draw_cells(&shifted, &canvas);
  for (uint32_t y = 0; y < o->rect_height; y++) {
    const uint32_t *source = frame + (size_t)(o->rect_y + y) * stride + o->rect_x;
    const uint32_t *expected = scratch + (size_t)y * o->rect_width;
    for (uint32_t x = 0; x < o->rect_width; x++)
      if ((source[x] & 0xffffffU) != expected[x])
        return false;
  }
  return true;
}

static bool outside_is_background(const continuity_outro_t *o, const uint32_t *frame, size_t stride)
{
  for (uint32_t y = 0; y < o->height; y++) {
    const uint32_t *line = frame + (size_t)y * stride;
    bool in_rows = y >= o->rect_y && y < o->rect_y + o->rect_height;
    for (uint32_t x = 0; x < o->width; x++) {
      if (in_rows && x >= o->rect_x && x < o->rect_x + o->rect_width) {
        x = o->rect_x + o->rect_width - 1U;
        continue;
      }
      if ((line[x] & 0xffffffU) != o->background)
        return false;
    }
  }
  return true;
}

bool continuity_outro_build(continuity_outro_t *o, const continuity_handoff_t *h,
                            uint32_t width, uint32_t height, unsigned int extra, const char **why)
{
  const char *reason = "invalid";
  bool finished = false;
  uint32_t mode;

  *o = (continuity_outro_t){0};
  if (h == NULL || why == NULL)
    goto fail;
  reason = "handoff-not-desktop";
  if (!h->outro_desktop)
    goto fail;
  /* Plymouth draws at an integer device scale: the physical frame is an
   * exact multiple of the logical display. */
  reason = "scale";
  if (h->display_width == 0 || h->display_height == 0 || width % h->display_width != 0 ||
      height % h->display_height != 0 ||
      width / h->display_width != height / h->display_height ||
      width / h->display_width == 0 || width / h->display_width > 8U)
    goto fail;
  o->scale = width / h->display_width;
  o->width = width;
  o->height = height;
  o->background = h->background;
  o->foreground = h->foreground;
  o->outro_ms = h->outro_ms;
  o->geometry = ttfx_geometry_for_view(h->display_width, h->display_height);
  reason = "geometry";
  if (o->geometry.cell_height == 0U || o->geometry.grid_width == 0U)
    goto fail;
  o->rect_x = o->geometry.grid_x * o->scale;
  o->rect_y = o->geometry.grid_y * o->scale;
  o->rect_width = o->geometry.grid_width * o->scale;
  o->rect_height = o->geometry.grid_height * o->scale;
  if (o->rect_x + o->rect_width > width || o->rect_y + o->rect_height > height)
    goto fail;
  reason = "engine";
  if (ttfx_engine_create_with_background(h->effect, h->seed, ttfx_embedded_logo,
                                         ttfx_embedded_logo_len, OUTRO_ENGINE_WIDTH,
                                         OUTRO_ENGINE_HEIGHT, OUTRO_ENGINE_FPS,
                                         h->background, &o->engine) != TTFX_STATUS_OK)
    goto fail;
  reason = "history";
  if (ttfx_engine_record_history(o->engine, OUTRO_HISTORY_FRAMES, OUTRO_HISTORY_BYTES) !=
      TTFX_STATUS_OK)
    goto fail;
  /* The phase counts the draws of the current cycle that advanced it;
   * cycles restart from the same first frame, so replaying the step
   * count from a fresh engine reproduces the published frame. */
  reason = "replay";
  mode = h->hold_final ? TTFX_LOGO_MODE_ONE_TIME : TTFX_LOGO_MODE_LOOP;
  for (uint64_t i = 0; i < h->step + extra; i++)
    if (!replay_draw(o, mode, &finished))
      goto fail;
  *why = "ok";
  return true;
fail:
  continuity_outro_free(o);
  if (why != NULL)
    *why = reason;
  return false;
}

void continuity_outro_draw_frame(const continuity_outro_t *o, uint32_t *xrgb, size_t stride)
{
  canvas_t canvas = {.pixels = xrgb, .stride = stride, .width = o->width, .height = o->height, .scale = o->scale, .alpha_bits = 0};

  for (uint32_t y = 0; y < o->height; y++)
    for (uint32_t x = 0; x < o->width; x++)
      xrgb[(size_t)y * stride + x] = o->background;
  if (o->engine != NULL)
    draw_cells(o, &canvas);
}

bool continuity_outro_prepare(continuity_outro_t *o, const continuity_handoff_t *h,
                              const uint32_t *frame, uint32_t width, uint32_t height,
                              size_t stride, const char **why)
{
  uint32_t *scratch = NULL;
  const char *reason = "invalid";

  if (frame == NULL || why == NULL || stride < width) {
    *o = (continuity_outro_t){0};
    if (why != NULL)
      *why = reason;
    return false;
  }
  /* The draw that completes a held playback is not counted in the
   * step, so a held frame may sit one draw further. */
  for (unsigned int extra = 0; extra < (h != NULL && h->hold_final ? 2U : 1U); extra++) {
    if (!continuity_outro_build(o, h, width, height, extra, why))
      return false;
    if (scratch == NULL)
      scratch = malloc((size_t)o->rect_width * o->rect_height * sizeof(*scratch));
    reason = "memory";
    if (scratch == NULL)
      break;
    reason = "frame-mismatch";
    if (grid_matches(o, frame, stride, scratch)) {
      free(scratch);
      if (!outside_is_background(o, frame, stride)) {
        continuity_outro_free(o);
        *why = "frame-not-plain";
        return false;
      }
      *why = "ok";
      return true;
    }
    continuity_outro_free(o);
  }
  free(scratch);
  continuity_outro_free(o);
  *why = reason;
  return false;
}

bool continuity_outro_begin(continuity_outro_t *o)
{
  uint32_t calls = 0;

  if (o->engine == NULL || o->started)
    return false;
  if (ttfx_engine_begin_reverse(o->engine, ttfx_outro_max_calls(o->outro_ms),
                                OUTRO_STEPS_PER_TICK, &calls) != TTFX_STATUS_OK ||
      calls == 0)
    return false;
  o->calls = calls;
  o->done = 0;
  o->started = true;
  return true;
}

bool continuity_outro_advance(continuity_outro_t *o, uint64_t elapsed_ns)
{
  uint32_t due;
  bool changed = false;

  if (!o->started || o->finished)
    return false;
  due = ttfx_outro_due_calls(elapsed_ns, o->outro_ms, o->calls, o->done);
  for (uint32_t i = 0; i < due && !o->finished; i++) {
    uint8_t finished = 0;
    if (ttfx_engine_draw_logo(o->engine, TTFX_LOGO_MODE_REVERSE, NULL, &finished) !=
        TTFX_STATUS_OK) {
      o->finished = true;
      return true;
    }
    o->done++;
    changed = true;
    if (finished)
      o->finished = true;
  }
  if (o->done >= o->calls)
    o->finished = true;
  return changed;
}

void continuity_outro_render(const continuity_outro_t *o, uint32_t *argb, size_t stride)
{
  canvas_t canvas = {.pixels = argb, .stride = stride, .width = o->width, .height = o->height, .scale = o->scale, .alpha_bits = 0xff000000U};

  for (uint32_t y = 0; y < o->rect_height; y++)
    memset(argb + (size_t)(o->rect_y + y) * stride + o->rect_x, 0,
           (size_t)o->rect_width * sizeof(*argb));
  if (o->engine != NULL)
    draw_cells(o, &canvas);
}

uint8_t continuity_outro_background_alpha(uint64_t elapsed_ns, unsigned int outro_ms,
                                          unsigned int reveal_ms)
{
  uint64_t hold = (uint64_t)outro_ms * UINT64_C(1000000);
  uint64_t span = (uint64_t)reveal_ms * UINT64_C(1000000);
  double t;

  if (elapsed_ns <= hold)
    return 255;
  if (span == 0 || elapsed_ns - hold >= span)
    return 0;
  t = (double)(elapsed_ns - hold) / (double)span;
  /* Smoothstep down from opaque to transparent. */
  t = t * t * (3.0 - 2.0 * t);
  return (uint8_t)(255.0 * (1.0 - t) + 0.5);
}
