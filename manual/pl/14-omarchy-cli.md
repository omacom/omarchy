# CLI Omarchy

Omarchy zwykle steruje się przez skróty oraz menu Omarchy (`Super + Space`). Ale możesz też sterować nim przez CLI `omarchy`. Jest to szczególnie pomocne, gdy pracujesz z agentem AI nad dostosowywaniem lub konfiguracją.

CLI ma dostęp do wszystkich wewnętrznych narzędzi używanych zarówno z menu, jak i w inny sposób. Wszystko, co jest dostępne, zobaczysz, uruchamiając `omarchy` w terminalu.

Wygląda to mniej więcej tak:

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

A do każdej grupy możesz wejść głębiej:

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

Każde polecenie przyjmuje też `--help`, niezależnie od tego, czy zapytasz całą grupę (`omarchy capture --help`), czy pojedyncze polecenie (`omarchy capture screenshot --help`).

### Otwieranie menu z terminala

Menu Omarchy jest też skryptowalne, co jest przydatne do własnych przypisań klawiszy. `omarchy menu` otwiera je u nasady, a możesz wskoczyć wprost do dowolnego punktu drzewa, nazywając go: `omarchy menu summon style.theme` idzie od razu do wyboru motywu, `omarchy menu toggle system` otwiera menu systemowe i zamyka je ponownie, jeśli jest już otwarte, a `omarchy menu close` je chowa.
