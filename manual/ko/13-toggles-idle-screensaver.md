# 토글, 유휴 상태와 화면 보호기

일상적으로 바꾸는 것들 중 상당수는 사실 설정이 아닙니다. 한 시간 동안 켰다가 다시 끄는 모드입니다. 늦게까지 일할 때의 야간 조명, 발표 중일 때의 방해 금지, 무언가를 시청하는 동안 깨어 있기 같은 것들입니다. Omarchy는 이를 토글이라고 부르며, 모두 같은 방식으로 작동합니다. 단축키, 메뉴 항목, 명령이 모두 같은 스위치를 누릅니다.

### 토글 메뉴

`Super + Ctrl + O`를 누르면 _트리거 > 토글_이 바로 열리고, Omarchy 메뉴(`Super + Space`)에서 이동할 수도 있습니다. 그 목록에 있는 모든 것은 상태가 어디에 저장되는지 생각할 필요 없이 뒤집을 수 있는 스위치입니다. 데스크톱의 모습과 관련된 스위치는 그 옆의 _외관_ 아래에 있습니다.

터미널에서는 같은 스위치를 `omarchy toggle <thing>`으로 조작합니다. `omarchy toggle`만 실행하면 전체 그룹을 볼 수 있습니다.

| 토글 | 단축키 | 명령 |
| ------ | ------ | ------- |
| 야간 조명 | — | `omarchy toggle nightlight` |
| 알림 무음 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 깨어 있기(유휴 잠금 없음) | `Super + Ctrl + I` | `omarchy toggle idle` |
| 충돌 캡처 | — | `omarchy toggle crash-capture` |
| 화면 보호기 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 테마 동기화 | — | `omarchy toggle theme sync` |
| 메뉴 바 | `Super + Shift + Space` | `omarchy toggle bar` |
| 터치패드 | `XF86TouchpadToggle` | `omarchy device touchpad` |
| 터치스크린 | — | `omarchy device touchscreen` |
| 일시 중단 | — | `omarchy toggle suspend` |
| 하이브리드 GPU | — | `omarchy toggle hybrid gpu` |

터치패드, 터치스크린, 하이브리드 GPU 스위치는 토글 아래가 아니라 _트리거 > 하드웨어_(`Super + Ctrl + H`) 아래에 있습니다. 해당 하드웨어가 실제로 있을 때만 나타나기 때문입니다. 터치패드와 터치스크린 스위치는 Hyprland를 다시 불러와도 유지됩니다. 비활성화된 기기의 이름이 작은 상태 파일에 저장되고, Hyprland가 시작할 때 이를 읽어 다시 비활성화합니다.

_외관_에는 메뉴 바와 애니메이션이 있고, `omarchy toggle` 명령은 아니지만 같은 방식으로 작동하는 몇 가지도 있습니다. 바의 배터리 백분율, 기본 작업 공간 레이아웃, 그리고 _창_ 아래의 창 간격(`Super + Shift + Backspace`)과 1개 창 정사각형 비율(`Super + Ctrl + Backspace`)입니다.

Hyprland가 그릴 GPU가 없어 대신 CPU로 렌더링할 때(llvmpipe), 예를 들어 GPU가 아직 지원되지 않는 Mac, 대부분의 가상 머신, 또는 그래픽 드라이버를 불러오지 못한 경우, Omarchy는 해당 세션에서 애니메이션, 블러, 그림자를 끄고 알림으로 한 번 알려줍니다. _외관 > 애니메이션 켜기_를 선택하면 다시 켜지며, Omarchy는 이후 세션에서도 이를 기억합니다.

이들 대부분은 `~/.local/state/omarchy/toggles/` 아래의 플래그 파일일 뿐입니다. 스크립트에서 이를 기준으로 분기하고 싶다면, 직접 찾아보지 않아도 `omarchy-toggle-enabled`가 종료 코드를 제공합니다:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

플래그는 꺼진 상태 기준으로 이름이 정해집니다. `screensaver-off`, `suspend-off`, `bar-off`처럼, 파일이 있으면 해당 기능이 비활성화된 것입니다.

### 바의 표시기

모드가 켜져 있으면 상단 바 가운데 시계 옆에 작은 글리프가 표시됩니다. 이것이 표시기 위젯이며, 받아쓰기, 화면 녹화, 예정된 미리 알림, 야간 조명, 방해 금지, 깨어 있기를 표시합니다.

비활성 표시기는 숨겨집니다. 바 어디에나 마우스를 올리면 흐리게 나타나므로, 단축키를 몰라도 클릭해서 켤 수 있습니다. 활성 표시기를 클릭하면 다시 꺼집니다. 항상 모두 표시하고 싶다면 `~/.config/omarchy/shell.json`의 `omarchy.indicators` 항목에서 `alwaysShow`를 `true`로 설정하십시오. 바 위젯 구성 방법은 [상단 바](05-the-top-bar.md)를 참조하십시오.

### 야간 조명

