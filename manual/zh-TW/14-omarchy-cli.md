# Omarchy CLI

Omarchy 通常是透過熱鍵與 Omarchy 選單（`Super + Space`）來操作。但你也可以透過 `omarchy` CLI 來控制它。當你讓 AI agent 協助你進行客製化或設定時，這特別有幫助。

此 CLI 可存取所有內部工具，這些工具既會透過選單使用，也會用於其他用途。你只要在終端機執行 `omarchy`，就能看到所有可用項目。

大概長這樣：

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

你也可以深入查看每個群組：

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

每個指令也都支援 `--help`，無論你查詢的是整個群組（`omarchy capture --help`）還是單一指令（`omarchy capture screenshot --help`）。

### 從終端機開啟選單

Omarchy 選單也可以透過指令碼控制，方便你設定自己的按鍵綁定。`omarchy menu` 會將它開啟在根層級，而你也可以直接指定名稱，跳到樹狀結構中的任何位置：`omarchy menu summon appearance.theme` 會直接進入主題選擇器，`omarchy menu toggle system` 會開啟系統選單，若它已經開啟則會將它關閉，而 `omarchy menu close` 則會將它收起。
