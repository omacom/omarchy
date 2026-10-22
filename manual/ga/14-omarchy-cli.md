# Omarchy CLI

De ghnáth rialaítear Omarchy trí na heochracha gasta agus roghchlár Omarchy (`Super + Space`). Ach is féidir leat é a rialú freisin trí CLI `omarchy`. Tá sé seo an-chabhrach go háirithe nuair a bhíonn gníomhaire AI ag obair leat ar shaincheapadh nó ar chumraíocht.

Tá rochtain ag an CLI ar an uirlisiú inmheánach ar fad a úsáidtear tríd an roghchlár agus ar shlí eile araon. Is féidir leat gach rud atá ar fáil a fheiceáil trí `omarchy` a rith sa teirminéal.

Tá cuma air rud éigin mar seo:

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

Glacann gach ordú le `--help` freisin, cibé acu a fhiafraíonn tú de ghrúpa iomlán (`omarchy capture --help`) nó d'ordú aonair (`omarchy capture screenshot --help`).

### An roghchlár a oscailt ón teirminéal

Is féidir roghchlár Omarchy a scriptiú freisin, atá áisiúil do do cheangail eochracha féin. Osclaíonn `omarchy menu` ag an bhfréamh é, agus is féidir leat léim go díreach chuig aon phointe sa chrann trí é a ainmniú: téann `omarchy menu summon style.theme` go díreach chuig an roghnóir téama, osclaíonn `omarchy menu toggle system` roghchlár an chórais agus dúnann sé arís é má tá sé suas cheana, agus cuireann `omarchy menu close` ar shiúl é.
