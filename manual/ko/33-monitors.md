# 모니터

Omarchy는 기본적으로 2x를 지원하는 레티나급 디스플레이를 사용하고 있다고 가정한다. 멋지고 선명한 프로그래머용 폰트를 얻으려면 이게 필요하다. 요즘 나오는 거의 모든 프리미엄 노트북의 고해상도 화면이 여기에 최적화되어 있다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/)나 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)를 쓴다면 이 설정을 원할 것이다.

하지만 PPI가 218 이상인 디스플레이를 쓰고 있지 않다면 모니터 설정을 바꿔야 한다. 예를 들어 27"나 32" 4K를 쓴다면, `~/.config/hypr/monitors.lua`(Omarchy 메뉴의 _Setup > Monitors_에서 접근)를 열고 해당 조합에 권장되는 설정으로 바꿔 분수 배율을 사용할 수 있다:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p나 1440p 디스플레이를 쓴다면 아마 1x 배율만으로 충분할 테니 다음을 쓰면 된다:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` 변경 사항은 변경 후 실행한 애플리케이션에 적용된다(그리고 GTK는 정수만 지원하니 모니터 배율에 가장 가까운 정수로 유지하라). 그러니 변경 후 너무 크게 보이는 창은 반드시 종료하라(아니면 `Ctrl + Alt + Del`로 모든 창을 닫아라!).

`Super + /`로 더 크게, `Super + Alt + /`로 더 작게 해서 주요 모니터 배율(1x, 1.25x, 1.6x, 2x, 3x, 4x)을 빠르게 오갈 수도 있고, 상단 바의 모니터 패널에서 하나를 골라도 된다. 이는 포커스가 있는 모니터에만 적용되므로 노트북 화면과 외부 디스플레이가 각자 자기 배율을 가질 수 있다. 선택한 값은 해당 모니터에 대한 `hl.monitor` 규칙으로 `~/.config/hypr/monitors.lua`에 저장되므로 재부팅 후에도 유지되고, 자체 규칙이 없는 모든 모니터의 배율로 남아 있는 `omarchy_monitor_scale`보다 우선한다.

### 텍스트를 더 크게 또는 더 작게 만들기

모니터 배율은 모든 것의 크기를 바꾼다. 원하는 게 단지 더 크거나 더 작은 _텍스트_뿐이라면, 그 용도의 조절 수단은 하나뿐이다:

```
omarchy display text size 14
```

9에서 20 사이의 픽셀 크기를 받으며, Omarchy 셸, GTK 애플리케이션, 터미널을 함께 움직여 전체 데스크톱의 비율이 유지된다. 인자 없이 실행하면 현재 설정을 확인할 수 있고, `omarchy display text size reset`으로 기본값으로 돌아갈 수 있다. Foot 하나만 뒤처진다: 설정을 다시 불러올 방법이 없어서, 이미 실행 중인 터미널은 새 터미널을 열 때까지 기존 크기를 유지한다.

### 노트북 디스플레이 확장 및 미러링

외부 화면을 노트북에 연결하면 디스플레이가 자동으로 확장된다. 하지만 Omarchy 메뉴의 _Trigger > Hardware_나 `Super + Ctrl + Alt + Delete`를 써서 미러링으로 바꿀 수 있다. 그 외부 화면이 프로젝터이고, 작업하면서 뭔가를 보여주고 싶을 때 특히 유용하다.

확장 중일 때 노트북 덮개를 닫으면 내부 화면이 자동으로 꺼진다. 덮개를 열면 다시 켜진다. Omarchy 메뉴의 _Trigger > Hardware_나 `Super + Ctrl + Delete`를 써서 수동으로 제어할 수도 있다.

### 여러 화면 배치하기

Hyprland는 여러 화면과도 훌륭하게 동작한다. 배치 방법은 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)에서 더 자세히 읽어보라. Omarchy에서는 이 설정을 `hl.monitor` 항목으로 `~/.config/hypr/monitors.lua`에 넣는다 — 이 파일에는 특정 모니터를 해상도, 위치, 회전으로 고정하는 주석 처리된 예제가 함께 들어 있다.

모든 모니터는 각각 1부터 10까지의 작업공간을 가지므로, `Super + 1`은 항상 지금 있는 모니터의 첫 번째 작업공간을 뜻한다. 내부적으로 Hyprland는 여전히 모든 모니터에 걸쳐 작업공간에 번호를 매긴다: 노트북 화면(또는 첫 번째 모니터)은 1–10을, 다음 모니터는 11–20을 받는 식이며, 각 모니터는 연결할 때마다 자기 블록을 유지한다. 특정 모니터에 대한 [작업공간 규칙](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)이나 창 규칙을 작성할 때는 이 번호를 사용하라. 예를 들어 작업공간 12는 두 번째 모니터의 두 번째 작업공간이다. `~/.local/state/omarchy/monitor-workspaces`에는 각 모니터가 어떤 블록을 가졌는지 나와 있다.

방향키는 레이아웃에서 가장자리를 공유하는 모니터 사이에서는 동작한다. 모서리에서만 닿거나 사이에 간격이 있는 화면은 이웃이 아니므로, 그 사이를 이동하려면 `Ctrl + Alt + Tab`을 사용하라.

| 단축키 | 모니터 간 동작 |
| --- | --- |
| `Super + Arrow` | 그 방향에 더 이상 창이 없으면 그쪽 모니터로 포커스를 이동한다 |
| `Super + Shift + Arrow` | 그쪽 모니터에 있는 창과 교환한다 |
| `Super + Alt + Arrow` | 창을 그쪽 모니터에 있는 그룹으로 이동한다 |
| `Super + Shift + Ctrl + Arrow` | 창을 그쪽 모니터가 표시 중인 작업공간으로 이동한다 |
| `Super + Shift + Alt + Arrow` | 작업공간을 그쪽 모니터로 이동하며, 비어 있으면 번호를 유지한다 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 레이아웃과 상관없이 다음 또는 이전 모니터로 포커스를 이동한다 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 지금 있는 모니터에 머무른다 |

여러 화면의 위치 지정을 도와줄 TUI를 원한다면 [Hyprmon](https://github.com/erans/hyprmon/)도 살펴보라.

### 밝기 제어

모니터 밝기는 밝기 올리기/내리기 전용 기능 키로 제어한다. Shift를 누른 채 이 키들을 누르면 최대 또는 최소 밝기로 이동한다. 이 키들은 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조절된다.

### Apple 디스플레이

Apple 디스플레이를 쓴다면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 동작한다. 이는 `asdcontrol` 명령을 통해 이뤄진다.

Apple 6K XDR 디스플레이를 쓴다면 `hyprctl monitors` 목록에 유령 화면이 보일 수 있다. _Setup > Monitors_에서 `hl.monitor({ output = "DP-2", disabled = true })` 같은 설정으로 이를 끌 수 있다.

Intel 기기에서는 일반 Thunderbolt 케이블로 Apple 디스플레이에 연결해야 한다. Thunderbolt가 없는 다른 기기에서는 보통 작동하게 만들려면 [DP + USB-A -> USB-C 케이블](https://www.amazon.com/dp/B0BNX7MS6N)을 써야 한다.
