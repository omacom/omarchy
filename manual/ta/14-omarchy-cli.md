# Omarchy CLI

Omarchy பொதுவாக hotkeys மற்றும் Omarchy menu (`Super + Space`) வழியாகக் கட்டுப்படுத்தப்படுகிறது. ஆனால் நீங்கள் அதை `omarchy` CLI வழியாகவும் கட்டுப்படுத்தலாம். தனிப்பயனாக்கம் அல்லது உள்ளமைவில் ஒரு AI agent உங்களுடன் பணிபுரியும்போது இது குறிப்பாக உதவியாக இருக்கும்.

menu வழியாகவும் மற்றபடியும் பயன்படுத்தப்படும் அனைத்து உள் கருவிகளுக்கும் CLI-க்கு அணுகல் உள்ளது. terminal-இல் `omarchy` ஐ இயக்குவதன் மூலம் கிடைக்கக்கூடிய அனைத்தையும் நீங்கள் பார்க்கலாம்.

இது ஏறக்குறைய இப்படித் தெரியும்:

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

மேலும் ஒவ்வொரு குழுவிலும் நீங்கள் ஆழமாகச் செல்லலாம்:

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

நீங்கள் முழுக் குழுவைக் கேட்டாலும் (`omarchy capture --help`) அல்லது ஒரு தனி கட்டளையைக் கேட்டாலும் (`omarchy capture screenshot --help`), ஒவ்வொரு கட்டளையும் `--help` ஐயும் ஏற்கிறது.

### terminal-இலிருந்து menu-வைத் திறத்தல்

Omarchy menu-வையும் script செய்ய முடியும், இது உங்கள் சொந்த keybindings-க்கு வசதியாக இருக்கும். `omarchy menu` அதை root-இல் திறக்கிறது, மேலும் அதன் பெயரைக் குறிப்பிடுவதன் மூலம் tree-யில் எந்தப் புள்ளிக்கும் நேரடியாகச் செல்லலாம்: `omarchy menu summon appearance.theme` நேரடியாக theme picker-க்குச் செல்கிறது, `omarchy menu toggle system` system menu-வைத் திறக்கிறது, ஏற்கனவே அது திறந்திருந்தால் அதை மீண்டும் மூடுகிறது, மேலும் `omarchy menu close` அதை மூடி வைக்கிறது.
