# Omarchy CLI

Omarchy সাধারণত হটকিগুলো এবং Omarchy মেনুর (`Super + Space`) মাধ্যমে নিয়ন্ত্রণ করা হয়। কিন্তু আপনি `omarchy` CLI-এর মাধ্যমেও এটি নিয়ন্ত্রণ করতে পারেন। এটি বিশেষভাবে সহায়ক যখন আপনি কাস্টমাইজেশন বা কনফিগারেশনে কোনো AI এজেন্টকে আপনার সঙ্গে কাজ করাচ্ছেন।

CLI-এর কাছে সমস্ত অভ্যন্তরীণ টুলিংয়ের অ্যাক্সেস রয়েছে যা মেনুর মাধ্যমে এবং অন্যভাবেও ব্যবহৃত হয়। টার্মিনালে `omarchy` চালিয়ে আপনি উপলব্ধ সবকিছু দেখতে পারেন।

এটি দেখতে মোটামুটি এমন:

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

ডায়াগনস্টিকের জন্য, সরাসরি `omarchy-debug --no-sudo --print` চালান। এটি sudo-র জন্য জিজ্ঞাসা না করেই ডায়াগনস্টিক প্রিন্ট করে এবং `/tmp/omarchy-debug.log` লেখে, এমনকি প্যাকেজ ইনস্টলের ক্ষেত্রেও যেখানে `omarchy debug` "Unknown Omarchy command" দিয়ে ব্যর্থ হতে পারে।

এবং আপনি প্রতিটি গ্রুপে আরও গভীরে যেতে পারেন:

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

প্রতিটি কমান্ড `--help`-ও নেয়, আপনি পুরো একটি গ্রুপকে জিজ্ঞাসা করুন (`omarchy capture --help`) বা একটি একক কমান্ডকে (`omarchy capture screenshot --help`)।

### টার্মিনাল থেকে মেনু খোলা

Omarchy মেনুটি স্ক্রিপ্টযোগ্যও, যা আপনার নিজের কিবাইন্ডিংয়ের জন্য কাজে লাগে। `omarchy menu` এটিকে রুটে খোলে, এবং আপনি নাম দিয়ে গাছের যেকোনো বিন্দুতে সরাসরি চলে যেতে পারেন: `omarchy menu summon appearance.theme` সরাসরি থিম পিকারে যায়, `omarchy menu toggle system` সিস্টেম মেনু খোলে এবং এটি ইতিমধ্যেই খোলা থাকলে আবার বন্ধ করে দেয়, এবং `omarchy menu close` এটিকে সরিয়ে দেয়।
