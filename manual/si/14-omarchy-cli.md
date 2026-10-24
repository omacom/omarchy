# Omarchy CLI

Omarchy සාමාන්‍යයෙන් පාලනය වන්නේ උණුසුම් යතුරු සහ Omarchy මෙනුව (`Super + Space`) හරහායි. නමුත් ඔබට එය `omarchy` CLI හරහා ද පාලනය කළ හැකිය. ඔබ අභිරුචිකරණය හෝ වින්‍යාසය පිළිබඳව AI නියෝජිතයෙකු ඔබ සමඟ වැඩ කරන විට මෙය විශේෂයෙන් ප්‍රයෝජනවත් වේ.

CLI එකට මෙනුව හරහා සහ වෙනත් ආකාරයකින් භාවිතා කරන සියලුම අභ්‍යන්තර මෙවලම් වෙත ප්‍රවේශය ඇත. ටර්මිනලයේ `omarchy` ධාවනය කිරීමෙන් ලබා ගත හැකි සියල්ල ඔබට දැකිය හැකිය.

එය මේ වගේ දෙයක් පෙනේ:

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

ඔබට සෑම කණ්ඩායමක් පිළිබඳවම ගැඹුරට කිමිදිය හැකිය:

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

ඔබ මුළු කණ්ඩායමක් (`omarchy capture --help`) හෝ තනි විධානයක් (`omarchy capture screenshot --help`) ඇසුවත් සෑම විධානයක්ම `--help` ද ගනී.

### ටර්මිනලයෙන් මෙනුව විවෘත කිරීම

Omarchy මෙනුව ස්ක්‍රිප්ට් කළ හැකි අතර, එය ඔබේම යතුරු බන්ධන සඳහා ප්‍රයෝජනවත් වේ. `omarchy menu` එය මූලයේ විවෘත කරන අතර, ඔබට එය නම් කිරීමෙන් ගසේ ඕනෑම ස්ථානයකට කෙලින්ම පැනිය හැකිය: `omarchy menu summon style.theme` කෙලින්ම තේමා තේරීමට යයි, `omarchy menu toggle system` පද්ධති මෙනුව විවෘත කරන අතර එය දැනටමත් ඉහළට පැමිණ ඇත්නම් එය නැවත වසයි, සහ `omarchy menu close` එය ඉවත් කරයි.
