# Omarchy CLI

Omarchy 通常透過快捷鍵和 Omarchy 選單（`Super + Space`）來控制。但你也可以透過 `omarchy` CLI 來控制它。當你讓 AI 代理程式和你一起處理自訂或設定時，這特別有幫助。

這個 CLI 可以存取所有透過選單以及其他方式使用的內部工具。在終端機中執行 `omarchy`，你就可以看到所有可用的東西。

它看起來像這樣：

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

而你可以深入每一個群組：

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

每一個指令也都接受 `--help`，無論你問的是一整個群組（`omarchy capture --help`）還是單一個指令（`omarchy capture screenshot --help`）。

### 從終端機開啟選單

Omarchy 選單也可以用腳本控制，這對你自己的快捷鍵很有用。`omarchy menu` 會在根目錄開啟它，而你可以透過命名直接跳到樹狀結構中的任何一點：`omarchy menu summon style.theme` 會直接前往主題選擇器，`omarchy menu toggle system` 會開啟系統選單，若它已經開啟則再次關閉，而 `omarchy menu close` 會把它收起來。
