#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the actual policy renderer/publication rather than setup heredocs:
# preserve vendor faillock includes and never expose a method without its guard.
python3 -B - "$ROOT/default/pam/polkit-policy.py" <<'PY'
from pathlib import Path
import runpy
import sys
import tempfile
from unittest.mock import patch

policy = runpy.run_path(sys.argv[1])
body = ''.join(f'{phase} include system-auth\n' for phase in ('auth', 'account', 'password', 'session'))
with tempfile.TemporaryDirectory() as directory:
  target = Path(directory) / 'polkit-1'
  vendor = Path(directory) / 'vendor'
  vendor.write_text(body)
  (Path(directory) / 'system-auth').write_text('auth required pam_unix.so\n')
  for method in ('fingerprint', 'fido2'):
    old = target.read_bytes() if target.exists() else None
    # Failure immediately before publication leaves the previous policy intact.
    with patch('os.replace', side_effect=OSError('interrupted publication')):
      try:
        policy['publish'](target, vendor, method)
      except OSError:
        pass
      else:
        raise AssertionError('publication did not reach the failure point')
    assert (target.read_bytes() if target.exists() else None) == old
    policy['publish'](target, vendor, method)
    rendered = target.read_text()
    assert rendered.startswith('account requisite pam_omarchy_lock.so\n')
    assert 'auth [success=ignore default=2] pam_omarchy_lock.so\nauth [success=1 default=ignore] pam_exec.so' in rendered
    assert 'auth optional pam_omarchy_lock.so password\nauth include system-auth' in rendered
    for line in body.splitlines():
      assert line in rendered
    assert rendered.count('pam_fprintd.so') == 1
    assert policy['render'](rendered, method) == rendered
  assert rendered.count('pam_u2f.so') == 1
  removed = policy['render'](rendered, 'remove-fingerprint')
  assert 'pam_fprintd.so' not in removed and 'omarchy-hw-laptop-closed' not in removed
  assert 'default=2]' not in removed and 'pam_u2f.so' in removed
  removed = policy['render'](removed, 'remove-fido2')
  assert 'pam_u2f.so' not in removed and 'default=1]' not in removed
  assert removed == 'account requisite pam_omarchy_lock.so\n' + body
  before = target.read_bytes()
  try:
    policy['publish'](target, vendor, 'unknown')
  except ValueError:
    pass
  else:
    raise AssertionError('invalid method accepted')
  assert target.read_bytes() == before
  # Comments/blank lines are not entries in PAM's relative-jump accounting.
  gate = 'AUTH [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed\n'
  example = gate + '# reader\n\naccount include system-auth\nAUTH SUFFICIENT pam_fprintd.so\nauth include system-auth\n'
  rendered = policy['render'](example)
  spaced = policy['render'](example.replace('success=1 default=ignore', 'success = 1 default = ignore'))
  assert 'default=2] pam_omarchy_lock.so' in spaced
  assert rendered.index('default=2] pam_omarchy_lock.so') < rendered.index(gate)
  assert 'default=1] pam_omarchy_lock.so' not in rendered
  required = 'auth requisite pam_deny.so # coordinated with pam_omarchy_lock.so\n'
  assert required in policy['render'](required + body)
  comments = '# omarchy-hw-laptop-closed\n# pam_fprintd.so\n' + body
  rendered = policy['render'](comments, 'fingerprint')
  assert 'auth sufficient pam_fprintd.so' in rendered
  for invalid in ('[auth] sufficient pam_fprintd.so\n', 'auth sufficient [pam_fprintd.so]\n', 'auth required pam_fprintd.so\n', 'auth sufficient \\\n pam_fprintd.so\n',
                  'auth [success=1 default=ignore] pam_permit.so # omarchy-hw-laptop-closed\n'):
    try:
      policy['render'](invalid)
    except ValueError:
      pass
    else:
      raise AssertionError('unsupported stack accepted: ' + invalid)
  (Path(directory) / 'system-auth').write_text('AUTH SUFFICIENT pam_fprintd.so\n')
  try:
    policy['publish'](target, vendor)
  except ValueError:
    pass
  else:
    raise AssertionError('included fingerprint factor treated as password-only')
  assert target.read_bytes() == before
print('ok - atomic biometric policy publication preserves faillock and guard ordering')
PY
