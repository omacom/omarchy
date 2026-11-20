# Mac이나 Windows에서 넘어오는 경우

macOS나 Windows에서 몇 년을 보냈다면, 당신의 손가락은 뇌가 배웠다는 사실조차 잊은 백 가지 것들을 알고 있다. 이 장은 그 번역 계층이다: Omarchy에서 그 본능들이 어디로 가는지. 기능 자체는 다른 곳에서 깊이 다루니 — 여기는 지도일 뿐이다.

### Super가 모든 것의 중심이다

Cmd나 Windows 키 주변에 쌓은 모든 근육 기억은 하나의 키로 옮겨간다: Super. 그게 PC 키보드의 Windows 키이며, Omarchy의 거의 모든 단축키의 닻이다.

Spotlight나 Raycast나 시작 메뉴를 찾는 반사신경은 `Super + Space`가 된다. 그러면 앱을 실행하고, 설정을 바꾸고, 소프트웨어를 설치하고, 화면을 캡처하는 — 거의 모든 것을 하는 Omarchy 메뉴가 열린다. 입력하기 시작하면 필터링된다. `Super + Alt + Space`는 Launchpad가 그러듯 모든 앱을 하나의 격자에 보여준다. [내비게이션](04-navigation.md)을 보라.

### 데스크톱 아이콘은 없고, 도크는 띄울 때만 나타난다

데스크톱에 배열할 아이콘이 없고, 타일링 워크스페이스에는 도크도 없다 — 도크는 플로팅 워크스페이스에서만 나타난다([내비게이션](04-navigation.md) 참조). 앱은 단축키(`Super + Return`은 터미널, `Super + Shift + Return`은 브라우저, `Super + K`는 매핑된 모든 것의 목록)나 메뉴에서 시작한다. 유일하게 항상 있는 UI는 [상단 바](05-the-top-bar.md)인데, 이전에 메뉴 바, 시스템 트레이, 알림 센터가 해주던 일을 대신한다 — 그리고 그 위의 거의 모든 위젯은 왼쪽, 오른쪽, 가운데 클릭마다 뭔가를 한다.

### 창은 스스로 자리를 잡는다

가장 큰 사고방식의 전환: 창을 끌어다 놓거나 화면 절반에 붙이지 않는다. 창을 열면 화면 전체를 차지한다. 두 번째를 열면 화면을 나눈다. 창이 겹치지 않으니 다른 창 밑에서 창을 끄집어낼 일도 결코 없다.

정말로 플로팅 창이 필요할 때는 `Super + T`로 활성 창을 타일링에서 꺼냈다가(다시 넣었다가) 한다. 하지만 먼저 타일링에 진짜 기회를 줘라 — 그게 전체의 핵심이다. [내비게이션](04-navigation.md)이 안내한다.

워크스페이스는 익숙하게 느껴질 것이다: macOS Spaces나 Windows 가상 데스크톱과 같은데, 단 실제로 쓰게 된다는 점이 다르다. `Super + 1/2/3/4`로 곧장 하나로 점프하고 `Super + Shift + 1/2/3/4`로 활성 창을 거기로 보내기 때문이다. 애니메이션 지연 없이, 그냥 즉각적인 점프다. 예전에 여러 모니터에 익숙했더라도, 어쩌면 더는 필요 없을지도 모른다는 뜻이다.

### 복사하고 붙여넣기는 그냥 된다

Mac에서는 어디서나 Cmd + C였다. Windows에서는 어디서나 Ctrl + C였다 — 터미널만 빼고, 거기서는 프로그램을 죽인다. Omarchy는 `Super + C`, `Super + X`, `Super + V`를 주고, 터미널을 포함해 어디서나 된다. 셸용으로 따로 익힐 반사신경은 없다.

Windows 쓰던 사람들: Win + V 클립보드 기록은 `Super + Ctrl + V`에 있고, 텍스트뿐 아니라 이미지도 담는다. [통합 클립보드 및 기록](08-unified-clipboard-history.md)을 보라.

### 번역 표

| 당신이 찾던 것 | Omarchy에서는 |
| ------------- | ---------- |
| Spotlight / Raycast / 시작 메뉴 | `Super + Space` — Omarchy 메뉴 |
| AirDrop | LocalSend, `Super + Ctrl + S`로 — [GUI](22-guis.md)를 보라 |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` 또는 `Print Screen` — [스크린샷과 녹화](12-screenshots-recording.md)를 보라 |
| 알림 센터 | `Super + Shift + Alt + ,`의 알림 기록 |
| Time Machine (시스템용) | 업데이트할 때마다 자동 [시스템 스냅샷](47-system-snapshots.md) |
| App Store / 설치 파일 다운로드 | 메뉴의 _Install_, 또는 `omarchy pkg add` — [기타 패키지](29-other-packages.md)를 보라 |
| 시스템 설정 / 제어판 | 메뉴의 _Setup_, 일반 설정 파일을 편집한다 — [도트파일](31-dotfiles.md)을 보라 |
| Finder / File Explorer | Files, `Super + Shift + F`로 — [GUI](22-guis.md)를 보라 |
| Safari / Edge | Google Chrome, `Super + Shift + Return`으로; 다른 것은 _Setup > Defaults > Browser_에서 골라라 — [브라우저](23-browsers.md)를 보라 |
| Preview / Photos | 사진, 동영상, 음악은 Omaview, PDF는 Document Viewer — [GUI](22-guis.md)를 보라 |
| TextEdit / Notepad | Plain, `Super + Shift + N`으로; 다른 것은 _Setup > Defaults > Editor_에서 골라라 |

### 어떤 것들은 정말로 다르다

많은 설정은 클릭해 들어가는 패널이 아니라, 당신이 편집하는 텍스트 파일에 있다. 모든 조정 사항을 볼 수 있고, 다음 기기로 복사할 수 있고, 버전 관리에 넣을 수 있다는 걸 깨닫기 전까지는 원시적으로 들린다. _Setup_ 메뉴는 당신을 곧장 올바른 파일로 데려가고, 끝나면 재시작이 필요한 것은 무엇이든 재시작한다.

업데이트는 하나의 명령 — _Update > Omarchy_ — 으로 오는데, 먼저 스냅샷을 찍고 Omarchy 자체와 시스템의 모든 패키지를 업데이트한다. 제멋대로 잔소리하는 앱별 업데이터는 없다. [업데이트](30-updates.md)를 보라.

소프트웨어는 다운로드한 설치 파일이 아니라 패키지 관리자에서 온다.

그리고 창을 닫으면 앱이 실제로 종료된다. 창은 없는데 프로그램이 계속 도는 macOS식 중간 상태는 없다. `Super + W` — 또는 당신이 가져온 손가락 기억이 그렇다면 `Super + Q` — 는 사라졌다는 뜻이다.

### Mac 하드웨어에서

Omarchy는 Intel Mac에서 잘 돌아간다 — [Mac 지원](44-mac-support.md)을 보라. 그리고 키보드가 친절하다: Omarchy는 아무것도 다시 매핑하지 않고, Linux는 Command 키를 Super로 취급하므로, Super는 Cmd가 늘 있던 바로 그 자리에 있다. 엄지손가락은 이동을 눈치채지 못할 것이다.

### 2주만 줘라

본능은 생각보다 빨리 옮겨온다. [단축키](07-hotkeys.md) 장을 한 번 훑어보고, 바인딩이 떠오르지 않을 때마다 `Super + K`를 눌러라 — 전부 보여준다. 그게 실제로 외워야 할 유일한 단축키다.
