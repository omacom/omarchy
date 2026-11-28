# Mac 또는 Windows에서 넘어오기

macOS나 Windows를 수년간 써왔다면, 스스로 배운 줄도 몰랐던 것들을 손가락은 백 가지는 기억하고 있습니다. 이 장은 그 번역 레이어입니다: 그 본능들이 Omarchy에서는 어디로 가는지 알려줍니다. 각 기능 자체는 다른 곳에서 깊이 다루므로, 여기서는 지도만 보여줍니다.

### Super가 모든 것의 중심이다

Cmd나 Windows 키를 중심으로 쌓아온 모든 근육 기억은 단 하나의 키, Super로 옮겨갑니다. PC 키보드의 Windows 키이며, Omarchy의 거의 모든 단축키의 기준점입니다.

Spotlight나 Raycast, 시작 메뉴를 찾던 반사 신경은 `Super + Space`가 됩니다. Omarchy 메뉴가 열리며, 앱 실행, 설정 변경, 소프트웨어 설치, 화면 캡처 등 거의 모든 것을 할 수 있습니다. 입력하기 시작하면 필터링됩니다. `Super + Alt + Space`는 Launchpad처럼 모든 앱을 하나의 격자에 보여줍니다. [탐색](04-navigation.md)을 참조하세요.

### 데스크톱 아이콘은 없고, 독은 방해되지 않게 물러나 있다

데스크톱에 배열할 아이콘은 없으며, 독은 워크스페이스에 창이 생기면 숨었다가 포인터를 화면의 해당 가장자리로 밀 때만 나타납니다. 옮기지 않았다면 오른쪽 가장자리입니다([탐색](04-navigation.md) 참조). 앱은 단축키(`Super + Return`은 터미널, `Super + Shift + Return`은 브라우저, `Super + K`는 매핑된 모든 것의 목록)나 메뉴에서 실행합니다. 항상 남아 있는 UI는 단 하나, [상단 바](05-the-top-bar.md)뿐입니다. 이전에 메뉴 바, 시스템 트레이, Notification Center가 하던 일을 모두 맡으며, 그 위의 거의 모든 위젯은 왼쪽 클릭, 오른쪽 클릭, 가운데 클릭마다 무언가를 합니다.

### 창은 알아서 자리를 잡는다

가장 큰 사고방식의 전환입니다: 창을 이리저리 끌거나 화면 절반에 붙이지 않습니다. 창 하나를 열면 화면 전체를 차지합니다. 두 번째를 열면 둘이 화면을 나눕니다. 창이 겹치지 않으니 다른 창 밑에서 창을 끄집어낼 일도 없습니다.

정말로 떠 있는 창이 필요할 때는 `Super + T`로 활성 창을 타일링에서 빼내거나 다시 넣을 수 있습니다. 하지만 먼저 타일링에 제대로 기회를 주세요 — 전체의 핵심이 바로 그것입니다. [탐색](04-navigation.md)에서 차근차근 안내합니다.

워크스페이스는 익숙하게 느껴질 것입니다: macOS의 Spaces나 Windows 가상 데스크톱과 같습니다. 다만 실제로 쓰게 될 것입니다. `Super + 1/2/3/4`로 곧바로 이동하고 `Super + Shift + 1/2/3/4`로 활성 창을 그곳으로 보내기 때문입니다. 애니메이션 지연 없이, 그냥 즉시 점프합니다. 예전에 여러 모니터를 쓰던 사람이라면, 어쩌면 이제 그럴 필요조차 없을 것입니다.

### 복사하고 붙여넣으면 그냥 된다

Mac에서는 어디서나 Cmd + C를 썼습니다. Windows에서는 어디서나 Ctrl + C를 썼습니다 — 터미널만 빼고요, 거기서는 프로그램이 죽습니다. Omarchy에서는 `Super + C`, `Super + X`, `Super + V`를 주며, 터미널을 포함해 어디서나 작동합니다. 셸용 반사 신경을 따로 익힐 필요가 없습니다.

