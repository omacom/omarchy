# Omarchy CLI

Omarchy 通常通过热键和 Omarchy 菜单（`Super + Space`）来操控。但你也可以通过 `omarchy` CLI 来操控它。当你让 AI agent 陪你一起做自定义或配置时，这一点尤其有用。

CLI 可以访问菜单及其他地方所用的全部内部工具。在终端里运行 `omarchy`，就能看到所有可用的东西。

它看起来大概是这样：

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
  omarchy-debug               Print debugging information

Groups:
  agent          AI coding agents, their usage, and subscription accounts
  ascii          Text drawn as ASCII art
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
  ...
```

要做诊断，直接运行 `omarchy-debug --no-sudo --print`。它会打印诊断信息，并写入 `/tmp/omarchy-debug.log`，不会提示输入 sudo，包括在软件包安装过程中也是如此；在那种情况下，`omarchy debug` 可能会以 "Unknown Omarchy command" 失败。

你还可以深入查看每个分组：

```
~ ❯ omarchy capture
Capture commands — Screenshots and screen recording:
  omarchy capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  omarchy capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording] [--status]  Start or stop screen recording
  omarchy capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  omarchy capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  omarchy capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  omarchy capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

每个命令也都支持 `--help`，无论你问的是整个分组（`omarchy capture --help`），还是单个命令（`omarchy capture screenshot --help`）。

### 从终端打开菜单

Omarchy 菜单同样可以脚本化，这对你自己的键绑定很方便。`omarchy menu` 会在根层级打开它，你也可以直接跳到树中的任意位置，只要点名即可：`omarchy menu summon appearance.theme` 会直达主题选择器，`omarchy menu toggle system` 会打开系统菜单，如果它已经打开则再关闭它，而 `omarchy menu close` 则会把它收起来。
