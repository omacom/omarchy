#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# These assertions pin the face-authentication contracts that routing and the
# PAM flow depend on. Routing itself (omarchy setup security face) is covered
# by test/cli.

SETUP="$ROOT/bin/omarchy-setup-security-face"
REMOVE="$ROOT/bin/omarchy-remove-security-face"
SERVICE="$ROOT/shell/plugins/lock/Service.qml"
VIEW="$ROOT/shell/plugins/lock/LockView.qml"
MANIFEST="$ROOT/shell/plugins/lock/manifest.json"

# The wizard must install the maintained Howdy build from AUR via omarchy-pkg-aur-add.
if ! grep -q "omarchy-pkg-aur-add howdy-git" "$SETUP"; then
  fail "setup installs howdy-git from the AUR"
fi
pass "setup installs howdy-git from the AUR"

if ! grep -q "omarchy-pkg-add v4l-utils" "$SETUP"; then
  fail "setup installs v4l-utils via pacman"
fi
pass "setup installs v4l-utils via pacman"
if grep -qE "omarchy-pkg-add howdy( |$)" "$SETUP"; then
  fail "setup must not install the outdated plain howdy package"
fi
pass "setup does not install the outdated plain howdy package"

# The PAM context may only reference the compiled module howdy-git actually
# ships at /lib/security/pam_howdy.so — never a module nothing installs.
if grep -rq "pam_howdy_face_only" "$ROOT/bin" "$ROOT/shell"; then
  fail "no reference to the nonexistent pam_howdy_face_only module may remain"
fi
pass "no reference to the nonexistent pam_howdy_face_only module may remain"

if ! grep -qE "auth\s+sufficient\s+/lib/security/pam_howdy\.so" "$SETUP"; then
  fail "setup writes the documented pam_howdy.so sufficient line"
fi
pass "setup writes the documented pam_howdy.so sufficient line"

if ! grep -q "pam_howdy.so is missing" "$SETUP"; then
  fail "setup refuses to enable face PAM when the module is absent"
fi
pass "setup refuses to enable face PAM when the module is absent"

# The Howdy config home moved between builds: master (r592+) uses /etc/howdy,
# the older packaged layout /lib/security/howdy, and the beta
# /usr/local/etc/howdy. The wizard must probe all three.
if ! grep -q "/etc/howdy/config.ini" "$SETUP" || ! grep -q 'HOWDY_DIR="/lib/security/howdy"' "$SETUP" || ! grep -q "/usr/local/etc/howdy/config.ini" "$SETUP"; then
  fail "setup probes every documented Howdy config location"
fi
pass "setup probes every documented Howdy config location"

if ! grep -q 'HOWDY_DIR="/lib/security/howdy"' "$REMOVE"; then
  fail "remove targets the packaged Howdy config directory"
fi
pass "remove targets the packaged Howdy config directory"

# The setup is idempotent: an existing face model skips enrollment so
# re-running to repair PAM never adds duplicate models.
if ! grep -qE "Existing face model found.*skipping enrollment" "$SETUP"; then
  fail "setup skips enrollment when a face model already exists"
fi
pass "setup skips enrollment when a face model already exists"

# Some Howdy builds write config and models to /usr/local/etc/howdy while the
# PAM module only reads /lib/security/howdy — the wizard must normalize that
# after enrollment or authentication silently never works.
if ! grep -q "normalize_howdy_paths" "$SETUP"; then
  fail "setup normalizes Howdy config/model paths after enrollment"
fi
pass "setup normalizes Howdy config/model paths after enrollment"

# Stored face snapshots are a documented spoofing hole; never capture them.
if ! grep -q "capture_failed = false" "$SETUP" || ! grep -q "capture_successful = false" "$SETUP"; then
  fail "setup disables Howdy face snapshots"
fi
pass "setup disables Howdy face snapshots"

if ! grep -q "dark_threshold = 90" "$SETUP"; then
  fail "setup applies the IR-friendly dark_threshold exactly once"
fi
pass "setup applies the IR-friendly dark_threshold exactly once"

