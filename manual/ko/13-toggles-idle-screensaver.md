# 토글, 유휴 및 화면 보호기

일상적으로 바꾸는 것 중 상당수는 사실 설정이 아닙니다. 한 시간 동안 켰다가 다시 끄는 모드입니다. 밤늦게 일할 때의 야간 조명, 발표할 때의 방해 금지, 무언가를 시청할 때의 절전 금지 같은 것들이죠. Omarchy는 이를 토글이라고 부르며, 모두 같은 방식으로 작동합니다 — 단축키, 메뉴 항목, 명령이 모두 같은 스위치를 맞춥니다.

### 토글 메뉴

`Super + Ctrl + O`는 _실행 > 토글_을 바로 열거나, Omarchy 메뉴(`Super + Space`)에서 걸어갈 수 있습니다. 그 목록의 모든 것은 상태가 어디 있는지 신경 쓰지 않고 켜고 끌 수 있는 스위치입니다. 데스크톱 모습에 대한 스위치는 그 옆 _실행 > 모양_ 아래에 있습니다.

터미널에서 같은 스위치는 `omarchy toggle <thing>`입니다. `omarchy toggle`을 단독으로 실행하면 그룹 전체를 볼 수 있습니다.

| 토글 | 단축키 | 명령 |
| ------ | ------ | ------- |
| 야간 조명 | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| 알림 무음 | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| 절전 금지(유휴 잠금 없음) | `Super + Ctrl + I` | `omarchy toggle idle` |
| 충돌 캡처 | — | `omarchy toggle crash-capture` |
| 화면 보호기 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 테마 동기화 | — | `omarchy toggle theme sync` |
| 메뉴 바 | `Super + Shift + Space` | `omarchy toggle bar` |
| 터치패드 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 터치스크린 | — | `omarchy toggle touchscreen` |
| 일시 중단 | — | `omarchy toggle suspend` |
| 하이브리드 GPU | — | `omarchy toggle hybrid gpu` |

터치패드, 터치스크린, 하이브리드 GPU 스위치는 실제로 해당 하드웨어가 있을 때만 나타나므로 토글 아래가 아니라 _실행 > 하드웨어_(`Super + Ctrl + H`) 아래에 있습니다. 터치패드와 터치스크린 항목은 Hyprland를 다시 로드해도 유지됩니다 — 비활성화된 장치 이름은 시작 시 Hyprland가 읽어 다시 비활성화하는 작은 상태 파일에 저장됩니다.

_실행 > 모양_에는 메뉴 바와 애니메이션이 있으며, `omarchy toggle` 명령은 아니지만 비슷하게 동작하는 몇 가지도 있습니다: 바에 배터리 백분율 표시, 기본 워크스페이스 레이아웃, 창 간격(`Super + Shift + Backspace`), 1창 정사각형 종횡비(`Super + Ctrl + Backspace`) 등입니다.

이들 대부분은 `~/.local/state/omarchy/toggles/` 아래의 플래그 파일일 뿐입니다. 스크립트에서 분기하고 싶다면 `omarchy-toggle-enabled`가 직접 찾아다니지 않아도 종료 코드를 제공합니다:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

플래그는 꺼진 상태의 이름을 따릅니다 — `screensaver-off`, `suspend-off`, `bar-off` — 따라서 그 존재는 기능이 비활성화되었다는 뜻입니다.

### 바의 표시기

모드가 켜져 있으면 시계 옆 상단 바 가운데에 작은 글리프가 나타납니다. 이는 표시기 위젯으로, 받아쓰기, 화면 녹화, 대기 중인 리마인더, 야간 조명, 방해 금지, 절전 금지를 표시합니다.

비활성 표시기는 숨겨져 있습니다. 그 주변 영역에 마우스를 올리면 흐릿하게 나타나므로, 단축키를 몰라도 클릭해 켤 수 있습니다. 활성 표시기를 클릭하면 다시 꺼집니다. 항상 전부 보이게 하고 싶다면 `~/.config/omarchy/shell.json`의 `omarchy.indicators` 항목에서 `alwaysShow`를 `true`로 설정하세요 — 바 위젯 구성 방식은 [상단 바](05-the-top-bar.md)를 참조하세요.

### 야간 조명

`Super + Ctrl + N`은 화면을 4000K로 따뜻하게 하고, 다시 누르면 6500K로 돌아갑니다. hyprsunset이 이를 구동하며, 이미 실행 중이 아니면 토글이 시작합니다.

기본적으로 hyprsunset은 화면에 전혀 영향을 주지 않습니다. `~/.config/hypr/hyprsunset.conf`는 디스플레이가 따뜻함을 요청할 때까지 그대로 유지되도록 항등 프로파일(identity profile)과 함께 제공됩니다. 시계에 맞춰 전환되길 원한다면 시간 프로파일로 교체하세요:

```
profile {
    time = 20:00
    temperature = 4000
}
```

그런 다음 `~/.config/hypr/autostart.lua`에 `o.launch_on_start("hyprsunset")`를 추가해 로그인 시 hyprsunset을 시작하세요. 토글이 사용하는 4000K/6500K 쌍은 고정되어 있으므로, 다른 온도를 원하면 구성 파일로 가세요.

### 방해 금지

`Super + Ctrl + ,`는 알림을 무음 처리합니다. 켜져 있는 동안에는 토스트가 뜨지 않으며, 취소선이 그어진 종 표시기가 바에 있어 데스크톱이 왜 조용해졌는지 알려 줍니다.

하지만 아무것도 잃어버리지 않습니다. 무음 처리된 알림은 알림 히스토리에 바로 기록되며, 이는 돌아왔을 때 무엇을 놓쳤는지 궁금해할 때 정확히 원하는 기록입니다. `Super + Shift + Alt + ,`로 여세요. 알림 이야기의 나머지는 [알림](10-notices.md)을 참조하세요.

여전히 통과하는 메시지는 두 종류입니다. 방금 한 일에 대한 Omarchy 자체의 확인 토스트("Theme changed", "Screenshot saved")와, 명령줄에서 보낸 중요(critical) 경고입니다. 모든 것을 중요로 표시해 눈앞에 억지로 나타나려는 채팅 앱은 해당하지 않습니다.

### 유휴

Omarchy 셸이 유휴 동작을 소유하며, 타이밍은 `~/.config/omarchy/shell.json`의 최상위 수준 `idle` 블록입니다:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

두 숫자는 모두 유휴 상태가 된 시점부터 센 초 단위 값이며, 서로로부터 센 값이 아닙니다. 따라서 기본값에서는 화면 보호기가 2분 30초 뒤에 뜨고, 화면 보호기가 실행되었든 아니든 5분에 잠금 화면이 이어받습니다. 파일을 저장하면 셸이 새 타이밍을 즉시 적용합니다.

잠금 마감 전에 화면 보호기를 닫으면 활동으로 간주되고 대기 중인 잠금이 취소됩니다. 머신을 힐끗 본 것만으로 잠기는 일은 없습니다.

유휴 시 잠금을 완전히 중단하려면 `Super + Ctrl + I` — 또는 `omarchy toggle idle` — 로 절전 금지를 켜면 바에 커피잔 표시기가 나타납니다. 긴 발표나 지켜보고 싶은 빌드 전에 눌러야 할 것이 바로 이것입니다. 다시 누르면 정상으로 돌아갑니다. 스크립트에서 필요하다면 `omarchy toggle idle status`가 현재 상태를 JSON으로 출력합니다.

이는 잠금과 화면 보호기에 대한 것이며 전원에 대한 것이 아닙니다. 일시 중단과 최대 절전 모드는 [시스템 절전](36-system-sleep.md)에 자체 설정이 있습니다.

### 화면 보호기

Omarchy의 화면 보호기는 모니터당 하나의 인스턴스로, 무작위 텍스트 효과를 통과하며 실행되는 ASCII 아트입니다. 어떤 키든 마우스 움직임이든 종료합니다.

유휴 화면 보호기를 꺼 둔 경우에도 _시스템 > 화면 보호기_(`Super + Esc`)에서 필요할 때 시작할 수 있습니다. 기본적으로 바인딩된 단축키는 없습니다.

`omarchy toggle screensaver`는 작업 중 상태에서 바로 잠금 상태로 가고 싶다면 유휴 화면 보호기를 끄는 역할을 합니다. 이는 구성 방법을 아는 터미널 — Alacritty, Foot, Ghostty, 또는 Kitty — 이 필요하며, 기본 터미널이 다른 것이면 그 사실을 알려 줍니다.

그것이 그리는 로고는 _스타일 > 화면 보호기_에서 바꿀 수 있습니다. png나 svg를 업로드하면 Omarchy가 ASCII로 변환합니다. [브랜딩](41-branding.md)을 참조하세요.

### 잠금 화면

`Super + Ctrl + L`은 머신을 잠급니다. 그러면 Omarchy 셸에서 잠금 화면이 실행되고, 디스플레이가 꺼지며, 잘못된 알파벳으로 비밀번호를 입력하지 않도록 키보드 레이아웃이 첫 번째 레이아웃으로 초기화되고, 1Password가 실행 중이면 나가는 길에 함께 잠깁니다.

잠금 화면은 비밀번호를 받으며, 지문을 설정해 두면 지문도 받습니다. 그 내용과 다른 인증 방법은 [하드웨어 인증](37-hardware-authentication.md)에서 다룹니다.
