# 토글, 유휴 상태 & 화면 보호기

일상적으로 바꾸는 것들 중 상당수는 사실 설정이 아니다. 한 시간 동안 켜 두었다가 다시 끄는 모드다: 늦게까지 일할 때 켜는 야간 조명, 발표할 때 켜는 방해 금지, 무언가를 보고 있을 때 켜는 깨어 있기 같은 것들이다. Omarchy는 이것들을 토글이라 부르며, 모두 같은 방식으로 작동한다 — 단축키, 메뉴 항목, 명령이 모두 같은 스위치를 건드린다.

### 토글 메뉴

`Super + Ctrl + O`를 누르면 _실행 > 토글_이 바로 열리고, Omarchy 메뉴(`Super + Space`)를 통해서도 찾아갈 수 있다. 그 목록에 있는 모든 것은 상태가 어디에 저장되는지 신경 쓸 필요 없이 뒤집을 수 있는 스위치다. 데스크톱의 겉모습을 바꾸는 스위치는 그 옆, _모양_ 아래에 있다.

터미널에서는 같은 스위치를 `omarchy toggle <thing>`으로 조작한다. `omarchy toggle`만 단독으로 실행하면 전체 그룹을 볼 수 있다.

| 토글 | 단축키 | 명령 |
| ------ | ------ | ------- |
| 야간 조명 | — | `omarchy toggle nightlight` |
| 알림 무음 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 깨어 있기 (유휴 잠금 없음) | `Super + Ctrl + I` | `omarchy toggle idle` |
| 충돌 캡처 | — | `omarchy toggle crash-capture` |
| 화면 보호기 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 테마 동기화 | — | `omarchy toggle theme sync` |
| 메뉴 바 | `Super + Shift + Space` | `omarchy toggle bar` |
| 터치패드 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 터치스크린 | — | `omarchy toggle touchscreen` |
| 일시 중단 | — | `omarchy toggle suspend` |
| 하이브리드 GPU | — | `omarchy toggle hybrid gpu` |

터치패드, 터치스크린, 하이브리드 GPU 스위치는 토글 아래가 아니라 _실행 > 하드웨어_(`Super + Ctrl + H`) 아래에 있다. 해당 하드웨어가 실제로 있을 때만 나타나기 때문이다. 터치패드와 터치스크린 스위치는 Hyprland를 다시 불러와도 유지된다 — 비활성화된 장치의 이름이 작은 상태 파일에 저장되고, Hyprland가 시작할 때 그 파일을 읽어 다시 비활성화한다.

_모양_에는 메뉴 바와 애니메이션이 있고, `omarchy toggle` 명령은 아니지만 똑같이 동작하는 몇 가지도 함께 있다: 바에 표시되는 배터리 백분율, 기본 워크스페이스 레이아웃, 그리고 _창_ 아래의 창 간격(`Super + Shift + Backspace`)과 창 1개일 때의 정사각형 비율(`Super + Ctrl + Backspace`)이다.

이들 대부분은 `~/.local/state/omarchy/toggles/` 아래에 있는 플래그 파일일 뿐이다. 스크립트에서 이를 기준으로 분기하고 싶다면, 직접 찾으러 다닐 필요 없이 `omarchy-toggle-enabled`가 종료 코드를 제공한다:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

플래그는 꺼진 상태를 기준으로 이름이 붙는다 — `screensaver-off`, `suspend-off`, `bar-off` — 따라서 파일이 존재하면 그 기능은 비활성화된 것이다.

### 바의 인디케이터

모드가 켜지면 상단 바 가운데, 시계 옆에 작은 글리프가 나타난다. 그것이 인디케이터 위젯이며, 받아쓰기, 화면 녹화, 대기 중인 알림, 야간 조명, 방해 금지, 깨어 있기를 표시한다.

비활성 인디케이터는 숨겨진다. 바 어디에든 마우스를 올리면 흐릿하게 서서히 나타나므로, 단축키를 몰라도 클릭해서 켤 수 있다. 활성 인디케이터를 클릭하면 다시 꺼진다. 항상 모두 표시하고 싶다면 `~/.config/omarchy/shell.json`에서 `omarchy.indicators` 항목의 `alwaysShow`를 `true`로 설정하라 — 바 위젯을 설정하는 방법은 [상단 바](05-the-top-bar.md)를 보라.

### 야간 조명

야간 조명은 화면을 4000K로 따뜻하게 만들고, 다시 토글하면 6500K로 되돌린다. 토글 메뉴(`Super + Ctrl + O`)에서 뒤집거나 `omarchy toggle nightlight`로 뒤집는다. hyprsunset이 구동하는데, 실행 중이 아니면 토글이 대신 시작해 준다.

