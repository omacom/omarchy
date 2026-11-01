# Omarchy CLI

Το Omarchy συνήθως ελέγχεται μέσω των συντομεύσεων πληκτρολογίου και του μενού Omarchy (`Super + Space`). Μπορείς όμως να το ελέγχεις και μέσω του `omarchy` CLI. Αυτό είναι ιδιαίτερα χρήσιμο όταν δουλεύεις μαζί με έναν agent AI πάνω σε προσαρμογές ή ρυθμίσεις.

Το CLI έχει πρόσβαση σε όλα τα εσωτερικά εργαλεία που χρησιμοποιούνται τόσο μέσω του μενού όσο και με άλλους τρόπους. Μπορείς να δεις όλα όσα είναι διαθέσιμα τρέχοντας το `omarchy` στο τερματικό.

Μοιάζει κάπως έτσι:

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

Και μπορείς να ψάξεις βαθύτερα σε κάθε ομάδα:

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

Κάθε εντολή δέχεται επίσης το `--help`, είτε ρωτήσεις μια ολόκληρη ομάδα (`omarchy capture --help`) είτε μια μεμονωμένη εντολή (`omarchy capture screenshot --help`).

### Άνοιγμα του μενού από το τερματικό

Το μενού Omarchy μπορεί επίσης να κληθεί από σενάρια, κάτι που είναι βολικό για τις δικές σου συντομεύσεις πληκτρολογίου. Το `omarchy menu` το ανοίγει στη ρίζα, και μπορείς να πας κατευθείαν σε οποιοδήποτε σημείο του δέντρου ονομάζοντάς το: το `omarchy menu summon appearance.theme` πηγαίνει κατευθείαν στην επιλογή θέματος, το `omarchy menu toggle system` ανοίγει το μενού συστήματος και το κλείνει ξανά αν είναι ήδη ανοιχτό, και το `omarchy menu close` το κλείνει.
