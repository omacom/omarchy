#ifndef PLY_STUBS_H
#define PLY_STUBS_H

#include <stdbool.h>
#include <stdint.h>

typedef struct ply_event_loop ply_event_loop_t;
typedef struct ply_pixel_display ply_pixel_display_t;
typedef struct ply_pixel_buffer ply_pixel_buffer_t;
typedef struct ply_entry ply_entry_t;
typedef struct ply_label ply_label_t;
typedef struct _ply_image ply_image_t;
typedef struct ply_key_file ply_key_file_t;
typedef struct ply_buffer ply_buffer_t;
typedef struct ply_renderer ply_renderer_t;
typedef struct { unsigned int pulls; } ply_trigger_t;
void ply_trigger_pull(ply_trigger_t *, void *);
typedef int ply_boot_splash_mode_t;
enum { PLY_BOOT_SPLASH_MODE_BOOT_UP = 0, PLY_BOOT_SPLASH_MODE_SHUTDOWN = 1 };
typedef struct _ply_boot_splash_plugin ply_boot_splash_plugin_t;

typedef struct {
        long x;
        long y;
        unsigned long width;
        unsigned long height;
} ply_rectangle_t;

typedef void (*ply_event_loop_exit_handler_t)(void *, int, ply_event_loop_t *);
typedef void (*ply_event_loop_timeout_handler_t)(void *, ply_event_loop_t *);
typedef void (*ply_pixel_display_draw_handler_t)(void *, ply_pixel_buffer_t *, int, int, int, int,
                                                  ply_pixel_display_t *);

typedef struct {
        ply_boot_splash_plugin_t *(*create_plugin)(ply_key_file_t *);
        void (*destroy_plugin)(ply_boot_splash_plugin_t *);
        void (*add_pixel_display)(ply_boot_splash_plugin_t *, ply_pixel_display_t *);
        void (*remove_pixel_display)(ply_boot_splash_plugin_t *, ply_pixel_display_t *);
        bool (*show_splash_screen)(ply_boot_splash_plugin_t *, ply_event_loop_t *, ply_buffer_t *,
                                   ply_boot_splash_mode_t);
        void (*update_status)(ply_boot_splash_plugin_t *, const char *);
        void (*on_boot_progress)(ply_boot_splash_plugin_t *, double, double);
        void (*hide_splash_screen)(ply_boot_splash_plugin_t *, ply_event_loop_t *);
        void (*become_idle)(ply_boot_splash_plugin_t *, ply_trigger_t *);
        void (*display_normal)(ply_boot_splash_plugin_t *);
        void (*display_password)(ply_boot_splash_plugin_t *, const char *, int);
        void (*display_question)(ply_boot_splash_plugin_t *, const char *, const char *);
        void (*display_message)(ply_boot_splash_plugin_t *, const char *);
        void (*hide_message)(ply_boot_splash_plugin_t *, const char *);
} ply_boot_splash_plugin_interface_t;

enum { PLY_LABEL_ALIGN_CENTER = 0 };

char *ply_key_file_get_value(ply_key_file_t *, const char *, const char *);
void ply_event_loop_watch_for_exit(ply_event_loop_t *, ply_event_loop_exit_handler_t, void *);
void ply_event_loop_stop_watching_for_exit(ply_event_loop_t *, ply_event_loop_exit_handler_t, void *);
void ply_event_loop_watch_for_timeout(ply_event_loop_t *, double, ply_event_loop_timeout_handler_t, void *);
void ply_event_loop_stop_watching_for_timeout(ply_event_loop_t *, ply_event_loop_timeout_handler_t, void *);
unsigned long ply_pixel_display_get_width(ply_pixel_display_t *);
unsigned long ply_pixel_display_get_height(ply_pixel_display_t *);
void ply_pixel_display_set_draw_handler(ply_pixel_display_t *, ply_pixel_display_draw_handler_t, void *);
void ply_pixel_display_draw_area(ply_pixel_display_t *, int, int, int, int);
ply_renderer_t *ply_pixel_display_get_renderer(ply_pixel_display_t *);
const char *ply_renderer_get_device_name(ply_renderer_t *);
typedef enum { PLY_PIXEL_BUFFER_ROTATE_UPRIGHT = 0 } ply_pixel_buffer_rotation_t;
int ply_pixel_buffer_get_device_scale(ply_pixel_buffer_t *);
void ply_pixel_buffer_set_device_scale(ply_pixel_buffer_t *, int);
ply_pixel_buffer_rotation_t ply_pixel_buffer_get_device_rotation(ply_pixel_buffer_t *);
unsigned long ply_pixel_buffer_get_width(ply_pixel_buffer_t *);
unsigned long ply_pixel_buffer_get_height(ply_pixel_buffer_t *);
uint32_t *ply_pixel_buffer_get_argb32_data(ply_pixel_buffer_t *);
void ply_pixel_buffer_push_clip_area(ply_pixel_buffer_t *, ply_rectangle_t *);
void ply_pixel_buffer_pop_clip_area(ply_pixel_buffer_t *);
void ply_pixel_buffer_fill_with_hex_color(ply_pixel_buffer_t *, ply_rectangle_t *, uint32_t);
void ply_pixel_buffer_fill_with_hex_color_at_opacity(ply_pixel_buffer_t *, ply_rectangle_t *, uint32_t, double);
void ply_pixel_buffer_fill_with_buffer(ply_pixel_buffer_t *, ply_pixel_buffer_t *, int, int);
void ply_pixel_buffer_fill_with_buffer_at_opacity(ply_pixel_buffer_t *, ply_pixel_buffer_t *, int, int, float);
ply_image_t *ply_image_new(const char *);
void ply_image_free(ply_image_t *);
bool ply_image_load(ply_image_t *);
long ply_image_get_width(ply_image_t *);
long ply_image_get_height(ply_image_t *);
ply_image_t *ply_image_resize(ply_image_t *, long, long);
ply_pixel_buffer_t *ply_image_get_buffer(ply_image_t *);
ply_entry_t *ply_entry_new(const char *);
void ply_entry_free(ply_entry_t *);
bool ply_entry_load(ply_entry_t *);
long ply_entry_get_width(ply_entry_t *);
long ply_entry_get_height(ply_entry_t *);
void ply_entry_set_text(ply_entry_t *, const char *);
void ply_entry_set_bullet_count(ply_entry_t *, int);
void ply_entry_show(ply_entry_t *, ply_event_loop_t *, ply_pixel_display_t *, long, long);
void ply_entry_hide(ply_entry_t *);
void ply_entry_draw_area(ply_entry_t *, ply_pixel_buffer_t *, int, int, unsigned long, unsigned long);
ply_label_t *ply_label_new(void);
void ply_label_free(ply_label_t *);
void ply_label_set_font(ply_label_t *, const char *);
void ply_label_set_hex_color(ply_label_t *, uint32_t);
void ply_label_set_text(ply_label_t *, const char *);
void ply_label_set_alignment(ply_label_t *, int);
void ply_label_set_width(ply_label_t *, long);
bool ply_label_show(ply_label_t *, ply_pixel_display_t *, long, long);
void ply_label_hide(ply_label_t *);
void ply_label_draw_area(ply_label_t *, ply_pixel_buffer_t *, int, int, unsigned long, unsigned long);

#endif
