#ifndef TTFX_PLYMOUTH_STATE_H
#define TTFX_PLYMOUTH_STATE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Step zero is the snapshot returned by create/reset (already first next_frame).
 * Loops reconstruct that same tuple, so cycle is informational, not replay work. */
typedef struct {
        uint64_t step;
        uint64_t cycle;
} ttfx_phase_t;

#define TTFX_HANDOFF_NAME "omarchy-plymouth-handoff.state"
#define TTFX_HANDOFF_TEMP ".omarchy-plymouth-handoff.state.tmp"
#define TTFX_RAW_NAME "omarchy-plymouth-handoff.raw"
#define TTFX_RAW_TEMP ".omarchy-plymouth-handoff.raw.tmp"
/* The last full repaint is kept at the panel's physical size for the fbcon
 * handoff on quit and for the raw file, so large HiDPI panels (3456x2234 on a
 * 16-inch MacBook Pro) are captured and published alike. */
#define TTFX_CAPTURE_MAX_WIDTH 8192U
#define TTFX_CAPTURE_MAX_HEIGHT 8192U
/* The raw file accepts every frame the capture accepts. Rows are converted
 * through a fixed TTFX_RAW_SCRATCH_PIXELS scratch (16 KiB), one write per
 * chunk, so the stack cost does not grow with the bound. */
#define TTFX_RAW_MAX_WIDTH TTFX_CAPTURE_MAX_WIDTH
#define TTFX_RAW_MAX_HEIGHT TTFX_CAPTURE_MAX_HEIGHT
#define TTFX_RAW_SCRATCH_PIXELS 4096U
/* A display that replaces another of the same width within this window is the
 * same panel seen by another driver (on Apple Silicon the firmware
 * framebuffer leaves out the notch rows the native driver adds on top). The
 * splash then starts where the old display drew it and glides into place. */
#define TTFX_DISPLAY_SWAP_WINDOW_NS UINT64_C(2000000000)
#define TTFX_DISPLAY_GLIDE_TICKS 96U
uint64_t ttfx_boottime_ns(void);
void ttfx_raw_clear(int directory);
bool ttfx_raw_publish(int directory, const uint32_t *pixels, uint32_t width,
                      uint32_t height, uint64_t captured_ns);
#define TTFX_HANDOFF_MAX_BYTES 512U
#define TTFX_HANDOFF_MAX_STEP UINT64_C(10000)
typedef struct {
        const char *effect;
        uint64_t seed;
        ttfx_phase_t phase;
        uint32_t width, height, fps, speed, background, foreground;
        bool hold_final;
} ttfx_handoff_t;
/* open verifies fixed /run, root ownership and tmpfs. No path/env overrides.
 * publish accepts only that trusted directory fd in production. */
int ttfx_handoff_open(void);
bool ttfx_handoff_publish(int directory, const ttfx_handoff_t *handoff);
void ttfx_handoff_clear(int directory);
void ttfx_handoff_close(int directory);

#define TTFX_FRAME_COUNT 120U
#define TTFX_GRID_COLUMNS 162U
#define TTFX_GRID_ROWS 20U
#define TTFX_REACTION_TICKS 168U
#define TTFX_FAILURE_CANDIDATE_TICKS 1200U
#define TTFX_REACTION_OFFSET_TICKS 24U
#define TTFX_PLAYBACK_STEPS_PER_TICK 2U
#define TTFX_FAST_FORWARD_STEPS_PER_TICK 8U

typedef enum {
        TTFX_PROMPT_NONE,
        TTFX_PROMPT_PASSWORD,
        TTFX_PROMPT_QUESTION
} ttfx_prompt_mode_t;

typedef enum {
        TTFX_PLAYBACK_SUBMIT_TO_FINISH,
        TTFX_PLAYBACK_CONTINUOUS
} ttfx_playback_mode_t;

typedef enum {
        TTFX_PLAYBACK_INPUT,
        TTFX_PLAYBACK_FAST_FORWARD,
        TTFX_PLAYBACK_FINAL
} ttfx_playback_phase_t;

typedef struct ttfx_message ttfx_message_t;

