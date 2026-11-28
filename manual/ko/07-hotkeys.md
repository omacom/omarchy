# 단축키

모든 주요 키보드 바인딩은 `Super + K`로 볼 수 있다 (Tmux 바인딩은 `Super + Alt + K`, Herdr 바인딩은 `Super + Ctrl + K`).

## 단축키가 배치되는 방식

모든 단축키는 수정자 키가 정하는 평면 위에 자리 잡고, 각 평면마다 한 가지 역할이 있다. 덕분에 단축키가 서로 뒤섞이지 않고, 보통 어떤 단축키가 어디에 있는지도 짐작할 수 있다.

| 평면 | 그곳에 있는 것 | 예시 |
| --- | --- | --- |
| `Super + key` | 시스템: 창, 작업 공간, 레이아웃, 핵심 메뉴 | `Super + Space` Omarchy 메뉴, `Super + W` 창 닫기, `Super + F` 전체 화면 |
| `Super + Shift + key` | 앱 | `Super + Shift + B` 브라우저, `Super + Shift + E` 이메일, `Super + Shift + N` 편집기 |
| `Super + Ctrl + key` | 패널과 시스템 메뉴 | `Super + Ctrl + A` 오디오, `Super + Ctrl + N` 네트워크, `Super + Ctrl + C` 캡처 메뉴 |
| `Super + Ctrl + Alt + key` | 빠른 동작과 알림 | `Super + Ctrl + Alt + T` 시간 표시, `Super + Ctrl + Alt + B` 배터리, `Super + Ctrl + Alt + C` 스크린샷 |

단축키에 `Alt`를 더하면 같은 것의 변형이 되지, 전혀 상관없는 무언가가 되지는 않는다:

- `Super + Shift + B`는 브라우저를 연다; `Super + Shift + Alt + B`는 프라이빗 창을 연다
- `Super + Shift + E`는 이메일을 연다; `Super + Shift + Alt + E`는 새 이메일을 시작한다
- `Super + F`는 전체 화면으로 전환한다; `Super + Alt + F`는 전체 너비로 전환한다
- `Super + Ctrl + C`는 캡처 메뉴를 연다; `Super + Ctrl + Alt + C`는 메뉴를 건너뛰고 스크린샷을 찍는다

단축키를 추가할 때:

1. 무엇을 하는지 보고 평면을 고른 다음, 키를 골라라.
2. 자리를 만들려고 기존 단축키를 옮기지 마라. 맞는 평면에서 빈 키를 찾아라.
3. `Alt`는 그것이 없는 단축키의 변형에만 써라.

몇몇 단축키는 편리해서 이 규칙을 어긴다. 화살표나 `Tab`과 함께 쓰는 `Shift`는 앱을 여는 대신 이동하거나 방향을 뒤집고, `Print`, 미디어 키, `Alt + Tab`, `Ctrl + Alt + Del`은 다른 모든 곳에서와 같은 방식으로 작동한다. 이는 예외일 뿐, 따라 할 패턴이 아니다.

기본값이 마음에 들지 않으면 (예를 들어 Windows처럼 스크린샷에 `Super + Shift + S`를 쓰고 싶다면), `~/.config/hypr/bindings.lua`에서 다시 바인딩하라.

