# 모니터

Omarchy는 기본적으로 2x를 지원하는 레티나급 디스플레이에서 실행되고 있다고 가정합니다. 선명하고 또렷한 프로그래머용 글꼴을 쓰려면 이게 필요합니다. 고해상도 화면을 갖춘 거의 모든 최신 프리미엄 노트북에 최적화된 방식이기도 합니다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) 또는 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)에서 실행하고 싶을 방식이기도 합니다.

하지만 PPI가 218 이상인 디스플레이를 사용하고 있지 않다면 모니터 설정을 바꾸는 게 좋습니다. 예를 들어 27" 또는 32" 4K가 있다면 상단 바의 모니터 패널에서 소수 배율을 선택하거나, `~/.config/hypr/monitors.lua`를 열어 모든 모니터에 대한 기본값을 해당 조합에 권장되는 값으로 바꿀 수 있습니다:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p 또는 1440p 디스플레이를 사용한다면 아마 그냥 1x 배율을 쓰고 싶을 것이고, GTK와 X11 앱도 마찬가지일 테니 이렇게 쓸 수 있습니다:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 변경 사항은 변경 후에 시작한 애플리케이션에 적용됩니다(그리고 GTK는 정수만 허용하므로 모니터 배율에 가장 가까운 정수로 유지하세요). 그러니 변경 후에 지나치게 커진 창은 반드시 종료하세요(또는 `Ctrl + Alt + Del`로 모든 창을 닫으세요!).

`Super + /`로 더 크게, `Super + Alt + /`로 더 작게 해서 주요 모니터 배율(1x, 1.25x, 1.6x, 2x, 3x, 4x)을 빠르게 오갈 수도 있고, 상단 바의 모니터 패널에서 하나를 선택할 수도 있습니다. 이는 포커스가 있는 모니터만 바꾸므로 노트북 화면과 외부 디스플레이가 각자 자기 배율을 가질 수 있습니다. 패널에서는 각 모니터의 해상도, 주사율, 회전도 설정합니다. 선택한 내용은 해당 물리적 모니터에 대해 `~/.local/state/omarchy/monitors/settings`에 저장되므로 재부팅 후에도 유지되고, 다음에 그 모니터를 어느 포트나 독에 꽂든 따라갑니다. 이는 `~/.config/hypr/monitors.lua`에 있는 같은 모니터에 대한 어떤 규칙보다 우선하며, Omarchy는 그 파일을 절대로 편집하지 않습니다. 모니터를 전적으로 그 파일에서 설정하고 싶다면 거기에 `omarchy_monitor_panel_settings = false`를 추가하세요. 그러면 패널의 변경 사항은 Hyprland가 다시 로드될 때까지만 유지됩니다. `GDK_SCALE`는 모든 화면에 대한 하나의 값이므로, 선택한 배율은 가장 낮은 배율의 모니터를 기준으로 이를 설정합니다. 그래서 X11 앱이 다른 화면에서 지나치게 커지는 게 아니라 더 고밀도인 화면에서 조금 작게 나옵니다.

### 텍스트 크게 또는 작게 만들기

모니터 배율은 모든 것의 크기를 바꿉니다. 원하는 게 더 크거나 더 작은 _텍스트_뿐이라면 그걸 위한 손잡이는 하나뿐입니다:

```
omarchy display text size 14
```

이는 9에서 20 사이의 픽셀 크기를 받으며, Omarchy 셸, GTK 애플리케이션, 터미널을 함께 움직여 전체 데스크톱의 비율이 유지되게 합니다. 인수 없이 실행하면 현재 상태를 볼 수 있고, `omarchy display text size reset`으로 기본값으로 돌아갑니다. Foot가 유일하게 뒤처지는 앱입니다: 설정을 다시 로드할 방법이 없어서, 실행 중인 터미널은 새 터미널을 열 때까지 예전 크기를 유지합니다.

### 노트북 디스플레이 확장 및 미러링

외부 화면을 노트북에 연결하면 디스플레이가 자동으로 확장됩니다. 하지만 상단 바의 모니터 패널에서 _확장_ | _미러_를, Omarchy 메뉴에서 _Trigger > 하드웨어_를, 또는 `Super + Ctrl + Alt + Delete`를 써서 대신 미러링으로 바꿀 수 있습니다. 그 외부 화면이 프로젝터이고 작업하면서 뭔가를 보여주고 싶을 때 특히 도움이 됩니다.

