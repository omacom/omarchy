import os
from pathlib import Path
from tempfile import TemporaryDirectory

from kitty.config import load_config
from kitty.options.utils import parse_map

root = Path(os.environ['ROOT'])
system = root / 'etc/xdg/kitty/kitty.conf'
template = root / 'config/kitty/kitty.conf'
legacy = root / 'test/shell.d/fixtures/kitty/legacy.conf'
active_lines = [line for line in template.read_text().splitlines() if line and not line.startswith('#')]
assert active_lines == ['include ~/.local/state/omarchy/current/theme/kitty.conf']

with TemporaryDirectory() as tmp:
  user = Path(tmp) / 'kitty.conf'
  # Use a local theme to avoid depending on the developer's generated state.
  theme = Path(tmp) / 'theme.conf'
  theme.write_text('background #123456\n')
  themed = f'include {theme}\n'
  user.write_text(themed)
  errors = []
  opts = load_config(str(system), str(user), accumulate_bad_lines=errors)
  assert not errors, errors
  assert opts.allow_remote_control == 'socket-only'
  assert opts.listen_on == 'unix:${XDG_RUNTIME_DIR}/omarchy-kitty-{kitty_pid}'

  old = Path(tmp) / 'legacy.conf'
  old.write_text(legacy.read_text().replace(active_lines[0], themed.strip()))
  before = load_config(str(old), accumulate_bad_lines=errors)
  # Moving defaults must preserve appearance and behavior except remote control.
  for key in ('font_family', 'bold_italic_font', 'font_size', 'window_padding_width',
              'hide_window_decorations', 'confirm_os_window_close', 'cursor_shape',
              'cursor_blink_interval', 'shell_integration', 'enable_audio_bell',
              'tab_bar_edge', 'tab_bar_style', 'tab_powerline_style',
              'tab_title_template', 'background'):
    assert getattr(opts, key) == getattr(before, key), key

  def binding(options, shortcut):
    trigger = next(parse_map(shortcut)).trigger
    return [entry.definition for entry in options.keyboard_modes[''].keymap.get(trigger, [])]

  for shortcut in ('ctrl+insert', 'shift+insert', 'shift+enter', 'alt+shift+enter'):
    assert binding(opts, shortcut) == binding(before, shortcut), shortcut

  user.write_text(themed + 'font_size 15\nmap ctrl+insert\nmap shift+insert copy_to_clipboard\n')
  opts = load_config(str(system), str(user), accumulate_bad_lines=errors)
  assert opts.font_size == 15
  assert not any(binding(opts, 'ctrl+insert'))
  assert binding(opts, 'shift+insert')[-1] == 'copy_to_clipboard'

  user.write_text(themed + 'clear_all_shortcuts yes\nmap f1 new_window\n')
  opts = load_config(str(system), str(user), accumulate_bad_lines=errors)
  assert len(opts.keyboard_modes[''].keymap) == 1
  assert binding(opts, 'f1') == ['new_window']
  assert not errors, errors

print('ok - Kitty loads defaults and theme, preserves appearance, and supports user overrides and unmapping')
