#define _GNU_SOURCE
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <stdatomic.h>
#include <time.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <linux/fb.h>

#include <ply-boot-splash-plugin.h>
#include <ply-entry.h>
#include <ply-image.h>
#include <ply-label.h>
#include <ply-pixel-buffer.h>
#include <ply-pixel-display.h>

#include "embedded-logo.h"
#include "glyph-atlas.generated.h"
#include "state.h"
#include "ttfx_plymouth.h"

#define FRAME_INTERVAL_SECONDS (1.0 / 240.0)
#ifndef TTFX_FBCON_PATH
#define TTFX_FBCON_PATH "/dev/fb0"
#endif
#ifndef TTFX_KMSG_PATH
#define TTFX_KMSG_PATH "/dev/kmsg"
#endif
/* Firmware hold: where a DRM card's driver link and the device-tree
 * framebuffer nodes are looked up. Tests point these at their own fixtures. */
#ifndef TTFX_SYSFS_DRM_PATH
#define TTFX_SYSFS_DRM_PATH "/sys/class/drm"
#endif
#ifndef TTFX_DEVICETREE_CHOSEN_PATH
#define TTFX_DEVICETREE_CHOSEN_PATH "/sys/firmware/devicetree/base/chosen"
#endif
#ifndef TTFX_DEVICETREE_SOC_PATH
#define TTFX_DEVICETREE_SOC_PATH "/sys/firmware/devicetree/base/soc"
#endif
#define FIRMWARE_MARK_IMAGE "boot-mark.png"
#define FIRMWARE_MARK_MAX_SCALE 8
/* Display-swap bridge: how often the helper thread looks for the new
 * framebuffer, how long it keeps looking, and when it rewrites the frame after
 * the first write (fbcon clears the framebuffer when it binds to it). */
#ifndef TTFX_SWAP_BRIDGE_POLL_NS
#define TTFX_SWAP_BRIDGE_POLL_NS UINT64_C(4000000)
#endif
#ifndef TTFX_SWAP_BRIDGE_WINDOW_NS
#define TTFX_SWAP_BRIDGE_WINDOW_NS TTFX_DISPLAY_SWAP_WINDOW_NS
#endif
#define TTFX_SWAP_BRIDGE_SLEEP_STEP_NS UINT64_C(2000000)
#define ENGINE_STEPS_PER_TICK 2U
#define FINAL_DRAW_WAIT_NS UINT64_C(250000000)
/* Reverse outro: the forward playback is recorded in at most this many
 * keyframes and bytes (decimated evenly when exceeded), and the blank frame
 * gets this long to be drawn before idle completes anyway. */
#define OUTRO_HISTORY_FRAMES 128U
#define OUTRO_HISTORY_BYTES ((size_t)4U * 1024U * 1024U)
#define OUTRO_DRAW_WAIT_NS FINAL_DRAW_WAIT_NS
#define BACKGROUND_COLOR 0x0b0d10U
#define LOGO_COLOR 0xf4f4f5U
#define PROMPT_LABEL_COLOR 0xf4f4f5ffU
#define MESSAGE_LABEL_COLOR 0xb8bec9ffU
#define UNLOCK_MARKER_COLOR 0xd7ff64U
#define ERROR_GLITCH_COLOR 0xff4057U

#define LOCK_GAP 15L
#define LOCK_MAX_DIMENSION 4096L
#define ENGINE_WIDTH 162U
#define ENGINE_HEIGHT 20U
#define ENGINE_FPS 240U
#define ENGINE_SEED UINT64_C(22321466108495961)

#define PROGRESS_FAKE_DURATION_NS UINT64_C(15000000000)
#define PROGRESS_VALIDATION_TIMEOUT_NS UINT64_C(60000000000)
#define PROGRESS_FAKE_LIMIT 0.70

struct _ply_boot_splash_plugin;
typedef struct view view_t;

/* Owned by the plugin thread; the helper thread reads only the frame fields,
 * which never change after creation, and the atomic flags. */
typedef struct {
        pthread_t thread;
        atomic_bool cancel;
        atomic_bool done;
        uint32_t *pixels;
        uint32_t width;
        uint32_t height;
        uint32_t background;
        uint64_t window_ns;
} swap_bridge_t;

/* Read only when a bridge starts; tests shorten it to exercise the expiry. */
static uint64_t swap_bridge_window_ns = TTFX_SWAP_BRIDGE_WINDOW_NS;

struct view {
        struct _ply_boot_splash_plugin *plugin;
        ply_pixel_display_t *display;
        ply_entry_t *entry;
        ply_label_t *prompt_label;
        ply_label_t *message_label;
        ttfx_geometry_t geometry;
        ttfx_view_state_t state;
        bool entry_loaded;
        int entry_reaction_x_offset;
        bool labels_loaded;
        uint32_t *raw_pixels;
        size_t raw_capacity;
        uint32_t raw_width, raw_height;
        uint32_t raw_logical_width, raw_logical_height;
        uint64_t raw_captured_ns;
        ttfx_phase_t raw_phase;
        bool raw_valid;
        /* Display-swap glide: logical y offset still applied to the grid. */
        int glide_from;
        int glide_offset;
        unsigned int glide_tick;
        /* Driven by a firmware framebuffer (simple-framebuffer). */
        bool firmware;
        view_t *next;
};

struct _ply_boot_splash_plugin {
        ply_event_loop_t *loop;
        view_t *views;
        ttfx_state_t state;
        ttfx_loop_state_t loop_state;
        ttfx_load_state_t load_state;
        char *image_dir;
        char *effect;
        ply_image_t *lock_image;
        ply_pixel_buffer_t *lock_buffer_error;

        ply_image_t *progress_box_image;
        ply_image_t *progress_bar_image;
        bool lock_scale_attempted;
        bool progress_assets_attempted;
        bool progress_visible;
        bool boot_progress_allowed;
        double progress_fraction;
        uint64_t progress_started_ns;
        uint64_t seed;
        uint32_t background_color;
        uint32_t text_color;
        uint32_t message_color;
        bool visible;
        bool idle;
        int handoff_directory;
        bool handoff_published;
        bool drawn_valid;
        ttfx_phase_t phase;
        ttfx_phase_t drawn_phase;
        TtfxCell drawn_cells[ENGINE_WIDTH * ENGINE_HEIGHT];
        bool timeout_scheduled;
        bool static_degraded;
        bool success_pending;
        uint64_t success_started_ns;
        /* The display that was last removed while the splash was up. */
        bool swap_pending;
        uint64_t swap_ns;
        unsigned int swap_width;
        unsigned int swap_height;
        unsigned int swap_grid_y;
        /* Helper thread painting the last frame into the next driver's fbdev
         * framebuffer until the replacement display draws. */
        swap_bridge_t *swap_bridge;
        /* Firmware hold: enabled by configuration, active, and already over
         * (it never starts again once released). */
        bool firmware_hold_enabled;
        /* Notch rows hidden above the device-tree framebuffer: the hold
         * raises the mark by half of them to stay where m1n1's logo was. */
        uint32_t firmware_hidden_notch;
        bool firmware_hold;
        bool firmware_hold_released;
        uint64_t firmware_hold_started_ns;
        ply_image_t *mark_image;
        bool mark_image_attempted;
        /* The mark resized for one device scale; a failed resize is not
         * retried for the same scale. */
        ply_image_t *mark_scaled;
        int mark_scaled_scale;
        /* Reverse outro: configured, allowed for the splash mode (boot only),
         * the engine records its playback, playing backwards, and the screen
         * is (to become) the plain background. */
        bool outro_enabled;
        unsigned int outro_ms;
        bool outro_mode_allowed;
        bool outro_recording;
        bool outro_active;
        bool outro_plain;
        bool outro_published;
        uint32_t outro_calls;
        uint32_t outro_done;
        uint64_t outro_started_ns;
        uint64_t outro_plain_ns;

        uint64_t (*clock_ns)(void);
        ply_trigger_t *idle_trigger;
        TtfxEngine *engine;
        const TtfxCell *cells;
        size_t cell_count;
        uint32_t canvas_width;
        uint32_t canvas_height;
};

static void apply_current_prompt(view_t *view);
static void apply_current_message(view_t *view);
static void hide_view_prompt(view_t *view);
static void on_timeout(void *user_data, ply_event_loop_t *loop);
static void schedule_timeout_if_needed(ply_boot_splash_plugin_t *plugin);
static void finish_become_idle(ply_boot_splash_plugin_t *plugin);
static void publish_frame_to_fbcon(ply_boot_splash_plugin_t *plugin);
static void reposition_view_prompt(view_t *view);
static void refresh_view_geometry(view_t *view);
static void stop_swap_bridge(ply_boot_splash_plugin_t *plugin);
static void fbcon_klog(const char *msg);
static void release_firmware_hold(ply_boot_splash_plugin_t *plugin, const char *message);
static void hide_view_message(view_t *view);

static ply_image_t *load_theme_image(const char *image_dir, const char *filename)
{
        size_t directory_length;
        size_t filename_length;
        size_t separator_length;
        size_t path_length;
        char *path;
        ply_image_t *image;

        if (image_dir == NULL || filename == NULL)
                return NULL;
        directory_length = strlen(image_dir);
        filename_length = strlen(filename) + 1U;
        separator_length = directory_length > 0U && image_dir[directory_length - 1U] == '/' ? 0U : 1U;
        if (directory_length > SIZE_MAX - separator_length - filename_length)
                return NULL;
        path_length = directory_length + separator_length + filename_length;
        path = malloc(path_length);
        if (path == NULL)
                return NULL;
        memcpy(path, image_dir, directory_length);
        if (separator_length != 0U)
                path[directory_length] = '/';
        memcpy(path + directory_length + separator_length, filename, filename_length);
        image = ply_image_new(path);
        free(path);
        if (image == NULL)
                return NULL;
        if (!ply_image_load(image)) {
                ply_image_free(image);
                return NULL;
        }
        return image;
}

static bool ensure_progress_assets(ply_boot_splash_plugin_t *plugin)
{
        if (!plugin->progress_assets_attempted) {
                plugin->progress_assets_attempted = true;
                plugin->progress_box_image = load_theme_image(plugin->image_dir, "progress_box.png");
                plugin->progress_bar_image = load_theme_image(plugin->image_dir, "progress_bar.png");
                if (plugin->progress_box_image == NULL || plugin->progress_bar_image == NULL) {
                        if (plugin->progress_box_image != NULL)
                                ply_image_free(plugin->progress_box_image);
                        if (plugin->progress_bar_image != NULL)
                                ply_image_free(plugin->progress_bar_image);
                        plugin->progress_box_image = NULL;
                        plugin->progress_bar_image = NULL;
                }
        }
        return plugin->progress_box_image != NULL && plugin->progress_bar_image != NULL;
}

static void stop_progress(ply_boot_splash_plugin_t *plugin)
{
        plugin->progress_visible = false;
        plugin->progress_started_ns = 0U;
}

static void start_progress(ply_boot_splash_plugin_t *plugin)
{
        if (!plugin->boot_progress_allowed || plugin->outro_active || plugin->outro_plain ||
            !ensure_progress_assets(plugin))
                return;
        plugin->progress_visible = true;
        plugin->progress_fraction = 0.0;
        plugin->progress_started_ns = plugin->clock_ns != NULL ? plugin->clock_ns() : 0U;
}

static void resume_progress(ply_boot_splash_plugin_t *plugin)
{
        if (!ttfx_state_password_pending(&plugin->state) ||
            !plugin->boot_progress_allowed || plugin->outro_active || plugin->outro_plain ||
            !ensure_progress_assets(plugin))
                return;
        plugin->progress_visible = true;
        if (plugin->progress_started_ns == 0U)
                plugin->progress_started_ns = plugin->clock_ns != NULL ? plugin->clock_ns() : 0U;
}

static bool progress_validation_expired(ply_boot_splash_plugin_t *plugin)
{
        uint64_t now;

        if (!plugin->progress_visible || plugin->progress_started_ns == 0U ||
            plugin->clock_ns == NULL)
                return false;
        now = plugin->clock_ns();
        return now < plugin->progress_started_ns ||
               now - plugin->progress_started_ns >= PROGRESS_VALIDATION_TIMEOUT_NS;
}

static void advance_fake_progress(ply_boot_splash_plugin_t *plugin)
{
        uint64_t now;
        double ratio;
        double eased;
        double progress;

        if (!plugin->progress_visible || plugin->progress_started_ns == 0U ||
            plugin->clock_ns == NULL)
                return;
        now = plugin->clock_ns();
        if (now < plugin->progress_started_ns)
                return;
        ratio = (double)(now - plugin->progress_started_ns) /
                (double)PROGRESS_FAKE_DURATION_NS;
        if (ratio > 1.0)
                ratio = 1.0;
        eased = 1.0 - (1.0 - ratio) * (1.0 - ratio);
        progress = eased * PROGRESS_FAKE_LIMIT;
        if (progress > plugin->progress_fraction)
                plugin->progress_fraction = progress;
}

static void clear_snapshot(ply_boot_splash_plugin_t *plugin)
{
        plugin->cells = NULL;
        plugin->cell_count = 0U;
        plugin->canvas_width = 0U;
        plugin->canvas_height = 0U;
}

