# Omarchy CLI

Omarchy zwykle steruje się za pomocą skrótów klawiszowych i menu Omarchy (`Super + Space`). Ale możesz nim sterować również za pomocą CLI `omarchy`. Jest to szczególnie pomocne, gdy współpracujesz z agentem AI przy dostosowywaniu lub konfiguracji.

CLI ma dostęp do wszystkich wewnętrznych narzędzi, które są używane zarówno przez menu, jak i w inny sposób. Możesz zobaczyć wszystko, co jest dostępne, uruchamiając `omarchy` w terminalu.

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

A w każdej grupie możesz zejść głębiej:

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

Każde polecenie przyjmuje też `--help`, niezależnie od tego, czy zapytasz o całą grupę (`omarchy capture --help`), czy o pojedyncze polecenie (`omarchy capture screenshot --help`).

### Otwieranie menu z terminala

Menu Omarchy można również skryptować, co przydaje się przy własnych skrótach klawiszowych. `omarchy menu` otwiera je na poziomie głównym, a możesz przejść prosto do dowolnego miejsca w drzewie, nazywając je: `omarchy menu summon appearance.theme` trafia prosto do wyboru motywu, `omarchy menu toggle system` otwiera menu systemowe i zamyka je ponownie, jeśli już jest otwarte, a `omarchy menu close` je zamyka.
