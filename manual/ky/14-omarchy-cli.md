# Omarchy CLI

Omarchy адатта баскыч айкалыштары жана Omarchy менюсу (`Super + Space`) аркылуу башкарылат. Бирок аны `omarchy` CLI аркылуу да башкарсаңыз болот. Бул өзгөчө жасалгалоо же жөндөө боюнча сиз менен бирге AI агенти иштеп жатканда ыңгайлуу.

CLI менюда да, башка жерлерде да колдонулган бардык ички куралдарга жетет. Эмнелер бар экенин терминалда `omarchy` иштетип көрө аласыз.

Ал болжол менен мындай көрүнөт:

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
  ascii          Text drawn as ASCII art
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

Диагностика үчүн `omarchy-debug --no-sudo --print` түз иштетиңиз. Ал sudo сурабастан диагностиканы чыгарып, `/tmp/omarchy-debug.log` жазат, анын ичинде `omarchy debug` "Unknown Omarchy command" деген ката менен иштебей калышы мүмкүн болгон пакеттик орнотууларда да.

Ар бир топту тереңирээк да изилдесеңиз болот:

```
~ ❯ omarchy capture
Capture commands — Screenshots and screen recording:
  omarchy capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  omarchy capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording] [--status]  Start or stop screen recording
  omarchy capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  omarchy capture screenshot [smart|region|windows|fullscreen|scroll] [copy|save]                                                                                                                                          Take a screenshot
  omarchy capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  omarchy capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

Ар бир буйрук `--help` да кабыл алат, бүтүндөй топту (`omarchy capture --help`) сурасаңыз да, бир буйрукту (`omarchy capture screenshot --help`) сурасаңыз да.

### Менюну терминалдан ачуу

Omarchy менюсун скрипт менен да башкарса болот, бул өз баскыч айкалыштарыңыз үчүн ыңгайлуу. `omarchy menu` аны башкы бетинде ачат, ал эми дарактын каалаган чекитине анын атын айтып эле түз өтсөңүз болот: `omarchy menu summon appearance.theme` тема тандагычка түз алып барат, `omarchy menu toggle system` тутум менюсун ачат, эгер ал ачык турса жабат, ал эми `omarchy menu close` аны жабат.