static void free_engine(ply_boot_splash_plugin_t *plugin)
{
        clear_snapshot(plugin);
        if (plugin->engine != NULL) {
                TtfxEngine *engine = plugin->engine;
                plugin->engine = NULL;
                ttfx_engine_free(engine);
        }
}

static bool update_snapshot(ply_boot_splash_plugin_t *plugin)
{
        const TtfxCell *cells = NULL;
        size_t count = 0U;
        uint32_t width = 0U;
        uint32_t height = 0U;

        if (plugin->engine == NULL ||
            ttfx_engine_cells(plugin->engine, &cells, &count, &width, &height) != TTFX_STATUS_OK ||
            cells == NULL || width == 0U || height == 0U ||
            width > TTFX_MAX_WIDTH || height > TTFX_MAX_HEIGHT ||
            (size_t)width > SIZE_MAX / (size_t)height ||
            (size_t)width * (size_t)height > TTFX_MAX_CELLS ||
            count != (size_t)width * (size_t)height) {
                return false;
        }
        plugin->cells = cells;
        plugin->cell_count = count;
        plugin->canvas_width = width;
        plugin->canvas_height = height;
        return true;
}

static bool initialize_engine(ply_boot_splash_plugin_t *plugin)
{
        if (plugin->engine != NULL)
                return true;
        if (!plugin->state.animation_enabled)
                return false;
        if (ttfx_engine_create_with_background(plugin->effect, plugin->seed,
                                               ttfx_embedded_logo, ttfx_embedded_logo_len,
                                               ENGINE_WIDTH, ENGINE_HEIGHT, ENGINE_FPS,
                                               plugin->background_color,
                                               &plugin->engine) != TTFX_STATUS_OK ||
            plugin->engine == NULL || !update_snapshot(plugin)) {
                free_engine(plugin);
                ttfx_state_disable_animation(&plugin->state);
                return false;
        }
        /* The outro needs the playback recorded from its first frame. Without
         * a record (refused or out of memory) idle simply skips the outro. */
        plugin->outro_recording = plugin->outro_enabled && plugin->outro_mode_allowed &&
                                  ttfx_engine_record_history(plugin->engine, OUTRO_HISTORY_FRAMES,
                                                             OUTRO_HISTORY_BYTES) == TTFX_STATUS_OK;
        return true;
}

static void damage_view(view_t *view)
{
        int width = (int)ply_pixel_display_get_width(view->display);
        int height = (int)ply_pixel_display_get_height(view->display);
        ply_pixel_display_draw_area(view->display, 0, 0, width, height);
}

static void damage_all_views(ply_boot_splash_plugin_t *plugin)
{
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                damage_view(view);
}

static void schedule_timeout_if_needed(ply_boot_splash_plugin_t *plugin)
{
        bool animation_active = plugin->state.animation_enabled && !plugin->static_degraded &&
                                ttfx_state_engine_steps_per_tick(&plugin->state) > 0U;
        bool transition_active = ttfx_state_password_pending(&plugin->state) ||
                                 ttfx_state_reaction_active(&plugin->state) ||
                                 plugin->success_pending || plugin->firmware_hold ||
                                 plugin->outro_active;

        for (view_t *view = plugin->views; view != NULL; view = view->next)
                transition_active = transition_active || view->glide_offset != 0;

        if (!plugin->visible || plugin->loop == NULL || plugin->idle ||
            plugin->timeout_scheduled || (!animation_active && !transition_active))
                return;
        ply_event_loop_watch_for_timeout(plugin->loop,
                                         FRAME_INTERVAL_SECONDS,
                                         on_timeout,
                                         plugin);
        plugin->timeout_scheduled = true;
}

static void draw_static_fallback(ply_boot_splash_plugin_t *plugin,
                                 ply_pixel_buffer_t *buffer,
                                 unsigned long width,
                                 unsigned long height)
{
        int x_offset = ttfx_state_reaction_x_offset(&plugin->state);
        uint32_t color = ttfx_state_reaction_active(&plugin->state)
                                 ? ERROR_GLITCH_COLOR
                                 : plugin->text_color;
        unsigned long logo_width = width < 360U ? width / 2U : 180U;
        unsigned long logo_height = height < 180U ? height / 12U : 15U;
        ply_rectangle_t logo = {
                .x = (long)((width - logo_width) / 2U) + x_offset,
                .y = (long)(height / 6U),
                .width = logo_width,
                .height = logo_height
        };
        ply_rectangle_t mark = {
                .x = logo.x + (long)(logo_width / 3U),
                .y = logo.y - (long)(logo_height / 2U),
                .width = logo_width / 3U,
                .height = logo_height * 2U
        };

        ply_pixel_buffer_fill_with_hex_color(buffer, &logo, color);
        ply_pixel_buffer_fill_with_hex_color(buffer, &mark, color);
}

