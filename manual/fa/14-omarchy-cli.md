# Omarchy CLI

Omarchy معمولاً از طریق کلیدهای میانبر و منوی Omarchy (`Super + Space`) کنترل می‌شود. اما می‌توانید آن را از طریق CLI `omarchy` هم کنترل کنید. این به‌ویژه زمانی مفید است که یک عامل هوش مصنوعی را برای همکاری با خودتان در سفارشی‌سازی یا پیکربندی به کار می‌گیرید.

CLI به همه ابزارهای داخلی‌ای دسترسی دارد که هم از طریق منو و هم به روش‌های دیگر استفاده می‌شوند. با اجرای `omarchy` در ترمینال می‌توانید همه چیزهای در دسترس را ببینید.

چیزی شبیه این است:

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

و می‌توانید در هر گروه عمیق‌تر هم بشوید:

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

هر فرمان `--help` را هم می‌پذیرد، چه از یک گروه کامل بپرسید (`omarchy capture --help`) و چه از یک فرمان منفرد (`omarchy capture screenshot --help`).

### باز کردن منو از ترمینال

منوی Omarchy قابل اسکریپت‌نویسی هم هست، که برای میانبرهای صفحه‌کلید خودتان به کار می‌آید. `omarchy menu` آن را از ریشه باز می‌کند، و می‌توانید با نام بردن از آن مستقیم به هر نقطه‌ای از درخت بروید: `omarchy menu summon appearance.theme` مستقیم به انتخاب‌گر تم می‌رود، `omarchy menu toggle system` منوی سیستم را باز می‌کند و اگر از قبل باز باشد دوباره آن را می‌بندد، و `omarchy menu close` آن را کنار می‌گذارد.
