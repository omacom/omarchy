/* Writes a matching handoff state and raw frame for the Wayland outro test:
 * outro-fixture RAW HANDOFF WIDTH HEIGHT SCALE SEED. The frame is drawn by the
 * outro renderer, so the client's verification accepts it when SEED matches
 * the handoff it writes (pass another SEED to the handoff to get a mismatch:
 * the frame always uses the default seed). */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "outro.h"

static void put32(unsigned char *p, uint32_t v)
{
  for (int i = 0; i < 4; i++)
    p[i] = (unsigned char)(v >> (8 * i));
}
static void put64(unsigned char *p, uint64_t v)
{
  for (int i = 0; i < 8; i++)
    p[i] = (unsigned char)(v >> (8 * i));
}

int main(int argc, char **argv)
{
  continuity_handoff_t h = {.seed = UINT64_C(22321466108495961), .step = 300, .background = 0x1a1b26, .foreground = 0xffffff, .hold_final = true, .outro_desktop = true, .outro_ms = 700};
  continuity_outro_t o;
  const char *why;
  struct timespec now;
  unsigned char header[48] = {0};
  uint32_t width, height, scale;
  uint32_t *pixels;
  FILE *f;

  if (argc != 7)
    return 2;
  width = (uint32_t)strtoul(argv[3], NULL, 10);
  height = (uint32_t)strtoul(argv[4], NULL, 10);
  scale = (uint32_t)strtoul(argv[5], NULL, 10);
  strcpy(h.effect, "decrypt");
  h.display_width = width / scale;
  h.display_height = height / scale;
  if (!continuity_outro_build(&o, &h, width, height, 0, &why)) {
    fprintf(stderr, "build: %s\n", why);
    return 1;
  }
  pixels = malloc((size_t)width * height * 4U);
  if (pixels == NULL)
    return 1;
  continuity_outro_draw_frame(&o, pixels, width);
  continuity_outro_free(&o);
  clock_gettime(CLOCK_BOOTTIME, &now);
  memcpy(header, "OMBFRAW1", 8);
  put32(header + 8, width);
  put32(header + 12, height);
  put32(header + 16, width * 4U);
  put32(header + 20, 0x34325258U);
  put64(header + 24, (uint64_t)width * height * 4U);
  put64(header + 32, (uint64_t)now.tv_sec * 1000000000U + (uint64_t)now.tv_nsec);
  f = fopen(argv[1], "wb");
  if (f == NULL || fwrite(header, 1, sizeof(header), f) != sizeof(header) ||
      fwrite(pixels, 4, (size_t)width * height, f) != (size_t)width * height || fclose(f) != 0)
    return 1;
  f = fopen(argv[2], "w");
  if (f == NULL)
    return 1;
  fprintf(f, "version=2\neffect=decrypt\nseed=%s\ncycle=0\nstep=300\nwidth=162\nheight=20\n"
             "fps=240\nspeed=2\nbackground=1a1b26\nforeground=ffffff\n"
             "input=embedded-logo-v2\nplayback=hold-final\ndisplay=%ux%u\noutro=desktop\n"
             "outro_ms=700\n",
          argv[6], h.display_width, h.display_height);
  free(pixels);
  return fclose(f) == 0 ? 0 : 1;
}
