#define _GNU_SOURCE
#include <assert.h>
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "state.h"

static void test_tick_progresses_and_wraps(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(state.frame == 0U);
        for (unsigned int i = 0; i < TTFX_FRAME_COUNT - 1U; i++)
                ttfx_state_tick(&state);
        assert(state.frame == TTFX_FRAME_COUNT - 1U);
        ttfx_state_tick(&state);
        assert(state.frame == 0U);
}

static void test_input_only_freezes_after_first_natural_completion(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(state.playback_mode == TTFX_PLAYBACK_SUBMIT_TO_FINISH);
        assert(state.playback_phase == TTFX_PLAYBACK_INPUT);
        assert(ttfx_state_engine_steps_per_tick(&state) == 2U);

        assert(ttfx_state_set_password(&state, "Password", 4));
        ttfx_state_set_normal(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FAST_FORWARD);
        assert(ttfx_state_engine_steps_per_tick(&state) ==
               TTFX_FAST_FORWARD_STEPS_PER_TICK);

        ttfx_state_engine_completed(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FINAL);
        assert(ttfx_state_engine_steps_per_tick(&state) == 0U);

        ttfx_state_confirm_success(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FINAL);
        assert(ttfx_state_engine_steps_per_tick(&state) == 0U);
        ttfx_state_destroy(&state);
}

static void test_input_only_fast_forwards_when_success_precedes_completion(void)
{
        ttfx_state_t state = ttfx_state_initial();

        ttfx_state_confirm_success(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FAST_FORWARD);
        assert(ttfx_state_engine_steps_per_tick(&state) ==
               TTFX_FAST_FORWARD_STEPS_PER_TICK);
        ttfx_state_engine_completed(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FINAL);
        assert(ttfx_state_engine_steps_per_tick(&state) == 0U);
        ttfx_state_destroy(&state);
}

static void test_continuous_mode_preserves_current_looping_behavior(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_playback_mode(&state, "continuous"));
        assert(state.playback_mode == TTFX_PLAYBACK_CONTINUOUS);
        assert(ttfx_state_set_password(&state, "Password", 3));
        ttfx_state_set_normal(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_INPUT);
        assert(ttfx_state_engine_steps_per_tick(&state) == 2U);
        ttfx_state_engine_completed(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_INPUT);
        assert(ttfx_state_engine_steps_per_tick(&state) == 2U);
        assert(!ttfx_state_set_playback_mode(&state, "unknown"));
        ttfx_state_destroy(&state);
}

static void test_retry_returns_submit_to_finish_mode_to_input(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 5));
        ttfx_state_set_normal(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FAST_FORWARD);
        ttfx_state_engine_completed(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FINAL);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(ttfx_state_reaction_active(&state));
        assert(state.playback_phase == TTFX_PLAYBACK_INPUT);
        assert(ttfx_state_engine_steps_per_tick(&state) == 2U);
        ttfx_state_destroy(&state);
}

static void test_submit_accelerates_to_final_for_verdict(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 4));
        ttfx_state_set_normal(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FAST_FORWARD);
        assert(ttfx_state_engine_steps_per_tick(&state) ==
               TTFX_FAST_FORWARD_STEPS_PER_TICK);
        ttfx_state_destroy(&state);
}

static void test_failed_answer_mid_fast_forward_loops_after_final(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 4));
        ttfx_state_set_normal(&state);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(ttfx_state_reaction_active(&state));
        assert(state.playback_phase == TTFX_PLAYBACK_FAST_FORWARD);
        ttfx_state_engine_completed(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_FINAL);
        ttfx_state_tick(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_INPUT);
        assert(ttfx_state_engine_steps_per_tick(&state) == 2U);
        ttfx_state_destroy(&state);
}

static void test_empty_submit_does_not_accelerate(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 0));
        ttfx_state_set_normal(&state);
        assert(state.playback_phase == TTFX_PLAYBACK_INPUT);
        ttfx_state_destroy(&state);
}

static void test_failed_nonempty_password_replacement_triggers_once(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 4));
        ttfx_state_set_normal(&state);
        assert(ttfx_state_password_pending(&state));
        assert(state.prompt_mode == TTFX_PROMPT_PASSWORD);
        assert(state.bullets == 4);
        assert(strcmp(state.prompt, "Password") == 0);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(!ttfx_state_password_pending(&state));
        assert(ttfx_state_reaction_active(&state));
        assert(state.reaction_tick == 0U);

        ttfx_state_tick(&state);
        assert(state.reaction_tick == 1U);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(state.reaction_tick == 1U);
        ttfx_state_destroy(&state);
}

