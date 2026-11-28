/* Unit tests for the desktop outro: handoff parsing, rebuilding the playback
 * against a frame, rejecting frames it does not reproduce, and the reverse
 * playback down to the blank canvas. */
#undef NDEBUG
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "outro.h"

static const char base[] =
    "version=2\neffect=decrypt\nseed=22321466108495961\ncycle=0\nstep=%u\n"
    "width=162\nheight=20\nfps=240\nspeed=2\nbackground=1a1b26\nforeground=ffffff\n"
    "input=embedded-logo-v2\nplayback=hold-final\n";

static size_t handoff_text(char *out, size_t size, unsigned int step, const char *extra)
{
  int n = snprintf(out, size, base, step);
  assert(n > 0 && (size_t)n < size);
  n += snprintf(out + n, size - (size_t)n, "%s", extra);
  assert((size_t)n < size);
  return (size_t)n;
}

static void test_parse(void)
{
  char text[1024];
  continuity_handoff_t h;
  size_t n;

  n = handoff_text(text, sizeof(text), 17, "");
  assert(continuity_handoff_parse(text, n, &h));
  assert(strcmp(h.effect, "decrypt") == 0 && h.seed == UINT64_C(22321466108495961));
  assert(h.step == 17 && h.hold_final && !h.outro_desktop && h.display_width == 0);
  assert(h.background == 0x1a1b26 && h.foreground == 0xffffff);

  n = handoff_text(text, sizeof(text), 17, "display=1728x1117\noutro=desktop\noutro_ms=700\n");
  assert(continuity_handoff_parse(text, n, &h));
  assert(h.outro_desktop && h.display_width == 1728 && h.display_height == 1117 && h.outro_ms == 700);

  /* Unknown keys are ignored. */
  n = handoff_text(text, sizeof(text), 1, "future=1\n");
  assert(continuity_handoff_parse(text, n, &h));

  /* Rejected: desktop without display or budget, out-of-range budget,
   * bad display, another engine size, missing newline, wrong version. */
  n = handoff_text(text, sizeof(text), 1, "outro=desktop\noutro_ms=700\n");
  assert(!continuity_handoff_parse(text, n, &h));
  n = handoff_text(text, sizeof(text), 1, "display=10x10\noutro=desktop\n");
  assert(!continuity_handoff_parse(text, n, &h));
  n = handoff_text(text, sizeof(text), 1, "display=10x10\noutro=desktop\noutro_ms=99\n");
  assert(!continuity_handoff_parse(text, n, &h));
  n = handoff_text(text, sizeof(text), 1, "display=0x10\n");
  assert(!continuity_handoff_parse(text, n, &h));
  n = handoff_text(text, sizeof(text), 1, "outro=sideways\n");
  assert(!continuity_handoff_parse(text, n, &h));
  n = handoff_text(text, sizeof(text), 1, "");
  assert(!continuity_handoff_parse(text, n - 1, &h));
  {
    char copy[1024];
    memcpy(copy, text, n);
    copy[8] = '3'; /* version=3 */
    assert(!continuity_handoff_parse(copy, n, &h));
    memcpy(copy, text, n);
    char *w = strstr(copy, "width=162");
    w[8] = '3';
    assert(!continuity_handoff_parse(copy, n, &h));
  }
  assert(!continuity_handoff_parse(NULL, 0, &h));
}

