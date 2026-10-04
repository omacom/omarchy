import sublime
import sublime_plugin


def set_window_defaults(window):
    window.set_menu_visible(False)
    window.set_minimap_visible(False)


def plugin_loaded():
    for window in sublime.windows():
        set_window_defaults(window)


class OmarchyWindowDefaults(sublime_plugin.EventListener):
    def on_new_window(self, window):
        set_window_defaults(window)
