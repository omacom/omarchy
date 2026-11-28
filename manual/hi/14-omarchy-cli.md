# Omarchy CLI

Omarchy को आमतौर पर हॉटकीज़ और Omarchy मेनू (`Super + Space`) के ज़रिए नियंत्रित किया जाता है। लेकिन आप इसे `omarchy` CLI के ज़रिए भी नियंत्रित कर सकते हैं। यह खास तौर पर तब मददगार होता है जब आप किसी AI एजेंट को अपने साथ कस्टमाइज़ेशन या कॉन्फ़िगरेशन पर काम करने दे रहे हों।

CLI के पास उन सभी आंतरिक टूल्स तक पहुँच है जिनका उपयोग मेनू के ज़रिए और अन्यथा दोनों तरह से किया जाता है। टर्मिनल में `omarchy` चलाकर आप देख सकते हैं कि क्या-क्या उपलब्ध है।

यह कुछ इस तरह दिखता है:

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

डायग्नोस्टिक्स के लिए, सीधे `omarchy-debug --no-sudo --print` चलाएँ। यह sudo के लिए पूछे बिना डायग्नोस्टिक्स प्रिंट करता है और `/tmp/omarchy-debug.log` लिखता है, पैकेज इंस्टॉल पर भी, जहाँ `omarchy debug` "Unknown Omarchy command" के साथ विफल हो सकता है।

और आप हर समूह में और गहराई तक जा सकते हैं:

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

हर कमांड `--help` भी लेता है, चाहे आप किसी पूरे समूह से पूछें (`omarchy capture --help`) या किसी एक कमांड से (`omarchy capture screenshot --help`)।

### टर्मिनल से मेनू खोलना

Omarchy मेनू को स्क्रिप्ट से भी चलाया जा सकता है, जो आपकी अपनी कीबाइंडिंग्स के लिए काम का है। `omarchy menu` इसे रूट पर खोलता है, और आप इसका नाम बताकर ट्री में सीधे किसी भी बिंदु पर जा सकते हैं: `omarchy menu summon appearance.theme` सीधे थीम पिकर पर जाता है, `omarchy menu toggle system` सिस्टम मेनू खोलता है और अगर वह पहले से खुला हो तो उसे फिर से बंद कर देता है, और `omarchy menu close` उसे हटा देता है।
