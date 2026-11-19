# 키보드, 마우스, 트랙패드

Hyprland에서는 모든 입력 장치를 아주 세밀하게 설정할 수 있다. 키보드 반복 속도를 초음속으로 빠르게 만들 수도 있고, 트랙패드에서 자연스러운 스크롤을 사용하게 할 수도 있다. 이 모든 것은 `~/.config/hypr/input.lua`에서 변경하며, Omarchy 메뉴(`Super + Space`)의 _Setup > Input_을 통해서도 접근할 수 있다. 거기서 설정한 내용은 Omarchy의 기본값을 대체한다.

예시는 다음과 같다:

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

입력과 관련해서는 Hyprland 위키에서 [모든 입력 옵션 보기](https://wiki.hypr.land/Configuring/Basics/Variables/#input)를 할 수 있다.

CapsLock은 일반 Caps Lock으로 작동하고, `Shift + CapsLock`은 [빠른 이모지](07-hotkeys.md#quick-emojis)와 [기타 완성](07-hotkeys.md#quick-completions)을 위한 컴포즈 키다. 컴포즈 키를 다른 곳에 두고 싶다면 `kb_options`에서 `omarchy:shift_caps_compose`를 교체하면 된다. 예를 들어, 다음은 컴포즈 키를 Right Alt로 옮긴다:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 기능 키

노트북 키보드의 맨 윗줄은 기본적으로 미디어 키(볼륨, 밝기 등)를 보내고, `Fn`을 누르고 있으면 F1-F12를 사용할 수 있으며, `Fn + Esc`를 누르면 그 반대 방식으로 잠기고 다시 누를 때까지 유지된다. 대부분의 키보드는 그 잠금 상태를 스스로 기억한다. ASUS 노트북과 Apple 스타일 키보드는 이를 Linux에 맡기는데, Linux는 부팅할 때마다 미디어 키로 시작한다. 대신 F1-F12로 시작하게 하려면 `omarchy device keyboard toprow fnkeys`를 실행하고(되돌리려면 `omarchy device keyboard toprow mediakeys`), 일부 노트북에서는 재부팅 후 적용된다. Apple Silicon Mac은 자체 설정을 유지한다.

### 트랙패드 제스처

트랙패드를 스와이프해 데스크톱을 이동한다:

| 제스처 | 동작 |
| --- | --- |
| 세 손가락 왼쪽 / 오른쪽 | 빈 워크스페이스를 포함해 이전 / 다음 워크스페이스 |
| 세 손가락 위로 | AI 콘솔 토글 |
| 세 손가락 아래로 | Omarchy 메뉴 열기 |
| 네 손가락 왼쪽 / 오른쪽 | 활성 창을 이전 / 다음 워크스페이스로 이동 |
| 네 손가락 아래로 | 전체 화면 토글 |

하나를 변경하려면, Hyprland는 같은 손가락 수와 방향에 두 개의 제스처를 허용하지 않으므로, 자신의 [트랙패드 제스처](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)를 추가하기 전에 `~/.config/hypr/input.lua`에서 해당 제스처를 해제한다:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy의 모든 제스처를 끄려면, Omarchy의 기본값이 로드되기 전에 `~/.config/hypr/hyprland.lua` 상단 근처에서 `omarchy_default_gestures = false`로 설정한다.

햅틱 터치패드가 있는 Dell XPS 노트북에서는 _Trigger > Hardware > Touchpad Haptics_ 아래에서 클릭 강도를 low, mid 또는 high로 설정할 수도 있다.

### 중국어, 일본어 및 기타 언어 입력

설치 프로그램이 키보드를 물을 때 Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) 또는 Hong Kong (Cangjie)를 선택한다. Omarchy는 오프라인 첫 부팅 설정을 포함해 키보드와 그에 맞는 입력 엔진을 자동으로 구성한다. Japanese는 Mozc를 사용하고, Korean은 표준 두벌식 Hangul를 사용하며, Simplified Chinese는 Pinyin을 사용하고, Taiwan은 Chewing의 표준 Zhuyin 배열을 사용하며, Hong Kong은 Hong Kong 문자 형태를 사용하는 Cangjie를 사용한다. Japanese (US keyboard)는 US 키보드 레이아웃과 함께 Mozc를 제공한다. Dvorak, Colemak 또는 AZERTY로 라틴 문자를 입력할 때도 Hangul, Zhuyin 및 Cangjie 키는 표준 위치에 그대로 유지된다. 이전에 Hangul이나 Chewing을 추가한 적이 있다면, _Setup > Keyboard > Input Methods_에서 선택을 해제했다가 다시 선택해 그 키들을 해당 위치로 옮긴다; 이미 입력에 사용 중인 엔진은 Omarchy가 그대로 둔다.

입력은 Latin 모드에서 시작한다. `Super + I`를 눌러 구성된 입력 방식을 순환하고, `Super + Shift + I`를 눌러 역방향으로 순환한다. `Shift`만 단독으로 탭하면 Pinyin 같은 입력 방식에서 빠져나와 라틴 문자로 전환하고, 다시 탭하면 Sogou, Microsoft Pinyin 및 macOS가 작동하는 방식처럼 돌아간다; `Shift`와 문자를 함께 누르면 여전히 대문자가 입력된다. Japanese 키보드에서는 全角/半角가 입력을 토글하고, 変換는 입력을 켜며, 無変換는 입력을 끈다. Korean에서는 한/영가 Hangul를 전환하고 한자이 Hanja로 변환하는데, 키보드에 전용 키가 있든 많은 노트북처럼 Right Alt와 Right Ctrl을 보내든 마찬가지이므로, 거기서는 Right Alt와 Right Ctrl이 일반 수정자 키가 아니다; 대신 받아쓰기는 Alt + Space로 토글한다. `Ctrl + Space`는 Tmux와 Herdr를 위해 그대로 사용할 수 있고, `Shift + CapsLock`은 컴포즈 키로 그대로 유지된다.

키보드 레이아웃이나 입력 방식이 여러 개일 때는 바 오른쪽에 키보드 표시기가 나타난다. 이를 클릭해 입력 언어를 전환한다; Japanese는 히라가나에 대해 あ를 표시한다. Japanese 문자 선택을 하려면 Japanese로 전환하고 `nihongo` 같은 단어를 입력한 다음 Space를 두 번 누른다. Enter를 눌러 선택을 확정한다. 키보드 레이아웃도 여러 개라면 표시기를 오른쪽 클릭해 레이아웃을 순환한다.

_Setup > Keyboard > Keyboard Inputs_를 사용해 설치 중 제공된 것과 같은 선택지에서 English와 French 같은 레이아웃을 선택한다. _Setup > Keyboard > Input Methods_를 사용해 활성화할 입력 엔진을 선택한다. 두 선택기 모두 현재 선택 항목이 체크된 상태로 Omarchy 메뉴 안에서 열린다. 클릭하거나 Enter를 눌러 선택을 토글한다; 각 변경은 즉시 적용된다. 입력 방식의 선택을 해제하면 제거하지 않고 순환 목록에서만 빠진다; 키보드는 계속 사용할 수 있다.

`omarchy setup keyboard` 또는 `omarchy setup input`을 실행하면 같은 선택기가 열린다. 명령줄에서 언어 하나를 추가하려면 `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` 또는 `cangjie5`를 사용한다. Quick, Boshiamy 및 Array는 Cangjie와 같은 패키지에 들어 있으며 Input Methods 선택기에 나타난다. 사용자 지정 전환 키는 그대로 보존된다. 대체 엔진 레이아웃이나 키를 사용하려면 `omarchy pkg add fcitx5-configtool`로 `fcitx5-configtool`을 설치하고 터미널에서 실행한다. 입력 언어를 선택해도 데스크톱 언어는 바뀌지 않는다. 아직 입력 방식이 없을 때 _Setup > Language_에서 Japanese, Korean 또는 Chinese를 선택하면 해당 입력 방식이 추가된다.

`Super + I`를 사용해 입력 방식이나 키보드 레이아웃을 순환하고, `Super + Shift + I`를 사용해 반대 방향으로 돌아간다. 따라서 세 개가 구성되어 있으면 이웃한 두 항목 사이를 오갈 수 있다. 입력 표시기는 입력 방식이나 레이아웃이 두 개 이상 구성되어 있을 때만 바 오른쪽에 나타난다. 이 데스크톱 바인딩은 기존 Fcitx 전환 키와 함께 작동하며, `~/.config/hypr/bindings.lua`에서 재정의할 수 있다. 입력 엔진과 컴포즈 시퀀스는 모든 세션에서 이미 실행 중인 [Fcitx5](https://fcitx-im.org/) 서비스를 사용한다.

### ALT를 SUPER로 사용하기

일부 키보드에서는 기본 메타 키(Windows/cmd 키)를 SUPER로 사용하는 것이 편하지 않다. 다음 변경으로 대신 ALT를 사용하게 바꿀 수 있다:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