static void test_playback(void)
{
  char text[1024];
  continuity_handoff_t h;
  continuity_outro_t o, reference;
  const char *why;
  const uint32_t width = 800, height = 400; /* 400x200 logical at scale 2 */
  uint32_t *frame = malloc((size_t)width * height * 4U);
  uint32_t *argb = calloc((size_t)width * height, 4U);
  size_t n = handoff_text(text, sizeof(text), 300,
                          "display=400x200\noutro=desktop\noutro_ms=700\n");

  assert(frame != NULL && argb != NULL);
  assert(continuity_handoff_parse(text, n, &h));

  /* The published frame is rebuilt and accepted. */
  assert(continuity_outro_build(&reference, &h, width, height, 0, &why));
  continuity_outro_draw_frame(&reference, frame, width);
  assert(continuity_outro_prepare(&o, &h, frame, width, height, width, &why));
  assert(strcmp(why, "ok") == 0 && o.scale == 2);
  assert(o.rect_x == o.geometry.grid_x * 2U && o.rect_width == o.geometry.grid_width * 2U);
  continuity_outro_free(&o);

  /* One draw further (the uncounted completing draw) is accepted too. */
  continuity_outro_free(&reference);
  assert(continuity_outro_build(&reference, &h, width, height, 1, &why));
  continuity_outro_draw_frame(&reference, frame, width);
  assert(continuity_outro_prepare(&o, &h, frame, width, height, width, &why));
  continuity_outro_free(&o);
  continuity_outro_free(&reference);

  /* A frame it does not reproduce is refused, with nothing allocated. */
  assert(continuity_outro_build(&reference, &h, width, height, 0, &why));
  continuity_outro_draw_frame(&reference, frame, width);
  {
    uint32_t *pixel = &frame[(size_t)(reference.rect_y + 3U) * width + reference.rect_x + 3U];
    uint32_t saved = *pixel;
    *pixel ^= 0x010101U;
    assert(!continuity_outro_prepare(&o, &h, frame, width, height, width, &why));
    assert(strcmp(why, "frame-mismatch") == 0 && o.engine == NULL);
    *pixel = saved;
    frame[5] = 0x123456U; /* outside the grid */
    assert(!continuity_outro_prepare(&o, &h, frame, width, height, width, &why));
    assert(strcmp(why, "frame-not-plain") == 0 && o.engine == NULL);
    frame[5] = h.background;
  }
  /* A frame that is not an integer multiple of the display is refused. */
  assert(!continuity_outro_prepare(&o, &h, frame, width - 1U, height, width, &why));
  assert(strcmp(why, "scale") == 0);
  {
    continuity_handoff_t plymouth = h;
    plymouth.outro_desktop = false;
    assert(!continuity_outro_prepare(&o, &plymouth, frame, width, height, width, &why));
    assert(strcmp(why, "handoff-not-desktop") == 0);
  }

  /* The reverse playback starts on the published frame and ends on the
   * blank canvas, leaving everything outside the grid untouched. */
  assert(continuity_outro_prepare(&o, &h, frame, width, height, width, &why));
  assert(continuity_outro_begin(&o) && o.calls > 0);
  assert(!continuity_outro_begin(&o));
  for (size_t i = 0; i < (size_t)width * height; i++)
    argb[i] = 0xdeadbeefU;
  continuity_outro_render(&o, argb, width);
  {
    /* First outro frame == published frame (opaque where painted,
     * transparent where the plain background shows). */
    size_t painted = 0;
    for (uint32_t y = 0; y < o.rect_height; y++)
      for (uint32_t x = 0; x < o.rect_width; x++) {
        size_t at = (size_t)(o.rect_y + y) * width + o.rect_x + x;
        uint32_t px = argb[at];
        if (px == 0)
          assert(frame[at] == h.background);
        else
          assert((px >> 24) == 0xffU && (px & 0xffffffU) == frame[at]),
              painted++;
      }
    assert(painted > 0);
    assert(argb[0] == 0xdeadbeefU);
  }
  {
    uint64_t elapsed = 0;
    unsigned int frames = 0;
    while (!o.finished && frames < 1000) {
      elapsed += UINT64_C(8333333); /* 120 Hz */
      (void)continuity_outro_advance(&o, elapsed);
      frames++;
    }
    assert(o.finished && o.done == o.calls);
    assert(elapsed <= UINT64_C(700000000) + UINT64_C(8333333));
  }
  continuity_outro_render(&o, argb, width);
  for (uint32_t y = 0; y < o.rect_height; y++)
    for (uint32_t x = 0; x < o.rect_width; x++)
      assert(argb[(size_t)(o.rect_y + y) * width + o.rect_x + x] == 0);
  assert(!continuity_outro_advance(&o, UINT64_C(800000000)));
  continuity_outro_free(&o);
  continuity_outro_free(&reference);
  free(frame);
  free(argb);
}

static void test_alpha(void)
{
  uint8_t previous = 255;
  /* Opaque for the whole reverse playback, then revealed over 350 ms. */
  assert(continuity_outro_background_alpha(0, 700, 350) == 255);
  assert(continuity_outro_background_alpha(UINT64_C(700000000), 700, 350) == 255);
  assert(continuity_outro_background_alpha(UINT64_C(875000000), 700, 350) == 128);
  assert(continuity_outro_background_alpha(UINT64_C(1050000000), 700, 350) == 0);
  assert(continuity_outro_background_alpha(UINT64_C(2000000000), 700, 350) == 0);
  assert(continuity_outro_background_alpha(UINT64_C(700000001), 700, 0) == 0);
  for (uint64_t t = 0; t <= UINT64_C(1100000000); t += UINT64_C(5000000)) {
    uint8_t a = continuity_outro_background_alpha(t, 700, 350);
    assert(a <= previous);
    previous = a;
  }
}

int main(void)
{
  test_parse();
  test_playback();
  test_alpha();
  puts("desktop outro tests: PASS");
  return 0;
}
