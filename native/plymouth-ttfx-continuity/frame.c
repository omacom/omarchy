#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include "frame.h"

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/sendfile.h>
#include <sys/stat.h>
#include <unistd.h>

#define MAX_AGE_LIMIT_MS UINT64_C(86400000)
#define MAX_MS_LIMIT UINT64_C(600000)
#define FADE_MS_LIMIT UINT64_C(10000)

static bool parse_ms(const char *text, uint64_t limit, uint64_t *out)
{
        uint64_t value = 0;
        if (text == NULL || *text == '\0')
                return false;
        for (const char *p = text; *p != '\0'; p++) {
                if (*p < '0' || *p > '9')
                        return false;
                value = value * 10U + (uint64_t)(*p - '0');
                if (value > limit)
                        return false;
        }
        *out = value;
        return true;
}

continuity_args_result_t continuity_parse_args(int argc, char **argv,
                                               continuity_options_t *options,
                                               char *err, size_t err_size)
{
        *options = (continuity_options_t){
                .file = CONTINUITY_RAW_PATH,
                .max_age_ms = 60000U,
                .max_ms = 8000U,
                .fade_ms = 200U,
                .alpha_modifier = true
        };
        const char *bad_name = "";
        size_t bad_length = 0;

        if (err_size > 0)
                err[0] = '\0';
        for (int i = 1; i < argc; i++) {
                const char *arg = argv[i];
                const char *value = NULL;
                const char *eq = NULL;
                size_t name_length;

                bad_name = arg;

                if (strcmp(arg, "--help") == 0 || strcmp(arg, "-h") == 0) {
                        options->help = true;
                        continue;
                }
                if (strcmp(arg, "--no-alpha-modifier") == 0) {
                        options->alpha_modifier = false;
                        continue;
                }
                if (strncmp(arg, "--", 2) != 0)
                        goto bad;
                eq = strchr(arg, '=');
                name_length = eq != NULL ? (size_t)(eq - arg) : strlen(arg);
                bad_length = name_length;
#define IS(name) (name_length == sizeof(name) - 1U && strncmp(arg, name, name_length) == 0)
                if (!IS("--file") && !IS("--max-age-ms") && !IS("--max-ms") && !IS("--fade-ms") &&
                    !IS("--pid-file") && !IS("--ready-file"))
                        goto bad;
                if (eq != NULL) {
                        value = eq + 1;
                } else {
                        if (i + 1 >= argc) {
                                snprintf(err, err_size, "missing value for %s", arg);
                                return CONTINUITY_ARGS_ERROR;
                        }
                        value = argv[++i];
                }
                if (IS("--file")) {
                        if (*value == '\0')
                                goto bad_value;
                        options->file = value;
                        options->file_overridden = true;
                } else if (IS("--max-age-ms")) {
                        if (!parse_ms(value, MAX_AGE_LIMIT_MS, &options->max_age_ms))
                                goto bad_value;
                } else if (IS("--max-ms")) {
                        if (!parse_ms(value, MAX_MS_LIMIT, &options->max_ms))
                                goto bad_value;
                } else if (IS("--fade-ms")) {
                        if (!parse_ms(value, FADE_MS_LIMIT, &options->fade_ms))
                                goto bad_value;
                } else if (IS("--pid-file")) {
                        if (*value == '\0')
                                goto bad_value;
                        options->pid_file = value;
                } else if (IS("--ready-file")) {
                        if (*value == '\0')
                                goto bad_value;
                        options->ready_file = value;
                } else {
                        goto bad;
                }
#undef IS
        }
        return CONTINUITY_ARGS_OK;
bad_value:
        snprintf(err, err_size, "invalid value for %.*s", (int)bad_length, bad_name);
        return CONTINUITY_ARGS_ERROR;
bad:
        snprintf(err, err_size, "unknown argument %.*s", (int)strcspn(bad_name, "="), bad_name);
        return CONTINUITY_ARGS_ERROR;
}

