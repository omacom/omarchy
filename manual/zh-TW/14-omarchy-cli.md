# Omarchy CLI

Omarchy 通常是透過快捷鍵與 Omarchy 選單（`Super + Space`）來控制。不過你也可以透過 `omarchy` CLI 來控制它。當你讓 AI agent 陪你一起進行自訂或設定時，這特別有幫助。

CLI 可以取用選單以及其他各處所使用的所有內部工具。你只要在終端機裡執行 `omarchy`，就能看到所有可用的項目。

看起來大概會像這樣：

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

而且你可以更深入地查看每個群組：

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

每個命令也都支援 `--help`，無論你要查詢的是整個群組（`omarchy capture --help`）還是單一命令（`omarchy capture screenshot --help`）。

### 從終端機開啟選單

Omarchy 選單同樣可以用 script 控制，這在你設定自己的按鍵綁定時很方便。`omarchy menu` 會從根層級開啟它，而你只要為它命名，就能直接跳到樹狀結構中的任何位置：`omarchy menu summon appearance.theme` 會直接前往主題選擇器，`omarchy menu toggle system` 會開啟系統選單、如果選單已經開啟則再次將它關閉，而 `omarchy menu close` 則會將它收起來。
