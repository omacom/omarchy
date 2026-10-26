# Omarchy CLI

Omarchy se contrôle habituellement via les raccourcis clavier et le menu Omarchy (`Super + Space`). Mais vous pouvez aussi le contrôler via la CLI `omarchy`. C'est particulièrement utile lorsque vous faites travailler un agent IA avec vous sur la personnalisation ou la configuration.

La CLI a accès à tous les outils internes utilisés à la fois via le menu et autrement. Vous pouvez voir tout ce qui est disponible en exécutant `omarchy` dans le terminal.

Cela ressemble à quelque chose comme ceci :

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

Et vous pouvez explorer chaque groupe plus en détail :

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

Chaque commande accepte aussi `--help`, que vous interrogiez un groupe entier (`omarchy capture --help`) ou une seule commande (`omarchy capture screenshot --help`).

### Ouvrir le menu depuis le terminal

Le menu Omarchy est également scriptable, ce qui est pratique pour vos propres raccourcis clavier. `omarchy menu` l'ouvre à la racine, et vous pouvez sauter directement à n'importe quel point de l'arborescence en le nommant : `omarchy menu summon appearance.theme` va directement au sélecteur de thème, `omarchy menu toggle system` ouvre le menu système et le referme s'il est déjà affiché, et `omarchy menu close` le masque.