typedef struct {
        unsigned int frame;
        ttfx_prompt_mode_t prompt_mode;
        int bullets;
        char *prompt;
        char *entry_text;
        char *failure_candidate_prompt;
        char *message;
        ttfx_message_t *messages;
        bool message_visible;
        bool animation_enabled;
        bool rendering_failed;
        bool failure_candidate_ready;
        bool reaction_active;
        ttfx_playback_mode_t playback_mode;
        ttfx_playback_phase_t playback_phase;
        unsigned int failure_candidate_tick;
        unsigned int reaction_tick;
} ttfx_state_t;

typedef struct {
        bool prompt_visible;
        bool message_visible;
        bool prompt_label_available;
        bool message_label_available;
} ttfx_view_state_t;

typedef struct {
        bool exit_watch_attached;
} ttfx_loop_state_t;

typedef struct {
        bool required_widgets_ready;
} ttfx_load_state_t;

typedef struct {
        unsigned int columns;
        unsigned int rows;
        unsigned int cell_width;
        unsigned int cell_height;
        unsigned int grid_x;
        unsigned int grid_y;
        unsigned int grid_width;
        unsigned int grid_height;
} ttfx_geometry_t;

ttfx_state_t ttfx_state_initial(void);
void ttfx_state_destroy(ttfx_state_t *state);
void ttfx_state_tick(ttfx_state_t *state);
void ttfx_state_disable_animation(ttfx_state_t *state);
void ttfx_state_fail_rendering(ttfx_state_t *state);
void ttfx_state_set_normal(ttfx_state_t *state);
void ttfx_state_clear_prompt(ttfx_state_t *state);
bool ttfx_state_set_password(ttfx_state_t *state, const char *prompt, int bullets);
bool ttfx_state_set_playback_mode(ttfx_state_t *state, const char *mode);
unsigned int ttfx_state_engine_steps_per_tick(const ttfx_state_t *state);
void ttfx_state_confirm_success(ttfx_state_t *state);
void ttfx_state_engine_completed(ttfx_state_t *state);
bool ttfx_state_password_pending(const ttfx_state_t *state);
bool ttfx_state_reaction_active(const ttfx_state_t *state);
int ttfx_state_reaction_x_offset(const ttfx_state_t *state);
bool ttfx_state_reaction_row_red(const ttfx_state_t *state, unsigned int row);
bool ttfx_state_set_question(ttfx_state_t *state, const char *prompt, const char *entry_text);
bool ttfx_state_set_message(ttfx_state_t *state, const char *message);
bool ttfx_state_hide_message(ttfx_state_t *state, const char *message);
ttfx_view_state_t ttfx_view_state_initial(void);
bool ttfx_view_show_prompt(ttfx_view_state_t *state);
bool ttfx_view_hide_prompt(ttfx_view_state_t *state);
bool ttfx_view_show_message(ttfx_view_state_t *state);
bool ttfx_view_hide_message(ttfx_view_state_t *state);
bool ttfx_view_prompt_can_show(const ttfx_view_state_t *state);
bool ttfx_view_message_can_show(const ttfx_view_state_t *state);
void ttfx_view_degrade_prompt(ttfx_state_t *plugin_state, ttfx_view_state_t *view_state);
void ttfx_view_degrade_message(ttfx_state_t *plugin_state, ttfx_view_state_t *view_state);
ttfx_loop_state_t ttfx_loop_state_initial(void);
void ttfx_loop_watch_attached(ttfx_loop_state_t *state);
bool ttfx_loop_detach_watch(ttfx_loop_state_t *state);
ttfx_load_state_t ttfx_load_state_initial(void);
void ttfx_load_state_record_view(ttfx_load_state_t *state, bool loaded);
bool ttfx_load_state_can_show(const ttfx_load_state_t *state);
bool ttfx_dynamic_view_should_keep(bool loaded);
ttfx_geometry_t ttfx_geometry_for_view(unsigned int width, unsigned int height);
bool ttfx_display_swap_offset(unsigned int old_width, unsigned int old_height, unsigned int old_grid_y,
                              unsigned int new_width, unsigned int new_height, unsigned int new_grid_y,
                              int *offset);
int ttfx_glide_offset(int from, unsigned int tick, unsigned int total);
/* Copies a width x height frame into `destination` (rows `stride` bytes apart,
 * height + top rows tall) bottom-aligned under `top` rows filled with `fill`.
 * Only the first width pixels of each destination row are written. Returns
 * false, writing nothing, for a null buffer, an empty frame or a stride
 * shorter than one frame row. */
