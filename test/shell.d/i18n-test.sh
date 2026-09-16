#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$DIR/../.." && pwd)"

node "$REPO_ROOT/test/shell.d/i18n-runtime-test.js"
echo "ok - i18n runtime test passed"
node "$DIR/i18n-notification-test.js"

echo "Testing omarchy-i18n shell command..."
I18N_BIN="$REPO_ROOT/bin/omarchy-i18n"
export OMARCHY_PATH="$REPO_ROOT"

# 1. Simplified Chinese translation
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "No QR code found")
[[ "$res" == "未找到二维码" ]] || { echo "Failed: expected 未找到二维码, got $res"; exit 1; }

# 2. Placeholder interpolation (2-arg form)
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Battery is down to %1%" "20")
[[ "$res" == "电池电量已降至 20%" ]] || { echo "Failed: expected 电池电量已降至 20%, got $res"; exit 1; }

# 3. Placeholder interpolation (3-arg form)
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Battery is down to %1%" "Battery is down to %1%" "20")
[[ "$res" == "电池电量已降至 20%" ]] || { echo "Failed: expected 电池电量已降至 20%, got $res"; exit 1; }

# 4. zh_SG alias
res=$(OMARCHY_UI_LANGUAGE=zh_SG bash "$I18N_BIN" "Battery is down to %1%" "20")
[[ "$res" == "电池电量已降至 20%" ]] || { echo "Failed: expected 电池电量已降至 20%, got $res"; exit 1; }

# 5. zh_TW isolation (must fallback to English)
res=$(OMARCHY_UI_LANGUAGE=zh_TW bash "$I18N_BIN" "Battery is down to %1%" "Battery is down to %1%" "20")
[[ "$res" == "Battery is down to 20%" ]] || { echo "Failed: expected Battery is down to 20%, got $res"; exit 1; }

# 6. en_US fallback
res=$(OMARCHY_UI_LANGUAGE=en_US bash "$I18N_BIN" "Battery is down to %1%" "Battery is down to %1%" "20")
[[ "$res" == "Battery is down to 20%" ]] || { echo "Failed: expected Battery is down to 20%, got $res"; exit 1; }

# 7. Migration pending notification
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Pending Omarchy Migrations")
[[ "$res" == "Omarchy 有待处理的迁移" ]] || { echo "Failed: expected Omarchy 有待处理的迁移, got $res"; exit 1; }

# 8. Literal-safe interpolation: & in dynamic value must not corrupt or backreference
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Transcoded to %1 %2" "A&B" "50%")
[[ "$res" == "已转码为 A&B 50%" ]] || { echo "Failed: expected 已转码为 A&B 50%, got $res"; exit 1; }

# 9. Literal-safe interpolation: backslashes, percent, file paths, metacharacters
res=$(OMARCHY_UI_LANGUAGE=en bash "$I18N_BIN" "%1 to %2 (%3)" "A&B" 'foo\bar' "100%")
[[ "$res" == 'A&B to foo\bar (100%)' ]] || { echo "Failed: expected A&B to foo\\bar (100%), got $res"; exit 1; }

res=$(OMARCHY_UI_LANGUAGE=en bash "$I18N_BIN" "Saved to %1" "Saved to %1" "/home/user/A&B/file.txt")
[[ "$res" == "Saved to /home/user/A&B/file.txt" ]] || { echo "Failed: expected /home/user/A&B/file.txt, got $res"; exit 1; }

# 10. Single-pass non-reentrant interpolation (%2 inside arg 1 must NOT expand)
res=$(OMARCHY_UI_LANGUAGE=en bash "$I18N_BIN" "%1 and %2" "%2" "final")
[[ "$res" == "%2 and final" ]] || { echo "Failed: expected '%2 and final', got $res"; exit 1; }

# 11. Metacharacters and command substitutions must remain inert literals
metachars='$(whoami) `date` $HOME * ? [ ] ; | > < ( ) '\'' "'
res=$(OMARCHY_UI_LANGUAGE=en bash "$I18N_BIN" "Value: %1" "$metachars")
[[ "$res" == "Value: $metachars" ]] || { echo "Failed: expected literal metacharacters, got $res"; exit 1; }

# Locale parity is exercised against both runtimes by the shared Node fixture runner.

# 13. Tailscale receive notification localization & & safety
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Received %1" "Received A&B.mp4" "A&B.mp4")
[[ "$res" == "已接收 A&B.mp4" ]] || { echo "Failed: expected 已接收 A&B.mp4, got $res"; exit 1; }

res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Saved to %1" "Saved to ~/Downloads" "~/Downloads")
[[ "$res" == "已保存到 ~/Downloads" ]] || { echo "Failed: expected 已保存到 ~/Downloads, got $res"; exit 1; }

# 14. Migration notification singular and plural tests
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Click to run 1 pending migration.")
[[ "$res" == "有 1 项待处理的迁移，点击运行。" ]] || { echo "Failed: expected 有 1 项待处理的迁移，点击运行。, got $res"; exit 1; }

res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Click to run %1 pending migrations." "Click to run %1 pending migrations." "2")
[[ "$res" == "有 2 项待处理的迁移，点击运行。" ]] || { echo "Failed: expected 有 2 项待处理的迁移，点击运行。, got $res"; exit 1; }

res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Click to run %1 pending migrations." "Click to run %1 pending migrations." "18")
[[ "$res" == "有 18 项待处理的迁移，点击运行。" ]] || { echo "Failed: expected 有 18 项待处理的迁移，点击运行。, got $res"; exit 1; }

# 15. File chooser prompt localization
res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Pick PNG or SVG for screensaver")
[[ "$res" == "选择用于屏幕保护的 PNG 或 SVG 图片" ]] || { echo "Failed: expected screensaver chooser prompt, got $res"; exit 1; }

res=$(OMARCHY_UI_LANGUAGE=zh_CN bash "$I18N_BIN" "Pick PNG or SVG for About")
[[ "$res" == "选择用于关于界面的 PNG 或 SVG 图片" ]] || { echo "Failed: expected about chooser prompt, got $res"; exit 1; }

echo "ok - omarchy-i18n shell command test passed"
