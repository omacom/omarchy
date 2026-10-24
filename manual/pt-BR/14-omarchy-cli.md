# CLI do Omarchy

O Omarchy geralmente é controlado pelos atalhos e pelo menu do Omarchy (`Super + Space`). Mas você também pode controlá-lo pela CLI `omarchy`. Isso é particularmente útil quando você tem um agente de IA trabalhando com você em personalização ou configuração.

A CLI tem acesso a todas as ferramentas internas usadas tanto pelo menu quanto de outras formas. Você pode ver tudo o que está disponível executando `omarchy` no terminal.

Ela se parece com algo assim:

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

E você pode mergulhar mais fundo em cada grupo:

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

Todo comando também aceita `--help`, quer você pergunte a um grupo inteiro (`omarchy capture --help`) ou a um único comando (`omarchy capture screenshot --help`).

### Abrindo o menu pelo terminal

O menu do Omarchy também é programável por script, o que é útil para seus próprios atalhos. `omarchy menu` o abre na raiz, e você pode pular direto para qualquer ponto da árvore nomeando-o: `omarchy menu summon style.theme` vai direto ao seletor de temas, `omarchy menu toggle system` abre o menu do sistema e o fecha de novo se já estiver aberto, e `omarchy menu close` o guarda.