const char *continuity_frame_result_name(continuity_frame_result_t result)
{
        switch (result) {
        case CONTINUITY_FRAME_OK: return "ok";
        case CONTINUITY_FRAME_OPEN: return "open";
        case CONTINUITY_FRAME_SYMLINK: return "symlink";
        case CONTINUITY_FRAME_NOT_REGULAR: return "not-regular";
        case CONTINUITY_FRAME_OWNER: return "owner";
        case CONTINUITY_FRAME_SHORT: return "short";
        case CONTINUITY_FRAME_MAGIC: return "magic";
        case CONTINUITY_FRAME_FORMAT: return "format";
        case CONTINUITY_FRAME_DIMENSIONS: return "dimensions";
        case CONTINUITY_FRAME_STRIDE: return "stride";
        case CONTINUITY_FRAME_SIZE: return "size";
        case CONTINUITY_FRAME_STALE: return "stale";
        case CONTINUITY_FRAME_FUTURE: return "future";
        case CONTINUITY_FRAME_READ: return "read";
        }
        return "unknown";
}

static uint64_t little(const uint8_t *bytes, unsigned int count)
{
        uint64_t value = 0;
        for (unsigned int i = 0; i < count; i++)
                value |= (uint64_t)bytes[i] << (8U * i);
        return value;
}

continuity_frame_result_t continuity_parse_header(const uint8_t header[CONTINUITY_HEADER_SIZE],
                                                  uint64_t file_size, uint64_t now_ns,
                                                  uint64_t max_age_ns,
                                                  continuity_header_t *out)
{
        continuity_header_t h;

        if (file_size < CONTINUITY_HEADER_SIZE)
                return CONTINUITY_FRAME_SHORT;
        if (memcmp(header, "OMBFRAW1", 8) != 0)
                return CONTINUITY_FRAME_MAGIC;
        h.width = (uint32_t)little(header + 8, 4);
        h.height = (uint32_t)little(header + 12, 4);
        h.stride = (uint32_t)little(header + 16, 4);
        h.bytes = little(header + 24, 8);
        h.captured_ns = little(header + 32, 8);
        if (little(header + 20, 4) != CONTINUITY_FOURCC_XR24 || little(header + 40, 8) != 0)
                return CONTINUITY_FRAME_FORMAT;
        if (h.width == 0 || h.height == 0 || h.width > TTFX_RAW_MAX_WIDTH ||
            h.height > TTFX_RAW_MAX_HEIGHT)
                return CONTINUITY_FRAME_DIMENSIONS;
        /* The plugin writes packed rows; anything else is not its file. */
        if (h.stride != h.width * 4U)
                return CONTINUITY_FRAME_STRIDE;
        if (h.bytes != (uint64_t)h.stride * h.height ||
            file_size != CONTINUITY_HEADER_SIZE + h.bytes)
                return CONTINUITY_FRAME_SIZE;
        if (h.captured_ns == 0 || h.captured_ns > now_ns)
                return CONTINUITY_FRAME_FUTURE;
        if (now_ns - h.captured_ns > max_age_ns)
                return CONTINUITY_FRAME_STALE;
        *out = h;
        return CONTINUITY_FRAME_OK;
}

