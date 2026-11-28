# 모니터

Omarchy는 기본적으로 2x 스케일링이 가능한 레티나급 디스플레이를 사용하고 있다고 가정한다. 멋지고 선명한 프로그래머용 폰트를 얻으려면 바로 이것이 필요하다. 고해상도 화면을 갖춘 거의 모든 최신 프리미엄 노트북이 여기에 최적화되어 있다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/)나 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)를 사용할 때 원하는 것도 바로 이것이다.

하지만 PPI가 218 이상인 디스플레이를 사용하고 있지 않다면 모니터 설정을 바꾸는 것이 좋다. 예를 들어 27" 또는 32" 4K가 있다면 상단 바의 모니터 패널에서 해당 디스플레이에 맞는 소수 스케일을 선택하거나, `~/.config/hypr/monitors.lua`를 열어 모든 모니터의 기본값을 해당 조합에 대한 권장값으로 바꿀 수 있다:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p나 1440p 디스플레이를 사용하고 있다면 아마 1x 스케일링만으로 충분할 것이고, GTK와 X11 앱도 마찬가지이므로 다음을 사용할 수 있다:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 변경 사항은 변경 후에 실행한 애플리케이션에 적용된다(그리고 GTK는 정수만 허용하므로 모니터 스케일에 가장 가까운 정수로 유지하라). 따라서 변경 후에 너무 크게 표시되는 창은 반드시 종료하라(또는 `Ctrl + Alt + Del`로 모든 창을 닫아라!).

`Super + /`로 더 크게, `Super + Alt + /`로 더 작게 하여 주요 모니터 스케일링 비율(1x, 1.25x, 1.6x, 2x, 3x, 4x)을 빠르게 단계별로 오갈 수도 있고, 상단 바의 모니터 패널에서 하나를 선택할 수도 있다. 이는 포커스가 있는 모니터만 변경하므로 노트북 화면과 외부 디스플레이가 각각 고유한 스케일을 가질 수 있다. 패널에서는 각 모니터의 해상도, 주사율, 회전도 설정한다. 선택한 내용은 해당 물리적 모니터에 대해 `~/.local/state/omarchy/monitors/settings`에 저장되므로 재부팅 후에도 유지되고, 다음에 어떤 포트나 독에 연결하든 모니터를 따라간다. 이는 `~/.config/hypr/monitors.lua`에 있는 같은 모니터에 대한 어떤 규칙보다 우선하며, Omarchy는 그 파일을 절대 편집하지 않는다. 모니터를 전적으로 그 파일에서 설정하고 싶다면 파일에 `omarchy_monitor_panel_settings = false`를 추가하라. 그러면 패널의 변경 사항은 Hyprland가 다시 로드될 때까지만 유지된다. `GDK_SCALE`은 모든 화면에 하나의 값만 사용하므로, 선택한 스케일은 가장 낮은 스케일을 가진 모니터를 기준으로 이를 설정한다. 따라서 X11 앱은 다른 화면에서 지나치게 크게 나오는 대신 더 밀도가 높은 화면에서 조금 작게 나온다.

### 텍스트를 더 크게 또는 더 작게 만들기

모니터 스케일링은 모든 것의 크기를 바꾼다. 원하는 것이 더 크거나 더 작은 _텍스트_뿐이라면 이를 위한 노브는 단 하나뿐이다:

```
omarchy display text size 14
```

이는 9에서 20 사이의 픽셀 크기를 받으며, Omarchy 셸, GTK 애플리케이션, 터미널을 함께 움직여 전체 데스크톱의 비율이 유지되도록 한다. 인자 없이 실행하면 현재 상태를 확인할 수 있고, `omarchy display text size reset`을 실행하면 기본값으로 돌아간다. Foot이 유일하게 뒤처지는 앱이다: 설정을 다시 로드할 방법이 없으므로, 실행 중인 터미널은 새 터미널을 열 때까지 이전 크기를 유지한다.

### 노트북 디스플레이 확장 및 미러링

외부 화면을 노트북에 연결하면 디스플레이가 자동으로 확장된다. 하지만 상단 바의 모니터 패널에서 _Extend_ | _Mirror_를 사용하거나, Omarchy 메뉴에서 _Trigger > Hardware_를 사용하거나, `Super + Ctrl + Alt + Delete`를 눌러 대신 미러링으로 변경할 수 있다. 외부 화면이 프로젝터이고 작업하면서 무언가를 보여주고 싶을 때 특히 유용하다.

확장 중일 때 노트북 덮개를 닫으면 내부 화면이 자동으로 꺼진다. 덮개를 열면 다시 켜진다. Omarchy 메뉴에서 _Trigger > Hardware_를 사용하거나 `Super + Ctrl + Delete`를 눌러 수동으로 제어할 수도 있다.

