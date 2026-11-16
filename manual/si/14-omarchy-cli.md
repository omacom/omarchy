# Omarchy CLI

Omarchy සාමාන්‍යයෙන් පාලනය කරන්නේ hotkeys සහ Omarchy menu (`Super + Space`) එක හරහාය. නමුත් ඔබට එය `omarchy` CLI එක හරහා ද පාලනය කළ හැකිය. ඔබ අභිරුචිකරණය හෝ වින්‍යාසය සම්බන්ධයෙන් AI agent කෙනෙකු ඔබ සමඟ වැඩ කරවන විට මෙය විශේෂයෙන්ම ප්‍රයෝජනවත් වේ.

CLI එකට menu එක හරහා සහ වෙනත් ආකාරවලින් භාවිතා වන සියලුම අභ්‍යන්තර මෙවලම් වෙත ප්‍රවේශය ඇත. terminal එකේ `omarchy` ධාවනය කිරීමෙන් ලබා ගත හැකි සියල්ල ඔබට දැක ගත හැකිය.

එය මේ වගේ දෙයක් ලෙස පෙනේ:

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

ඔබට සෑම group එකක් ගැනම තවදුරටත් ගැඹුරින් බැලිය හැකිය:

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

සෑම command එකක්ම `--help` ද ලබා ගනී, ඔබ සම්පූර්ණ group එකක් (`omarchy capture --help`) හෝ තනි command එකක් (`omarchy capture screenshot --help`) ඇසුවත්.

### terminal එකෙන් menu එක විවෘත කිරීම

Omarchy menu එක script කළ හැකි ද වේ, එය ඔබේම keybindings සඳහා පහසු වේ. `omarchy menu` එය root එකේ විවෘත කරයි, ඔබට එය නම් කිරීමෙන් tree එකේ ඕනෑම ස්ථානයකට කෙලින්ම යා හැකිය: `omarchy menu summon appearance.theme` theme picker එකට කෙලින්ම යයි, `omarchy menu toggle system` system menu එක විවෘත කරන අතර එය දැනටමත් විවෘත නම් නැවත එය වසා දමයි, සහ `omarchy menu close` එය ඉවත් කරයි.