static void test_password_candidate_expires_to_normal(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 4));
        ttfx_state_set_normal(&state);
        for (unsigned int tick = 1U; tick < TTFX_FAILURE_CANDIDATE_TICKS; tick++) {
                ttfx_state_tick(&state);
                assert(ttfx_state_password_pending(&state));
                assert(state.prompt_mode == TTFX_PROMPT_PASSWORD);
                assert(state.bullets == 4);
        }
        ttfx_state_tick(&state);
        assert(!ttfx_state_password_pending(&state));
        assert(state.prompt_mode == TTFX_PROMPT_NONE);
        assert(state.bullets == 0);
        assert(state.prompt == NULL);
        ttfx_state_destroy(&state);
}

static void test_clear_prompt_never_arms_password_failure(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 4));
        ttfx_state_clear_prompt(&state);
        assert(!ttfx_state_password_pending(&state));
        assert(state.prompt_mode == TTFX_PROMPT_NONE);
        assert(state.bullets == 0);
        assert(state.prompt == NULL);
        ttfx_state_destroy(&state);
}

static void test_password_failure_sequence_rejects_false_positives(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 4));
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(!ttfx_state_reaction_active(&state));

        assert(ttfx_state_set_password(&state, "Password", 3));
        ttfx_state_set_normal(&state);
        assert(ttfx_state_set_password(&state, "Other volume", 0));
        assert(!ttfx_state_reaction_active(&state));

        assert(ttfx_state_set_password(&state, "Password", 2));
        ttfx_state_set_normal(&state);
        for (unsigned int tick = 0U; tick < TTFX_FAILURE_CANDIDATE_TICKS; tick++)
                ttfx_state_tick(&state);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(!ttfx_state_reaction_active(&state));

        assert(ttfx_state_set_password(&state, "Password", 0));
        ttfx_state_set_normal(&state);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(!ttfx_state_reaction_active(&state));
        ttfx_state_destroy(&state);
}

static void test_reaction_visual_is_horizontal_bounded_red_and_finite(void)
{
        ttfx_state_t state = ttfx_state_initial();
        char prompt[] = "Password";

        assert(TTFX_REACTION_TICKS == 168U);
        assert(TTFX_FAILURE_CANDIDATE_TICKS == 1200U);

        assert(ttfx_state_set_password(&state, prompt, 5));
        ttfx_state_set_normal(&state);
        prompt[0] = 'X';
        assert(ttfx_state_set_password(&state, "Password", 0));
        for (unsigned int tick = 0U; tick < 24U; tick++) {
                assert(ttfx_state_reaction_x_offset(&state) == -8);
                ttfx_state_tick(&state);
        }
        assert(ttfx_state_reaction_x_offset(&state) == 6);
        state.reaction_tick = 0U;
        for (unsigned int tick = 0U; tick < TTFX_REACTION_TICKS; tick++) {
                int offset = ttfx_state_reaction_x_offset(&state);
                assert(offset >= -8 && offset <= 8);
                assert(ttfx_state_reaction_row_red(&state, tick % TTFX_GRID_ROWS));
                ttfx_state_tick(&state);
        }
        assert(!ttfx_state_reaction_active(&state));
        assert(ttfx_state_reaction_x_offset(&state) == 0);
        assert(!ttfx_state_reaction_row_red(&state, 0U));

        assert(ttfx_state_set_password(&state, "Password", 2));
        ttfx_state_set_normal(&state);
        assert(ttfx_state_set_password(&state, "Password", 0));
        assert(ttfx_state_reaction_active(&state));
        assert(ttfx_state_set_question(&state, "Recovery key", ""));
        assert(!ttfx_state_reaction_active(&state));
        ttfx_state_destroy(&state);
}

static void test_prompt_modes_and_bullets(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_password(&state, "Password", 7));
        assert(state.prompt_mode == TTFX_PROMPT_PASSWORD);
        assert(state.bullets == 7);

        assert(ttfx_state_set_password(&state, "Password", -3));
        assert(state.bullets == 0);

        assert(ttfx_state_set_question(&state, "Question", "answer"));
        assert(state.prompt_mode == TTFX_PROMPT_QUESTION);
        assert(state.bullets == 0);

        ttfx_state_set_normal(&state);
        assert(state.prompt_mode == TTFX_PROMPT_NONE);
        ttfx_state_destroy(&state);
}

static void test_active_prompt_state_is_owned_for_new_views(void)
{
        ttfx_state_t state = ttfx_state_initial();
        char prompt[] = "Question";
        char answer[] = "visible answer";

        assert(ttfx_state_set_question(&state, prompt, answer));
        prompt[0] = 'X';
        answer[0] = 'X';
        assert(strcmp(state.prompt, "Question") == 0);
        assert(strcmp(state.entry_text, "visible answer") == 0);

        assert(ttfx_state_set_password(&state, "Password", 4));
        assert(strcmp(state.prompt, "Password") == 0);
        assert(state.entry_text == NULL);
        assert(state.bullets == 4);
        ttfx_state_destroy(&state);
}

