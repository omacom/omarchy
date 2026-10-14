# Omarchy CLI

Omarchy di solito si controlla tramite le scorciatoie e il menu Omarchy (`Super + Space`). Ma puoi anche controllarlo tramite la CLI `omarchy`. Questo è particolarmente utile quando hai un agente AI che lavora con te su personalizzazione o configurazione.

La CLI ha accesso a tutti gli strumenti interni usati sia tramite il menu che altrimenti. Puoi vedere tutto ciò che è disponibile eseguendo `omarchy` nel terminale.

Ha un aspetto simile a questo:

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

E puoi approfondire ogni gruppo:

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

Ogni comando accetta anche `--help`, che tu chieda un intero gruppo (`omarchy capture --help`) o un singolo comando (`omarchy capture screenshot --help`).

### Aprire il menu da terminale

Anche il menu Omarchy è scriptabile, il che è comodo per le tue combinazioni. `omarchy menu` lo apre alla radice, e puoi saltare dritto a qualsiasi punto dell'albero nominandolo: `omarchy menu summon style.theme` va dritto al selettore del tema, `omarchy menu toggle system` apre il menu di sistema e lo chiude di nuovo se è già aperto, e `omarchy menu close` lo mette via.
