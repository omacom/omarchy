# Omarchy CLI

Omarchy সাধারণত হটকি এবং Omarchy মেনুর (`Super + Space`) মাধ্যমে নিয়ন্ত্রিত হয়। কিন্তু আপনি এটি `omarchy` CLI দিয়েও নিয়ন্ত্রণ করতে পারেন। যখন আপনি কাস্টমাইজেশন বা কনফিগারেশনে আপনার সঙ্গে কাজ করার জন্য একটি AI এজেন্টকে নিযুক্ত করেন, তখন এটি বিশেষভাবে সহায়ক।

মেনুর মাধ্যমে এবং অন্যভাবেও ব্যবহৃত সমস্ত অভ্যন্তরীণ টুলিংয়ে CLI-এর অ্যাক্সেস রয়েছে। টার্মিনালে `omarchy` চালিয়ে আপনি উপলব্ধ সবকিছু দেখতে পারেন।

এটি দেখতে অনেকটা এরকম:

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

আর আপনি প্রতিটি গ্রুপে আরও গভীরে যেতে পারেন:

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

প্রতিটি কমান্ড `--help`-ও নেয়, আপনি পুরো একটি গ্রুপকে (`omarchy capture --help`) জিজ্ঞাসা করুন বা একটি একক কমান্ডকে (`omarchy capture screenshot --help`)।

### টার্মিনাল থেকে মেনু খোলা

Omarchy মেনু স্ক্রিপ্টযোগ্যও, যা আপনার নিজের কিবাইন্ডিংয়ের জন্য সুবিধাজনক। `omarchy menu` এটিকে রুটে খোলে, এবং আপনি নাম ধরে গাছের যেকোনো বিন্দুতে সরাসরি যেতে পারেন: `omarchy menu summon appearance.theme` সরাসরি থিম পিকারে যায়, `omarchy menu toggle system` সিস্টেম মেনু খোলে এবং এটি ইতিমধ্যে খোলা থাকলে আবার বন্ধ করে দেয়, আর `omarchy menu close` এটিকে সরিয়ে দেয়।
