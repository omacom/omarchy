# Omarchy CLI

Omarchy genellikle kısayollar ve Omarchy menüsü (`Super + Space`) yoluyla denetlenir. Ancak onu `omarchy` CLI yoluyla da denetleyebilirsiniz. Bu, özellikle bir AI ajanını özelleştirme veya yapılandırma konusunda sizinle çalıştırırken yararlıdır.

CLI, hem menü yoluyla hem de başka şekilde kullanılan tüm dahili araçlara erişime sahiptir. Terminalde `omarchy` çalıştırarak kullanılabilir her şeyi görebilirsiniz.

Şöyle bir şeye benzer:

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

Ve her gruba daha derine inebilirsiniz:

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

Her komut `--help` de alır; ister tüm bir grubu sorun (`omarchy capture --help`) ister tek bir komutu sorun (`omarchy capture screenshot --help`).

### Menüyü terminalden açmak

Omarchy menüsü de betiklenebilir; bu kendi tuş bağlamalarınız için kullanışlıdır. `omarchy menu` onu kökte açar ve adını vererek ağaçtaki herhangi bir noktaya doğrudan atlayabilirsiniz: `omarchy menu summon style.theme` doğrudan tema seçiciye gider, `omarchy menu toggle system` sistem menüsünü açar ve zaten açıksa tekrar kapatır ve `omarchy menu close` onu kaldırır.