## 탐색

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy 메뉴 (앱과 그 밖의 모든 것)    |
| `Super + Alt + Space` | 앱 그리드 |
| `Super + Escape` | 시스템 메뉴 (절전, 재시작 등)  |
| `Super + Ctrl + L` | 컴퓨터 잠그기 |
| `Super + W` or `Super + Q` | 창 닫기             |
| `Ctrl + Alt + Del` | 모든 창 닫기 |
| `Super + K` | 모든 단축키 표시 |
| `Super + Alt + K` | tmux 단축키 표시 |
| `Super + Ctrl + K` | herdr 단축키 표시 |
| `Super + M` | 창을 dock으로 최소화 |
| `Super + T`               | 창을 타일링/플로팅 사이에서 전환             |
| `Super + J` | 창 위치 전환 (가로/세로) |
| `Super + O`               | 창을 sticky'n'floating으로 띄우기 전환 |
| `Super + L`               | dwindle, scrolling, floating 레이아웃 순환 |
| `Super + Alt + L`         | 레이아웃을 역순으로 순환 |
| `Super + P`               | pseudo 창 스타일 전환 (natural 대 stretch) |
| `Super + F`                 | 전체 화면으로 전환              |
| `Super + Alt + F`                 | 전체 너비로 전환              |
| `Super + Ctrl + F`                 | 창 안에서 전체 화면으로 전환              |
| `Super + 1…9/0`         | 포커스된 모니터에서 특정 작업 공간으로 이동 (0은 10) |
| `Super + Tab` | 포커스된 모니터에서 다음 작업 공간으로 이동 |
| `Super + Shift + Tab` | 포커스된 모니터에서 이전 작업 공간으로 이동 |
| `Super + Ctrl + Tab` | 포커스된 모니터에서 이전에 있던 작업 공간으로 이동 |
| `Super + Shift + 1…9/0` | 포커스된 모니터의 작업 공간으로 창 이동 |
| `Super + Shift + Alt + 1…9/0` | 따라가지 않고 포커스된 모니터의 작업 공간으로 창 이동 |
| `Super + S` | 전체 scratchpad 전환 |
| `Super + Alt + S` | 창을 전체 scratchpad로 이동 |
| `Super + the key above Tab` (미국식 배열에서는 grave) | Quake 콘솔 전환 |
| `Super + Shift + the key above Tab` (미국식 배열에서는 grave) | 창을 Quake 콘솔로 이동 |
| `Super + Shift + Ctrl + Arrows` | 그 방향에 있는 모니터로 창 이동 |
| `Super + Shift + Alt + Arrows` | 그 방향에 있는 모니터로 작업 공간 이동 |
| `Super + Arrow`  | 화살표 방향에 있는 창으로 포커스 이동, 화면 가장자리에서는 그쪽 모니터로 넘어감 |
| `Super + Shift + Arrow`  | 화살표 방향에 있는 창과 자리 바꾸기, 그쪽 모니터에 있는 창도 포함 |
| `Super + Minus` | 창을 왼쪽으로 확장 |
| `Super + Equal` | 창을 왼쪽으로 축소 |
| `Super + Shift + Minus` | 창을 위쪽으로 축소 |
| `Super + Shift + Equal` | 창을 아래쪽으로 확장 |
| `Super + Alt + Minus/Equal` | 더 작은 단계로 같은 크기 조정 |
| `Super + Ctrl + Minus/Equal` | 더 큰 단계로 같은 크기 조정 |
| `Super + Alt + Home` | 창 너비 저장 |
| `Super + Home` | 저장한 창 너비 복원 |
| `Super + Left Mouse` | 창을 드래그해 이동 |
| `Super + Right Mouse` | 창 크기 조정 |
| `Super + Scroll Wheel` | 포커스된 모니터에서 작업 공간을 스크롤해 이동 |
| `Super + G`               | 창 그룹화 전환      |
| `Super + Alt + G`               | 창을 그룹화에서 빼기      |
| `Super + Alt + Tab`               | 그룹화 안에서 창 순환      |
| `Super + Alt + Shift + Tab`               | 그룹화 안에서 창을 역순으로 순환      |
| `Super + Alt + Scroll Wheel` | 그룹화 안에서 창 순환 |
| `Super + Alt + 1/2/3/4/5`               | 그룹화 안에서 특정 창으로 이동      |
| `Super + Alt + Arrow`  | 화살표 방향으로 창을 그룹화에 넣기, 그쪽 모니터에 있는 창도 포함 |
| `Super + Ctrl + Left/Right`  | 타일링 그룹 안에서 창 사이 이동 |
| `Super + Ctrl + Z` | 화면 확대 (반복하면 더 확대) |
| `Super + Ctrl + Alt + Z` | 화면을 완전히 축소 |
| `Super + /` | 모니터 배율 옵션을 앞으로 단계별 이동 |
| `Super + Alt + /` | 모니터 배율 옵션을 뒤로 단계별 이동 |
| `Alt + Tab` | 활성 작업 공간의 창을 앞으로 순환 |
| `Alt + Shift + Tab` | 활성 작업 공간의 창을 뒤로 순환 |
| `Ctrl + Alt + Tab`| 모니터 사이에서 포커스를 앞으로 순환 |
| `Ctrl + Alt + Shift + Tab`| 모니터 사이에서 포커스를 뒤로 순환 |
| `Super + I` | 입력 언어 전환 (레이아웃이나 입력 방식이 두 개 이상일 때) |
| `Super + Shift + I` | 입력 언어를 반대로 전환 |

