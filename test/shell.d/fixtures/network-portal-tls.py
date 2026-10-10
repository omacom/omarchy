"""Exercise the real portal with inert GTK/WebKit objects; no network or GUI.

TLS outcomes are injected at WebKit's documented signal boundary. These tests
verify application actions, not WebKit's certificate verifier or GTK lifetime
semantics. See docs/network-portal-security.md for backend evidence and gaps.
"""

import ast
import json
import os
from pathlib import Path
import runpy
import sys
from types import ModuleType, SimpleNamespace
import unittest
from unittest.mock import Mock, patch


SOURCE = Path(sys.argv.pop(1))


class Widget:
  def __init__(self, **kwargs):
    self.text = kwargs.get("label", "")
    self.signals = {}
    self.children = []
    self.destroyed = False

  def __getattr__(self, name):
    # Inert rendering operations (CSS, size, margin, etc.).
    return Mock(name=name)

  def connect(self, signal, callback):
    self.signals[signal] = callback

  def emit(self, signal, *args):
    if signal in self.signals:
      return self.signals[signal](self, *args)
    return False

  def pack_start(self, widget, *_args):
    self.children.append(widget)

  add_named = pack_start

  def remove(self, child):
    self.children.remove(child)

  def set_visible_child(self, child):
    self.visible_child = child

  def get_visible_child(self):
    return self.visible_child

  pack_end = pack_start
  add = pack_start

  def get_child(self):
    return self.children[0]

  def set_text(self, text):
    self.text = text

  def destroy(self):
    self.destroyed = True
    self.emit("destroy")


class View(Widget):
  def __init__(self, **kwargs):
    super().__init__()
    self.context = kwargs["related_view"].context if "related_view" in kwargs else kwargs["web_context"]
    self.settings = Mock()
    self.load_uri = Mock()
    self.reload = Mock()
    self.uri = None

  def get_context(self):
    return self.context

  def get_settings(self):
    return self.settings

  def get_uri(self):
    return self.uri

  def tls_failure(self, uri, flags):
    certificate = object()
    handled = self.emit("load-failed-with-tls-errors", uri, certificate, flags)
    # WebKit FAIL policy: unhandled TLS errors also emit load-failed; either
    # signal's return value only controls notification, not certificate trust.
    if not handled:
      self.emit("load-failed", "started", uri,
                SimpleNamespace(message="TLS certificate validation failed"))
    self.emit("load-changed", "finished")

  def commit(self, uri):
    # The backend has already authorized this response, or it is plain HTTP.
    self.uri = uri
    self.emit("load-changed", "committed")
    self.emit("load-changed", "finished")