static uint32_t rgba_over_rgb(uint32_t rgba, uint32_t background)
{
        uint32_t alpha = rgba & 0xffU;
        uint32_t inverse = 255U - alpha;
        uint32_t red = ((((rgba >> 24U) & 0xffU) * alpha) +
                        (((background >> 16U) & 0xffU) * inverse) + 127U) / 255U;
        uint32_t green = ((((rgba >> 16U) & 0xffU) * alpha) +
                          (((background >> 8U) & 0xffU) * inverse) + 127U) / 255U;
        uint32_t blue = ((((rgba >> 8U) & 0xffU) * alpha) +
                         ((background & 0xffU) * inverse) + 127U) / 255U;
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

static void draw_glyph_mask(ply_pixel_buffer_t *buffer,
                            const ply_rectangle_t *cell,
                            uint32_t codepoint,
                            uint32_t color)
{
        const uint8_t *rows = &ttfx_decrypt_glyph_atlas[glyph_atlas_index(codepoint) *
                                                         TTFX_GLYPH_HEIGHT];

        for (unsigned int glyph_y = 0U; glyph_y < TTFX_GLYPH_HEIGHT; glyph_y++) {
                uint8_t bits = rows[glyph_y];
                unsigned int glyph_x = 0U;
                unsigned long top = glyph_y * cell->height / TTFX_GLYPH_HEIGHT;
                unsigned long bottom = (glyph_y + 1U) * cell->height / TTFX_GLYPH_HEIGHT;
                if (bottom <= top)
                        continue;
                while (glyph_x < TTFX_GLYPH_WIDTH) {
                        unsigned int run_start;
                        unsigned long left;
                        unsigned long right;
                        ply_rectangle_t run;
                        while (glyph_x < TTFX_GLYPH_WIDTH &&
                               (bits & (uint8_t)(1U << glyph_x)) == 0U)
                                glyph_x++;
                        if (glyph_x == TTFX_GLYPH_WIDTH)
                                break;
                        run_start = glyph_x;
                        while (glyph_x < TTFX_GLYPH_WIDTH &&
                               (bits & (uint8_t)(1U << glyph_x)) != 0U)
                                glyph_x++;
                        left = run_start * cell->width / TTFX_GLYPH_WIDTH;
                        right = glyph_x * cell->width / TTFX_GLYPH_WIDTH;
                        if (right <= left)
                                continue;
                        run = (ply_rectangle_t){.x = cell->x + (long)left,
                                                .y = cell->y + (long)top,
                                                .width = right - left,
                                                .height = bottom - top};
                        ply_pixel_buffer_fill_with_hex_color(buffer, &run, color);
                }
        }
}

static void draw_grid(view_t *view, ply_pixel_buffer_t *buffer)
{
        const ttfx_geometry_t *geometry = &view->geometry;
        int x_offset = ttfx_state_reaction_x_offset(&view->plugin->state);

        for (unsigned int row = 0U; row < geometry->rows; row++) {
                for (unsigned int column = 0U; column < geometry->columns; column++) {
                        size_t index = (size_t)row * view->plugin->canvas_width + column;
                        unsigned int left = ttfx_geometry_x_edge(geometry, column);
                        unsigned int right = ttfx_geometry_x_edge(geometry, column + 1U);
                        long cell_x = (long)geometry->grid_x + (long)left + x_offset;
                        unsigned long cell_y = geometry->grid_y + row * geometry->cell_height;
                        ply_rectangle_t cell = {
                                .x = cell_x,
                                .y = (long)cell_y,
                                .width = right - left,
                                .height = geometry->cell_height
                        };
                        const TtfxCell *snapshot_cell;
                        uint32_t cell_background = view->plugin->background_color;
                        uint32_t foreground = view->plugin->text_color;
                        bool has_foreground;
                        bool has_background;
                        bool reverse;

                        if (index >= view->plugin->cell_count || cell.width == 0U || cell.height == 0U)
                                continue;
                        snapshot_cell = &view->plugin->cells[index];
                        has_foreground = (snapshot_cell->flags & TTFX_CELL_FG) != 0U;
                        has_background = (snapshot_cell->flags & TTFX_CELL_BG) != 0U;
                        reverse = (snapshot_cell->flags & TTFX_CELL_REVERSE) != 0U;
                        if (has_background)
                                cell_background = rgba_over_rgb(snapshot_cell->bg_rgba,
                                                                view->plugin->background_color);
                        if (has_foreground)
                                foreground = rgba_over_rgb(snapshot_cell->fg_rgba,
                                                           cell_background);
                        if (reverse) {
                                uint32_t swapped = cell_background;
                                cell_background = foreground;
                                foreground = swapped;
                                has_background = true;
                                has_foreground = true;
                        }
                        if (has_foreground &&
                            ttfx_state_reaction_row_red(&view->plugin->state, row))
                                foreground = ERROR_GLITCH_COLOR;
                        if (has_background)
                                ply_pixel_buffer_fill_with_hex_color(buffer, &cell,
                                                                    cell_background);
                        if (snapshot_cell->codepoint != UINT32_C(0x20) &&
                            snapshot_cell->codepoint != 0U && has_foreground &&
                            (snapshot_cell->flags & TTFX_CELL_HIDDEN) == 0U) {
                                /* Preserve the official logo blocks geometrically; every other
                                 * decrypt symbol uses the pinned shared 5x10 glyph atlas. */
                                unsigned long half = cell.height / 2U;
                                if (snapshot_cell->codepoint == UINT32_C(0x2580)) {
                                        cell.height = half;
                                } else if (snapshot_cell->codepoint == UINT32_C(0x2584)) {
                                        cell.y += (long)half;
                                        cell.height -= half;
                                } else if (snapshot_cell->codepoint != UINT32_C(0x2588)) {
                                        draw_glyph_mask(buffer, &cell,
                                                        snapshot_cell->codepoint,
                                                        foreground);
                                        continue;
                                }
                                if (cell.height > 0U)
                                        ply_pixel_buffer_fill_with_hex_color(buffer, &cell, foreground);
                        }
                }
        }
}

static void get_entry_position(view_t *view, long *entry_x, long *entry_y)
{
        unsigned long screen_width = ply_pixel_display_get_width(view->display);
        unsigned long screen_height = ply_pixel_display_get_height(view->display);
        long entry_width = ply_entry_get_width(view->entry);
        long entry_height = ply_entry_get_height(view->entry);
        *entry_x = ((long)screen_width - entry_width) / 2L;
        *entry_y = (long)(view->geometry.grid_y + view->geometry.grid_height + 24U);

        if (*entry_y + entry_height + 36L > (long)screen_height)
                *entry_y = (long)screen_height - entry_height - 36L;
        if (*entry_y < 0L)
                *entry_y = 0L;
}

static void draw_progress(view_t *view, ply_pixel_buffer_t *buffer)
{
        ply_boot_splash_plugin_t *plugin = view->plugin;
        long screen_width = (long)ply_pixel_display_get_width(view->display);
        long entry_x;
        long entry_y;
        long entry_height = ply_entry_get_height(view->entry);
        long box_width;
        long box_height;
        long bar_width;
        long bar_height;
        long box_x;
        long box_y;
        long bar_x;
        long bar_y;
        long fill_width;
        ply_rectangle_t clip;

        if (!plugin->progress_visible || plugin->progress_box_image == NULL ||
            plugin->progress_bar_image == NULL)
                return;
        box_width = ply_image_get_width(plugin->progress_box_image);
        box_height = ply_image_get_height(plugin->progress_box_image);
        bar_width = ply_image_get_width(plugin->progress_bar_image);
        bar_height = ply_image_get_height(plugin->progress_bar_image);
        if (box_width <= 0L || box_height <= 0L || bar_width <= 0L || bar_height <= 0L)
                return;
        get_entry_position(view, &entry_x, &entry_y);
        (void)entry_x;
        box_x = (screen_width - box_width) / 2L;
        box_y = entry_y + (entry_height - box_height) / 2L;
        bar_x = (screen_width - bar_width) / 2L;
        bar_y = box_y + (box_height - bar_height) / 2L;
        fill_width = (long)((double)bar_width * plugin->progress_fraction);
        if (fill_width < 1L)
                fill_width = 1L;
        if (fill_width > bar_width)
                fill_width = bar_width;
        ply_pixel_buffer_fill_with_buffer(buffer,
                                          ply_image_get_buffer(plugin->progress_box_image),
                                          (int)box_x, (int)box_y);
        clip = (ply_rectangle_t){
                .x = bar_x, .y = bar_y,
                .width = (unsigned long)fill_width,
                .height = (unsigned long)bar_height
        };
        ply_pixel_buffer_push_clip_area(buffer, &clip);
        ply_pixel_buffer_fill_with_buffer(buffer,
                                          ply_image_get_buffer(plugin->progress_bar_image),
                                          (int)bar_x, (int)bar_y);
        ply_pixel_buffer_pop_clip_area(buffer);
}

static void sync_password_entry_reaction_position(view_t *view)
{
        int target_offset;
        long entry_x;
        long entry_y;

        if (!view->entry_loaded || !view->state.prompt_visible ||
            view->plugin->state.prompt_mode != TTFX_PROMPT_PASSWORD)
                return;
        target_offset = ttfx_state_reaction_x_offset(&view->plugin->state);
        if (target_offset == view->entry_reaction_x_offset)
                return;
        get_entry_position(view, &entry_x, &entry_y);
        ply_entry_hide(view->entry);
        ply_entry_show(view->entry, view->plugin->loop, view->display,
                       entry_x + target_offset, entry_y);
        view->entry_reaction_x_offset = target_offset;
}

/* Moves a visible prompt to the view's current geometry (display-swap glide). */
static void reposition_view_prompt(view_t *view)
{
        unsigned long screen_width = ply_pixel_display_get_width(view->display);
        long label_width = (long)(screen_width * 4U / 5U);
        long entry_x;
        long entry_y;

        if (!view->entry_loaded || !view->state.prompt_visible)
                return;
        get_entry_position(view, &entry_x, &entry_y);
        ply_entry_hide(view->entry);
        ply_entry_show(view->entry, view->plugin->loop, view->display,
                       entry_x + view->entry_reaction_x_offset, entry_y);
        if (view->plugin->state.prompt_mode == TTFX_PROMPT_QUESTION && view->labels_loaded &&
            ttfx_view_prompt_can_show(&view->state))
                (void)ply_label_show(view->prompt_label, view->display,
                                     ((long)screen_width - label_width) / 2L,
                                     entry_y + ply_entry_get_height(view->entry) + 10L);
}

/* Red-tinted copy of the lock image used while the wrong-answer reaction is
 * active, so the padlock also signals the failure instead of only the entry
 * outline and animation row. */
static ply_pixel_buffer_t *build_error_lock_buffer(ply_image_t *image)
{
        if (image == NULL)
                return NULL;
        ply_pixel_buffer_t *source = ply_image_get_buffer(image);
        unsigned long width = ply_pixel_buffer_get_width(source);
        unsigned long height = ply_pixel_buffer_get_height(source);
        ply_pixel_buffer_t *tinted = ply_pixel_buffer_new(width, height);
        if (tinted == NULL)
                return NULL;
        uint32_t *src = ply_pixel_buffer_get_argb32_data(source);
        uint32_t *dst = ply_pixel_buffer_get_argb32_data(tinted);
        if (src == NULL || dst == NULL) {
                ply_pixel_buffer_free(tinted);
                return NULL;
        }
        const uint32_t tr = (ERROR_GLITCH_COLOR >> 16) & 0xffU;
        const uint32_t tg = (ERROR_GLITCH_COLOR >> 8) & 0xffU;
        const uint32_t tb = ERROR_GLITCH_COLOR & 0xffU;
        for (unsigned long i = 0UL; i < width * height; i++) {
                uint32_t px = src[i];
                uint32_t a = px >> 24;
                if (a == 0U) {
                        dst[i] = 0U;
                        continue;
                }
                uint32_t r = (px >> 16) & 0xffU;
                uint32_t g = (px >> 8) & 0xffU;
                uint32_t b = px & 0xffU;
                r = (r * 30U + tr * 70U) / 100U;
                g = (g * 30U + tg * 70U) / 100U;
                b = (b * 30U + tb * 70U) / 100U;
                dst[i] = (a << 24) | (r << 16) | (g << 8) | b;
        }
        return tinted;
}

static bool draw_lock_image(view_t *view, ply_pixel_buffer_t *buffer)
{
        ply_image_t *image = view->plugin->lock_image;
        long entry_x;
        long entry_y;
        long entry_height;
        long lock_width;
        long lock_height;

        if (image == NULL)
                return false;
        ply_pixel_buffer_t *source = ply_image_get_buffer(image);
        if (ttfx_state_reaction_active(&view->plugin->state) &&
            view->plugin->lock_buffer_error != NULL)
                source = view->plugin->lock_buffer_error;
        get_entry_position(view, &entry_x, &entry_y);
        entry_height = ply_entry_get_height(view->entry);
        lock_width = ply_image_get_width(image);
        lock_height = ply_image_get_height(image);
        ply_pixel_buffer_fill_with_buffer(buffer,
                                          source,
                                          (int)(entry_x - lock_width - LOCK_GAP +
                                                ttfx_state_reaction_x_offset(&view->plugin->state)),
                                          (int)(entry_y + (entry_height - lock_height) / 2L));
        return true;
}

static void draw_unlock_marker(view_t *view, ply_pixel_buffer_t *buffer)
{
        long entry_width = ply_entry_get_width(view->entry);
        long entry_height = ply_entry_get_height(view->entry);
        long entry_x;
        long entry_y;
        long marker_x;
        ply_rectangle_t body;
        ply_rectangle_t shackle_top;
        ply_rectangle_t shackle_side;

        get_entry_position(view, &entry_x, &entry_y);
        marker_x = (entry_x >= 28L ? entry_x - 28L : entry_x + entry_width + 8L) +
                   ttfx_state_reaction_x_offset(&view->plugin->state);
        body = (ply_rectangle_t){
                .x = marker_x,
                .y = entry_y + entry_height / 2L - 2L,
                .width = 18U,
                .height = 14U
        };
        shackle_top = (ply_rectangle_t){
                .x = marker_x + 4L,
                .y = body.y - 7L,
                .width = 10U,
                .height = 3U
        };
        shackle_side = (ply_rectangle_t){
                .x = marker_x + 4L,
                .y = body.y - 7L,
                .width = 3U,
                .height = 9U
        };
        ply_pixel_buffer_fill_with_hex_color(buffer, &body, view->plugin->text_color);
        ply_pixel_buffer_fill_with_hex_color(buffer, &shackle_top, view->plugin->text_color);
        ply_pixel_buffer_fill_with_hex_color(buffer, &shackle_side, view->plugin->text_color);
}

static void draw_password_error_overlay(view_t *view, ply_pixel_buffer_t *buffer)
{
        long entry_width = ply_entry_get_width(view->entry);
        long entry_height = ply_entry_get_height(view->entry);
        long entry_x;
        long entry_y;
        int x_offset = ttfx_state_reaction_x_offset(&view->plugin->state);

        if (!ttfx_state_reaction_active(&view->plugin->state) ||
            entry_width < 6L || entry_height < 6L)
                return;
        get_entry_position(view, &entry_x, &entry_y);
        entry_x += x_offset;
        ply_rectangle_t outline[] = {
                {.x = entry_x, .y = entry_y,
                 .width = (unsigned long)entry_width, .height = 3U},
                {.x = entry_x, .y = entry_y + entry_height - 3L,
                 .width = (unsigned long)entry_width, .height = 3U},
                {.x = entry_x, .y = entry_y,
                 .width = 3U, .height = (unsigned long)entry_height},
                {.x = entry_x + entry_width - 3L, .y = entry_y,
                 .width = 3U, .height = (unsigned long)entry_height},
                {.x = entry_x + 6L, .y = entry_y + 11L, .width = 22U, .height = 3U},
                {.x = entry_x + entry_width - 28L, .y = entry_y + 33L,
                 .width = 22U, .height = 3U}
        };
        for (size_t index = 0U; index < sizeof(outline) / sizeof(outline[0]); index++)
                ply_pixel_buffer_fill_with_hex_color(buffer, &outline[index], ERROR_GLITCH_COLOR);

        unsigned int bullets = view->plugin->state.bullets > 0 ?
                               (unsigned int)view->plugin->state.bullets : 0U;
        unsigned int capacity = entry_width > 16L ? (unsigned int)(entry_width - 16L) / 10U : 0U;
        if (bullets > capacity)
                bullets = capacity;
        long bullet_x = entry_x + (entry_width - (long)bullets * 10L) / 2L + 3L;
        for (unsigned int bullet = 0U; bullet < bullets; bullet++) {
                ply_rectangle_t marker = {
                        .x = bullet_x + (long)bullet * 10L,
                        .y = entry_y + (entry_height - 4L) / 2L,
                        .width = 4U,
                        .height = 4U
                };
                ply_pixel_buffer_fill_with_hex_color(buffer, &marker, ERROR_GLITCH_COLOR);
        }
}

static void capture_full_frame(view_t *view, ply_pixel_buffer_t *buffer,
                               int x, int y, int width, int height)
{
        ply_boot_splash_plugin_t *plugin = view->plugin;
        unsigned long w = ply_pixel_display_get_width(view->display);
        unsigned long h = ply_pixel_display_get_height(view->display);
        int scale = ply_pixel_buffer_get_device_scale(buffer);
        unsigned long physical_width;
        unsigned long physical_height;
        bool exclusive;

        /* The reaction changes the base grid without encoding that change in
         * the handoff phase. Keep an older clean capture only if its phase
         * still matches when idle is reached. */
        if (ttfx_state_reaction_active(&plugin->state))
                return;
        /* A partial repaint cannot certify or invalidate a complete base: the
         * entry widget emits one while hiding for the success fade. */
        if (x != 0 || y != 0 || width != (int)w || height != (int)h)
                return;
        view->raw_valid = false;
        /* Preserve each upright view's complete physical HiDPI buffer after a
         * full repaint has passed every check: the fbcon handoff picks the view
         * that matches the console framebuffer. raw_valid, which certifies the
         * capture for the desktop bridge's raw file, still requires the view to
         * be the only one. */
        exclusive = plugin->views == view && view->next == NULL;
        if (!plugin->visible ||
            !plugin->drawn_valid || !w || !h || scale <= 0 ||
            w > TTFX_CAPTURE_MAX_WIDTH / (unsigned int)scale ||
            h > TTFX_CAPTURE_MAX_HEIGHT / (unsigned int)scale ||
            ply_pixel_buffer_get_device_rotation(buffer) != PLY_PIXEL_BUFFER_ROTATE_UPRIGHT ||
            ply_pixel_buffer_get_width(buffer) != w || ply_pixel_buffer_get_height(buffer) != h)
                return;
        physical_width = w * (unsigned int)scale;
        physical_height = h * (unsigned int)scale;
        uint32_t *pixels = ply_pixel_buffer_get_argb32_data(buffer);
        if (!pixels)
                return;
        size_t bytes = (size_t)physical_width * physical_height * sizeof(uint32_t);
        if (view->raw_capacity != bytes) {
                free(view->raw_pixels);
                view->raw_pixels = malloc(bytes);
                view->raw_capacity = view->raw_pixels ? bytes : 0;
        }
        if (!view->raw_pixels)
                return;
        memcpy(view->raw_pixels, pixels, bytes);
        view->raw_width = (uint32_t)physical_width;
        view->raw_height = (uint32_t)physical_height;
        view->raw_logical_width = (uint32_t)w;
        view->raw_logical_height = (uint32_t)h;
        view->raw_captured_ns = ttfx_boottime_ns();
        view->raw_phase = plugin->drawn_phase;
        view->raw_valid = exclusive && view->raw_captured_ns != 0;
}

/* The mark resized to TTFX_FIRMWARE_MARK_LOGICAL_SIZE logical pixels for the
 * buffer's device scale, its pixel buffer tagged with that scale so Plymouth
 * composites it 1:1 on HiDPI panels. NULL without a usable mark. */
static ply_pixel_buffer_t *firmware_mark_for_scale(ply_boot_splash_plugin_t *plugin, int scale)
{
        ply_image_t *source = plugin->mark_image;
        long source_width;
        long source_height;
        long size;

        if (scale < 1)
                scale = 1;
        if (scale > FIRMWARE_MARK_MAX_SCALE)
                scale = FIRMWARE_MARK_MAX_SCALE;
        if (plugin->mark_scaled_scale == scale)
                return plugin->mark_scaled != NULL ? ply_image_get_buffer(plugin->mark_scaled) : NULL;
        if (plugin->mark_scaled != NULL)
                ply_image_free(plugin->mark_scaled);
        plugin->mark_scaled = NULL;
        plugin->mark_scaled_scale = scale;
        if (source == NULL)
                return NULL;
        source_width = ply_image_get_width(source);
        source_height = ply_image_get_height(source);
        if (source_width <= 0L || source_width > LOCK_MAX_DIMENSION ||
            source_height <= 0L || source_height > LOCK_MAX_DIMENSION)
                return NULL;
        size = TTFX_FIRMWARE_MARK_LOGICAL_SIZE * (long)scale;
        plugin->mark_scaled = ply_image_resize(source, size, size);
        if (plugin->mark_scaled == NULL)
                return NULL;
        ply_pixel_buffer_set_device_scale(ply_image_get_buffer(plugin->mark_scaled), scale);
        return ply_image_get_buffer(plugin->mark_scaled);
}

/* Firmware hold frame: background plus the centred mark, nothing else; on a
 * framebuffer that hides a notch the mark is centred on the whole panel. */
static void draw_firmware_hold(ply_boot_splash_plugin_t *plugin,
                               ply_pixel_buffer_t *buffer,
                               unsigned long width,
                               unsigned long height)
{
        int scale = ply_pixel_buffer_get_device_scale(buffer);
        ply_pixel_buffer_t *mark = firmware_mark_for_scale(plugin, scale);

        if (mark == NULL)
                return;
        ply_pixel_buffer_fill_with_buffer(buffer, mark,
                                          (int)(((long)width - TTFX_FIRMWARE_MARK_LOGICAL_SIZE) / 2L),
                                          (int)(((long)height - TTFX_FIRMWARE_MARK_LOGICAL_SIZE) / 2L -
                                                ttfx_firmware_mark_lift(plugin->firmware_hidden_notch,
                                                                        scale)));
}

static void on_draw(void *user_data,
                    ply_pixel_buffer_t *pixel_buffer,
                    int x,
                    int y,
                    int width,
                    int height,
                    ply_pixel_display_t *pixel_display)
{
        view_t *view = user_data;
        ply_rectangle_t clip = {.x = x, .y = y, .width = (unsigned long)width, .height = (unsigned long)height};
        ply_rectangle_t background = clip;
        unsigned long display_width = ply_pixel_display_get_width(pixel_display);
        unsigned long display_height = ply_pixel_display_get_height(pixel_display);

        ply_pixel_buffer_push_clip_area(pixel_buffer, &clip);
        ply_pixel_buffer_fill_with_hex_color(pixel_buffer, &background, view->plugin->background_color);
        /* Nothing drawn during the hold is captured: it is neither an
         * animation frame for the handoff nor a frame to bridge a swap with. */
        if (view->plugin->firmware_hold) {
                draw_firmware_hold(view->plugin, pixel_buffer, display_width, display_height);
                ply_pixel_buffer_pop_clip_area(pixel_buffer);
                return;
        }
        if (view->plugin->outro_plain) {
                /* The outro has dissolved the logo (or failed): only the plain
                 * background is left, the colour the desktop starts on. */
        } else if (view->plugin->state.animation_enabled && view->plugin->cells != NULL)
                draw_grid(view, pixel_buffer);
        else
                draw_static_fallback(view->plugin, pixel_buffer, display_width, display_height);

        /* Certify and copy the complete animation-only base before any lock,
         * entry, bullet, prompt label, or message label can touch the buffer. */
        if (!view->plugin->idle) {
                ply_boot_splash_plugin_t *plugin = view->plugin;
                const ttfx_geometry_t *g = &view->geometry;
                bool covers_grid = x <= (int)g->grid_x && y <= (int)g->grid_y &&
                        (int64_t)x + width >= (int64_t)g->grid_x + g->grid_width &&
                        (int64_t)y + height >= (int64_t)g->grid_y + g->grid_height;
                bool touches_grid = (int64_t)x + width > g->grid_x &&
                        (int64_t)y + height > g->grid_y &&
                        x < (int64_t)g->grid_x + g->grid_width &&
                        y < (int64_t)g->grid_y + g->grid_height;
                if (touches_grid && (!plugin->state.animation_enabled || plugin->cells == NULL ||
                    plugin->phase.step != plugin->drawn_phase.step ||
                    plugin->phase.cycle != plugin->drawn_phase.cycle))
                        plugin->drawn_valid = false;
                if (covers_grid && plugin->visible && plugin->state.animation_enabled &&
                    plugin->cells != NULL && plugin->canvas_width == ENGINE_WIDTH &&
                    plugin->canvas_height == ENGINE_HEIGHT) {
                        memcpy(plugin->drawn_cells, plugin->cells, sizeof(plugin->drawn_cells));
                        plugin->drawn_phase = plugin->phase;
                        plugin->drawn_valid = true;
                }
                capture_full_frame(view, pixel_buffer, x, y, width, height);
        }
        if (view->plugin->progress_visible) {
                draw_progress(view, pixel_buffer);
        } else {
                if (view->state.prompt_visible &&
                    view->plugin->state.prompt_mode == TTFX_PROMPT_PASSWORD &&
                    !draw_lock_image(view, pixel_buffer))
                        draw_unlock_marker(view, pixel_buffer);
                if (view->entry_loaded && view->state.prompt_visible)
                        ply_entry_draw_area(view->entry, pixel_buffer, x, y,
                                            (unsigned long)width, (unsigned long)height);
                if (view->entry_loaded && view->state.prompt_visible &&
                    view->plugin->state.prompt_mode == TTFX_PROMPT_PASSWORD)
                        draw_password_error_overlay(view, pixel_buffer);
        }
        if (view->state.prompt_visible && view->state.prompt_label_available &&
            view->plugin->state.prompt_mode == TTFX_PROMPT_QUESTION)
                ply_label_draw_area(view->prompt_label, pixel_buffer, x, y, (unsigned long)width, (unsigned long)height);
        if (view->state.message_visible && view->state.message_label_available &&
            view->plugin->state.prompt_mode != TTFX_PROMPT_PASSWORD)
                ply_label_draw_area(view->message_label, pixel_buffer, x, y, (unsigned long)width, (unsigned long)height);
        ply_pixel_buffer_pop_clip_area(pixel_buffer);
        /* The replacement display has a complete frame of its own now: stop
         * painting the old one into the console framebuffer. */
        if (view->plugin->swap_bridge != NULL && x == 0 && y == 0 &&
            width == (int)display_width && height == (int)display_height)
                stop_swap_bridge(view->plugin);
}

/* The blank frame was fully drawn (or there is no display to draw it). */
static bool outro_blank_drawn(ply_boot_splash_plugin_t *plugin)
{
        return plugin->views == NULL ||
               (plugin->drawn_valid && plugin->drawn_phase.step == plugin->phase.step &&
                plugin->drawn_phase.cycle == plugin->phase.cycle);
}

static bool outro_draw_wait_expired(ply_boot_splash_plugin_t *plugin)
{
        uint64_t now_ns = plugin->clock_ns();

        return now_ns < plugin->outro_plain_ns ||
               now_ns - plugin->outro_plain_ns >= OUTRO_DRAW_WAIT_NS;
}

static unsigned int outro_due_calls(ply_boot_splash_plugin_t *plugin)
{
        uint64_t now_ns = plugin->clock_ns();
        uint64_t elapsed = now_ns > plugin->outro_started_ns ? now_ns - plugin->outro_started_ns : 0U;

        return ttfx_outro_due_calls(elapsed, plugin->outro_ms, plugin->outro_calls, plugin->outro_done);
}

static void on_timeout(void *user_data, ply_event_loop_t *loop)
{
        ply_boot_splash_plugin_t *plugin = user_data;
        bool password_was_pending;
        unsigned int engine_steps;

        (void)loop;
        plugin->timeout_scheduled = false;
        if (!plugin->visible || plugin->loop == NULL || plugin->idle)
                return;

        /* The hold freezes the engine, prompt timers, reactions and progress:
         * the animation starts from its first frame once the hold is over. */
        if (plugin->firmware_hold) {
                uint64_t now_ns = plugin->clock_ns();

                if (now_ns < plugin->firmware_hold_started_ns ||
                    now_ns - plugin->firmware_hold_started_ns >= TTFX_FIRMWARE_HOLD_NS)
                        release_firmware_hold(plugin, "firmware hold: released (deadline)");
                else
                        schedule_timeout_if_needed(plugin);
                return;
        }

        if (plugin->success_pending && plugin->state.playback_phase == TTFX_PLAYBACK_FINAL) {
                uint64_t now_ns = plugin->clock_ns();
                bool terminal_drawn = plugin->drawn_valid &&
                                      plugin->drawn_phase.step == plugin->phase.step &&
                                      plugin->drawn_phase.cycle == plugin->phase.cycle;
                bool wait_expired = plugin->success_started_ns != 0U &&
                                    now_ns >= plugin->success_started_ns &&
                                    now_ns - plugin->success_started_ns >= FINAL_DRAW_WAIT_NS;
                if (terminal_drawn || wait_expired) {
                        finish_become_idle(plugin);
                        return;
                }
        }

        /* The blank frame is exposed: idle completes once it was drawn, or
         * after a short wait when no display draws it. */
        if (plugin->outro_active && plugin->outro_plain) {
                if (outro_blank_drawn(plugin) || outro_draw_wait_expired(plugin)) {
                        finish_become_idle(plugin);
                        return;
                }
                schedule_timeout_if_needed(plugin);
                return;
        }

        password_was_pending = ttfx_state_password_pending(&plugin->state);
        if (plugin->outro_active)
                engine_steps = outro_due_calls(plugin);
        else
                engine_steps = plugin->state.animation_enabled && !plugin->static_degraded
                                       ? ttfx_state_engine_steps_per_tick(&plugin->state)
                                       : 0U;
        if (plugin->progress_visible && password_was_pending)
                plugin->state.failure_candidate_tick = 0U;
        ttfx_state_tick(&plugin->state);
        advance_fake_progress(plugin);
        if (progress_validation_expired(plugin)) {
                ttfx_state_clear_prompt(&plugin->state);
                stop_progress(plugin);
        }
        if (password_was_pending && !ttfx_state_password_pending(&plugin->state)) {
                stop_progress(plugin);
                for (view_t *view = plugin->views; view != NULL; view = view->next) {
                        apply_current_prompt(view);
                        apply_current_message(view);
                }
        }
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                sync_password_entry_reaction_position(view);
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                int offset;

                if (view->glide_offset == 0)
                        continue;
                view->glide_tick++;
                offset = ttfx_glide_offset(view->glide_from, view->glide_tick, TTFX_DISPLAY_GLIDE_TICKS);
                if (offset == view->glide_offset)
                        continue;
                view->glide_offset = offset;
                refresh_view_geometry(view);
                reposition_view_prompt(view);
        }
        for (unsigned int step = 0U; step < engine_steps; step++) {
                uint8_t looped = 0U;
                uint8_t finished = 0U;
                /* The logo is drawn through the engine's single entry point:
                 * LOOP while waiting for input (both playback modes keep the
                 * animation rotating during password entry), ONE_TIME while
                 * accelerating to the end and once the final frame is held,
                 * REVERSE while the outro plays the record backwards. */
                uint32_t mode = plugin->outro_active ? TTFX_LOGO_MODE_REVERSE
                                : plugin->state.playback_phase == TTFX_PLAYBACK_INPUT
                                        ? TTFX_LOGO_MODE_LOOP
                                        : TTFX_LOGO_MODE_ONE_TIME;

                clear_snapshot(plugin);
                if (plugin->engine == NULL ||
                    ttfx_engine_draw_logo(plugin->engine, mode, &looped,
                                          &finished) != TTFX_STATUS_OK ||
                    !update_snapshot(plugin)) {
                        bool outro = plugin->outro_active;

                        free_engine(plugin);
                        ttfx_state_disable_animation(&plugin->state);
                        plugin->static_degraded = true;
                        /* A failed outro still ends on the plain background,
                         * at once: never hold up the handover. */
                        if (outro)
                                plugin->outro_plain = true;
                        damage_all_views(plugin);
                        if (outro) {
                                finish_become_idle(plugin);
                                return;
                        }
                        schedule_timeout_if_needed(plugin);
                        return;
                }
                if (plugin->outro_active) {
                        plugin->outro_done++;
                        if (plugin->phase.step != UINT64_MAX)
                                plugin->phase.step++;
                        if (finished) {
                                plugin->outro_plain = true;
                                plugin->outro_plain_ns = plugin->clock_ns();
                                break;
                        }
                        continue;
                }
                if (looped) {
                        /* LOOP restarted the tape this call. */
                        plugin->phase.step = 0U;
                        if (plugin->phase.cycle != UINT64_MAX)
                                plugin->phase.cycle++;
                        break;
                }
                if (finished) {
                        /* ONE_TIME completed: the engine now holds the final
                         * frame on every later call. */
                        ttfx_state_engine_completed(&plugin->state);
                        break;
                }
                if (plugin->phase.step != UINT64_MAX)
                        plugin->phase.step++;
        }
        damage_all_views(plugin);
        /* Plymouth draws synchronously: usually the blank frame is already on
         * screen (and captured) here, and idle completes on this tick. */
        if (plugin->outro_active && plugin->outro_plain && outro_blank_drawn(plugin)) {
                finish_become_idle(plugin);
                return;
        }
        schedule_timeout_if_needed(plugin);
}

