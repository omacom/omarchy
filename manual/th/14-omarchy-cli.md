# Omarchy CLI

โดยปกติ Omarchy ควบคุมผ่านปุ่มลัดและเมนู Omarchy (`Super + Space`) แต่คุณยังควบคุมมันผ่าน CLI `omarchy` ได้เช่นกัน สิ่งนี้ช่วยได้เป็นพิเศษเมื่อคุณให้เอเจนต์ AI ทำงานร่วมกับคุณในการปรับแต่งหรือการกำหนดค่า

CLI เข้าถึงเครื่องมือภายในทั้งหมดที่ใช้ทั้งผ่านเมนูและวิธีอื่น ๆ ได้ คุณสามารถดูทุกสิ่งที่มีได้โดยการรัน `omarchy` ในเทอร์มินัล

มันมีหน้าตาอะไรแบบนี้:

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

และคุณลงลึกในทุกกลุ่มได้:

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

ทุกคำสั่งรับ `--help` ด้วย ไม่ว่าคุณจะถามทั้งกลุ่ม (`omarchy capture --help`) หรือคำสั่งเดียว (`omarchy capture screenshot --help`)

### การเปิดเมนูจากเทอร์มินัล

เมนู Omarchy ยังเขียนสคริปต์ได้เช่นกัน ซึ่งมีประโยชน์สำหรับการผูกปุ่มของคุณเอง `omarchy menu` เปิดมันที่ราก และคุณกระโดดตรงไปยังจุดใด ๆ ในโครงสร้างโดยการตั้งชื่อมัน: `omarchy menu summon style.theme` ตรงไปยังตัวเลือกธีม `omarchy menu toggle system` เปิดเมนูระบบและปิดอีกครั้งหากมันเปิดอยู่แล้ว และ `omarchy menu close` เก็บมันไว้
