# Omarchy CLI

Omarchy genellikle kısayol tuşları ve Omarchy menüsü (`Super + Space`) aracılığıyla kontrol edilir. Ancak onu `omarchy` CLI aracılığıyla da kontrol edebilirsiniz. Bu, özellikle bir AI agent ile birlikte özelleştirme veya yapılandırma üzerinde çalışırken faydalıdır.

CLI, hem menü aracılığıyla hem de başka yollarla kullanılan tüm dahili araçlara erişebilir. Terminalde `omarchy` çalıştırarak mevcut olan her şeyi görebilirsiniz.

Görünümü aşağı yukarı şöyledir:

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

Ve her grubun derinliklerine de inebilirsiniz:

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

Her komut `--help` de kabul eder; ister bütün bir grubu (`omarchy capture --help`) ister tek bir komutu (`omarchy capture screenshot --help`) sorgulayın.

### Terminalden menüyü açma

Omarchy menüsü de scriptlenebilir; bu, kendi tuş atamalarınız için kullanışlıdır. `omarchy menu` onu kök düzeyde açar ve adını belirterek ağacın herhangi bir noktasına doğrudan atlayabilirsiniz: `omarchy menu summon appearance.theme` doğrudan tema seçiciye gider, `omarchy menu toggle system` sistem menüsünü açar ve zaten açıksa tekrar kapatır, `omarchy menu close` ise onu ortadan kaldırır.
