/* omarchy-plymouth-continuity: keeps the last Plymouth frame on screen after
 * the compositor starts, until the desktop is ready to take over.
 *
 * Reads the plugin's /run/omarchy-plymouth-handoff.raw (OMBFRAW1), and shows
 * it 1:1 in physical pixels on the output whose current mode matches, as a
 * wlr-layer-shell OVERLAY surface that takes no input. It leaves on
 * SIGTERM/SIGINT (at once), or on SIGUSR1 or after --max-ms (with a fade of
 * --fade-ms). It must never block or break login: every failure path exits 0.
 *
 * Startup is ordered for the earliest first frame: validate the file, send
 * the registry request, copy the payload while the compositor answers, bind
 * everything in that single registry pass, and (with one output) create the
 * layer surface at once; the buffer is committed in the dispatch that acks
 * the first configure. "first-frame" is logged at the first wl_surface.frame
 * callback (the compositor has drawn a frame with the surface); the "timing"
 * line adds each phase in ms since start and, with wp_presentation, when
 * that frame was actually presented (converted to CLOCK_BOOTTIME).
 */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <poll.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/signalfd.h>
#include <sys/timerfd.h>
#include <time.h>
#include <unistd.h>

#include <wayland-client.h>

#include "alpha-modifier-v1-client-protocol.h"
#include "presentation-time-client-protocol.h"
#include "viewporter-client-protocol.h"
#include "wlr-layer-shell-unstable-v1-client-protocol.h"

#include "frame.h"

#define NAMESPACE "omarchy-plymouth-continuity"
#define MAX_OUTPUTS 16
/* Payload copied per main-loop iteration, between Wayland dispatches. */
#define COPY_STEP_BYTES ((size_t)2 << 20)
/* Exit anyway if the fade's frame callbacks stop coming (output off). */
#define FADE_GRACE_NS UINT64_C(500000000)

typedef struct client client_t;

typedef struct {
        client_t *client;
        struct wl_output *output;
        uint32_t global_name;
        int32_t scale;
        continuity_output_info_t info;
        char name[64];
} output_t;

typedef struct {
        struct wl_buffer *buffer;
        uint32_t *pixels;
        bool busy;
} fade_buffer_t;

enum phase {
        PHASE_REGISTRY,         /* waiting for the globals */
        PHASE_OUTPUTS,          /* several outputs: waiting for their modes */
        PHASE_WAIT_CONFIGURE,   /* surface created: configure, output, copy */
        PHASE_SHOWN,
        PHASE_FADING,
        PHASE_DONE
};

struct client {
        continuity_options_t options;
        uint64_t start_ns;
        uint64_t first_frame_ns;
        const char *exit_reason;
        continuity_timing_t timing;
        bool timing_logged;
        bool presentation_pending;

        struct wl_display *display;
        struct wl_registry *registry;
        struct wl_compositor *compositor;
        struct wl_shm *shm;
        struct zwlr_layer_shell_v1 *layer_shell;
        struct wp_viewporter *viewporter;
        struct wp_alpha_modifier_v1 *alpha_modifier;
        struct wp_presentation *presentation;
        clockid_t presentation_clock;
        bool presentation_clock_known;
        output_t outputs[MAX_OUTPUTS];
        size_t output_count;
        output_t *target;

        continuity_header_t header;
        int frame_fd;
        int shm_fd;             /* memfd holding a copy of the payload */
        continuity_copy_t copy;
        bool copying;

        struct wl_surface *surface;
        struct zwlr_layer_surface_v1 *layer_surface;
        struct wp_viewport *viewport;
        struct wp_alpha_modifier_surface_v1 *alpha_surface;
        struct wl_buffer *buffer;
        uint32_t *pixels;
        size_t pixels_size;
        struct wl_callback *frame_callback;
        struct wp_presentation_feedback *feedback;
        uint32_t logical_width;
        uint32_t logical_height;
        bool configured;        /* first configure acked, size below */
        uint32_t configure_width;
        uint32_t configure_height;

        fade_buffer_t fade[2];
        uint32_t *fade_map;
        size_t fade_map_size;
        bool fade_with_buffers;
        uint64_t fade_start_ns;

        enum phase phase;
        bool pid_written;
};

