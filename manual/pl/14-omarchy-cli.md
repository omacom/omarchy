# Omarchy CLI

Omarchy zwykle obsługuje się za pomocą skrótów klawiszowych i menu Omarchy (`Super + Space`). Można nią jednak sterować także przez CLI `omarchy`. Jest to szczególnie pomocne, gdy agent AI współpracuje z Tobą nad dostosowywaniem lub konfiguracją.

CLI ma dostęp do wszystkich wewnętrznych narzędzi używanych zarówno przez menu, jak i w inny sposób. Wszystko, co jest dostępne, zobaczysz po uruchomieniu `omarchy` w terminalu.

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

Możesz też zajrzeć głębiej do każdej grupy:

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

Menu Omarchy można też obsługiwać skryptami, co przydaje się przy własnych skrótach klawiszowych. `omarchy menu` otwiera je na poziomie głównym, a podając nazwę, możesz przejść od razu do dowolnego miejsca w drzewie: `omarchy menu summon appearance.theme` prowadzi prosto do wyboru motywu, `omarchy menu toggle system` otwiera menu systemowe i zamyka je ponownie, jeśli jest już otwarte, a `omarchy menu close` je chowa.