static void detach_from_event_loop(void *user_data,
                                   int exit_code,
                                   ply_event_loop_t *loop)
{
        ply_boot_splash_plugin_t *plugin = user_data;

        (void)exit_code;
        (void)loop;
        (void)ttfx_loop_detach_watch(&plugin->loop_state);
        plugin->loop = NULL;
        plugin->timeout_scheduled = false;
}

static void stop_animation(ply_boot_splash_plugin_t *plugin)
{
        if (plugin->loop != NULL && plugin->timeout_scheduled) {
                ply_event_loop_stop_watching_for_timeout(plugin->loop,
                                                         on_timeout,
                                                         plugin);
                plugin->timeout_scheduled = false;
        }
}

/* Publishes the fbcon frame plus the desktop bridge handoff (state + raw).
 * Must run before the splash goes away, regardless of whether the daemon
 * idles the plugin or deactivates/hides it. */
/* After the outro the splash ends on the plain background: that is the frame
 * for the console restore and for the desktop's continuity overlay. There is
 * no animation left to continue, so the phase file is removed. */
static void publish_outro_handoff(ply_boot_splash_plugin_t *plugin)
{
        uint32_t plain = UINT32_C(0xff000000) | plugin->background_color;
        view_t *view = plugin->views;

        /* A full repaint of the blank frame is exactly the background, so a
         * view whose last capture predates it (a partial or no draw since)
         * gets that frame for the console restore. */
        for (view_t *each = plugin->views; each != NULL; each = each->next) {
                size_t count = (size_t)each->raw_width * each->raw_height;

                if (each->raw_pixels == NULL)
                        continue;
                for (size_t index = 0U; index < count; index++)
                        each->raw_pixels[index] = plain;
        }
        publish_frame_to_fbcon(plugin);
        ttfx_handoff_clear(plugin->handoff_directory);
        plugin->handoff_published = false;
        /* The raw file stays a real capture: the blank frame's own full
         * repaint, timestamped when it was drawn, on the only display. */
        if (plugin->visible && view && !view->next && view->raw_valid && plugin->drawn_valid &&
            view->raw_logical_width == ply_pixel_display_get_width(view->display) &&
            view->raw_logical_height == ply_pixel_display_get_height(view->display) &&
            view->raw_phase.step == plugin->phase.step && view->raw_phase.cycle == plugin->phase.cycle &&
            plugin->drawn_phase.step == plugin->phase.step &&
            plugin->drawn_phase.cycle == plugin->phase.cycle)
                (void)ttfx_raw_publish(plugin->handoff_directory, view->raw_pixels,
                                       view->raw_width, view->raw_height, view->raw_captured_ns);
        plugin->outro_published = true;
}