static uint64_t boottime_ns(void)
{
        struct timespec now;
        if (clock_gettime(CLOCK_BOOTTIME, &now) != 0)
                return 0;
        return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

static void log_line(const char *event, const char *format, ...)
{
        uint64_t now = boottime_ns();
        char extra[384] = "";
        va_list args;

        if (format != NULL) {
                va_start(args, format);
                vsnprintf(extra, sizeof(extra), format, args);
                va_end(args);
        }
        fprintf(stderr, NAMESPACE ": %s boottime=%" PRIu64 ".%06" PRIu64 "%s%s\n", event,
                now / UINT64_C(1000000000), (now % UINT64_C(1000000000)) / UINT64_C(1000),
                extra[0] != '\0' ? " " : "", extra);
}

/* Small files written next to their final path, then renamed into place. */
static bool write_small_file(const char *path, const char *text)
{
        char temp[4096];
        int fd;
        size_t length = strlen(text);
        bool ok;

        if (snprintf(temp, sizeof(temp), "%s.%ld.tmp", path, (long)getpid()) >= (int)sizeof(temp))
                return false;
        fd = open(temp, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0644);
        if (fd < 0)
                return false;
        ok = write(fd, text, length) == (ssize_t)length;
        ok = close(fd) == 0 && ok;
        if (ok && rename(temp, path) == 0)
                return true;
        (void)unlink(temp);
        return false;
}

static void write_pid_file(client_t *c)
{
        char text[32];
        if (c->options.pid_file == NULL)
                return;
        snprintf(text, sizeof(text), "%ld\n", (long)getpid());
        c->pid_written = write_small_file(c->options.pid_file, text);
}

/* Removes the pid file only if it still names this process. */
static void remove_pid_file(client_t *c)
{
        char text[32] = "";
        char expected[32];
        int fd;
        ssize_t got;

        if (!c->pid_written)
                return;
        fd = open(c->options.pid_file, O_RDONLY | O_NOFOLLOW | O_CLOEXEC);
        if (fd < 0)
                return;
        got = read(fd, text, sizeof(text) - 1U);
        close(fd);
        snprintf(expected, sizeof(expected), "%ld\n", (long)getpid());
        if (got > 0 && strcmp(text, expected) == 0)
                (void)unlink(c->options.pid_file);
}

/* ---- buffers ---- */

static int create_shm_file(size_t size)
{
        int fd = memfd_create(NAMESPACE, MFD_CLOEXEC | MFD_ALLOW_SEALING);
        if (fd < 0)
                return -1;
        if (ftruncate(fd, (off_t)size) != 0) {
                close(fd);
                return -1;
        }
        return fd;
}

static void fade_buffer_release(void *data, struct wl_buffer *buffer)
{
        (void)buffer;
        ((fade_buffer_t *)data)->busy = false;
}

static const struct wl_buffer_listener fade_buffer_listener = {
        .release = fade_buffer_release
};

/* The payload is copied into a private memfd: OMBFRAW1 BGRX rows already are
 * wl_shm XRGB8888 little-endian layout, so no conversion is needed.
 *
 * Why not hand the compositor the raw file itself (zero copy)? The client
 * can only open it O_RDONLY (root-owned, 0644), and Hyprland maps every
 * wl_shm pool PROT_READ | PROT_WRITE, MAP_SHARED (src/protocols/core/Shm.cpp),
 * which fails with EACCES on a read-only fd and is answered with the fatal
 * protocol error WL_SHM_ERROR_INVALID_FD: the connection would be lost, not
 * merely the zero-copy attempt. Hyprland also installs no SIGBUS guard for
 * pools. A memfd we own and seal against shrinking avoids both problems.
 *
 * sendfile() copies inside the kernel, so the 30 MB destination is never
 * faulted in through a user mapping (about half the cost of mmap + read). */
static bool begin_frame_copy(client_t *c)
{
        int fd = create_shm_file((size_t)c->header.bytes);

        if (fd < 0)
                return false;
        c->shm_fd = fd;
        if (continuity_copy_init(&c->copy, c->frame_fd, &c->header, fd) != CONTINUITY_FRAME_OK)
                return false;
        c->copying = true;
        return true;
}

static void try_show(client_t *c);
static void finish(client_t *c, const char *reason);

/* One bounded copy step; on completion the raw file is closed and the
 * frame is shown if the surface is already configured. */
static void copy_step(client_t *c)
{
        if (continuity_copy_step(&c->copy, COPY_STEP_BYTES) != CONTINUITY_FRAME_OK) {
                c->copying = false;
                continuity_copy_release(&c->copy);
                finish(c, "buffer");
                return;
        }
        if (!continuity_copy_complete(&c->copy))
                return;
        c->copying = false;
        continuity_copy_release(&c->copy);
        close(c->frame_fd);
        c->frame_fd = -1;
        /* The compositor maps this file for as long as the buffer lives:
         * guarantee it can never shrink under that mapping. */
        (void)fcntl(c->shm_fd, F_ADD_SEALS, F_SEAL_SHRINK | F_SEAL_GROW | F_SEAL_SEAL);
        c->timing.buffer = boottime_ns();
        try_show(c);
}

static bool create_frame_buffer(client_t *c)
{
        struct wl_shm_pool *pool = wl_shm_create_pool(c->shm, c->shm_fd, (int32_t)c->header.bytes);

        c->buffer = wl_shm_pool_create_buffer(pool, 0, (int32_t)c->header.width,
                                              (int32_t)c->header.height,
                                              (int32_t)c->header.stride, WL_SHM_FORMAT_XRGB8888);
        wl_shm_pool_destroy(pool);
        return c->buffer != NULL;
}

/* Read-only view of the frame, needed only by the buffer fade fallback. */
static bool map_frame_pixels(client_t *c)
{
        size_t size = (size_t)c->header.bytes;
        void *map;

        if (c->pixels != NULL)
                return true;
        map = mmap(NULL, size, PROT_READ, MAP_SHARED, c->shm_fd, 0);
        if (map == MAP_FAILED)
                return false;
        c->pixels = map;
        c->pixels_size = size;
        return true;
}

/* Fallback fade: two premultiplied ARGB8888 buffers, rendered alternately
 * into whichever the compositor has released. */
static bool create_fade_buffers(client_t *c)
{
        size_t one = (size_t)c->header.bytes;
        size_t size = one * 2U;
        int fd;
        struct wl_shm_pool *pool;

        if (!map_frame_pixels(c))
                return false;
        fd = create_shm_file(size);
        if (fd < 0)
                return false;
        c->fade_map = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (c->fade_map == MAP_FAILED) {
                c->fade_map = NULL;
                close(fd);
                return false;
        }
        c->fade_map_size = size;
        pool = wl_shm_create_pool(c->shm, fd, (int32_t)size);
        for (int i = 0; i < 2; i++) {
                c->fade[i].pixels = c->fade_map + (size_t)i * (one / 4U);
                c->fade[i].buffer = wl_shm_pool_create_buffer(pool, (int32_t)((size_t)i * one),
                                                              (int32_t)c->header.width,
                                                              (int32_t)c->header.height,
                                                              (int32_t)c->header.stride,
                                                              WL_SHM_FORMAT_ARGB8888);
                wl_buffer_add_listener(c->fade[i].buffer, &fade_buffer_listener, &c->fade[i]);
        }
        wl_shm_pool_destroy(pool);
        close(fd);
        return c->fade[0].buffer != NULL && c->fade[1].buffer != NULL;
}

/* ---- surface ---- */

static void frame_done(void *data, struct wl_callback *callback, uint32_t time);

static const struct wl_callback_listener frame_listener = {
        .done = frame_done
};

static void request_frame(client_t *c)
{
        if (c->frame_callback != NULL)
                wl_callback_destroy(c->frame_callback);
        c->frame_callback = wl_surface_frame(c->surface);
        wl_callback_add_listener(c->frame_callback, &frame_listener, c);
}

/* One compact line with every phase, once the first frame is known to be
 * on screen (frame callback plus presentation feedback when offered), or at
 * exit with whatever was reached. */
static void log_timing(client_t *c)
{
        char fields[320];

        if (c->timing_logged || c->timing.file == 0)
                return;
        c->timing_logged = true;
        if (!continuity_format_timing(&c->timing, fields, sizeof(fields)))
                return;
        log_line("timing", "%s copy=%s", fields,
                 c->shm_fd >= 0 ? continuity_copy_method_name(c->copy.method) : "-");
}

static void maybe_log_timing(client_t *c)
{
        if (c->timing.frame != 0 && !c->presentation_pending)
                log_timing(c);
}

static void feedback_sync_output(void *data, struct wp_presentation_feedback *feedback,
                                 struct wl_output *output)
{
        (void)data; (void)feedback; (void)output;
}

static void feedback_presented(void *data, struct wp_presentation_feedback *feedback,
                               uint32_t tv_sec_hi, uint32_t tv_sec_lo, uint32_t tv_nsec,
                               uint32_t refresh, uint32_t seq_hi, uint32_t seq_lo, uint32_t flags)
{
        client_t *c = data;
        struct timespec now_clock;
        uint64_t now_boot = boottime_ns();
        uint64_t presented = ((uint64_t)tv_sec_hi << 32 | tv_sec_lo) * UINT64_C(1000000000) + tv_nsec;
        (void)refresh; (void)seq_hi; (void)seq_lo; (void)flags;

        wp_presentation_feedback_destroy(feedback);
        c->feedback = NULL;
        c->presentation_pending = false;
        /* Translate the compositor's clock into CLOCK_BOOTTIME. */
        if (c->presentation_clock_known && clock_gettime(c->presentation_clock, &now_clock) == 0) {
                uint64_t now = (uint64_t)now_clock.tv_sec * UINT64_C(1000000000) +
                               (uint64_t)now_clock.tv_nsec;
                uint64_t age = now > presented ? now - presented : 0;
                c->timing.presented = now_boot > age ? now_boot - age : 1;
        }
        maybe_log_timing(c);
}

static void feedback_discarded(void *data, struct wp_presentation_feedback *feedback)
{
        client_t *c = data;
        wp_presentation_feedback_destroy(feedback);
        c->feedback = NULL;
        c->presentation_pending = false;
        maybe_log_timing(c);
}

static const struct wp_presentation_feedback_listener feedback_listener = {
        .sync_output = feedback_sync_output,
        .presented = feedback_presented,
        .discarded = feedback_discarded
};

static void presentation_clock_id(void *data, struct wp_presentation *presentation, uint32_t clk_id)
{
        client_t *c = data;
        (void)presentation;
        c->presentation_clock = (clockid_t)clk_id;
        c->presentation_clock_known = true;
}

static const struct wp_presentation_listener presentation_listener = {
        .clock_id = presentation_clock_id
};

static void finish(client_t *c, const char *reason)
{
        if (c->phase == PHASE_DONE)
                return;
        c->phase = PHASE_DONE;
        c->exit_reason = reason;
}

/* One fade step at the current time; finishes once alpha reaches zero. */
static void fade_step(client_t *c)
{
        uint64_t now = boottime_ns();
        uint64_t elapsed = now > c->fade_start_ns ? now - c->fade_start_ns : 0;
        uint8_t alpha = continuity_fade_alpha(elapsed, c->options.fade_ms * UINT64_C(1000000));

        if (alpha == 0) {
                finish(c, "faded");
                return;
        }
        if (c->fade_with_buffers) {
                fade_buffer_t *target = NULL;
                for (int i = 0; i < 2 && target == NULL; i++)
                        if (!c->fade[i].busy)
                                target = &c->fade[i];
                if (target != NULL) {
                        continuity_premultiply(c->pixels, target->pixels,
                                               (size_t)c->header.width * c->header.height, alpha);
                        target->busy = true;
                        wl_surface_attach(c->surface, target->buffer, 0, 0);
                        wl_surface_damage_buffer(c->surface, 0, 0, INT32_MAX, INT32_MAX);
                }
        } else {
                wp_alpha_modifier_surface_v1_set_multiplier(c->alpha_surface,
                                                            (uint32_t)((uint64_t)alpha * UINT32_MAX / 255U));
        }
        request_frame(c);
        wl_surface_commit(c->surface);
}

static void start_fade(client_t *c, const char *reason)
{
        if (c->phase == PHASE_FADING || c->phase == PHASE_DONE)
                return;
        /* Nothing was shown yet, or no fade wanted: just leave. */
        if (c->phase != PHASE_SHOWN || c->options.fade_ms == 0) {
                finish(c, reason);
                return;
        }
        c->exit_reason = reason;
        c->fade_with_buffers = c->alpha_surface == NULL;
        if (c->fade_with_buffers && !create_fade_buffers(c)) {
                finish(c, reason);
                return;
        }
        /* The surface stops being opaque while it fades. */
        wl_surface_set_opaque_region(c->surface, NULL);
        c->phase = PHASE_FADING;
        c->fade_start_ns = boottime_ns();
        log_line("fade", "reason=%s mechanism=%s fade_ms=%" PRIu64, reason,
                 c->fade_with_buffers ? "argb-premultiplied" : "alpha-modifier",
                 c->options.fade_ms);
        fade_step(c);
}

static void frame_done(void *data, struct wl_callback *callback, uint32_t time)
{
        client_t *c = data;
        (void)time;
        wl_callback_destroy(callback);
        c->frame_callback = NULL;
        if (c->first_frame_ns == 0) {
                c->first_frame_ns = boottime_ns();
                c->timing.frame = c->first_frame_ns;
                log_line("first-frame", "output=%s size=%" PRIu32 "x%" PRIu32
                         " logical=%" PRIu32 "x%" PRIu32 " latency_ms=%" PRIu64,
                         c->target->name, c->header.width, c->header.height,
                         c->logical_width, c->logical_height,
                         (c->first_frame_ns - c->start_ns) / UINT64_C(1000000));
                if (c->options.ready_file != NULL) {
                        char text[96];
                        snprintf(text, sizeof(text), "start_ns=%" PRIu64 "\nfirst_frame_ns=%" PRIu64 "\n",
                                 c->start_ns, c->first_frame_ns);
                        if (!write_small_file(c->options.ready_file, text))
                                log_line("warning", "ready-file not written");
                }
                maybe_log_timing(c);
        }
        if (c->phase == PHASE_FADING)
                fade_step(c);
}

/* Attaches the frame once the first configure, the target output's
 * description and the payload copy are all in. Called from each of those
 * events, so the buffer is committed in the same dispatch as the configure
 * ack whenever the output's events (sent by the compositor on bind) and the
 * copy finished first. */
static void try_show(client_t *c)
{
        struct wl_region *opaque;
        uint32_t width = c->configure_width;
        uint32_t height = c->configure_height;

        if (c->phase != PHASE_WAIT_CONFIGURE || !c->target->info.done)
                return;
        /* With a single output the surface was created before its mode was
         * known: check now that the frame matches it 1:1. */
        if (continuity_pick_output(&c->target->info, 1, c->header.width, c->header.height) != 0) {
                finish(c, "no-matching-output");
                return;
        }
        if (!c->configured || c->copying)
                return;
        if (c->buffer == NULL && !create_frame_buffer(c)) {
                finish(c, "buffer");
                return;
        }
        c->logical_width = width;
        c->logical_height = height;
        if (c->viewport != NULL) {
                /* Buffer pixels map onto the output's logical size, which the
                 * compositor scales back to exactly the physical mode. */
                wp_viewport_set_destination(c->viewport, (int32_t)width, (int32_t)height);
        } else {
                int32_t scale = c->target->scale > 0 ? c->target->scale : 1;
                if (c->header.width % (uint32_t)scale != 0 || c->header.height % (uint32_t)scale != 0 ||
                    c->header.width / (uint32_t)scale != width ||
                    c->header.height / (uint32_t)scale != height) {
                        /* Without a viewport only an integer scale is 1:1. */
                        finish(c, "no-viewporter-fractional-scale");
                        return;
                }
                wl_surface_set_buffer_scale(c->surface, scale);
        }
        opaque = wl_compositor_create_region(c->compositor);
        wl_region_add(opaque, 0, 0, (int32_t)width, (int32_t)height);
        wl_surface_set_opaque_region(c->surface, opaque);
        wl_region_destroy(opaque);
        wl_surface_attach(c->surface, c->buffer, 0, 0);
        wl_surface_damage_buffer(c->surface, 0, 0, INT32_MAX, INT32_MAX);
        request_frame(c);
        if (c->presentation != NULL) {
                c->feedback = wp_presentation_feedback(c->presentation, c->surface);
                wp_presentation_feedback_add_listener(c->feedback, &feedback_listener, c);
                c->presentation_pending = true;
        }
        wl_surface_commit(c->surface);
        c->timing.commit = boottime_ns();
        c->phase = PHASE_SHOWN;
}

static void layer_configure(void *data, struct zwlr_layer_surface_v1 *layer_surface,
                            uint32_t serial, uint32_t width, uint32_t height)
{
        client_t *c = data;

        zwlr_layer_surface_v1_ack_configure(layer_surface, serial);
        if (c->timing.configure == 0)
                c->timing.configure = boottime_ns();
        if (width == 0 || height == 0) {
                finish(c, "bad-configure");
                return;
        }
        if (c->phase != PHASE_WAIT_CONFIGURE) {
                /* A later resize keeps the 1:1 mapping only with a viewport. */
                if (c->viewport != NULL && (width != c->logical_width || height != c->logical_height)) {
                        c->logical_width = width;
                        c->logical_height = height;
                        wp_viewport_set_destination(c->viewport, (int32_t)width, (int32_t)height);
                        wl_surface_commit(c->surface);
                }
                return;
        }
        /* Before the frame is attached, the latest configure wins. */
        c->configured = true;
        c->configure_width = width;
        c->configure_height = height;
        try_show(c);
}

static void layer_closed(void *data, struct zwlr_layer_surface_v1 *layer_surface)
{
        (void)layer_surface;
        finish(data, "closed-by-compositor");
}

static const struct zwlr_layer_surface_v1_listener layer_listener = {
        .configure = layer_configure,
        .closed = layer_closed
};

static bool create_surface(client_t *c)
{
        const uint32_t anchors = ZWLR_LAYER_SURFACE_V1_ANCHOR_TOP | ZWLR_LAYER_SURFACE_V1_ANCHOR_BOTTOM |
                                 ZWLR_LAYER_SURFACE_V1_ANCHOR_LEFT | ZWLR_LAYER_SURFACE_V1_ANCHOR_RIGHT;
        struct wl_region *empty;

        c->surface = wl_compositor_create_surface(c->compositor);
        if (c->surface == NULL)
                return false;
        if (c->viewporter != NULL)
                c->viewport = wp_viewporter_get_viewport(c->viewporter, c->surface);
        if (c->alpha_modifier != NULL && c->options.alpha_modifier && c->options.fade_ms > 0)
                c->alpha_surface = wp_alpha_modifier_v1_get_surface(c->alpha_modifier, c->surface);
        c->layer_surface = zwlr_layer_shell_v1_get_layer_surface(c->layer_shell, c->surface,
                                                                 c->target->output,
                                                                 ZWLR_LAYER_SHELL_V1_LAYER_OVERLAY,
                                                                 NAMESPACE);
        if (c->layer_surface == NULL)
                return false;
        zwlr_layer_surface_v1_add_listener(c->layer_surface, &layer_listener, c);
        zwlr_layer_surface_v1_set_size(c->layer_surface, 0, 0);
        zwlr_layer_surface_v1_set_anchor(c->layer_surface, anchors);
        zwlr_layer_surface_v1_set_exclusive_zone(c->layer_surface, -1);
        zwlr_layer_surface_v1_set_keyboard_interactivity(c->layer_surface,
                                                         ZWLR_LAYER_SURFACE_V1_KEYBOARD_INTERACTIVITY_NONE);
        empty = wl_compositor_create_region(c->compositor);
        wl_surface_set_input_region(c->surface, empty);
        wl_region_destroy(empty);
        /* Initial commit without a buffer: the compositor answers with a
         * configure carrying the output's logical size. */
        wl_surface_commit(c->surface);
        c->timing.surface = boottime_ns();
        return true;
}

/* ---- globals ---- */

static void output_geometry(void *data, struct wl_output *wl_output, int32_t x, int32_t y,
                            int32_t physical_width, int32_t physical_height, int32_t subpixel,
                            const char *make, const char *model, int32_t transform)
{
        output_t *o = data;
        (void)wl_output; (void)x; (void)y; (void)physical_width; (void)physical_height;
        (void)subpixel; (void)make; (void)model;
        o->info.transform = transform;
}

static void output_mode(void *data, struct wl_output *wl_output, uint32_t flags,
                        int32_t width, int32_t height, int32_t refresh)
{
        output_t *o = data;
        (void)wl_output; (void)refresh;
        if (flags & WL_OUTPUT_MODE_CURRENT) {
                o->info.mode_width = width;
                o->info.mode_height = height;
                o->info.has_mode = true;
        }
}

static void output_done(void *data, struct wl_output *wl_output)
{
        output_t *o = data;
        (void)wl_output;
        o->info.done = true;
        if (o->client->target == o)
                try_show(o->client);
}

static void output_scale(void *data, struct wl_output *wl_output, int32_t factor)
{
        (void)wl_output;
        ((output_t *)data)->scale = factor;
}

static void output_name(void *data, struct wl_output *wl_output, const char *name)
{
        output_t *o = data;
        (void)wl_output;
        snprintf(o->name, sizeof(o->name), "%s", name != NULL ? name : "?");
}

static void output_description(void *data, struct wl_output *wl_output, const char *description)
{
        (void)data; (void)wl_output; (void)description;
}

static const struct wl_output_listener output_listener = {
        .geometry = output_geometry,
        .mode = output_mode,
        .done = output_done,
        .scale = output_scale,
        .name = output_name,
        .description = output_description
};

static uint32_t min_u32(uint32_t a, uint32_t b)
{
        return a < b ? a : b;
}

static void registry_global(void *data, struct wl_registry *registry, uint32_t name,
                            const char *interface, uint32_t version)
{
        client_t *c = data;

        if (strcmp(interface, wl_compositor_interface.name) == 0 && version >= 4) {
                c->compositor = wl_registry_bind(registry, name, &wl_compositor_interface, 4);
        } else if (strcmp(interface, wl_shm_interface.name) == 0) {
                c->shm = wl_registry_bind(registry, name, &wl_shm_interface, 1);
        } else if (strcmp(interface, wl_output_interface.name) == 0 && version >= 2 &&
                   c->output_count < MAX_OUTPUTS) {
                output_t *o = &c->outputs[c->output_count++];
                *o = (output_t){.client = c, .global_name = name, .scale = 1};
                snprintf(o->name, sizeof(o->name), "wl_output-%" PRIu32, name);
                o->output = wl_registry_bind(registry, name, &wl_output_interface,
                                             min_u32(version, 4));
                wl_output_add_listener(o->output, &output_listener, o);
        } else if (strcmp(interface, zwlr_layer_shell_v1_interface.name) == 0) {
                c->layer_shell = wl_registry_bind(registry, name, &zwlr_layer_shell_v1_interface,
                                                  min_u32(version, 4));
        } else if (strcmp(interface, wp_viewporter_interface.name) == 0) {
                c->viewporter = wl_registry_bind(registry, name, &wp_viewporter_interface, 1);
        } else if (strcmp(interface, wp_alpha_modifier_v1_interface.name) == 0) {
                c->alpha_modifier = wl_registry_bind(registry, name, &wp_alpha_modifier_v1_interface, 1);
        } else if (strcmp(interface, wp_presentation_interface.name) == 0) {
                /* Optional: only measures when the first frame hit the screen. */
                c->presentation = wl_registry_bind(registry, name, &wp_presentation_interface, 1);
                wp_presentation_add_listener(c->presentation, &presentation_listener, c);
        }
}

static void registry_global_remove(void *data, struct wl_registry *registry, uint32_t name)
{
        client_t *c = data;
        (void)registry;
        if (c->target != NULL && c->target->global_name == name)
                finish(c, "output-removed");
}

static const struct wl_registry_listener registry_listener = {
        .global = registry_global,
        .global_remove = registry_global_remove
};

/* ---- startup ---- */

static void sync_done(void *data, struct wl_callback *callback, uint32_t serial);

static const struct wl_callback_listener sync_listener = {
        .done = sync_done
};

static void request_sync(client_t *c)
{
        struct wl_callback *callback = wl_display_sync(c->display);
        wl_callback_add_listener(callback, &sync_listener, c);
}

static void start_surface(client_t *c)
{
        if (!create_surface(c)) {
                finish(c, "surface");
                return;
        }
        c->phase = PHASE_WAIT_CONFIGURE;
}

/* The registry pass is done (all globals bound in it), or with several
 * outputs, their descriptions are in too. */
static void sync_done(void *data, struct wl_callback *callback, uint32_t serial)
{
        client_t *c = data;
        (void)serial;
        wl_callback_destroy(callback);

        if (c->phase == PHASE_REGISTRY) {
                c->timing.registry = boottime_ns();
                if (c->compositor == NULL || c->shm == NULL || c->layer_shell == NULL) {
                        finish(c, "missing-globals");
                        return;
                }
                if (c->output_count == 1) {
                        /* The usual laptop case: create the surface at once on
                         * the only output. Its mode/scale events, sent on bind,
                         * arrive before the configure; try_show() checks them. */
                        c->target = &c->outputs[0];
                        start_surface(c);
                        return;
                }
                /* Several (or no) outputs: their modes decide which to cover. */
                c->phase = PHASE_OUTPUTS;
                request_sync(c);
        } else if (c->phase == PHASE_OUTPUTS) {
                continuity_output_info_t infos[MAX_OUTPUTS];
                int picked;

                c->timing.outputs = boottime_ns();
                for (size_t i = 0; i < c->output_count; i++)
                        infos[i] = c->outputs[i].info;
                picked = continuity_pick_output(infos, c->output_count, c->header.width,
                                                c->header.height);
                if (picked < 0) {
                        finish(c, "no-matching-output");
                        return;
                }
                c->target = &c->outputs[picked];
                start_surface(c);
        }
}

/* ---- main loop ---- */

static int make_signal_fd(void)
{
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGTERM);
        sigaddset(&set, SIGINT);
        sigaddset(&set, SIGUSR1);
        sigaddset(&set, SIGHUP);
        sigaddset(&set, SIGPIPE);
        if (sigprocmask(SIG_BLOCK, &set, NULL) != 0)
                return -1;
        sigdelset(&set, SIGPIPE);
        return signalfd(-1, &set, SFD_CLOEXEC | SFD_NONBLOCK);
}

