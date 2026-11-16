# Omarchy CLI

In genere Omarchy si controlla tramite le scorciatoie da tastiera e il menu Omarchy (`Super + Space`). Ma puoi controllarlo anche tramite la CLI `omarchy`. È particolarmente utile quando lavori con un agente AI per personalizzazioni o configurazioni.

La CLI ha accesso a tutti gli strumenti interni utilizzati sia tramite il menu sia in altro modo. Puoi vedere tutto ciò che è disponibile eseguendo `omarchy` nel terminale.

Si presenta più o meno così:

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

Per la diagnostica, esegui direttamente `omarchy-debug --no-sudo --print`. Stampa le informazioni di diagnostica e scrive `/tmp/omarchy-debug.log` senza chiedere sudo, anche nelle installazioni di pacchetti in cui `omarchy debug` può fallire con "Unknown Omarchy command".

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

Anche ogni comando accetta `--help`, sia che tu lo chieda per un intero gruppo (`omarchy capture --help`) sia per un singolo comando (`omarchy capture screenshot --help`).

### Aprire il menu dal terminale

Anche il menu Omarchy è scriptabile, il che è comodo per le tue scorciatoie personalizzate. `omarchy menu` lo apre alla radice, e puoi saltare direttamente a qualsiasi punto dell'albero indicandolo per nome: `omarchy menu summon appearance.theme` va dritto al selettore dei temi, `omarchy menu toggle system` apre il menu di sistema e lo chiude di nuovo se è già aperto, e `omarchy menu close` lo fa sparire.
