/* FS-UAE 3.2.35 Omarchy frame protocol v1. Linked into the private backend.
 * One immutable restore per owned process. stdout is the controller-owned log;
 * a fresh 128-bit token binds records to that launch, not a namespace PID.
 * This proves completed post-restore GL rendering, NOT scene/demo approval.
 */
#include <SDL.h>
#include <GL/gl.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void fsuae_probe_error(const char *);
void fsuae_probe_restore(const char *);
unsigned fsuae_probe_generation(void);
void fsuae_probe_uploaded(unsigned, int);
void fsuae_probe_rendered(int);
void fsuae_probe_swap(SDL_Window *);

static const char *token, *expected;
static atomic_uint generation;
static atomic_int failed;
static unsigned uploaded_generation;
static int uploaded_seq, rendered_seq, reported;

void fsuae_probe_error(const char *reason)
{
  if (token && !atomic_exchange(&failed, 1)) {
    printf("OMARCHY_FRAME_V1 %s error %s\n", token, reason);
    fflush(stdout);
  }
}

__attribute__((constructor)) static void frame_init(void)
{
  token = getenv("OMARCHY_FRAME_TOKEN");
  expected = getenv("OMARCHY_FRAME_STATE");
  if (!token) return; /* Ordinary emulator operation stays unchanged. */
  if (strlen(token) != 32 || strspn(token, "0123456789abcdef") != 32 || !expected)
    exit(74);
  printf("OMARCHY_FRAME_V1 %s protocol 1\n", token);
  fflush(stdout);
}

void fsuae_probe_restore(const char *path)
{
  if (!token || atomic_load(&failed)) return;
  if (strcmp(path, expected)) { fsuae_probe_error("unexpected-state"); return; }
  if (atomic_load(&generation)) { fsuae_probe_error("multiple-restores"); return; }
  /* Publish the record before permitting producer acquisition. */
  printf("OMARCHY_FRAME_V1 %s restored 1\n", token);
  fflush(stdout);
  atomic_store(&generation, 1);
}

unsigned fsuae_probe_generation(void)
{
  return atomic_load(&failed) ? 0 : atomic_load(&generation);
}

void fsuae_probe_uploaded(unsigned gen, int seq)
{
  uploaded_generation = gen;
  uploaded_seq = seq;
  rendered_seq = 0;
}

void fsuae_probe_rendered(int seq)
{
  rendered_seq = seq;
}

void fsuae_probe_swap(SDL_Window *window)
{
  int eligible = token && !reported && !atomic_load(&failed) &&
    atomic_load(&generation) == 1 && uploaded_generation == 1 &&
    uploaded_seq > 0 && rendered_seq == uploaded_seq;
  int w = 0, h = 0;
  uint64_t hash = UINT64_C(14695981039346656037);
  if (eligible) {
    SDL_GL_GetDrawableSize(window, &w, &h);
    if (w <= 0 || h <= 0 || w > 8192 || h > 8192 || glGetError() != GL_NO_ERROR) {
      fsuae_probe_error("render-gl-error");
    } else {
      size_t size = (size_t)w * h * 3;
      unsigned char *pixels = malloc(size);
      if (!pixels) fsuae_probe_error("allocation");
      else {
        GLint pack, buffer;
        glGetIntegerv(GL_PACK_ALIGNMENT, &pack);
        glGetIntegerv(GL_READ_BUFFER, &buffer);
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        glReadBuffer(GL_BACK);
        glFinish();
        glReadPixels(0, 0, w, h, GL_RGB, GL_UNSIGNED_BYTE, pixels);
        GLenum error = glGetError();
        glReadBuffer(buffer);
        glPixelStorei(GL_PACK_ALIGNMENT, pack);
        if (error != GL_NO_ERROR) fsuae_probe_error("readback-gl-error");
        else {
          for (size_t i = 0; i < size; i++) { hash ^= pixels[i]; hash *= UINT64_C(1099511628211); }
          /* Optional test artifact; failure must never authorize a frame. */
          const char *capture = getenv("OMARCHY_FRAME_CAPTURE");
          if (capture) {
            FILE *f = fopen(capture, "wbx");
            if (!f) fsuae_probe_error("capture-open");
            else {
              int ok = fprintf(f, "P6\n%d %d\n255\n", w, h) > 0;
              for (int y = h - 1; y >= 0; y--)
                if (fwrite(pixels + (size_t)y*w*3, 1, (size_t)w*3, f) != (size_t)w*3) ok = 0;
              if (fclose(f)) ok = 0;
              if (!ok) fsuae_probe_error("capture-write");
            }
          }
        }
        free(pixels);
      }
    }
  }
  /* No intervening upload or draw: swap precisely the buffer just read. */
  SDL_GL_SwapWindow(window);
  if (eligible && !atomic_load(&failed)) {
    glFinish();
    if (glGetError() != GL_NO_ERROR) fsuae_probe_error("swap-gl-error");
    else {
      printf("OMARCHY_FRAME_V1 %s frame 1 %d %d %d %016llx\n",
             token, uploaded_seq, w, h, (unsigned long long)hash);
      fflush(stdout);
      reported = 1;
    }
  }
  uploaded_generation = 0; /* A later swap cannot reuse this upload. */
}
