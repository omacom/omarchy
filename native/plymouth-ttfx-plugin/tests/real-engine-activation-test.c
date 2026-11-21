#include "embedded-logo.h"
#include "ttfx_plymouth.h"

#include <assert.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static TtfxEngine *new_vhstape(void)
{
        TtfxEngine *engine = NULL;
        assert(ttfx_engine_create_with_background("vhstape", UINT64_C(0x4f4d4152434859),
                ttfx_embedded_logo, ttfx_embedded_logo_len, 162, 20, 240, 0x0b0d10,
                &engine) == TTFX_STATUS_OK);
        return engine;
}

static void verify_replay(TtfxEngine *live, unsigned int step)
{
        TtfxEngine *replay = new_vhstape();
        const TtfxCell *a, *b;
        size_t an, bn;
        uint32_t aw, ah, bw, bh;
        for (unsigned int i = 0; i < step; i++) {
                uint8_t looped;
                assert(ttfx_engine_step(replay, &looped) == TTFX_STATUS_OK);
                assert(!looped);
        }
        assert(ttfx_engine_cells(live, &a, &an, &aw, &ah) == TTFX_STATUS_OK);
        assert(ttfx_engine_cells(replay, &b, &bn, &bw, &bh) == TTFX_STATUS_OK);
        assert(an == bn && aw == bw && ah == bh);
        assert(memcmp(a, b, an * sizeof(*a)) == 0);
        ttfx_engine_free(replay);
}

static void test_loop_local_replay(void)
{
        TtfxEngine *engine = new_vhstape();
        unsigned int step = 0, cycles = 0, ticks = 0;
        verify_replay(engine, 0);
        while (cycles < 2 && ticks < 10000) {
                for (unsigned int i = 0; i < 3; i++) {
                        uint8_t looped;
                        assert(ttfx_engine_step(engine, &looped) == TTFX_STATUS_OK);
                        if (looped) {
                                assert(ttfx_engine_reset(engine) == TTFX_STATUS_OK);
                                step = 0;
                                cycles++;
                                verify_replay(engine, 0);
                        } else {
                                step++;
                        }
                }
                if (ticks == 0 || cycles > 0) verify_replay(engine, step);
                ticks++;
        }
        assert(cycles >= 2);
        ttfx_engine_free(engine);
        printf("real vhstape replay: PASS (%u ticks, %u loops, exact cell equality)\n", ticks, cycles);
}

/* The outro through the real C ABI: decrypt recorded with the plugin's bounds,
 * played forward like the boot (2 steps per tick), then backwards within the
 * default 168-call budget to an exactly blank canvas. */
static void test_reverse_outro_reaches_the_blank_canvas(void)
{
        TtfxEngine *engine = NULL;
        const TtfxCell *cells;
        size_t count;
        uint32_t width, height, calls = 0U;

        assert(ttfx_engine_create_with_background("decrypt", UINT64_C(22321466108495961),
                ttfx_embedded_logo, ttfx_embedded_logo_len, 162, 20, 240, 0x0b0d10,
                &engine) == TTFX_STATUS_OK);
        assert(ttfx_engine_record_history(engine, 128U, (size_t)4U << 20) == TTFX_STATUS_OK);
        for (unsigned int tick = 0U; tick < 600U; tick++)
                for (unsigned int step = 0U; step < 2U; step++)
                        assert(ttfx_engine_draw_logo(engine, TTFX_LOGO_MODE_ONE_TIME, NULL, NULL) ==
                               TTFX_STATUS_OK);
        assert(ttfx_engine_begin_reverse(engine, 168U, 2U, &calls) == TTFX_STATUS_OK);
        assert(calls >= 2U && calls <= 168U);
        for (uint32_t call = 1U; call <= calls; call++) {
                uint8_t finished = 9U;
                assert(ttfx_engine_draw_logo(engine, TTFX_LOGO_MODE_REVERSE, NULL, &finished) ==
                       TTFX_STATUS_OK);
                assert(finished == (call == calls));
        }
        assert(ttfx_engine_cells(engine, &cells, &count, &width, &height) == TTFX_STATUS_OK);
        for (size_t index = 0U; index < count; index++)
                assert(cells[index].codepoint == 0x20U && cells[index].flags == 0U);
        ttfx_engine_free(engine);
        printf("real decrypt reverse outro: PASS (%u calls to the blank canvas)\n", calls);
}

int main(void)
{
        test_reverse_outro_reaches_the_blank_canvas();
        test_loop_local_replay();
        TtfxEngine *engine = NULL;
        const TtfxCell *cells = NULL;
        size_t count = 0U;
        uint32_t width = 0U;
        uint32_t height = 0U;

        if (ttfx_engine_create("decrypt", UINT64_C(22321466108495961),
                               ttfx_embedded_logo, ttfx_embedded_logo_len,
                               162U, 20U, 240U, &engine) != TTFX_STATUS_OK ||
            engine == NULL) {
                fputs("real activation probe: engine creation failed\n", stderr);
                return EXIT_FAILURE;
        }
        if (ttfx_engine_cells(engine, &cells, &count, &width, &height) != TTFX_STATUS_OK ||
            cells == NULL || count != 162U * 20U || width != 162U || height != 20U) {
                fputs("real activation probe: incomplete initial snapshot\n", stderr);
                ttfx_engine_free(engine);
                return EXIT_FAILURE;
        }
        ttfx_engine_free(engine);
        puts("real activation probe: PASS (162x20 snapshot)");
        return EXIT_SUCCESS;
}
