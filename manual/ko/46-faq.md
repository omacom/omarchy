# FAQ

### 키보드 레이아웃은 어떻게 전환하나요?

`~/.config/hypr/input.lua` 파일을 편집하고, `Left Alt + Right Alt`로 레이아웃을 전환할 수 있도록 다음을 추가하세요:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

여러 레이아웃을 구성하면 바에 현재 키보드 레이아웃이 자동으로 표시됩니다(클릭해서 전환할 수도 있습니다).

### 시계 형식을 12시간제로 어떻게 바꾸나요?

바의 시계를 오른쪽 클릭하면 12시간제를 포함한 흔히 쓰는 형식들을 돌아가며 선택할 수 있습니다. 형식을 직접 설정할 수도 있습니다:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

이렇게 하면 일요일 10:55 AM으로 표시됩니다.

### 시간대는 어떻게 바꾸나요?

Omarchy 메뉴에서 _Update > Timezone_을 실행하고 목록에서 선택하세요. 시간대는 맞는데 시계 자체가 어긋난 경우라면, _Update > Time_이 시간 동기화를 대신 재시작해줍니다.

### DNS를 바꾸거나, Wi-Fi를 공유하거나, 연결 속도를 확인하려면 어떻게 하나요?

그것들은 모두 [네트워킹](35-networking.md)에 있습니다.

### 디스크 속도는 어떻게 확인하나요?

_Trigger > Speed Test > Disk Speed Test_는 드라이브의 실시간 읽기 및 쓰기 속도를 측정합니다. 터미널에서 `omarchy disk speedtest`를 실행해도 됩니다.

### 프린터는 어떻게 추가하나요?

인쇄는 기본으로 설정되어 실행 중이며, 각 프린터는 앱 런처(`Super + Space`)의 _Print Settings_에서 직접 추가합니다.

_Add_를 선택하고 잠시 기다리면 찾습니다: USB로 연결한 프린터와 대부분의 네트워크 프린터는 자동으로 찾아줍니다. 목록에 없다면 _Network Printer > Internet Printing Protocol (ipp)_를 선택하고 그 주소를 입력하세요 — 프린터 자체의 디스플레이나 웹 페이지에서 그 주소를 확인할 수 있으며, 보통 `192.168.1.50` 같은 주소에 `ipp/print` 큐를 사용합니다. 그런 다음 _Forward_에서 드라이버를 제안하는데, 최신 프린터는 드라이버 없는 _IPP Everywhere_ 프로필이 가장 잘 맞고 오래된 프린터는 해당 모델 전용 드라이버를 원합니다.

프린터를 오른쪽 클릭하고 _Set as Default_를 선택하면 앱이 가장 먼저 사용할 프린터를 정할 수 있고, _Properties_에서는 용지 크기, 양면 인쇄와 품질을 설정합니다.

네트워크의 프린터가 추가 없이 나타나는 자동 검색은 개편 중이라 임시로 꺼져 있습니다. 그래서 위의 첫 단계가 자동이 아니라 직접 해야 하는 것입니다. PDF 파일로 인쇄하는 것은 프린터가 전혀 없어도 작동합니다.

### 스크린샷이나 화면 녹화가 저장되는 위치는 어떻게 바꾸나요?

저장된 스크린샷은 기본적으로 `~/Pictures/Screenshots`로 갑니다. 다른 디렉터리를 사용하려면 `~/.config/uwsm/env.d/` 아래 파일(`~/.config/uwsm/env.d/capture` 같은 파일)에 다음을 추가하세요:

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

`OMARCHY_SCREENRECORD_DIR`를 이용해 화면 녹화에 대해서도 같은 방식으로 할 수 있습니다.

Omasnap은 스크린샷 디렉터리를 자동으로 만듭니다. 화면 녹화 디렉터리는 직접 만든 다음, 두 환경 변경 중 어느 경우든 적용하려면 Omarchy를 재시작하세요.

### Apple Studio Display에서 스피커와 웹캠을 작동하게 하려면 어떻게 하나요?

USB C만 꽂으면 다 될 것 같지만, 안타깝게도 그렇지 않습니다. 제가 찾은 안정적으로 작동하게 하는 해결책은 [the WJESOG DisplayPort + USB-A => USB-C cable](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/)을 사용하는 것입니다. 그러면 스피커와 웹캠이 아주 잘 작동합니다.

Omarchy에는 일반 키보드 밝기 버튼을 사용하는 Apple Displays(Studio와 XDR 모두)용 내장 밝기 조절 기능이 있다는 점도 기억하세요.

### 여분의 소프트웨어를 모두 없애려면 어떻게 하나요?

Obsidian이나 LibreOffice 같은 프로그램이나 그 밖의 사전 설치된 것들을 원하지 않는다면, 아주 쉽게 제거할 수 있습니다.

_Remove > Package_를 실행하면 설치된 모든 패키지를 볼 수 있습니다. 그런 다음 tab으로 제거하고 싶은 패키지를 선택하고, return으로 선택한 모든 것의 제거를 시작할 수 있습니다.

Omarchy 메뉴의 _Remove > Web App_을 사용해 원하지 않는 사전 설치 웹 앱을 제거할 수도 있습니다.

아니면 _Remove > Preinstalls_를 실행해 사전 설치된 추가 항목들 — 웹 앱, TUI, 선택적 애플리케이션 — 을 한 번에 쓸어내세요. 그것들을 실행하던 단축키도 함께 사라지므로, `~/.config/hypr/bindings.lua`에서 직접 채워 넣을 깨끗한 바인딩 상태가 남습니다.

---

오류와 고장 난 부분은 [문제 해결 섹션](45-troubleshooting.md)을 보세요.
