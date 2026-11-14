#define _GNU_SOURCE
#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <ply-pixel-buffer.h>
#include "state.h"

static uint64_t little(const uint8_t *p, size_t n)
{
        uint64_t value = 0;
        for (size_t i = 0; i < n; i++) value |= (uint64_t)p[i] << (8 * i);
        return value;
}

int main(void)
{
        char directory[] = "/dev/shm/ttfx-real-raw.XXXXXX";
        assert(mkdtemp(directory));
        int dir = open(directory, O_RDONLY | O_DIRECTORY);
        assert(dir >= 0);
        ply_pixel_buffer_t *buffer = ply_pixel_buffer_new(1280, 720);
        assert(buffer && ply_pixel_buffer_get_device_scale(buffer) == 1);
        ply_rectangle_t full = {.width = 1280, .height = 720};
        ply_rectangle_t mark = {.x = 311, .y = 219, .width = 107, .height = 83};
        ply_pixel_buffer_fill_with_hex_color(buffer, &full, 0x0b0d10);
        ply_pixel_buffer_fill_with_hex_color(buffer, &mark, 0x123456);
        uint32_t *pixels = ply_pixel_buffer_get_argb32_data(buffer);
        assert(pixels && (pixels[219 * 1280 + 311] & 0xffffff) == 0x123456);
        uint64_t stamp = ttfx_boottime_ns();
        assert(ttfx_raw_publish(dir, pixels, 1280, 720, stamp));
        int fd = openat(dir, TTFX_RAW_NAME, O_RDONLY | O_NOFOLLOW);
        struct stat st;
        assert(fd >= 0 && fstat(fd, &st) == 0);
        assert(S_ISREG(st.st_mode) && st.st_nlink == 1 && st.st_uid == geteuid());
        assert((st.st_mode & 0777) == 0644 && st.st_size == 48 + 1280 * 720 * 4);
        uint8_t *raw = malloc((size_t)st.st_size);
        assert(raw && read(fd, raw, (size_t)st.st_size) == st.st_size);
        close(fd);
        assert(memcmp(raw, "OMBFRAW1", 8) == 0);
        assert(little(raw + 8, 4) == 1280 && little(raw + 12, 4) == 720);
        assert(little(raw + 16, 4) == 5120 && little(raw + 20, 4) == 0x34325258);
        assert(little(raw + 24, 8) == 1280 * 720 * 4);
        assert(little(raw + 32, 8) == stamp && little(raw + 40, 8) == 0);
        for (size_t i = 0; i < 1280 * 720; i++)
                assert(little(raw + 48 + i * 4, 4) == (pixels[i] & 0xffffff));
        free(raw);
        assert(!ttfx_raw_publish(dir, pixels, TTFX_RAW_MAX_WIDTH + 1U, 720, stamp));
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);
        assert(!ttfx_raw_publish(dir, pixels, 1280, TTFX_RAW_MAX_HEIGHT + 1U, stamp));
        assert(!ttfx_raw_publish(dir, pixels, 1280, 720, UINT64_MAX));
        assert(!ttfx_raw_publish(dir, pixels, 1280, 720, 0));
        assert(symlinkat("missing-target", dir, TTFX_RAW_TEMP) == 0);
        assert(!ttfx_raw_publish(dir, pixels, 1280, 720, stamp));
        assert(unlinkat(dir, TTFX_RAW_TEMP, 0) == 0);
        assert(ttfx_raw_publish(dir, pixels, 1280, 720, stamp));
        ttfx_handoff_clear(dir);
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);
        ply_pixel_buffer_free(buffer);
        close(dir);
        assert(rmdir(directory) == 0);

        /* Firmware-hold mark: a source tagged with the canvas's device scale
         * is composited 1:1 in physical pixels at a logical offset, and its
         * alpha blends over the background. */
        ply_pixel_buffer_t *canvas = ply_pixel_buffer_new(400, 400);
        ply_pixel_buffer_t *mark_buffer = ply_pixel_buffer_new(TTFX_FIRMWARE_MARK_LOGICAL_SIZE * 2,
                                                               TTFX_FIRMWARE_MARK_LOGICAL_SIZE * 2);
        assert(canvas && mark_buffer);
        ply_pixel_buffer_set_device_scale(canvas, 2);
        ply_pixel_buffer_set_device_scale(mark_buffer, 2);
        assert(ply_pixel_buffer_get_width(canvas) == 200 && ply_pixel_buffer_get_width(mark_buffer) == 128);
        ply_rectangle_t logical = {.width = 200, .height = 200};
        ply_pixel_buffer_fill_with_hex_color(canvas, &logical, 0x0b0d10);
        uint32_t *mark_pixels = ply_pixel_buffer_get_argb32_data(mark_buffer);
        for (size_t i = 0; i < 256 * 256; i++)
                mark_pixels[i] = 0xffff0000U;
        mark_pixels[0] = 0x00000000U;
        mark_pixels[1] = 0x80800000U; /* premultiplied half-transparent red */
        ply_pixel_buffer_fill_with_buffer(canvas, mark_buffer, (200 - 128) / 2, (200 - 128) / 2);
        uint32_t *canvas_pixels = ply_pixel_buffer_get_argb32_data(canvas);
        assert((canvas_pixels[72 * 400 + 72] & 0xffffff) == 0x0b0d10);
        assert((canvas_pixels[72 * 400 + 73] & 0xff0000) >= 0x800000 &&
               (canvas_pixels[72 * 400 + 73] & 0xff0000) <= 0x870000);
        assert((canvas_pixels[72 * 400 + 74] & 0xffffff) == 0xff0000);
        assert((canvas_pixels[327 * 400 + 327] & 0xffffff) == 0xff0000);
        assert((canvas_pixels[71 * 400 + 200] & 0xffffff) == 0x0b0d10);
        assert((canvas_pixels[328 * 400 + 200] & 0xffffff) == 0x0b0d10);
        assert((canvas_pixels[200 * 400 + 71] & 0xffffff) == 0x0b0d10);
        assert((canvas_pixels[200 * 400 + 328] & 0xffffff) == 0x0b0d10);
        ply_pixel_buffer_free(mark_buffer);
        ply_pixel_buffer_free(canvas);
        puts("real Plymouth HiDPI mark composite: PASS (256x256 at scale 2, 1:1 with alpha)");
        puts("real Plymouth pixelbuffer -> OMBFRAW1 full-frame readback: PASS (1280x720, every pixel)");
}