기본적으로 hyprsunset은 화면에 아무것도 하지 않는다. `~/.config/hypr/hyprsunset.conf`에는 identity 프로필이 함께 제공되는데, 이는 따뜻함을 요청하기 전까지 디스플레이를 그대로 두기 위해서다. 시계에 맞춰 전환되게 하고 싶다면, 이를 시간 프로필로 교체하라:

```
profile {
    time = 20:00
    temperature = 4000
}
```

그런 다음 `~/.config/hypr/autostart.lua`에 `o.launch_on_start("hyprsunset")`를 추가해 로그인 시 hyprsunset이 시작되게 하라. 토글이 사용하는 4000K/6500K 쌍은 고정되어 있으므로, 다른 온도를 원한다면 설정 파일로 가야 한다.

### 방해 금지

`Super + Ctrl + Alt + ,`를 누르면 알림이 무음이 된다. 켜져 있는 동안에는 토스트가 뜨지 않고, 줄에 그어진 종 인디케이터가 바에 앉아 데스크톱이 왜 조용해졌는지 알려 준다.

아무것도 사라지지는 않는다. 무음이 된 알림은 보류된다: `Super + Shift + Alt + ,`를 누르면 최근 몇 개를 다시 화면에 띄울 수 있다. 나머지는 [알림](10-notices.md)을 보라.

그래도 통과하는 메시지에는 두 종류가 있다: 방금 한 일에 대한 Omarchy 자체의 확인 토스트("테마가 변경됨", "스크린샷이 저장됨")와 명령줄에서 보낸 긴급 경고다. 모든 것을 긴급으로 표시해 억지로 앞에 나타나려는 채팅 앱은 여기에 해당하지 않는다.

### 유휴 상태

유휴 동작은 Omarchy 셸이 담당하며, 타이밍은 `~/.config/omarchy/shell.json`의 최상위 `idle` 블록에 있다:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

두 숫자 모두 유휴 상태가 된 순간부터 세는 초 단위 값이다 — 서로를 기준으로 세는 것이 아니다. 따라서 기본값에서는 화면 보호기가 2분 30초 뒤에 나타나고, 화면 보호기가 실행됐는지와 무관하게 잠금 화면이 5분에 이어받는다. 파일을 저장하면 셸이 새 타이밍을 즉시 반영한다.

잠금 마감 전에 화면 보호기를 해제하면 활동으로 간주되어 대기 중인 잠금이 취소된다. 기기를 흘끗 봤다고 해서 잠겨 버리는 일은 없다.

유휴 상태에서의 잠금을 완전히 중단하려면 `Super + Ctrl + I`를 누르거나 — `omarchy toggle idle`을 실행해 — 깨어 있기를 켜면 커피잔 인디케이터가 바에 나타난다. 긴 발표나 지켜보고 싶은 빌드가 시작되기 전에 눌러야 할 바로 그 스위치다. 다시 누르면 정상으로 돌아간다. 스크립트에서 필요하다면 `omarchy toggle idle status`가 현재 상태를 JSON으로 출력한다.

이는 전원이 아니라 잠금과 화면 보호기에 관한 것이다. 일시 중단과 최대 절전 모드는 [시스템 절전](36-system-sleep.md)에 별도로 설정한다.

### 화면 보호기

Omarchy의 화면 보호기는 무작위 텍스트 효과를 거치며 실행되는 ASCII 아트이며, 모니터마다 하나씩 실행된다. 아무 키나 누르거나 마우스를 움직이면 종료된다.

_시스템 > 화면 보호기_(`Super + Esc`)에서 필요할 때 시작할 수 있으며, 유휴 화면 보호기를 꺼 두었더라도 강제로 띄운다. 기본적으로 여기에 바인딩된 단축키는 없다.

작업하다가 바로 잠금으로 넘어가고 싶다면, 유휴 화면 보호기를 끄는 것은 `omarchy toggle screensaver`다. 설정 방법을 아는 터미널 — Alacritty, Foot, Ghostty, 또는 Kitty — 이 필요하며, 기본 터미널이 다른 것이라면 그렇게 알려 준다.

그리는 로고는 _모양 > 브랜딩 > 화면 보호기_에서 바꿀 수 있다. png나 svg를 업로드하면 Omarchy가 ASCII로 변환한다. [브랜딩](41-branding.md)을 보라.

### 잠금 화면

`Super + Ctrl + L`을 누르면 기기가 잠긴다. 그러면 Omarchy 셸의 잠금 화면이 실행되고, 디스플레이가 꺼지고, 엉뚱한 문자 체계로 비밀번호를 입력하는 일이 없도록 키보드 레이아웃이 첫 번째 것으로 재설정되며 — 실행 중이라면 — 나가는 길에 1Password도 잠근다.

잠금 화면은 비밀번호를 받으며, 설정해 두었다면 지문도 받는다. 그 방법과 다른 인증 방법은 [하드웨어 인증](37-hardware-authentication.md)에서 다룬다.