if grep -q "dark_threshold = 60" "$SETUP"; then
  fail "no contradictory second dark_threshold rewrite may remain"
fi
pass "no contradictory second dark_threshold rewrite may remain"

# Removal tears everything down: PAM context, packages, the IR emitter unit,
# and the enrolled biometric models.
if ! grep -q "omarchy-pkg-drop howdy-git" "$REMOVE"; then
  fail "remove drops the howdy-git package"
fi
pass "remove drops the howdy-git package"

if ! grep -q 'rm -rf "$models_dir"' "$REMOVE" && ! grep -q 'rm -rf "$HOWDY_DIR/models"' "$REMOVE"; then
  fail "remove deletes the enrolled face models"
fi
pass "remove deletes the enrolled face models"
if ! grep -q "/etc/howdy/models" "$REMOVE"; then
  fail "remove deletes models left under /etc/howdy"
fi
pass "remove deletes models left under /etc/howdy"

if ! grep -q "/usr/local/etc/howdy/models" "$REMOVE"; then
  fail "remove deletes models left under /usr/local/etc/howdy"
fi
pass "remove deletes models left under /usr/local/etc/howdy"
if ! grep -q "face-ir-emitter-enabled" "$SETUP" || ! grep -q "face-ir-emitter-enabled" "$REMOVE"; then
  fail "setup records and remove respects pre-existing IR emitter service state"
fi
pass "setup records and remove respects pre-existing IR emitter service state"
if ! grep -q "omarchy-lock-howdy" "$REMOVE"; then
  fail "remove tears down the face PAM context"
fi
pass "remove tears down the face PAM context"

# The hardware detector is sysfs-precise (uvcvideo binding, or camera/IR-ish
# embedded names) and must not match every /dev/video node.
if ! grep -q "uvcvideo" "$ROOT/bin/omarchy-hw-face"; then
  fail "hardware detector matches USB webcams by their driver binding"
fi
pass "hardware detector matches USB webcams by their driver binding"

if grep -q "ls /dev/video" "$ROOT/bin/omarchy-hw-face"; then
  fail "hardware detector must not match every /dev/video node"
fi
pass "hardware detector must not match every /dev/video node"

# Enrollment mirrors the fingerprint flow: prove the camera delivers frames
# before asking for a face, and prove enrollment stored a model before any
# PAM configuration is written.
if ! grep -q "verify_camera_capture" "$SETUP" || ! grep -q "stream-count=1" "$SETUP"; then
  fail "setup verifies the camera can capture frames before enrollment"
fi
pass "setup verifies the camera can capture frames before enrollment"

if ! grep -qE "timeout\s+[0-9]+\s+v4l2-ctl.*--stream-mmap" "$SETUP"; then
  fail "camera probe uses a timeout to prevent hanging"
fi
pass "camera probe uses a timeout to prevent hanging"

if grep -q "Howdy needs a working camera. Nothing was changed" "$SETUP"; then
  fail "camera failure must not claim nothing was changed after packages were installed"
fi
pass "camera failure does not falsely claim nothing was changed"

if ! grep -qE '\$TARGET_USER\.dat|\$\{TARGET_USER\}\.dat' "$SETUP"; then
  fail "setup checks enrollment for the target user specifically"
fi
pass "setup checks enrollment for the target user specifically"

if ! grep -q 'howdy -U "\$TARGET_USER" add' "$SETUP"; then
  fail "setup enrolls the target user explicitly"
fi
pass "setup enrolls the target user explicitly"

if ! grep -q "verify_enrollment" "$SETUP" || ! grep -q "no face model was stored" "$SETUP"; then
  fail "setup verifies enrollment produced a face model before writing PAM"
fi
pass "setup verifies enrollment produced a face model before writing PAM"
# The lock service keeps the face flow bounded: attempts are rate-limited so
# motion wake cannot turn every mouse movement into a camera-on PAM attempt.
if ! grep -q "faceCooldownTimer" "$SERVICE"; then
  fail "lock service rate-limits face attempts with a cooldown"