static void test_messages_restore_latest_still_active_message(void)
{
        ttfx_state_t state = ttfx_state_initial();
        char first[] = "A";

        assert(ttfx_state_set_message(&state, first));
        first[0] = 'X';
        assert(ttfx_state_set_message(&state, "B"));
        assert(strcmp(state.message, "B") == 0);

        assert(ttfx_state_hide_message(&state, "A"));
        assert(state.message_visible);
        assert(strcmp(state.message, "B") == 0);

        assert(ttfx_state_hide_message(&state, "B"));
        assert(!state.message_visible);
        assert(state.message == NULL);
        ttfx_state_destroy(&state);
}

static void test_duplicate_and_unknown_messages_are_safe(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(ttfx_state_set_message(&state, "A"));
        assert(ttfx_state_set_message(&state, "B"));
        assert(ttfx_state_set_message(&state, "A"));
        assert(strcmp(state.message, "A") == 0);

        assert(ttfx_state_hide_message(&state, "A"));
        assert(strcmp(state.message, "B") == 0);
        assert(!ttfx_state_hide_message(&state, "unknown"));
        assert(strcmp(state.message, "B") == 0);
        assert(!ttfx_state_hide_message(&state, NULL));
        assert(strcmp(state.message, "B") == 0);

        assert(ttfx_state_hide_message(&state, "A"));
        assert(strcmp(state.message, "B") == 0);
        assert(!ttfx_state_hide_message(&state, "A"));
        assert(ttfx_state_hide_message(&state, "B"));
        assert(state.message == NULL);
        ttfx_state_destroy(&state);
}

static void test_repeated_password_only_shows_on_hidden_transition(void)
{
        ttfx_view_state_t view = ttfx_view_state_initial();

        assert(ttfx_view_show_prompt(&view));
        assert(!ttfx_view_show_prompt(&view));
        assert(ttfx_view_hide_prompt(&view));
        assert(!ttfx_view_hide_prompt(&view));
        assert(ttfx_view_show_prompt(&view));

        assert(ttfx_view_show_message(&view));
        assert(!ttfx_view_show_message(&view));
        assert(ttfx_view_hide_message(&view));
        assert(!ttfx_view_hide_message(&view));
}

static void test_live_loop_detach_is_idempotent(void)
{
        ttfx_loop_state_t loop = ttfx_loop_state_initial();

        ttfx_loop_watch_attached(&loop);
        assert(ttfx_loop_detach_watch(&loop));
        assert(!ttfx_loop_detach_watch(&loop));
}

static void test_widget_load_failure_rejects_graphical_splash(void)
{
        ttfx_load_state_t load = ttfx_load_state_initial();

        ttfx_load_state_record_view(&load, true);
        assert(ttfx_load_state_can_show(&load));
        ttfx_load_state_record_view(&load, false);
        assert(!ttfx_load_state_can_show(&load));
        ttfx_load_state_record_view(&load, true);
        assert(!ttfx_load_state_can_show(&load));
}

static void test_dynamic_view_failure_is_discarded_without_poisoning_splash(void)
{
        ttfx_load_state_t load = ttfx_load_state_initial();

        ttfx_load_state_record_view(&load, true);
        assert(ttfx_dynamic_view_should_keep(true));
        assert(!ttfx_dynamic_view_should_keep(false));
        assert(ttfx_load_state_can_show(&load));
}

static void test_animation_unavailable_selects_static_only_mode(void)
{
        ttfx_state_t state = ttfx_state_initial();

        assert(state.animation_enabled);
        assert(!state.rendering_failed);
        ttfx_state_disable_animation(&state);
        assert(!state.animation_enabled);
        assert(!state.rendering_failed);
        ttfx_state_destroy(&state);
}

static void test_runtime_label_failure_degrades_without_hiding_prompt(void)
{
        ttfx_state_t state = ttfx_state_initial();
        ttfx_view_state_t view = ttfx_view_state_initial();

        assert(ttfx_view_show_prompt(&view));
        assert(view.prompt_visible);
        assert(ttfx_view_prompt_can_show(&view));
        ttfx_view_degrade_prompt(&state, &view);
        assert(!ttfx_view_prompt_can_show(&view));
        assert(view.prompt_visible);
        assert(!state.animation_enabled);
        assert(!state.rendering_failed);

        /* A repeated callback must keep the entry visible and not retry the label. */
        assert(!ttfx_view_show_prompt(&view));
        ttfx_view_degrade_prompt(&state, &view);
        assert(view.prompt_visible);
        assert(!ttfx_view_prompt_can_show(&view));
        assert(!state.rendering_failed);

        assert(ttfx_view_message_can_show(&view));
        ttfx_view_degrade_message(&state, &view);
        assert(!ttfx_view_message_can_show(&view));
        assert(!view.message_visible);
        assert(!state.animation_enabled);
        assert(!state.rendering_failed);
        ttfx_state_destroy(&state);
}

