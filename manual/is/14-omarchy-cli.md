# Omarchy CLI

Omarchy er yfirleitt stjórnað með flýtilyklunum og Omarchy-valmyndinni (`Super + Space`). En þú getur líka stjórnað því með `omarchy` CLI-inu. Þetta er sérstaklega gagnlegt þegar þú lætur gervigreindarumboðsmann vinna með þér í að sérsníða eða stilla hluti.

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

Til greiningar skaltu keyra `omarchy-debug --no-sudo --print` beint. Það prentar út greiningarupplýsingar og skrifar í `/tmp/omarchy-debug.log` án þess að biðja um sudo, líka við pakkauppsetningar þar sem `omarchy debug` getur mistekist með "Unknown Omarchy command".

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

Sérhver skipun tekur líka við `--help`, hvort sem þú spyrð um heilan hóp (`omarchy capture --help`) eða eina skipun (`omarchy capture screenshot --help`).

### Að opna valmyndina frá útstöðinni

Omarchy-valmyndin er líka forskriftanleg, sem kemur sér vel fyrir þínar eigin lyklabindingar. `omarchy menu` opnar hana við rótina og þú getur hoppað beint á hvaða stað sem er í trénu með því að nefna hann: `omarchy menu summon appearance.theme` fer beint í þemavalinn, `omarchy menu toggle system` opnar kerfisvalmyndina og lokar henni aftur ef hún er þegar opin og `omarchy menu close` lokar henni.