터치패드에서는 세 손가락과 네 손가락 스와이프로 작업 공간을 전환하고, 창을 이동하고, 메뉴와 Quake 콘솔을 연다; 제스처는 [키보드, 마우스, 트랙패드](34-keyboard-mouse-trackpad.md)를 참고하라.

크기 조정은 0 오른쪽에 있는 두 키를 사용한다, 키보드에 무엇이 인쇄되어 있든: 미국 키보드에서는 `-`와 `=`, 덴마크어와 스웨덴어에서는 `+`와 `´`, 노르웨이어에서는 `+`와 `\\`, 독일어에서는 `ß`와 `´`, 스페인어에서는 `'`와 `¡`, 일본어 (JIS)에서는 `-`와 `^`이다. `Super + K`는 키보드에 인쇄된 대로 표시한다. JIS에서는 `Super + ^`가 `Super + Equal`이고, `Super + Shift + -` (`=`를 입력함)는 `Super + Shift + Minus`이다. 모니터 배율과 비밀번호 관리자는 `/`를 사용한다; `/`를 Shift와 함께만 입력할 수 있는 배열에서는, 대부분의 유럽식 배열이 그렇듯, 대신 오른쪽 Shift 왼쪽에 있는 키를 사용한다 (덴마크어와 독일어에서는 `-`).

## 시스템 제어

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | 오디오 패널    |
| `Super + Ctrl + B`           | Bluetooth 패널    |
| `Super + Ctrl + N`           | Wifi/네트워크 패널    |
| `Super + Ctrl + D`           | 디스플레이 패널    |
| `Super + Ctrl + P`           | 전원 패널    |
| `Super + Ctrl + X`           | Agents 패널    |
| `Super + Ctrl + Alt + D`           | 캘린더 패널    |
| `Super + Ctrl + Alt + E`           | 세계 시계 패널    |
| `Super + Ctrl + 1-9`           | 위치별로 바 패널 전환    |
| `Super + Ctrl + S` | 공유 메뉴 (LocalSend를 통해) |
| `Super + Ctrl + C` | 캡처 제어 (스크린샷/-녹화/피커) |
| `Super + Ctrl + O` | 메뉴 전환 |
| `Super + Ctrl + H` | 하드웨어 메뉴 |
| `Super + Ctrl + E` | 이모지 피커 |
| `Super + Ctrl + .` | 미디어 트랜스코딩 |
| `Super + Shift + Ctrl + A` | 기본 agent 시작 |
| `Power` key | 시스템 메뉴 |
| `Super + Shift + Copilot` key | Omarchy 메뉴 |

## 조정

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 화면 밝기 최대 |
| `Shift + Brightness Down` | 화면 밝기 최소 |
| `Alt + Brightness Up/Down` | 1% 단위 정밀 밝기 변경 |
| `Alt + Volume Up/Down` | 1% 단위 정밀 음량 변경 |
| `Keyboard Brightness Up/Down` | 키보드 백라이트를 더 밝게/어둡게 |
| `Keyboard Backlight` | 키보드 백라이트 단계 순환 |
| `Ctrl + Brightness Up/Down` | 자체 키가 없는 키보드에서 키보드 백라이트를 더 밝게/어둡게 |
| `Mic Mute` | 마이크 음소거 |
| `Shift + Mute` | 오디오 출력 전환 |
| `Touchpad Toggle` | 터치패드 켜기 또는 끄기 |
| `Display` key | 작업 공간 레이아웃 순환 |
| `Alt + Play` | 다음 트랙 |
| `Alt + Shift + Play` | 이전 트랙 |

