# Mac이나 Windows에서 넘어오기

macOS나 Windows에서 수년을 보냈다면, 당신의 손가락은 뇌가 배웠다는 사실조차 잊은 백 가지 동작을 기억하고 있습니다. 이 장은 그 번역 계층입니다: 그 본능들이 Omarchy에서는 어디로 가는지 알려줍니다. 각 기능 자체는 다른 곳에서 깊이 다루니, 여기는 지도일 뿐입니다.

### Super가 모든 것의 중심이다

Cmd나 Windows 키를 중심으로 쌓아온 모든 근육 기억은 단 하나의 키, Super로 옮겨갑니다. PC 키보드의 Windows 키가 바로 그것이며, Omarchy의 거의 모든 단축키의 기준점입니다.

Spotlight나 Raycast, 시작 메뉴를 떠올리는 반사 동작은 `Super + Space`가 됩니다. 이 키로 Omarchy 메뉴가 열리며, 앱 실행, 설정 변경, 소프트웨어 설치, 화면 캡처 등 거의 모든 일을 할 수 있습니다. 타이핑을 시작하면 필터링됩니다. `Super + Alt + Space`는 Launchpad처럼 모든 앱을 하나의 그리드에 보여줍니다. [탐색](04-navigation.md)을 참고하세요.

### 바탕화면 아이콘은 없고, 독은 플로팅 상태일 때만 나타난다

바탕화면에 정리할 아이콘이 없고, 타일링 워크스페이스에는 독도 없습니다 — 독은 플로팅 워크스페이스에서만 나타납니다([탐색](04-navigation.md) 참고). 앱은 단축키(`Super + Return`은 터미널, `Super + Shift + Return`은 브라우저, `Super + K`는 매핑된 모든 것의 목록)나 메뉴에서 실행합니다. 항상 유지되는 유일한 UI는 [상단 바](05-the-top-bar.md)이며, 이전의 메뉴 바, 시스템 트레이, Notification Center가 하던 일을 대신합니다 — 그리고 그 위의 거의 모든 위젯은 왼쪽, 오른쪽, 가운데 클릭마다 무언가를 합니다.

### 창은 스스로 자리를 잡는다

가장 큰 사고방식의 전환: 창을 끌어다 놓거나 화면 절반에 맞추지 않습니다. 창 하나를 열면 전체 화면을 차지합니다. 두 번째 창을 열면 화면을 나눠 가집니다. 창이 겹치지 않으니, 다른 창 밑에 깔린 창을 끄집어낼 일도 없습니다.

정말로 플로팅 창이 필요하면 `Super + T`로 활성 창을 타일링에서 빼냈다가 다시 넣을 수 있습니다. 하지만 먼저 타일링에 제대로 기회를 주세요 — 이게 전체의 핵심입니다. [탐색](04-navigation.md)에서 차근차근 설명합니다.

워크스페이스는 익숙하게 느껴질 겁니다: macOS Spaces나 Windows 가상 데스크톱과 같지만, 실제로 쓰게 될 겁니다. `Super + 1/2/3/4`로 바로 이동하고 `Super + Shift + 1/2/3/4`로 활성 창을 그곳으로 보내기 때문입니다. 애니메이션 지연 없이, 그저 즉각적으로 이동합니다. 예전에 다중 모니터에 익숙했더라도, 어쩌면 더 이상 필요 없을지도 모른다는 뜻입니다.

### 복사하고 붙여넣으면 그냥 된다

Mac에서는 어디서나 Cmd + C를 썼습니다. Windows에서는 어디서나 Ctrl + C를 썼죠 — 터미널에서는 프로그램이 종료된다는 점만 빼면요. Omarchy는 `Super + C`, `Super + X`, `Super + V`를 제공하며, 터미널을 포함해 어디서나 동작합니다. 셸을 위해 따로 반사 동작을 배울 필요가 없습니다.

