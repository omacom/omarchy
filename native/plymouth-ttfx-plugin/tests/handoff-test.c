#define _GNU_SOURCE
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
static int fail_write, fail_rename;
static ssize_t test_write(int fd, const void *data, size_t size)
{
        if (fail_write) return size > 0 ? (ssize_t)size - 1 : -1;
        return write(fd, data, size);
}
static int test_renameat(int from, const char *a, int to, const char *b)
{
        if (fail_rename) return -1;
        return renameat(from, a, to, b);
}
#define write test_write
#define renameat test_renameat
#include "../state.c"
#undef write
#undef renameat

static uint64_t little(const uint8_t *bytes, size_t count)
{
        uint64_t value = 0;
        for (size_t i = 0; i < count; i++)
                value |= (uint64_t)bytes[i] << (8U * i);
        return value;
}

static uint32_t pattern_pixel(size_t index)
{
        /* Alpha set on purpose: the file must carry zero X bytes. */
        return UINT32_C(0xff000000) | (uint32_t)((index * UINT64_C(2654435761)) & 0xffffffU);
}

static bool raw_publish_pattern(int dir, uint32_t width, uint32_t height)
{
        size_t count = (size_t)width * height;
        uint32_t *pixels = malloc(count * sizeof(*pixels));
        assert(pixels != NULL);
        for (size_t i = 0; i < count; i++)
                pixels[i] = pattern_pixel(i);
        bool published = ttfx_raw_publish(dir, pixels, width, height, ttfx_boottime_ns());
        free(pixels);
        return published;
}

/* Publishes a width x height pattern and reads every byte back. */
static void check_raw_frame(int dir, uint32_t width, uint32_t height)
{
        size_t count = (size_t)width * height;
        size_t size = 48U + count * 4U;
        struct stat st;
        assert(raw_publish_pattern(dir, width, height));
        int file = openat(dir, TTFX_RAW_NAME, O_RDONLY | O_NOFOLLOW);
        assert(file >= 0 && fstat(file, &st) == 0);
        assert(S_ISREG(st.st_mode) && (st.st_mode & 0777) == 0644);
        assert(st.st_size == (off_t)size);
        uint8_t *raw = malloc(size);
        assert(raw != NULL);
        size_t done = 0;
        while (done < size) {
                ssize_t got = read(file, raw + done, size - done);
                assert(got > 0);
                done += (size_t)got;
        }
        close(file);
        assert(memcmp(raw, "OMBFRAW1", 8) == 0);
        assert(little(raw + 8, 4) == width && little(raw + 12, 4) == height);
        assert(little(raw + 16, 4) == (uint64_t)width * 4U);
        assert(little(raw + 20, 4) == UINT32_C(0x34325258));
        assert(little(raw + 24, 8) == (uint64_t)count * 4U);
        assert(little(raw + 32, 8) != 0 && little(raw + 40, 8) == 0);
        for (size_t i = 0; i < count; i++)
                assert(little(raw + 48U + i * 4U, 4) == (pattern_pixel(i) & 0xffffffU));
        free(raw);
        ttfx_raw_clear(dir);
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);
}