## 앱 실행

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Return`           | 터미널    |
| `Super + Alt + Return` | Tmux 터미널 |
| `Super + Ctrl + Return` | Herdr (agent 관리자) |
| `Super + Shift + Return` or `Super + Shift + B`  | 브라우저    |
| `Super + Shift + Alt + B`           | 브라우저 (프라이빗/시크릿)    |
| `Super + Shift + F`           | 파일 관리자    |
| `Super + Shift + Alt + F`           | 터미널의 cwd에서 파일 관리자    |
| `Super + Shift + M`           | 음악 (Spotify)    |
| `Super + Shift + Alt + M`           | 음악 (cliamp)    |
| `Super + Shift + /`           | 비밀번호 관리자 (1password)    |
| `Super + Shift + Q` or `Calculator` key  | 계산기 (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, 설치한 뒤)    |
| `Super + Shift + T`           | 활동 (btop)    |
| `Super + Shift + N`           | 편집기 (Plain, 또는 선택한 기본값)  |
| `Super + Shift + C`           | 캘린더 ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | 이메일 ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | 새 이메일 ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | 메신저 (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | 메신저 (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | 메신저 (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | 글쓰기 (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (새 게시물) |
| `Super + Shift + Y`           | YouTube |

바인딩 변경/추가는 `~/.config/hypr/bindings.lua`에서 한다.

## 범용 클립보드

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A`를 지원하는 앱에서 모두 선택    |
| `Super + C`           | 복사    |
| `Super + X`           | 잘라내기 (터미널에서는 안 됨)    |
| `Super + V`           | 붙여넣기    |
| `Super + Ctrl + V`           | 클립보드 관리자    |

보통 Linux에서는 터미널에서 복사'n'붙여넣기를 하려면 `Ctrl + Shift + C/V`가 필요하고, 그 밖의 모든 곳에서는 `Ctrl + C/V`가 필요하다. 이런 Omarchy 통합 클립보드 단축키는 어디에서나 작동한다.

## 캡처

| 단축키              | 기능                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | 스크린샷                      |
| `Super + Ctrl + Alt + C`            | 스크린샷 (Print Screen 키가 없는 키보드를 위한 같은 샷) |
| `Super + Ctrl + C` | 캡처 메뉴 |
| `Alt + Print Screen`            | 화면 녹화                     |
| `Super + Shift + Ctrl + Alt + C` | 메뉴를 건너뛰고 오디오 없이 화면 녹화 (다시 누르면 중지) |
| `Super + Print Screen` | 색상 피커 |
| `Super + Ctrl + Print Screen` | 텍스트를 추출해 클립보드로 |
| `Super + Alt + [` | 녹화 중 웹캠 오버레이를 더 작게 |
| `Super + Alt + ]` | 녹화 중 웹캠 오버레이를 더 크게 |
| `Alt + Shift + L` | 웹앱이나 브라우저에서 현재 URL 복사 |
| `Alt + Shift + D` | 현재 페이지의 동영상을 `~/Videos`로 다운로드 |
| `Alt + Space` | 받아쓰기 시작/중지 (_Setup > Defaults > Dictation_ 필요) |
| `Right Alt` | 누르고 있는 동안 받아쓰기 (_Setup > Defaults > Dictation_ 필요) |

화면 녹화에서는 단축키가 먼저 어떤 오디오를 원하는지 묻고, 그 다음 녹화를 시작한다. 다시 누르면 중지한다. 자세한 내용은 [스크린샷과 녹화](12-screenshots-recording.md)를 참고하라.

모든 캡처 옵션은 Omarchy 메뉴 (`Super + Space`)의 _Trigger > Capture_에서도 접근할 수 있다.

