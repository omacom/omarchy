#ifndef TTFX_PLYMOUTH_H
#define TTFX_PLYMOUTH_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct TtfxEngine TtfxEngine;

typedef struct TtfxCell {
  /* First Unicode scalar value in the TTFX symbol, or U+0020 if empty. */
  uint32_t codepoint;
  /* 0xRRGGBBAA; meaningful only when the corresponding color flag is set. */
  uint32_t fg_rgba;
  uint32_t bg_rgba;
  uint32_t flags;
} TtfxCell;

#ifdef __cplusplus
static_assert(sizeof(TtfxCell) == 16, "TtfxCell ABI must be 16 bytes");
#else
_Static_assert(sizeof(TtfxCell) == 16, "TtfxCell ABI must be 16 bytes");
#endif

enum {
  TTFX_CELL_FG = 1u << 0,
  TTFX_CELL_BG = 1u << 1,
  TTFX_CELL_BOLD = 1u << 2,
  TTFX_CELL_DIM = 1u << 3,
  TTFX_CELL_ITALIC = 1u << 4,
  TTFX_CELL_UNDERLINE = 1u << 5,
  TTFX_CELL_BLINK = 1u << 6,
  TTFX_CELL_REVERSE = 1u << 7,
  TTFX_CELL_HIDDEN = 1u << 8,
  TTFX_CELL_STRIKE = 1u << 9
};

enum {
  TTFX_STATUS_OK = 0,
  TTFX_STATUS_INVALID_ARGUMENT = 1,
  TTFX_STATUS_INVALID_EFFECT = 2,
  TTFX_STATUS_INVALID_DIMENSIONS = 3,
  TTFX_STATUS_INVALID_FRAME_RATE = 4,
  TTFX_STATUS_INVALID_UTF8 = 5,
  TTFX_STATUS_OVERFLOW = 6,
  TTFX_STATUS_ENGINE_ERROR = 7,
  TTFX_STATUS_PANIC = 8,
  TTFX_STATUS_INPUT_TOO_LARGE = 9,
  TTFX_STATUS_POISONED = 10,
  /* begin_reverse: no usable recorded history (never enabled or dropped). */
  TTFX_STATUS_UNAVAILABLE = 11,
  /* The call does not apply to the current playback (forward vs reverse). */
  TTFX_STATUS_INVALID_STATE = 12
};

enum {
  /* Plays the animation endlessly, seamlessly restarting at the end. */
  TTFX_LOGO_MODE_LOOP = 0,
  /* Plays the animation exactly once, then holds the final frame. */
  TTFX_LOGO_MODE_ONE_TIME = 1,
  /* Plays the recorded playback backwards after ttfx_engine_begin_reverse,
   * ending on the blank canvas. */
  TTFX_LOGO_MODE_REVERSE = 2
};

enum {
  TTFX_MAX_EFFECT_NAME_BYTES = 128,
  TTFX_MAX_INPUT_BYTES = 64 * 1024,
  TTFX_MAX_WIDTH = 162,
  TTFX_MAX_HEIGHT = 40,
  TTFX_MAX_CELLS = 4800,
  TTFX_MAX_FPS = 240,
  TTFX_MAX_HISTORY_FRAMES = 4096,
  TTFX_MAX_REVERSE_CALLS = 100000
};

/*
 * Handles are single-threaded and non-reentrant. Every call for a handle must
 * run on its creating thread, with no concurrent access. Input and output
 * storage passed to an API must not overlap the handle or each other. If a
 * mutable call returns TTFX_STATUS_PANIC, the handle is poisoned: only
 * ttfx_engine_free is then valid; other calls return TTFX_STATUS_POISONED.
 *
 * effect must be readable through a NUL within TTFX_MAX_EFFECT_NAME_BYTES.
 * input_len must not exceed TTFX_MAX_INPUT_BYTES. Dimensions and fps must not
 * exceed TTFX_MAX_WIDTH, TTFX_MAX_HEIGHT, TTFX_MAX_CELLS, and TTFX_MAX_FPS.
 * On success, ttfx_engine_cells immediately exposes the complete deterministic
 * first frame; no ttfx_engine_step call is required before the first read.
 */