fi
pass "lock service rate-limits face attempts with a cooldown"

if ! sed -n '/function startFace/,/^  }/p' "$SERVICE" | grep -q "faceCooldownTimer.running"; then
  fail "startFace honors the attempt cooldown"
fi
pass "startFace honors the attempt cooldown"

if ! sed -n '/faceCooldownTimer/,/^[[:space:]]*}/p' "$SERVICE" | grep -q "root.startFace()"; then
  fail "face cooldown timer retries face scan when expired"
fi
pass "face cooldown timer retries face scan when expired"

if ! sed -n '/function startFace/,/^  }/p' "$SERVICE" | grep -q "displaysBlank"; then
  fail "startFace does not scan when display is blanked"
fi
pass "startFace does not scan when display is blanked"

if ! sed -n '/function startFace/,/^  }/p' "$SERVICE" | grep -qE "faceAttempts.*maxFaceAttempts|maxFaceAttempts.*faceAttempts" || ! grep -q "maxFaceAttempts: 2" "$SERVICE"; then
  fail "startFace bounds consecutive face scan attempts to 2"
fi
pass "startFace bounds consecutive face scan attempts to 2"

if ! sed -n '/faceCooldownTimer/,/^[[:space:]]*}/p' "$SERVICE" | grep -q "displaysBlank"; then
  fail "face cooldown timer does not retry face scan when display is blanked"
fi
pass "face cooldown timer does not retry face scan when display is blanked"

if ! sed -n '/function runBlank/,/^  }/p' "$SERVICE" | grep -q "facePam.active"; then
  fail "runBlank aborts active face authentication"
fi
pass "runBlank aborts active face authentication"

if ! sed -n '/function runWake/,/^  }/p' "$SERVICE" | grep -q "faceAttempts"; then
  fail "runWake resets face attempts count"
fi
pass "runWake resets face attempts count"

if ! sed -n '/function resetAuthenticationState/,/^[[:space:]]*}/p' "$SERVICE" | grep -q "faceCooldownTimer.stop()"; then
  fail "resetAuthenticationState stops the face cooldown timer"
fi
pass "resetAuthenticationState stops the face cooldown timer"
if ! grep -q "running: root.lockRequested && facePamConfigured" "$SERVICE"; then
  fail "resume detection only runs when face auth is configured"
fi
pass "resume detection only runs when face auth is configured"

if ! sed -n '/id: resumeDetectionTimer/,/^[[:space:]]*}/p' "$SERVICE" | grep -q "faceAttempts = 0"; then
  fail "resumeDetectionTimer resets face attempts on resume"
fi
pass "resumeDetectionTimer resets face attempts on resume"

if ! sed -n '/function onScreensChanged/,/^[[:space:]]*}/p' "$SERVICE" | grep -q "faceAttempts = 0"; then
  fail "onScreensChanged resets face attempts when screens change"
fi
pass "onScreensChanged resets face attempts when screens change"

if ! sed -n '/function onScreensChanged/,/^[[:space:]]*}/p' "$SERVICE" | grep -q "startFace()"; then
  fail "onScreensChanged starts face scan when screens change"
fi
pass "onScreensChanged starts face scan when screens change"

if ! grep -q 'config: "omarchy-lock-howdy"' "$SERVICE"; then
  fail "lock service declares the omarchy-lock-howdy PAM context"
fi
pass "lock service declares the omarchy-lock-howdy PAM context"

node -e '
const fs = require("fs");
for (const file of [process.argv[1], process.argv[2]]) {
  const content = fs.readFileSync(file, "utf8");
  let balance = 0;
  for (let i = 0; i < content.length; i++) {
    if (content[i] === "{") balance++;
    else if (content[i] === "}") balance--;
    if (balance < 0) process.exit(1);
  }
  if (balance !== 0) process.exit(1);
}
' "$SERVICE" "$VIEW" || fail "lock service and view QML files have balanced braces"
pass "lock service and view QML files have balanced braces"
# The view keeps exactly one hover area (the existing one, extended with
# motion wake) so an added overlay cannot steal hover or cursor styling.
mouse_areas=$(grep -c "MouseArea {" "$VIEW")
if (( mouse_areas != 1 )); then
  fail "lock view keeps a single hover area (found $mouse_areas)"
