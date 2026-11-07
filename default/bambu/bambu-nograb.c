#define _GNU_SOURCE
#include <dlfcn.h>
#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Bambu Studio shows a parameter card as a wxPopupTransientWindow.
   On GTK that grabs the pointer, and shaping the card can stall the UI
   thread in poll (cairo_stroke -> XRenderCompositeTrapezoids). Both are
   fixed upstream by bambulab/BambuStudio#12262 (commit da8b44e, not in any
   Linux build yet). Drop this shim when a released Studio includes it.

   A popup opened by a click or key keeps its grab and its shape, so menus
   still work. A hover card is shown from a timer and has no such event. */

__attribute__((constructor)) static void nograb_init(void)
{
    char exe[4096];
    ssize_t n = readlink("/proc/self/exe", exe, sizeof exe - 1);
    if (n <= 0)
        return;
    exe[n] = 0;
    const char *base = strrchr(exe, '/');
    if (base && strcmp(base + 1, "bambu-studio") == 0)
        unsetenv("LD_PRELOAD");
}

static int from_bambu(void *caller)
{
    Dl_info info;
    if (!dladdr(caller, &info) || !info.dli_fname)
        return 0;
    const char *base = strrchr(info.dli_fname, '/');
    return strcmp(base ? base + 1 : info.dli_fname, "bambu-studio") == 0;
}

static int opened_by_click_or_key(void)
{
    GdkEvent *ev = gtk_get_current_event();
    if (!ev)
        return 0;
    GdkEventType t = ev->type;
    gdk_event_free(ev);
    switch (t) {
    case GDK_BUTTON_PRESS:
    case GDK_2BUTTON_PRESS:
    case GDK_3BUTTON_PRESS:
    case GDK_BUTTON_RELEASE:
    case GDK_KEY_PRESS:
    case GDK_KEY_RELEASE:
        return 1;
    default:
        return 0;
    }
}

static int is_popup(GtkWidget *widget)
{
    return widget && GTK_IS_WINDOW(widget) &&
           gtk_window_get_window_type(GTK_WINDOW(widget)) == GTK_WINDOW_POPUP;
}

/* Click and key popups must keep the grab. Hover and timer popups must not. */
static int should_skip_grab(GtkWidget *widget, void *caller)
{
    if (!is_popup(widget) || !from_bambu(caller))
        return 0;
    if (opened_by_click_or_key())
        return 0;
    return 1;
}

/* Same cards also call SetShape. Skip that for a hover popup. A real
   toplevel keeps its shape. A NULL widget here is the gdk path, called
   before the window's user data is set; a click-opened popup still has
   an event and is left alone above. */
static int should_skip_shape(GtkWidget *widget, void *caller)
{
    if (!from_bambu(caller) || opened_by_click_or_key())
        return 0;
    if (widget && !is_popup(widget))
        return 0;
    return 1;
}

void gtk_grab_add(GtkWidget *widget)
{
    static void (*real)(GtkWidget *);
    if (!real)
        real = (void (*)(GtkWidget *))dlsym(RTLD_NEXT, "gtk_grab_add");

    if (should_skip_grab(widget, __builtin_return_address(0)))
        return;
    real(widget);
}

GdkGrabStatus gdk_device_grab(GdkDevice *device, GdkWindow *window, GdkGrabOwnership ownership,
                              gboolean owner_events, GdkEventMask mask, GdkCursor *cursor, guint32 time_)
{
    static GdkGrabStatus (*real)(GdkDevice *, GdkWindow *, GdkGrabOwnership, gboolean, GdkEventMask,
                                 GdkCursor *, guint32);
    if (!real)
        real = dlsym(RTLD_NEXT, "gdk_device_grab");

    gpointer widget = NULL;
    if (window)
        gdk_window_get_user_data(window, &widget);
    if (should_skip_grab(widget, __builtin_return_address(0)))
        return GDK_GRAB_SUCCESS;
    return real(device, window, ownership, owner_events, mask, cursor, time_);
}

GdkGrabStatus gdk_seat_grab(GdkSeat *seat, GdkWindow *window, GdkSeatCapabilities caps,
                            gboolean owner_events, GdkCursor *cursor, const GdkEvent *event,
                            GdkSeatGrabPrepareFunc prepare, gpointer data)
{
    static GdkGrabStatus (*real)(GdkSeat *, GdkWindow *, GdkSeatCapabilities, gboolean, GdkCursor *,
                                 const GdkEvent *, GdkSeatGrabPrepareFunc, gpointer);
    if (!real)
        real = dlsym(RTLD_NEXT, "gdk_seat_grab");

    gpointer widget = NULL;
    if (window)
        gdk_window_get_user_data(window, &widget);
    if (should_skip_grab(widget, __builtin_return_address(0)))
        return GDK_GRAB_SUCCESS;
    return real(seat, window, caps, owner_events, cursor, event, prepare, data);
}

void gtk_widget_shape_combine_region(GtkWidget *widget, cairo_region_t *region)
{
    static void (*real)(GtkWidget *, cairo_region_t *);
    if (!real)
        real = (void (*)(GtkWidget *, cairo_region_t *))dlsym(RTLD_NEXT, "gtk_widget_shape_combine_region");

    if (region && should_skip_shape(widget, __builtin_return_address(0)))
        return;
    real(widget, region);
}

void gdk_window_shape_combine_region(GdkWindow *window, const cairo_region_t *shape_region,
                                     gint offset_x, gint offset_y)
{
    static void (*real)(GdkWindow *, const cairo_region_t *, gint, gint);
    if (!real)
        real = (void (*)(GdkWindow *, const cairo_region_t *, gint, gint))dlsym(
            RTLD_NEXT, "gdk_window_shape_combine_region");

    gpointer widget = NULL;
    if (window)
        gdk_window_get_user_data(window, &widget);
    if (shape_region && should_skip_shape(widget, __builtin_return_address(0)))
        return;
    real(window, shape_region, offset_x, offset_y);
}
