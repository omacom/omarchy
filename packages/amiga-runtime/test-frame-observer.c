/* Native offscreen observer regression: genuine GL, controlled producer events.
 * Not an emulator/demo compatibility test. Built with frame-observer.c. */
#include <SDL.h>
#include <GL/gl.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

void fsuae_probe_restore(const char *);
unsigned fsuae_probe_generation(void);
void fsuae_probe_uploaded(unsigned, int);
void fsuae_probe_rendered(int);
void fsuae_probe_swap(SDL_Window *);

int main(void)
{
  assert(SDL_Init(SDL_INIT_VIDEO) == 0);
  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  SDL_Window *window = SDL_CreateWindow("observer-test", 0, 0, 64, 48, SDL_WINDOW_OPENGL | SDL_WINDOW_HIDDEN);
  assert(window);
  SDL_GLContext context = SDL_GL_CreateContext(window);
  assert(context);
  glClearColor(.1f, .2f, .3f, 1);
  glClear(GL_COLOR_BUFFER_BIT);
  unsigned stale = fsuae_probe_generation();
  assert(stale == 0);
  fsuae_probe_restore(getenv("OMARCHY_FRAME_STATE"));
  assert(fsuae_probe_generation() == 1);
  /* Queued pixels were acquired before restore, even though uploaded/drawn later. */
  fsuae_probe_uploaded(stale, 10);
  fsuae_probe_rendered(10);
  fsuae_probe_swap(window);
  puts("CHECKPOINT stale-rejected");
  /* A fresh acquisition without its corresponding completed draw is insufficient. */
  fsuae_probe_uploaded(1, 11);
  fsuae_probe_rendered(10);
  fsuae_probe_swap(window);
  puts("CHECKPOINT incomplete-draw-rejected");
  glClear(GL_COLOR_BUFFER_BIT);
  fsuae_probe_uploaded(1, 12);
  fsuae_probe_rendered(12);
  fsuae_probe_swap(window);
  puts("CHECKPOINT fresh-completed");
  SDL_GL_DeleteContext(context);
  SDL_DestroyWindow(window);
  SDL_Quit();
  return 0;
}
