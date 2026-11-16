# Omarchy CLI

Το Omarchy ελέγχεται συνήθως μέσω των πλήκτρων συντόμευσης και του μενού Omarchy (`Super + Space`). Μπορείτε όμως να το ελέγχετε και μέσω του CLI `omarchy`. Αυτό είναι ιδιαίτερα χρήσιμο όταν έχετε έναν agent AI να συνεργάζεται μαζί σας για προσαρμογές ή διαμόρφωση.

Το CLI έχει πρόσβαση σε όλα τα εσωτερικά εργαλεία που χρησιμοποιούνται τόσο μέσω του μενού όσο και με άλλους τρόπους. Μπορείτε να δείτε όλα όσα είναι διαθέσιμα εκτελώντας `omarchy` στο τερματικό.

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

Για διαγνωστικά, εκτελέστε απευθείας το `omarchy-debug --no-sudo --print`. Εκτυπώνει διαγνωστικά και γράφει στο `/tmp/omarchy-debug.log` χωρίς να ζητήσει sudo, συμπεριλαμβανομένων των εγκαταστάσεων πακέτων όπου το `omarchy debug` μπορεί να αποτύχει με "Unknown Omarchy command".

Και μπορείτε να εμβαθύνετε περισσότερο σε κάθε ομάδα:

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

Κάθε εντολή δέχεται επίσης το `--help`, είτε ρωτήσετε μια ολόκληρη ομάδα (`omarchy capture --help`) είτε μια μεμονωμένη εντολή (`omarchy capture screenshot --help`).

### Άνοιγμα του μενού από το τερματικό

Το μενού Omarchy μπορεί επίσης να ελεγχθεί μέσω script, κάτι που είναι βολικό για τις δικές σας συντομεύσεις πληκτρολογίου. Το `omarchy menu` το ανοίγει στη ρίζα, και μπορείτε να μεταβείτε απευθείας σε οποιοδήποτε σημείο του δέντρου ονομάζοντάς το: το `omarchy menu summon appearance.theme` πηγαίνει κατευθείαν στον επιλογέα θέματος, το `omarchy menu toggle system` ανοίγει το μενού συστήματος και το κλείνει ξανά αν είναι ήδη ανοιχτό, και το `omarchy menu close` το εξαφανίζει.
