import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import time


with tempfile.TemporaryDirectory(prefix="omarchy-gtk-runtime-") as scratch:
    home = Path(scratch)
    config = home / ".config"
    gtk_dir = config / "gtk-4.0"
    runtime = home / "runtime"
    gtk_dir.mkdir(parents=True)
    runtime.mkdir(mode=0o700)
    os.environ.update(
        HOME=scratch,
        XDG_CONFIG_HOME=str(config),
        XDG_RUNTIME_DIR=str(runtime),
        GDK_BACKEND="broadway",
        BROADWAY_DISPLAY=":77",
        GTK_A11Y="none",
    )
    os.environ.pop("DISPLAY", None)
    os.environ.pop("WAYLAND_DISPLAY", None)
    server = subprocess.Popen(
        ["gtk4-broadwayd", "--unixsocket=" + str(home / "http.socket"), ":77"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    try:
        deadline = time.monotonic() + 5
        while not (runtime / "broadway78.socket").exists():
            if server.poll() is not None:
                raise RuntimeError(server.communicate()[0])
            if time.monotonic() >= deadline:
                raise RuntimeError("Private GTK display did not start")
            time.sleep(0.01)

        import gi

        gi.require_version("Gtk", "4.0")
        from gi.repository import Gio, GLib, Gtk

        # Use a symlinked user entrypoint importing a symlinked theme palette.
        dotfiles = home / "dotfiles"
        dotfiles.mkdir()
        target = dotfiles / "custom.css"
        css = gtk_dir / "gtk.css"
        css.symlink_to(target)
        palette_dir = home / "theme"
        palette_dir.mkdir()
        palette = palette_dir / "gtk.css"
        palette.write_text("@define-color omarchy_test_color #ff0000;\n")
        (gtk_dir / "omarchy.css").symlink_to(palette)
        target.write_text(f'@import url("{gtk_dir / "omarchy.css"}");\n')
        Gtk.init()
        source = Path(os.environ["ROOT"]) / "default/nautilus-python/extensions/omarchy_theme.py"
        spec = importlib.util.spec_from_file_location("omarchy_theme_test", source)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        extension = module.OmarchyThemeExtension()
        window = Gtk.Window()
        context = GLib.MainContext.default()

        def current_color():
            found, color = window.get_style_context().lookup_color("omarchy_test_color")
            assert found
            return color.to_string()

        def wait_for(predicate):
            deadline = time.monotonic() + 5
            while time.monotonic() < deadline:
                while context.pending():
                    context.iteration(False)
                if predicate():
                    return
                time.sleep(0.01)
            raise AssertionError("Timed out waiting for CSS reload")

        assert current_color() == "rgb(255,0,0)"

        # Stop monitoring to prove that this update is delivered by D-Bus alone.
        for monitor in extension._monitors:
            monitor.cancel()
        palette.write_text("@define-color omarchy_test_color #0000ff;\n")
        bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        bus.emit_signal(None, "/org/omarchy/Theme", "org.omarchy.Theme", "Changed", None)
        bus.flush_sync(None)
        wait_for(lambda: current_color() == "rgb(0,0,255)")

        # Both a direct target edit and an atomic editor save must trigger reload.
        palette.write_text("@define-color omarchy_test_color #00ff00;\n")
        wait_for(lambda: current_color() == "rgb(0,255,0)")
        replacement = dotfiles / "replacement.css"
        replacement.write_text("@define-color omarchy_test_color #00ffff;\n")
        replacement.replace(target)
        wait_for(lambda: current_color() == "rgb(0,255,255)")

        # Invalid replacement CSS leaves the last successfully loaded provider.
        target.write_text("button { color: definitely-not-a-color; }\n")
        previous = extension._provider
        wait_for(lambda: extension._reload_source != 0)
        wait_for(lambda: extension._reload_source == 0)
        assert extension._provider is previous
        assert current_color() == "rgb(0,255,255)"

        # A changed entrypoint target must rearm the monitors on the new directory.
        other_dir = home / "other-dotfiles"
        other_dir.mkdir()
        other_target = other_dir / "gtk.css"
        other_target.write_text("@define-color omarchy_test_color #ffff00;\n")
        replacement_link = gtk_dir / "next-gtk.css"
        replacement_link.symlink_to(other_target)
        replacement_link.replace(css)
        wait_for(lambda: current_color() == "rgb(255,255,0)")
        other_target.write_text("@define-color omarchy_test_color #ff00ff;\n")
        wait_for(lambda: current_color() == "rgb(255,0,255)")

        # Clearing removes only our provider; GTK's startup red stays until restart.
        css.unlink()
        wait_for(lambda: extension._provider is None)
        assert current_color() == "rgb(255,0,0)"
        assert extension._restart_notice_shown
        window.destroy()
        for monitor in extension._monitors:
            monitor.cancel()
    finally:
        server.terminate()
        server.communicate(timeout=5)
