# Mac 또는 Windows에서 넘어오기

macOS나 Windows를 수년간 써왔다면, 당신의 손가락은 뇌가 배웠다는 사실조차 잊어버린 수백 가지를 기억하고 있다. 이 장은 번역 계층이다. 그 본능들이 Omarchy에서는 어디로 가는지 알려준다. 각 기능 자체는 다른 곳에서 깊이 다루므로, 여기는 지도일 뿐이다.

### Super가 모든 것의 중심이다

Cmd나 Windows 키를 중심으로 쌓아온 모든 근육 기억은 단 하나의 키, Super로 옮겨 간다. PC 키보드에 있는 바로 그 Windows 키이며, Omarchy의 거의 모든 단축키의 기준점이다.

Spotlight나 Raycast, 시작 메뉴를 떠올리는 반사 행동은 `Super + Space`가 된다. 그러면 앱을 실행하고, 설정을 바꾸고, 소프트웨어를 설치하고, 화면을 캡처하는 등 거의 모든 일을 하는 Omarchy 메뉴가 열린다. 입력을 시작하면 필터링된다. `Super + Alt + Space`는 Launchpad처럼 모든 앱을 하나의 격자로 보여준다. [탐색](04-navigation.md)을 보라.

### 바탕화면 아이콘이 없고, 독은 방해하지 않는다

바탕화면에 정리할 아이콘이 없고, 독은 워크스페이스에 창이 생기면 숨겨졌다가 포인터를 화면의 해당 가장자리, 옮기지 않았다면 아래쪽 가장자리로 밀 때 나타난다([탐색](04-navigation.md) 참조). 앱은 단축키(터미널은 `Super + Return`, 브라우저는 `Super + Shift + Return`, 매핑된 모든 것의 목록은 `Super + K`)나 메뉴에서 실행한다. 계속 남아 있는 UI는 [상단 바](05-the-top-bar.md) 하나뿐이며, 이전에 메뉴 바, 시스템 트레이, Notification Center가 하던 일을 대신한다. 그 위에 있는 거의 모든 위젯은 왼쪽, 오른쪽, 가운데 클릭마다 무언가를 한다.

### 창은 스스로 자리를 잡는다

가장 큰 사고방식의 전환은 이것이다. 창을 이리저리 끌어다 놓거나 화면 절반에 붙일 필요가 없다. 창을 열면 전체 화면을 차지한다. 두 번째 창을 열면 화면을 나눠 갖는다. 창이 겹치지 않으므로 다른 창 아래에 깔린 창을 끄집어낼 일도 없다.

정말로 떠 있는 창이 필요할 때는 `Super + T`로 활성 창을 타일링에서 빼내거나 다시 넣을 수 있다. 하지만 먼저 타일링에 진짜 기회를 줘보라. 그것이 이 전체의 핵심이다. [탐색](04-navigation.md)에서 안내한다.

워크스페이스는 익숙하게 느껴질 것이다. macOS Spaces나 Windows 가상 데스크톱과 같지만, 실제로 쓰게 된다는 점이 다르다. `Super + 1/2/3/4`로 곧바로 이동하고 `Super + Shift + 1/2/3/4`로 활성 창을 그곳으로 보내기 때문이다. 애니메이션 지연 없이 즉각 점프한다. 즉, 이전에 익숙했더라도 모니터가 여러 대 필요 없을지도 모른다는 뜻이다.

### 복사하고 붙여넣기가 그냥 된다

Mac에서는 어디서나 Cmd + C를 썼다. Windows에서는 어디서나 Ctrl + C를 썼다. 단, 터미널에서는 프로그램이 종료된다는 점만 빼고. Omarchy는 `Super + C`, `Super + X`, `Super + V`를 제공하며, 터미널을 포함해 어디서나 작동한다. 셸을 위해 별도의 반사 행동을 배울 필요가 없다.

