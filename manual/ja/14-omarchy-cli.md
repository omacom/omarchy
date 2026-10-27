# Omarchy CLI

Omarchy は通常、ホットキーと Omarchy メニュー（`Super + Space`）で操作します。しかし、`omarchy` CLI からも操作できます。これは、AI エージェントにカスタマイズや設定を手伝ってもらうときに特に便利です。

CLI からは、メニュー経由などで使われている内部ツールのすべてにアクセスできます。利用可能なものはすべて、ターミナルで `omarchy` を実行すれば確認できます。

だいたいこんな感じです：

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

さらに、各グループについても詳しく見られます：

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

すべてのコマンドでも `--help` が使えます。グループ全体（`omarchy capture --help`）でも、個別のコマンド（`omarchy capture screenshot --help`）でも同様です。

### ターミナルからメニューを開く

Omarchy メニューはスクリプトからも操作でき、独自のキーバインドを作るときに便利です。`omarchy menu` でルートから開きます。名前を指定すれば、ツリー内の任意の場所へ直接移動できます：`omarchy menu summon appearance.theme` はテーマピッカーへ直行し、`omarchy menu toggle system` はシステムメニューを開き、すでに開いている場合は閉じます。`omarchy menu close` で閉じます。