static void publish_handoff(ply_boot_splash_plugin_t *plugin)
{
        if (plugin->outro_plain) {
                publish_outro_handoff(plugin);
                return;
        }
        publish_frame_to_fbcon(plugin);
        if (plugin->drawn_valid && plugin->state.animation_enabled && !plugin->static_degraded) {
                plugin->cells = plugin->drawn_cells;
                plugin->cell_count = ENGINE_WIDTH * ENGINE_HEIGHT;
                plugin->canvas_width = ENGINE_WIDTH;
                plugin->canvas_height = ENGINE_HEIGHT;
                const ttfx_handoff_t handoff = {
                        .effect = plugin->effect, .seed = plugin->seed,
                        .phase = plugin->drawn_phase,
                        .width = ENGINE_WIDTH, .height = ENGINE_HEIGHT,
                        .fps = ENGINE_FPS, .speed = ENGINE_STEPS_PER_TICK,
                        .background = plugin->background_color, .foreground = plugin->text_color,
                        .hold_final = plugin->state.playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH
                };
                plugin->handoff_published = ttfx_handoff_publish(plugin->handoff_directory, &handoff);
        } else {
                ttfx_handoff_clear(plugin->handoff_directory);
        }
        /* Raw is optional, but it must refer to exactly the published phase. */
        view_t *view = plugin->views;
        ttfx_raw_clear(plugin->handoff_directory);
        if (plugin->handoff_published && plugin->visible && view && !view->next && view->raw_valid &&
            view->raw_logical_width == ply_pixel_display_get_width(view->display) &&
            view->raw_logical_height == ply_pixel_display_get_height(view->display) &&
            view->raw_phase.step == plugin->drawn_phase.step &&
            view->raw_phase.cycle == plugin->drawn_phase.cycle)
                (void)ttfx_raw_publish(plugin->handoff_directory, view->raw_pixels,
                                       view->raw_width, view->raw_height, view->raw_captured_ns);
}

/* Ends an active hold without showing anything; false when none was active. */
static bool end_firmware_hold(ply_boot_splash_plugin_t *plugin, const char *message)
{
        if (!plugin->firmware_hold)
                return false;
        plugin->firmware_hold = false;
        plugin->firmware_hold_released = true;
        fbcon_klog(message);
        return true;
}

/* Ends an active hold and starts the splash proper: first animation frame,
 * current prompt and message on every view. */
static void release_firmware_hold(ply_boot_splash_plugin_t *plugin, const char *message)
{
        if (!end_firmware_hold(plugin, message))
                return;
        if (plugin->engine != NULL && (plugin->phase.step != 0U || plugin->phase.cycle != 0U)) {
                clear_snapshot(plugin);
                if (ttfx_engine_reset(plugin->engine) != TTFX_STATUS_OK || !update_snapshot(plugin)) {
                        free_engine(plugin);
                        ttfx_state_disable_animation(&plugin->state);
                        plugin->static_degraded = true;
                }
        }
        plugin->phase = (ttfx_phase_t){0};
        plugin->drawn_valid = false;
        /* Fake progress is timed from its start: count it from now so it does
         * not jump by the length of the hold. */
        if (plugin->progress_visible && plugin->progress_started_ns != 0U)
                plugin->progress_started_ns = plugin->clock_ns != NULL ? plugin->clock_ns() : 0U;
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                apply_current_prompt(view);
                apply_current_message(view);
        }
        damage_all_views(plugin);
        schedule_timeout_if_needed(plugin);
}

static void finish_become_idle(ply_boot_splash_plugin_t *plugin)
{
        ply_trigger_t *idle_trigger = plugin->idle_trigger;

        plugin->idle_trigger = NULL;
        plugin->success_pending = false;
        plugin->success_started_ns = 0U;
        plugin->outro_active = false;
        stop_progress(plugin);
        plugin->idle = true;
        stop_animation(plugin);
        if (plugin->state.prompt_mode != TTFX_PROMPT_NONE) {
                ttfx_state_clear_prompt(&plugin->state);
                for (view_t *view = plugin->views; view != NULL; view = view->next)
                        hide_view_prompt(view);
                damage_all_views(plugin);
        }
        publish_handoff(plugin);
        /* Trigger can synchronously destroy the plugin: access nothing after pull. */
        if (idle_trigger != NULL)
                ply_trigger_pull(idle_trigger, NULL);
}

/* Starts the reverse outro of at most max_calls engine draws. False, with
 * nothing changed, when it does not apply: disabled, not the boot splash, no
 * record, nothing animated on screen, or the engine declines. */
static bool start_outro(ply_boot_splash_plugin_t *plugin, uint32_t max_calls)
{
        uint32_t calls = 0U;

        if (!plugin->outro_recording || !plugin->outro_mode_allowed || plugin->outro_active ||
            plugin->outro_plain || !plugin->visible || plugin->loop == NULL || plugin->views == NULL ||
            plugin->engine == NULL || !plugin->state.animation_enabled || plugin->static_degraded ||
            plugin->state.rendering_failed || plugin->firmware_hold)
                return false;
        if (ttfx_engine_begin_reverse(plugin->engine, max_calls, ENGINE_STEPS_PER_TICK,
                                      &calls) != TTFX_STATUS_OK || calls == 0U)
                return false;
        plugin->outro_active = true;
        plugin->outro_calls = calls;
        plugin->outro_done = 0U;
        plugin->outro_started_ns = plugin->clock_ns();
        plugin->success_pending = false;
        stop_progress(plugin);
        /* Nothing but the dissolving logo: no prompt, entry, reaction,
         * message or progress while the outro plays. */
        ttfx_state_clear_prompt(&plugin->state);
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                hide_view_prompt(view);
                hide_view_message(view);
        }
        fbcon_klog("outro: reverse playback started");
        return true;
}

/* Ends a running outro at once on its blank frame and repaints every view
 * (Plymouth draws synchronously, so the plain frame is captured here). */
static void finish_outro_now(ply_boot_splash_plugin_t *plugin)
{
        while (!plugin->outro_plain && plugin->outro_done < plugin->outro_calls) {
                uint8_t finished = 0U;

                clear_snapshot(plugin);
                if (plugin->engine == NULL ||
                    ttfx_engine_draw_logo(plugin->engine, TTFX_LOGO_MODE_REVERSE, NULL,
                                          &finished) != TTFX_STATUS_OK ||
                    !update_snapshot(plugin)) {
                        free_engine(plugin);
                        ttfx_state_disable_animation(&plugin->state);
                        plugin->static_degraded = true;
                        break;
                }
                plugin->outro_done++;
                if (plugin->phase.step != UINT64_MAX)
                        plugin->phase.step++;
                if (finished)
                        break;
        }
        plugin->outro_plain = true;
        plugin->outro_plain_ns = plugin->clock_ns();
        damage_all_views(plugin);
}

static void become_idle(ply_boot_splash_plugin_t *plugin, ply_trigger_t *idle_trigger)
{
        if (plugin->idle) {
                ply_trigger_pull(idle_trigger, NULL);
                return;
        }
        stop_progress(plugin);
        plugin->idle_trigger = idle_trigger;
        /* No animation was shown yet: there is nothing to play to its end. */
        if (end_firmware_hold(plugin, "firmware hold: released (idle)")) {
                finish_become_idle(plugin);
                return;
        }
        /* The outro plays backwards from wherever the animation is, so the
         * success fast-forward to the final frame is not needed first. */
        if (start_outro(plugin, ttfx_outro_max_calls(plugin->outro_ms))) {
                damage_all_views(plugin);
                schedule_timeout_if_needed(plugin);
                return;
        }
        if (plugin->state.playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH &&
            plugin->state.animation_enabled && !plugin->static_degraded &&
            (plugin->state.playback_phase != TTFX_PLAYBACK_FINAL || !plugin->drawn_valid ||
             plugin->drawn_phase.step != plugin->phase.step ||
             plugin->drawn_phase.cycle != plugin->phase.cycle)) {
                plugin->success_pending = true;
                plugin->success_started_ns = plugin->clock_ns();
                ttfx_state_confirm_success(&plugin->state);
                ttfx_state_clear_prompt(&plugin->state);
                for (view_t *view = plugin->views; view != NULL; view = view->next)
                        hide_view_prompt(view);
                damage_all_views(plugin);
                schedule_timeout_if_needed(plugin);
                return;
        }
        finish_become_idle(plugin);
}

static void detach_event_loop_watch(ply_boot_splash_plugin_t *plugin)
{
        if (plugin->loop != NULL && ttfx_loop_detach_watch(&plugin->loop_state))
                ply_event_loop_stop_watching_for_exit(plugin->loop,
                                                      detach_from_event_loop,
                                                      plugin);
        plugin->loop = NULL;
}

static void hide_view_prompt(view_t *view)
{
        if (ttfx_view_hide_prompt(&view->state)) {
                ply_entry_hide(view->entry);
                ply_label_hide(view->prompt_label);
                view->entry_reaction_x_offset = 0;
        }
}

static void hide_view_message(view_t *view)
{
        if (ttfx_view_hide_message(&view->state))
                ply_label_hide(view->message_label);
}

static void enter_degraded_static_mode(ply_boot_splash_plugin_t *plugin)
{
        stop_animation(plugin);
        free_engine(plugin);
        if (plugin->visible)
                plugin->static_degraded = true;
        /* Static mode never holds: show the static splash and prompts now. */
        release_firmware_hold(plugin, "firmware hold: released (static mode)");
        damage_all_views(plugin);
}

static bool place_prompt(view_t *view,
                         const char *prompt,
                         const char *entry_text,
                         int bullets)
{
        unsigned long screen_width = ply_pixel_display_get_width(view->display);
        long entry_height = ply_entry_get_height(view->entry);
        long entry_x;
        long entry_y;
        long label_width = (long)(screen_width * 4U / 5U);

        if (view->plugin->state.rendering_failed)
                return false;
        get_entry_position(view, &entry_x, &entry_y);

        if (entry_text != NULL)
                ply_entry_set_text(view->entry, entry_text);
        if (bullets >= 0)
                ply_entry_set_bullet_count(view->entry, bullets);
        if (ttfx_view_show_prompt(&view->state)) {
                view->entry_reaction_x_offset =
                        view->plugin->state.prompt_mode == TTFX_PROMPT_PASSWORD ?
                        ttfx_state_reaction_x_offset(&view->plugin->state) : 0;
                ply_entry_show(view->entry, view->plugin->loop, view->display,
                               entry_x + view->entry_reaction_x_offset, entry_y);
        }

        if (view->plugin->state.prompt_mode == TTFX_PROMPT_PASSWORD) {
                ply_label_hide(view->prompt_label);
                return true;
        }
        if (!ttfx_view_prompt_can_show(&view->state))
                return true;
        ply_label_set_text(view->prompt_label, prompt != NULL ? prompt : "");
        ply_label_set_alignment(view->prompt_label, PLY_LABEL_ALIGN_CENTER);
        ply_label_set_width(view->prompt_label, label_width);
        if (!ply_label_show(view->prompt_label,
                            view->display,
                            ((long)screen_width - label_width) / 2L,
                            entry_y + entry_height + 10L)) {
                ply_label_hide(view->prompt_label);
                ttfx_view_degrade_prompt(&view->plugin->state, &view->state);
                enter_degraded_static_mode(view->plugin);
                return true;
        }
        return true;
}

