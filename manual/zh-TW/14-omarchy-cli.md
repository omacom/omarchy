# Omarchy CLI

Omarchy 通常是透過快捷鍵和 Omarchy 選單 (`Super + Space`) 來控制。但你也可以透過 `omarchy` CLI 來控制它。當你讓 AI agent 陪你一起進行客製化或設定時，這特別有幫助。

CLI 可以存取所有透過選單及其他方式使用的內部工具。你可以在終端機執行 `omarchy`，查看所有可用的內容。

它看起來大概像這樣：

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

若要進行診斷，請直接執行 `omarchy-debug --no-sudo --print`。它會印出診斷資訊並寫入 `/tmp/omarchy-debug.log`，且不會提示輸入 sudo，包括在某些套件安裝情況下，`omarchy debug` 可能會失敗並顯示 "Unknown Omarchy command"。

而且你還可以深入查看每個群組：

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

每個命令也都支援 `--help`，無論你是查詢整個群組 (`omarchy capture --help`) 還是單一命令 (`omarchy capture screenshot --help`)。

### 從終端機開啟選單

Omarchy 選單也可以用指令碼控制，這對你自己的快捷鍵綁定很方便。`omarchy menu` 會在根目錄開啟它，你也可以直接指定名稱跳到樹狀結構中的任何位置：`omarchy menu summon appearance.theme` 會直接前往主題選擇器，`omarchy menu toggle system` 會開啟系統選單，若已開啟則會再次將它關閉，而 `omarchy menu close` 則會將它收起。
