# Omarchy CLI

โดยปกติแล้ว Omarchy จะควบคุมผ่านปุ่มลัดและเมนู Omarchy (`Super + Space`) แต่คุณก็ควบคุมมันผ่าน `omarchy` CLI ได้เช่นกัน วิธีนี้มีประโยชน์เป็นพิเศษเมื่อคุณให้ AI agent มาช่วยปรับแต่งหรือตั้งค่าต่าง ๆ ไปพร้อมกับคุณ

CLI เข้าถึงเครื่องมือภายในทั้งหมดที่ใช้ทั้งผ่านเมนูและช่องทางอื่น ๆ ได้ คุณดูทุกอย่างที่มีให้ใช้ได้ด้วยการรัน `omarchy` ในเทอร์มินัล

หน้าตาของมันจะเป็นประมาณนี้:

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

และคุณยังเจาะลึกลงไปได้ในทุกกลุ่ม:

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

ทุกคำสั่งยังใช้ `--help` ได้เช่นกัน ไม่ว่าคุณจะถามทั้งกลุ่ม (`omarchy capture --help`) หรือถามคำสั่งเดียว (`omarchy capture screenshot --help`)

### การเปิดเมนูจากเทอร์มินัล

เมนู Omarchy ก็สั่งงานด้วยสคริปต์ได้เช่นกัน ซึ่งสะดวกมากสำหรับ keybindings ของคุณเอง `omarchy menu` จะเปิดเมนูที่จุดเริ่มต้น และคุณก็ข้ามตรงไปยังจุดใดก็ได้ในโครงสร้างเมนูด้วยการระบุชื่อจุดนั้น: `omarchy menu summon appearance.theme` จะพาคุณตรงไปยังตัวเลือกธีมทันที `omarchy menu toggle system` จะเปิดเมนูระบบ และปิดมันอีกครั้งหากเปิดอยู่แล้ว และ `omarchy menu close` จะปิดเมนูทิ้งไป
