# Omarchy CLI

Omarchy biasanya dikendalikan melalui hotkey dan menu Omarchy (`Super + Space`). Tetapi kamu juga bisa mengendalikannya melalui CLI `omarchy`. Ini sangat membantu ketika kamu meminta agent AI bekerja bersamamu dalam kustomisasi atau konfigurasi.

CLI ini memiliki akses ke semua tooling internal yang digunakan baik melalui menu maupun cara lainnya. Kamu bisa melihat semua yang tersedia dengan menjalankan `omarchy` di terminal.

Tampilannya kurang lebih seperti ini:

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

Dan kamu bisa menyelami lebih dalam setiap grup:

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

Setiap perintah juga menerima `--help`, baik kamu menanyakan seluruh grup (`omarchy capture --help`) maupun satu perintah saja (`omarchy capture screenshot --help`).

### Membuka menu dari terminal

Menu Omarchy juga bisa di-script, yang berguna untuk keybinding kamu sendiri. `omarchy menu` membukanya di root, dan kamu bisa langsung melompat ke titik mana pun di tree dengan menyebut namanya: `omarchy menu summon appearance.theme` langsung menuju ke pemilih tema, `omarchy menu toggle system` membuka menu sistem dan menutupnya lagi jika sudah tampil, dan `omarchy menu close` menyembunyikannya.
