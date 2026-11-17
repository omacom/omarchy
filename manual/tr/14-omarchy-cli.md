# Omarchy CLI

Omarchy genellikle kısayol tuşları ve Omarchy menüsü (`Super + Space`) üzerinden kontrol edilir. Ancak `omarchy` CLI üzerinden de kontrol edebilirsiniz. Bu, özellikle bir AI agent ile birlikte özelleştirme veya yapılandırma üzerinde çalışırken faydalıdır.

CLI, hem menü üzerinden hem de başka yollarla kullanılan tüm dahili araçlara erişime sahiptir. Terminalde `omarchy` çalıştırarak mevcut olan her şeyi görebilirsiniz.

Görünümü şuna benzer:

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

Tanılama için doğrudan `omarchy-debug --no-sudo --print` çalıştırın. Sudo istemeden tanılama çıktısını yazdırır ve `/tmp/omarchy-debug.log` dosyasına yazar; bu, `omarchy debug` komutunun "Unknown Omarchy command" hatasıyla başarısız olabildiği paket kurulumlarında da geçerlidir.

Ve her grupta daha derine inebilirsiniz:

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

Her komut `--help` de kabul eder; ister tüm bir grubu (`omarchy capture --help`) ister tek bir komutu (`omarchy capture screenshot --help`) sorgulayın.

### Menüyü terminalden açma

Omarchy menüsü de scriptlenebilir, bu da kendi tuş atamalarınız için kullanışlıdır. `omarchy menu` menüyü kök düzeyde açar ve adını belirterek ağaçtaki herhangi bir noktaya doğrudan atlayabilirsiniz: `omarchy menu summon appearance.theme` doğrudan tema seçiciye gider, `omarchy menu toggle system` sistem menüsünü açar ve zaten açıksa tekrar kapatır, `omarchy menu close` ise menüyü kaldırır.