static void test_geometry_is_centered_and_bounded(void)
{
        ttfx_geometry_t geometry = ttfx_geometry_for_view(1920U, 1080U);

        assert(geometry.columns == TTFX_GRID_COLUMNS);
        assert(geometry.rows == TTFX_GRID_ROWS);
        assert(geometry.cell_width > 0U);
        assert(geometry.cell_height > 0U);
        assert(geometry.cell_width == 5U);
        assert(geometry.grid_width == 826U);
        assert(geometry.grid_height == 200U);
        assert(geometry.cell_height == 10U);
        assert(geometry.grid_x == (1920U - geometry.grid_width) / 2U);
        assert(geometry.grid_y == (1080U - geometry.grid_height) * 9U / 20U);
        assert(geometry.grid_x + geometry.grid_width <= 1920U);
        assert(geometry.grid_y + geometry.grid_height <= 1080U);

        /* Cumulative widths alternate without holes or accumulated pitch error. */
        for (unsigned int column = 0U; column < geometry.columns; column++) {
                unsigned int left = ttfx_geometry_x_edge(&geometry, column);
                unsigned int right = ttfx_geometry_x_edge(&geometry, column + 1U);
                assert(left == column * 51U / 10U);
                assert(right - left == 5U || right - left == 6U);
        }
        assert(ttfx_geometry_x_edge(&geometry, 162U) == geometry.grid_width);
        /* Occupied official wordmark starts one half-row below the canvas. */
        assert(geometry.grid_height - geometry.cell_height == 190U);
        const unsigned int sizes[][2] = {{800U, 600U}, {320U, 200U}, {80U, 40U}, {3U, 2U}, {0U, 0U}};
        for (unsigned int i = 0U; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
                ttfx_geometry_t small = ttfx_geometry_for_view(sizes[i][0], sizes[i][1]);
                assert(small.grid_x + small.grid_width <= sizes[i][0]);
                assert(small.grid_y + small.grid_height <= sizes[i][1]);
                assert(small.grid_width == ttfx_geometry_x_edge(&small, small.columns));
                assert(small.grid_width == small.columns * small.cell_height * 51U / 100U);
        }

        geometry = ttfx_geometry_for_view(80U, 40U);
        assert(geometry.grid_width <= 80U);
        assert(geometry.grid_height <= 40U);

        geometry = ttfx_geometry_for_view(3U, 2U);
        assert(geometry.columns * geometry.cell_width <= geometry.grid_width);
        assert(geometry.rows * geometry.cell_height <= geometry.grid_height);
}

static void test_multiple_views_keep_independent_geometry(void)
{
        ttfx_geometry_t wide = ttfx_geometry_for_view(1920U, 1080U);
        ttfx_geometry_t compact = ttfx_geometry_for_view(800U, 600U);

        assert(wide.grid_x != compact.grid_x);
        assert(wide.grid_y != compact.grid_y);
        assert(wide.grid_x == (1920U - wide.grid_width) / 2U);
        assert(compact.grid_x == (800U - compact.grid_width) / 2U);
}


static void test_display_swap_offset_and_glide(void)
{
        int offset = 0;
        ttfx_geometry_t old_view = ttfx_geometry_for_view(1728U, 1080U);
        ttfx_geometry_t new_view = ttfx_geometry_for_view(1728U, 1117U);

        assert(ttfx_display_swap_offset(1728U, 1080U, old_view.grid_y, 1728U, 1117U, new_view.grid_y, &offset));
        assert(offset == (int)old_view.grid_y + 37 - (int)new_view.grid_y);
        assert(offset > 0);
        assert(!ttfx_display_swap_offset(1728U, 1080U, old_view.grid_y, 1920U, 1117U, new_view.grid_y, &offset));
        assert(!ttfx_display_swap_offset(1728U, 1080U, old_view.grid_y, 1728U, 1080U, old_view.grid_y, &offset));
        assert(!ttfx_display_swap_offset(1728U, 800U, 300U, 1728U, 1117U, new_view.grid_y, &offset));
        assert(!ttfx_display_swap_offset(0U, 0U, 0U, 0U, 0U, 0U, &offset));
        assert(!ttfx_display_swap_offset(1728U, 1080U, 1U, 1728U, 1117U, 2U, NULL));

        assert(ttfx_glide_offset(21, 0U, 96U) == 21);
        assert(ttfx_glide_offset(-21, 0U, 96U) == -21);
        assert(ttfx_glide_offset(21, 96U, 96U) == 0);
        assert(ttfx_glide_offset(21, 500U, 96U) == 0);
        assert(ttfx_glide_offset(21, 1U, 0U) == 0);
        int previous = 21;
        for (unsigned int tick = 1U; tick <= 96U; tick++) {
                int value = ttfx_glide_offset(21, tick, 96U);
                assert(value <= previous && value >= 0);
                previous = value;
        }
        /* Ease-out: most of the distance is covered in the first third. */
        assert(ttfx_glide_offset(21, 32U, 96U) <= 7);
}

