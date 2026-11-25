# 토글, 유휴 상태와 화면 보호기

매일 바꾸는 것들 중 상당수는 사실 설정이 아니다. 한 시간 동안 켜 두었다가 다시 끄는 모드다: 늦게까지 일할 때의 야간 모드, 발표할 때의 방해 금지, 무언가를 보고 있을 때의 깨어 있기. Omarchy는 이것들을 토글이라고 부르며, 모두 같은 방식으로 작동한다 — 단축키, 메뉴 항목, 명령이 모두 같은 스위치를 건드린다.

### 토글 메뉴

`Super + Ctrl + O`를 누르면 _Trigger > Toggle_이 바로 열리고, Omarchy 메뉴(`Super + Space`)를 거쳐 갈 수도 있다. 그 목록에 있는 모든 것은 상태가 어디에 저장되는지 생각할 필요 없이 뒤집을 수 있는 스위치다. 데스크톱의 외관을 결정하는 스위치들은 그 옆의 _Appearance_ 아래에 있다.

터미널에서는 같은 스위치들이 `omarchy toggle <thing>`이다. `omarchy toggle`만 실행하면 전체 그룹을 볼 수 있다.

| 토글 | 단축키 | 명령 |
| ------ | ------ | ------- |
| 야간 모드 | — | `omarchy toggle nightlight` |
| 알림 음소거 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 깨어 있기 (유휴 잠금 없음) | `Super + Ctrl + I` | `omarchy toggle idle` |
| 충돌 캡처 | — | `omarchy toggle crash-capture` |
| 화면 보호기 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 테마 동기화 | — | `omarchy toggle theme sync` |
| 메뉴 바 | `Super + Shift + Space` | `omarchy toggle bar` |
| 전체 화면 데스크톱 (바 없음, 간격 없음) | `Super + Ctrl + Alt + F` | `omarchy toggle fullscreen desktop` |
| 애니메이션, 블러 및 그림자 | — | `omarchy toggle animations` |
| 터치패드 | `XF86TouchpadToggle` | `omarchy device touchpad` |
| 터치스크린 | — | `omarchy device touchscreen` |
| 일시 중단 | — | `omarchy toggle suspend` |
| 하이브리드 GPU | — | `omarchy device gpu hybrid` |

터치패드, 터치스크린, 하이브리드 GPU 스위치는 Toggle 아래가 아니라 _Trigger > Hardware_ (`Super + Ctrl + H`) 아래에 있다. 해당 하드웨어가 실제로 있을 때만 나타나기 때문이다. 터치패드와 터치스크린 스위치는 Hyprland를 다시 로드해도 유지된다 — 비활성화된 기기의 이름이 작은 상태 파일에 저장되고, Hyprland가 시작할 때 그 파일을 읽어 다시 비활성화한다.

_Appearance_에는 메뉴 바와 애니메이션, 그리고 `omarchy toggle` 명령은 아니지만 똑같이 동작하는 몇 가지가 들어 있다: 바의 배터리 백분율, 기본 워크스페이스 레이아웃, 그리고 _Windows_ 아래의 창 간격(`Super + Shift + Backspace`)과 창 1개 정사각형 비율(`Super + Ctrl + Backspace`)이다.

Hyprland가 그릴 GPU가 없어 대신 CPU로 렌더링할 때(llvmpipe), 예를 들어 GPU가 아직 지원되지 않는 Mac, 대부분의 가상 머신, 또는 그래픽 드라이버를 로드하지 못한 경우, Omarchy는 그 세션 동안 애니메이션, 블러, 그림자를 끄고 알림으로 한 번 알려준다. _Appearance > Animations On_을 선택하면 다시 켜지며, Omarchy는 이후 세션을 위해서도 그 설정을 기억한다.

대부분은 `~/.local/state/omarchy/toggles/` 아래의 플래그 파일일 뿐이다. 스크립트에서 그중 하나를 기준으로 분기하고 싶다면, 직접 찾아다닐 필요 없이 `omarchy-toggle-enabled`가 종료 코드를 제공한다:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

플래그는 꺼진 상태를 기준으로 이름이 붙는다 — `screensaver-off`, `suspend-off`, `bar-off` — 따라서 파일이 존재하면 해당 기능이 비활성화된 것이다.

### 바의 표시기

모드가 켜져 있으면 시계 옆 상단 바 중앙에 작은 글리프가 표시된다. 그것이 표시기 위젯이며, 화면 녹화, 보류 중인 리마인더, 야간 모드, 방해 금지, 깨어 있기를 표시하고, 비밀번호 없는 sudo가 켜져 있거나 누군가 원격 세션에 접속해 있을 때는 경고를 표시한다.

비활성 표시기는 숨겨진다. 바 어디에든 마우스를 올리면 희미하게 나타나므로, 단축키를 몰라도 클릭해서 켤 수 있다. 활성화된 표시기를 클릭하면 다시 꺼진다. 항상 모두 표시하고 싶다면 `~/.config/omarchy/shell.json`에서 `omarchy.indicators` 항목의 `alwaysShow`를 `true`로 설정하라 — 바 위젯을 구성하는 방법은 [상단 바](05-the-top-bar.md)를 참조하라.

### 야간 모드

