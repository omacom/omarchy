# Omarchy CLI

Rialaítear Omarchy de ghnáth trí na heochracha te agus tríd an roghchlár Omarchy (`Super + Space`). Ach is féidir leat é a rialú freisin tríd an `omarchy` CLI. Tá sé seo an-chabhrach go háirithe nuair a bhíonn gníomhaire AI ag obair leat ar shaincheapadh nó ar chumraíocht.

Tá rochtain ag an CLI ar an uirlisíocht inmheánach go léir a úsáidtear tríd an roghchlár agus ar bhealaí eile araon. Is féidir leat gach rud atá ar fáil a fheiceáil trí `omarchy` a rith sa teirminéal.

Breathnaíonn sé rud éigin mar seo:

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

Le haghaidh diagnóisice, rith `omarchy-debug --no-sudo --print` go díreach. Priontálann sé diagnóisic agus scríobhann sé `/tmp/omarchy-debug.log` gan sudo a iarraidh, lena n-áirítear ar shuiteálacha pacáiste áit a bhféadfadh `omarchy debug` teip le "Unknown Omarchy command".

Agus is féidir leat dul níos doimhne ar gach grúpa:

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

Glacann gach ordú le `--help` freisin, cibé a iarrann tú ar ghrúpa iomlán (`omarchy capture --help`) nó ar ordú aonair (`omarchy capture screenshot --help`).

### An roghchlár a oscailt ón teirminéal

Is féidir an roghchlár Omarchy a scripteáil freisin, rud atá áisiúil do do cheangail eochracha féin. Osclaíonn `omarchy menu` é ag an bhfréamh, agus is féidir leat léim go díreach chuig aon phointe sa chrann trína ainmniú: téann `omarchy menu summon appearance.theme` díreach chuig an roghnóir téama, osclaíonn `omarchy menu toggle system` an roghchlár córais agus dúnann sé arís é má tá sé ar oscailt cheana, agus cuireann `omarchy menu close` ar shiúl é.
