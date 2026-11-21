#define _GNU_SOURCE
#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

#include "frame.h"

#define NS_PER_MS UINT64_C(1000000)

static char directory[4096];

static uint64_t boottime_ns(void)
{
        struct timespec now;
        assert(clock_gettime(CLOCK_BOOTTIME, &now) == 0);
        return (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
}

static void put_little(uint8_t *out, uint64_t value, unsigned int bytes)
{
        for (unsigned int i = 0; i < bytes; i++)
                out[i] = (uint8_t)(value >> (8U * i));
}

static void make_header(uint8_t header[48], uint32_t width, uint32_t height, uint64_t captured)
{
        memset(header, 0, 48);
        memcpy(header, "OMBFRAW1", 8);
        put_little(header + 8, width, 4);
        put_little(header + 12, height, 4);
        put_little(header + 16, (uint64_t)width * 4U, 4);
        put_little(header + 20, CONTINUITY_FOURCC_XR24, 4);
        put_little(header + 24, (uint64_t)width * height * 4U, 8);
        put_little(header + 32, captured, 8);
}

static char *fixture(const char *name)
{
        static char path[4200];
        snprintf(path, sizeof(path), "%s/%s", directory, name);
        return path;
}

/* Writes header + payload (payload_pixels pixels of a pattern). */
static void write_frame(const char *name, const uint8_t header[48], size_t payload_pixels)
{
        int fd = open(fixture(name), O_WRONLY | O_CREAT | O_TRUNC | O_NOFOLLOW | O_CLOEXEC, 0644);
        assert(fd >= 0);
        assert(write(fd, header, 48) == 48);
        for (size_t i = 0; i < payload_pixels; i++) {
                uint8_t px[4];
                put_little(px, (uint32_t)(i * 2654435761U) & 0xffffffU, 4);
                assert(write(fd, px, 4) == 4);
        }
        assert(fchmod(fd, 0644) == 0);
        assert(close(fd) == 0);
}

static void test_header(void)
{
        uint8_t h[48];
        continuity_header_t out;
        const uint64_t now = UINT64_C(500000000000);
        const uint64_t age = 60000U * NS_PER_MS;
        const uint64_t size = 48U + 4U * 3U * 4U;

        make_header(h, 4, 3, now - 1U);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_OK);
        assert(out.width == 4 && out.height == 3 && out.stride == 16 && out.bytes == 48);
        assert(out.captured_ns == now - 1U);
        assert(continuity_parse_header(h, 47, now, age, &out) == CONTINUITY_FRAME_SHORT);
        assert(continuity_parse_header(h, size - 1U, now, age, &out) == CONTINUITY_FRAME_SIZE);
        assert(continuity_parse_header(h, size + 1U, now, age, &out) == CONTINUITY_FRAME_SIZE);

        make_header(h, 4, 3, now);
        h[7] = '2';
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_MAGIC);
        make_header(h, 4, 3, now);
        put_little(h + 20, UINT32_C(0x34325241), 4); /* AR24 */
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_FORMAT);
        make_header(h, 4, 3, now);
        h[40] = 1;
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_FORMAT);
        make_header(h, 4, 3, now);
        put_little(h + 16, 20, 4);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_STRIDE);
        make_header(h, 4, 3, now);
        put_little(h + 24, 44, 8);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_SIZE);

        make_header(h, 0, 3, now);
        assert(continuity_parse_header(h, 48, now, age, &out) == CONTINUITY_FRAME_DIMENSIONS);
        make_header(h, 4, 0, now);
        assert(continuity_parse_header(h, 48, now, age, &out) == CONTINUITY_FRAME_DIMENSIONS);
        make_header(h, TTFX_RAW_MAX_WIDTH + 1U, 1, now);
        assert(continuity_parse_header(h, 48U + (TTFX_RAW_MAX_WIDTH + 1U) * 4U, now, age, &out) ==
               CONTINUITY_FRAME_DIMENSIONS);
        make_header(h, 1, TTFX_RAW_MAX_HEIGHT + 1U, now);
        assert(continuity_parse_header(h, 48U + (TTFX_RAW_MAX_HEIGHT + 1U) * 4U, now, age, &out) ==
               CONTINUITY_FRAME_DIMENSIONS);
        /* Largest accepted frame and the 16-inch MacBook Pro panel. */
        make_header(h, TTFX_RAW_MAX_WIDTH, TTFX_RAW_MAX_HEIGHT, now);
        assert(continuity_parse_header(h, 48U + (uint64_t)TTFX_RAW_MAX_WIDTH * TTFX_RAW_MAX_HEIGHT * 4U,
                                       now, age, &out) == CONTINUITY_FRAME_OK);
        make_header(h, 3456, 2234, now);
        assert(continuity_parse_header(h, 48U + 3456U * 2234U * 4U, now, age, &out) ==
               CONTINUITY_FRAME_OK);
        /* Width overflow in stride cannot sneak through: 2^30 is out of bounds. */
        make_header(h, UINT32_C(1) << 30, 1, now);
        assert(continuity_parse_header(h, 48, now, age, &out) == CONTINUITY_FRAME_DIMENSIONS);

        /* Age: exactly max age passes, one ns more is stale; future and zero
         * timestamps (another boot, a forged file) are rejected. */
        make_header(h, 4, 3, now - age);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_OK);
        make_header(h, 4, 3, now - age - 1U);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_STALE);
        make_header(h, 4, 3, now + 1U);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_FUTURE);
        make_header(h, 4, 3, 0);
        assert(continuity_parse_header(h, size, now, age, &out) == CONTINUITY_FRAME_FUTURE);
}

