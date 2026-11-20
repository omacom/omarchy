# Omarchy CLI

Omarchy সাধারণত hotkey এবং Omarchy মেনু (`Super + Space`) দিয়ে নিয়ন্ত্রণ করা হয়। তবে তুমি এটাকে `omarchy` CLI দিয়েও নিয়ন্ত্রণ করতে পারো। এটা বিশেষভাবে কাজে লাগে যখন তুমি কোনো AI agent-কে দিয়ে নিজের পছন্দমতো সাজানো বা configuration-এর কাজ করাচ্ছ।

এই CLI-তে সেই সব internal tooling-এর access আছে, যেগুলো মেনু এবং অন্য সব জায়গায় ব্যবহার করা হয়। টার্মিনালে `omarchy` চালালেই তুমি দেখতে পাবে কী কী পাওয়া যায়।

এটা দেখতে অনেকটা এরকম:

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

Diagnostics-এর জন্য, সরাসরি `omarchy-debug --no-sudo --print` চালাও। এটা diagnostics print করে এবং sudo-র জন্য prompt না করেই `/tmp/omarchy-debug.log`-এ লিখে রাখে, এমনকি package install-এর ক্ষেত্রেও, যেখানে `omarchy debug` "Unknown Omarchy command" দিয়ে ব্যর্থ হতে পারে।

আর তুমি প্রতিটা group-এর ভেতরে আরও গভীরে যেতে পারো:

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

প্রতিটা command-ই `--help` নেয়, তুমি পুরো group (`omarchy capture --help`) জানতে চাও বা একটা নির্দিষ্ট command (`omarchy capture screenshot --help`) জানতে চাও।

### টার্মিনাল থেকে মেনু খোলা

Omarchy মেনুটাও scriptable, যা তোমার নিজস্ব keybinding-এর জন্য বেশ কাজের। `omarchy menu` এটাকে root-এ খোলে, আর তুমি নাম ধরে tree-র যেকোনো জায়গায় সরাসরি চলে যেতে পারো: `omarchy menu summon appearance.theme` সোজা theme picker-এ নিয়ে যায়, `omarchy menu toggle system` system মেনু খোলে এবং ইতিমধ্যে খোলা থাকলে আবার বন্ধ করে দেয়, আর `omarchy menu close` এটাকে সরিয়ে ফেলে।
