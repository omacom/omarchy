# Omarchy CLI

Omarchy er venjulega stjórnað með flýtilyklunum og Omarchy-valmyndinni (`Super + Space`). En þú getur líka stjórnað því með `omarchy` CLI. Þetta er sérstaklega hjálplegt þegar þú ert með gervigreindarumboðsmann að vinna með þér að sérsniði eða uppsetningu.

CLI-ið hefur aðgang að öllum innri verkfærunum sem eru notuð bæði í gegnum valmyndina og á annan hátt. Þú getur séð allt sem er í boði með því að keyra `omarchy` í útstöðinni.

Það lítur einhvern veginn svona út:

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

Og þú getur kafað dýpra í hvern hóp:

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

Sérhver skipun tekur líka `--help`, hvort sem þú spyrð heilan hóp (`omarchy capture --help`) eða eina skipun (`omarchy capture screenshot --help`).

### Að opna valmyndina úr útstöðinni

Omarchy-valmyndin er líka forskrifanleg, sem er þægilegt fyrir þínar eigin lyklabindingar. `omarchy menu` opnar hana við rótina, og þú getur hoppað beint á hvaða punkt sem er í trénu með því að nefna hann: `omarchy menu summon appearance.theme` fer beint í þemavalið, `omarchy menu toggle system` opnar kerfisvalmyndina og lokar henni aftur ef hún er þegar opin, og `omarchy menu close` setur hana burt.