fi
pass "lock view keeps a single hover area"

if grep -q "acceptedButtons: Qt.NoButton" "$VIEW"; then
  fail "no click-swallowing overlay MouseArea may remain"
fi
pass "no click-swallowing overlay MouseArea may remain"

if ! grep -q "onPositionChanged: root.wakeRequested()" "$VIEW"; then
  fail "lock view wakes on mouse motion"
fi
pass "lock view wakes on mouse motion"

# Indicator spacing is measured from the glyphs, not hardcoded.
if ! grep -q "fingerprintIcon.implicitWidth" "$VIEW" || ! grep -q "faceIcon.implicitWidth" "$VIEW"; then
  fail "indicator reserve is measured from the rendered glyphs"
fi
pass "indicator reserve is measured from the rendered glyphs"

if ! grep -q "faceIndicator" "$VIEW"; then
  fail "lock view contains the face indicator"
fi
pass "lock view contains the face indicator"

if ! grep -q "separate password, fingerprint, and face PAM flows" "$MANIFEST"; then
  fail "lock manifest documents the face PAM flow"
fi
pass "lock manifest documents the face PAM flow"

[[ -x $ROOT/bin/omarchy-hw-face ]] || fail "omarchy-hw-face is executable"
[[ -x $SETUP ]] || fail "omarchy-setup-security-face is executable"
[[ -x $REMOVE ]] || fail "omarchy-remove-security-face is executable"
pass "face authentication tools are executable"

# Fixture-based behavioral testing for removal and setup paths
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# 1. Verify remove deletes all 3 model directories
mkdir -p "$test_tmp/etc/howdy/models" "$test_tmp/lib/security/howdy/models" "$test_tmp/usr/local/etc/howdy/models"
touch "$test_tmp/etc/howdy/models/alice.dat"
touch "$test_tmp/lib/security/howdy/models/bob.dat"
touch "$test_tmp/usr/local/etc/howdy/models/charlie.dat"

remove_copy="$test_tmp/remove.sh"
sed -E -e "s:(^|[[:space:]])/etc/howdy/models:\1$test_tmp/etc/howdy/models:g" \
       -e "s:(^|[[:space:]])/usr/local/etc/howdy/models:\1$test_tmp/usr/local/etc/howdy/models:g" \
       -e "s|HOWDY_DIR=\"/lib/security/howdy\"|HOWDY_DIR=\"$test_tmp/lib/security/howdy\"|g" \
       -e "s|PAM_FILE=\"/etc/pam.d/omarchy-lock-howdy\"|PAM_FILE=\"$test_tmp/pam-howdy\"|g" \
       -e "s|/var/lib/omarchy/face-ir-emitter-enabled|$test_tmp/face-ir-emitter-enabled|g" \
       -e "s|\\\$HOME/\\.local/state/omarchy/face-ir-emitter-enabled|$test_tmp/home-state-emitter|g" \
       -e "s|sudo ||g" \
       "$REMOVE" >"$remove_copy"
chmod +x "$remove_copy"

# Create mock stub bin for package and systemctl calls
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$SYSTEMCTL_LOG"
if [[ $* == *"list-unit-files"* ]]; then
  echo "linux-enable-ir-emitter.service"
fi
exit 0
SH
cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin"/*

export SYSTEMCTL_LOG="$test_tmp/systemctl.log"
: >"$SYSTEMCTL_LOG"

# Scenario A: Emitter was pre-existing (no face-ir-emitter-enabled marker).
# Removal must NOT disable linux-enable-ir-emitter.service!
PATH="$stub_bin:$PATH" bash "$remove_copy" >/dev/null 2>&1 || true

