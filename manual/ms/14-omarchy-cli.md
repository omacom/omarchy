# Omarchy CLI

Omarchy biasanya dikawal melalui kekunci pintas dan menu Omarchy (`Super + Space`). Tetapi anda juga boleh mengawalnya melalui CLI `omarchy`. Ini amat membantu apabila anda meminta ejen AI bekerjasama dengan anda untuk penyesuaian atau konfigurasi.

CLI ini mempunyai akses kepada semua perkakas dalaman yang digunakan melalui menu dan juga sebaliknya. Anda boleh melihat semua yang tersedia dengan menjalankan `omarchy` dalam terminal.

Ia kelihatan lebih kurang seperti ini:

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

Dan anda boleh menyelami setiap kumpulan dengan lebih mendalam:

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

Setiap arahan juga menerima `--help`, sama ada anda bertanya kepada keseluruhan kumpulan (`omarchy capture --help`) atau satu arahan sahaja (`omarchy capture screenshot --help`).

### Membuka menu dari terminal

Menu Omarchy juga boleh diskrip, yang berguna untuk ikatan kekunci anda sendiri. `omarchy menu` membukanya pada peringkat akar, dan anda boleh melompat terus ke mana-mana titik dalam pepohon dengan menamakannya: `omarchy menu summon appearance.theme` terus pergi ke pemilih tema, `omarchy menu toggle system` membuka menu sistem dan menutupnya semula jika ia sudah terbuka, dan `omarchy menu close` menyimpannya.