int main(void)
{
        char directory[] = "/dev/shm/ttfx-handoff-test.XXXXXX";
        assert(mkdtemp(directory) != NULL);
        int dir = open(directory, O_DIRECTORY | O_RDONLY | O_CLOEXEC);
        assert(dir >= 0);
        ttfx_handoff_t handoff = {
                .effect = "vhstape", .seed = UINT64_MAX,
                .phase = {.step = 17, .cycle = 2},
                .width = 162, .height = 20, .fps = 240, .speed = 2,
                .background = 0x0b0d10, .foreground = 0xf4f4f5,
                .hold_final = true
        };
        assert(ttfx_handoff_publish(dir, &handoff));
        int file = openat(dir, TTFX_HANDOFF_NAME, O_RDONLY | O_NOFOLLOW);
        assert(file >= 0);
        struct stat st;
        assert(fstat(file, &st) == 0 && st.st_uid == geteuid());
        assert((st.st_mode & 0777) == 0644 && st.st_size < TTFX_HANDOFF_MAX_BYTES);
        char text[TTFX_HANDOFF_MAX_BYTES] = {0};
        assert(read(file, text, sizeof(text) - 1) == st.st_size);
        close(file);
        assert(strstr(text, "version=2\neffect=vhstape\nseed=18446744073709551615\ncycle=2\nstep=17\n") != NULL);
        assert(strstr(text, "fps=240\nspeed=2\n") != NULL);
        assert(strstr(text, "width=162\nheight=20\n") != NULL);
        assert(strstr(text, "input=embedded-logo-v2\n") != NULL);
        assert(strstr(text, "playback=hold-final\n") != NULL);
        /* A colliding temporary leaf (including symlink) cannot be followed.
         * Publication fails closed, removing stale final state, not its target. */
        assert(symlinkat("missing-target", dir, TTFX_HANDOFF_TEMP) == 0);
        assert(!ttfx_handoff_publish(dir, &handoff));
        assert(faccessat(dir, TTFX_HANDOFF_NAME, F_OK, 0) != 0);
        unlinkat(dir, TTFX_HANDOFF_TEMP, 0);
        assert(ttfx_handoff_publish(dir, &handoff));
        fail_write = 1;
        assert(!ttfx_handoff_publish(dir, &handoff));
        assert(faccessat(dir, TTFX_HANDOFF_NAME, F_OK, 0) != 0);
        assert(faccessat(dir, TTFX_HANDOFF_TEMP, F_OK, 0) != 0);
        fail_write = 0;
        fail_rename = 1;
        assert(!ttfx_handoff_publish(dir, &handoff));
        assert(faccessat(dir, TTFX_HANDOFF_TEMP, F_OK, 0) != 0);
        fail_rename = 0;
        assert(symlinkat("missing-target", dir, TTFX_HANDOFF_NAME) == 0);
        assert(ttfx_handoff_publish(dir, &handoff));
        assert(fstatat(dir, TTFX_HANDOFF_NAME, &st, AT_SYMLINK_NOFOLLOW) == 0);
        assert(S_ISREG(st.st_mode));
        handoff.phase.step = TTFX_HANDOFF_MAX_STEP + 1U;
        assert(!ttfx_handoff_publish(dir, &handoff));
        assert(faccessat(dir, TTFX_HANDOFF_NAME, F_OK, 0) != 0);
        handoff.phase.step = 0;
        handoff.effect = "bad\nstep=9";
        assert(!ttfx_handoff_publish(dir, &handoff));
        assert(!ttfx_handoff_publish(-1, &handoff));
        uint32_t pixels[] = {0xff123456U, 0xffabcdefU};
        uint64_t stamp = ttfx_boottime_ns();
        assert(ttfx_raw_publish(dir, pixels, 2, 1, stamp));
        fail_write = 1;
        assert(!ttfx_raw_publish(dir, pixels, 2, 1, stamp));
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);
        assert(faccessat(dir, TTFX_RAW_TEMP, F_OK, 0) != 0);
        fail_write = 0;
        fail_rename = 1;
        assert(!ttfx_raw_publish(dir, pixels, 2, 1, stamp));
        assert(faccessat(dir, TTFX_RAW_TEMP, F_OK, 0) != 0);
        fail_rename = 0;
        assert(symlinkat("missing-target", dir, TTFX_RAW_NAME) == 0);
        assert(ttfx_raw_publish(dir, pixels, 2, 1, stamp));
        assert(fstatat(dir, TTFX_RAW_NAME, &st, AT_SYMLINK_NOFOLLOW) == 0 && S_ISREG(st.st_mode));
        ttfx_handoff_clear(dir);
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);

        /* The raw bound matches the capture bound: a 16-inch MacBook Pro
         * panel (3456x2234, above the old 4096x2160 height) is published
         * pixel for pixel. */
        assert(TTFX_RAW_MAX_WIDTH == TTFX_CAPTURE_MAX_WIDTH);
        assert(TTFX_RAW_MAX_HEIGHT == TTFX_CAPTURE_MAX_HEIGHT);
        check_raw_frame(dir, 3456U, 2234U);
        /* Rows wider than the 16 KiB scratch are written in chunks. */
        check_raw_frame(dir, TTFX_RAW_SCRATCH_PIXELS + 7U, 3U);
        check_raw_frame(dir, TTFX_RAW_MAX_WIDTH, 2U);
        fail_write = 1;
        assert(!raw_publish_pattern(dir, TTFX_RAW_SCRATCH_PIXELS + 1U, 2U));
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);
        assert(faccessat(dir, TTFX_RAW_TEMP, F_OK, 0) != 0);
        fail_write = 0;
        /* Out-of-bound dimensions are rejected before any pixel is read. */
        assert(!ttfx_raw_publish(dir, pixels, TTFX_RAW_MAX_WIDTH + 1U, 1, stamp));
        assert(!ttfx_raw_publish(dir, pixels, 1, TTFX_RAW_MAX_HEIGHT + 1U, stamp));
        assert(faccessat(dir, TTFX_RAW_NAME, F_OK, 0) != 0);
        close(dir);
        assert(rmdir(directory) == 0);
        puts("handoff publication tests: PASS");
        return 0;
}
