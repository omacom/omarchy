# Omarchy CLI

Normalmente, Omarchy se controla mediante las teclas de acceso rápido y el menú de Omarchy (`Super + Space`). Pero también puedes controlarlo mediante la CLI `omarchy`. Esto es especialmente útil cuando tienes a un agente de IA trabajando contigo en la personalización o la configuración.

La CLI tiene acceso a todas las herramientas internas que se usan tanto desde el menú como por otros medios. Puedes ver todo lo que está disponible ejecutando `omarchy` en la terminal.

Se ve más o menos así:

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

Y puedes profundizar en cada grupo:

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

Todo comando también admite `--help`, ya sea que consultes un grupo completo (`omarchy capture --help`) o un solo comando (`omarchy capture screenshot --help`).

### Abrir el menú desde la terminal

El menú de Omarchy también se puede controlar mediante comandos, lo que viene bien para tus propios atajos de teclado. `omarchy menu` lo abre en la raíz, y puedes saltar directamente a cualquier punto del árbol nombrándolo: `omarchy menu summon appearance.theme` va directo al selector de temas, `omarchy menu toggle system` abre el menú del sistema y lo vuelve a cerrar si ya está abierto, y `omarchy menu close` lo oculta.