Windows 사용자 여러분: Win + V로 보던 클립보드 히스토리는 `Super + Ctrl + V`에 살고 있으며, 텍스트뿐 아니라 이미지도 담습니다. [통합 클립보드와 히스토리](08-unified-clipboard-history.md)를 참조하세요.

### 번역 표

| 찾으시던 것 | Omarchy에서는 |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy 메뉴 |
| AirDrop | LocalSend, `Super + Ctrl + S` 사용 — [GUI](22-guis.md) 참조 |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 또는 `Print Screen` — [스크린샷과 녹화](12-screenshots-recording.md) 참조 |
| Notification Center | `Super + Shift + Alt + ,`의 알림 히스토리 |
| Time Machine (시스템용) | 업데이트할 때마다 자동 [시스템 스냅샷](47-system-snapshots.md) |
| App Store / 설치 파일 다운로드 | 메뉴의 _Install_, 또는 `omarchy pkg add` — [기타 패키지](29-other-packages.md) 참조 |
| System Settings / Control Panel | 메뉴의 _Setup_, 일반 설정 파일을 편집함 — [dotfiles](31-dotfiles.md) 참조 |
| Finder / File Explorer | Files, `Super + Shift + F` — [GUI](22-guis.md) 참조 |
| Safari / Edge | `Super + Shift + Return`의 Google Chrome; 다른 브라우저는 _Setup > Defaults > Browser_에서 선택 — [브라우저](23-browsers.md) 참조 |
| Preview / Photos | 사진, 동영상, 음악은 Omaview, PDF는 Document Viewer — [GUI](22-guis.md) 참조 |
| TextEdit / Notepad | Plain, `Super + Shift + N`; 다른 편집기는 _Setup > Defaults > Editor_에서 선택 |

### 어떤 것들은 정말로 다르다

많은 설정은 클릭으로 오가는 패널이 아니라, 직접 편집하는 텍스트 파일에 있습니다. 원시적으로 들리지만, 모든 조정을 눈으로 볼 수 있고, 다음 컴퓨터로 복사할 수 있으며, 버전 관리에 넣을 수 있다는 뜻임을 깨닫는 순간 생각이 바뀝니다. _Setup_ 메뉴는 곧바로 알맞은 파일로 데려가며, 다 끝나면 재시작이 필요한 것은 알아서 재시작합니다.

업데이트는 하나의 명령 — _Update > Omarchy_ — 으로 이뤄집니다. 먼저 스냅샷을 찍은 뒤 Omarchy 자체와 시스템의 모든 패키지를 업데이트합니다. 앱마다 따로 업데이터가 제멋대로 잔소리하는 일은 없습니다. [업데이트](30-updates.md)를 참조하세요.

소프트웨어는 다운로드한 설치 파일이 아니라 패키지 매니저를 통해 옵니다.

그리고 창을 닫으면 앱이 실제로 종료됩니다. 창이 하나도 없는데도 프로그램이 계속 실행되는 macOS식 중간 상태 같은 건 없습니다. `Super + W` — 또는 갖고 오신 손가락 기억이 그거라면 `Super + Q` — 는 말 그대로 사라진다는 뜻입니다.

### Mac 하드웨어에서

Omarchy는 Intel Mac에서 잘 돌아가고, M1, M2, M3 Mac에서는 Omarchy for Apple Silicon으로 잘 돌아갑니다. [Mac 지원](44-mac-support.md)을 참조하세요. 키보드도 친절합니다: Omarchy는 아무것도 다시 매핑하지 않으며, Linux는 Command 키를 Super로 취급합니다. 그래서 Super는 Cmd가 늘 있던 바로 그 자리에 있습니다. 엄지손가락은 이사를 알아채지도 못할 것입니다.

### 2주만 써보세요

본능은 생각보다 빠르게 옮겨옵니다. [단축키](07-hotkeys.md) 장을 한 번 훑어보고, 바인딩이 떠오르지 않을 때마다 `Super + K`를 누르세요 — 전부 보여줍니다. 사실 외워야 할 단축키는 그것 하나뿐입니다.