확장 중일 때 노트북 덮개를 닫으면 내부 화면이 자동으로 꺼집니다. 덮개를 열면 다시 켜집니다. Omarchy 메뉴에서 _Trigger > 하드웨어_를 쓰거나 `Super + Ctrl + Delete`를 써서 수동으로 제어할 수도 있습니다.

### 여러 화면 배치하기

Hyprland는 여러 화면과 아주 잘 작동합니다. 상단 바의 모니터 패널은 화면들이 앉아 있는 위치대로 그려줍니다: 하나를 다른 하나의 옆면에 대고 드래그하면 거기로 이동하고, 그 배치는 각 모니터의 다른 설정과 함께 저장됩니다. 패널이 다루지 않는 것에 대해서는 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)에서 배치 방법을 더 읽어보세요. Omarchy에서는 이것들이 `~/.config/hypr/monitors.lua`에 `hl.monitor` 항목으로 들어갑니다 — 이 파일에는 모니터를 꺼 두는 것, 패널이 제공하지 않는 모드, 10-bit 색상, 가변 주사율에 대한 주석 처리된 예제가 기본으로 들어 있습니다.

모든 모니터는 각자 1부터 10까지의 워크스페이스를 가지므로, `Super + 1`은 항상 지금 있는 모니터의 첫 번째 워크스페이스를 뜻합니다. 뒤에서는 Hyprland가 여전히 모든 모니터에 걸쳐 워크스페이스에 번호를 매깁니다: 노트북 화면(또는 첫 번째 모니터)은 1–10을, 다음 모니터는 11–20을 받는 식이며, 각 모니터는 꽂을 때마다 자기 블록을 유지합니다. 특정 모니터에 대한 [워크스페이스 규칙](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)이나 창 규칙을 작성할 때 그 번호들을 쓰세요. 그래서 워크스페이스 12는 두 번째 모니터의 두 번째 워크스페이스입니다. `~/.local/state/omarchy/monitors/workspaces`에는 각 모니터가 어떤 블록을 가졌는지가 나열되어 있습니다.

방향키는 레이아웃에서 가장자리를 공유하는 모니터들 사이에서 작동합니다. 모서리에서만 닿거나 사이에 간격이 있는 화면은 이웃이 아니므로, 그 사이를 오가려면 `Ctrl + Alt + Tab`을 쓰세요.

| 단축키 | 모니터 간 |
| --- | --- |
| `Super + Arrow` | 그 방향으로 더 이상 창이 없을 때 그쪽 모니터로 포커스를 이동 |
| `Super + Shift + Arrow` | 그쪽 모니터에 있는 창과 교체 |
| `Super + Alt + Arrow` | 창을 그쪽 모니터에 있는 그룹으로 이동 |
| `Super + Shift + Ctrl + Arrow` | 창을 그쪽 모니터로, 그 모니터가 표시 중인 워크스페이스 위로 이동 |
| `Super + Shift + Alt + Arrow` | 워크스페이스를 그쪽 모니터로 이동하되, 비어 있으면 그 번호를 유지 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 레이아웃과 상관없이 다음 또는 이전 모니터로 포커스를 이동 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 지금 있는 모니터에 머무름 |

여러 화면의 위치를 잡는 데 도움이 되는 TUI를 원한다면 [Hyprmon](https://github.com/erans/hyprmon/)도 확인해 보세요.

### 밝기 조절하기

모니터 밝기는 밝기 높이기/낮추기 전용 기능 키로 조절합니다. 이 키들을 누르면서 Shift를 누르고 있으면 최대 또는 최소 밝기로 이동합니다. 키는 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조절됩니다.

### Apple 디스플레이

Apple 디스플레이를 사용한다면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 작동합니다. 이는 `asdcontrol` 명령을 통해 이루어집니다.

Apple 6K XDR 디스플레이를 사용한다면 `hyprctl monitors` 목록에서 유령 화면이 보일 수 있다는 점에 유의하세요. `~/.config/hypr/monitors.lua`에 `hl.monitor({ output = "DP-2", disabled = true })` 같은 것을 넣어 이를 끌 수 있습니다.

Intel 컴퓨터에서는 일반 Thunderbolt 케이블을 사용해 Apple 디스플레이에 연결해야 합니다. Thunderbolt가 없는 다른 컴퓨터에서는 보통 작동하게 하려면 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N)을 사용해야 합니다.
