/* Compile against the actual patched source, not a model of its row copying.
 * Single-threaded unit fixture; only the mutex transport is stubbed. */
#include <assert.h>
#include "libfsemu/src/emu/video_buffer.c"

static unsigned test_generation;
unsigned fsuae_probe_generation(void) { return test_generation; }
fs_mutex *fs_mutex_create(void) { return (fs_mutex *)1; }
int fs_mutex_lock(fs_mutex *mutex) { (void)mutex; return 0; }
int fs_mutex_unlock(fs_mutex *mutex) { (void)mutex; return 0; }
int g_fs_emu_video_bpp = 4;

int main(void)
{
  fs_emu_video_buffer_init(4, 4, 4);
  fs_emu_video_buffer *old = fs_emu_video_buffer_get_available(0);
  memset(old->data, 0x55, old->size);
  fs_emu_video_buffer_update_lines(old);
  g_video_buffer_current = old;
  assert(old->probe_generation == 0);
  test_generation = 1;
  fs_emu_video_buffer *fresh = fs_emu_video_buffer_get_available(0);
  assert(fresh->probe_generation == 1);
  memset(fresh->data, 0xaa, fresh->size);
  fresh->line[1] = 1; /* One unchanged row is copied from pre-restore pixels. */
  fs_emu_video_buffer_update_lines(fresh);
  assert(((unsigned char *)fresh->data)[16] == 0x55);
  assert(fresh->probe_rows[0] == 1);
  assert(fresh->probe_rows[1] == 0); /* Must not inherit acquisition generation. */
  g_video_buffer_current = fresh;
  fs_emu_video_buffer *next = fs_emu_video_buffer_get_available(0);
  memset(next->line, 1, 4);
  next->line[1] = 0; /* Only now redraw the previously stale row. */
  fs_emu_video_buffer_update_lines(next);
  for (int y = 0; y < 4; y++) assert(next->probe_rows[y] == 1);
  puts("actual producer rows: stale-copy rejected; later complete provenance accepted");
  return 0;
}