[[ ! -d "$test_tmp/etc/howdy/models" ]] || fail "remove deletes /etc/howdy/models fixture"
[[ ! -d "$test_tmp/lib/security/howdy/models" ]] || fail "remove deletes /lib/security/howdy/models fixture"
[[ ! -d "$test_tmp/usr/local/etc/howdy/models" ]] || fail "remove deletes /usr/local/etc/howdy/models fixture"
pass "remove fixture cleanly deletes models from all three supported locations"

if grep -q "disable --now linux-enable-ir-emitter" "$SYSTEMCTL_LOG"; then
  fail "remove must not disable pre-existing IR emitter when setup did not enable it"
fi
pass "remove preserves pre-existing IR emitter when unmanaged"

# Scenario B: Emitter was enabled by face setup (marker present).
# Removal must disable the unit and clean the marker.
: >"$SYSTEMCTL_LOG"
touch "$test_tmp/face-ir-emitter-enabled"
PATH="$stub_bin:$PATH" bash "$remove_copy" >/dev/null 2>&1 || true

if ! grep -q "disable --now linux-enable-ir-emitter" "$SYSTEMCTL_LOG"; then
  fail "remove disables IR emitter service when face setup enabled it"
fi
[[ ! -f "$test_tmp/face-ir-emitter-enabled" ]] || fail "remove cleans the emitter marker file"
pass "remove disables IR emitter and clears marker when setup enabled it"

# 2. Verify setup camera validation updates Howdy's configured device_path on fallback
mkdir -p "$test_tmp/etc/howdy"
cat >"$test_tmp/etc/howdy/config.ini" <<'EOF'
[video]
device_path = /dev/video_dead_ir
EOF

setup_copy="$test_tmp/setup.sh"
sed -E -e "s:(^|[[:space:]])/etc/howdy/config.ini:\1$test_tmp/etc/howdy/config.ini:g" \
       -e "s|HOWDY_DIR=\"/lib/security/howdy\"|HOWDY_DIR=\"$test_tmp/lib/security/howdy\"|g" \
       -e "s|/dev/video\*|$test_tmp/dev/video*|g" \
       -e "s|/dev/v4l/by-path|$test_tmp/dev/v4l/by-path|g" \
       -e "s|sudo ||g" \
       "$SETUP" >"$setup_copy"

# Source the helper functions from setup_copy in an isolated subshell
bash -c '
set -euo pipefail
test_tmp="'"$test_tmp"'"
source "'"$setup_copy"'"

mkdir -p "$test_tmp/dev"
touch "$test_tmp/dev/video0" "$test_tmp/dev/video1"

# Mock can_capture_device to simulate configured device /dev/video_dead_ir failing and /dev/video1 working
can_capture_device() {
  local dev="$1"
  [[ $dev == *"/dev/video1" ]]
}

verify_camera_capture >/dev/null
grep -q "device_path = $test_tmp/dev/video1" "$test_tmp/etc/howdy/config.ini" || exit 1
' || fail "setup camera validation fails to update Howdy configured device_path to fallback device"
pass "setup camera validation updates Howdy configured device_path on fallback"

# 3. Verify setup enrollment checks target user specifically (does not skip on unrelated models)
bash -c '
set -euo pipefail
test_tmp="'"$test_tmp"'"
source "'"$setup_copy"'"

TARGET_USER="testuser"
mkdir -p "$test_tmp/etc/howdy/models"

# Case A: Only another user is enrolled
touch "$test_tmp/etc/howdy/models/otheruser.dat"
if verify_enrollment; then
  echo "verify_enrollment should have failed when only otheruser.dat exists" >&2
  exit 1
fi

# Case B: Target user has an empty file (silent failure)
touch "$test_tmp/etc/howdy/models/testuser.dat"
if verify_enrollment; then
  echo "verify_enrollment should have failed when testuser.dat is empty" >&2
  exit 1
fi

# Case C: Target user has non-empty model data
echo "model-data-bytes" >"$test_tmp/etc/howdy/models/testuser.dat"
if ! verify_enrollment; then
  echo "verify_enrollment should have passed when testuser.dat has data" >&2
  exit 1
fi
' || fail "setup enrollment verification does not properly scope to target user"
pass "setup enrollment verification requires non-empty model for the target user specifically"
