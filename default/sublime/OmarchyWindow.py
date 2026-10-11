import sublime
import sublime_plugin

# Hide the menu and minimap once after install; Sublime keeps the user's
# later choices in its own session state.
STATE = 'Omarchy.sublime-settings'


def apply_window_defaults():
    state = sublime.load_settings(STATE)
    windows = sublime.windows()
    if state.get('window_defaults_applied') or not windows:
        return
    for window in windows:
        window.set_menu_visible(False)
        window.set_minimap_visible(False)
    state.set('window_defaults_applied', True)
    sublime.save_settings(STATE)


def plugin_loaded():
    apply_window_defaults()


class OmarchyWindowDefaults(sublime_plugin.EventListener):
    def on_new_window(self, window):
        apply_window_defaults()
