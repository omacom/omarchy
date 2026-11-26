# Omarchy CLI

โดยปกติ Omarchy จะควบคุมผ่านปุ่มลัดและเมนู Omarchy (`Super + Space`) แต่คุณก็ควบคุมมันผ่าน CLI ของ `omarchy` ได้เช่นกัน วิธีนี้มีประโยชน์เป็นพิเศษตอนที่คุณให้เอเจนต์ AI ทำงานร่วมกับคุณเพื่อปรับแต่งหรือตั้งค่าต่าง ๆ

CLI นี้เข้าถึงเครื่องมือภายในทั้งหมดที่ใช้ทั้งผ่านเมนูและช่องทางอื่น ๆ ได้ คุณดูทุกอย่างที่มีให้ใช้ได้ด้วยการรัน `omarchy` ในเทอร์มินัล

หน้าตาจะประมาณนี้:

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

สำหรับการวินิจฉัยปัญหา ให้รัน `omarchy-debug --no-sudo --print` โดยตรง มันจะพิมพ์ข้อมูลวินิจฉัยและเขียนไฟล์ `/tmp/omarchy-debug.log` โดยไม่ถามหา sudo รวมถึงในกรณีติดตั้งจากแพ็กเกจซึ่ง `omarchy debug` อาจล้มเหลวพร้อมข้อความ "Unknown Omarchy command"

และคุณเจาะลึกแต่ละกลุ่มได้ด้วย:

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

ทุกคำสั่งรับ `--help` ได้ด้วยเช่นกัน ไม่ว่าคุณจะถามทั้งกลุ่ม (`omarchy capture --help`) หรือคำสั่งเดียว (`omarchy capture screenshot --help`)

### การเปิดเมนูจากเทอร์มินัล

เมนู Omarchy ก็สั่งงานด้วยสคริปต์ได้เช่นกัน ซึ่งสะดวกสำหรับการตั้งปุ่มลัดของคุณเอง `omarchy menu` จะเปิดเมนูที่จุดเริ่มต้น และคุณกระโดดตรงไปยังจุดใดก็ได้ในโครงสร้างเมนูด้วยการระบุชื่อ: `omarchy menu summon appearance.theme` จะพาไปตัวเลือกธีมทันที `omarchy menu toggle system` จะเปิดเมนูระบบ และปิดมันอีกครั้งถ้ามันเปิดอยู่แล้ว และ `omarchy menu close` จะเก็บมันไป
