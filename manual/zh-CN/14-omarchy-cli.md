# Omarchy CLI

Omarchy 通常通过快捷键和 Omarchy 菜单（`Super + Space`）来控制。但你也可以通过 `omarchy` CLI 来控制它。当你让 AI 智能体与你一起进行自定义或配置时，这尤其有帮助。

CLI 可以访问通过菜单和其他方式使用的所有内部工具。你可以在终端中运行 `omarchy` 查看所有可用内容。

它看起来像这样：

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

你可以深入了解每个组：

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

每个命令也都接受 `--help`，无论你是询问整个组（`omarchy capture --help`）还是单个命令（`omarchy capture screenshot --help`）。

### 从终端打开菜单

Omarchy 菜单也可以脚本化，这对于你自己的键盘绑定很方便。`omarchy menu` 在根处打开它，你可以通过命名直接跳转到树中的任意点：`omarchy menu summon style.theme` 直接转到主题选择器，`omarchy menu toggle system` 打开系统菜单，如果它已经打开则再次关闭它，`omarchy menu close` 将其收起。