class PortalTLS(unittest.TestCase):
  def setUp(self):
    self.gtk = Mock()
    self.buttons = []

    def button(**kwargs):
      widget = Widget(**kwargs)
      self.buttons.append(widget)
      return widget

    self.gtk.Window.side_effect = Widget
    self.gtk.Box.side_effect = Widget
    self.gtk.Stack.side_effect = Widget
    self.gtk.Label.side_effect = Widget
    self.gtk.Button.side_effect = button
    self.webkit = Mock()
    self.webkit.WebView.side_effect = View
    self.webkit.LoadEvent.COMMITTED = "committed"
    self.webkit.WebContext.new_ephemeral.side_effect = lambda: Mock(name="private context")
    self.gdk = SimpleNamespace(KEY_Escape=27, KEY_F5=65474, KEY_r=114,
                               ModifierType=SimpleNamespace(CONTROL_MASK=4),
                               Screen=Mock())
    gi = ModuleType("gi")
    gi.require_version = Mock()
    repository = ModuleType("gi.repository")
    for name, value in (("Gtk", self.gtk), ("Gdk", self.gdk),
                        ("WebKit2", self.webkit), ("GLib", Mock()),
                        ("GtkLayerShell", Mock())):
      setattr(repository, name, value)
    gi.repository = repository

    # Neither module startup nor any retained callback may escape the fixture.
    self.run = self.enterContext(patch("subprocess.run", return_value=
      SimpleNamespace(returncode=1, stdout="", stderr="")))
    self.popen = self.enterContext(patch("subprocess.Popen"))
    for name in ("execv", "execvp", "execvpe"):
      self.enterContext(patch("os." + name, side_effect=AssertionError("unexpected exec")))
    self.enterContext(patch.dict(sys.modules, {"gi": gi, "gi.repository": repository}))
    self.enterContext(patch.dict(os.environ, {"OMARCHY_PORTAL_PRELOADED": "1"}))
    self.enterContext(patch.object(sys, "argv", [str(SOURCE)]))
    self.module = runpy.run_path(str(SOURCE), run_name="portal_test")
    self.portal = self.module["Portal"](self.module["DEFAULT_URL"], "Test network", 0)
    self.view = self.portal.view
    self.context = self.view.get_context()

  def assert_no_bypass(self):
    self.context.allow_tls_certificate_for_host.assert_not_called()
    self.context.set_tls_errors_policy.assert_not_called()
    self.context.get_website_data_manager.return_value.set_tls_errors_policy.assert_not_called()
    self.assertNotIn("pending_certificate", vars(self.portal))
    self.assertNotIn("trust_prompt", vars(self.portal))
    self.assertFalse(hasattr(type(self.portal), "accept_certificate"))
    self.assertEqual([b.text for b in self.buttons], ["×", "Open in browser"])
    self.popen.assert_not_called()

  def test_consecutive_hosts_have_no_acceptance_action(self):
    initial_requests = list(self.view.load_uri.call_args_list)
    for host in ("gateway-a.example", "gateway-b.example", "gateway-a.example"):
      self.view.tls_failure("https://" + host + "/login", 1)
      self.assertIn(host, self.portal.footer.text)
      self.assertIn("TLS certificate validation failed", self.portal.footer.text)
      self.assert_no_bypass()
    self.assertEqual(self.view.load_uri.call_args_list, initial_requests)

  def test_every_tls_error_combination_cannot_trigger_application_bypass(self):
    # UNKNOWN_CA, BAD_IDENTITY, NOT_ACTIVATED, EXPIRED, REVOKED, INSECURE,
    # GENERIC_ERROR, all combinations, and a future flag. A TLS-failure event
    # with incomplete/empty diagnostics must not authorize anything either.
    for flags in [*range(128), 1 << 20]:
      with self.subTest(flags=flags):
        self.view.load_uri.reset_mock()
        self.view.tls_failure("https://invalid.example/login", flags)
        self.assert_no_bypass()
        self.view.load_uri.assert_not_called()
        self.view.reload.assert_not_called()
        self.assertIn("TLS certificate validation failed", self.portal.footer.text)

  def test_repeated_keyboard_actions_only_retry_with_platform_validation(self):
    for key, state in ((65474, 0), (114, 4), (65474, 0)):
      self.view.tls_failure("https://invalid.example/login", 1 | 2 | 8)
      self.view.load_uri.reset_mock()
      self.view.reload.reset_mock()
      self.assertTrue(self.portal.window.emit("key-press-event",
        SimpleNamespace(keyval=key, state=state)))
      self.view.reload.assert_called_once_with()
      self.view.load_uri.assert_not_called()
      self.assert_no_bypass()

  def test_cancellation_and_late_failure_callbacks_cannot_authorize(self):
    callback = self.view.signals["load-failed"]
    self.view.tls_failure("https://gateway-a.example/login", 1)
    self.portal.window.emit("key-press-event", SimpleNamespace(keyval=27, state=0))
    self.buttons[0].emit("clicked")
    self.portal.window.destroy()
    self.assertTrue(self.portal.window.destroyed)
    self.gtk.main_quit.assert_called()
    self.view.load_uri.reset_mock()
    # Directly replay retained callbacks, even after teardown, without relying
    # on GTK disconnecting signals or the main loop having already stopped.
    for uri in ("https://gateway-b.example/", "https://gateway-a.example/"):
      callback(self.view, "started", uri, SimpleNamespace(message="Cancelled"))
      self.view.tls_failure(uri, 2 | 8)
      self.assert_no_bypass()
    self.view.load_uri.assert_not_called()
    self.view.reload.assert_not_called()

  def test_http_discovery_and_valid_https_responses_reach_the_view(self):
    self.view.load_uri.assert_called_once_with(self.module["DEFAULT_URL"])
    self.assertTrue(self.module["DEFAULT_URL"].startswith("http://"))
    self.view.tls_failure("https://invalid.example/login", 1)
    for uri in ("http://gateway.example/login", "https://login.example/signin"):
      self.view.commit(uri)
      self.assertEqual(self.portal.address.text, uri)
      self.assertEqual(self.portal.footer.text, "Esc closes. Private browsing session.")
      self.assert_no_bypass()
    # Direct HTTPS invocation is preserved, not rewritten to the HTTP probe.
    self.buttons.clear()
    portal = self.module["Portal"]("https://login.example/signin", "Test", 0)
    portal.view.load_uri.assert_called_once_with("https://login.example/signin")

  def test_redirect_tls_failure_never_loads_an_http_fallback(self):
    self.view.commit("http://gateway.example/login")
    for uri in ("https://gateway-a.example/login", "https://gateway-b.example/login"):
      self.view.emit("load-changed", "redirected")
      self.view.tls_failure(uri, 1 | 2)
      self.assertEqual(self.portal.address.text, "http://gateway.example/login")
      self.assert_no_bypass()
    self.view.load_uri.assert_called_once_with(self.module["DEFAULT_URL"])
    self.view.reload.assert_not_called()

  def test_browser_handoff_is_explicit_and_resolves_the_live_probe(self):
    self.view.tls_failure("https://invalid.example/private", 1)
    self.assert_no_bypass()
    self.run.return_value = SimpleNamespace(returncode=0,
      stdout=json.dumps({"type": "s", "data": "http://configured.test/check"}))
    self.buttons[1].emit("clicked")
    self.popen.assert_called_once()
    args, kwargs = self.popen.call_args
    self.assertEqual(args, (["omarchy-launch-browser", "--new-window",
                            "http://configured.test/check"],))
    self.assertTrue(kwargs["start_new_session"])
    self.assertNotIn("OMARCHY_PORTAL_PRELOADED", kwargs["env"])
    self.assertNotIn(self.module["LAYER_SHELL_LIB"], kwargs["env"].get("LD_PRELOAD", ""))
    self.context.allow_tls_certificate_for_host.assert_not_called()

  def test_probe_uses_live_daemon_and_rejects_unsafe_or_hsts_urls(self):
    fallback = "http://neverssl.com/"
    for value, expected in (
      ("http://configured.test/check?value=one", "http://configured.test/check?value=one"),
      ("HTTP://configured.test/check", "http://configured.test/check"),
      ("http://192.0.2.1/login", "http://192.0.2.1/login"),
      ("http://[2001:db8::1]/check", "http://[2001:db8::1]/check"),
      ("http://ping.archlinux.org/nm-check.txt", fallback),
      ("http://ARCHLINUX.ORG.:80/check", fallback),
      ("http://nmcheck.gnome.org/check_network_status.txt", fallback),
      ("https://configured.test/check", fallback),
      ("http://user:secret@configured.test/check", fallback),
      ("http://configured.test\\@other.test/", fallback),
      ("http://configured.test/\ncheck", fallback),
      ("http://%61rchlinux.org/check", fallback),
      ("http://configured.test:invalid/check", fallback),
      ("http:///check", fallback),
      ("file:///etc/passwd", fallback),
      ("", fallback),
    ):
      with self.subTest(value=value):
        self.run.return_value = SimpleNamespace(returncode=0,
          stdout=json.dumps({"type": "s", "data": value}))
        self.assertEqual(self.module["discovery_url"](), expected)
        args = self.run.call_args.args[0]
        self.assertIn("ConnectivityCheckUri", args)
        self.assertNotIn("--print-config", args)
        self.assertEqual(args[0], "busctl")
    for output in ("", "not json", '{"type":"s","data":[]}', '{}'):
      self.run.return_value = SimpleNamespace(returncode=0, stdout=output)
      self.assertEqual(self.module["discovery_url"](), fallback)
    self.run.side_effect = OSError("daemon unavailable")
    self.assertEqual(self.module["discovery_url"](), fallback)

  def test_auto_close_checks_only_the_portal_device(self):
    self.portal.interface = "test-wifi"
    def query(args, **kwargs):
      if "GetDeviceByIpIface" in args:
        self.assertEqual(args[-1], "test-wifi")
        return SimpleNamespace(returncode=0, stdout='{"type":"o","data":["/org/freedesktop/NetworkManager/Devices/7"]}')
      self.assertIn("/org/freedesktop/NetworkManager/Devices/7", args)
      self.assertNotIn("general", args)
      return SimpleNamespace(returncode=0, stdout='{"type":"u","data":2}\n{"type":"u","data":1}')
    self.run.side_effect = query
    self.assertTrue(self.portal.close_once_online())
    self.assertNotEqual(self.portal.footer.text, "Signed in.")
    self.run.side_effect = [
      SimpleNamespace(returncode=0, stdout='{"type":"o","data":["/org/freedesktop/NetworkManager/Devices/7"]}'),
      SimpleNamespace(returncode=0, stdout='{"type":"u","data":4}\n{"type":"u","data":1}')]
    self.assertFalse(self.portal.close_once_online())
    self.assertEqual(self.portal.footer.text, "Signed in.")
    self.portal.interface = ""
    self.run.reset_mock()
    self.assertFalse(self.portal.close_once_online())
    self.run.assert_not_called()

  def test_popup_uses_related_private_view_and_cannot_bypass_tls(self):
    child = self.view.emit("create", SimpleNamespace(is_user_gesture=lambda: True))
    self.assertIsInstance(child, View)
    self.assertIs(child.context, self.context)
    child.emit("ready-to-show")
    self.assertIs(self.portal.view, child)
    self.assertIs(self.portal.view_stack.get_visible_child(), child)
    child.tls_failure("https://bad-popup.example/", 1 | 2 | 8)
    self.assert_no_bypass()
    child.load_uri.assert_not_called()
    child.emit("close")
    self.assertIs(self.portal.view, self.view)
    child.emit("close")
    child.emit("ready-to-show")
    self.assertIsNone(child.emit("create", SimpleNamespace(is_user_gesture=lambda: True)))
    self.assertIs(self.portal.view, self.view)
    self.assertEqual(self.portal.footer.text, "Esc closes. Private browsing session.")
    self.assertIsNone(self.view.emit("create", SimpleNamespace(is_user_gesture=lambda: False)))

  def test_missing_gui_dependency_uses_browser_without_installing(self):
    gi = sys.modules["gi"]
    gi.require_version.side_effect = ValueError("GtkLayerShell unavailable")
    with self.assertRaises(SystemExit):
      runpy.run_path(str(SOURCE), run_name="missing_dependency_test")
    self.popen.assert_called_once()
    self.assertEqual(self.popen.call_args.args[0],
      ["omarchy-launch-browser", "--new-window", "http://neverssl.com/"])
    self.assertTrue(self.popen.call_args.kwargs["start_new_session"])
    self.assertNotIn("OMARCHY_PORTAL_PRELOADED", self.popen.call_args.kwargs["env"])
    self.assertTrue(all(c.args[0][0] in ("busctl", "omarchy-toggle-enabled", "omarchy-version", "omarchy-theme-color")
                        for c in self.run.call_args_list))

  def test_placement_tracks_each_bar_edge_and_stays_on_screen(self):
    bounds = self.module["portal_bounds"]
    cases = (
      ("top", [900, 32, 380, 600]),
      ("bottom", [900, 136, 380, 600]),
      ("left", [32, 100, 380, 600]),
      ("right", [954, 100, 380, 600]),
    )
    for edge, card in cases:
      with self.subTest(edge=edge):
        x, y, width, height = bounds(1366, 768, card, edge)
        self.assertGreaterEqual(x, 0)
        self.assertGreaterEqual(y, 0)
        self.assertLessEqual(x + width, 1366)
        self.assertLessEqual(y + height, 768)
        self.assertTrue(x + width <= card[0] or x >= card[0] + card[2])
        if edge == "left":
          self.assertGreater(x, card[0])
        if edge == "bottom":
          self.assertEqual(y + height, card[1] + card[3])
    for screen in ((400, 720), (800, 480)):
      x, y, width, height = bounds(*screen, [4, 4, 380, 400], "top")
      self.assertTrue(0 <= x <= screen[0] - width)
      self.assertTrue(0 <= y <= screen[1] - height)

  def test_placement_uses_the_originating_monitor_and_actual_card(self):
    other = Mock()
    other.get_geometry.return_value = SimpleNamespace(x=0, y=0, width=1920, height=1080)
    origin = Mock()
    origin.get_geometry.return_value = SimpleNamespace(x=-1366, y=0, width=1366, height=768)
    self.gdk.Display = Mock()
    display = self.gdk.Display.get_default.return_value
    display.get_n_monitors.return_value = 2
    display.get_monitor.side_effect = lambda index: [other, origin][index]
    layer = self.module["GtkLayerShell"]
    layer.reset_mock()
    self.portal.place({"screen": [-1366, 0, 1366, 768],
                       "card": [32, 100, 380, 600], "edge": "left"})
    layer.set_monitor.assert_called_once_with(self.portal.window, origin)
    layer.set_exclusive_zone.assert_called_once_with(self.portal.window, -1)
    layer.set_margin.assert_any_call(self.portal.window, layer.Edge.LEFT, 416)
    layer.set_margin.assert_any_call(self.portal.window, layer.Edge.TOP, 44)

  def test_browser_preference_launches_before_gui_dependencies(self):
    gi = sys.modules["gi"]
    gi.require_version.reset_mock()
    def command(args, **kwargs):
      return SimpleNamespace(returncode=0,
        stdout='{"type":"s","data":"http://configured.test/discover"}')
    self.run.side_effect = command
    with self.assertRaises(SystemExit) as exit_status:
      runpy.run_path(str(SOURCE), run_name="browser_preference_test")
    self.assertEqual(exit_status.exception.code, 0)
    gi.require_version.assert_not_called()
    self.popen.assert_called_once()
    self.assertEqual(self.popen.call_args.args[0],
      ["omarchy-launch-browser", "--new-window", "http://configured.test/discover"])
    self.assertTrue(self.popen.call_args.kwargs["start_new_session"])

  def test_platform_security_defaults_are_not_weakened(self):
    self.webkit.WebContext.new_ephemeral.assert_called_once_with()
    settings = dict(c.args for c in self.view.settings.set_property.call_args_list)
    self.assertFalse(settings["allow-file-access-from-file-urls"])
    self.assertFalse(settings["allow-universal-access-from-file-urls"])
    for name in ("allow-running-of-insecure-content", "allow-display-of-insecure-content"):
      self.assertFalse(settings.get(name, False), name)
    self.assert_no_bypass()
    tree = ast.parse(SOURCE.read_text())
    # Cover dormant code as well as the exercised callbacks. TLS flag filtering
    # is unsafe: GLib may report only one of several certificate problems.
    forbidden = {"allow_tls_certificate_for_host", "TLSErrorsPolicy",
                 "TlsCertificateFlags", "set_tls_errors_policy"}
    for node in ast.walk(tree):
      if isinstance(node, ast.Attribute):
        self.assertNotIn(node.attr, forbidden)
    self.assertNotIn("load-failed-with-tls-errors", self.view.signals)


if __name__ == "__main__":
  unittest.main(verbosity=2)