## 알림

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + ,` | 최신 알림에 대해 동작 실행: 열거나 유일한 버튼 누르기, 선택지 중에서 고르기, 아무것도 없으면 닫기  |
| `Super + Shift + ,` | 모든 알림 닫기 |
| `Super + Ctrl + ,` | 키보드로 알림 제어  |
| `Super + Alt + ,` | 최신 알림 닫기  |
| `Super + Shift + Alt + ,` | 알림 기록 열기  |
| `Super + Ctrl + Alt + ,` | 알림 무음 전환  |

## 스타일

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 새 테마 선택 (`Super + Ctrl + Shift + Space`도 가능) |
| `Super + Ctrl + W` | 테마 배경 선택 (`Super + Ctrl + Space`도 가능) |
| `Super + Backspace` | 창의 투명도 전환 |
| `Super + Ctrl + Backspace` | 단일 창 정사각형 비율 전환 |

추가 배경 이미지는 `~/.config/omarchy/backgrounds/<theme name>`에 있다. Omarchy 메뉴의 _Install > Style > Background_에서도 이용할 수 있다.

모든 스타일 옵션은 Omarchy 메뉴 (`Super + Space`)의 _Appearance_에서도 접근할 수 있다.

## 토글

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | 유휴 시 잠금 전환 |
| `Super + Ctrl + Delete` | 노트북 디스플레이 켜기/끄기 전환 |
| `Super + Ctrl + Alt + Delete` | 노트북 디스플레이 미러링 전환 |
| `Super + Shift + Space` | 상단 바 전환  |
| `Shift + Mute` | 다음 오디오 출력으로 전환 |
| `Shift + Play` | 다음 미디어 소스로 전환 |
| `Super + Shift + Backspace` | 창 간격 전환 |
| `Super + Ctrl + Alt + F` | 전체 화면 데스크톱 전환 (상단 바 + 창 간격) |

## 리마인더

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | 리마인더 설정  |
| `Super + Ctrl + Alt + R` | 모든 리마인더 보기  |
| `Super + Ctrl + Shift + R` | 모든 리마인더 지우기  |

## 통지

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 시간을 알림으로 표시  |
| `Super + Ctrl + Alt + B` | 배터리를 알림으로 표시  |
| `Super + Ctrl + Alt + W` | 날씨를 알림으로 표시 전환  |

## Tmux

prefix 키는 `Ctrl + Space`이다 (`Ctrl + B`도 작동한다). 이 바인딩은 `~/.config/tmux/tmux.conf`에서 변경할 수 있다.

### 페인

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + v` | 옆에 페인 분할 (수직) |
| `Prefix + h` | 아래에 페인 분할 (수평) |
| `Prefix + x` | 페인 종료 |
| `Prefix + z` | 페인 확대/축소 전환 (전체 화면) |
| `Alt + Enter` | 아래에 페인 분할 (prefix 없음) |
| `Alt + Shift + Enter` | 옆에 페인 분할 (prefix 없음) |
| `Alt + Escape` | 페인 종료 (prefix 없음) |
| `Ctrl + Alt + Arrows` | 페인 사이 이동 |
| `Ctrl + Alt + Shift + Arrows` | 페인 크기 조정 |

### 윈도우

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + c` | 새 윈도우 |
| `Prefix + k` | 윈도우 종료 |
| `Prefix + r` | 윈도우 이름 바꾸기 |
| `Alt + 1-9` | 특정 윈도우로 이동 |
| `Alt + Arrow Left/Right` | 윈도우 사이 이동 |
| `Alt + Shift + Arrow Left/Right` | 윈도우를 왼쪽/오른쪽으로 이동 |

### 세션

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + C` | 새 세션 |
| `Prefix + K` | 세션 종료 |
| `Prefix + R` | 세션 이름 바꾸기 |
| `Prefix + N` | 다음 세션 |
| `Prefix + P` | 이전 세션 |
| `Alt + Arrow Up/Down` | 세션 사이 이동 |
| `Prefix + s` | 세션 목록 |
| `Prefix + d` | 세션에서 분리 |