/* Display-swap bridge and fbcon handoff: a frame lands bottom-aligned in a
 * framebuffer of the same width, under rows filled with the background. */
static void test_compose_bottom_aligned_fills_top_rows_and_respects_stride(void)
{
        enum { WIDTH = 3, HEIGHT = 2, TOP = 2, STRIDE_PIXELS = 5, SENTINEL = 0x5a5a5a5a };
        const uint32_t frame[WIDTH * HEIGHT] = {1U, 2U, 3U, 4U, 5U, 6U};
        uint32_t destination[(HEIGHT + TOP) * STRIDE_PIXELS];
        const size_t stride = STRIDE_PIXELS * sizeof(uint32_t);

        for (size_t i = 0U; i < sizeof(destination) / sizeof(destination[0]); i++)
                destination[i] = SENTINEL;
        assert(ttfx_compose_bottom_aligned(destination, stride, frame, WIDTH, HEIGHT, TOP,
                                           UINT32_C(0xff0b0d10)));
        for (unsigned int row = 0U; row < HEIGHT + TOP; row++) {
                for (unsigned int x = 0U; x < STRIDE_PIXELS; x++) {
                        uint32_t value = destination[row * STRIDE_PIXELS + x];
                        if (x >= WIDTH)
                                assert(value == SENTINEL); /* stride padding untouched */
                        else if (row < TOP)
                                assert(value == UINT32_C(0xff0b0d10));
                        else
                                assert(value == frame[(row - TOP) * WIDTH + x]);
                }
        }

        /* Zero top rows: a same-size framebuffer gets the frame from row 0. */
        for (size_t i = 0U; i < sizeof(destination) / sizeof(destination[0]); i++)
                destination[i] = SENTINEL;
        assert(ttfx_compose_bottom_aligned(destination, stride, frame, WIDTH, HEIGHT, 0U, 0U));
        for (unsigned int x = 0U; x < WIDTH; x++) {
                assert(destination[x] == frame[x]);
                assert(destination[STRIDE_PIXELS + x] == frame[WIDTH + x]);
        }
        assert(destination[WIDTH] == SENTINEL);
        assert(destination[2U * STRIDE_PIXELS] == SENTINEL);

        /* A tightly packed destination (stride == row size) works too. */
        uint32_t packed[(HEIGHT + 1) * WIDTH];
        assert(ttfx_compose_bottom_aligned(packed, WIDTH * sizeof(uint32_t), frame, WIDTH, HEIGHT,
                                           1U, 7U));
        assert(packed[0] == 7U && packed[1] == 7U && packed[2] == 7U);
        assert(memcmp(packed + WIDTH, frame, sizeof(frame)) == 0);

        /* Refusals write nothing. */
        for (size_t i = 0U; i < sizeof(destination) / sizeof(destination[0]); i++)
                destination[i] = SENTINEL;
        assert(!ttfx_compose_bottom_aligned(destination, WIDTH * sizeof(uint32_t) - 1U, frame,
                                            WIDTH, HEIGHT, TOP, 0U));
        assert(!ttfx_compose_bottom_aligned(NULL, stride, frame, WIDTH, HEIGHT, TOP, 0U));
        assert(!ttfx_compose_bottom_aligned(destination, stride, NULL, WIDTH, HEIGHT, TOP, 0U));
        assert(!ttfx_compose_bottom_aligned(destination, stride, frame, 0U, HEIGHT, TOP, 0U));
        assert(!ttfx_compose_bottom_aligned(destination, stride, frame, WIDTH, 0U, TOP, 0U));
        for (size_t i = 0U; i < sizeof(destination) / sizeof(destination[0]); i++)
                assert(destination[i] == SENTINEL);
}