int32_t ttfx_engine_create(const char *effect, uint64_t seed,
                           const uint8_t *input, size_t input_len,
                           uint32_t width, uint32_t height, uint32_t fps,
                           TtfxEngine **out_engine);

/* Like ttfx_engine_create, with the embedding surface's 0xRRGGBB background. */
int32_t ttfx_engine_create_with_background(const char *effect, uint64_t seed,
                                           const uint8_t *input, size_t input_len,
                                           uint32_t width, uint32_t height, uint32_t fps,
                                           uint32_t background_rgb,
                                           TtfxEngine **out_engine);

/* The legacy out_looped name reports completion: 1 retains the terminal frame.
 * Further steps return 1 unchanged until ttfx_engine_reset is called. */
int32_t ttfx_engine_step(TtfxEngine *engine, uint8_t *out_looped);

/* Reconstruct the original effect and expose its deterministic first frame. */
int32_t ttfx_engine_reset(TtfxEngine *engine);

/*
 * Starts (max_frames 2..TTFX_MAX_HISTORY_FRAMES) or stops (max_frames 0)
 * recording the forward playback so it can later be played backwards. The
 * current frame is recorded first; every reset or loop restart begins a new
 * record. Recording only reads exposed frames: forward playback stays
 * byte-identical. max_bytes must hold at least one uncompressed frame
 * (width * height * sizeof(TtfxCell)); past max_frames or max_bytes every
 * other keyframe is dropped, so the record keeps spanning the whole cycle.
 * A later allocation failure silently drops the record; begin_reverse then
 * returns TTFX_STATUS_UNAVAILABLE. Not valid during a reverse playback.
 */
int32_t ttfx_engine_record_history(TtfxEngine *engine, uint32_t max_frames,
                                   size_t max_bytes);

/*
 * Prepares a reverse playback for TTFX_LOGO_MODE_REVERSE draws: from the
 * exposed frame back to the first recorded frame of the current cycle, at no
 * less than frames_per_call recorded frames per draw (faster when it would not
 * fit), then a dissolve of whatever that first frame still shows, and the
 * blank canvas (every cell U+0020 without flags) on the last draw.
 * *out_calls receives the exact number of draws, 1..max_calls
 * (max_calls <= TTFX_MAX_REVERSE_CALLS). It does not change the exposed
 * frame. TTFX_STATUS_UNAVAILABLE leaves the engine unchanged. Forward draws
 * and ttfx_engine_step return TTFX_STATUS_INVALID_STATE until
 * ttfx_engine_reset ends the reverse playback.
 */
int32_t ttfx_engine_begin_reverse(TtfxEngine *engine, uint32_t max_calls,
                                  uint32_t frames_per_call, uint32_t *out_calls);

/*
 * Draws the logo according to mode (TTFX_LOGO_MODE_*). Every caller keeps its
 * playback state exclusively through this function; the current frame is
 * always available through ttfx_engine_cells after the call.
 *
 * out_looped (may be NULL) is set to 1 only for the call in which a
 * TTFX_LOGO_MODE_LOOP playback wrapped to a fresh cycle. out_finished (may be
 * NULL) is set to 1 once a TTFX_LOGO_MODE_ONE_TIME playback has completed and
 * the final frame is being held, or once a TTFX_LOGO_MODE_REVERSE playback
 * exposes the blank canvas; it stays 1 on later calls. REVERSE without a
 * prepared reverse playback returns TTFX_STATUS_INVALID_STATE.
 */
int32_t ttfx_engine_draw_logo(TtfxEngine *engine, uint32_t mode,
                              uint8_t *out_looped, uint8_t *out_finished);

/*
 * Borrows a complete top-to-bottom, left-to-right row-major canvas. The cell
 * pointer is valid until the next mutable call or ttfx_engine_free(engine).
 */
int32_t ttfx_engine_cells(const TtfxEngine *engine, const TtfxCell **out_cells,
                          size_t *out_count, uint32_t *out_width,
                          uint32_t *out_height);

/* NULL is accepted. Every non-NULL handle must be freed exactly once. */
void ttfx_engine_free(TtfxEngine *engine);

#ifdef __cplusplus
}
#endif

#endif
