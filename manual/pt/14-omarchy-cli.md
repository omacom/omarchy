# Omarchy CLI

O Omarchy é normalmente controlado através das teclas de atalho e do menu Omarchy (`Super + Space`). Mas também o podes controlar através da CLI `omarchy`. Isto é particularmente útil quando tens um agente de IA a trabalhar contigo na personalização ou na configuração.

A CLI tem acesso a todas as ferramentas internas que são utilizadas tanto através do menu como de outras formas. Podes ver tudo o que está disponível ao executares `omarchy` no terminal.

Tem um aspeto semelhante a isto:

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

E podes aprofundar cada grupo:

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

Todos os comandos também aceitam `--help`, quer perguntes a um grupo inteiro (`omarchy capture --help`) quer a um único comando (`omarchy capture screenshot --help`).

### Abrir o menu a partir do terminal

O menu Omarchy também pode ser controlado por script, o que dá jeito para os teus próprios atalhos de teclado. `omarchy menu` abre-o na raiz, e podes saltar diretamente para qualquer ponto da árvore ao indicá-lo: `omarchy menu summon appearance.theme` vai diretamente para o seletor de temas, `omarchy menu toggle system` abre o menu do sistema e volta a fechá-lo se já estiver aberto, e `omarchy menu close` fecha-o.
