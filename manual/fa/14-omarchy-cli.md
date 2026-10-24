# Omarchy CLI

Omarchy معمولاً از طریق کلیدهای میانبر و منوی Omarchy (`Super + Space`) کنترل می‌شود. اما همچنین می‌توانید آن را از طریق CLI ـی `omarchy` کنترل کنید. این به‌ویژه وقتی یک عامل هوش مصنوعی در سفارشی‌سازی یا پیکربندی با شما کار می‌کند مفید است.

CLI به همهٔ ابزارهای درونی که هم از طریق منو و هم در غیر این صورت استفاده می‌شوند دسترسی دارد. می‌توانید با اجرای `omarchy` در ترمینال همهٔ آنچه در دسترس است را ببینید.

تقریباً این‌گونه به نظر می‌رسد:

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

و می‌توانید در هر گروه عمیق‌تر شوید:

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

هر فرمان همچنین `--help` را می‌پذیرد، چه یک گروه کامل را بپرسید (`omarchy capture --help`) یا یک فرمان واحد (`omarchy capture screenshot --help`).

### باز کردن منو از ترمینال

منوی Omarchy همچنین قابل اسکریپت‌نویسی است، که برای نگاشت‌های کلیدی خودتان مفید است. `omarchy menu` آن را در ریشه باز می‌کند و می‌توانید با نام‌بردن مستقیماً به هر نقطه‌ای در درخت بروید: `omarchy menu summon style.theme` مستقیماً به انتخاب‌گر تم می‌رود، `omarchy menu toggle system` منوی سیستم را باز می‌کند و اگر از قبل باز باشد دوباره آن را می‌بندد و `omarchy menu close` آن را کنار می‌گذارد.
