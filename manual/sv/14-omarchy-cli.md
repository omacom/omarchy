# Omarchy CLI

Omarchy styrs vanligtvis via snabbtangenterna och Omarchy-menyn (`Super + Space`). Men du kan också styra det via `omarchy` CLI. Detta är särskilt hjälpsamt när du låter en AI-agent arbeta med dig på anpassning eller konfiguration.

CLI:t har åtkomst till alla interna verktyg som används både via menyn och annars. Du kan se allt som är tillgängligt genom att köra `omarchy` i terminalen.

Det ser ut ungefär så här:

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

Och du kan dyka djupare i varje grupp:

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

Varje kommando tar också `--help`, oavsett om du frågar en hel grupp (`omarchy capture --help`) eller ett enskilt kommando (`omarchy capture screenshot --help`).

### Öppna menyn från terminalen

Omarchy-menyn är också skriptbar, vilket är praktiskt för dina egna tangentbindningar. `omarchy menu` öppnar den vid roten, och du kan hoppa direkt till valfri punkt i trädet genom att namnge den: `omarchy menu summon style.theme` går rakt till temaväljaren, `omarchy menu toggle system` öppnar systemmenyn och stänger den igen om den redan är uppe, och `omarchy menu close` lägger undan den.