static void test_firmware_hold_mode_parsing(void)
{
        assert(ttfx_firmware_hold_mode_parse("true") == TTFX_FIRMWARE_HOLD_ON);
        assert(ttfx_firmware_hold_mode_parse("false") == TTFX_FIRMWARE_HOLD_OFF);
        assert(ttfx_firmware_hold_mode_parse("auto") == TTFX_FIRMWARE_HOLD_AUTO);
        assert(ttfx_firmware_hold_mode_parse(NULL) == TTFX_FIRMWARE_HOLD_AUTO);
        assert(ttfx_firmware_hold_mode_parse("") == TTFX_FIRMWARE_HOLD_AUTO);
        assert(ttfx_firmware_hold_mode_parse("TRUE") == TTFX_FIRMWARE_HOLD_AUTO);
        assert(ttfx_firmware_hold_mode_parse("true ") == TTFX_FIRMWARE_HOLD_AUTO);
        assert(ttfx_firmware_hold_mode_parse("1") == TTFX_FIRMWARE_HOLD_AUTO);
        assert(ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_ON, "/nonexistent/ttfx-chosen"));
        assert(!ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_OFF, "/nonexistent/ttfx-chosen"));
        assert(!ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_AUTO, "/nonexistent/ttfx-chosen"));
        assert(!ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_AUTO, NULL));
        assert(!ttfx_devicetree_has_framebuffer(""));
}

static void fixture_path(char *path, size_t size, const char *root, const char *relative)
{
        int written = snprintf(path, size, "%s/%s", root, relative);
        assert(written > 0 && (size_t)written < size);
}

static void fixture_mkdir(const char *root, const char *relative)
{
        char path[PATH_MAX];

        fixture_path(path, sizeof(path), root, relative);
        assert(mkdir(path, 0755) == 0);
}

static void fixture_u32(const char *root, const char *relative, uint32_t value, size_t length)
{
        char path[PATH_MAX];
        const unsigned char bytes[5] = {(unsigned char)(value >> 24), (unsigned char)(value >> 16),
                                        (unsigned char)(value >> 8), (unsigned char)value, 0U};
        FILE *file;

        fixture_path(path, sizeof(path), root, relative);
        file = fopen(path, "wb");
        assert(file != NULL);
        assert(fwrite(bytes, 1U, length, file) == length);
        assert(fclose(file) == 0);
}

static void fixture_symlink(const char *root, const char *target, const char *relative)
{
        char path[PATH_MAX];

        fixture_path(path, sizeof(path), root, relative);
        assert(symlink(target, path) == 0);
}

/* Fixtures live under ${TMPDIR:-/var/tmp} and are retained; every symlink
 * target stays inside the fixture directory. */
