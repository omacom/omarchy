# Omarchy CLI

Omarchy thường được điều khiển qua các phím tắt và menu Omarchy (`Super + Space`). Nhưng bạn cũng có thể điều khiển nó qua CLI `omarchy`. Điều này đặc biệt hữu ích khi bạn đang để một AI agent làm việc cùng bạn về tùy chỉnh hoặc cấu hình.

CLI có quyền truy cập vào toàn bộ công cụ nội bộ được dùng cả qua menu lẫn theo các cách khác. Bạn có thể thấy mọi thứ có sẵn bằng cách chạy `omarchy` trong terminal.

Nó trông đại khái như thế này:

```
~ ❯ omarchy
Omarchy command center

Usage:
  omarchy <command> [args...]
  omarchy commands [--all] [--json] [--check]
  omarchy <group> --help
  omarchy <group> <command> --help

Common commands:
  omarchy update              Update Omarchy and system packages
  omarchy theme list          List available themes
  omarchy theme set <name>    Apply a theme
  omarchy font list           List available fonts
  omarchy screenshot          Take a screenshot
  omarchy debug               Print debugging information

Groups:
  agent          AI coding agents, their usage, and subscription accounts
  audio          Audio input and output controls
  bar            Omarchy shell bar layout and settings
  battery        Battery status helpers
  bluetooth      Bluetooth device controls
  branch         Omarchy git branch management
  branding       About and screensaver branding
  brightness     Display and keyboard brightness
  capture        Screenshots and screen recording
  channel        Omarchy release channel management
  clipboard      Clipboard helpers
  cmd            Command and shortcut helpers
  config         System configuration helpers
  debug          Diagnostics and support logs
  ...
```

Và bạn có thể đi sâu hơn vào từng nhóm:

```
~ ❯ omarchy capture
Capture commands — Screenshots and screen recording:
  omarchy capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  omarchy capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording]  Start or stop screen recording
  omarchy capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  omarchy capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  omarchy capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  omarchy capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

Mọi lệnh cũng đều nhận `--help`, dù bạn hỏi cả một nhóm (`omarchy capture --help`) hay một lệnh đơn lẻ (`omarchy capture screenshot --help`).

### Mở menu từ terminal

Menu Omarchy cũng có thể được điều khiển bằng script, điều này rất tiện cho các keybinding của riêng bạn. `omarchy menu` mở nó ở cấp gốc, và bạn có thể nhảy thẳng đến bất kỳ điểm nào trong cây bằng cách gọi tên nó: `omarchy menu summon appearance.theme` đi thẳng đến trình chọn theme, `omarchy menu toggle system` mở menu hệ thống và đóng lại nếu nó đang mở, và `omarchy menu close` đóng nó đi.
