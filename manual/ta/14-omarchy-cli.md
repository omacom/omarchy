# Omarchy CLI

Omarchy பொதுவாக hotkeys மற்றும் Omarchy menu (`Super + Space`) வழியாகக் கட்டுப்படுத்தப்படுகிறது. ஆனால் நீங்கள் அதை `omarchy` CLI வழியாகவும் கட்டுப்படுத்தலாம். தனிப்பயனாக்கம் அல்லது உள்ளமைவில் உங்களுடன் ஒரு AI agent வேலை செய்யும்போது இது குறிப்பாக உதவியாக இருக்கும்.

CLI-க்கு menu வழியாகவும் மற்றபடியும் பயன்படுத்தப்படும் அனைத்து உள் கருவிகளுக்கும் அணுகல் உள்ளது. Terminal-இல் `omarchy` ஐ இயக்குவதன் மூலம் கிடைக்கக்கூடிய அனைத்தையும் நீங்கள் பார்க்கலாம்.

இது இதுபோலத் தோன்றும்:

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

கண்டறிதலுக்கு, `omarchy-debug --no-sudo --print` ஐ நேரடியாக இயக்கவும். இது கண்டறிதல் தகவல்களை அச்சிட்டு, sudo கேட்காமல் `/tmp/omarchy-debug.log` இல் எழுதுகிறது, `omarchy debug` "Unknown Omarchy command" என்று தோல்வியடையக்கூடிய package நிறுவல்கள் உட்பட.

மேலும் ஒவ்வொரு group-ஐயும் நீங்கள் ஆழமாக ஆராயலாம்:

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

ஒவ்வொரு command-உம் `--help` ஐயும் ஏற்கும், நீங்கள் ஒரு முழு group-ஐக் (`omarchy capture --help`) கேட்டாலும் சரி அல்லது ஒரு தனி command-ஐக் (`omarchy capture screenshot --help`) கேட்டாலும் சரி.

### Terminal-இலிருந்து menu-வைத் திறத்தல்

Omarchy menu-வை script செய்யவும் முடியும், இது உங்கள் சொந்த keybindings-க்கு வசதியாக இருக்கும். `omarchy menu` அதை root-இல் திறக்கிறது, மேலும் அதன் பெயரைக் குறிப்பிடுவதன் மூலம் tree-யில் எந்தப் புள்ளிக்கும் நேரடியாகச் செல்லலாம்: `omarchy menu summon appearance.theme` நேரடியாக theme picker-க்குச் செல்கிறது, `omarchy menu toggle system` system menu-வைத் திறக்கிறது, ஏற்கனவே திறந்திருந்தால் அதை மீண்டும் மூடுகிறது, மற்றும் `omarchy menu close` அதை மூடிவிடுகிறது.
