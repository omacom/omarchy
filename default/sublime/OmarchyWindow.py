import sublime
import sublime_plugin


class OmarchyWindowDefaults(sublime_plugin.EventListener):
    def on_new_window(self, window):
        previous = next((other for other in sublime.windows() if other != window), None)
        if previous:
            window.set_menu_visible(previous.is_menu_visible())
            window.set_minimap_visible(previous.is_minimap_visible())
        else:
            settings = sublime.load_settings('Preferences.sublime-settings')
            if settings.get('omarchy_hide_menu', True):
                window.set_menu_visible(False)
            if settings.get('omarchy_hide_minimap', True):
                window.set_minimap_visible(False)
