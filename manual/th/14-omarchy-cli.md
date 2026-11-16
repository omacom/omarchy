# Omarchy CLI

โดยปกติแล้ว Omarchy จะควบคุมผ่านปุ่มลัดและเมนู Omarchy (`Super + Space`) แต่คุณยังควบคุมผ่าน `omarchy` CLI ได้ด้วย ซึ่งมีประโยชน์เป็นพิเศษเมื่อคุณให้ AI agent ทำงานร่วมกับคุณในเรื่องการปรับแต่งหรือการตั้งค่า

CLI นี้เข้าถึงเครื่องมือภายในทั้งหมดที่ใช้ทั้งผ่านเมนูและช่องทางอื่น ๆ ได้ คุณสามารถดูทุกอย่างที่มีได้โดยการรัน `omarchy` ใน terminal

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

และคุณสามารถเจาะลึกลงไปในแต่ละกลุ่มได้:

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

ทุกคำสั่งรองรับ `--help` ด้วยเช่นกัน ไม่ว่าคุณจะถามทั้งกลุ่ม (`omarchy capture --help`) หรือคำสั่งเดียว (`omarchy capture screenshot --help`)

### การเปิดเมนูจาก terminal

เมนู Omarchy ก็เขียนสคริปต์ควบคุมได้เช่นกัน ซึ่งสะดวกสำหรับ keybindings ของคุณเอง `omarchy menu` จะเปิดเมนูที่ระดับ root และคุณสามารถกระโดดตรงไปยังจุดใดก็ได้ในโครงสร้างโดยการระบุชื่อ: `omarchy menu summon appearance.theme` จะตรงไปยังตัวเลือกธีม `omarchy menu toggle system` จะเปิดเมนูระบบและปิดอีกครั้งถ้ามันเปิดอยู่แล้ว และ `omarchy menu close` จะปิดเมนูไป