Windows 사용자 여러분, Win + V 클립보드 기록은 `Super + Ctrl + V`에 있으며, 텍스트뿐 아니라 이미지도 보관한다. [통합 클립보드와 기록](08-unified-clipboard-history.md)을 보라.

### 번역 표

| 당신이 찾게 되는 것 | Omarchy에서는 |
| ------------- | ---------- |
| Spotlight / Raycast / 시작 메뉴 | `Super + Space` — Omarchy 메뉴 |
| AirDrop | LocalSend, `Super + Ctrl + S` 사용 — [GUI](22-guis.md) 참조 |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 또는 `Print Screen` — [스크린샷과 녹화](12-screenshots-recording.md) 참조 |
| Notification Center | `Super + Shift + Alt + ,`의 알림 기록 |
| Time Machine (시스템용) | 모든 업데이트 시 자동 [시스템 스냅샷](47-system-snapshots.md) |
| App Store / 설치 프로그램 다운로드 | 메뉴의 _Install_, 또는 `omarchy pkg add` — [기타 패키지](29-other-packages.md) 참조 |
| 시스템 설정 / 제어판 | 일반 설정 파일을 편집하는 메뉴의 _Setup_ — [dotfiles](31-dotfiles.md) 참조 |
| Finder / 파일 탐색기 | Files, `Super + Shift + F` — [GUI](22-guis.md) 참조 |
| Safari / Edge | `Super + Shift + Return`의 Google Chrome; _Setup > Defaults > Browser_에서 다른 것을 선택 — [브라우저](23-browsers.md) 참조 |
| Preview / 사진 | 사진, 동영상, 음악용 Omaview, PDF용 Document Viewer — [GUI](22-guis.md) 참조 |
| TextEdit / 메모장 | Plain, `Super + Shift + N`; _Setup > Defaults > Editor_에서 다른 것을 선택 |

### 어떤 것들은 정말로 다르다

많은 설정이 클릭하며 돌아다니는 패널이 아니라, 당신이 편집하는 텍스트 파일에 있다. 모든 조정을 눈으로 확인하고, 다음 컴퓨터에 복사하고, 버전 관리에 넣을 수 있다는 사실을 깨닫기 전까지는 원시적으로 들린다. _Setup_ 메뉴는 당신을 곧바로 올바른 파일로 데려가며, 작업을 마치면 재시작이 필요한 것은 무엇이든 재시작한다.

업데이트는 먼저 스냅샷을 만든 뒤 Omarchy 자체와 시스템의 모든 패키지를 업데이트하는 단 하나의 명령, _Update > Omarchy_로 이뤄진다. 앱마다 제멋대로 당신을 귀찮게 하는 업데이터는 없다. [업데이트](30-updates.md)를 보라.

소프트웨어는 다운로드한 설치 프로그램이 아니라 패키지 관리자에서 온다.

그리고 창을 닫으면 앱이 실제로 종료된다. 창은 하나도 없는데 프로그램이 계속 실행되는 macOS식 애매한 상태는 없다. `Super + W`, 또는 당신이 몸에 익혀 온 손가락 기억이 그렇다면 `Super + Q`는 사라진다는 뜻이다.

### Mac 하드웨어에서

Omarchy는 Intel Mac에서, 그리고 Omarchy for Apple Silicon을 사용하면 M1, M2, M3 Mac에서도 잘 실행된다. [Mac 지원](44-mac-support.md)을 보라. 키보드도 친절하다. Omarchy는 아무것도 다시 매핑하지 않으며, Linux는 Command 키를 Super로 취급하므로 Super가 Cmd가 늘 있던 바로 그 자리에 있다. 엄지손가락은 변화를 눈치채지 못할 것이다.

### 2주를 줘보라

본능은 생각보다 빠르게 옮겨 간다. [단축키](07-hotkeys.md) 장을 한 번 훑어보고, 바인딩이 생각나지 않을 때마다 `Super + K`를 눌러보라. 전부 보여준다. 그것이 당신이 실제로 외워야 할 유일한 단축키다.
