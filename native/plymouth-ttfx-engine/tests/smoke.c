#include "ttfx_plymouth.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHECK(condition, message)                                               \
  do {                                                                          \
    if (!(condition)) {                                                          \
      fprintf(stderr, "smoke failure: %s (line %d)\n", (message), __LINE__);   \
      goto cleanup;                                                              \
    }                                                                            \
  } while (0)

static int copy_snapshot(TtfxEngine *engine, TtfxCell **copy, size_t *count) {
  const TtfxCell *cells = NULL;
  uint32_t width = 0;
  uint32_t height = 0;
  if (ttfx_engine_cells(engine, &cells, count, &width, &height) !=
          TTFX_STATUS_OK ||
      cells == NULL || *count != (size_t)width * height || width != 16 ||
      height != 3) {
    return 0;
  }
  *copy = malloc(*count * sizeof(**copy));
  if (*copy == NULL) {
    return 0;
  }
  memcpy(*copy, cells, *count * sizeof(**copy));
  return 1;
}

int main(void) {
  static const uint8_t input[] = "Plymouth λ";
  TtfxEngine *engine = NULL;
  TtfxCell *first = NULL;
  TtfxCell *second = NULL;
  TtfxCell *loop_frame = NULL;
  TtfxCell *reset_frame = NULL;
  size_t count = 0;
  size_t other_count = 0;
  uint8_t looped = 99;
  int result = EXIT_FAILURE;

  CHECK(ttfx_engine_create("print", UINT64_C(0x12345678), input,
                           sizeof(input) - 1, 16, 3, 60, &engine) ==
            TTFX_STATUS_OK,
        "create real print effect");
  CHECK(engine != NULL, "create returned handle");
  CHECK(copy_snapshot(engine, &first, &count),
        "create exposes first full canvas");
  CHECK(ttfx_engine_step(engine, &looped) == TTFX_STATUS_OK && looped == 0,
        "step second frame");
  CHECK(copy_snapshot(engine, &second, &other_count), "copy second full canvas");
  CHECK(other_count == count && memcmp(first, second, count * sizeof(*first)) != 0,
        "first two snapshots are distinguishable");

  for (size_t step = 0; step < 10000; ++step) {
    CHECK(ttfx_engine_step(engine, &looped) == TTFX_STATUS_OK,
          "step until deterministic loop");
    if (looped != 0) {
      break;
    }
  }
  CHECK(looped == 1, "effect completed within safety bound");
  CHECK(copy_snapshot(engine, &loop_frame, &other_count), "copy terminal frame");
  CHECK(other_count == count &&
            memcmp(first, loop_frame, count * sizeof(*first)) != 0,
        "completion retains terminal frame, not the next cycle's first frame");

  {
    int has_lambda = 0;
    for (size_t cell = 0; cell < count; ++cell) {
      if (loop_frame[cell].codepoint == UINT32_C(0x03bb)) {
        has_lambda = 1;
      }
    }
    CHECK(has_lambda, "terminal snapshot preserves the Unicode lambda glyph");
  }
  CHECK(ttfx_engine_step(engine, &looped) == TTFX_STATUS_OK && looped == 1,
        "completion remains idempotent before explicit reset");
  {
    const TtfxCell *cells = NULL;
    uint32_t width = 0;
    uint32_t height = 0;
    CHECK(ttfx_engine_cells(engine, &cells, &other_count, &width, &height) ==
              TTFX_STATUS_OK && other_count == count &&
              memcmp(loop_frame, cells, count * sizeof(*cells)) == 0,
          "repeated completion preserves the exact terminal snapshot");
  }
  CHECK(ttfx_engine_reset(engine) == TTFX_STATUS_OK, "explicit reset");
  CHECK(copy_snapshot(engine, &reset_frame, &other_count), "copy reset frame");
  CHECK(other_count == count &&
            memcmp(first, reset_frame, count * sizeof(*first)) == 0,
        "reset restores deterministic first frame");

  looped = 99;
  CHECK(ttfx_engine_step(NULL, &looped) == TTFX_STATUS_INVALID_ARGUMENT &&
            looped == 0,
        "null step initializes output");
  CHECK(ttfx_engine_step(engine, NULL) == TTFX_STATUS_INVALID_ARGUMENT,
        "null step output rejected");
  CHECK(ttfx_engine_reset(NULL) == TTFX_STATUS_INVALID_ARGUMENT,
        "null reset rejected");

  {
    const TtfxCell *cells = (const TtfxCell *)(uintptr_t)1;
    size_t invalid_count = 99;
    uint32_t width = 99;
    uint32_t height = 99;
    CHECK(ttfx_engine_cells(NULL, &cells, &invalid_count, &width, &height) ==
              TTFX_STATUS_INVALID_ARGUMENT &&
              cells == NULL && invalid_count == 0 && width == 0 && height == 0,
          "invalid cells call initializes all outputs");
  }
  {
    TtfxEngine *invalid = (TtfxEngine *)(uintptr_t)1;
    uint8_t invalid_utf8[] = {0xff};
    CHECK(ttfx_engine_create(NULL, 1, input, sizeof(input) - 1, 16, 3, 60,
                             &invalid) == TTFX_STATUS_INVALID_ARGUMENT &&
              invalid == NULL,
          "null effect rejected and output initialized");
    CHECK(ttfx_engine_create("print", 1, invalid_utf8, sizeof(invalid_utf8), 16,
                             3, 60, &invalid) == TTFX_STATUS_INVALID_UTF8 &&
              invalid == NULL,
          "invalid UTF-8 rejected and output initialized");
  }
  {
    char unterminated[TTFX_MAX_EFFECT_NAME_BYTES];
    TtfxEngine *invalid = (TtfxEngine *)(uintptr_t)1;
    memset(unterminated, 'x', sizeof(unterminated));
    CHECK(ttfx_engine_create(unterminated, 1, input, sizeof(input) - 1, 16, 3,
                             60, &invalid) == TTFX_STATUS_INVALID_ARGUMENT &&
              invalid == NULL,
          "unterminated effect name rejected at bound");
  }

  result = EXIT_SUCCESS;
  printf("C smoke passed: %zu cells, distinct frames, loop/reset deterministic\n",
         count);

cleanup:
  free(reset_frame);
  free(loop_frame);
  free(second);
  free(first);
  ttfx_engine_free(engine);
  ttfx_engine_free(NULL);
  return result;
}