static void test_files(void)
{
        uint8_t h[48];
        continuity_header_t out;
        int fd = -1;
        uint64_t now = boottime_ns();
        const uint64_t age = 60000U * NS_PER_MS;

        make_header(h, 5, 2, now);
        write_frame("good.raw", h, 10);
        assert(continuity_open_frame(fixture("good.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_OK);
        assert(fd >= 0 && out.width == 5 && out.height == 2);
        uint32_t pixels[10];
        assert(continuity_read_payload(fd, &out, pixels) == CONTINUITY_FRAME_OK);
        for (size_t i = 0; i < 10; i++)
                assert(pixels[i] == ((uint32_t)(i * 2654435761U) & 0xffffffU));
        close(fd);

        /* Root ownership is required for the default path only. */
        continuity_frame_result_t as_root =
                continuity_open_frame(fixture("good.raw"), true, now, age, &fd, &out);
        if (geteuid() == 0) {
                assert(as_root == CONTINUITY_FRAME_OK);
                close(fd);
                assert(chmod(fixture("good.raw"), 0664) == 0);
                assert(continuity_open_frame(fixture("good.raw"), true, now, age, &fd, &out) ==
                       CONTINUITY_FRAME_OWNER && fd == -1);
                assert(chmod(fixture("good.raw"), 0644) == 0);
                if (chown(fixture("good.raw"), 65534, 65534) == 0) {
                        assert(continuity_open_frame(fixture("good.raw"), true, now, age, &fd, &out) ==
                               CONTINUITY_FRAME_OWNER);
                        assert(continuity_open_frame(fixture("good.raw"), false, now, age, &fd, &out) ==
                               CONTINUITY_FRAME_OK);
                        close(fd);
                }
        } else {
                assert(as_root == CONTINUITY_FRAME_OWNER && fd == -1);
        }

        /* A symlink is refused even when it points at a valid frame; the
         * fixture link targets a file inside this test's own directory. */
        assert(symlink("good.raw", fixture("link.raw")) == 0);
        assert(continuity_open_frame(fixture("link.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_SYMLINK && fd == -1);
        assert(mkdir(fixture("dir.raw"), 0755) == 0);
        assert(continuity_open_frame(fixture("dir.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_NOT_REGULAR);
        assert(mkfifo(fixture("fifo.raw"), 0644) == 0);
        assert(continuity_open_frame(fixture("fifo.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_NOT_REGULAR);
        assert(continuity_open_frame(fixture("missing.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_OPEN);

        /* Truncated payload, extra bytes, short header. */
        write_frame("short-payload.raw", h, 9);
        assert(continuity_open_frame(fixture("short-payload.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_SIZE);
        write_frame("long-payload.raw", h, 11);
        assert(continuity_open_frame(fixture("long-payload.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_SIZE);
        int tiny = open(fixture("tiny.raw"), O_WRONLY | O_CREAT | O_TRUNC, 0644);
        assert(tiny >= 0 && write(tiny, "OMBFRAW1", 8) == 8 && close(tiny) == 0);
        assert(continuity_open_frame(fixture("tiny.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_SHORT);

        /* A stale capture from earlier in this boot is refused. */
        make_header(h, 5, 2, now - age - 1U);
        write_frame("stale.raw", h, 10);
        assert(continuity_open_frame(fixture("stale.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_STALE);
        make_header(h, 5, 2, now + NS_PER_MS);
        write_frame("future.raw", h, 10);
        assert(continuity_open_frame(fixture("future.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_FUTURE);

        static const char *const files[] = {
                "good.raw", "link.raw", "fifo.raw", "short-payload.raw", "long-payload.raw",
                "tiny.raw", "stale.raw", "future.raw"
        };
        for (size_t i = 0; i < sizeof(files) / sizeof(files[0]); i++)
                assert(unlink(fixture(files[i])) == 0);
        assert(rmdir(fixture("dir.raw")) == 0);
}

/* Copies a validated frame through the stepped copy and checks the bytes. */
static void check_copy(int src, const continuity_header_t *h, int dst, size_t step,
                       continuity_copy_method_t expect_method)
{
        continuity_copy_t copy;
        int steps = 0;
        assert(ftruncate(dst, (off_t)h->bytes) == 0);
        assert(continuity_copy_init(&copy, src, h, dst) == CONTINUITY_FRAME_OK);
        while (!continuity_copy_complete(&copy)) {
                assert(continuity_copy_step(&copy, step) == CONTINUITY_FRAME_OK);
                steps++;
        }
        assert(copy.method == expect_method);
        assert(steps >= (int)((h->bytes + step - 1U) / step));
        /* Further steps are no-ops. */
        assert(continuity_copy_step(&copy, step) == CONTINUITY_FRAME_OK && copy.done == h->bytes);
        continuity_copy_release(&copy);
        continuity_copy_release(&copy);
        uint32_t *got = mmap(NULL, (size_t)h->bytes, PROT_READ, MAP_SHARED, dst, 0);
        assert(got != MAP_FAILED);
        for (size_t i = 0; i < (size_t)h->bytes / 4U; i++)
                assert(got[i] == ((uint32_t)(i * 2654435761U) & 0xffffffU));
        assert(munmap(got, (size_t)h->bytes) == 0);
}

static void test_copy(void)
{
        uint8_t h[48];
        continuity_header_t out;
        int fd = -1;
        uint64_t now = boottime_ns();
        const uint64_t age = 60000U * NS_PER_MS;

        /* 300x200: several steps of an odd size, not page aligned. */
        make_header(h, 300, 200, now);
        write_frame("copy.raw", h, 300U * 200U);
        assert(continuity_open_frame(fixture("copy.raw"), false, now, age, &fd, &out) ==
               CONTINUITY_FRAME_OK);

        int mem = memfd_create("continuity-test", MFD_CLOEXEC);
        assert(mem >= 0);
        check_copy(fd, &out, mem, 65536U + 12U, CONTINUITY_COPY_SENDFILE);
        assert(close(mem) == 0);

        /* sendfile refuses an O_APPEND destination with EINVAL: the copy
         * falls back to mmap + pread and still produces the same bytes. */
        int append = open(fixture("copy.dst"), O_RDWR | O_CREAT | O_TRUNC | O_APPEND | O_CLOEXEC, 0600);
        assert(append >= 0);
        check_copy(fd, &out, append, 100000U, CONTINUITY_COPY_PREAD);
        assert(close(append) == 0);
        assert(strcmp(continuity_copy_method_name(CONTINUITY_COPY_SENDFILE), "sendfile") == 0);
        assert(strcmp(continuity_copy_method_name(CONTINUITY_COPY_PREAD), "pread") == 0);

        /* A source that shrank after validation fails instead of copying
         * stale or out-of-range bytes. The fixture is truncated through a
         * separate descriptor; the client itself never writes the file. */
        int writer = open(fixture("copy.raw"), O_WRONLY | O_CLOEXEC);
        assert(writer >= 0 && ftruncate(writer, 48 + 1000) == 0 && close(writer) == 0);
        mem = memfd_create("continuity-test", MFD_CLOEXEC);
        assert(mem >= 0 && ftruncate(mem, (off_t)out.bytes) == 0);
        continuity_copy_t copy;
        continuity_frame_result_t result = CONTINUITY_FRAME_OK;
        assert(continuity_copy_init(&copy, fd, &out, mem) == CONTINUITY_FRAME_OK);
        while (result == CONTINUITY_FRAME_OK && !continuity_copy_complete(&copy))
                result = continuity_copy_step(&copy, 4096U);
        assert(result == CONTINUITY_FRAME_READ && copy.done == 1000U);
        continuity_copy_release(&copy);
        assert(close(mem) == 0);
        assert(close(fd) == 0);

        assert(unlink(fixture("copy.raw")) == 0);
        assert(unlink(fixture("copy.dst")) == 0);
}

static void test_copy_readonly_source(void)
{
        uint8_t h[48];
        continuity_header_t out;
        int fd = -1;
        uint64_t now = boottime_ns();
        struct stat before, after;

        make_header(h, 64, 4, now);
        write_frame("ro.raw", h, 64U * 4U);
        assert(stat(fixture("ro.raw"), &before) == 0);
        assert(continuity_open_frame(fixture("ro.raw"), false, now, 60000U * NS_PER_MS, &fd, &out) ==
               CONTINUITY_FRAME_OK);
        /* The validated descriptor is read-only. */
        assert((fcntl(fd, F_GETFL) & O_ACCMODE) == O_RDONLY);
        int mem = memfd_create("continuity-test", MFD_CLOEXEC);
        assert(mem >= 0);
        check_copy(fd, &out, mem, 1U << 20, CONTINUITY_COPY_SENDFILE);
        assert(close(mem) == 0 && close(fd) == 0);
        assert(stat(fixture("ro.raw"), &after) == 0);
        assert(after.st_size == before.st_size && after.st_mtim.tv_sec == before.st_mtim.tv_sec &&
               after.st_mtim.tv_nsec == before.st_mtim.tv_nsec);
        assert(unlink(fixture("ro.raw")) == 0);
}

static void test_timing(void)
{
        char line[512];
        continuity_timing_t t = {.start = UINT64_C(1000000000)};
        assert(continuity_format_timing(&t, line, sizeof(line)));
        assert(strcmp(line, "file=- connect=- buffer=- registry=- outputs=- surface=- configure=- "
                            "commit=- frame=- presented=-") == 0);
        t.file = t.start + UINT64_C(40000);          /* 0.04 ms */
        t.connect = t.start + UINT64_C(1234567);     /* 1.23 ms */
        t.buffer = t.start + UINT64_C(9876543);
        t.registry = t.start + UINT64_C(600000);
        t.surface = t.start + UINT64_C(610000);
        t.configure = t.start + UINT64_C(1700000);
        t.commit = t.start + UINT64_C(9880000);
        t.frame = t.start + UINT64_C(205000000);
        t.presented = t.start - 5U;                  /* clock skew clamps to 0 */
        assert(continuity_format_timing(&t, line, sizeof(line)));
        assert(strcmp(line, "file=0.04 connect=1.23 buffer=9.87 registry=0.60 outputs=- "
                            "surface=0.61 configure=1.70 commit=9.88 frame=205.00 presented=0.00") == 0);
        char small[20];
        assert(!continuity_format_timing(&t, small, sizeof(small)));
        assert(!continuity_format_timing(&t, small, 0));
}

static void test_args(void)
{
        continuity_options_t o;
        char err[128];
        char *defaults[] = {"x", NULL};
        assert(continuity_parse_args(1, defaults, &o, err, sizeof(err)) == CONTINUITY_ARGS_OK);
        assert(strcmp(o.file, "/run/omarchy-plymouth-handoff.raw") == 0 && !o.file_overridden);
        assert(o.max_age_ms == 60000 && o.max_ms == 8000 && o.fade_ms == 200);
        assert(o.pid_file == NULL && o.ready_file == NULL && o.alpha_modifier && !o.help);

        char *all[] = {"x", "--file", "/tmp/f", "--max-age-ms=5", "--max-ms", "0", "--fade-ms=0",
                       "--pid-file", "/p", "--ready-file=/r", "--no-alpha-modifier", NULL};
        assert(continuity_parse_args(11, all, &o, err, sizeof(err)) == CONTINUITY_ARGS_OK);
        assert(strcmp(o.file, "/tmp/f") == 0 && o.file_overridden);
        assert(o.max_age_ms == 5 && o.max_ms == 0 && o.fade_ms == 0);
        assert(strcmp(o.pid_file, "/p") == 0 && strcmp(o.ready_file, "/r") == 0);
        assert(!o.alpha_modifier);

        char *bad_number[] = {"x", "--max-ms", "12a", NULL};
        assert(continuity_parse_args(3, bad_number, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        assert(strstr(err, "--max-ms") != NULL);
        char *negative[] = {"x", "--fade-ms=-1", NULL};
        assert(continuity_parse_args(2, negative, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *huge[] = {"x", "--max-ms=99999999999999999999999", NULL};
        assert(continuity_parse_args(2, huge, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *too_long_fade[] = {"x", "--fade-ms=10001", NULL};
        assert(continuity_parse_args(2, too_long_fade, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *missing[] = {"x", "--file", NULL};
        assert(continuity_parse_args(2, missing, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *empty[] = {"x", "--file=", NULL};
        assert(continuity_parse_args(2, empty, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *unknown[] = {"x", "--bogus=1", NULL};
        assert(continuity_parse_args(2, unknown, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        assert(strstr(err, "--bogus") != NULL);
        char *unknown_last[] = {"x", "--bogus", NULL};
        assert(continuity_parse_args(2, unknown_last, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        assert(strstr(err, "unknown argument --bogus") != NULL);
        char *positional[] = {"x", "file", NULL};
        assert(continuity_parse_args(2, positional, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *prefix[] = {"x", "--file-x=1", NULL};
        assert(continuity_parse_args(2, prefix, &o, err, sizeof(err)) == CONTINUITY_ARGS_ERROR);
        char *help[] = {"x", "--help", NULL};
        assert(continuity_parse_args(2, help, &o, err, sizeof(err)) == CONTINUITY_ARGS_OK && o.help);
}

static void test_outputs(void)
{
        continuity_output_info_t outputs[3] = {
                {.mode_width = 1920, .mode_height = 1080, .has_mode = true},
                {.mode_width = 3456, .mode_height = 2234, .transform = 1, .has_mode = true},
                {.mode_width = 3456, .mode_height = 2234, .has_mode = true}
        };
        assert(continuity_pick_output(outputs, 3, 3456, 2234) == 2);
        assert(continuity_pick_output(outputs, 3, 1920, 1080) == 0);
        assert(continuity_pick_output(outputs, 3, 2234, 3456) == -1);
        assert(continuity_pick_output(outputs, 3, 1920, 1200) == -1);
        assert(continuity_pick_output(outputs, 0, 1920, 1080) == -1);
        outputs[0].has_mode = false;
        assert(continuity_pick_output(outputs, 1, 1920, 1080) == -1);
}

static void test_fade(void)
{
        uint32_t src[4] = {0x00ffffffU, 0x00000000U, 0x00804020U, 0x00010203U};
        uint32_t dst[4];
        continuity_premultiply(src, dst, 4, 255);
        assert(dst[0] == 0xffffffffU && dst[1] == 0xff000000U && dst[2] == 0xff804020U);
        continuity_premultiply(src, dst, 4, 0);
        for (int i = 0; i < 4; i++)
                assert(dst[i] == 0);
        /* Every 8-bit channel and alpha: exact round(c * a / 255). */
        for (uint32_t a = 0; a < 256; a++) {
                for (uint32_t ch = 0; ch < 256; ch++) {
                        uint32_t px = ch << 16 | ch << 8 | ch;
                        uint32_t out;
                        uint32_t expected = (ch * a * 2U + 255U) / 510U;
                        continuity_premultiply(&px, &out, 1, (uint8_t)a);
                        assert(out >> 24 == a);
                        assert(((out >> 16) & 0xffU) == expected && ((out >> 8) & 0xffU) == expected &&
                               (out & 0xffU) == expected);
                }
        }
        const uint64_t fade = 200U * NS_PER_MS;
        assert(continuity_fade_alpha(0, fade) == 255);
        assert(continuity_fade_alpha(fade / 2U, fade) == 128);
        assert(continuity_fade_alpha(fade - 1U, fade) == 0 || continuity_fade_alpha(fade - 1U, fade) == 1);
        assert(continuity_fade_alpha(fade, fade) == 0);
        assert(continuity_fade_alpha(fade * 2U, fade) == 0);
        assert(continuity_fade_alpha(0, 0) == 0);
        uint8_t previous = 255;
        for (uint64_t t = 0; t <= fade; t += NS_PER_MS) {
                uint8_t alpha = continuity_fade_alpha(t, fade);
                assert(alpha <= previous);
                previous = alpha;
        }
}

int main(void)
{
        const char *tmp = getenv("TMPDIR");
        snprintf(directory, sizeof(directory), "%s/omarchy-continuity-test.XXXXXX",
                 tmp != NULL && *tmp != '\0' ? tmp : "/var/tmp");
        assert(mkdtemp(directory) != NULL);
        test_header();
        test_files();
        test_copy();
        test_copy_readonly_source();
        test_timing();
        test_args();
        test_outputs();
        test_fade();
        assert(rmdir(directory) == 0);
        puts("continuity frame tests: PASS");
        return 0;
}
