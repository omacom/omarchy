# Omarchy CLI

Omarchy は通常、ホットキーと Omarchy メニュー（`Super + Space`）で操作する。だが、`omarchy` CLI からも操作できる。AI エージェントにカスタマイズや設定を手伝わせているときは特に便利だ。

この CLI は、メニュー経由でもそれ以外でも使われる内部ツールすべてにアクセスできる。利用可能なものはすべて、ターミナルで `omarchy` を実行すれば確認できる。

こんな感じだ:

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

診断には、`omarchy-debug --no-sudo --print` を直接実行する。これで sudo の入力を求められることなく診断情報が表示され、`/tmp/omarchy-debug.log` に書き込まれる。パッケージのインストール時のように、`omarchy debug` が "Unknown Omarchy command" で失敗する場合でも使える。

さらに、すべてのグループを掘り下げることもできる:

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

どのコマンドも `--help` に対応している。グループ全体に聞いても（`omarchy capture --help`）、単一のコマンドに聞いても（`omarchy capture screenshot --help`）使える。

### ターミナルからメニューを開く

Omarchy メニューはスクリプトからも操作できる。独自のキーバインドを作るときに便利だ。`omarchy menu` でルートから開き、名前を指定すればツリー内の任意の場所へ直接ジャンプできる: `omarchy menu summon appearance.theme` ならテーマピッカーへまっすぐ進み、`omarchy menu toggle system` ならシステムメニューを開き、すでに開いている場合は閉じ、`omarchy menu close` で片付ける。