bool ttfx_compose_bottom_aligned(void *destination, size_t stride,
                                 const uint32_t *frame, uint32_t width, uint32_t height,
                                 uint32_t top, uint32_t fill);
unsigned int ttfx_geometry_x_edge(const ttfx_geometry_t *geometry, unsigned int column);

/* Firmware hold: while only firmware framebuffers drive the panel (on Apple
 * Silicon the device-tree simple-framebuffer, replaced by the native display
 * driver a few seconds into boot) the splash shows a static mark and starts
 * the animation once a native display is added, or after this deadline. */
#define TTFX_FIRMWARE_HOLD_NS UINT64_C(8000000000)
#define TTFX_FIRMWARE_MARK_LOGICAL_SIZE 128L
#define TTFX_FIRMWARE_DRIVER_NAME "simple-framebuffer"
#define TTFX_DEVICETREE_FRAMEBUFFER_PREFIX "framebuffer@"

typedef enum {
        TTFX_FIRMWARE_HOLD_AUTO,
        TTFX_FIRMWARE_HOLD_ON,
        TTFX_FIRMWARE_HOLD_OFF
} ttfx_firmware_hold_mode_t;

/* "true", "false" or "auto"; anything else, including NULL, is auto. */
ttfx_firmware_hold_mode_t ttfx_firmware_hold_mode_parse(const char *value);
/* True when `chosen_path` has an entry named framebuffer@<anything>. */
bool ttfx_devicetree_has_framebuffer(const char *chosen_path);
/* Auto enables the hold only when the device tree declares a framebuffer. */
bool ttfx_firmware_hold_resolve(ttfx_firmware_hold_mode_t mode, const char *chosen_path);
/* Notched Apple panels: m1n1 draws its boot logo centred on the whole panel,
 * then hands the OS (and U-Boot, so Limine too) a framebuffer that starts
 * below the notch, recording the notch height as apple,notch-height on the
 * DCP node. The rows hidden above the device-tree framebuffer in
 * `chosen_path`, read from the first dcp@* node under `soc_path` that has the
 * property; 0 when either is missing or unreadable, or when the framebuffer
 * still covers the notch (m1n1's asahi,show-notch=1, detected like m1n1
 * does: the height is not an exact 16:N of the width). */
uint32_t ttfx_devicetree_hidden_notch(const char *chosen_path, const char *soc_path);
/* How far, in logical pixels, a mark centred on the hidden-notch framebuffer
 * moves up to sit where m1n1's logo sat: half the notch, rounded to nearest
 * at `scale` (clamped to 1). */
long ttfx_firmware_mark_lift(uint32_t hidden_notch, int scale);
/* True when `device_name` is /dev/dri/card<digits> and
 * <sysfs_drm_root>/card<digits>/device/driver links to a driver directory
 * named simple-framebuffer. Anything else, including unreadable links, is
 * not a firmware display. */
bool ttfx_firmware_display(const char *device_name, const char *sysfs_drm_root);

/* Reverse outro: right before the handover to the desktop the effect plays
 * backwards until only the plain background is left, so the compositor starts
 * on the same colour. [ttfx] Outro=reverse|none selects it (absent or any
 * other value: reverse); OutroMs is its wall-clock budget in milliseconds
 * (absent or not a decimal number: 700; clamped to 100..1500, well inside
 * the 3 s `plymouth deactivate` timeout). */
#define TTFX_OUTRO_DEFAULT_MS 700U
#define TTFX_OUTRO_MIN_MS 100U
#define TTFX_OUTRO_MAX_MS 1500U
#define TTFX_OUTRO_TICKS_PER_SECOND 240U
/* True (reverse) unless the value is exactly "none". */
bool ttfx_outro_mode_parse(const char *value);
unsigned int ttfx_outro_ms_parse(const char *value);
/* Engine draw calls that fit the budget at one call per 240 Hz tick. */
uint32_t ttfx_outro_max_calls(unsigned int ms);
/* Draw calls to make now so that `done` of `calls` keeps pace with the
 * elapsed time: at least one per tick, all remaining ones once the budget
 * is spent, 0 when done. */
uint32_t ttfx_outro_due_calls(uint64_t elapsed_ns, unsigned int ms, uint32_t calls, uint32_t done);


#endif
