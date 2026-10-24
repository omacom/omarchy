# Omarchy CLI

Omarchy は通常、ホットキーと Omarchy メニュー（`Super + Space`）から制御します。しかし `omarchy` CLI からも制御できます。これは、AI エージェントにカスタマイズや設定を一緒にやってもらうときに特に役立ちます。

CLI は、メニュー経由やそれ以外で使われるすべての内部ツールにアクセスできます。ターミナルで `omarchy` を実行すると、利用可能なもののすべてが見えます。

こんな感じです：

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

そしてすべてのグループをより深く掘り下げることもできます：

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

すべてのコマンドは `--help` も受け付けます。グループ全体でも（`omarchy capture --help`）、単一のコマンドでも（`omarchy capture screenshot --help`）です。

### ターミナルからメニューを開く

Omarchy メニューはスクリプト化もでき、自分のキーバインドに便利です。`omarchy menu` はルートで開き、名前を指定するとツリーの任意のポイントへ直接ジャンプできます：`omarchy menu summon style.theme` はテーマピッカーへ直接行き、`omarchy menu toggle system` はシステムメニューを開き、すでに開いていれば再び閉じ、`omarchy menu close` は片付けます。