### 복사 모드 (vi 스타일)

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + [` | 복사 모드 들어가기 |
| `v` | 선택 시작 (복사 모드에서) |
| `y` | 선택 복사 (복사 모드에서) |

### 일반

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + q` | 설정 다시 불러오기 |
| `Prefix + ?` | Tmux 키 바인딩 표시 |
| `Prefix + :` | 명령 프롬프트 |

### Tmux 레이아웃 함수

이 함수들은 Tmux 세션 안에서 실행해야 한다.

| 명령 | 기능 |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | 편집기, AI, 터미널로 개발 레이아웃 만들기 |
| `tdlm <ai> [<second_ai>]` | 하위 디렉터리별로 개발 레이아웃 만들기 |
| `tsl <count> <command>` | 다중 페인 swarm 레이아웃 만들기 |

## Ghostty 터미널

Ghostty 터미널은 Omarchy 메뉴를 통해 _Install > Terminal_을 사용해 설치한다.

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 아래에 새 분할 |
| `Ctrl + Shift + O` | 옆에 새 분할 |
| `Ctrl + Alt + Arrows` | 분할 사이 이동 |
| `Super + Ctrl + Shift + Arrows` | 분할 크기를 10줄만큼 조정 |
| `Super + Ctrl + Shift + Alt + Arrows` | 분할 크기를 100줄만큼 조정 |
| `Ctrl + Shift + T` | 새 탭  |
| `Ctrl + Shift + Arrows` | 탭 사이 이동 |
| `Alt + Numbers` | 특정 탭으로 이동 |
| `Shift + Pg Up/Down` | 기록 스크롤 |
| `Ctrl + Left mouse` | 링크를 브라우저에서 열기 |

## 파일 관리자

| 단축키              | 기능                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | 경로로 이동                     |
| `Space`               | 파일 미리보기 (화살표로 탐색) |
| `Alt + Up`       | 상위 폴더로 이동        |

## Neovim (w/ lazyvim)

### 탐색

| 단축키                   | 기능                        |
| ------------------------ | ------------------------------- |
| `Space`                    | 명령 옵션 표시            |
| `Space Space`              | 퍼지 검색으로 파일 열기      |
| `Space E`                  | 사이드바 전환                  |
| `Space G G`                | git 제어 표시               |
| `Space S G`                | 파일 내용 검색             |
| `Ctrl + W W`               | 사이드바와 편집기 사이 이동 |
| `Ctrl + Left/right arrow`  | 사이드바 크기 변경          |
| `Shift + H`                      | 왼쪽 파일 탭으로 이동             |
| `Shift + L`                      | 오른쪽 파일 탭으로 이동            |
| `Space B D`                | 파일 탭 닫기                  |

### 사이드바에 있을 때

| 단축키                   | 기능                        |
| ------------------------ | ------------------------------- |
| `A`                        | 상위 디렉터리에 새 파일 추가      |
| `Shift + A`                | 상위 디렉터리에 새 하위 디렉터리 추가    |
| `D`                        | 강조된 파일/디렉터리 삭제     |
| `M`                        | 강조된 파일/디렉터리 이동       |
| `R`                        | 강조된 파일/디렉터리 이름 바꾸기     |
| `?`                        | 모든 명령에 대한 도움말 표시      |

[LazyVim이 설정한 모든 Neovim 단축키 보기](https://www.lazyvim.org/keymaps).

## 빠른 이모지

`Super + Ctrl + E`를 사용하면 선택한 것을 클립보드에 넣는 완전한 이모지 피커를 표시할 수 있고, 이런 빠른 접근 옵션을 사용할 수도 있다.

| 단축키       | EM | 단서       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 미소      |
| `Shift + CapsLock M C` | 😂 | 울음        |
| `Shift + CapsLock M L` | 😍 | 사랑       |
| `Shift + CapsLock M V` | ✌️ | 승리    |
| `Shift + CapsLock M H` | ❤️ | 하트      |
| `Shift + CapsLock M Y` | 👍 | 네        |
| `Shift + CapsLock M N` | 👎 | 아니요         |
| `Shift + CapsLock M F` | 🖕 | 엿       |
| `Shift + CapsLock M W` | 🤞 | 소원       |
| `Shift + CapsLock M R` | 🤘 | 록       |
| `Shift + CapsLock M K` | 😘 | 키스       |
| `Shift + CapsLock M E` | 🙄 | 눈굴리기    |
| `Shift + CapsLock M I` | 😉 | 윙크       |
| `Shift + CapsLock M P` | 🙏 | 기도 |
| `Shift + CapsLock M D` | 🤤 | 침흘리기      |
| `Shift + CapsLock M M` | 💰 | 돈      |
| `Shift + CapsLock M X` | 🎉 | 축하 |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | 건배      |
| `Shift + CapsLock M O` |👌 | 오케이 |
| `Shift + CapsLock M G` |👋 | 인사 |
| `Shift + CapsLock M A` |💪 | 팔 |
| `Shift + CapsLock M B` |🤯 | 폭발 |

## 빠른 완성

| 단축키       | 완성       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (엠 대시)   |
| `Shift + CapsLock Space N` | 이름 (설정 시 입력한 대로)  |
| `Shift + CapsLock Space E` | 이메일 (설정 시 입력한 대로)  |

`~/.XCompose`를 편집해 직접 더 추가할 수 있고, 그 다음 터미널에서 `omarchy restart xcompose`를 실행하면 변경 사항이 반영된다.
