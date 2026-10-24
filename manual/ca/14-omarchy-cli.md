# CLI d'Omarchy

Omarchy normalment es controla mitjançant les dreceres i el menú d'Omarchy (`Super + Space`). Però també el podeu controlar mitjançant la CLI `omarchy`. Això és especialment útil quan teniu un agent d'IA treballant amb vosaltres en la personalització o la configuració.

La CLI té accés a totes les eines internes que es fan servir tant des del menú com d'altres maneres. Podeu veure tot el que hi ha disponible executant `omarchy` al terminal.

És una cosa així:

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

I podeu aprofundir en cada grup:

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

Cada ordre també accepta `--help`, tant si demaneu a tot un grup (`omarchy capture --help`) com a una sola ordre (`omarchy capture screenshot --help`).

### Obrir el menú des del terminal

El menú d'Omarchy també es pot programar, cosa útil per a les vostres pròpies dreceres. `omarchy menu` l'obre a l'arrel, i podeu saltar directament a qualsevol punt de l'arbre anomenant-lo: `omarchy menu summon style.theme` va directament al selector de temes, `omarchy menu toggle system` obre el menú del sistema i el torna a tancar si ja és obert, i `omarchy menu close` el desa.
