# 모니터

Omarchy는 기본적으로 2x 가능한 레티나급 디스플레이에서 실행 중이라고 가정합니다. 멋지고 선명한 프로그래머 글꼴을 얻으려면 이것이 필요합니다. 거의 모든 새 고급 노트북이 고해상도 화면으로 최적화되어 있는 것이기도 합니다. 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/)나 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/)에서 실행하고 싶은 것이기도 합니다.

하지만 PPI가 218 이상인 디스플레이를 실행하고 있지 않다면, 모니터 설정을 변경하고 싶을 것입니다. 예를 들어 27" 또는 32" 4K가 있다면, `~/.config/hypr/monitors.lua`(Omarchy 메뉴의 _설정 > 모니터_ 사용)를 열고 해당 조합에 대한 권장 사항으로 전환해 분수 스케일링을 사용할 수 있습니다:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p 또는 1440p 디스플레이를 사용하고 있다면, 대개 1x 스케일링을 사용하고 싶을 것이므로, 다음을 사용할 수 있습니다:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE`에 대한 변경은 변경 후에 시작된 애플리케이션에 적용됩니다(GTK는 정수만 허용하므로, 모니터 스케일에서 가장 가까운 정수로 유지하세요). 따라서 변경 후에 커진 창은 반드시 종료하세요(또는 `Ctrl + Alt + Del`로 모든 창을 닫으세요!).

`Super + /`로 더 높게, `Super + Alt + /`로 더 낮게 이동하며 주요 모니터 스케일링 비율(1x, 1.25x, 1.6x, 2x, 3x, 4x)을 빠르게 단계별로 이동할 수도 있습니다. 기본 구성을 사용하고 있다면, 이러한 변경은 재부팅 후에도 유지됩니다.

### 텍스트를 더 크게 또는 더 작게 만들기

모니터 스케일링은 모든 것의 크기를 변경합니다. _텍스트_만 더 크게 또는 더 작게 만들고 싶다면, 그 목적만을 위한 노브가 하나 있습니다:

```
omarchy display text size 14
```

이는 9에서 20 사이의 픽셀 크기를 받아, Omarchy 셸, GTK 애플리케이션, 터미널을 함께 이동시켜 전체 데스크톱이 비례하게 유지합니다. 인수 없이 실행하면 현재 위치를 볼 수 있고, `omarchy display text size reset`으로 기본값으로 돌아갈 수 있습니다. Foot이 유일한 이탈자입니다. 구성을 다시 로드할 방법이 없으므로, 실행 중인 터미널은 새 터미널을 열 때까지 이전 크기를 유지합니다.

### 노트북 디스플레이 확장과 미러링

외부 화면을 노트북에 연결하면 디스플레이가 자동으로 확장됩니다. 하지만 Omarchy 메뉴의 _실행 > 하드웨어_나 `Super + Ctrl + Alt + Delete`를 사용해 대신 미러링으로 변경할 수 있습니다. 이는 특히 해당 외부 화면이 프로젝터이고 작업하면서 무언가를 보여주고 싶을 때 도움이 됩니다.

확장 중일 때 노트북 뚜껑을 닫으면 내장 화면이 자동으로 꺼집니다. 뚜껑을 열면 다시 켜집니다. Omarchy 메뉴의 _실행 > 하드웨어_나 `Super + Ctrl + Delete`를 사용해 수동으로 제어할 수도 있습니다.

### 여러 화면 정렬하기

Hyprland는 여러 화면과 훌륭하게 동작합니다. 레이아웃 방법은 [Hyprland 모니터 문서](https://wiki.hypr.land/Configuring/Basics/Monitors/)에서 더 읽어보세요. [특정 워크스페이스를 특정 모니터에 바인딩](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/)할 수도 있습니다. Omarchy에서 이러한 규칙은 `hl.monitor` 항목으로 `~/.config/hypr/monitors.lua`에 들어갑니다 — 파일에는 특정 모니터를 해상도, 위치, 회전에 고정하는 예제가 주석으로 제공됩니다.

여러 화면의 위치를 정하는 데 도움이 되는 TUI가 필요하시다면 [Hyprmon](https://github.com/erans/hyprmon/)도 확인해 보세요.

### 밝기 조절하기

모니터 밝기는 밝기 높이기/낮추기를 위한 전용 기능 키로 조절됩니다. 이러한 키를 누르면서 Shift를 누르면 최대 또는 최소 밝기로 이동합니다. 키는 포커스가 있는 디스플레이를 제어하므로, DDC/CI를 지원하는 외부 모니터도 노트북 화면과 같은 방식으로 조절됩니다.

### Apple 디스플레이

Apple 디스플레이를 사용하고 있다면, Apple 디스플레이에 포커스가 있을 때 일반 키보드 밝기 키도 자동으로 동작합니다. 이는 `asdcontrol` 명령을 통해 수행됩니다.

Apple 6K XDR 디스플레이를 사용하고 있다면, `hyprctl monitors` 목록에서 유령 화면이 보일 수 있습니다. _설정 > 모니터_를 통해 `hl.monitor({ output = "DP-2", disabled = true })` 같은 것으로 끌 수 있습니다.

Intel 컴퓨터에서는 일반 Thunderbolt 케이블을 사용해 Apple 디스플레이에 연결해야 합니다. Thunderbolt가 없는 다른 컴퓨터에서는 대개 [DP + USB-A -> USB-C 케이블](https://www.amazon.com/dp/B0BNX7MS6N)을 사용해야 동작합니다.
