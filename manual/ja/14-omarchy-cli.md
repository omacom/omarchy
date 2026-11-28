# Omarchy CLI

Omarchy は通常、ホットキーと Omarchy メニュー（`Super + Space`）で操作します。しかし、`omarchy` CLI から操作することもできます。これは、AI エージェントにカスタマイズや設定を手伝ってもらっているときに特に便利です。

CLI からは、メニュー経由でもそれ以外でも使われる内部ツールのすべてにアクセスできます。ターミナルで `omarchy` を実行すれば、利用できるものすべてを確認できます。

だいたい次のような感じです：

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

診断を行うには、`omarchy-debug --no-sudo --print` を直接実行してください。sudo を求めることなく診断結果を表示し、`/tmp/omarchy-debug.log` に書き込みます。パッケージのインストール時など、`omarchy debug` が "Unknown Omarchy command" で失敗する場合でも使えます。

どのグループについても、さらに深く掘り下げることができます：

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

どのコマンドも `--help` に対応しています。グループ全体に対してでも（`omarchy capture --help`）、単体のコマンドに対してでも（`omarchy capture screenshot --help`）使えます。

### ターミナルからメニューを開く

Omarchy メニューはスクリプトからも操作できるので、独自のキーバインドに組み込むときに便利です。`omarchy menu` でルートから開け、名前を指定すればツリー内の任意の場所へ直接ジャンプできます：`omarchy menu summon appearance.theme` ならテーマピッカーへ直行し、`omarchy menu toggle system` ならシステムメニューを開き、すでに開いている場合は閉じます。そして `omarchy menu close` でしまうことができます。