노트북이 전원에 연결되어 있는 동안에는 덮개를 닫아도 절대 절전 모드로 들어가지 않으므로, 외부 화면이 잠시 끊어져도 독에 연결된 노트북은 깨어 있는 상태를 유지한다. 외부 화면이 연결되어 있지 않은 상태에서 전원에 연결한 채 덮개를 닫으면 잠기기만 한다. 배터리 사용 시에는 덮개를 닫으면 평소대로 일시 중단된다.

### 여러 화면 배치하기

Hyprland는 여러 화면과도 훌륭하게 작동한다. 상단 바의 모니터 패널은 화면들이 놓인 위치 그대로 그려준다: 하나를 다른 하나의 옆면에 대고 드래그하면 그 위치로 이동하고, 배치는 각 모니터의 다른 설정과 함께 저장된다. 패널에서 다루지 않는 사항에 대해서는 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)에서 배치 방법을 더 자세히 읽어보라. Omarchy에서는 이러한 설정을 `~/.config/hypr/monitors.lua`에 `hl.monitor` 항목으로 넣는다 — 이 파일에는 모니터를 꺼진 상태로 유지하기, 패널에서 제공하지 않는 모드, 10-bit 색상, 가변 주사율에 대한 주석 처리된 예제가 함께 제공된다.

모든 모니터는 각각 1부터 10까지의 워크스페이스를 가지므로, `Super + 1`은 항상 현재 있는 모니터의 첫 번째 워크스페이스를 의미한다. 내부적으로 Hyprland는 여전히 모든 모니터에 걸쳐 워크스페이스 번호를 매긴다: 노트북 화면(또는 첫 번째 모니터)은 1–10을, 다음 모니터는 11–20을 받는 식이며, 각 모니터는 연결할 때마다 자신의 블록을 유지한다. 특정 모니터에 대한 [워크스페이스 규칙](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)이나 창 규칙을 작성할 때는 이 번호를 사용하라. 예를 들어 워크스페이스 12는 두 번째 모니터의 두 번째 워크스페이스이다. `~/.local/state/omarchy/monitors/workspaces`에는 각 모니터가 어떤 블록을 가졌는지 나열되어 있다.

방향키는 레이아웃에서 한 변을 공유하는 모니터 간에 작동한다. 모서리에서만 닿거나 사이에 간격이 있는 화면은 이웃이 아니므로, 그 사이를 이동하려면 `Ctrl + Alt + Tab`을 사용하라.

| 단축키 | 모니터 간 동작 |
| --- | --- |
| `Super + Arrow` | 해당 방향에 더 이상 창이 없을 때 그쪽 모니터로 포커스를 이동한다 |
| `Super + Shift + Arrow` | 그쪽 모니터에 있는 창과 교체한다 |
| `Super + Alt + Arrow` | 창을 그쪽 모니터에 있는 그룹으로 이동한다 |
| `Super + Shift + Ctrl + Arrow` | 창을 그쪽 모니터로, 그 모니터가 표시 중인 워크스페이스로 이동한다 |
| `Super + Shift + Alt + Arrow` | 워크스페이스를 그쪽 모니터로 이동하며, 비어 있으면 그 번호를 유지한다 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 레이아웃과 관계없이 다음 또는 이전 모니터로 포커스를 이동한다 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 현재 있는 모니터에 머문다 |

여러 화면의 위치를 잡는 데 도움이 되는 TUI를 원한다면 [Hyprmon](https://github.com/erans/hyprmon/)도 확인해 보라.

### 밝기 조절

모니터 밝기는 밝기 높이기/낮추기 전용 기능 키로 조절한다. 이 키들을 누를 때 Shift를 누른 채로 있으면 최대 또는 최소 밝기로 이동한다. 이 키들은 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조절된다.

### Apple 디스플레이

Apple 디스플레이를 사용하고 있다면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 작동한다. 이는 `asdcontrol` 명령을 통해 이루어진다.

Apple 6K XDR 디스플레이를 사용하고 있다면 `hyprctl monitors` 목록에 유령 화면이 보일 수 있다. `~/.config/hypr/monitors.lua`에 `hl.monitor({ output = "DP-2", disabled = true })`와 같은 내용을 넣어 이를 끌 수 있다.

Intel 컴퓨터에서는 일반 Thunderbolt 케이블을 사용해 Apple 디스플레이에 연결해야 한다. Thunderbolt가 없는 다른 컴퓨터에서는 일반적으로 작동하게 하려면 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N)을 사용해야 한다.
