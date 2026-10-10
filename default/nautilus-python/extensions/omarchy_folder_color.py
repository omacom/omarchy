import shutil

from gi import require_version

require_version("Nautilus", "4.1")

from gi.repository import Gio, GObject, Nautilus


# (internal color name passed to the CLI, label shown in the menu)
COLORS = [
    ("red", "Red"),
    ("orange", "Orange"),
    ("yellow", "Yellow"),
    ("olive", "Olive"),
    ("sage", "Sage"),
    ("green", "Green"),
    ("blue", "Blue"),
    ("purple", "Purple"),
    ("magenta", "Magenta"),
    ("brown", "Brown"),
]


class FolderColorAction(GObject.GObject, Nautilus.MenuProvider):
    def _binary(self):
        return shutil.which("omarchy-folder-color")

    def _run(self, args):
        binary = self._binary()
        if not binary:
            return
        Gio.Subprocess.new([binary, *args], Gio.SubprocessFlags.NONE)

    def _folder_paths(self, files):
        paths = []
        seen = set()
        for file in files:
            if file.get_uri_scheme() != "file" or not file.is_directory():
                continue
            location = file.get_location()
            if not location:
                continue
            path = location.get_path()
            if path and path not in seen:
                seen.add(path)
                paths.append(path)
        return paths

    def _build_menu(self, prefix, paths):
        top = Nautilus.MenuItem(
            name=f"{prefix}::top",
            label="Folder color",
            tip="Color this folder's icon",
            icon="folder",
        )
        submenu = Nautilus.Menu()
        top.set_submenu(submenu)

        for color, label in COLORS:
            item = Nautilus.MenuItem(name=f"{prefix}::{color}", label=label)
            item.connect("activate", self._on_set, paths, color)
            submenu.append_item(item)

        clear = Nautilus.MenuItem(name=f"{prefix}::clear", label="Remove color")
        clear.connect("activate", self._on_clear, paths)
        submenu.append_item(clear)

        return top

    def _on_set(self, _menu, paths, color):
        for path in paths:
            self._run(["set", path, color])

    def _on_clear(self, _menu, paths):
        for path in paths:
            self._run(["clear", path])

    def get_file_items(self, *args):
        if not self._binary():
            return []
        files = args[0] if len(args) == 1 else args[1]
        paths = self._folder_paths(files)
        if not paths:
            return []
        return [self._build_menu("OmarchyFolderColor", paths)]

    def get_background_items(self, *args):
        if not self._binary():
            return []
        folder = args[0] if len(args) == 1 else args[1]
        paths = self._folder_paths([folder])
        if not paths:
            return []
        return [self._build_menu("OmarchyFolderColorBackground", paths)]
