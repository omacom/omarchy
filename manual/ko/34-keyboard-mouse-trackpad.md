# 키보드, 마우스, 트랙패드

Hyprland를 사용하면 모든 입력 장치를 매우 세밀하게 설정할 수 있습니다. 키보드 반복 속도를 초음속으로 빠르게 바꾸거나 트랙패드에서 자연스러운 스크롤을 사용하게 할 수 있습니다. 이 모든 것은 `~/.config/hypr/input.lua`에서 변경합니다. 이 파일은 Omarchy 메뉴(`Super + Space`)의 _설정 > 입력_을 통해서도 열 수 있습니다. 거기에서 설정한 내용은 Omarchy의 기본값을 대체합니다.

예시는 다음과 같습니다:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Hyprland 위키에서 입력에 관한 [모든 입력 옵션 보기](https://wiki.hypr.land/Configuring/Basics/Variables/#input)를 확인할 수 있습니다.

CapsLock은 일반적인 Caps Lock으로 작동하고, `Shift + CapsLock`은 [빠른 이모지](07-hotkeys.md#quick-emojis)와 [기타 완성](07-hotkeys.md#quick-completions)을 위한 조합 키입니다. 조합 키를 다른 곳으로 옮기고 싶다면 `kb_options`에서 `omarchy:shift_caps_compose`를 교체하십시오. 예를 들어, 다음은 조합 키를 Right Alt로 옮깁니다:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 트랙패드 제스처

트랙패드에서 스와이프하면 데스크톱을 이동할 수 있습니다:

| 제스처 | 동작 |
| --- | --- |
| 세 손가락 왼쪽 / 오른쪽 | 빈 워크스페이스를 포함해 이전 / 다음 워크스페이스 |
| 세 손가락 위로 | AI 콘솔 토글 |
| 세 손가락 아래로 | Omarchy 메뉴 열기 |
| 네 손가락 왼쪽 / 오른쪽 | 활성 창을 이전 / 다음 워크스페이스로 이동 |
| 네 손가락 아래로 | 전체 화면 토글 |

하나를 변경하려면, Hyprland는 같은 손가락 수와 같은 방향에 두 가지 제스처를 허용하지 않으므로, 자신만의 [트랙패드 제스처](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)를 추가하기 전에 `~/.config/hypr/input.lua`에서 해당 제스처를 해제하십시오:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy의 모든 제스처를 끄려면, Omarchy의 기본값이 로드되기 전에 `~/.config/hypr/hyprland.lua` 상단 근처에 `omarchy_default_gestures = false`를 설정하십시오.

햅틱 터치패드가 있는 Dell XPS 노트북에서는 _Trigger > 하드웨어 > Touchpad Haptics_에서 클릭 강도를 낮음, 중간, 높음으로 설정할 수도 있습니다.

### 중국어, 일본어 및 기타 언어로 입력하기

설치 프로그램이 키보드를 물을 때 일본어, 한국어, 중국어(간체, Pinyin), 대만(Zhuyin) 또는 홍콩(Cangjie)을 선택하십시오. Omarchy는 오프라인 첫 부팅 설정을 포함해 키보드와 그에 맞는 입력 엔진을 자동으로 구성합니다. 일본어는 Mozc를, 한국어는 표준 두벌식 Hangul을, 중국어 간체는 Pinyin을, 대만은 Chewing의 표준 Zhuyin 배열을, 홍콩은 홍콩 문자 형태를 사용하는 Cangjie를 사용합니다. 일본어(US 키보드)는 US 키보드 레이아웃과 함께 Mozc를 제공합니다. Hangul, Zhuyin, Cangjie 키는 Dvorak, Colemak 또는 AZERTY로 라틴 문자를 입력할 때도 표준 위치에 그대로 유지됩니다. 이전에 Hangul이나 Chewing을 추가한 적이 있다면, _설정 > 입력 > 입력 방식_에서 해당 항목을 선택 취소한 뒤 다시 선택해 키를 그 위치로 옮기십시오. 이미 입력에 사용하고 있는 엔진은 Omarchy가 그대로 둡니다.

입력은 라틴 모드에서 시작합니다. `Super + I`를 눌러 구성된 입력 방식을 순환하고, `Super + Shift + I`를 눌러 역방향으로 순환합니다. `Shift`만 가볍게 눌러 Pinyin 같은 입력 방식에서 벗어나 라틴 문자로 전환하고, 다시 가볍게 누르면 Sogou, Microsoft Pinyin, macOS가 작동하는 방식처럼 원래대로 돌아갑니다. `Shift`와 문자를 함께 누르면 여전히 대문자가 입력됩니다. 일본어 키보드에서는 全角/半角가 입력을 토글하고, 変換는 입력을 켜고, 無変換는 입력을 끕니다. 한국어에서는 한/영이 Hangul을 전환하고 한자가 Hanja로 변환합니다. 이는 키보드에 전용 키가 있든, 많은 노트북처럼 해당 키가 Right Alt와 Right Ctrl을 보내든 마찬가지입니다. 따라서 거기에서는 Right Alt와 Right Ctrl이 일반 보조 키가 아닙니다. 받아쓰기용 눌러서 말하기는 F9에 그대로 유지됩니다. `Ctrl + Space`는 Tmux와 Herdr를 위해 그대로 사용할 수 있고, `Shift + CapsLock`은 조합 키로 그대로 유지됩니다.

키보드 레이아웃이나 입력 방식이 여러 개일 때 바 오른쪽에 키보드 표시기가 나타납니다. 이를 클릭해 입력 언어를 전환하십시오. 일본어는 히라가나에 대해 あ를 표시합니다. 일본어 문자 선택을 위해서는 일본어로 전환하고 `nihongo` 같은 단어를 입력한 뒤 Space를 두 번 누르십시오. Enter를 눌러 선택을 확정하십시오. 키보드 레이아웃도 여러 개라면, 표시기를 오른쪽 클릭해 레이아웃을 순환하십시오.

_설정 > 입력 > 키보드 레이아웃_을 사용해 설치 중 제공된 것과 같은 선택지에서 영어, 프랑스어 같은 레이아웃을 선택하십시오. _설정 > 입력 > 입력 방식_을 사용해 활성화할 조합 엔진을 선택하십시오. 두 선택기 모두 Omarchy 메뉴 안에서 열리며 현재 선택 항목에 체크가 표시됩니다. 클릭하거나 Enter를 눌러 선택을 토글하십시오. 각 변경 사항은 즉시 적용됩니다. 입력 방식을 선택 취소하면 제거하지 않고 순환에서만 제거합니다. 키보드는 계속 사용할 수 있습니다.

`omarchy setup keyboard` 또는 `omarchy setup input`을 실행하면 같은 선택기를 열 수 있습니다. 명령줄에서 언어 하나를 추가하려면 `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` 또는 `cangjie5`를 사용하십시오. Quick, Boshiamy, Array는 Cangjie와 같은 패키지에 포함되어 있으며 입력 방식 선택기에 나타납니다. 사용자 지정 전환 키는 보존됩니다. 대체 엔진 레이아웃이나 키를 사용하려면 `omarchy pkg add fcitx5-configtool`로 `fcitx5-configtool`을 설치하고 터미널에서 실행하십시오. 입력 언어를 선택해도 데스크톱 언어는 바뀌지 않습니다. 아직 입력 방식이 없을 때 _설정 > 언어_에서 일본어, 한국어 또는 중국어를 선택하면 해당 입력 방식이 추가됩니다.

`Super + I`를 사용해 입력 방식 또는 키보드 레이아웃을 순환하고, `Super + Shift + I`를 사용해 반대 방향으로 이동하십시오. 따라서 세 개가 구성된 경우 두 이웃 사이를 이동할 수 있습니다. 입력 표시기는 입력 방식이나 레이아웃이 하나보다 많이 구성된 경우에만 바 오른쪽에 나타납니다. 이 데스크톱 바인딩은 기존 Fcitx 전환 키와 함께 작동합니다. `~/.config/hypr/bindings.lua`에서 이를 재정의할 수 있습니다. 입력 엔진과 조합 시퀀스는 모든 세션에서 이미 실행 중인 [Fcitx5](https://fcitx-im.org/) 서비스를 사용합니다.

### ALT를 SUPER로 사용하기

일부 키보드에서는 기본 메타 키(Windows/cmd 키)를 SUPER로 사용하는 것이 편하지 않습니다. 다음 변경을 이용해 대신 ALT를 사용하도록 바꿀 수 있습니다:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