static void apply_current_prompt(view_t *view)
{
        const ttfx_state_t *state = &view->plugin->state;

        /* Recorded in the plugin state, shown when the hold is released. */
        if (state->rendering_failed || view->plugin->firmware_hold ||
            view->plugin->outro_active || view->plugin->outro_plain)
                hide_view_prompt(view);
        else if (state->prompt_mode == TTFX_PROMPT_PASSWORD)
                (void)place_prompt(view, state->prompt, NULL, state->bullets);
        else if (state->prompt_mode == TTFX_PROMPT_QUESTION)
                (void)place_prompt(view, state->prompt, state->entry_text, -1);
        else
                hide_view_prompt(view);
}

static void apply_current_message(view_t *view)
{
        const ttfx_state_t *state = &view->plugin->state;

        if (state->rendering_failed || !state->message_visible ||
            state->prompt_mode == TTFX_PROMPT_PASSWORD || view->plugin->firmware_hold ||
            view->plugin->outro_active || view->plugin->outro_plain) {
                hide_view_message(view);
                return;
        }
        if (!ttfx_view_message_can_show(&view->state))
                return;
        ply_label_set_text(view->message_label, state->message);
        if (ttfx_view_show_message(&view->state)) {
                if (!ply_label_show(view->message_label, view->display, 16L, 16L)) {
                        ply_label_hide(view->message_label);
                        ttfx_view_degrade_message(&view->plugin->state, &view->state);
                        enter_degraded_static_mode(view->plugin);
                        return;
                }
        }
}

static bool scale_lock_for_entry(ply_boot_splash_plugin_t *plugin, long entry_height)
{
        ply_image_t *source = plugin->lock_image;
        long source_width;
        long source_height;
        long target_width;
        long target_height;
        ply_image_t *scaled;

        if (source == NULL || plugin->lock_scale_attempted)
                return source != NULL;
        plugin->lock_scale_attempted = true;
        source_width = ply_image_get_width(source);
        source_height = ply_image_get_height(source);
        if (entry_height <= 0L || entry_height > LOCK_MAX_DIMENSION ||
            source_width <= 0L || source_width > LOCK_MAX_DIMENSION ||
            source_height <= 0L || source_height > LOCK_MAX_DIMENSION) {
                ply_image_free(source);
                plugin->lock_image = NULL;
                if (plugin->lock_buffer_error != NULL) {
                        ply_pixel_buffer_free(plugin->lock_buffer_error);
                        plugin->lock_buffer_error = NULL;
                }
                return false;
        }
        target_height = (entry_height * 4L + 2L) / 5L;
        target_width = (entry_height * 4L * source_width + source_height * 5L / 2L) /
                       (source_height * 5L);
        if (target_width <= 0L || target_height <= 0L) {
                ply_image_free(source);
                plugin->lock_image = NULL;
                if (plugin->lock_buffer_error != NULL) {
                        ply_pixel_buffer_free(plugin->lock_buffer_error);
                        plugin->lock_buffer_error = NULL;
                }
                return false;
        }
        scaled = ply_image_resize(source, target_width, target_height);
        ply_image_free(source);
        plugin->lock_image = scaled;
        /* The tinted error copy must come from the SCALED image: building it
         * from the original would draw the padlock bigger on a wrong answer.
         * It only tints; the shake comes from the entry's reaction offset. */
        if (plugin->lock_buffer_error != NULL) {
                ply_pixel_buffer_free(plugin->lock_buffer_error);
                plugin->lock_buffer_error = NULL;
        }
        if (scaled != NULL)
                plugin->lock_buffer_error = build_error_lock_buffer(scaled);
        return scaled != NULL;
}

/* The view's geometry, with any display-swap glide offset still applied. */
static void refresh_view_geometry(view_t *view)
{
        unsigned long width = ply_pixel_display_get_width(view->display);
        unsigned long height = ply_pixel_display_get_height(view->display);
        int64_t grid_y;

        view->geometry = ttfx_geometry_for_view((unsigned int)width, (unsigned int)height);
        grid_y = (int64_t)view->geometry.grid_y + view->glide_offset;
        if (grid_y < 0)
                grid_y = 0;
        if (grid_y + view->geometry.grid_height > (int64_t)height)
                grid_y = height > view->geometry.grid_height ? (int64_t)(height - view->geometry.grid_height) : 0;
        view->geometry.grid_y = (unsigned int)grid_y;
}

static bool load_view(view_t *view)
{
        refresh_view_geometry(view);
        if (!view->entry_loaded)
                view->entry_loaded = ply_entry_load(view->entry);
        if (!view->entry_loaded)
                return false;
        (void)scale_lock_for_entry(view->plugin, ply_entry_get_height(view->entry));
        if (!view->labels_loaded) {
                bool prompt_loaded;
                bool message_loaded;

                ply_label_set_text(view->prompt_label, "");
                prompt_loaded = ply_label_show(view->prompt_label, view->display, 0L, 0L);
                if (prompt_loaded)
                        ply_label_hide(view->prompt_label);
                ply_label_set_text(view->message_label, "");
                message_loaded = ply_label_show(view->message_label, view->display, 0L, 0L);
                if (message_loaded)
                        ply_label_hide(view->message_label);
                if (!prompt_loaded || !message_loaded) {
                        ply_label_hide(view->prompt_label);
                        ply_label_hide(view->message_label);
                        return false;
                }
                ply_label_set_hex_color(view->prompt_label, view->plugin->text_color << 8U | 0xffU);
                ply_label_set_hex_color(view->message_label, view->plugin->message_color << 8U | 0xffU);
                view->labels_loaded = true;
        }
        return true;
}

static view_t *view_new(ply_boot_splash_plugin_t *plugin,
                        ply_pixel_display_t *display)
{
        view_t *view = calloc(1U, sizeof(*view));
        if (view == NULL)
                return NULL;

        view->plugin = plugin;
        view->display = display;
        view->state = ttfx_view_state_initial();
        view->firmware = ttfx_firmware_display(
                ply_renderer_get_device_name(ply_pixel_display_get_renderer(display)),
                TTFX_SYSFS_DRM_PATH);
        view->entry = ply_entry_new(plugin->image_dir);
        view->prompt_label = ply_label_new();
        view->message_label = ply_label_new();
        if (view->entry == NULL || view->prompt_label == NULL || view->message_label == NULL) {
                if (view->entry != NULL)
                        ply_entry_free(view->entry);
                if (view->prompt_label != NULL)
                        ply_label_free(view->prompt_label);
                if (view->message_label != NULL)
                        ply_label_free(view->message_label);
                free(view);
                return NULL;
        }
        ply_label_set_font(view->prompt_label, "Sans 12");
        ply_label_set_font(view->message_label, "Sans 10");
        return view;
}

static void view_free(view_t *view)
{
        ply_pixel_display_set_draw_handler(view->display, NULL, NULL);
        ply_entry_free(view->entry);
        ply_label_free(view->prompt_label);
        ply_label_free(view->message_label);
        free(view->raw_pixels);
        free(view);
}

static bool parse_enabled(const char *value, bool *enabled)
{
        if (value == NULL || enabled == NULL)
                return false;
        if (strcmp(value, "true") == 0) {
                *enabled = true;
                return true;
        }
        if (strcmp(value, "false") == 0) {
                *enabled = false;
                return true;
        }
        return false;
}

static bool mode_is_animated(const char *value)
{
        return value != NULL &&
               (strcmp(value, "fixed") == 0 || strcmp(value, "random") == 0);
}

static bool parse_effect_name(const char *value)
{
        size_t length = 0U;

        if (value == NULL || value[0] < 'a' || value[0] > 'z')
                return false;
        while (value[length] != '\0') {
                unsigned char byte = (unsigned char)value[length];
                if (length >= 127U ||
                    !((byte >= 'a' && byte <= 'z') ||
                      (length > 0U && byte >= '0' && byte <= '9') ||
                      (length > 0U && byte == '-')))
                        return false;
                length++;
        }
        return length > 0U;
}

static bool parse_seed(const char *value, uint64_t *seed)
{
        uint64_t parsed = 0U;
        size_t index = 0U;

        if (value == NULL || seed == NULL || value[0] == '\0' ||
            (value[0] == '0' && value[1] != '\0'))
                return false;
        while (value[index] != '\0') {
                unsigned int digit;
                if (index >= 20U || value[index] < '0' || value[index] > '9')
                        return false;
                digit = (unsigned int)(value[index] - '0');
                if (parsed > (UINT64_MAX - digit) / UINT64_C(10))
                        return false;
                parsed = parsed * UINT64_C(10) + digit;
                index++;
        }
        *seed = parsed;
        return true;
}

static bool parse_color(const char *value, uint32_t *color)
{
        uint32_t parsed = 0U;

        if (value == NULL || color == NULL)
                return false;
        for (size_t index = 0U; index < 6U; index++) {
                unsigned char byte = (unsigned char)value[index];
                unsigned int digit;
                if (byte >= '0' && byte <= '9') digit = byte - '0';
                else if (byte >= 'a' && byte <= 'f') digit = byte - 'a' + 10U;
                else if (byte >= 'A' && byte <= 'F') digit = byte - 'A' + 10U;
                else return false;
                parsed = (parsed << 4U) | digit;
        }
        if (value[6] != '\0')
                return false;
        *color = parsed;
        return true;
}

static char *copy_string(const char *value)
{
        size_t length = strlen(value) + 1U;
        char *copy = malloc(length);
        if (copy != NULL)
                memcpy(copy, value, length);
        return copy;
}

static ply_boot_splash_plugin_t *create_plugin(ply_key_file_t *key_file)
{
        ply_boot_splash_plugin_t *plugin = calloc(1U, sizeof(*plugin));
        char *configured_dir = NULL;
        char *configured_mode = NULL;
        char *configured_enabled = NULL;
        char *configured_effect = NULL;
        char *configured_seed = NULL;
        char *configured_background = NULL;
        char *configured_text = NULL;
        char *configured_message = NULL;
        char *configured_playback = NULL;
        char *configured_hold = NULL;
        char *configured_outro = NULL;
        char *configured_outro_ms = NULL;
        bool animation_enabled = true;
        bool native_config_valid = true;
        uint64_t configured_seed_value = 0U;

        if (plugin == NULL)
                return NULL;
        plugin->seed = ENGINE_SEED;
        plugin->background_color = BACKGROUND_COLOR;
        plugin->text_color = LOGO_COLOR;
        plugin->message_color = MESSAGE_LABEL_COLOR >> 8U;
        plugin->effect = copy_string("decrypt");
        if (key_file != NULL) {
                configured_dir = ply_key_file_get_value(key_file, "ttfx", "ImageDir");
                configured_mode = ply_key_file_get_value(key_file, "ttfx", "Mode");
                configured_enabled = ply_key_file_get_value(key_file, "ttfx", "Enabled");
                configured_effect = ply_key_file_get_value(key_file, "ttfx", "Effect");
                configured_seed = ply_key_file_get_value(key_file, "ttfx", "Seed");
                configured_background = ply_key_file_get_value(key_file, "ttfx", "BackgroundColor");
                configured_text = ply_key_file_get_value(key_file, "ttfx", "TextColor");
                configured_message = ply_key_file_get_value(key_file, "ttfx", "MessageColor");
                configured_playback = ply_key_file_get_value(key_file, "ttfx", "PlaybackMode");
                configured_hold = ply_key_file_get_value(key_file, "ttfx", "FirmwareHold");
                configured_outro = ply_key_file_get_value(key_file, "ttfx", "Outro");
                configured_outro_ms = ply_key_file_get_value(key_file, "ttfx", "OutroMs");
                native_config_valid = parse_enabled(configured_enabled, &animation_enabled);
                if (native_config_valid && strcmp(configured_mode != NULL ? configured_mode : "", "off") == 0) {
                        native_config_valid = !animation_enabled && configured_effect != NULL &&
                                              strcmp(configured_effect, "off") == 0 &&
                                              parse_seed(configured_seed, &configured_seed_value) &&
                                              configured_seed_value == 0U;
                } else if (native_config_valid && mode_is_animated(configured_mode)) {
                        native_config_valid = animation_enabled && parse_effect_name(configured_effect) &&
                                              strcmp(configured_effect, "off") != 0 &&
                                              parse_seed(configured_seed, &configured_seed_value);
                } else {
                        native_config_valid = false;
                }
                if (native_config_valid) {
                        free(plugin->effect);
                        plugin->effect = configured_effect;
                        configured_effect = NULL;
                        plugin->seed = configured_seed_value;
                }
                if (configured_background != NULL)
                        (void)parse_color(configured_background, &plugin->background_color);
                if (configured_text != NULL)
                        (void)parse_color(configured_text, &plugin->text_color);
                if (configured_message != NULL)
                        (void)parse_color(configured_message, &plugin->message_color);
                if (!native_config_valid)
                        animation_enabled = false;
        }
        free(configured_mode);
        free(configured_enabled);
        free(configured_effect);
        free(configured_seed);
        free(configured_background);
        free(configured_text);
        free(configured_message);
        plugin->firmware_hold_enabled =
                ttfx_firmware_hold_resolve(ttfx_firmware_hold_mode_parse(configured_hold),
                                           TTFX_DEVICETREE_CHOSEN_PATH);
        plugin->firmware_hidden_notch =
                plugin->firmware_hold_enabled
                        ? ttfx_devicetree_hidden_notch(TTFX_DEVICETREE_CHOSEN_PATH, TTFX_DEVICETREE_SOC_PATH)
                        : 0U;
        free(configured_hold);
        /* Installed descriptors predate these keys: absent means on. */
        plugin->outro_enabled = ttfx_outro_mode_parse(configured_outro);
        plugin->outro_ms = ttfx_outro_ms_parse(configured_outro_ms);
        free(configured_outro);
        free(configured_outro_ms);
        if (configured_dir != NULL) {
                plugin->image_dir = configured_dir;
        } else {
                plugin->image_dir = copy_string("/usr/share/plymouth/themes/spinner");
        }
        if (plugin->image_dir == NULL || plugin->effect == NULL) {
                free(configured_playback);
                free(plugin->effect);
                free(plugin->image_dir);
                free(plugin);
                return NULL;
        }
        plugin->lock_image = load_theme_image(plugin->image_dir, "lock.png");
        plugin->state = ttfx_state_initial();
        if (!ttfx_state_set_playback_mode(&plugin->state, configured_playback))
                animation_enabled = false;
        free(configured_playback);
        if (!animation_enabled)
                ttfx_state_disable_animation(&plugin->state);
        plugin->loop_state = ttfx_loop_state_initial();
        plugin->load_state = ttfx_load_state_initial();
        plugin->handoff_directory = ttfx_handoff_open();
        plugin->clock_ns = ttfx_boottime_ns;
        return plugin;
}