continuity_frame_result_t continuity_open_frame(const char *path, bool require_root,
                                                uint64_t now_ns, uint64_t max_age_ns,
                                                int *fd_out, continuity_header_t *out)
{
        struct stat link_info;
        struct stat info;
        uint8_t header[CONTINUITY_HEADER_SIZE];
        continuity_frame_result_t result;
        size_t done = 0;
        int fd;

        *fd_out = -1;
        if (path == NULL || lstat(path, &link_info) != 0)
                return CONTINUITY_FRAME_OPEN;
        if (S_ISLNK(link_info.st_mode))
                return CONTINUITY_FRAME_SYMLINK;
        if (!S_ISREG(link_info.st_mode))
                return CONTINUITY_FRAME_NOT_REGULAR;
        /* O_NOFOLLOW + O_NONBLOCK: a symlink or FIFO swapped in after lstat
         * fails or does not block; fstat then re-checks what was opened. */
        fd = open(path, O_RDONLY | O_NOFOLLOW | O_NONBLOCK | O_CLOEXEC | O_NOCTTY);
        if (fd < 0)
                return errno == ELOOP ? CONTINUITY_FRAME_SYMLINK : CONTINUITY_FRAME_OPEN;
        if (fstat(fd, &info) != 0) {
                result = CONTINUITY_FRAME_OPEN;
                goto fail;
        }
        if (!S_ISREG(info.st_mode) || info.st_dev != link_info.st_dev ||
            info.st_ino != link_info.st_ino) {
                result = CONTINUITY_FRAME_NOT_REGULAR;
                goto fail;
        }
        if (require_root && (info.st_uid != 0 || (info.st_mode & 0022) != 0)) {
                result = CONTINUITY_FRAME_OWNER;
                goto fail;
        }
        if (info.st_size < (off_t)CONTINUITY_HEADER_SIZE) {
                result = CONTINUITY_FRAME_SHORT;
                goto fail;
        }
        while (done < sizeof(header)) {
                ssize_t got = read(fd, header + done, sizeof(header) - done);
                if (got < 0 && errno == EINTR)
                        continue;
                if (got <= 0) {
                        result = CONTINUITY_FRAME_READ;
                        goto fail;
                }
                done += (size_t)got;
        }
        result = continuity_parse_header(header, (uint64_t)info.st_size, now_ns, max_age_ns, out);
        if (result != CONTINUITY_FRAME_OK)
                goto fail;
        *fd_out = fd;
        return CONTINUITY_FRAME_OK;
fail:
        close(fd);
        return result;
}

continuity_frame_result_t continuity_read_payload(int fd, const continuity_header_t *header,
                                                  void *dst)
{
        uint8_t *out = dst;
        uint64_t done = 0;

        while (done < header->bytes) {
                size_t chunk = header->bytes - done > (UINT64_C(1) << 24)
                                       ? (size_t)1 << 24
                                       : (size_t)(header->bytes - done);
                ssize_t got = pread(fd, out + done, chunk, (off_t)(CONTINUITY_HEADER_SIZE + done));
                if (got < 0 && errno == EINTR)
                        continue;
                if (got <= 0)
                        return CONTINUITY_FRAME_READ;
                done += (uint64_t)got;
        }
        return CONTINUITY_FRAME_OK;
}

const char *continuity_copy_method_name(continuity_copy_method_t method)
{
        return method == CONTINUITY_COPY_SENDFILE ? "sendfile" : "pread";
}

continuity_frame_result_t continuity_copy_init(continuity_copy_t *copy, int src_fd,
                                               const continuity_header_t *header, int dst_fd)
{
        *copy = (continuity_copy_t){
                .src_fd = src_fd,
                .dst_fd = dst_fd,
                .total = header->bytes,
                .method = CONTINUITY_COPY_SENDFILE
        };
        /* sendfile writes at the destination's file position. */
        if (lseek(dst_fd, 0, SEEK_SET) != 0)
                return CONTINUITY_FRAME_READ;
        return CONTINUITY_FRAME_OK;
}

static continuity_frame_result_t start_fallback(continuity_copy_t *copy)
{
        void *map = mmap(NULL, (size_t)copy->total, PROT_READ | PROT_WRITE, MAP_SHARED,
                         copy->dst_fd, 0);
        if (map == MAP_FAILED)
                return CONTINUITY_FRAME_READ;
        copy->map = map;
        copy->method = CONTINUITY_COPY_PREAD;
        return CONTINUITY_FRAME_OK;
}

