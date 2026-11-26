# Omarchy CLI

Omarchy ko aam tor par hotkeys aur Omarchy menu (`Super + Space`) ke zariye control kiya jata hai. Lekin aap ise `omarchy` CLI ke zariye bhi control kar sakte hain. Yeh khaas tor par us waqt madadgar hota hai jab aap kisi AI agent ko apne saath customization ya configuration par kaam karwa rahe hon.

CLI ke paas us tamam internal tooling tak rasai hai jo menu aur deegar zariye istemal hoti hai. Aap terminal mein `omarchy` chala kar sab kuch dekh sakte hain jo dastiyab hai.

Yeh kuch is tarah dikhta hai:

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

Tashkhees ke liye, seedha `omarchy-debug --no-sudo --print` chalayen. Yeh diagnostics print karta hai aur sudo ka istefsar kiye baghair `/tmp/omarchy-debug.log` mein likhta hai, in package installs par bhi jahan `omarchy debug` "Unknown Omarchy command" ke saath nakam ho sakta hai.

Aur aap har group ki mazid teh mein bhi ja sakte hain:

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

Har command `--help` bhi leti hai, khawah aap kisi poore group (`omarchy capture --help`) se poochein ya sirf ek command (`omarchy capture screenshot --help`) se.

### Terminal se menu kholna

Omarchy menu scriptable bhi hai, jo aapki apni keybindings ke liye kaar-aamad hai. `omarchy menu` ise root par kholta hai, aur aap is ka naam bata kar tree mein kisi bhi nuqte par seedha pohanch sakte hain: `omarchy menu summon appearance.theme` seedha theme picker par le jata hai, `omarchy menu toggle system` system menu kholta hai, aur agar woh pehle se khula ho to use dobara band kar deta hai, aur `omarchy menu close` ise wahan se hata deta hai.
