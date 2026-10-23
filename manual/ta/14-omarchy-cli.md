# Omarchy CLI

Omarchy பொதுவாக ஹாட்கீகள் மற்றும் Omarchy மெனு (`Super + Space`) மூலம் கட்டுப்படுத்தப்படுகிறது. ஆனால் `omarchy` CLI மூலமும் அதைக் கட்டுப்படுத்தலாம். தனிப்பயனாக்கம் அல்லது கட்டமைப்பில் உங்களுடன் ஒரு AI Agent வேலை செய்யும் போது இது குறிப்பாக உதவியாக இருக்கும்.

CLI மெனு வழியாகவும் இல்லையெனில் வழியாகவும் பயன்படுத்தப்படும் அனைத்து உள் கருவிகளுக்கும் அணுகலைக் கொண்டுள்ளது. டெர்மினலில் `omarchy` ஐ இயக்குவதன் மூலம் கிடைக்கக் கூடிய அனைத்தையும் காணலாம்.

அது இது போல ஏதோ இருக்கும்:

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

மேலும் ஒவ்வொரு குழுவிலும் ஆழமாகச் செல்லலாம்:

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

ஒவ்வொரு கட்டளையும் `--help` ஐயும் எடுக்கிறது, நீங்கள் ஒரு முழு குழுவைக் கேட்டாலும் (`omarchy capture --help`) அல்லது ஒரு ஒற்றை கட்டளையைக் கேட்டாலும் (`omarchy capture screenshot --help`).

### டெர்மினலிலிருந்து மெனுவைத் திறத்தல்

Omarchy மெனு ஸ்கிரிப்ட் செய்யக்கூடியதும் கூட, இது உங்கள் சொந்த விசைப்பிணைப்புகளுக்கு வசதியானது. `omarchy menu` அதை ரூட்டில் திறக்கிறது, மேலும் அதைப் பெயரிடுவதன் மூலம் மரத்தில் உள்ள எந்த புள்ளிக்கும் நேரடியாகத் தாவலாம்: `omarchy menu summon style.theme` நேரடியாக தீம் தேர்வாளருக்குச் செல்கிறது, `omarchy menu toggle system` கணினி மெனுவைத் திறக்கிறது மற்றும் அது ஏற்கனவே இருந்தால் அதை மீண்டும் மூடுகிறது, மற்றும் `omarchy menu close` அதை வைக்கிறது.