Windows 사용자 여러분: Win + V 클립보드 기록은 `Super + Ctrl + V`에 있으며, 텍스트뿐 아니라 이미지도 보관합니다. [통합 클립보드 및 기록](08-unified-clipboard-history.md)을 참고하세요.

### 번역표

| 찾던 기능 | Omarchy에서는 |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy 메뉴 |
| AirDrop | `Super + Ctrl + S`로 사용하는 LocalSend — [GUI](22-guis.md) 참고 |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 또는 `Print Screen` — [스크린샷 및 녹화](12-screenshots-recording.md) 참고 |
| Notification Center | `Super + Shift + Alt + ,`의 알림 기록 |
| Time Machine (시스템용) | 업데이트할 때마다 자동으로 생성되는 [시스템 스냅샷](47-system-snapshots.md) |
| App Store / 설치 프로그램 다운로드 | 메뉴의 _Install_, 또는 `omarchy pkg add` — [기타 패키지](29-other-packages.md) 참고 |
| System Settings / Control Panel | 일반 설정 파일을 편집하는 메뉴의 _Setup_ — [dotfiles](31-dotfiles.md) 참고 |
| Finder / File Explorer | `Super + Shift + F`의 Files — [GUI](22-guis.md) 참고 |
| Safari / Edge | `Super + Shift + Return`의 Google Chrome; _Setup > Defaults > Browser_에서 다른 것으로 교체 — [브라우저](23-browsers.md) 참고 |
| Preview / Photos | 사진, 동영상, 음악용 Omaview, PDF용 Document Viewer — [GUI](22-guis.md) 참고 |
| TextEdit / Notepad | `Super + Shift + N`의 Plain; _Setup > Defaults > Editor_에서 다른 것으로 교체 |

### 정말로 다른 것들도 있다

많은 설정은 클릭으로 넘기는 패널이 아니라, 직접 편집하는 텍스트 파일에 있습니다. 원시적으로 들리지만, 모든 조정을 눈으로 확인하고, 다음 기기로 복사하고, 버전 관리를 할 수 있다는 뜻이라는 걸 깨닫게 됩니다. _Setup_ 메뉴는 바로 올바른 파일로 데려다주고, 끝나면 재시작이 필요한 것을 재시작합니다.

업데이트는 _Update > Omarchy_ 명령 하나로 이루어집니다 — Omarchy 자체와 시스템의 모든 패키지를 업데이트하며, 먼저 스냅샷을 찍습니다. 앱마다 제멋대로 귀찮게 구는 업데이터가 없습니다. [업데이트](30-updates.md)를 참고하세요.

소프트웨어는 다운로드한 설치 프로그램이 아니라 패키지 매니저에서 옵니다.

그리고 창을 닫으면 앱이 실제로 종료됩니다. 창이 없는데도 프로그램이 계속 실행되는 macOS의 애매한 상태는 없습니다. `Super + W` — 또는 처음 올 때 그 손가락 기억을 가지고 왔다면 `Super + Q` — 는 사라졌다는 뜻입니다.

### Mac 하드웨어에서

Omarchy는 Intel Mac에서 잘 동작하고, Omarchy for Apple Silicon을 사용하면 M1, M2, M3 Mac에서도 잘 동작합니다. [Mac 지원](44-mac-support.md)을 참고하세요. 키보드도 친절합니다: Omarchy는 아무것도 다시 매핑하지 않고, Linux는 Command 키를 Super로 취급하므로, Super는 Cmd가 항상 있던 바로 그 자리에 있습니다. 엄지손가락은 이사를 알아차리지도 못할 겁니다.

### 2주만 써보세요

본능은 생각보다 빠르게 옮겨갑니다. [단축키](07-hotkeys.md) 장을 한 번 훑어보고, 바인딩이 떠오르지 않을 때마다 `Super + K`를 누르세요 — 모든 바인딩을 보여줍니다. 그게 실제로 외워야 할 유일한 단축키입니다.
