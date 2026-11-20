# 모니터

Omarchy는 기본적으로 2x를 지원하는 레티나급 디스플레이를 사용하고 있다고 가정합니다. 멋지고 선명한 프로그래머용 폰트를 얻으려면 바로 이게 필요합니다. 고해상도 화면을 갖춘 거의 모든 최신 프리미엄 노트북이 최적화된 방식이기도 합니다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/)나 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)에서 돌리고 싶은 방식입니다.

하지만 PPI가 218 이상인 디스플레이를 사용하고 있지 않다면 모니터 설정을 바꿔야 합니다. 예를 들어 27"나 32" 4K가 있다면, 상단 바의 모니터 패널에서 소수 배율을 선택하거나, `~/.config/hypr/monitors.lua`를 열어 모든 모니터의 기본값을 해당 조합에 대한 권장값으로 바꿀 수 있습니다:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p나 1440p 디스플레이를 사용하고 있다면 아마 1x 배율을 쓰고 싶을 것이고, GTK와 X11 앱에도 똑같이 적용하고 싶을 것이므로, 다음을 사용할 수 있습니다:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` 변경 사항은 변경 후에 시작된 애플리케이션에 적용됩니다(GTK는 정수만 지원하므로, 모니터 배율에 가장 가까운 정수로 유지하세요). 그러니 변경 후에 너무 크게 나온 창들은 반드시 종료하세요(아니면 `Ctrl + Alt + Del`로 모든 창을 닫으세요!).

`Super + /`로 더 크게, `Super + Alt + /`로 더 작게 해서 주요 모니터 배율(1x, 1.25x, 1.6x, 2x, 3x, 4x)을 빠르게 단계별로 오갈 수도 있고, 상단 바의 모니터 패널에서 하나를 선택할 수도 있습니다. 이는 지금 포커스가 있는 모니터만 바꾸므로, 노트북 화면과 외부 디스플레이가 각자 자신의 배율을 가질 수 있습니다. 패널에서는 각 모니터의 해상도, 주사율, 회전도 설정합니다. 선택한 내용은 해당 물리적 모니터에 대해 `~/.local/state/omarchy/monitors/settings`에 저장되므로, 재부팅 후에도 유지되고 다음에 그 모니터를 어느 포트나 독에 연결하든 따라갑니다. 이는 Omarchy가 절대 편집하지 않는 `~/.config/hypr/monitors.lua`에 있는 같은 모니터에 대한 어떤 규칙보다 우선합니다. 모니터를 전적으로 그 파일에서 설정하고 싶다면, 그 파일에 `omarchy_monitor_panel_settings = false`를 추가하세요. 그러면 패널의 변경 사항은 Hyprland가 다시 불러와질 때까지만 유지됩니다. `GDK_SCALE`은 모든 화면에 대한 하나의 값이기 때문에, 선택한 배율은 배율이 가장 낮은 모니터를 기준으로 이를 설정합니다. 그래서 X11 앱이 다른 화면에서 너무 크게 나오는 대신, 더 조밀한 화면에서 조금 작게 나옵니다.

### 텍스트 키우거나 줄이기

모니터 배율은 모든 것의 크기를 바꿉니다. 원하는 것이 더 크거나 더 작은 _텍스트_뿐이라면, 그걸 위한 손잡이는 하나뿐입니다:

```
omarchy display text size 14
```

이는 9에서 20 사이의 픽셀 크기를 받으며, Omarchy 셸, GTK 애플리케이션, 터미널을 함께 움직여서 전체 데스크톱의 비율이 유지되게 합니다. 인수 없이 실행하면 현재 상태를 볼 수 있고, 기본값으로 돌아가려면 `omarchy display text size reset`을 실행하세요. Foot 하나가 뒤처진 예외입니다: 설정을 다시 불러올 방법이 없어서, 실행 중인 터미널은 새 터미널을 열 때까지 이전 크기를 유지합니다.

### 노트북 디스플레이 확장 및 미러링

노트북에 외부 화면을 연결하면 디스플레이가 자동으로 확장됩니다. 하지만 Omarchy 메뉴에서 _Trigger > Hardware_를 사용하거나 `Super + Ctrl + Alt + Delete`를 눌러 대신 미러링으로 바꿀 수 있습니다. 그 외부 화면이 프로젝터이고, 작업하면서 무언가를 보여주고 싶을 때 특히 유용합니다.

확장 중일 때 노트북 덮개를 닫으면 내부 화면이 자동으로 꺼집니다. 덮개를 열면 다시 켜집니다. Omarchy 메뉴에서 _Trigger > Hardware_를 사용하거나 `Super + Ctrl + Delete`를 눌러 수동으로 제어할 수도 있습니다.

### 여러 화면 배치하기

Hyprland는 여러 화면에서 훌륭하게 작동합니다. 상단 바의 모니터 패널은 화면들이 놓인 위치 그대로 그려줍니다: 하나를 다른 하나의 옆면에 끌어다 놓으면 그 위치로 이동하고, 그 배치는 각 모니터의 다른 설정과 함께 저장됩니다. 패널이 다루지 않는 부분에 대해서는 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)에서 배치 방법을 더 읽어보세요. Omarchy에서는 이런 설정이 `~/.config/hypr/monitors.lua`에 `hl.monitor` 항목으로 들어갑니다 — 이 파일에는 모니터를 꺼 두는 방법, 패널이 제공하지 않는 모드, 10-bit 색상, 가변 주사율에 대한 주석 처리된 예제가 기본으로 들어 있습니다.

모든 모니터는 각자 1부터 10까지의 워크스페이스를 가집니다. 그래서 `Super + 1`은 항상 지금 있는 모니터의 첫 번째 워크스페이스를 의미합니다. 뒤에서는 Hyprland가 여전히 모든 모니터에 걸쳐 워크스페이스 번호를 매깁니다: 노트북 화면(또는 첫 번째 모니터)은 1–10, 다음 모니터는 11–20을 받는 식이며, 각 모니터는 연결할 때마다 자신의 블록을 유지합니다. 특정 모니터에 대한 [워크스페이스 규칙](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)이나 창 규칙을 작성할 때는 이 번호를 사용하세요. 예를 들어 워크스페이스 12는 두 번째 모니터의 두 번째 워크스페이스입니다. `~/.local/state/omarchy/monitors/workspaces`에는 각 모니터가 어떤 블록을 가졌는지 나와 있습니다.

화살표 키는 배치에서 한 변을 공유하는 모니터 사이에서는 작동합니다. 모서리에서만 닿아 있거나 사이에 간격이 있는 화면은 이웃이 아니므로, 그 사이를 이동하려면 `Ctrl + Alt + Tab`을 사용하세요.

| 단축키 | 모니터 간 이동 |
| --- | --- |
| `Super + Arrow` | 그 방향에 더 이상 창이 없을 때 그쪽 모니터로 포커스를 이동합니다 |
| `Super + Shift + Arrow` | 그쪽 모니터에 있는 창과 교체합니다 |
| `Super + Alt + Arrow` | 창을 그쪽 모니터에 있는 그룹으로 이동합니다 |
| `Super + Shift + Ctrl + Arrow` | 창을 그쪽 모니터로, 그 모니터가 표시 중인 워크스페이스로 이동합니다 |
| `Super + Shift + Alt + Arrow` | 워크스페이스를 그쪽 모니터로 이동합니다. 번호가 비어 있으면 그 번호를 유지합니다 |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | 배치와 관계없이 다음 또는 이전 모니터로 포커스를 이동합니다 |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 지금 있는 모니터에 머무릅니다 |

여러 화면의 위치를 잡는 데 도움이 되는 TUI를 원한다면 [Hyprmon](https://github.com/erans/hyprmon/)도 확인해 보세요.

### 밝기 제어하기

모니터 밝기는 밝기 올리기/내리기 전용 기능 키로 제어합니다. 이 키들을 누를 때 Shift를 누르고 있으면 최대 또는 최소 밝기로 이동합니다. 이 키들은 지금 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조정됩니다.

### Apple 디스플레이

Apple 디스플레이를 사용하고 있다면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 작동합니다. 이는 `asdcontrol` 명령을 통해 이뤄집니다.

참고로 Apple 6K XDR 디스플레이를 사용하고 있다면, `hyprctl monitors` 목록에 유령 화면이 보일 수 있습니다. `~/.config/hypr/monitors.lua`에 `hl.monitor({ output = "DP-2", disabled = true })` 같은 것을 넣어서 끌 수 있습니다.

Intel 기기에서는 일반 Thunderbolt 케이블로 Apple 디스플레이에 연결해야 합니다. Thunderbolt가 없는 다른 기기에서는 보통 작동하게 하려면 [DP + USB-A -> USB-C 케이블](https://www.amazon.com/dp/B0BNX7MS6N)을 사용해야 합니다.
