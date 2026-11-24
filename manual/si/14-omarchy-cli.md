# Omarchy CLI

Omarchy සාමාන්‍යයෙන් පාලනය කරන්නේ කෙටිමං යතුරු සහ Omarchy menu එක (`Super + Space`) හරහාය. නමුත් ඔබට එය `omarchy` CLI එක හරහාද පාලනය කළ හැකිය. ඔබ සමඟ එක්ව අභිරුචිකරණය හෝ වින්‍යාස කිරීම සිදු කිරීමට AI agent කෙනෙකු ලවා වැඩ කරවන විට මෙය විශේෂයෙන් උපකාරී වේ.

menu එක හරහා සහ වෙනත් ආකාරවලින් භාවිතා කරන සියලුම අභ්‍යන්තර මෙවලම් වෙත CLI එකට ප්‍රවේශය ඇත. terminal එකේ `omarchy` ධාවනය කිරීමෙන් ලබා ගත හැකි සියල්ල ඔබට දැක ගත හැකිය.

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

රෝග විනිශ්චය සඳහා, `omarchy-debug --no-sudo --print` කෙලින්ම ධාවනය කරන්න. එය රෝග විනිශ්චය තොරතුරු මුද්‍රණය කරන අතර sudo සඳහා විමසීමකින් තොරව `/tmp/omarchy-debug.log` වෙත ලියයි, `omarchy debug` එක "Unknown Omarchy command" යනුවෙන් අසාර්ථක විය හැකි package ස්ථාපනයන්හිදී පවා එය එසේ කරයි.

තවද ඔබට සෑම group එකක් ගැනම වඩාත් ගැඹුරින් සොයා බැලිය හැකිය:

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

සෑම command එකක්ම `--help` ද පිළිගනියි, ඔබ සම්පූර්ණ group එකක් ගැන (`omarchy capture --help`) හෝ තනි command එකක් ගැන (`omarchy capture screenshot --help`) ඇසුවත් එය එසේමය.

### terminal එකෙන් menu එක විවෘත කිරීම

Omarchy menu එක script කළ හැකි අතර, එය ඔබේම keybindings සඳහා පහසු වේ. `omarchy menu` එක එය root එකේ විවෘත කරයි, තවද එය නම් කිරීමෙන් ඔබට ගසේ ඕනෑම ස්ථානයකට කෙලින්ම යා හැකිය: `omarchy menu summon appearance.theme` එක කෙලින්ම theme picker එක වෙත යයි, `omarchy menu toggle system` එක system menu එක විවෘත කරන අතර එය දැනටමත් විවෘතව තිබේ නම් එය නැවත වසා දමයි, තවද `omarchy menu close` එක එය ඉවත් කරයි.
