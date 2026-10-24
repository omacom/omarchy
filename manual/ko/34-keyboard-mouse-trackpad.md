# 키보드, 마우스, 트랙패드

Hyprland는 모든 입력을 아주 세세하게 구성할 수 있게 해줍니다. 키보드 반복을 초음속으로 빠르게 만들거나 트랙패드가 자연 스크롤을 사용하게 할 수 있습니다. 모든 것을 `~/.config/hypr/input.lua`에서 변경합니다. Omarchy 메뉴(`Super + Space`)의 _설정 > 입력_을 통해서도 접근할 수 있습니다. 거기서 설정한 것은 무엇이든 Omarchy 기본값을 교체합니다.

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

입력에 대해 Hyprland 위키에서 [모든 입력 옵션 보기](https://wiki.hypr.land/Configuring/Basics/Variables/#input)를 참고할 수 있습니다.

CapsLock은 일반 Caps Lock으로 동작하며, `Shift + CapsLock`은 [빠른 이모지](07-hotkeys.md#quick-emojis)와 [기타 완성](07-hotkeys.md#quick-completions)을 위한 compose 키입니다. compose 키를 다른 곳에 두고 싶다면, `kb_options`에서 `omarchy:shift_caps_compose`를 교체하세요. 예를 들어, 다음은 compose 키를 Right Alt로 이동시킵니다:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 트랙패드 제스처

세 손가락으로 스와이프해 워크스페이스를 변경하는 것처럼 [터치패드 제스처](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)를 켤 수도 있습니다:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

햅틱 터치패드가 있는 Dell XPS 노트북에서는 _실행 > 하드웨어 > 터치패드 햅틱_에서 클릭 강도를 낮음, 중간, 높음으로 설정할 수도 있습니다.

### 중국어, 일본어 및 기타 언어로 입력하기

설치 프로그램이 키보드를 물을 때 일본어, 한국어, 중국어(간체자, Pinyin), 또는 중국어(번체자, Zhuyin)를 선택하세요. Omarchy는 오프라인 최초 부팅 설정 중을 포함해 키보드와 일치하는 입력 엔진을 자동으로 구성합니다. 일본어는 Mozc를, 한국어는 표준 두벌식 한글을, 간체자 중국어는 Pinyin을, 번체자 중국어는 Chewing의 표준 Zhuyin 배열을 사용합니다. 일본어(US 키보드)는 US 키보드 레이아웃으로 Mozc를 제공합니다.

입력은 라틴 모드에서 시작합니다. `Super + I`를 누르면 구성된 입력 방식을 순환하고, `Super + Shift + I`를 누르면 뒤로 순환합니다. `Shift`를 홀로 탭하면 Pinyin 같은 입력 방식에서 라틴 문자로 빠져나오고, 다시 탭하면 돌아옵니다. Sogou, Microsoft Pinyin, macOS가 동작하는 방식과 같습니다. `Shift`에 문자를 더하면 여전히 대문자가 입력됩니다. 일본어 키보드에서는 전각/반각이 입력을 토글하고, 変換가 켜고, 無変換이 끕니다. 한국어 키보드 레이아웃에서는 전용 한/영 키와 한자 키가 한글로 전환하고 한자로 변환합니다. `Ctrl + Space`는 Tmux와 Herdr에 사용할 수 있도록 남아 있습니다. `Shift + CapsLock`은 compose 키로 남아 있습니다.

키보드 표시기는 여러 키보드 레이아웃이나 입력 방식이 있을 때 막대 오른쪽에 나타납니다. 클릭하면 입력 언어를 전환할 수 있으며, 일본어는 히라가나를 위해 あ를 표시합니다. 일본어 문자 선택을 위해서는 일본어로 전환하고 `nihongo` 같은 단어를 입력한 뒤 Space를 두 번 누르세요. Enter를 눌러 선택을 수락하세요. 여러 키보드 레이아웃도 있다면, 표시기를 마우스 오른쪽 버튼으로 클릭해 그들을 순환하세요.

_설정 > 타이핑 > 키보드 레이아웃_을 사용해 설치 중에 제공되는 것과 같은 선택지에서 영어와 프랑스어 같은 레이아웃을 선택하세요. _설정 > 타이핑 > 입력 방식_을 사용해 어떤 작성 엔진이 활성화되는지 선택하세요. 두 선택기 모두 현재 선택이 체크된 상태로 Omarchy 메뉴 안에서 열립니다. 클릭하거나 Enter를 눌러 선택을 토글하세요. 각 변경은 즉시 적용됩니다. 입력 방식을 선택 해제하면 제거하지 않고 순환에서 제거됩니다. 키보드는 계속 사용할 수 있습니다.

`omarchy setup keyboard`나 `omarchy setup input`을 실행하면 같은 선택기가 열립니다. 명령줄에서 한 언어를 추가하려면 `omarchy setup input mozc`, `hangul`, `pinyin`, 또는 `chewing`을 사용하세요. 사용자 지정 전환 키는 보존됩니다. 대체 엔진 레이아웃이나 키에 대해서는 `omarchy pkg add fcitx5-configtool`로 `fcitx5-configtool`을 설치하고 터미널에서 실행하세요. 입력 언어를 선택해도 데스크톱 언어는 변경되지 않습니다.

`Super + I`를 사용해 입력 방식이나 키보드 레이아웃을 순환하고, `Super + Shift + I`를 사용해 다른 방향으로 가세요. 세 개가 구성되어 있으면 두 이웃 사이에서 이동할 수 있습니다. 입력 표시기는 둘 이상의 입력 방식이나 레이아웃이 구성되어 있을 때만 막대 오른쪽에 나타납니다. 이 데스크톱 바인딩은 기존 Fcitx 전환 키와 함께 동작합니다. `~/.config/hypr/bindings.lua`에서 재정의할 수 있습니다. 입력 엔진과 compose 시퀀스는 모든 세션에서 이미 실행 중인 [Fcitx5](https://fcitx-im.org/) 서비스를 사용합니다.

### ALT를 SUPER로 사용하기

일부 키보드에서는 기본 메타 키(Windows/cmd 키)를 SUPER로 사용하는 것이 편리하지 않습니다. 다음 변경을 사용해 대신 ALT로 변경할 수 있습니다:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