/* On quit (even with --retain-splash) the daemon's DRM fds close, the kernel
 * runs its lastclose path and restores the fbcon framebuffer — which never
 * drew anything, so the panel goes black until the compositor's first flip.
 * Paint the last captured animation frame into the fbcon framebuffer so the
 * console restore shows the same pixels the splash ended on. */
static void fbcon_klog(const char *msg)
{
        int k = open(TTFX_KMSG_PATH, O_WRONLY | O_CLOEXEC);
        if (k >= 0) {
                dprintf(k, "6 ttfx-fbcon: %s\n", msg);
                close(k);
        }
}

/* Opens the console framebuffer and reads its geometry. A failed query leaves
 * a zeroed geometry that no frame accepts. */
static int fbcon_open(struct fb_var_screeninfo *var, struct fb_fix_screeninfo *fix)
{
        int fd = open(TTFX_FBCON_PATH, O_RDWR | O_CLOEXEC);

        if (fd < 0)
                return -1;
        if (ioctl(fd, FBIOGET_VSCREENINFO, var) != 0 || ioctl(fd, FBIOGET_FSCREENINFO, fix) != 0) {
                memset(var, 0, sizeof(*var));
                memset(fix, 0, sizeof(*fix));
        }
        /* With several outputs the emulated framebuffer is as large as the
         * largest one, which scans out all of it, while xres/yres describe the
         * smallest: the frame is laid out for the whole buffer. */
        if (var->xres_virtual > var->xres)
                var->xres = var->xres_virtual;
        if (var->yres_virtual > var->yres)
                var->yres = var->yres_virtual;
        return fd;
}

/* A width x height frame fits a 32 bpp framebuffer of the same width. With
 * allow_taller the framebuffer may be up to an eighth taller (the native Apple
 * driver's panel with the notch rows on top): the frame is then
 * bottom-aligned under background-coloured rows. */
static bool fbcon_accepts(const struct fb_var_screeninfo *var, const struct fb_fix_screeninfo *fix,
                          uint32_t width, uint32_t height, bool allow_taller)
{
        return width != 0U && height != 0U && var->xres == width && var->bits_per_pixel == 32U &&
               var->yres >= height && (allow_taller || var->yres == height) &&
               var->yres - height <= height / 8U && var->yres_virtual >= var->yres &&
               (size_t)fix->line_length >= (size_t)width * sizeof(uint32_t);
}

/* Writes an accepted frame into the open framebuffer. Touches no plugin state:
 * the display-swap bridge thread uses it too. */
static bool write_frame_to_fbcon(int fd, const struct fb_var_screeninfo *var,
                                 const struct fb_fix_screeninfo *fix, const uint32_t *pixels,
                                 uint32_t width, uint32_t height, uint32_t background)
{
        size_t map_size = (size_t)fix->line_length * var->yres_virtual;
        void *destination = mmap(NULL, map_size, PROT_WRITE, MAP_SHARED, fd, 0);
        bool written;

        if (destination == MAP_FAILED)
                return false;
        written = ttfx_compose_bottom_aligned(destination, fix->line_length, pixels, width, height,
                                              var->yres - height,
                                              UINT32_C(0xff000000) | background);
        munmap(destination, map_size);
        return written;
}

/* The first view whose last complete frame has exactly the framebuffer's
 * visible size. With an external monitor attached the console framebuffer
 * keeps the internal panel's size, so that view is the one to restore. */
static view_t *fbcon_view_for(ply_boot_splash_plugin_t *plugin, const struct fb_var_screeninfo *var)
{
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                if (view->raw_pixels != NULL && view->raw_width != 0U &&
                    view->raw_width == var->xres && view->raw_height == var->yres)
                        return view;
        }
        return NULL;
}

static void publish_frame_to_fbcon(ply_boot_splash_plugin_t *plugin)
{
        struct fb_var_screeninfo var;
        struct fb_fix_screeninfo fix;
        view_t *view;
        bool captured = false;
        int fd;

        if (plugin->views == NULL) {
                fbcon_klog("skip: no view");
                return;
        }
        /* raw_valid is cleared by the final hide/fade sequence; raw_pixels still
         * holds the last complete frame, which is exactly what the console
         * restore needs. */
        for (view = plugin->views; view != NULL; view = view->next)
                captured = captured || (view->raw_pixels != NULL && view->raw_width != 0U &&
                                        view->raw_height != 0U);
        if (!captured) {
                fbcon_klog("skip: no captured frame pixels");
                return;
        }
        fd = fbcon_open(&var, &fix);
        if (fd < 0) {
                fbcon_klog("skip: /dev/fb0 open failed");
                return;
        }
        view = fbcon_view_for(plugin, &var);
        if (view == NULL)
                fbcon_klog("skip: no view matches fb0");
        else if (!fbcon_accepts(&var, &fix, view->raw_width, view->raw_height, false))
                fbcon_klog("skip: fb0 geometry mismatch");
        else if (write_frame_to_fbcon(fd, &var, &fix, view->raw_pixels, view->raw_width,
                                      view->raw_height, plugin->background_color))
                fbcon_klog("frame written to fbcon framebuffer");
        else
                fbcon_klog("skip: fb0 mmap failed");
        close(fd);
}

static uint64_t monotonic_ns(void)
{
        struct timespec now;

        if (clock_gettime(CLOCK_MONOTONIC, &now) != 0 || now.tv_sec < 0)
                return 0U;
        return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

/* Sleeps for `ns` in short steps; false as soon as the bridge is cancelled. */
static bool swap_bridge_sleep(swap_bridge_t *bridge, uint64_t ns)
{
        while (!atomic_load(&bridge->cancel)) {
                uint64_t step = ns < TTFX_SWAP_BRIDGE_SLEEP_STEP_NS ? ns : TTFX_SWAP_BRIDGE_SLEEP_STEP_NS;
                struct timespec pause = {.tv_sec = 0, .tv_nsec = (long)step};

                if (ns == 0U)
                        return true;
                (void)nanosleep(&pause, NULL);
                ns -= step;
        }
        return false;
}

static bool swap_bridge_write(const swap_bridge_t *bridge)
{
        struct fb_var_screeninfo var;
        struct fb_fix_screeninfo fix;
        bool written = false;
        int fd = fbcon_open(&var, &fix);

        if (fd < 0)
                return false;
        if (fbcon_accepts(&var, &fix, bridge->width, bridge->height, true))
                written = write_frame_to_fbcon(fd, &var, &fix, bridge->pixels, bridge->width,
                                               bridge->height, bridge->background);
        close(fd);
        return written;
}

static void swap_bridge_run(swap_bridge_t *bridge)
{
        /* fbcon clears the framebuffer when it binds to it, right around the
         * time the device node appears: paint the frame again a few times. */
        static const uint64_t rewrite_ns[] = {
                UINT64_C(8000000), UINT64_C(30000000), UINT64_C(100000000), UINT64_C(250000000)
        };
        uint64_t started = monotonic_ns();
        uint64_t written_at;

        while (!swap_bridge_write(bridge)) {
                if (monotonic_ns() - started >= bridge->window_ns) {
                        fbcon_klog("display swap: no usable framebuffer within the swap window");
                        return;
                }
                if (!swap_bridge_sleep(bridge, TTFX_SWAP_BRIDGE_POLL_NS))
                        return;
        }
        written_at = monotonic_ns();
        fbcon_klog("display swap: bridge frame written to the new framebuffer");
        for (size_t index = 0U; index < sizeof(rewrite_ns) / sizeof(rewrite_ns[0]); index++) {
                uint64_t elapsed = monotonic_ns() - written_at;

                if (!swap_bridge_sleep(bridge, elapsed < rewrite_ns[index] ? rewrite_ns[index] - elapsed : 0U))
                        return;
                (void)swap_bridge_write(bridge);
        }
}

/* Helper thread: touches only its own bridge, the framebuffer and the kernel
 * log, never plugin or Plymouth state. */
static void *swap_bridge_main(void *data)
{
        swap_bridge_t *bridge = data;

        swap_bridge_run(bridge);
        atomic_store(&bridge->done, true);
        return NULL;
}

/* Cancels and joins the bridge thread. Joining is short: the thread sleeps in
 * TTFX_SWAP_BRIDGE_SLEEP_STEP_NS steps and checks the flag between writes. */
static void stop_swap_bridge(ply_boot_splash_plugin_t *plugin)
{
        swap_bridge_t *bridge = plugin->swap_bridge;

        if (bridge == NULL)
                return;
        plugin->swap_bridge = NULL;
        atomic_store(&bridge->cancel, true);
        (void)pthread_join(bridge->thread, NULL);
        free(bridge->pixels);
        free(bridge);
}

/* On Apple Silicon the next driver's fbdev framebuffer appears (and fbcon
 * binds to it, showing a black console) well before Plymouth gets the new
 * display when an external monitor is attached. A helper thread waits for
 * that framebuffer and paints the removed view's last frame into it,
 * bottom-aligned exactly where the display-swap glide starts. */
static void start_swap_bridge(ply_boot_splash_plugin_t *plugin, const view_t *view)
{
        swap_bridge_t *bridge;
        sigset_t blocked;
        sigset_t previous;
        size_t bytes;
        int status;

        stop_swap_bridge(plugin);
        if (view->raw_pixels == NULL || view->raw_width == 0U || view->raw_height == 0U) {
                fbcon_klog("display swap: no captured frame to bridge");
                return;
        }
        bytes = (size_t)view->raw_width * view->raw_height * sizeof(uint32_t);
        bridge = calloc(1U, sizeof(*bridge));
        if (bridge == NULL)
                return;
        bridge->pixels = malloc(bytes);
        if (bridge->pixels == NULL) {
                free(bridge);
                return;
        }
        memcpy(bridge->pixels, view->raw_pixels, bytes);
        bridge->width = view->raw_width;
        bridge->height = view->raw_height;
        bridge->background = plugin->background_color;
        bridge->window_ns = swap_bridge_window_ns;
        atomic_init(&bridge->cancel, false);
        atomic_init(&bridge->done, false);
        /* Signals stay with Plymouth's event loop thread. */
        sigfillset(&blocked);
        (void)pthread_sigmask(SIG_SETMASK, &blocked, &previous);
        status = pthread_create(&bridge->thread, NULL, swap_bridge_main, bridge);
        (void)pthread_sigmask(SIG_SETMASK, &previous, NULL);
        if (status != 0) {
                fbcon_klog("display swap: bridge thread failed to start");
                free(bridge->pixels);
                free(bridge);
                return;
        }
        plugin->swap_bridge = bridge;
}

static void destroy_plugin(ply_boot_splash_plugin_t *plugin)
{
        if (plugin == NULL)
                return;
        stop_animation(plugin);
        detach_event_loop_watch(plugin);
        stop_swap_bridge(plugin);
        publish_frame_to_fbcon(plugin);
        free_engine(plugin);
        while (plugin->views != NULL) {
                view_t *view = plugin->views;
                plugin->views = view->next;
                view_free(view);
        }
        ttfx_handoff_close(plugin->handoff_directory);
        ttfx_state_destroy(&plugin->state);
        if (plugin->lock_image != NULL)
                ply_image_free(plugin->lock_image);
        if (plugin->lock_buffer_error != NULL)
                ply_pixel_buffer_free(plugin->lock_buffer_error);
        if (plugin->mark_scaled != NULL)
                ply_image_free(plugin->mark_scaled);
        if (plugin->mark_image != NULL)
                ply_image_free(plugin->mark_image);

        if (plugin->progress_box_image != NULL)
                ply_image_free(plugin->progress_box_image);
        if (plugin->progress_bar_image != NULL)
                ply_image_free(plugin->progress_bar_image);
        free(plugin->effect);
        free(plugin->image_dir);
        free(plugin);
}

/* A display that replaces the one removed moments ago, at the same width,
 * starts where the old one drew the splash and glides into place. */
static void start_display_swap_glide(ply_boot_splash_plugin_t *plugin, view_t *view)
{
        int offset;
        uint64_t now;

        if (!plugin->swap_pending)
                return;
        plugin->swap_pending = false;
        now = plugin->clock_ns();
        if (now < plugin->swap_ns || now - plugin->swap_ns > TTFX_DISPLAY_SWAP_WINDOW_NS)
                return;
        if (!ttfx_display_swap_offset(plugin->swap_width, plugin->swap_height, plugin->swap_grid_y,
                                      (unsigned int)ply_pixel_display_get_width(view->display),
                                      (unsigned int)ply_pixel_display_get_height(view->display),
                                      view->geometry.grid_y, &offset))
                return;
        view->glide_from = offset;
        view->glide_offset = offset;
        view->glide_tick = 0U;
        refresh_view_geometry(view);
        fbcon_klog("display swap: splash glides into place");
        schedule_timeout_if_needed(plugin);
}

static void add_pixel_display(ply_boot_splash_plugin_t *plugin,
                              ply_pixel_display_t *display)
{
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                if (view->display == display)
                        return;
        }

        view_t *view = view_new(plugin, display);
        if (view == NULL) {
                if (!plugin->visible)
                        ttfx_load_state_record_view(&plugin->load_state, false);
                return;
        }
        ply_pixel_display_set_draw_handler(display, on_draw, view);
        if (plugin->visible) {
                if (!ttfx_dynamic_view_should_keep(load_view(view))) {
                        view_free(view);
                        return;
                }
                start_display_swap_glide(plugin, view);
                view->next = plugin->views;
                plugin->views = view;
                /* The native display is up: the hold is over. */
                if (plugin->firmware_hold && !view->firmware) {
                        release_firmware_hold(plugin, "firmware hold: released (native display)");
                        return;
                }
                apply_current_prompt(view);
                apply_current_message(view);
                damage_view(view);
        } else {
                view->next = plugin->views;
                plugin->views = view;
        }
}