static int make_deadline_timer(uint64_t ms)
{
        struct itimerspec spec = {0};
        int fd = timerfd_create(CLOCK_BOOTTIME, TFD_CLOEXEC | TFD_NONBLOCK);
        if (fd < 0)
                return -1;
        spec.it_value.tv_sec = (time_t)(ms / 1000U);
        spec.it_value.tv_nsec = (long)((ms % 1000U) * 1000000U);
        if (spec.it_value.tv_sec == 0 && spec.it_value.tv_nsec == 0)
                spec.it_value.tv_nsec = 1;
        if (timerfd_settime(fd, 0, &spec, NULL) != 0) {
                close(fd);
                return -1;
        }
        return fd;
}

static void handle_signals(client_t *c, int signal_fd)
{
        struct signalfd_siginfo info;
        while (read(signal_fd, &info, sizeof(info)) == (ssize_t)sizeof(info)) {
                switch (info.ssi_signo) {
                case SIGUSR1:
                        start_fade(c, "sigusr1");
                        break;
                case SIGTERM:
                        finish(c, "sigterm");
                        break;
                case SIGINT:
                        finish(c, "sigint");
                        break;
                case SIGHUP:
                        finish(c, "sighup");
                        break;
                default:
                        break;
                }
        }
}

static void run_loop(client_t *c, int signal_fd, int deadline_fd)
{
        while (c->phase != PHASE_DONE) {
                struct pollfd fds[3] = {
                        {.fd = wl_display_get_fd(c->display), .events = POLLIN},
                        {.fd = signal_fd, .events = POLLIN},
                        {.fd = deadline_fd, .events = POLLIN}
                };
                int timeout_ms = -1;
                int ready;

                while (wl_display_prepare_read(c->display) != 0) {
                        if (wl_display_dispatch_pending(c->display) < 0) {
                                finish(c, "display-error");
                                return;
                        }
                }
                if (c->phase == PHASE_DONE) {
                        wl_display_cancel_read(c->display);
                        return;
                }
                if (wl_display_flush(c->display) < 0 && errno == EAGAIN)
                        fds[0].events |= POLLOUT;
                if (c->copying) {
                        /* Only peek at the socket: the copy continues below. */
                        timeout_ms = 0;
                } else if (c->phase == PHASE_FADING) {
                        uint64_t limit = c->fade_start_ns + c->options.fade_ms * UINT64_C(1000000) +
                                         FADE_GRACE_NS;
                        uint64_t now = boottime_ns();
                        timeout_ms = now >= limit ? 0 : (int)((limit - now) / UINT64_C(1000000)) + 1;
                }
                ready = poll(fds, 3, timeout_ms);
                if (ready < 0 && errno != EINTR) {
                        wl_display_cancel_read(c->display);
                        finish(c, "poll-error");
                        return;
                }
                if (ready > 0 && (fds[0].revents & POLLIN)) {
                        if (wl_display_read_events(c->display) < 0) {
                                finish(c, "display-error");
                                return;
                        }
                } else {
                        wl_display_cancel_read(c->display);
                }
                if (ready > 0 && (fds[0].revents & (POLLERR | POLLHUP)) && !(fds[0].revents & POLLIN)) {
                        finish(c, "display-hangup");
                        return;
                }
                if (wl_display_dispatch_pending(c->display) < 0) {
                        finish(c, "display-error");
                        return;
                }
                if (ready > 0 && (fds[1].revents & POLLIN))
                        handle_signals(c, signal_fd);
                if (ready > 0 && (fds[2].revents & POLLIN)) {
                        uint64_t expirations;
                        (void)!read(deadline_fd, &expirations, sizeof(expirations));
                        start_fade(c, "max-ms");
                }
                if (ready == 0 && c->phase == PHASE_FADING && !c->copying)
                        finish(c, "fade-timeout");
                if (c->copying && c->phase != PHASE_DONE)
                        copy_step(c);
        }
}