static void test_firmware_display_detection_and_devicetree(void)
{
        const char *tmp = getenv("TMPDIR");
        char root[PATH_MAX];
        char drm[PATH_MAX];
        char path[PATH_MAX];
        char target[PATH_MAX];
        int written = snprintf(root, sizeof(root), "%s/ttfx-state-firmware.XXXXXX",
                               tmp != NULL && tmp[0] != '\0' ? tmp : "/var/tmp");

        assert(written > 0 && (size_t)written < sizeof(root));
        assert(mkdtemp(root) != NULL);
        fixture_mkdir(root, "drivers");
        fixture_mkdir(root, "drivers/simple-framebuffer");
        fixture_mkdir(root, "drivers/apple-dcp");
        fixture_mkdir(root, "drivers/not-simple-framebuffer");
        fixture_mkdir(root, "drm");
        fixture_mkdir(root, "drm/card0");
        fixture_mkdir(root, "drm/card0/device");
        fixture_mkdir(root, "drm/card1");
        fixture_mkdir(root, "drm/card1/device");
        fixture_mkdir(root, "drm/card2");
        fixture_mkdir(root, "drm/card2/device");
        fixture_mkdir(root, "drm/card3");
        fixture_mkdir(root, "drm/card3/device");
        fixture_mkdir(root, "drm/card12");
        fixture_mkdir(root, "drm/card12/device");
        fixture_mkdir(root, "drm/card4");
        fixture_mkdir(root, "drm/card4/device");
        fixture_path(target, sizeof(target), root, "drivers/simple-framebuffer");
        fixture_symlink(root, target, "drm/card0/device/driver");
        fixture_path(target, sizeof(target), root, "drivers/apple-dcp");
        fixture_symlink(root, target, "drm/card1/device/driver");
        fixture_path(target, sizeof(target), root, "drivers/not-simple-framebuffer");
        fixture_symlink(root, target, "drm/card2/device/driver");
        /* Relative, like the kernel's own links, and with a trailing slash. */
        fixture_symlink(root, "../../../drivers/simple-framebuffer", "drm/card12/device/driver");
        fixture_path(target, sizeof(target), root, "drivers/simple-framebuffer/");
        fixture_symlink(root, target, "drm/card4/device/driver");
        /* card3 has a device but no driver link. */
        fixture_path(drm, sizeof(drm), root, "drm");

        assert(ttfx_firmware_display("/dev/dri/card0", drm));
        assert(ttfx_firmware_display("/dev/dri/card12", drm));
        assert(ttfx_firmware_display("/dev/dri/card4", drm));
        assert(!ttfx_firmware_display("/dev/dri/card1", drm));
        assert(!ttfx_firmware_display("/dev/dri/card2", drm));
        assert(!ttfx_firmware_display("/dev/dri/card3", drm));
        assert(!ttfx_firmware_display("/dev/dri/card9", drm));
        assert(!ttfx_firmware_display("/dev/dri/card", drm));
        assert(!ttfx_firmware_display("/dev/dri/card0 ", drm));
        assert(!ttfx_firmware_display("/dev/dri/card0/../card0", drm));
        assert(!ttfx_firmware_display("/dev/dri/card-1", drm));
        assert(!ttfx_firmware_display("/dev/dri/card00000", drm));
        assert(!ttfx_firmware_display("/dev/dri/renderD128", drm));
        assert(!ttfx_firmware_display("/dev/fb0", drm));
        assert(!ttfx_firmware_display("dev/dri/card0", drm));
        assert(!ttfx_firmware_display("", drm));
        assert(!ttfx_firmware_display(NULL, drm));
        assert(!ttfx_firmware_display("/dev/dri/card0", NULL));
        assert(!ttfx_firmware_display("/dev/dri/card0", ""));
        assert(!ttfx_firmware_display("/dev/dri/card0", "/nonexistent/ttfx-sysfs-drm"));

        fixture_mkdir(root, "chosen-empty");
        fixture_mkdir(root, "chosen-empty/bootargs");
        fixture_mkdir(root, "chosen-empty/framebuffer");
        fixture_mkdir(root, "chosen");
        fixture_mkdir(root, "chosen/framebuffer@be2000000");
        fixture_path(path, sizeof(path), root, "chosen-empty");
        assert(!ttfx_devicetree_has_framebuffer(path));
        assert(!ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_AUTO, path));
        assert(ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_ON, path));
        fixture_path(path, sizeof(path), root, "chosen");
        assert(ttfx_devicetree_has_framebuffer(path));
        assert(ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_AUTO, path));
        assert(!ttfx_firmware_hold_resolve(TTFX_FIRMWARE_HOLD_OFF, path));

        /* Hidden notch: m1n1 crops a 3456x2234 panel to 16:10 and records the
         * 74 rows on a DCP node; dcpext nodes without the property are skipped. */
        char soc[PATH_MAX];
        fixture_mkdir(root, "notch");
        fixture_mkdir(root, "notch/framebuffer@103d1579c00");
        fixture_u32(root, "notch/framebuffer@103d1579c00/width", 3456U, 4U);
        fixture_u32(root, "notch/framebuffer@103d1579c00/height", 2160U, 4U);
        fixture_mkdir(root, "soc");
        fixture_mkdir(root, "soc/dcpext@315c00000");
        fixture_mkdir(root, "soc/dcp@389c00000");
        fixture_u32(root, "soc/dcp@389c00000/apple,notch-height", 74U, 4U);
        fixture_path(path, sizeof(path), root, "notch");
        fixture_path(soc, sizeof(soc), root, "soc");
        assert(ttfx_devicetree_hidden_notch(path, soc) == 74U);
        assert(ttfx_devicetree_hidden_notch(NULL, soc) == 0U);
        assert(ttfx_devicetree_hidden_notch(path, "") == 0U);
        assert(ttfx_devicetree_hidden_notch(path, "/nonexistent/ttfx-soc") == 0U);
        /* asahi,show-notch=1 keeps the full 3456x2234 framebuffer: nothing hidden. */
        fixture_mkdir(root, "shown");
        fixture_mkdir(root, "shown/framebuffer@103d1480000");
        fixture_u32(root, "shown/framebuffer@103d1480000/width", 3456U, 4U);
        fixture_u32(root, "shown/framebuffer@103d1480000/height", 2234U, 4U);
        fixture_path(path, sizeof(path), root, "shown");
        assert(ttfx_devicetree_hidden_notch(path, soc) == 0U);
        /* No size on the framebuffer, or a malformed property: nothing hidden. */
        fixture_path(path, sizeof(path), root, "chosen");
        assert(ttfx_devicetree_hidden_notch(path, soc) == 0U);
        fixture_mkdir(root, "short");
        fixture_mkdir(root, "short/framebuffer@1");
        fixture_u32(root, "short/framebuffer@1/width", 3456U, 3U);
        fixture_u32(root, "short/framebuffer@1/height", 2160U, 5U);
        fixture_path(path, sizeof(path), root, "short");
        assert(ttfx_devicetree_hidden_notch(path, soc) == 0U);

        assert(ttfx_firmware_mark_lift(74U, 2) == 19L);
        assert(ttfx_firmware_mark_lift(74U, 1) == 37L);
        assert(ttfx_firmware_mark_lift(74U, 0) == 37L);
        assert(ttfx_firmware_mark_lift(0U, 2) == 0L);
}

