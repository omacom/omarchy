#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include "state.h"
#include <dirent.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/vfs.h>
#include <linux/magic.h>
#include <unistd.h>

#include <stdlib.h>
#include <string.h>

#include <time.h>

uint64_t ttfx_boottime_ns(void)
{
        struct timespec now;
        if (clock_gettime(CLOCK_BOOTTIME, &now) != 0 || now.tv_sec < 0)
                return 0;
        return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

void ttfx_raw_clear(int directory)
{
        if (directory >= 0)
                (void)unlinkat(directory, TTFX_RAW_NAME, 0);
}

static void put_little(uint8_t *out, uint64_t value, unsigned int bytes)
{
        for (unsigned int i = 0; i < bytes; i++)
                out[i] = (uint8_t)(value >> (i * 8U));
}

bool ttfx_raw_publish(int directory, const uint32_t *pixels, uint32_t width,
                      uint32_t height, uint64_t captured_ns)
{
        uint8_t header[48] = {0};
        uint8_t row[TTFX_RAW_SCRATCH_PIXELS * 4U];
        int file = -1;
        bool created = false;
        uint64_t now = ttfx_boottime_ns();
        if (directory < 0)
                return false;
        if (!pixels || !width || !height || width > TTFX_RAW_MAX_WIDTH ||
            height > TTFX_RAW_MAX_HEIGHT || !captured_ns || captured_ns > now ||
            now - captured_ns > UINT64_C(30000000000))
                goto fail;
        memcpy(header, "OMBFRAW1", 8);
        put_little(header + 8, width, 4);
        put_little(header + 12, height, 4);
        put_little(header + 16, width * 4U, 4);
        put_little(header + 20, UINT32_C(0x34325258), 4);
        put_little(header + 24, (uint64_t)width * height * 4U, 8);
        put_little(header + 32, captured_ns, 8);
        file = openat(directory, TTFX_RAW_TEMP,
                      O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK, 0600);
        if (file < 0)
                goto fail;
        created = true;
        if (write(file, header, sizeof(header)) != (ssize_t)sizeof(header))
                goto fail;
        /* Packed native Plymouth ARGB words -> explicit little-endian BGRX.
         * One write per row chunk of at most TTFX_RAW_SCRATCH_PIXELS: a single
         * write per row up to 4096 pixels wide, two at the 8192 bound (at most
         * 16384 writes). No retry/sync/sleep and only 16 KiB scratch. */
        for (uint32_t y = 0; y < height; y++) {
                const uint32_t *source = pixels + (size_t)y * width;
                for (uint32_t x = 0; x < width; x += TTFX_RAW_SCRATCH_PIXELS) {
                        uint32_t count = width - x < TTFX_RAW_SCRATCH_PIXELS
                                                 ? width - x
                                                 : TTFX_RAW_SCRATCH_PIXELS;
                        for (uint32_t i = 0; i < count; i++)
                                put_little(row + i * 4U, source[x + i] & 0xffffffU, 4);
                        if (write(file, row, count * 4U) != (ssize_t)(count * 4U))
                                goto fail;
                }
        }
        if (fchmod(file, 0644) != 0)
                goto fail;
        int closed = close(file);
        file = -1;
        if (closed != 0 || renameat(directory, TTFX_RAW_TEMP, directory, TTFX_RAW_NAME) != 0)
                goto fail;
        return true;
fail:
        if (file >= 0)
                (void)close(file);
        if (created)
                (void)unlinkat(directory, TTFX_RAW_TEMP, 0);
        ttfx_raw_clear(directory);
        return false;
}

void ttfx_handoff_clear(int directory)
{
        if (directory >= 0)
                (void)unlinkat(directory, TTFX_HANDOFF_NAME, 0);
        ttfx_raw_clear(directory);
}

void ttfx_handoff_close(int directory)
{
        if (directory >= 0)
                (void)close(directory);
}

int ttfx_handoff_open(void)
{
        struct stat st;
        struct statfs fs;
        if (geteuid() != 0)
                return -1;
        int directory = open("/run", O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK);
        if (directory < 0)
                return -1;
        if (fstat(directory, &st) != 0 || st.st_uid != 0 || (st.st_mode & 0022) != 0 ||
            fstatfs(directory, &fs) != 0 || fs.f_type != TMPFS_MAGIC) {
                close(directory);
                return -1;
        }
        ttfx_handoff_clear(directory);
        return directory;
}

bool ttfx_handoff_publish(int directory, const ttfx_handoff_t *h)
{
        char text[TTFX_HANDOFF_MAX_BYTES];
        size_t length = 0;
        int file = -1;
        bool created = false;
        if (directory < 0)
                return false;
        if (h == NULL || h->effect == NULL || h->phase.step > TTFX_HANDOFF_MAX_STEP ||
            h->width != 162U || h->height != 20U || h->fps != 240U ||
            h->speed != TTFX_PLAYBACK_STEPS_PER_TICK ||
            h->background > 0xffffffU || h->foreground > 0xffffffU)
                goto fail;
        while (length < 128U && h->effect[length] != '\0') {
                char c = h->effect[length];
                if (!((c >= 'a' && c <= 'z') ||
                    (length > 0U && ((c >= '0' && c <= '9') || c == '-'))))
                        goto fail;
                length++;
        }
        if (length == 0U || length == 128U)
                goto fail;
        int size = snprintf(text, sizeof(text),
                "version=2\neffect=%s\nseed=%" PRIu64 "\ncycle=%" PRIu64 "\nstep=%" PRIu64
                "\nwidth=%" PRIu32 "\nheight=%" PRIu32 "\nfps=%" PRIu32 "\nspeed=%" PRIu32
                "\nbackground=%06" PRIx32 "\nforeground=%06" PRIx32
                "\ninput=embedded-logo-v2\nplayback=%s\n",
                h->effect, h->seed, h->phase.cycle, h->phase.step,
                h->width, h->height, h->fps, h->speed, h->background, h->foreground,
                h->hold_final ? "hold-final" : "continuous");
        if (size <= 0 || (size_t)size >= sizeof(text))
                goto fail;
        /* Fixed-size tmpfs I/O only: no disk sync, wait, sleep or retry loops.
         * O_EXCL prevents following symlinks/FIFOs and never truncates an existing leaf. */
        file = openat(directory, TTFX_HANDOFF_TEMP,
                      O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC | O_NONBLOCK, 0600);
        if (file < 0)
                goto fail;
        created = true;
        if (write(file, text, (size_t)size) != size || fchmod(file, 0644) != 0)
                goto fail;
        int closed = close(file);
        file = -1;
        if (closed != 0 || renameat(directory, TTFX_HANDOFF_TEMP, directory, TTFX_HANDOFF_NAME) != 0)
                goto fail;
        return true;
fail:
        if (file >= 0)
                (void)close(file);
        if (created)
                (void)unlinkat(directory, TTFX_HANDOFF_TEMP, 0);
        ttfx_handoff_clear(directory);
        return false;
}

struct ttfx_message {
        char *text;
        ttfx_message_t *next;
};

static unsigned int min_u(unsigned int left, unsigned int right)
{
        return left < right ? left : right;
}

ttfx_state_t ttfx_state_initial(void)
{
        ttfx_state_t state = {
                .prompt_mode = TTFX_PROMPT_NONE,
                .animation_enabled = true,
                .playback_mode = TTFX_PLAYBACK_SUBMIT_TO_FINISH,
                .playback_phase = TTFX_PLAYBACK_INPUT
        };
        return state;
}

static char *copy_string(const char *text)
{
        const char *source = text != NULL ? text : "";
        size_t size = strlen(source) + 1U;
        char *copy = malloc(size);

        if (copy != NULL)
                memcpy(copy, source, size);
        return copy;
}

void ttfx_state_destroy(ttfx_state_t *state)
{
        ttfx_message_t *message = state->messages;

        free(state->prompt);
        free(state->entry_text);
        free(state->failure_candidate_prompt);
        while (message != NULL) {
                ttfx_message_t *next = message->next;
                free(message->text);
                free(message);
                message = next;
        }
        state->prompt = NULL;
        state->entry_text = NULL;
        state->failure_candidate_prompt = NULL;
        state->message = NULL;
        state->messages = NULL;
        state->message_visible = false;
}

void ttfx_state_tick(ttfx_state_t *state)
{
        state->frame = (state->frame + 1U) % TTFX_FRAME_COUNT;
        if (state->failure_candidate_ready) {
                state->failure_candidate_tick++;
                if (state->failure_candidate_tick >= TTFX_FAILURE_CANDIDATE_TICKS) {
                        free(state->failure_candidate_prompt);
                        state->failure_candidate_prompt = NULL;
                        state->failure_candidate_ready = false;
                        state->failure_candidate_tick = 0U;
                        state->prompt_mode = TTFX_PROMPT_NONE;
                        state->bullets = 0;
                        free(state->prompt);
                        state->prompt = NULL;
                        free(state->entry_text);
                        state->entry_text = NULL;
                }
        }
        if (state->reaction_active) {
                /* A retry must keep looping: once the fast-forward lands on
                 * the final frame, hand control back to the input loop
                 * instead of freezing there. */
                if (state->playback_phase == TTFX_PLAYBACK_FINAL)
                        state->playback_phase = TTFX_PLAYBACK_INPUT;
                state->reaction_tick++;
                if (state->reaction_tick >= TTFX_REACTION_TICKS)
                        state->reaction_active = false;
        }
}

void ttfx_state_disable_animation(ttfx_state_t *state)
{
        state->animation_enabled = false;
}

void ttfx_state_fail_rendering(ttfx_state_t *state)
{
        ttfx_state_disable_animation(state);
        state->rendering_failed = true;
}

void ttfx_state_set_normal(ttfx_state_t *state)
{
        free(state->failure_candidate_prompt);
        state->failure_candidate_prompt = NULL;
        state->failure_candidate_ready = false;
        state->failure_candidate_tick = 0U;
        state->reaction_active = false;
        state->reaction_tick = 0U;
        if (state->prompt_mode == TTFX_PROMPT_PASSWORD && state->bullets > 0 &&
            state->prompt != NULL && state->prompt[0] != '\0') {
                state->failure_candidate_ready = true;
                /* The answer was submitted and is being verified: accelerate
                 * towards the final frame now, so a possible error is shown
                 * there with motion instead of after an unanimated wait. */
                if (state->playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH &&
                    state->playback_phase == TTFX_PLAYBACK_INPUT)
                        state->playback_phase = TTFX_PLAYBACK_FAST_FORWARD;
                return;
        }
        ttfx_state_clear_prompt(state);
}

void ttfx_state_clear_prompt(ttfx_state_t *state)
{
        free(state->failure_candidate_prompt);
        state->failure_candidate_prompt = NULL;
        state->failure_candidate_ready = false;
        state->failure_candidate_tick = 0U;
        state->reaction_active = false;
        state->reaction_tick = 0U;
        state->prompt_mode = TTFX_PROMPT_NONE;
        state->bullets = 0;
        free(state->prompt);
        free(state->entry_text);
        state->prompt = NULL;
        state->entry_text = NULL;
}

bool ttfx_state_set_password(ttfx_state_t *state, const char *prompt, int bullets)
{
        char *prompt_copy = copy_string(prompt);
        int safe_bullets = bullets < 0 ? 0 : bullets;
        if (prompt_copy == NULL)
                return false;

        if (safe_bullets == 0 && state->failure_candidate_ready &&
            state->prompt != NULL && strcmp(state->prompt, prompt_copy) == 0) {
                state->reaction_active = true;
                state->reaction_tick = 0U;
                /* Wrong answer: the fast-forward already reached (or is about
                 * to reach) the final frame. Resume looping from the natural
                 * tape boundary instead of hard-resetting the animation. */
                if (state->playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH &&
                    state->playback_phase == TTFX_PLAYBACK_FINAL)
                        state->playback_phase = TTFX_PLAYBACK_INPUT;
        }
        free(state->failure_candidate_prompt);
        state->failure_candidate_prompt = NULL;
        state->failure_candidate_ready = false;
        state->failure_candidate_tick = 0U;

        free(state->prompt);
        free(state->entry_text);
        state->prompt = prompt_copy;
        state->entry_text = NULL;
        state->prompt_mode = TTFX_PROMPT_PASSWORD;
        state->bullets = safe_bullets;
        return true;
}

bool ttfx_state_set_playback_mode(ttfx_state_t *state, const char *mode)
{
        if (mode == NULL || strcmp(mode, "submit-to-finish") == 0) {
                state->playback_mode = TTFX_PLAYBACK_SUBMIT_TO_FINISH;
                return true;
        }
        if (strcmp(mode, "continuous") == 0) {
                state->playback_mode = TTFX_PLAYBACK_CONTINUOUS;
                state->playback_phase = TTFX_PLAYBACK_INPUT;
                return true;
        }
        return false;
}

unsigned int ttfx_state_engine_steps_per_tick(const ttfx_state_t *state)
{
        if (state->playback_mode == TTFX_PLAYBACK_CONTINUOUS ||
            state->playback_phase == TTFX_PLAYBACK_INPUT)
                return TTFX_PLAYBACK_STEPS_PER_TICK;
        if (state->playback_phase == TTFX_PLAYBACK_FAST_FORWARD)
                return TTFX_FAST_FORWARD_STEPS_PER_TICK;
        return 0U;
}

void ttfx_state_confirm_success(ttfx_state_t *state)
{
        if (state->playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH &&
            state->playback_phase == TTFX_PLAYBACK_INPUT)
                state->playback_phase = TTFX_PLAYBACK_FAST_FORWARD;
}

void ttfx_state_engine_completed(ttfx_state_t *state)
{
        if (state->playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH &&
            state->playback_phase != TTFX_PLAYBACK_FINAL)
                state->playback_phase = TTFX_PLAYBACK_FINAL;
}

bool ttfx_state_password_pending(const ttfx_state_t *state)
{
        return state->failure_candidate_ready;
}

bool ttfx_state_reaction_active(const ttfx_state_t *state)
{
        return state->reaction_active;
}

int ttfx_state_reaction_x_offset(const ttfx_state_t *state)
{
        static const int offsets[] = {-8, 6, -5, 8, -4, 5, -2};

        if (!state->reaction_active)
                return 0;
        return offsets[(state->reaction_tick / TTFX_REACTION_OFFSET_TICKS) %
                       (sizeof(offsets) / sizeof(offsets[0]))];
}

bool ttfx_state_reaction_row_red(const ttfx_state_t *state, unsigned int row)
{
        (void)row;
        return state->reaction_active;
}

bool ttfx_state_set_question(ttfx_state_t *state, const char *prompt, const char *entry_text)
{
        char *prompt_copy = copy_string(prompt);
        char *entry_copy = copy_string(entry_text);
        if (prompt_copy == NULL || entry_copy == NULL) {
                free(prompt_copy);
                free(entry_copy);
                return false;
        }

        free(state->failure_candidate_prompt);
        state->failure_candidate_prompt = NULL;
        state->failure_candidate_ready = false;
        state->failure_candidate_tick = 0U;
        state->reaction_active = false;
        state->reaction_tick = 0U;
        free(state->prompt);
        free(state->entry_text);
        state->prompt = prompt_copy;
        state->entry_text = entry_copy;
        state->prompt_mode = TTFX_PROMPT_QUESTION;
        state->bullets = 0;
        return true;
}

bool ttfx_state_set_message(ttfx_state_t *state, const char *message)
{
        char *message_copy = copy_string(message);
        ttfx_message_t *new_message;

        if (message_copy == NULL)
                return false;
        new_message = malloc(sizeof(*new_message));
        if (new_message == NULL) {
                free(message_copy);
                return false;
        }
        new_message->text = message_copy;
        new_message->next = state->messages;
        state->messages = new_message;
        state->message = new_message->text;
        state->message_visible = true;
        return true;
}

bool ttfx_state_hide_message(ttfx_state_t *state, const char *message)
{
        ttfx_message_t **link = &state->messages;

        if (message == NULL)
                return false;
        while (*link != NULL) {
                ttfx_message_t *candidate = *link;
                if (strcmp(candidate->text, message) == 0) {
                        *link = candidate->next;
                        free(candidate->text);
                        free(candidate);
                        state->message = state->messages != NULL ? state->messages->text : NULL;
                        state->message_visible = state->message != NULL;
                        return true;
                }
                link = &candidate->next;
        }
        return false;
}

ttfx_view_state_t ttfx_view_state_initial(void)
{
        ttfx_view_state_t state = {
                .prompt_label_available = true,
                .message_label_available = true
        };
        return state;
}

bool ttfx_view_show_prompt(ttfx_view_state_t *state)
{
        bool was_hidden = !state->prompt_visible;
        state->prompt_visible = true;
        return was_hidden;
}

bool ttfx_view_hide_prompt(ttfx_view_state_t *state)
{
        bool was_visible = state->prompt_visible;
        state->prompt_visible = false;
        return was_visible;
}

bool ttfx_view_show_message(ttfx_view_state_t *state)
{
        bool was_hidden = !state->message_visible;
        state->message_visible = true;
        return was_hidden;
}

bool ttfx_view_hide_message(ttfx_view_state_t *state)
{
        bool was_visible = state->message_visible;
        state->message_visible = false;
        return was_visible;
}

bool ttfx_view_prompt_can_show(const ttfx_view_state_t *state)
{
        return state->prompt_label_available;
}

bool ttfx_view_message_can_show(const ttfx_view_state_t *state)
{
        return state->message_label_available;
}

void ttfx_view_degrade_prompt(ttfx_state_t *plugin_state, ttfx_view_state_t *view_state)
{
        ttfx_state_disable_animation(plugin_state);
        view_state->prompt_label_available = false;
}

void ttfx_view_degrade_message(ttfx_state_t *plugin_state, ttfx_view_state_t *view_state)
{
        ttfx_state_disable_animation(plugin_state);
        view_state->message_label_available = false;
        view_state->message_visible = false;
}

ttfx_loop_state_t ttfx_loop_state_initial(void)
{
        ttfx_loop_state_t state = {false};
        return state;
}

void ttfx_loop_watch_attached(ttfx_loop_state_t *state)
{
        state->exit_watch_attached = true;
}

bool ttfx_loop_detach_watch(ttfx_loop_state_t *state)
{
        bool was_attached = state->exit_watch_attached;
        state->exit_watch_attached = false;
        return was_attached;
}

ttfx_load_state_t ttfx_load_state_initial(void)
{
        ttfx_load_state_t state = {true};
        return state;
}

void ttfx_load_state_record_view(ttfx_load_state_t *state, bool loaded)
{
        state->required_widgets_ready = state->required_widgets_ready && loaded;
}

bool ttfx_load_state_can_show(const ttfx_load_state_t *state)
{
        return state->required_widgets_ready;
}

bool ttfx_dynamic_view_should_keep(bool loaded)
{
        return loaded;
}

/* Official wordmark lattice after exact 2x2 subdivision: 51 units wide per
 * 100-unit terminal row. 162 columns at height 10 still span 826px. */
unsigned int ttfx_geometry_x_edge(const ttfx_geometry_t *geometry, unsigned int column)
{
        return (unsigned int)((uint64_t)column * geometry->cell_height * 51U / 100U);
}

/* Bottom-aligned mapping of the old display's grid row onto the new display:
 * the logical offset from the new grid row that keeps the splash where it was.
 * Only for a same-width display whose height differs by at most an eighth. */
bool ttfx_display_swap_offset(unsigned int old_width, unsigned int old_height, unsigned int old_grid_y,
                              unsigned int new_width, unsigned int new_height, unsigned int new_grid_y,
                              int *offset)
{
        unsigned int difference;
        int64_t from;

        if (offset == NULL || old_width == 0U || old_width != new_width || old_height == new_height)
                return false;
        difference = old_height > new_height ? old_height - new_height : new_height - old_height;
        if (difference > new_height / 8U)
                return false;
        from = (int64_t)old_grid_y + (int64_t)new_height - (int64_t)old_height - (int64_t)new_grid_y;
        if (from == 0 || from > (int64_t)new_height || from < -(int64_t)new_height)
                return false;
        *offset = (int)from;
        return true;
}

/* Ease-out cubic glide from `from` to 0: the remaining offset after `tick` of
 * `total` ticks is from * (1 - t)^3, truncated toward zero, 0 from the end on. */
int ttfx_glide_offset(int from, unsigned int tick, unsigned int total)
{
        int64_t remaining;

        if (total == 0U || tick >= total)
                return 0;
        remaining = (int64_t)(total - tick);
        return (int)(((int64_t)from * remaining * remaining * remaining) /
                     ((int64_t)total * total * total));
}

bool ttfx_compose_bottom_aligned(void *destination, size_t stride,
                                 const uint32_t *frame, uint32_t width, uint32_t height,
                                 uint32_t top, uint32_t fill)
{
        size_t row_bytes;
        char *base = destination;

        if (destination == NULL || frame == NULL || width == 0U || height == 0U)
                return false;
        row_bytes = (size_t)width * sizeof(uint32_t);
        if (stride < row_bytes)
                return false;
        for (uint32_t row = 0U; row < top; row++) {
                uint32_t *line = (uint32_t *)(void *)(base + (size_t)row * stride);
                for (uint32_t x = 0U; x < width; x++)
                        line[x] = fill;
        }
        for (uint32_t row = 0U; row < height; row++)
                memcpy(base + ((size_t)top + row) * stride,
                       frame + (size_t)row * width, row_bytes);
        return true;
}

ttfx_geometry_t ttfx_geometry_for_view(unsigned int width, unsigned int height)
{
        ttfx_geometry_t geometry;

        geometry.columns = min_u(TTFX_GRID_COLUMNS, width);
        geometry.rows = min_u(TTFX_GRID_ROWS, height);
        geometry.cell_height = geometry.rows > 0U && geometry.columns > 0U
                                       ? min_u(10U, height / geometry.rows)
                                       : 0U;
        if (geometry.columns > 0U) {
                unsigned int width_limited_height = (unsigned int)
                        ((uint64_t)width * 100U / ((uint64_t)geometry.columns * 51U));
                geometry.cell_height = min_u(geometry.cell_height, width_limited_height);
        }
        /* Informational minimum width; rendering must use cumulative edges. */
        geometry.cell_width = ttfx_geometry_x_edge(&geometry, 1U);
        geometry.grid_width = ttfx_geometry_x_edge(&geometry, geometry.columns);
        geometry.grid_height = geometry.cell_height * geometry.rows;
        geometry.grid_x = (width - geometry.grid_width) / 2U;
        geometry.grid_y = (height - geometry.grid_height) * 9U / 20U;
        return geometry;
}



ttfx_firmware_hold_mode_t ttfx_firmware_hold_mode_parse(const char *value)
{
        if (value != NULL && strcmp(value, "true") == 0)
                return TTFX_FIRMWARE_HOLD_ON;
        if (value != NULL && strcmp(value, "false") == 0)
                return TTFX_FIRMWARE_HOLD_OFF;
        return TTFX_FIRMWARE_HOLD_AUTO;
}

bool ttfx_devicetree_has_framebuffer(const char *chosen_path)
{
        static const char prefix[] = TTFX_DEVICETREE_FRAMEBUFFER_PREFIX;
        struct dirent *entry;
        bool found = false;
        DIR *directory;

        if (chosen_path == NULL || chosen_path[0] == '\0')
                return false;
        directory = opendir(chosen_path);
        if (directory == NULL)
                return false;
        while (!found && (entry = readdir(directory)) != NULL)
                found = strncmp(entry->d_name, prefix, sizeof(prefix) - 1U) == 0;
        closedir(directory);
        return found;
}

bool ttfx_firmware_hold_resolve(ttfx_firmware_hold_mode_t mode, const char *chosen_path)
{
        if (mode == TTFX_FIRMWARE_HOLD_ON)
                return true;
        if (mode == TTFX_FIRMWARE_HOLD_OFF)
                return false;
        return ttfx_devicetree_has_framebuffer(chosen_path);
}

/* One big-endian u32 device-tree property; false unless it is exactly 4 bytes. */
static bool devicetree_read_u32(const char *directory, const char *name, uint32_t *value)
{
        char path[PATH_MAX];
        unsigned char bytes[5];
        ssize_t length;
        int fd;
        int written = snprintf(path, sizeof(path), "%s/%s", directory, name);

        if (written < 0 || (size_t)written >= sizeof(path))
                return false;
        fd = open(path, O_RDONLY | O_CLOEXEC);
        if (fd < 0)
                return false;
        length = read(fd, bytes, sizeof(bytes));
        close(fd);
        if (length != 4)
                return false;
        *value = (uint32_t)bytes[0] << 24 | (uint32_t)bytes[1] << 16 | (uint32_t)bytes[2] << 8 |
                 (uint32_t)bytes[3];
        return true;
}

/* The first entry of `directory` starting with `prefix` for which `name`
 * reads as a u32. */
static bool devicetree_find_u32(const char *directory, const char *prefix, const char *name,
                                uint32_t *value)
{
        char path[PATH_MAX];
        struct dirent *entry;
        bool found = false;
        DIR *handle = opendir(directory);

        if (handle == NULL)
                return false;
        while (!found && (entry = readdir(handle)) != NULL) {
                int written;

                if (strncmp(entry->d_name, prefix, strlen(prefix)) != 0)
                        continue;
                written = snprintf(path, sizeof(path), "%s/%s", directory, entry->d_name);
                if (written < 0 || (size_t)written >= sizeof(path))
                        continue;
                found = devicetree_read_u32(path, name, value);
        }
        closedir(handle);
        return found;
}

uint32_t ttfx_devicetree_hidden_notch(const char *chosen_path, const char *soc_path)
{
        uint32_t width = 0U;
        uint32_t height = 0U;
        uint32_t notch = 0U;
        uint64_t sixteenths;

        if (chosen_path == NULL || chosen_path[0] == '\0' || soc_path == NULL || soc_path[0] == '\0')
                return 0U;
        if (!devicetree_find_u32(chosen_path, TTFX_DEVICETREE_FRAMEBUFFER_PREFIX, "width", &width) ||
            !devicetree_find_u32(chosen_path, TTFX_DEVICETREE_FRAMEBUFFER_PREFIX, "height", &height) ||
            !devicetree_find_u32(soc_path, "dcp@", "apple,notch-height", &notch))
                return 0U;
        if (width == 0U || height == 0U || notch == 0U || notch >= height)
                return 0U;
        sixteenths = (uint64_t)height * 16U / width;
        if ((uint64_t)width * sixteenths / 16U != height)
                return 0U;
        return notch;
}

long ttfx_firmware_mark_lift(uint32_t hidden_notch, int scale)
{
        if (scale < 1)
                scale = 1;
        return ((long)hidden_notch + (long)scale) / (2L * (long)scale);
}

bool ttfx_firmware_display(const char *device_name, const char *sysfs_drm_root)
{
        static const char prefix[] = "/dev/dri/card";
        char path[PATH_MAX];
        char target[PATH_MAX];
        const char *digits;
        const char *base;
        size_t count = 0U;
        ssize_t length;
        int written;

        if (device_name == NULL || sysfs_drm_root == NULL || sysfs_drm_root[0] == '\0' ||
            strncmp(device_name, prefix, sizeof(prefix) - 1U) != 0)
                return false;
        digits = device_name + sizeof(prefix) - 1U;
        while (digits[count] >= '0' && digits[count] <= '9')
                count++;
        if (count == 0U || count > 4U || digits[count] != '\0')
                return false;
        written = snprintf(path, sizeof(path), "%s/card%s/device/driver", sysfs_drm_root, digits);
        if (written < 0 || (size_t)written >= sizeof(path))
                return false;
        length = readlink(path, target, sizeof(target) - 1U);
        if (length <= 0)
                return false;
        target[length] = '\0';
        while (length > 1 && target[length - 1] == '/')
                target[--length] = '\0';
        base = strrchr(target, '/');
        base = base != NULL ? base + 1 : target;
        return strcmp(base, TTFX_FIRMWARE_DRIVER_NAME) == 0;
}

bool ttfx_outro_mode_parse(const char *value)
{
        return value == NULL || strcmp(value, "none") != 0;
}

unsigned int ttfx_outro_ms_parse(const char *value)
{
        unsigned int parsed = 0U;
        size_t index = 0U;

        if (value == NULL || value[0] == '\0')
                return TTFX_OUTRO_DEFAULT_MS;
        while (value[index] != '\0') {
                if (index >= 9U || value[index] < '0' || value[index] > '9')
                        return TTFX_OUTRO_DEFAULT_MS;
                parsed = parsed * 10U + (unsigned int)(value[index] - '0');
                index++;
        }
        if (parsed < TTFX_OUTRO_MIN_MS)
                return TTFX_OUTRO_MIN_MS;
        if (parsed > TTFX_OUTRO_MAX_MS)
                return TTFX_OUTRO_MAX_MS;
        return parsed;
}

uint32_t ttfx_outro_max_calls(unsigned int ms)
{
        uint32_t calls = (uint32_t)((uint64_t)ms * TTFX_OUTRO_TICKS_PER_SECOND / 1000U);

        return calls > 0U ? calls : 1U;
}

uint32_t ttfx_outro_due_calls(uint64_t elapsed_ns, unsigned int ms, uint32_t calls, uint32_t done)
{
        uint64_t budget_ns = (uint64_t)ms * UINT64_C(1000000);
        uint64_t target;

        if (done >= calls)
                return 0U;
        if (budget_ns == 0U || elapsed_ns >= budget_ns)
                return calls - done;
        target = elapsed_ns * calls / budget_ns;
        if (target < (uint64_t)done + 1U)
                target = (uint64_t)done + 1U;
        if (target > calls)
                target = calls;
        return (uint32_t)(target - done);
}
