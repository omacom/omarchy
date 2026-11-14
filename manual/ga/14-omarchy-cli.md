# Omarchy CLI

Rialaítear Omarchy de ghnáth trí na heochracha aicearra agus trí roghchlár Omarchy (`Super + Space`). Ach is féidir leat é a rialú freisin tríd an CLI `omarchy`. Tá sé seo an-chabhrach go háirithe nuair a bhíonn gníomhaire AI ag obair in éineacht leat ar shaincheapadh nó ar chumraíocht.

Tá rochtain ag an CLI ar an uirlisiú inmheánach go léir a úsáidtear tríd an roghchlár agus ar bhealaí eile araon. Is féidir leat gach rud atá ar fáil a fheiceáil trí `omarchy` a rith sa teirminéal.

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

Agus is féidir leat dul níos doimhne isteach i ngach grúpa:

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

Glacann gach ordú le `--help` freisin, cibé acu a iarrann tú grúpa iomlán (`omarchy capture --help`) nó ordú aonair (`omarchy capture screenshot --help`).

### An roghchlár a oscailt ón teirminéal

Is féidir roghchlár Omarchy a scripteáil freisin, rud atá áisiúil do do cheangail eochracha féin. Osclaíonn `omarchy menu` ag an bhfréamh é, agus is féidir leat léim díreach go dtí pointe ar bith sa chrann trína ainmniú: téann `omarchy menu summon appearance.theme` díreach chuig an roghnóir téama, osclaíonn `omarchy menu toggle system` an roghchlár córais agus dúnann sé arís é má tá sé aníos cheana, agus cuireann `omarchy menu close` ar shiúl é.
