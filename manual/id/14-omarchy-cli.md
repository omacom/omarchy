# CLI Omarchy

Omarchy biasanya dikontrol melalui hotkey dan menu Omarchy (`Super + Space`). Namun Anda juga dapat mengontrolnya melalui CLI `omarchy`. Ini sangat membantu ketika Anda memiliki agen AI yang bekerja dengan Anda dalam kustomisasi atau konfigurasi.

CLI memiliki akses ke semua perkakas internal yang digunakan baik melalui menu maupun sebaliknya. Anda dapat melihat semua yang tersedia dengan menjalankan `omarchy` di terminal.

Ia terlihat seperti ini:

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

Dan Anda dapat menyelami lebih dalam pada setiap grup:

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

Setiap perintah juga menerima `--help`, apakah Anda menanyakan seluruh grup (`omarchy capture --help`) atau satu perintah (`omarchy capture screenshot --help`).

### Membuka menu dari terminal

Menu Omarchy juga dapat diskrip, yang berguna untuk keybinding Anda sendiri. `omarchy menu` membukanya di akar, dan Anda dapat langsung melompat ke titik mana pun dalam pohon dengan menamainya: `omarchy menu summon style.theme` langsung menuju pemilih tema, `omarchy menu toggle system` membuka menu sistem dan menutupnya lagi jika sudah terbuka, dan `omarchy menu close` menutupnya.
