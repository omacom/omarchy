#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788380505.sh"
[[ -f $migration ]] || fail "SDDM Qt6 guard migration exists"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_dir=$(cd -- "$test_dir" && pwd -P)

mkdir -p "$test_dir/bin" "$test_dir/etc/sddm.conf.d" "$test_dir/usr/share/sddm/themes/"{omarchy,maya,custom6} "$test_dir/usr/bin" "$test_dir/proc/23456"
printf 'LC_ALL=C\0' >"$test_dir/proc/23456/environ"
ln -s /usr/bin/sddm "$test_dir/proc/23456/exe"

cat >"$test_dir/bin/systemctl" <<'STUB'
#!/bin/bash
printf '23456\n'
STUB
chmod +x "$test_dir/bin/systemctl"

cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$test_dir/bin/sudo"

cat >"$test_dir/bin/ldd" <<'STUB'
#!/bin/bash
# Fake ldd: prints missing-library lines when the binary name contains -broken.
if [[ ${1##*/} == *-broken* ]]; then
  printf 'libQt5Core.so.5 => not found\nlibQt5Gui.so.5 => not found\n'
fi
STUB
chmod +x "$test_dir/bin/ldd"

cat >"$test_dir/usr/share/sddm/themes/omarchy/metadata.desktop" <<'EOF'
[SddmGreeterTheme]
Name=Omarchy
QtVersion=6
EOF

cat >"$test_dir/usr/share/sddm/themes/maya/metadata.desktop" <<'EOF'
[SddmGreeterTheme]
Name=Maya
EOF

cat >"$test_dir/usr/share/sddm/themes/custom6/metadata.desktop" <<'EOF'
[SddmGreeterTheme]
Name=Custom
QtVersion=6
EOF

touch "$test_dir/usr/bin/sddm-greeter-good"
touch "$test_dir/usr/bin/sddm-greeter-broken"
touch "$test_dir/usr/bin/sddm-greeter-qt6"
chmod +x "$test_dir/usr/bin/"sddm-greeter-*

run_migration() {
  HOME="$test_dir/home" \
    OMARCHY_SDDM_CONF="$test_dir/etc/sddm.conf" \
    OMARCHY_SDDM_CONF_DIR="$test_dir/etc/sddm.conf.d" \
    OMARCHY_SDDM_SYS_CONF_DIR="$test_dir/usr/lib/sddm/sddm.conf.d" \
    OMARCHY_SDDM_PROC_ROOT="$test_dir/proc" \
    OMARCHY_SDDM_BACKUP_DIR="$test_dir/backups" \
    OMARCHY_SDDM_THEME_DIR="$test_dir/usr/share/sddm/themes" \
    OMARCHY_SDDM_QT5_GREETER="$test_dir/usr/bin/$1" \
    OMARCHY_SDDM_QT6_GREETER="$test_dir/usr/bin/sddm-greeter-qt6" \
    PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration"
}

# Scenario 1: the active theme already declares QtVersion=6 — no change.
{
  reset_state() {
    rm -rf "$test_dir/etc" "$test_dir/home"
    mkdir -p "$test_dir/etc/sddm.conf.d" "$test_dir/home"
  }
  reset_state
  printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  run_migration sddm-greeter-broken >/dev/null
  grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "safe Qt6 theme is left unchanged"
}

# Scenario 2: an existing Qt5 theme is active with missing greeter libraries — reset.
{
  reset_state
  printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/99-user-theme.conf"
  run_migration sddm-greeter-broken >/dev/null
  grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/99-user-theme.conf" >/dev/null ||
    fail "unsafe non-Qt6 theme is reset to omarchy"
  grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "packaged theme file stays valid"
}

# Scenario 3: a Qt5 theme is active but its greeter links successfully — leave it.
{
  reset_state
  printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  run_migration sddm-greeter-good >/dev/null
  grep -Fx 'Current=maya' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "non-Qt6 theme is left alone when Qt5 greeter works"
}

# Scenario 4: a custom theme declares QtVersion=6 even though the Qt5 greeter is broken.
{
  reset_state
  printf '[Theme]\nCurrent=custom6\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  run_migration sddm-greeter-broken >/dev/null
  grep -Fx 'Current=custom6' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
    fail "custom Qt6 theme is left unchanged"
}

# Scenario 5: no Current= is configured anywhere — nothing to guard.
{
  reset_state
  run_migration sddm-greeter-broken >/dev/null
  [[ ! -e $test_dir/etc/sddm.conf.d/10-theme.conf ]] ||
    fail "guard does not create a theme file when none exists"
}

pass "SDDM Qt6 theme guard resets unsafe themes and preserves safe ones"

python3 - "$migration" <<'PY'
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

migration = sys.argv.pop()


class SddmRepairTest(unittest.TestCase):
  def setUp(self):
    self.scratch = tempfile.TemporaryDirectory()
    self.addCleanup(self.scratch.cleanup)
    self.root = Path(self.scratch.name).resolve()
    for directory in ('etc/sddm.conf.d', 'vendor', 'bin', 'home', 'backups'):
      (self.root / directory).mkdir(parents=True)
    self.env = dict(os.environ, HOME=str(self.root / 'home'), LC_ALL='C',
      OMARCHY_SDDM_CONF=str(self.root / 'etc/sddm.conf'),
      OMARCHY_SDDM_CONF_DIR=str(self.root / 'etc/sddm.conf.d'),
      OMARCHY_SDDM_SYS_CONF_DIR=str(self.root / 'vendor'),
      OMARCHY_SDDM_PROC_ROOT=str(self.root / 'proc'),
      OMARCHY_SDDM_THEME_DIR=str(self.root / 'themes'),
      OMARCHY_SDDM_BACKUP_DIR=str(self.root / 'backups'),
      OMARCHY_SDDM_QT5_GREETER=str(self.root / 'bin/greeter5'),
      OMARCHY_SDDM_QT6_GREETER=str(self.root / 'bin/greeter6'),
      PATH=str(self.root / 'bin') + ':' + os.environ['PATH'])
    for name in ('greeter5', 'greeter6'):
      self.put('bin/' + name, '')
      (self.root / 'bin' / name).chmod(0o755)
    self.put('bin/ldd', '\n'.join((
      '#!/bin/bash',
      'if [[ $1 == *greeter5 ]]; then',
      '  case ${SDDM_TEST_LDD:-broken} in',
      "    good) printf 'libQt5Core.so.5 => /usr/lib/libQt5Core.so.5\\n' ;;",
      "    error) echo 'ldd: failed to inspect greeter' >&2; exit 42 ;;",
      "    changed) printf '# administrator edit\\n' >>\"$OMARCHY_SDDM_CONF_DIR/10-theme.conf\"; printf 'libQt5Core.so.5 => not found\\n' ;;",
      "    large) printf 'libQt5Core.so.5 => not found\\n'; for ((i=0; i<10000; i++)); do printf 'libother.so => /usr/lib/libother.so\\n'; done ;;",
      "    *) printf 'libQt5Core.so.5 => not found\\n' ;;",
      '  esac',
      "elif [[ ${SDDM_TEST_QT6_BROKEN:-0} == 1 ]]; then",
      "  printf 'libQt6Core.so.6 => not found\\n'",
      'fi',
      '')))
    (self.root / 'bin/ldd').chmod(0o755)
    self.put('bin/sudo', '#!/bin/bash\nexec "$@"\n')
    (self.root / 'bin/sudo').chmod(0o755)
    self.put('bin/systemctl', '\n'.join((
      '#!/bin/bash',
      '[[ $* == "show sddm.service --property=MainPID --value" ]] || exit 2',
      'touch "$OMARCHY_SDDM_PROC_ROOT/queried"',
      'printf "%s\\n" "${SDDM_TEST_MAIN_PID:-23456}"',
      'exit "${SDDM_TEST_SYSTEMCTL_STATUS:-0}"',
      ''))).chmod(0o755)
    self.put('proc/23456/environ', 'LC_ALL=C\0')
    (self.root / 'proc/23456/exe').symlink_to('/usr/bin/sddm')
    for theme, metadata in {'omarchy': 'QtVersion=6', 'maya': 'Name=Maya', 'custom6': 'QtVersion=6'}.items():
      self.put('themes/' + theme + '/metadata.desktop', '[SddmGreeterTheme]\n' + metadata + '\n')
    self.dropin = 'etc/sddm.conf.d/10-theme.conf'

  def put(self, path, text):
    dest = self.root / path
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(text.encode())
    return dest

  def get(self, path):
    return (self.root / path).read_bytes().decode()

  def run_repair(self, success=True):
    result = subprocess.run(['bash', '-euo', 'pipefail', migration], env=self.env, cwd=self.root / 'home', capture_output=True, text=True)
    if success:
      self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
    else:
      self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
    return result

  def snapshot(self):
    return {str(p.relative_to(self.root)): p.read_bytes() for directory in ('etc', 'vendor', 'backups')
      for p in (self.root / directory).rglob('*') if p.is_file()}

  def assert_unchanged(self, success=True):
    before = self.snapshot()
    self.run_repair(success)
    self.assertEqual(self.snapshot(), before)

  def backups(self):
    return [p for p in (self.root / 'backups').rglob('*') if p.is_file()]

  def test_etc_conf_has_highest_precedence(self):
    self.put(self.dropin, '[Theme]\nCurrent=omarchy\n')
    self.put('etc/sddm.conf', '[Theme]\nCurrent=maya\n')
    self.run_repair()
    self.assertEqual(self.get('etc/sddm.conf'), '[Theme]\nCurrent=omarchy\n')
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=omarchy\n')

  @unittest.skipUnless(sys.platform.startswith('linux'), 'Linux ICU sorting')
  def test_locale_aware_directory_order_matches_qt_icu(self):
    for environment in ('LANG=en_US.UTF-8\0', 'LANG=C\0LC_COLLATE=en_US.UTF-8\0',
                        'LANG=C\0LC_COLLATE=C\0LC_ALL=en_US.UTF-8\0'):
      with self.subTest(environment=environment):
        self.put('proc/23456/environ', environment + 'PRIVATE=do-not-print-this\0')
        self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
        self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n')
        result = self.run_repair()
        self.assertNotIn('do-not-print-this', result.stdout + result.stderr)
        self.assertEqual(self.get('etc/sddm.conf.d/a.conf'), '[Theme]\nCurrent=omarchy\n')
        self.assertEqual(self.get('etc/sddm.conf.d/a_.conf'), '[Theme]\nCurrent=custom6\n')

  @unittest.skipUnless(sys.platform.startswith('linux'), 'Linux ICU sorting')
  def test_equal_icu_keys_are_not_given_a_guessed_order(self):
    self.put('proc/23456/environ', 'LC_ALL=en_US.UTF-8\0')
    for i in range(20):
      self.put('etc/sddm.conf.d/a' + '\u200d' * i + '.conf', '[Theme]\nCurrent=' + ('maya' if i else 'custom6') + '\n')
    before = self.snapshot()
    result = self.run_repair(success=False)
    self.assertIn('ambiguous', result.stderr)
    self.assertEqual(self.snapshot(), before)

  def test_service_c_locale_overrides_updater_locale(self):
    self.env['LC_ALL'] = 'en_US.UTF-8'
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n')
    for environment in ('', 'LANG=\0LC_ALL=\0', 'LANG=en_US.UTF-8\0LC_COLLATE=C\0',
                        'LANG=en_US.UTF-8\0LC_COLLATE=en_US.UTF-8\0LC_ALL=C\0'):
      with self.subTest(environment=environment):
        self.put('proc/23456/environ', environment)
        self.assert_unchanged()

  def test_unavailable_service_locale_does_not_guess_competing_settings(self):
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n')
    for pid in ('0', 'not-a-pid', '99999', '../23456'):
      with self.subTest(pid=pid):
        self.env['SDDM_TEST_MAIN_PID'] = pid
        before = self.snapshot()
        result = self.run_repair(success=False)
        self.assertIn('service locale', result.stderr)
        self.assertEqual(self.snapshot(), before)
    self.env['SDDM_TEST_MAIN_PID'] = '23456'
    self.env['SDDM_TEST_SYSTEMCTL_STATUS'] = '1'
    self.assert_unchanged(success=False)
    self.env['SDDM_TEST_SYSTEMCTL_STATUS'] = '0'
    (self.root / 'proc/23456/environ').unlink()
    self.assert_unchanged(success=False)

  def test_service_locale_is_not_taken_from_another_executable(self):
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n')
    executable = self.root / 'proc/23456/exe'
    executable.unlink()
    executable.symlink_to('/usr/bin/user-session')
    self.assert_unchanged(success=False)
    executable.unlink()
    executable.symlink_to('/usr/bin/sddm (deleted)')
    self.assert_unchanged()

  def test_service_pid_change_during_locale_read_stays_pending(self):
    self.put('bin/systemctl', '\n'.join((
      '#!/bin/bash',
      'if [[ -e $OMARCHY_SDDM_PROC_ROOT/queried ]]; then',
      "  printf '0\\n'",
      'else',
      '  touch "$OMARCHY_SDDM_PROC_ROOT/queried"',
      "  printf '23456\\n'",
      'fi',
      ''))).chmod(0o755)
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n')
    self.assert_unchanged(success=False)

  def test_stopped_service_allows_unambiguous_settings_and_higher_overrides(self):
    self.env['SDDM_TEST_MAIN_PID'] = '0'
    self.env['LC_ALL'] = 'not-a-locale'
    self.put('vendor/default.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=custom6\n')
    self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n[Users]\nHideUsers=private\n')
    self.assert_unchanged()
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf', '[Theme]\nCurrent=custom6\n')
    self.assert_unchanged()
    self.put('etc/sddm.conf', '[Theme]\nCurrent=maya\n')
    self.run_repair()
    self.assertEqual(self.get('etc/sddm.conf'), '[Theme]\nCurrent=omarchy\n')
    self.assertFalse((self.root / 'proc/queried').exists())

  def test_stopped_service_same_broken_choice_gets_an_override(self):
    self.env['SDDM_TEST_MAIN_PID'] = '0'
    for name in ('a.conf', 'a_.conf'):
      self.put('etc/sddm.conf.d/' + name, '[Theme]\nCurrent=maya\n')
    self.run_repair()
    self.assertEqual(self.get('etc/sddm.conf'), '[Theme]\nCurrent=omarchy\n')
    for name in ('a.conf', 'a_.conf'):
      self.assertEqual(self.get('etc/sddm.conf.d/' + name), '[Theme]\nCurrent=maya\n')

  def test_stopped_service_does_not_guess_theme_directory(self):
    self.env['SDDM_TEST_MAIN_PID'] = '0'
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    self.put('vendor/a.conf', '[Theme]\nThemeDir=/missing\n')
    self.put('vendor/a_.conf', '[Theme]\nThemeDir=' + str(self.root / 'themes') + '\n')
    self.assert_unchanged(success=False)
    self.put('etc/sddm.conf', '[Theme]\nThemeDir=' + str(self.root / 'themes') + '\n')
    self.assert_unchanged()

  def test_missing_qt5_executable_needs_no_service_locale(self):
    self.env['SDDM_TEST_MAIN_PID'] = '0'
    self.put('etc/sddm.conf.d/a.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/a_.conf', '[Theme]\nCurrent=custom6\n')
    (self.root / 'bin/greeter5').unlink()
    self.assert_unchanged()

  def test_metadata_escaped_group_and_quoted_semicolon_follow_qsettings(self):
    for metadata in ('[%53ddmGreeterTheme]\nQtVersion=6\n',
                     '[SddmGreeterTheme]\nQtVersion="5;not a number"\n'):
      with self.subTest(metadata=metadata):
        self.put('themes/custom6/metadata.desktop', metadata)
        self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
        self.assert_unchanged()

  def test_only_newline_delimits_sddm_config_records(self):
    self.put(self.dropin, '[Theme]\nCurrent=custom6\vCurrent=maya\n')
    self.assert_unchanged()

  def test_safe_high_priority_config_does_not_modify_inactive_choices(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf', '[Theme]\nCurrent=custom6\n')
    self.assert_unchanged()

  def test_all_visible_directory_files_participate(self):
    for suffix in ('.pacsave', '.pacnew', '.bak', '~', '.txt'):
      with self.subTest(suffix=suffix):
        self.put(self.dropin, '[Theme]\nCurrent=omarchy\n')
        path = self.dropin + suffix
        self.put(path, '[Theme]\nCurrent=maya\n')
        self.run_repair()
        self.assertEqual(self.get(path), '[Theme]\nCurrent=maya\n')
        self.assertEqual(self.get('etc/sddm.conf'), '[Theme]\nCurrent=omarchy\n')
        (self.root / path).unlink()
        (self.root / 'etc/sddm.conf').unlink()

  def test_hidden_files_and_directories_are_not_loaded(self):
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    self.put('etc/sddm.conf.d/.hidden', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf.d/99-directory/file.conf', '[Theme]\nCurrent=maya\n')
    self.assert_unchanged()

  def test_vendor_theme_gets_local_override_not_package_edit(self):
    self.put('vendor/default.conf', '[Theme]\nCurrent=maya\n')
    self.put('etc/sddm.conf', '[Users]\nHideUsers=private')
    self.run_repair()
    self.assertEqual(self.get('vendor/default.conf'), '[Theme]\nCurrent=maya\n')
    self.assertEqual(self.get('etc/sddm.conf'), '[Users]\nHideUsers=private\n[Theme]\nCurrent=omarchy\n')

  def test_local_settings_override_vendor_files(self):
    self.put('vendor/default.conf', '[Theme]\nCurrent=maya\n')
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    self.assert_unchanged()

  def test_current_syntax_comments_eof_and_exact_edit(self):
    for line in ('Current=maya', '  Current = maya\n', 'Current=maya # chosen\n', 'Current=maya\r\n'):
      with self.subTest(line=line):
        self.put(self.dropin, '[Theme]\n' + line)
        self.run_repair()
        self.assertEqual(self.get(self.dropin), '[Theme]\n' + line.replace('maya', 'omarchy'))

  def test_only_winning_theme_current_is_replaced(self):
    original = '[Theme]\nCurrent=custom6\n[General]\nCurrent=irrelevant\n[Theme]\nCurrent=maya\n[Users]\nCurrent=omarchy\n'
    self.put(self.dropin, original)
    self.run_repair()
    self.assertEqual(self.get(self.dropin), original.replace('Current=maya', 'Current=omarchy'))

  def test_safe_comments_and_irrelevant_keys_do_not_trigger_edits(self):
    self.put(self.dropin, '[Theme]\nCurrent=custom6 # chosen\n[General]\nCurrent=maya\n')
    self.assert_unchanged()

  def test_safe_fallbacks_and_non_qt5_metadata_are_unchanged(self):
    for theme in ('', 'nosuchtheme'):
      with self.subTest(theme=theme):
        self.put(self.dropin, '[Theme]\nCurrent=' + theme + '\n')
        self.assert_unchanged()
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    for version in ('6', '7', 'invalid', '"6"', '+6', '06'):
      with self.subTest(version=version):
        self.put('themes/maya/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=' + version + '\n')
        self.assert_unchanged()
    self.put('themes/maya/metadata.desktop', '[SddmGreeterTheme]\nName=Maya\n')
    (self.root / 'bin/greeter5').chmod(0o644)
    self.assert_unchanged()
    (self.root / 'bin/greeter5').unlink()
    self.assert_unchanged()

  def test_missing_metadata_in_existing_theme_is_qt5(self):
    (self.root / 'themes/maya/metadata.desktop').unlink()
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.run_repair()
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=omarchy\n')

  def test_metadata_key_is_group_scoped_case_sensitive_and_last_wins(self):
    for metadata in ('[SddmGreeterTheme]\nName=Maya\n[Other]\nQtVersion=6\n',
                     '[SddmGreeterTheme]\nqtversion=6\n',
                     '[DEFAULT]\nQtVersion=6\n[SddmGreeterTheme]\nName=Maya\n',
                     '[SddmGreeterTheme]\nQtVersion=6\nQtVersion=5\n'):
      with self.subTest(metadata=metadata):
        self.put('themes/maya/metadata.desktop', metadata)
        self.put(self.dropin, '[Theme]\nCurrent=maya\n')
        self.run_repair()
        self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=omarchy\n')
    self.put('themes/custom6/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=6\n[Other]\nQtVersion=5\n')
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    self.assert_unchanged()

  def test_effective_theme_dir_and_absolute_theme_names(self):
    alternate = str(self.root / 'alternate')
    self.put('alternate/outside6/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=6\n')
    self.put('alternate/omarchy/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=5\n')
    self.put('vendor/default.conf', '[Theme]\nThemeDir=' + alternate + '\n')
    self.put(self.dropin, '[Theme]\nCurrent=outside6\n')
    self.assert_unchanged()
    self.put(self.dropin, '[Theme]\nCurrent=' + alternate + '/outside6\n')
    self.assert_unchanged()
    self.put(self.dropin, '[Theme]\nCurrent=omarchy\n')
    self.run_repair()
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=' + str(self.root / 'themes/omarchy') + '\n')
    self.assertEqual(self.get('vendor/default.conf'), '[Theme]\nThemeDir=' + alternate + '\n')

  def test_relative_theme_dir_uses_the_system_service_working_directory(self):
    relative = str(self.root / 'themes').lstrip('/')
    original = '[Theme]\nThemeDir=' + relative + '\nCurrent=maya\n'
    self.put(self.dropin, original)
    self.run_repair()
    self.assertEqual(self.get(self.dropin), original.replace('Current=maya', 'Current=' + str(self.root / 'themes/omarchy')))

  def test_theme_dir_highest_precedence_is_used(self):
    self.put('vendor/default.conf', '[Theme]\nThemeDir=/missing\n')
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    self.put('etc/sddm.conf', '[Theme]\nThemeDir=' + str(self.root / 'themes') + '\n')
    self.assert_unchanged()

  def test_backup_is_retained_outside_loaded_dirs_with_original_bytes_and_mode(self):
    original = '[Theme]\n  Current = maya # selected\n[Users]\nHideUsers=private\n'
    source = self.put(self.dropin, original)
    source.chmod(0o640)
    self.put(self.dropin + '.bak', '# previous administrator backup\n[Users]\nHideUsers=other\n')
    self.put('backups/10-theme.conf', 'older recovery copy\n')
    result = self.run_repair()
    self.assertEqual(self.get(self.dropin + '.bak'), '# previous administrator backup\n[Users]\nHideUsers=other\n')
    self.assertEqual(self.get('backups/10-theme.conf'), 'older recovery copy\n')
    copies = [p for p in self.backups() if p.read_text() == original]
    self.assertEqual(len(copies), 1)
    self.assertIn(str(copies[0]), result.stdout)
    self.assertEqual(copies[0].stat().st_mode & 0o777, 0o600)
    self.assertEqual(source.stat().st_mode & 0o777, 0o640)
    self.assert_unchanged()
    self.put(self.dropin, original)
    self.run_repair()
    self.assertEqual(len([p for p in self.backups() if p.read_text() == original]), 2)

  def test_backup_failure_leaves_configuration_untouched(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.put('not-a-directory', 'blocked')
    self.env['OMARCHY_SDDM_BACKUP_DIR'] = str(self.root / 'not-a-directory/backup')
    self.assert_unchanged(success=False)

  def test_backup_inside_loaded_directory_is_rejected(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    for directory in ('etc/sddm.conf.d', 'etc/sddm.conf.d/recovery', 'vendor/recovery'):
      self.env['OMARCHY_SDDM_BACKUP_DIR'] = str(self.root / directory)
      self.assert_unchanged(success=False)

  def test_symlink_and_writable_config_are_not_replaced(self):
    source = self.put('outside.conf', '[Theme]\nCurrent=maya\n')
    link = self.root / self.dropin
    link.symlink_to(source)
    self.assert_unchanged(success=False)
    self.assertTrue(link.is_symlink())
    link.unlink()
    self.put(self.dropin, '[Theme]\nCurrent=maya\n').chmod(0o666)
    self.assert_unchanged(success=False)
    link.chmod(0o644)
    os.link(link, self.root / 'hardlink.conf')
    self.assert_unchanged(success=False)

  def test_unsafe_parent_and_backup_symlink_are_rejected(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    parent = self.root / 'etc/sddm.conf.d'
    parent.chmod(0o777)
    self.assert_unchanged(success=False)
    parent.chmod(0o755)
    (self.root / 'backups').rmdir()
    (self.root / 'backups').symlink_to(self.root / 'home', target_is_directory=True)
    self.assert_unchanged(success=False)

  def test_ldd_failures_are_pending_and_large_output_is_fully_consumed(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.env['SDDM_TEST_LDD'] = 'good'
    self.assert_unchanged()
    self.env['SDDM_TEST_LDD'] = 'error'
    result = self.run_repair(success=False)
    self.assertIn('ldd', result.stderr)
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=maya\n')
    self.env['SDDM_TEST_LDD'] = 'large'
    self.run_repair()
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=omarchy\n')

  def test_changed_configuration_is_not_overwritten(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.env['SDDM_TEST_LDD'] = 'changed'
    self.run_repair(success=False)
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=maya\n# administrator edit\n')
    self.assertEqual(self.backups(), [])

  def test_unsupported_metadata_is_not_guessed(self):
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    for value in ('\\\\x36', '"6\n"', '@ByteArray(5)', '@Variant(5)', '@String(5'):
      with self.subTest(value=value):
        self.put('themes/custom6/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=' + value + '\n')
        self.assert_unchanged(success=False)

  def test_malformed_metadata_sections_never_trigger_repair(self):
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    for metadata in ('[SddmGreeterTheme\nQtVersion=6\n',
                     '[SddmGreeterTheme]\nQtVersion=6\n[Other\nQtVersion=5\n',
                     '[SddmGreeterTheme]]\nQtVersion=6\n'):
      with self.subTest(metadata=metadata):
        self.put('themes/custom6/metadata.desktop', metadata)
        self.assert_unchanged(success=False)
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.put('themes/omarchy/metadata.desktop', '[SddmGreeterTheme\nQtVersion=6\n')
    self.assert_unchanged(success=False)

  def test_qsettings_string_encoded_qt_versions(self):
    self.put('themes/omarchy/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=@String(6)\n')
    for version in ('@String(5)', '"@String(5)"', '@String(+5)', '@String(05)'):
      with self.subTest(version=version):
        self.put(self.dropin, '[Theme]\nCurrent=maya\n')
        self.put('themes/maya/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=' + version + '\n')
        self.run_repair()
        self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=omarchy\n')
    self.put(self.dropin, '[Theme]\nCurrent=custom6\n')
    self.put('themes/custom6/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=@String(6)\n')
    self.assert_unchanged()

  def test_migration_failure_stays_pending_then_completes_only_once(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.put('runtime/migrations/1788380505.sh', Path(migration).read_text())
    self.put('runtime/migrations/9999999999.sh', 'touch "$HOME/later-ran"\n')
    self.env['OMARCHY_PATH'] = str(self.root / 'runtime')
    self.env['OMARCHY_MIGRATION_STATE'] = str(self.root / 'home/markers')
    runner = str(Path(os.environ['ROOT']) / 'bin/omarchy-migrate')
    self.env['SDDM_TEST_LDD'] = 'error'
    result = subprocess.run(['bash', runner], env=self.env, capture_output=True, text=True)
    self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
    self.assertFalse((self.root / 'home/markers/1788380505.sh').exists())
    self.assertFalse((self.root / 'home/later-ran').exists())
    self.env['SDDM_TEST_LDD'] = 'broken'
    result = subprocess.run(['bash', runner], env=self.env, capture_output=True, text=True)
    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
    self.assertTrue((self.root / 'home/markers/1788380505.sh').exists())
    self.assertTrue((self.root / 'home/later-ran').exists())
    self.assertEqual(self.get(self.dropin), '[Theme]\nCurrent=omarchy\n')
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    before = self.snapshot()
    result = subprocess.run(['bash', runner], env=self.env, capture_output=True, text=True)
    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
    self.assertEqual(self.snapshot(), before)

  def test_replacement_must_be_available_and_qt6(self):
    self.put(self.dropin, '[Theme]\nCurrent=maya\n')
    self.env['SDDM_TEST_QT6_BROKEN'] = '1'
    self.assert_unchanged(success=False)
    self.env['SDDM_TEST_QT6_BROKEN'] = '0'
    self.put('themes/omarchy/metadata.desktop', '[SddmGreeterTheme]\nQtVersion=5\n')
    self.assert_unchanged(success=False)


unittest.main(verbosity=2)
PY
