/* Hidden SDL/Wayland GL initialization, matching FS-UAE's desktop GL API. */
#include <SDL.h>
#include <SDL_opengl.h>
#include <stdio.h>

int main(void) {
  if (SDL_Init(SDL_INIT_VIDEO) != 0) {
    fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
    return 1;
  }
  SDL_Window *window = SDL_CreateWindow("Amiga GL probe", 0, 0, 32, 32,
    SDL_WINDOW_OPENGL | SDL_WINDOW_HIDDEN);
  SDL_GLContext context = window ? SDL_GL_CreateContext(window) : NULL;
  const GLubyte *renderer = context ? glGetString(GL_RENDERER) : NULL;
  if (renderer) {
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glFinish();
    if (glGetError() != GL_NO_ERROR) renderer = NULL;
  }
  if (renderer) printf("AMIGA_GL_RENDERER=%s\n", renderer);
  else fprintf(stderr, "GL initialization/readiness failed: %s\n", SDL_GetError());
  int result = renderer ? 0 : 1;
  if (context) SDL_GL_DeleteContext(context);
  if (window) SDL_DestroyWindow(window);
  SDL_Quit();
  return result;
}
