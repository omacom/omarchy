# Omarchy CLI

Omarchy는 보통 단축키와 Omarchy 메뉴(`Super + Space`)를 통해 제어합니다. 하지만 `omarchy` CLI를 통해서도 제어할 수 있습니다. 이는 AI 에이전트와 함께 맞춤 설정이나 구성을 작업할 때 특히 유용합니다.

CLI는 메뉴를 통해 사용되는 내부 도구를 비롯해 그 외의 모든 내부 도구에 접근할 수 있습니다. 터미널에서 `omarchy`를 실행하면 사용 가능한 모든 것을 확인할 수 있습니다.

대략 다음과 같은 모습입니다:

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

진단이 필요할 때는 `omarchy-debug --no-sudo --print`를 직접 실행하세요. sudo를 묻지 않고 진단을 출력하고 `/tmp/omarchy-debug.log`를 작성합니다. 패키지 설치처럼 `omarchy debug`가 "Unknown Omarchy command" 오류로 실패할 수 있는 경우에도 마찬가지입니다.

그리고 모든 그룹을 더 깊이 파고들 수도 있습니다:

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

모든 명령은 `--help`도 지원합니다. 그룹 전체에 대해 물어보든(`omarchy capture --help`) 단일 명령에 대해 물어보든(`omarchy capture screenshot --help`) 마찬가지입니다.

### 터미널에서 메뉴 열기

Omarchy 메뉴도 스크립트로 제어할 수 있어, 직접 키 바인딩을 만들 때 편리합니다. `omarchy menu`는 메뉴를 루트에서 열고, 이름을 지정하면 트리의 원하는 지점으로 바로 이동할 수 있습니다: `omarchy menu summon appearance.theme`는 테마 선택기로 바로 이동하고, `omarchy menu toggle system`은 시스템 메뉴를 열며 이미 열려 있으면 다시 닫고, `omarchy menu close`는 메뉴를 닫습니다.
