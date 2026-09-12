# nautilus-swipe-navigation — two-finger swipe back/forward in GNOME Files
# Copyright (C) 2026  Kenny Keeton
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

from gi import require_version

require_version("Gtk", "4.0")
require_version("Gdk", "4.0")
require_version("Nautilus", "4.1")

from gi.repository import Gdk, GLib, GObject, Gtk, Nautilus

# Touchpad two-finger motion is a scroll, not a GtkGestureSwipe. Horizontal
# kinetic scrolls are treated as history navigation, matching Firefox/Epiphany.
# See https://gitlab.gnome.org/GNOME/nautilus/-/issues/845

_MIN_VELOCITY = 0.6  # px/ms, from GtkEventControllerScroll::decelerate
_MIN_DISTANCE = 80.0  # px of accumulated surface-unit delta
_HORIZONTAL_RATIO = 1.25
_COOLDOWN_MS = 350
_HOOK_RETRY_MS = 100

_hooked_app = None


class _GestureState:
    __slots__ = ("acc_x", "acc_y", "from_surface", "handled")

    def __init__(self):
        self.reset()

    def reset(self):
        self.acc_x = 0.0
        self.acc_y = 0.0
        self.from_surface = False
        self.handled = False


def _activate_slot_action(root, action_name):
    focus = root.get_focus() if hasattr(root, "get_focus") else None
    if focus is not None and focus.activate_action(action_name, None):
        return True

    slot = _find_named_widget(root, "NautilusWindowSlot")
    if slot is not None and slot.activate_action(action_name, None):
        return True

    return _activate_in_tree(root, action_name)


def _find_named_widget(widget, type_name):
    if widget is None:
        return None
    if widget.__gtype__.name == type_name:
        return widget
    child = widget.get_first_child()
    while child is not None:
        found = _find_named_widget(child, type_name)
        if found is not None:
            return found
        child = child.get_next_sibling()
    return None


def _activate_in_tree(widget, action_name):
    if widget is None:
        return False
    if widget.activate_action(action_name, None):
        return True
    child = widget.get_first_child()
    while child is not None:
        if _activate_in_tree(child, action_name):
            return True
        child = child.get_next_sibling()
    return False


class SwipeNavigation(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()
        self._controllers = []
        self._cooldown = False
        GLib.timeout_add(_HOOK_RETRY_MS, self._try_hook)

    def _try_hook(self):
        global _hooked_app

        app = Gtk.Application.get_default()
        if app is None:
            return True

        if _hooked_app is app:
            return False

        _hooked_app = app
        app.connect("window-added", self._on_window_added)
        for window in app.get_windows():
            self._on_window_added(app, window)
        return False

    def _on_window_added(self, _app, window):
        if getattr(window, "_nautilus_swipe_navigation", False):
            return

        state = _GestureState()
        flags = (
            Gtk.EventControllerScrollFlags.BOTH_AXES
            | Gtk.EventControllerScrollFlags.KINETIC
        )
        controller = Gtk.EventControllerScroll.new(flags)
        controller.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        controller.connect("scroll-begin", self._on_scroll_begin, state)
        controller.connect("scroll", self._on_scroll, state)
        controller.connect("decelerate", self._on_decelerate, window, state)
        controller.connect("scroll-end", self._on_scroll_end, window, state)

        window.add_controller(controller)
        window._nautilus_swipe_navigation = True
        self._controllers.append(controller)

    def _on_scroll_begin(self, _controller, state):
        state.reset()

    def _on_scroll(self, controller, dx, dy, state):
        # Touchpads/touchscreens report pixel (surface) deltas. Mouse wheels
        # use the wheel unit and must not trigger back/forward.
        if controller.get_unit() != Gdk.ScrollUnit.SURFACE:
            return False

        state.from_surface = True
        state.acc_x += dx
        state.acc_y += dy

        if (
            abs(state.acc_x) > abs(state.acc_y) * _HORIZONTAL_RATIO
            and abs(state.acc_x) > 40
        ):
            # Consume a committed horizontal swipe so the file view does not
            # also pan sideways.
            return True
        return False

    def _on_decelerate(self, _controller, vel_x, vel_y, window, state):
        self._maybe_navigate(window, state, vel_x, vel_y)

    def _on_scroll_end(self, _controller, window, state):
        self._maybe_navigate(window, state, 0.0, 0.0)

    def _maybe_navigate(self, window, state, vel_x, vel_y):
        if state.handled or self._cooldown or not state.from_surface:
            return

        abs_x = max(abs(state.acc_x), abs(vel_x) * 16)
        abs_y = max(abs(state.acc_y), abs(vel_y) * 16)
        strong_flick = abs(vel_x) >= _MIN_VELOCITY and abs(vel_x) > abs(vel_y) * _HORIZONTAL_RATIO
        long_swipe = abs(state.acc_x) >= _MIN_DISTANCE and abs(state.acc_x) > abs(state.acc_y) * _HORIZONTAL_RATIO

        if not strong_flick and not long_swipe:
            return
        if abs_x <= abs_y:
            return

        direction = state.acc_x if abs(state.acc_x) >= 1 else vel_x
        ltr = window.get_direction() != Gtk.TextDirection.RTL
        go_back = (direction < 0) if ltr else (direction > 0)
        action = "slot.back" if go_back else "slot.forward"

        if not _activate_slot_action(window, action):
            return

        state.handled = True
        self._cooldown = True
        GLib.timeout_add(_COOLDOWN_MS, self._clear_cooldown)

    def _clear_cooldown(self):
        self._cooldown = False
        return False

    def get_file_items(self, *args):
        return []

    def get_background_items(self, *args):
        return []
