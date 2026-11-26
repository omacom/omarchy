# Omarchy CLI

Omarchy பொதுவாக ஹாட்கீகள் மற்றும் Omarchy மெனு (`Super + Space`) வழியாகக் கட்டுப்படுத்தப்படுகிறது. ஆனால் நீங்கள் அதை `omarchy` CLI வழியாகவும் கட்டுப்படுத்தலாம். தனிப்பயனாக்கம் அல்லது உள்ளமைவில் ஒரு AI agent உங்களுடன் வேலை செய்யும்போது இது குறிப்பாக உதவியாக இருக்கும்.

மெனு வழியாகவும் பிற வழிகளிலும் பயன்படுத்தப்படும் அனைத்து உள் கருவிகளுக்கும் இந்த CLI-க்கு அணுகல் உண்டு. டெர்மினலில் `omarchy` என்று இயக்குவதன் மூலம் கிடைக்கக்கூடிய அனைத்தையும் நீங்கள் பார்க்கலாம்.

இது இப்படித்தான் இருக்கும்:

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

நோயறிதலுக்கு, `omarchy-debug --no-sudo --print` ஐ நேரடியாக இயக்குங்கள். இது sudo கேட்காமல் நோயறிதல் தகவல்களை அச்சிட்டு `/tmp/omarchy-debug.log` இல் எழுதுகிறது; `omarchy debug` "Unknown Omarchy command" என்று தோல்வியடையக்கூடிய தொகுப்பு நிறுவல்களிலும் இது பொருந்தும்.

மேலும் ஒவ்வொரு குழுவிலும் நீங்கள் ஆழமாகச் செல்லலாம்:

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

ஒவ்வொரு கட்டளையும் `--help` ஐயும் ஏற்கும்; ஒரு முழுக் குழுவைக் கேட்டாலும் (`omarchy capture --help`) அல்லது ஒரு தனிக் கட்டளையைக் கேட்டாலும் (`omarchy capture screenshot --help`) அப்படித்தான்.

### டெர்மினலில் இருந்து மெனுவைத் திறத்தல்

Omarchy மெனுவையும் ஸ்கிரிப்ட் செய்ய முடியும், இது உங்கள் சொந்த கீபைண்டிங்குகளுக்கு வசதியாக இருக்கும். `omarchy menu` அதை ரூட்டில் திறக்கும், அதன் பெயரைச் சொல்வதன் மூலம் நீங்கள் அந்த மரக்கட்டமைப்பின் எந்தப் புள்ளிக்கும் நேரடியாகத் தாவலாம்: `omarchy menu summon appearance.theme` நேரடியாக தீம் தேர்வாளருக்குச் செல்லும், `omarchy menu toggle system` சிஸ்டம் மெனுவைத் திறக்கும், அது ஏற்கெனவே திறந்திருந்தால் மீண்டும் மூடும், `omarchy menu close` அதை மறைத்துவிடும்.