static void test_outro_parsing_and_pacing(void)
{
        assert(ttfx_outro_mode_parse(NULL));
        assert(ttfx_outro_mode_parse("reverse"));
        assert(ttfx_outro_mode_parse("Reverse"));
        assert(ttfx_outro_mode_parse(""));
        assert(!ttfx_outro_mode_parse("none"));
        assert(ttfx_outro_ms_parse(NULL) == TTFX_OUTRO_DEFAULT_MS);
        assert(ttfx_outro_ms_parse("") == TTFX_OUTRO_DEFAULT_MS);
        assert(ttfx_outro_ms_parse("-5") == TTFX_OUTRO_DEFAULT_MS);
        assert(ttfx_outro_ms_parse("7e2") == TTFX_OUTRO_DEFAULT_MS);
        assert(ttfx_outro_ms_parse("1234567890") == TTFX_OUTRO_DEFAULT_MS);
        assert(ttfx_outro_ms_parse("0") == TTFX_OUTRO_MIN_MS);
        assert(ttfx_outro_ms_parse("99") == TTFX_OUTRO_MIN_MS);
        assert(ttfx_outro_ms_parse("0450") == 450U);
        assert(ttfx_outro_ms_parse("1500") == 1500U);
        assert(ttfx_outro_ms_parse("999999999") == TTFX_OUTRO_MAX_MS);
        assert(ttfx_outro_max_calls(700U) == 168U);
        assert(ttfx_outro_max_calls(TTFX_OUTRO_MIN_MS) == 24U);
        assert(ttfx_outro_max_calls(TTFX_OUTRO_MAX_MS) == 360U);
        assert(ttfx_outro_max_calls(1U) == 1U);

        /* On-time ticks make exactly one call each; the last tick of the
         * budget reaches the final call. */
        uint32_t done = 0U;
        for (uint64_t tick = 1U; tick <= 168U; tick++) {
                uint32_t due = ttfx_outro_due_calls(tick * UINT64_C(4166667), 700U, 168U, done);
                assert(due == 1U);
                done += due;
        }
        assert(done == 168U);
        assert(ttfx_outro_due_calls(UINT64_C(800000000), 700U, 168U, done) == 0U);
        /* Late ticks catch up; a spent budget returns every remaining call. */
        assert(ttfx_outro_due_calls(UINT64_C(0), 700U, 168U, 0U) == 1U);
        assert(ttfx_outro_due_calls(UINT64_C(350000000), 700U, 168U, 10U) == 74U);
        assert(ttfx_outro_due_calls(UINT64_C(700000000), 700U, 168U, 10U) == 158U);
        assert(ttfx_outro_due_calls(UINT64_MAX, 700U, 168U, 167U) == 1U);
        assert(ttfx_outro_due_calls(UINT64_C(1000), 700U, 1U, 0U) == 1U);
}

int main(void)
{
        test_outro_parsing_and_pacing();
        test_firmware_hold_mode_parsing();
        test_firmware_display_detection_and_devicetree();
        test_tick_progresses_and_wraps();
        test_input_only_freezes_after_first_natural_completion();
        test_input_only_fast_forwards_when_success_precedes_completion();
        test_continuous_mode_preserves_current_looping_behavior();
        test_retry_returns_submit_to_finish_mode_to_input();
        test_submit_accelerates_to_final_for_verdict();
        test_failed_answer_mid_fast_forward_loops_after_final();
        test_empty_submit_does_not_accelerate();
        test_failed_nonempty_password_replacement_triggers_once();
        test_password_candidate_expires_to_normal();
        test_clear_prompt_never_arms_password_failure();
        test_password_failure_sequence_rejects_false_positives();
        test_reaction_visual_is_horizontal_bounded_red_and_finite();
        test_prompt_modes_and_bullets();
        test_active_prompt_state_is_owned_for_new_views();
        test_messages_restore_latest_still_active_message();
        test_duplicate_and_unknown_messages_are_safe();
        test_repeated_password_only_shows_on_hidden_transition();
        test_live_loop_detach_is_idempotent();
        test_widget_load_failure_rejects_graphical_splash();
        test_dynamic_view_failure_is_discarded_without_poisoning_splash();
        test_animation_unavailable_selects_static_only_mode();
        test_runtime_label_failure_degrades_without_hiding_prompt();
        test_geometry_is_centered_and_bounded();
        test_display_swap_offset_and_glide();
        test_multiple_views_keep_independent_geometry();
        test_compose_bottom_aligned_fills_top_rows_and_respects_stride();

        puts("state tests: PASS");
        return 0;
}
