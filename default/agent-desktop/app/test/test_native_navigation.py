import json
from pathlib import Path
import runpy
from types import SimpleNamespace
import unittest
from unittest.mock import patch

class Window:
    def __init__(self, title='Overview'):
        self.title = title
        self.visible = True
    def show_all(self): self.visible = True
    def hide(self): self.visible = False
    def present(self): self.visible = True
    def get_visible(self): return self.visible
    def set_title(self, title): self.title = title
    def set_urgency_hint(self, value): self.urgent = value
    def set_icon_name(self, value): self.icon = value
    def connect(self, *args): pass

class Notification:
    def set_body(self, value): self.body = value
    def set_icon(self, value): self.icon = value
    def set_default_action_and_target(self, action, target): self.action, self.target = action, target

class Application:
    def __init__(self, **kwargs): pass
    def add_main_option(self, *args): pass

class NavigationTest(unittest.TestCase):
    def setUp(self):
        self.callbacks = []
        gi = SimpleNamespace(require_version=lambda *args: None)
        repository = SimpleNamespace(Gtk=SimpleNamespace(Application=Application),
            Gio=SimpleNamespace(ApplicationFlags=SimpleNamespace(HANDLES_COMMAND_LINE=8),
                Notification=SimpleNamespace(new=lambda title: Notification()), ThemedIcon=SimpleNamespace(new=lambda name: name)),
            GLib=SimpleNamespace(OptionFlags=SimpleNamespace(NONE=0), OptionArg=SimpleNamespace(NONE=0), Variant=lambda kind, value: SimpleNamespace(get_string=lambda: value), timeout_add=lambda delay, callback: self.callbacks.append(callback)), WebKit2=SimpleNamespace())
        with patch.dict('sys.modules', {'gi': gi, 'gi.repository': repository}):
            code = runpy.run_path(str(Path(__file__).parents[1] / 'agent-desktops'), run_name='native_navigation')
        self.app = code['Desktops']()
        self.app.main = Window()
        self.app.url = 'http://127.0.0.1/private/'
        self.app.window = lambda title, url, chat: Window(title)
        self.app.adjacent = lambda parent: True
    def message(self, kind, identity='one'):
        value = {'type': kind, 'id': identity, 'agentId': 'host/' + identity, 'title': identity}
        result = SimpleNamespace(get_js_value=lambda: SimpleNamespace(to_string=lambda: json.dumps(value)))
        self.app.message(None, result, self.app.main)
    def test_auto_open_keeps_an_existing_chat_in_place(self):
        self.message('chat'); self.callbacks.pop()()
        self.app.get_windows = lambda: [self.app.main, *self.app.chats.values()]
        command = SimpleNamespace(get_options_dict=lambda: SimpleNamespace(contains=lambda key: True))
        self.assertEqual(self.app.do_command_line(command), 0)
        self.assertFalse(self.app.main.visible)
        self.assertTrue(self.app.chats['one'].visible)

    def test_auto_open_launches_when_no_window_exists(self):
        self.app.get_windows = lambda: []
        activations = []
        self.app.do_activate = lambda: activations.append(True)
        command = SimpleNamespace(get_options_dict=lambda: SimpleNamespace(contains=lambda key: True))
        self.assertEqual(self.app.do_command_line(command), 0)
        self.assertEqual(activations, [True])

    def test_attention_deduplicates_resolves_and_opens_the_verified_group(self):
        sent, withdrawn = [], []
        self.app.send_notification = lambda identity, notice: sent.append((identity, notice))
        self.app.withdraw_notification = withdrawn.append
        self.app.get_windows = lambda: [self.app.main]
        chat = {'id': 'one', 'agentId': 'hub/thread', 'title': 'Build editor'}
        self.app.update_attention([chat]); self.app.update_attention([chat])
        self.assertEqual(len(sent), 1)
        self.assertTrue(self.app.main.urgent)
        self.assertEqual(self.app.main.icon, 'dialog-warning')
        self.assertEqual(sent[0][1].action, 'app.open-agent')
        self.app.open_attention(None, sent[0][1].target)
        self.callbacks.pop()()
        self.assertIn('one', self.app.groups)
        self.assertIn('one', self.app.chats)
        self.app.update_attention([])
        self.assertEqual(withdrawn, ['agent-one'])
        self.assertFalse(self.app.main.urgent)
        self.app.update_attention([chat])
        self.assertEqual(len(sent), 2, 'a new waiting episode gets a new notification')

    def test_notification_uses_the_installed_gio_binding(self):
        try:
            from gi.repository import Gio, GLib
        except ImportError:
            self.skipTest('native Gio dependency unavailable')
        sent = []
        self.app.send_notification = lambda identity, notice: sent.append(notice)
        self.app.get_windows = lambda: [self.app.main]
        with patch.dict(self.app.update_attention.__func__.__globals__, {'Gio': Gio, 'GLib': GLib}):
            self.app.update_attention([{'id': 'one', 'agentId': 'host/thread', 'title': 'Test notification'}])
        self.assertIsInstance(sent[0], Gio.Notification)

    def test_overview_cancels_a_delayed_chat(self):
        self.message('chat')
        self.message('overview')
        self.assertFalse(self.callbacks.pop()())
        self.assertEqual(self.app.chats, {})
        self.assertTrue(self.app.main.visible)
    def test_switching_agents_cancels_the_previous_delayed_chat(self):
        self.message('chat', 'one')
        self.message('chat', 'two')
        for callback in self.callbacks: callback()
        self.assertEqual(set(self.app.chats), {'two'})
        self.assertFalse(self.app.groups['one'].visible)
    def test_return_reuses_the_existing_chat_window(self):
        self.message('chat'); self.callbacks.pop()()
        original = self.app.chats['one']
        self.message('overview')
        self.assertFalse(original.visible)
        self.message('chat'); self.callbacks.pop()()
        self.assertIs(self.app.chats['one'], original)
        self.assertTrue(original.visible)

if __name__ == '__main__': unittest.main()