static void usage(void)
{
        fputs("Usage: omarchy-plymouth-continuity [--file PATH] [--max-age-ms N] [--max-ms N]\n"
              "                                   [--fade-ms N] [--pid-file PATH] [--ready-file PATH]\n"
              "                                   [--no-alpha-modifier]\n"
              "Shows the last Plymouth frame (" CONTINUITY_RAW_PATH ") as a Wayland overlay\n"
              "until SIGTERM/SIGINT (immediate), SIGUSR1 or --max-ms (with a fade).\n"
              "Always exits 0.\n", stderr);
}

int main(int argc, char **argv)
{
        static client_t client = {.frame_fd = -1, .shm_fd = -1};
        client_t *c = &client;
        char err[128];
        int signal_fd = -1;
        int deadline_fd = -1;
        continuity_frame_result_t frame;

        c->start_ns = boottime_ns();
        c->timing.start = c->start_ns;
        /* Block the signals first so an early SIGUSR1/SIGTERM never kills us
         * with the default action before the loop reads it. */
        signal_fd = make_signal_fd();
        if (continuity_parse_args(argc, argv, &c->options, err, sizeof(err)) != CONTINUITY_ARGS_OK) {
                log_line("start", "pid=%ld", (long)getpid());
                log_line("exit", "reason=usage detail=\"%s\"", err);
                usage();
                return 0;
        }
        if (c->options.help) {
                usage();
                return 0;
        }
        log_line("start", "pid=%ld file=%s max_ms=%" PRIu64 " fade_ms=%" PRIu64, (long)getpid(),
                 c->options.file, c->options.max_ms, c->options.fade_ms);
        write_pid_file(c);
        if (signal_fd < 0) {
                c->exit_reason = "signalfd";
                goto out;
        }
        deadline_fd = make_deadline_timer(c->options.max_ms);
        if (deadline_fd < 0) {
                c->exit_reason = "timerfd";
                goto out;
        }

        frame = continuity_open_frame(c->options.file, !c->options.file_overridden, c->start_ns,
                                      c->options.max_age_ms * UINT64_C(1000000), &c->frame_fd,
                                      &c->header);
        if (frame != CONTINUITY_FRAME_OK) {
                c->exit_reason = continuity_frame_result_name(frame);
                goto out;
        }
        c->timing.file = boottime_ns();

        c->display = wl_display_connect(NULL);
        if (c->display == NULL) {
                c->exit_reason = "no-display";
                goto out;
        }
        c->registry = wl_display_get_registry(c->display);
        wl_registry_add_listener(c->registry, &registry_listener, c);
        request_sync(c);
        (void)wl_display_flush(c->display);
        c->timing.connect = boottime_ns();
        /* From here everything is driven by the loop: the payload is copied
         * in steps while the compositor answers the registry and configure
         * requests, so the copy overlaps those roundtrips. */
        if (!begin_frame_copy(c)) {
                c->exit_reason = "buffer";
                goto out;
        }
        c->phase = PHASE_REGISTRY;
        run_loop(c, signal_fd, deadline_fd);

out:
        log_timing(c);
        if (c->display != NULL) {
                /* Unmap promptly: the compositor drops the surface with it. */
                if (c->layer_surface != NULL)
                        zwlr_layer_surface_v1_destroy(c->layer_surface);
                if (c->surface != NULL)
                        wl_surface_destroy(c->surface);
                (void)wl_display_flush(c->display);
                wl_display_disconnect(c->display);
        }
        if (c->pixels != NULL)
                munmap(c->pixels, c->pixels_size);
        if (c->fade_map != NULL)
                munmap(c->fade_map, c->fade_map_size);
        continuity_copy_release(&c->copy);
        if (c->frame_fd >= 0)
                close(c->frame_fd);
        if (c->shm_fd >= 0)
                close(c->shm_fd);
        if (deadline_fd >= 0)
                close(deadline_fd);
        if (signal_fd >= 0)
                close(signal_fd);
        remove_pid_file(c);
        log_line("exit", "reason=%s shown_ms=%" PRIu64,
                 c->exit_reason != NULL ? c->exit_reason : "unknown",
                 c->first_frame_ns != 0 ? (boottime_ns() - c->first_frame_ns) / UINT64_C(1000000) : 0);
        return 0;
}
