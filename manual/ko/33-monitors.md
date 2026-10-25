# 모니터

Omarchy는 기본적으로 2x를 지원하는 레티나급 디스플레이를 사용하고 있다고 가정한다. 선명하고 또렷한 프로그래머용 폰트를 얻으려면 바로 이것이 필요하다. 거의 모든 최신 프리미엄 노트북의 고해상도 화면이 이에 최적화되어 있다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 또는 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)를 사용할 때 원하는 것도 바로 이것이다.

하지만 PPI가 218 이상인 디스플레이를 사용하고 있지 않다면 모니터 설정을 변경해야 한다. 예를 들어 27" 또는 32" 4K를 사용한다면, `~/.config/hypr/monitors.lua`(Omarchy 메뉴의 _Setup > Monitors_를 통해 열 수 있다)를 열고 분수 배율(fractional scaling)을 사용해 해당 조합에 대한 권장 설정으로 전환하면 된다:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p 또는 1440p 디스플레이를 사용한다면 아마 1x 배율을 사용하는 편이 나을 것이므로, 다음과 같이 사용하면 된다:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE`에 대한 변경 사항은 변경 후에 시작된 애플리케이션에 적용된다(GTK는 정수만 지원하므로 모니터 배율에 가장 가까운 정수로 유지하라). 따라서 변경 후에 너무 크게 표시되는 창은 반드시 종료하라(또는 `Ctrl + Alt + Del`로 모든 창을 닫아라!).

`Super + /`로 더 높은 배율로, `Super + Alt + /`로 더 낮은 배율로 이동하면서 주요 모니터 배율 비율(1x, 1.25x, 1.6x, 2x, 3x, 4x)을 빠르게 단계별로 전환할 수도 있다. 기본 설정을 사용한다면 이러한 변경 사항은 재부팅 후에도 유지된다.

### 텍스트를 더 크게 또는 더 작게 만들기

모니터 배율은 모든 것의 크기를 변경한다. 원하는 것이 더 크거나 더 작은 _텍스트_뿐이라면, 그 용도의 조절 장치는 단 하나뿐이다:

```
omarchy display text size 14
```

이는 9에서 20 사이의 픽셀 크기를 받으며, Omarchy 셸, GTK 애플리케이션, 터미널을 함께 이동시켜 전체 데스크톱의 비율이 유지되도록 한다. 인수 없이 실행하면 현재 상태를 확인할 수 있고, `omarchy display text size reset`을 실행하면 기본값으로 돌아간다. Foot이 유일하게 뒤처지는 존재다: 설정을 다시 로드할 방법이 없으므로, 실행 중인 터미널은 새 터미널을 열 때까지 기존 크기를 유지한다.

### 노트북 디스플레이 확장 및 미러링

외부 화면을 노트북에 연결하면 디스플레이가 자동으로 확장된다. 하지만 Omarchy 메뉴의 _Trigger > Hardware_ 또는 `Super + Ctrl + Alt + Delete`를 사용해 대신 미러링으로 변경할 수 있다. 이는 특히 외부 화면이 프로젝터이고, 작업하면서 무언가를 보여주고 싶을 때 도움이 된다.

확장 중일 때 노트북 덮개를 닫으면 내부 화면이 자동으로 꺼진다. 덮개를 열면 다시 켜진다. Omarchy 메뉴의 _Trigger > Hardware_ 또는 `Super + Ctrl + Delete`를 사용해 이를 수동으로 제어할 수도 있다.

### 여러 화면 배열하기

Hyprland는 여러 화면과도 훌륭하게 작동한다. 배치 방법에 대한 자세한 내용은 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)를 읽어 보라. Omarchy에서는 이러한 설정이 `hl.monitor` 항목으로 `~/.config/hypr/monitors.lua`에 들어간다 — 이 파일에는 특정 모니터를 해상도, 위치, 회전에 고정하기 위한 주석 처리된 예제가 함께 제공된다.

모든 모니터는 각각 1부터 10까지의 워크스페이스를 가지므로, `Super + 1`은 항상 현재 있는 모니터의 첫 번째 워크스페이스를 의미한다. 내부적으로 Hyprland는 여전히 모든 모니터에 걸쳐 워크스페이스 번호를 매긴다: 노트북 화면(또는 첫 번째 모니터)은 1–10을, 다음 모니터는 11–20을 받는 식이며, 각 모니터는 연결할 때마다 자신의 블록을 유지한다. 특정 모니터에 대한 [워크스페이스 규칙](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)이나 창 규칙을 작성할 때는 이 번호를 사용하라. 예를 들어 워크스페이스 12는 두 번째 모니터의 두 번째 워크스페이스다. `~/.local/state/omarchy/monitor-workspaces`에는 각 모니터가 어떤 블록을 가지고 있는지 나열되어 있다.

화살표 키는 레이아웃에서 가장자리를 공유하는 모니터 간에 작동한다. 모서리에서만 닿아 있거나 사이에 간격이 있는 화면은 이웃이 아니므로, 그 사이를 이동하려면 `Ctrl + Alt + Tab`을 사용하라.

| Hotkey | 모니터 간 |
| --- | --- |
| `Super + Arrow` | 해당 방향에 더 이상 창이 없을 때 해당 쪽 모니터로 포커스를 이동한다 |
| `Super + Shift + Arrow` | 해당 쪽 모니터에 있는 창과 교체한다 |
| `Super + Alt + Arrow` | 창을 해당 쪽 모니터에 있는 그룹으로 이동한다 |
| `Super + Shift + Ctrl + Arrow` | 창을 해당 쪽 모니터로, 그 모니터가 표시하고 있는 워크스페이스 위로 이동한다 |
| `Super + Shift + Alt + Arrow` | 워크스페이스를 해당 쪽 모니터로 이동하며, 비어 있다면 그 번호를 유지한다 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 레이아웃과 관계없이 다음 또는 이전 모니터로 포커스를 이동한다 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 현재 있는 모니터에 머문다 |

여러 화면의 위치 지정을 도와주는 TUI를 원한다면 [Hyprmon](https://github.com/erans/hyprmon/)도 확인해 보라.

### 밝기 조절

모니터 밝기는 밝기 증가/감소 전용 기능 키로 조절한다. 이 키를 누를 때 shift를 누르고 있으면 최대 또는 최소 밝기로 이동한다. 키는 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조정된다.

### Apple 디스플레이

Apple 디스플레이를 사용한다면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 작동한다. 이는 `asdcontrol` 명령을 통해 이루어진다.

Apple 6K XDR 디스플레이를 사용한다면 `hyprctl monitors` 목록에 팬텀 화면이 보일 수 있다. _Setup > Monitors_를 통해 `hl.monitor({ output = "DP-2", disabled = true })`와 같은 설정으로 이를 끌 수 있다.

Intel 컴퓨터에서는 일반 Thunderbolt 케이블을 사용해 Apple 디스플레이에 연결해야 한다. Thunderbolt가 없는 다른 컴퓨터에서는 일반적으로 작동하게 하려면 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N)을 사용해야 한다.