야간 모드는 화면을 4000K로 따뜻하게 만들고, 다시 토글하면 6500K로 되돌린다. 토글 메뉴(`Super + Ctrl + O`)에서 뒤집거나 `omarchy toggle nightlight`를 사용하라. 이는 hyprsunset이 구동하며, 아직 실행 중이 아니라면 토글이 대신 시작해 준다.

기본적으로 hyprsunset은 화면에 아무것도 하지 않는다. `~/.config/hypr/hyprsunset.conf`에는 항등 프로필이 기본으로 들어 있어, 따뜻함을 요청하기 전까지 디스플레이는 손대지 않은 상태로 유지된다. 시계를 기준으로 전환하고 싶다면 시간 프로필로 교체하라:

```
profile {
    time = 20:00
    temperature = 4000
}
```

그런 다음 `~/.config/hypr/autostart.lua`에 `o.launch_on_start("hyprsunset")`를 추가해 로그인 시 hyprsunset을 시작하라. 토글이 사용하는 4000K/6500K 쌍은 고정되어 있으므로, 다른 온도를 원한다면 설정 파일에서 바꿔야 한다.

### 방해 금지

`Super + Ctrl + Alt + ,`를 누르면 알림이 음소거된다. 켜져 있는 동안에는 토스트가 뜨지 않고, 바에 줄이 그어진 종 표시기가 있어 데스크톱이 왜 조용해졌는지 알려준다.

잃어버리는 것은 없다. 음소거된 알림은 보류된다: `Super + Shift + Alt + ,`를 누르면 최근 몇 개를 다시 화면에 표시할 수 있다. 나머지는 [알림](10-notices.md)을 참조하라.

세 종류의 메시지는 여전히 통과한다: 방금 한 일에 대한 Omarchy 자체의 확인 토스트("Theme changed", "Screenshot saved"), 명령줄에서 보낸 중요 알림, 그리고 인증 코드다. 모든 것을 중요하다고 표시해 당신 앞에 강제로 나타나려는 채팅 앱은 해당되지 않는다.

### 유휴 상태

Omarchy 셸이 유휴 동작을 담당하며, 타이밍은 `~/.config/omarchy/shell.json`의 최상위 `idle` 블록에 있다:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

두 숫자 모두 당신이 유휴 상태가 된 순간부터 세는 초 단위 값이다 — 서로를 기준으로 세는 것이 아니다. 따라서 기본값에서는 2분 30초 후에 화면 보호기가 나오고, 화면 보호기가 실행됐든 안 됐든 5분이 되면 잠금 화면이 이어받는다. 파일을 저장하면 셸이 새 타이밍을 즉시 반영한다.

잠금 기한 전에 화면 보호기를 해제하면 활동으로 간주되어 보류 중인 잠금이 취소된다. 컴퓨터를 힐끗 봤다고 잠겨 버리는 일은 없다.

유휴 시 잠금을 완전히 중단하려면 `Super + Ctrl + I` — 또는 `omarchy toggle idle` — 를 눌러 깨어 있기를 켜면 바에 커피잔 표시기가 나타난다. 긴 발표나 지켜보고 싶은 빌드 전에 눌러야 할 것이 바로 이것이다. 다시 누르면 정상으로 돌아간다. 스크립트에서 필요하다면 `omarchy toggle idle status`가 현재 상태를 JSON으로 출력한다.

이것은 잠금과 화면 보호기에 대한 것이지 전원에 대한 것이 아니다. 일시 중단과 최대 절전 모드는 [시스템 절전](36-system-sleep.md)에 별도로 설정되어 있다.

### 화면 보호기

Omarchy의 화면 보호기는 무작위 텍스트 효과를 거치는 ASCII 아트이며, 모니터마다 인스턴스가 하나씩 실행된다. 어떤 키를 누르거나 마우스를 움직여도 종료된다.

_System > Screensaver_(`Super + Esc`)에서 필요할 때 시작할 수 있으며, 유휴 화면 보호기를 꺼 두었더라도 강제로 표시된다. 기본적으로 여기에 연결된 단축키는 없다.

작업하다가 바로 잠금 상태로 가고 싶다면 `omarchy toggle screensaver`로 유휴 화면 보호기를 끌 수 있다. 어떤 키, 클릭, 스크롤, 마우스 움직임으로도 닫힌다.

그리는 로고는 _Appearance > Branding > Screensaver_에서 원하는 대로 바꿀 수 있다. png나 svg를 업로드하면 Omarchy가 ASCII로 변환한다. [브랜딩](41-branding.md)을 참조하라.

### 잠금 화면

`Super + Ctrl + L`을 누르면 컴퓨터가 잠긴다. 그러면 Omarchy 셸의 잠금 화면이 실행되고, 디스플레이가 꺼지며, 잘못된 알파벳으로 비밀번호를 입력하지 않도록 키보드 레이아웃이 첫 번째 것으로 재설정되고, 실행 중이라면 나가는 길에 1Password도 잠근다.

잠금 화면은 비밀번호를 받으며, 지문을 설정해 두면 지문도 받는다. 그 방법과 다른 인증 방법은 [하드웨어 인증](37-hardware-authentication.md)에 설명되어 있다.
