# Omarchy CLI

Omarchy thường được điều khiển qua các phím tắt và menu Omarchy (`Super + Space`). Nhưng bạn cũng có thể điều khiển nó qua CLI `omarchy`. Điều này đặc biệt hữu ích khi bạn có một AI agent làm việc cùng bạn về tùy chỉnh hoặc cấu hình.

CLI có quyền truy cập vào mọi công cụ nội bộ được dùng cả qua menu và bằng cách khác. Bạn có thể xem mọi thứ khả dụng bằng cách chạy `omarchy` trong terminal.

Nó trông giống như thế này:

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

Và bạn có thể đi sâu hơn vào mọi nhóm:

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

Mọi lệnh cũng nhận `--help`, dù bạn hỏi một nhóm toàn bộ (`omarchy capture --help`) hay một lệnh duy nhất (`omarchy capture screenshot --help`).

### Mở menu từ terminal

Menu Omarchy cũng có thể viết tập lệnh được, điều này tiện dụng cho các phím gán của riêng bạn. `omarchy menu` mở nó ở gốc, và bạn có thể nhảy thẳng tới bất kỳ điểm nào trong cây bằng cách đặt tên cho nó: `omarchy menu summon style.theme` đi thẳng tới bộ chọn chủ đề, `omarchy menu toggle system` mở menu hệ thống và đóng nó lại nếu nó đã hiển thị, và `omarchy menu close` cất nó đi.
