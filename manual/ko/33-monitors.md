# 모니터

Omarchy는 기본적으로 2x를 지원하는 레티나급 디스플레이를 사용하고 있다고 가정합니다. 멋지고 선명한 프로그래머용 글꼴을 얻으려면 바로 이게 필요합니다. 고해상도 화면을 갖춘 거의 모든 최신 프리미엄 노트북이 여기에 최적화되어 있습니다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 또는 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)에서 실행하고 싶어지는 것도 바로 이겁니다.

하지만 PPI가 218 이상인 디스플레이를 사용하고 있지 않다면 모니터 설정을 바꾸는 게 좋습니다. 예를 들어 27" 또는 32" 4K를 사용한다면, `~/.config/hypr/monitors.lua`(Omarchy 메뉴의 _설정 > 모니터_를 통해)를 열고 해당 조합에 대한 권장 설정으로 전환해 부분 배율을 사용할 수 있습니다:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p 또는 1440p 디스플레이를 사용한다면 아마 1x 배율만으로 충분할 것이므로, 다음을 사용할 수 있습니다:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE`의 변경 사항은 변경 후 시작된 애플리케이션에 적용됩니다(GTK는 정수만 허용하므로, 모니터 배율에 가장 가까운 정수로 유지하세요). 따라서 변경 후 크기가 너무 커진 창은 반드시 종료하세요(또는 `Ctrl + Alt + Del`로 모든 창을 닫으세요!).

`Super + /`로 높이고 `Super + Alt + /`로 낮추면서 주요 모니터 배율 단계(1x, 1.25x, 1.6x, 2x, 3x, 4x)를 빠르게 오가거나, 상단 바의 모니터 패널에서 하나를 선택할 수도 있습니다. 이 기능은 현재 포커스가 있는 모니터만 변경하므로, 노트북 화면과 외부 디스플레이가 각자 다른 배율을 가질 수 있습니다. 선택한 값은 해당 모니터에 대한 `hl.monitor` 규칙으로 `~/.config/hypr/monitors.lua`에 저장되므로 재부팅 후에도 유지되며, 자체 규칙이 없는 모든 모니터의 배율로 남는 `omarchy_monitor_scale`보다 우선합니다. `GDK_SCALE`은 모든 화면에 적용되는 단일 값이므로, 이 변경은 가장 낮은 배율을 가진 모니터를 기준으로 그 값을 설정합니다. 그래서 X11 앱이 다른 화면에서 너무 커지는 대신 밀도가 더 높은 화면에서는 조금 작게 표시됩니다.

### 텍스트 크게 또는 작게 만들기

모니터 배율은 모든 것의 크기를 바꿉니다. 원하는 게 더 크거나 작은 _텍스트_뿐이라면, 그 용도의 조절 장치는 하나만 있습니다:

```
omarchy display text size 14
```

9에서 20 사이의 픽셀 크기를 지정하면 Omarchy 셸, GTK 애플리케이션, 터미널이 함께 움직여 전체 데스크톱의 비율이 유지됩니다. 인수 없이 실행하면 현재 상태를 확인할 수 있고, `omarchy display text size reset`으로 기본값으로 돌아갈 수 있습니다. Foot 하나만 뒤처집니다: 설정을 다시 불러올 방법이 없어서, 실행 중인 터미널은 새 터미널을 열 때까지 기존 크기를 유지합니다.

### 노트북 디스플레이 확장 및 미러링

노트북에 외부 화면을 연결하면 디스플레이가 자동으로 확장됩니다. 하지만 Omarchy 메뉴의 _트리거 > 하드웨어_ 또는 `Super + Ctrl + Alt + Delete`를 이용해 대신 미러링으로 바꿀 수 있습니다. 특히 그 외부 화면이 프로젝터이고 작업하면서 뭔가를 보여주고 싶을 때 도움이 됩니다.

확장 중일 때 노트북 덮개를 닫으면 내장 화면이 자동으로 꺼집니다. 덮개를 열면 다시 켜집니다. Omarchy 메뉴의 _트리거 > 하드웨어_ 또는 `Super + Ctrl + Delete`를 이용해 수동으로 제어할 수도 있습니다.

### 여러 화면 배치하기

Hyprland는 여러 화면도 훌륭하게 처리합니다. 배치 방법은 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)에서 더 자세히 읽어보세요. Omarchy에서는 이 설정이 `~/.config/hypr/monitors.lua`에 `hl.monitor` 항목으로 들어갑니다 — 이 파일에는 특정 모니터를 해상도, 위치, 회전으로 고정하는 주석 처리된 예제가 함께 제공됩니다.

모든 모니터에는 자체적인 1부터 10까지의 작업 공간이 있어서, `Super + 1`은 항상 현재 있는 모니터의 첫 번째 작업 공간을 의미합니다. 내부적으로 Hyprland는 여전히 모든 모니터에 걸쳐 작업 공간에 번호를 매깁니다: 노트북 화면(또는 첫 번째 모니터)은 1–10, 다음 모니터는 11–20, 이런 식으로 이어지며, 각 모니터는 연결할 때마다 자신의 블록을 그대로 유지합니다. 특정 모니터에 대한 [작업 공간 규칙](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)이나 창 규칙을 작성할 때는 이 번호를 사용하세요. 예를 들어 작업 공간 12는 두 번째 모니터의 두 번째 작업 공간입니다. `~/.local/state/omarchy/monitor-workspaces`에는 각 모니터가 어떤 블록을 가지고 있는지 나열됩니다.

방향키는 레이아웃에서 한쪽 가장자리를 공유하는 모니터 사이에서 작동합니다. 모서리에서만 닿거나 사이에 간격이 있는 화면은 이웃이 아니므로, 그 사이를 이동하려면 `Ctrl + Alt + Tab`을 사용하세요.

| 단축키 | 모니터 간 |
| --- | --- |
| `Super + Arrow` | 그 방향에 남은 창이 더 이상 없을 때 해당 방향의 모니터로 포커스를 이동합니다 |
| `Super + Shift + Arrow` | 해당 방향 모니터에 있는 창과 교체합니다 |
| `Super + Alt + Arrow` | 창을 해당 방향 모니터에 있는 그룹으로 이동합니다 |
| `Super + Shift + Ctrl + Arrow` | 창을 해당 방향의 모니터로, 그 모니터가 표시 중인 작업 공간으로 이동합니다 |
| `Super + Shift + Alt + Arrow` | 작업 공간을 해당 방향의 모니터로 이동하며, 비어 있으면 번호를 유지합니다 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 레이아웃과 상관없이 다음 또는 이전 모니터로 포커스를 이동합니다 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 현재 모니터에 머무릅니다 |

여러 화면의 위치 조정에 도움이 되는 TUI를 원한다면 [Hyprmon](https://github.com/erans/hyprmon/)도 확인해보세요.

### 밝기 제어

모니터 밝기는 전용 밝기 높이기/낮추기 기능 키로 제어합니다. 이 키를 누를 때 Shift를 누르고 있으면 최대 또는 최소 밝기로 이동합니다. 이 키는 현재 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조정됩니다.

### Apple 디스플레이

Apple 디스플레이를 사용 중이라면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 작동합니다. 이는 `asdcontrol` 명령을 통해 이루어집니다.

Apple 6K XDR 디스플레이를 사용 중이라면 `hyprctl monitors` 목록에 유령 화면이 보일 수 있습니다. _설정 > 모니터_에서 `hl.monitor({ output = "DP-2", disabled = true })` 같은 설정으로 이를 끌 수 있습니다.

Intel 컴퓨터에서는 일반 Thunderbolt 케이블로 Apple 디스플레이에 연결해야 합니다. Thunderbolt가 없는 다른 컴퓨터에서는 보통 이를 작동시키려면 [DP + USB-A -> USB-C 케이블](https://www.amazon.com/dp/B0BNX7MS6N)을 사용해야 합니다.