continuity_frame_result_t continuity_copy_step(continuity_copy_t *copy, size_t max_bytes)
{
        size_t chunk;

        if (continuity_copy_complete(copy))
                return CONTINUITY_FRAME_OK;
        if (max_bytes == 0)
                max_bytes = 1;
        chunk = copy->total - copy->done > max_bytes ? max_bytes : (size_t)(copy->total - copy->done);
        for (;;) {
                off_t in = (off_t)(CONTINUITY_HEADER_SIZE + copy->done);
                ssize_t got;

                if (copy->method == CONTINUITY_COPY_SENDFILE) {
                        got = sendfile(copy->dst_fd, copy->src_fd, &in, chunk);
                        if (got < 0 && copy->done == 0 && (errno == EINVAL || errno == ENOSYS)) {
                                if (start_fallback(copy) != CONTINUITY_FRAME_OK)
                                        return CONTINUITY_FRAME_READ;
                                continue;
                        }
                } else {
                        got = pread(copy->src_fd, copy->map + copy->done, chunk, in);
                }
                if (got < 0 && errno == EINTR)
                        continue;
                if (got <= 0)
                        return CONTINUITY_FRAME_READ;
                copy->done += (uint64_t)got;
                return CONTINUITY_FRAME_OK;
        }
}

void continuity_copy_release(continuity_copy_t *copy)
{
        if (copy->map != NULL) {
                munmap(copy->map, (size_t)copy->total);
                copy->map = NULL;
        }
}

static size_t put_ms(char *out, size_t size, const char *sep, const char *name,
                     uint64_t start, uint64_t at)
{
        int n;
        if (at == 0) {
                n = snprintf(out, size, "%s%s=-", sep, name);
        } else {
                uint64_t us = at > start ? (at - start) / UINT64_C(1000) : 0;
                n = snprintf(out, size, "%s%s=%" PRIu64 ".%02" PRIu64, sep, name,
                             us / UINT64_C(1000), (us % UINT64_C(1000)) / UINT64_C(10));
        }
        return n < 0 ? size : (size_t)n;
}

bool continuity_format_timing(const continuity_timing_t *t, char *out, size_t out_size)
{
        const struct {
                const char *name;
                uint64_t at;
        } fields[] = {
                {"file", t->file},           {"connect", t->connect}, {"buffer", t->buffer},
                {"registry", t->registry},   {"outputs", t->outputs}, {"surface", t->surface},
                {"configure", t->configure}, {"commit", t->commit},   {"frame", t->frame},
                {"presented", t->presented}
        };
        size_t used = 0;

        if (out_size == 0)
                return false;
        out[0] = '\0';
        for (size_t i = 0; i < sizeof(fields) / sizeof(fields[0]); i++) {
                size_t n = put_ms(out + used, out_size - used, i == 0 ? "" : " ", fields[i].name,
                                  t->start, fields[i].at);
                if (n >= out_size - used)
                        return false;
                used += n;
        }
        return true;
}

int continuity_pick_output(const continuity_output_info_t *outputs, size_t count,
                           uint32_t width, uint32_t height)
{
        for (size_t i = 0; i < count; i++) {
                const continuity_output_info_t *o = &outputs[i];
                if (o->has_mode && o->transform == 0 && o->mode_width > 0 && o->mode_height > 0 &&
                    (uint32_t)o->mode_width == width && (uint32_t)o->mode_height == height)
                        return (int)i;
        }
        return -1;
}

void continuity_premultiply(const uint32_t *src, uint32_t *dst, size_t count, uint8_t alpha)
{
        const uint32_t a = alpha;
        for (size_t i = 0; i < count; i++) {
                uint32_t p = src[i];
                /* Exact round(c * a / 255) for 8-bit c and a. */
                uint32_t r = ((p >> 16) & 0xffU) * a + 128U;
                uint32_t g = ((p >> 8) & 0xffU) * a + 128U;
                uint32_t b = (p & 0xffU) * a + 128U;
                r = (r + (r >> 8)) >> 8;
                g = (g + (g >> 8)) >> 8;
                b = (b + (b >> 8)) >> 8;
                dst[i] = (a << 24) | (r << 16) | (g << 8) | b;
        }
}

uint8_t continuity_fade_alpha(uint64_t elapsed_ns, uint64_t fade_ns)
{
        if (fade_ns == 0 || elapsed_ns >= fade_ns)
                return 0;
        /* Rounded 255 * (1 - elapsed / fade). */
        uint64_t remaining = fade_ns - elapsed_ns;
        return (uint8_t)((remaining * 255U + fade_ns / 2U) / fade_ns);
}
