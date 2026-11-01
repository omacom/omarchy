#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

agent="$ROOT/shell/plugins/polkit/PolkitAgent.qml"

run_node_test <<'JS'
const polkit = requireFromRoot('shell/plugins/polkit/PolkitModel.js')

const asking = `
auth      [success=2 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth      optional pam_exec.so seteuid quiet stdout /usr/bin/omarchy-face-match --hint
auth      sufficient pam_exec.so seteuid quiet stdout expose_authtok /usr/bin/omarchy-face-match
auth      include system-auth
`
assert(polkit.faceConfiguredFromPamConfig(asking), 'polkit offers face when the stack asks first')
assert(!polkit.faceConfiguredFromPamConfig(asking.replace(' expose_authtok', '')), 'a face line that scans unasked is not offered')
assert(!polkit.faceConfiguredFromPamConfig(`
auth      [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed
auth      sufficient pam_python.so /usr/lib/security/howdy/pam.py
auth      include system-auth
`), 'the pam_python glue of earlier setups is not offered')
assert(!polkit.faceConfiguredFromPamConfig(`
# auth sufficient pam_exec.so seteuid quiet stdout expose_authtok /usr/bin/omarchy-face-match
auth include system-auth
`), 'a commented-out face line is not offered')
assert(!polkit.faceConfiguredFromPamConfig(`
auth sufficient pam_fprintd.so
auth include system-auth
`), 'a fingerprint stack offers no face')
assert(polkit.fingerprintConfiguredFromPamConfig(asking + 'auth sufficient pam_fprintd.so\n'), 'fingerprint detection is untouched by the face lines')
JS

grep -q 'property bool faceConfigured: false' "$agent" || fail "the agent tracks face enrollment from the PAM stack"
grep -q 'faceConfigured = PolkitModel.faceConfiguredFromPamConfig(raw)' "$agent" || fail "the agent reads face from the same PAM file as fingerprint"
grep -q 'readonly property bool faceOffered: faceConfigured && !laptopClosed && dialogVisible && responseRequired' "$agent" || fail "face is offered only while PAM waits for the password with the lid open"
grep -qF 'I18n.t("polkit.faceOrPassword")' "$agent" || fail "the empty field offers the face"
grep -qF 'I18n.t("polkit.scanningFace")' "$agent" || fail "a scan reads as scanning"
grep -q 'root.faceOffered || root.scanning ? "\\uf030" : "\\uf023"' "$agent" || fail "the padlock becomes a camera while face is offered or scanning"
# Upstream's qml-text-format suite: a Text whose text is a binding says how to render it.
grep -A1 -F 'root.faceOffered || root.scanning ? "\uf030" : "\uf023"' "$agent" | grep -q 'textFormat: Text.PlainText' ||
  fail "the camera or padlock declares plain text, as every bound Text upstream does"
pass "the polkit dialog offers the face and reports a scan while it runs"

# function_has <name> <literal>: the QML function's body contains the literal.
function_has() {
  awk -v name="function $1(" -v literal="$2" '
    index($0, name) { inside = 1 }
    inside && index($0, literal) { found = 1 }
    inside && /^  \}/ { exit }
    END { exit !found }' "$agent"
}

# Enter submits what was typed, as upstream's dialog does; only the Copilot
# key, handed over by Hyprland, answers with nothing to start a scan.
function_has submitResponse 'scanning = false' || fail "a submitted field is a password, never the face"
function_has scanFace 'if (!faceOffered || !flow || !flow.isResponseRequired) return "ignored"' || fail "the key acts only while the dialog offers the face"
{ function_has scanFace 'passwordInput.text = ""' && function_has scanFace 'flow.submit("")'; } || fail "the key drops what was typed and answers with nothing"
function_has scanFace 'scanning = true' || fail "the key's answer reads as a scan"
grep -Pzo '(ShellIpc|IpcHandler) \{\s*target: "polkit"\s*function faceKey\(\): string \{\s*return root\.scanFace\(\)' "$agent" >/dev/null ||
  fail "the dialog answers the key at the polkit IPC target"
grep -qF '{ ipc = "polkit.faceKey" }' "$ROOT/default/hypr/toggles/face-key.lua" || fail "Hyprland hands the key to that target"
pass "the Copilot key, handed over by Hyprland, starts the scan; Enter submits only the password"

qmllint=/usr/lib/qt6/bin/qmllint
if [[ -x $qmllint ]]; then
  out=$("$qmllint" --bare "$agent" 2>&1 || true)
  ! grep -q -i -E 'syntax error|unexpected token|expected token' <<<"$out" || fail "PolkitAgent.qml parses" "$out"
  pass "the patched polkit agent parses"
else
  skip "qmllint is not installed; QML syntax not checked"
fi