static void remove_pixel_display(ply_boot_splash_plugin_t *plugin,
                                 ply_pixel_display_t *display)
{
        view_t **link = &plugin->views;
        while (*link != NULL) {
                view_t *view = *link;
                if (view->display == display) {
                        /* A display removed during the hold showed only the
                         * mark: there is no frame to bridge or glide from. */
                        if (plugin->visible && !plugin->idle && !plugin->firmware_hold &&
                            !plugin->outro_active && !plugin->outro_plain &&
                            plugin->views == view && view->next == NULL) {
                                /* The panel stays lit by the next driver's console
                                 * until the new display is up: show the same frame
                                 * there as soon as its framebuffer appears. */
                                plugin->swap_pending = true;
                                plugin->swap_ns = plugin->clock_ns();
                                plugin->swap_width = (unsigned int)ply_pixel_display_get_width(display);
                                plugin->swap_height = (unsigned int)ply_pixel_display_get_height(display);
                                plugin->swap_grid_y = view->geometry.grid_y;
                                start_swap_bridge(plugin, view);
                        }
                        *link = view->next;
                        view_free(view);
                        return;
                }
                link = &view->next;
        }
}

/* Holds while every display is a firmware framebuffer and the animation is
 * available; never again once a hold was released. */
static void maybe_enter_firmware_hold(ply_boot_splash_plugin_t *plugin)
{
        if (!plugin->firmware_hold_enabled || plugin->firmware_hold_released ||
            plugin->firmware_hold || plugin->views == NULL ||
            !plugin->state.animation_enabled || plugin->static_degraded || plugin->engine == NULL)
                return;
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                if (!view->firmware)
                        return;
        }
        if (!plugin->mark_image_attempted) {
                plugin->mark_image_attempted = true;
                plugin->mark_image = load_theme_image(plugin->image_dir, FIRMWARE_MARK_IMAGE);
        }
        plugin->firmware_hold = true;
        plugin->firmware_hold_started_ns = plugin->clock_ns();
        fbcon_klog("firmware hold: showing the mark until the native display is ready");
}

/* Shown again after a hide ended the animation on the plain background: the
 * animation starts over from its first frame (a reset also ends the engine's
 * reverse playback and restarts its record). */
static void restart_after_outro(ply_boot_splash_plugin_t *plugin)
{
        plugin->outro_active = false;
        plugin->outro_plain = false;
        plugin->outro_published = false;
        plugin->outro_calls = 0U;
        plugin->outro_done = 0U;
        if (plugin->engine != NULL) {
                clear_snapshot(plugin);
                if (ttfx_engine_reset(plugin->engine) != TTFX_STATUS_OK || !update_snapshot(plugin)) {
                        free_engine(plugin);
                        ttfx_state_disable_animation(&plugin->state);
                        plugin->static_degraded = true;
                }
        }
        plugin->phase = (ttfx_phase_t){0};
        plugin->drawn_valid = false;
}

static bool show_splash_screen(ply_boot_splash_plugin_t *plugin,
                               ply_event_loop_t *loop,
                               ply_buffer_t *boot_buffer,
                               ply_boot_splash_mode_t mode)
{
        (void)boot_buffer;
        if (plugin->visible)
                return plugin->loop == loop;
        plugin->boot_progress_allowed = mode == PLY_BOOT_SPLASH_MODE_BOOT_UP;
        /* Only the boot splash hands over to a desktop; shutdown, reboot and
         * update splashes end with the machine and keep their last frame. */
        plugin->outro_mode_allowed = mode == PLY_BOOT_SPLASH_MODE_BOOT_UP;
        if (plugin->state.rendering_failed)
                return false;
        if (!plugin->idle && (plugin->outro_active || plugin->outro_plain))
                restart_after_outro(plugin);
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                ttfx_load_state_record_view(&plugin->load_state, load_view(view));
        if (!ttfx_load_state_can_show(&plugin->load_state))
                return false;
        if (plugin->state.animation_enabled && !plugin->static_degraded && !initialize_engine(plugin))
                plugin->static_degraded = true;
        plugin->loop = loop;
        plugin->visible = true;
        ply_event_loop_watch_for_exit(loop, detach_from_event_loop, plugin);
        ttfx_loop_watch_attached(&plugin->loop_state);
        maybe_enter_firmware_hold(plugin);
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                apply_current_prompt(view);
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                apply_current_message(view);
        resume_progress(plugin);
        if (plugin->state.rendering_failed) {
                plugin->visible = false;
                stop_animation(plugin);
                detach_event_loop_watch(plugin);
                return false;
        }
        damage_all_views(plugin);
        schedule_timeout_if_needed(plugin);
        return true;
}

static void update_status(ply_boot_splash_plugin_t *plugin,
                          const char *status)
{
        (void)plugin;
        (void)status;
}

static void on_boot_progress(ply_boot_splash_plugin_t *plugin,
                             double duration,
                             double fraction_done)
{
        (void)duration;
        if (!plugin->progress_visible || fraction_done != fraction_done)
                return;
        if (fraction_done < 0.0)
                fraction_done = 0.0;
        if (fraction_done > 1.0)
                fraction_done = 1.0;
        if (fraction_done <= plugin->progress_fraction)
                return;
        plugin->progress_fraction = fraction_done;
        damage_all_views(plugin);
}

static void hide_splash_screen(ply_boot_splash_plugin_t *plugin,
                               ply_event_loop_t *loop)
{
        /* `plymouth deactivate` (issued by plymouth-quit) hides the splash
         * instead of idling it; without publishing here the desktop bridge
         * can read a stale handoff phase and restart from the first frame. */
        ply_trigger_t *idle_trigger;
        bool held = end_firmware_hold(plugin, "firmware hold: released (idle)");

        /* Hiding never waits for the outro: a running one, or one that idle
         * never started, ends on the plain background right now. A hold
         * showed no animation, so there is nothing to dissolve. */
        if (plugin->outro_active || (!plugin->idle && !held && start_outro(plugin, 1U)))
                finish_outro_now(plugin);
        if (!plugin->handoff_published && !plugin->outro_published)
                publish_handoff(plugin);
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                hide_view_prompt(view);
                hide_view_message(view);
        }
        plugin->visible = false;
        plugin->progress_visible = false;
        stop_animation(plugin);
        detach_event_loop_watch(plugin);
        (void)loop;
        /* An idle still waiting for the outro or the success fast-forward
         * completes now instead of never. Plymouth runs its idle handler from
         * a later event-loop timeout, so the pull does not re-enter the
         * plugin; nothing is accessed after it. */
        idle_trigger = plugin->idle_trigger;
        if (idle_trigger != NULL) {
                plugin->idle_trigger = NULL;
                plugin->idle = true;
                plugin->success_pending = false;
                plugin->outro_active = false;
                ply_trigger_pull(idle_trigger, NULL);
        }
}

static void display_normal(ply_boot_splash_plugin_t *plugin)
{
        ttfx_state_set_normal(&plugin->state);
        if (ttfx_state_password_pending(&plugin->state))
                start_progress(plugin);
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                if (!ttfx_state_password_pending(&plugin->state))
                        hide_view_prompt(view);
                apply_current_message(view);
        }
        damage_all_views(plugin);
        schedule_timeout_if_needed(plugin);
}

static void display_password(ply_boot_splash_plugin_t *plugin,
                             const char *prompt,
                             int bullets)
{
        bool reaction_was_active = ttfx_state_reaction_active(&plugin->state);

        stop_progress(plugin);
        ttfx_raw_clear(plugin->handoff_directory);
        if (!ttfx_state_set_password(&plugin->state, prompt, bullets)) {
                ttfx_state_disable_animation(&plugin->state);
                enter_degraded_static_mode(plugin);
                return;
        }
        if (!reaction_was_active && ttfx_state_reaction_active(&plugin->state) &&
            plugin->engine != NULL && !plugin->outro_active && !plugin->outro_plain &&
            plugin->state.playback_mode == TTFX_PLAYBACK_CONTINUOUS) {
                clear_snapshot(plugin);
                if (ttfx_engine_reset(plugin->engine) != TTFX_STATUS_OK ||
                    !update_snapshot(plugin)) {
                        free_engine(plugin);
                        ttfx_state_disable_animation(&plugin->state);
                        plugin->static_degraded = true;
                } else {
                        plugin->phase = (ttfx_phase_t){0};
                }
        }
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                if (view->entry_loaded) {
                        apply_current_prompt(view);
                        sync_password_entry_reaction_position(view);
                }
        }
        damage_all_views(plugin);
        schedule_timeout_if_needed(plugin);
}

static void display_question(ply_boot_splash_plugin_t *plugin,
                             const char *prompt,
                             const char *entry_text)
{
        stop_progress(plugin);
        ttfx_raw_clear(plugin->handoff_directory);
        if (!ttfx_state_set_question(&plugin->state, prompt, entry_text)) {
                ttfx_state_disable_animation(&plugin->state);
                enter_degraded_static_mode(plugin);
                return;
        }
        for (view_t *view = plugin->views; view != NULL; view = view->next) {
                if (view->entry_loaded)
                        apply_current_prompt(view);
        }
        damage_all_views(plugin);
}

static void display_message(ply_boot_splash_plugin_t *plugin,
                            const char *message)
{
        ttfx_raw_clear(plugin->handoff_directory);
        if (!ttfx_state_set_message(&plugin->state, message)) {
                ttfx_state_disable_animation(&plugin->state);
                enter_degraded_static_mode(plugin);
                return;
        }
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                apply_current_message(view);
        damage_all_views(plugin);
}

static void hide_message(ply_boot_splash_plugin_t *plugin,
                         const char *message)
{
        if (!ttfx_state_hide_message(&plugin->state, message))
                return;
        for (view_t *view = plugin->views; view != NULL; view = view->next)
                apply_current_message(view);
        damage_all_views(plugin);
}

__attribute__((visibility("default")))
ply_boot_splash_plugin_interface_t *ply_boot_splash_plugin_get_interface(void)
{
        static ply_boot_splash_plugin_interface_t plugin_interface = {
                .create_plugin = create_plugin,
                .destroy_plugin = destroy_plugin,
                .add_pixel_display = add_pixel_display,
                .remove_pixel_display = remove_pixel_display,
                .show_splash_screen = show_splash_screen,
                .update_status = update_status,
                .on_boot_progress = on_boot_progress,
                .hide_splash_screen = hide_splash_screen,
                .display_normal = display_normal,
                .display_password = display_password,
                .display_question = display_question,
                .display_message = display_message,
                .become_idle = become_idle,
                .hide_message = hide_message
        };
        return &plugin_interface;
}