야간 조명은 화면을 4000K로 따뜻하게 만들고, 다시 토글하면 6500K로 돌아갑니다. 토글 메뉴(`Super + Ctrl + O`)에서 뒤집거나 `omarchy toggle nightlight`를 사용하십시오. hyprsunset이 구동하며, 실행 중이 아니면 토글이 대신 시작해 줍니다.

기본적으로 hyprsunset은 화면에 아무것도 하지 않습니다. `~/.config/hypr/hyprsunset.conf`에는 identity 프로필이 함께 제공되며, 이는 따뜻함을 요청하기 전까지 디스플레이를 그대로 두기 위한 것입니다. 시계에 맞춰 전환하고 싶다면 시간 프로필로 교체하십시오:

```
profile {
    time = 20:00
    temperature = 4000
}
```

그런 다음 `~/.config/hypr/autostart.lua`에 `o.launch_on_start("hyprsunset")`를 추가하여 로그인 시 hyprsunset을 시작하십시오. 토글이 사용하는 4000K/6500K 쌍은 고정되어 있으므로, 다른 온도를 원한다면 설정 파일을 수정해야 합니다.

### 방해 금지

`Super + Ctrl + Alt + ,`를 누르면 알림이 무음이 됩니다. 켜져 있는 동안에는 토스트가 나타나지 않으며, 데스크톱이 조용해진 이유를 알려주는 줄이 그어진 종 표시기가 바에 표시됩니다.

잃는 것은 없습니다. 무음이 된 알림은 보류됩니다. `Super + Shift + Alt + ,`를 누르면 최근 몇 개를 다시 화면에 표시할 수 있습니다. 나머지는 [알림](10-notices.md)을 참조하십시오.

두 종류의 메시지는 여전히 통과합니다. 방금 수행한 작업에 대한 Omarchy 자체 확인 토스트("Theme changed", "Screenshot saved")와 명령줄에서 보낸 긴급 알림입니다. 모든 것을 긴급으로 표시하여 억지로 앞에 나타나려는 채팅 앱은 해당하지 않습니다.

### 유휴 상태

Omarchy 셸이 유휴 동작을 담당하며, 타이밍은 `~/.config/omarchy/shell.json`의 최상위 `idle` 블록에 있습니다:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

두 숫자 모두 유휴 상태가 된 순간부터 센 초 단위이며, 서로를 기준으로 하지 않습니다. 따라서 기본값에서는 화면 보호기가 2분 30초 후에 나타나고, 화면 보호기가 실행되었는지와 관계없이 잠금 화면이 5분에 대신 나타납니다. 파일을 저장하면 셸이 새 타이밍을 즉시 적용합니다.

잠금 기한 전에 화면 보호기를 해제하면 활동으로 간주되어 보류 중인 잠금이 취소됩니다. 기기를 흘끗 본 것만으로 잠기지는 않습니다.

유휴 잠금을 완전히 중지하려면 `Super + Ctrl + I`를 누르거나 `omarchy toggle idle`로 깨어 있기를 켜면 바에 커피잔 표시기가 나타납니다. 긴 발표나 지켜보고 싶은 빌드 전에 눌러야 하는 것이 바로 이것입니다. 다시 누르면 정상으로 돌아갑니다. 스크립트에서 필요하다면 `omarchy toggle idle status`가 현재 상태를 JSON으로 출력합니다.

이는 전원이 아니라 잠금과 화면 보호기에 관한 것입니다. 일시 중단과 최대 절전 모드는 [시스템 절전](36-system-sleep.md)에 별도로 설정되어 있습니다.

### 화면 보호기

Omarchy의 화면 보호기는 무작위 텍스트 효과를 통해 실행되는 ASCII 아트이며, 모니터마다 하나의 인스턴스가 실행됩니다. 아무 키나 누르거나 마우스를 움직이면 종료됩니다.

_시스템 > 화면 보호기_(`Super + Esc`)에서 필요할 때 시작할 수 있으며, 유휴 화면 보호기를 꺼 두었더라도 강제로 표시됩니다. 기본적으로 바인딩된 단축키는 없습니다.

작업에서 곧바로 잠금으로 이동하고 싶다면 `omarchy toggle screensaver`로 유휴 화면 보호기를 끌 수 있습니다. 아무 키, 클릭, 스크롤 또는 마우스 움직임으로도 닫힙니다.

그리는 로고는 _외관 > 브랜딩 > 화면 보호기_에서 변경할 수 있습니다. png 또는 svg를 업로드하면 Omarchy가 ASCII로 변환합니다. [브랜딩](41-branding.md)을 참조하십시오.

### 잠금 화면

`Super + Ctrl + L`를 누르면 기기가 잠깁니다. 이는 Omarchy 셸의 잠금 화면을 실행하고, 디스플레이를 비우며, 키보드 레이아웃을 첫 번째 레이아웃으로 재설정하여 잘못된 알파벳으로 비밀번호를 입력하지 않도록 하고, 실행 중이라면 잠그는 과정에서 1Password를 잠급니다.

잠금 화면은 비밀번호를 받으며, 지문을 설정하면 지문도 받습니다. 그 방법과 다른 인증 방법은 [하드웨어 인증](37-hardware-authentication.md)에 설명되어 있습니다.
