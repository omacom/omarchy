#ifndef OMARCHY_PLYMOUTH_CONTINUITY_FRAME_H
#define OMARCHY_PLYMOUTH_CONTINUITY_FRAME_H

/* Pure, Wayland-free parts of omarchy-plymouth-continuity: option parsing,
 * validation of the Plymouth plugin's OMBFRAW1 raw frame, output selection and
 * the premultiplied fade conversion. Kept separate so it is unit tested. */

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

/* Shares the file name and dimension bounds with the plugin that writes it. */
#include "../plymouth-ttfx-plugin/state.h"

#define CONTINUITY_RAW_PATH "/run/" TTFX_RAW_NAME
#define CONTINUITY_HEADER_SIZE 48U
#define CONTINUITY_FOURCC_XR24 UINT32_C(0x34325258)

typedef struct {
        const char *file;       /* raw frame path */
        bool file_overridden;   /* --file given: root ownership not required */
        uint64_t max_age_ms;    /* reject captures older than this */
        uint64_t max_ms;        /* stay at most this long */
        uint64_t fade_ms;       /* fade-out length, 0 = none */
        const char *pid_file;
        const char *ready_file;
        bool alpha_modifier;    /* use wp_alpha_modifier_v1 when offered */
        bool help;
} continuity_options_t;

typedef enum {
        CONTINUITY_ARGS_OK = 0,
        CONTINUITY_ARGS_ERROR
} continuity_args_result_t;

/* Fills defaults, then applies argv. Accepts "--opt value" and "--opt=value".
 * On error writes a short reason into err (always NUL terminated). */
continuity_args_result_t continuity_parse_args(int argc, char **argv,
                                               continuity_options_t *options,
                                               char *err, size_t err_size);

typedef struct {
        uint32_t width;
        uint32_t height;
        uint32_t stride;
        uint64_t bytes;
        uint64_t captured_ns;
} continuity_header_t;

typedef enum {
        CONTINUITY_FRAME_OK = 0,
        CONTINUITY_FRAME_OPEN,          /* missing or unreadable */
        CONTINUITY_FRAME_SYMLINK,
        CONTINUITY_FRAME_NOT_REGULAR,
        CONTINUITY_FRAME_OWNER,         /* not root-owned or writable by others */
        CONTINUITY_FRAME_SHORT,         /* shorter than the header */
        CONTINUITY_FRAME_MAGIC,
        CONTINUITY_FRAME_FORMAT,        /* fourcc or reserved field */
        CONTINUITY_FRAME_DIMENSIONS,    /* zero or above the plugin's bounds */
        CONTINUITY_FRAME_STRIDE,
        CONTINUITY_FRAME_SIZE,          /* header byte count vs file size */
        CONTINUITY_FRAME_STALE,         /* older than max age */
        CONTINUITY_FRAME_FUTURE,        /* captured after "now": another boot */
        CONTINUITY_FRAME_READ
} continuity_frame_result_t;

const char *continuity_frame_result_name(continuity_frame_result_t result);

/* Validates a 48-byte header against the file size and the clock. */
continuity_frame_result_t continuity_parse_header(const uint8_t header[CONTINUITY_HEADER_SIZE],
                                                  uint64_t file_size, uint64_t now_ns,
                                                  uint64_t max_age_ns,
                                                  continuity_header_t *out);

/* Opens and validates the file: no symlink, regular, root-owned and not
 * group/world writable when require_root, header consistent. On success the
 * returned fd (O_CLOEXEC) is positioned after the header. */
continuity_frame_result_t continuity_open_frame(const char *path, bool require_root,
                                                uint64_t now_ns, uint64_t max_age_ns,
                                                int *fd_out, continuity_header_t *out);

/* Reads the BGRX payload, which already is wl_shm XRGB8888 memory layout. */
continuity_frame_result_t continuity_read_payload(int fd, const continuity_header_t *header,
                                                  void *dst);

typedef enum {
        CONTINUITY_COPY_SENDFILE = 0,   /* in-kernel copy, no user mapping */
        CONTINUITY_COPY_PREAD           /* fallback: pread into a mapping */
} continuity_copy_method_t;

/* Incremental copy of the payload (header->bytes from offset
 * CONTINUITY_HEADER_SIZE of src_fd) to offset 0 of dst_fd, which must already
 * be header->bytes long. Done in bounded steps so the caller can service its
 * Wayland connection between them: the copy then overlaps the compositor's
 * roundtrips instead of delaying them. Uses sendfile(2), which never faults
 * in a user mapping of the destination; falls back to mmap + pread when the
 * kernel refuses sendfile for this pair of files. Never writes to src_fd. A
 * source that turns out shorter than the header claims fails with
 * CONTINUITY_FRAME_READ. */
typedef struct {
        int src_fd;
        int dst_fd;
        uint64_t total;
        uint64_t done;
        continuity_copy_method_t method;
        uint8_t *map;           /* pread fallback only */
} continuity_copy_t;

continuity_frame_result_t continuity_copy_init(continuity_copy_t *copy, int src_fd,
                                               const continuity_header_t *header, int dst_fd);

/* Copies at most max_bytes (at least one page's worth is advisable). */
continuity_frame_result_t continuity_copy_step(continuity_copy_t *copy, size_t max_bytes);

static inline bool continuity_copy_complete(const continuity_copy_t *copy)
{
        return copy->done >= copy->total;
}

/* Releases the fallback mapping; safe to call more than once. */
void continuity_copy_release(continuity_copy_t *copy);

const char *continuity_copy_method_name(continuity_copy_method_t method);

/* Per-phase timestamps of one run, CLOCK_BOOTTIME nanoseconds, 0 = not
 * reached. Logged as one compact "timing" line in milliseconds since start. */
typedef struct {
        uint64_t start;         /* main() entered */
        uint64_t file;          /* raw file opened and header validated */
        uint64_t connect;       /* wl_display_connect returned, registry sent */
        uint64_t buffer;        /* payload copied into the shm file */
        uint64_t registry;      /* registry roundtrip done, globals bound */
        uint64_t outputs;       /* extra output roundtrip (several outputs only) */
        uint64_t surface;       /* layer surface created, initial commit sent */
        uint64_t configure;     /* first layer-surface configure received */
        uint64_t commit;        /* buffer attached and committed */
        uint64_t frame;         /* first wl_surface.frame callback */
        uint64_t presented;     /* wp_presentation timestamp of that commit */
} continuity_timing_t;

/* Formats the timing fields ("file=0.12 connect=0.40 ... presented=-") into
 * out; returns false if it did not fit. Unreached phases print "-". */
bool continuity_format_timing(const continuity_timing_t *timing, char *out, size_t out_size);

typedef struct {
        int32_t mode_width;     /* current mode, physical pixels */
        int32_t mode_height;
        int32_t transform;      /* wl_output transform, 0 = normal */
        bool has_mode;
        bool done;
} continuity_output_info_t;

/* Index of the first output whose current upright mode equals the frame size,
 * or -1. */
int continuity_pick_output(const continuity_output_info_t *outputs, size_t count,
                           uint32_t width, uint32_t height);

/* XRGB8888 -> premultiplied ARGB8888 at the given alpha (0..255). */
void continuity_premultiply(const uint32_t *src, uint32_t *dst, size_t count, uint8_t alpha);

/* Alpha for a fade step: 255 at elapsed 0, 0 at or after fade_ns. */
uint8_t continuity_fade_alpha(uint64_t elapsed_ns, uint64_t fade_ns);

#endif
