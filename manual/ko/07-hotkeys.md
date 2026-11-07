# 단축키

`Super + K`로 모든 주요 키보드 바인딩을 볼 수 있다(Tmux 바인딩은 `Super + Alt + K`, Herdr 바인딩은 `Super + Ctrl + K`).

## 단축키 배치 방식

모든 단축키는 수정자 키로 정해지는 평면 위에 자리 잡고 있으며, 각 평면마다 하나의 역할이 있다. 덕분에 단축키가 서로 뒤섞이지 않고, 보통 어디에 무엇이 있는지 짐작할 수 있다.

| 평면 | 그곳에 있는 것 | 예시 |
| --- | --- | --- |
| `Super + key` | 시스템: 창, 워크스페이스, 레이아웃, 핵심 메뉴 | `Super + Space` Omarchy 메뉴, `Super + W` 창 닫기, `Super + F` 전체 화면 |
| `Super + Shift + key` | 앱 | `Super + Shift + B` 브라우저, `Super + Shift + E` 이메일, `Super + Shift + N` 편집기 |
| `Super + Ctrl + key` | 패널과 시스템 메뉴 | `Super + Ctrl + A` 오디오, `Super + Ctrl + N` 네트워크, `Super + Ctrl + C` 캡처 메뉴 |
| `Super + Ctrl + Alt + key` | 빠른 동작과 알림 | `Super + Ctrl + Alt + T` 시간 표시, `Super + Ctrl + Alt + B` 배터리, `Super + Ctrl + Alt + C` 스크린샷 |

단축키에 `Alt`를 추가하면 같은 것의 변형이 되며, 전혀 상관없는 기능이 되지는 않는다:

- `Super + Shift + B`는 브라우저를 연다; `Super + Shift + Alt + B`는 시크릿 창을 연다
- `Super + Shift + E`는 이메일을 연다; `Super + Shift + Alt + E`는 새 이메일을 시작한다
- `Super + F`는 전체 화면으로 전환한다; `Super + Alt + F`는 전체 너비로 전환한다
- `Super + Ctrl + C`는 캡처 메뉴를 연다; `Super + Ctrl + Alt + C`는 메뉴를 건너뛰고 스크린샷을 찍는다

단축키를 추가할 때:

1. 어떤 일을 하는지 보고 평면을 고른 다음, 키를 고른다.
2. 자리를 만들기 위해 기존 단축키를 옮기지 마라. 올바른 평면에서 빈 키를 찾아라.
3. `Alt`는 그것이 없는 단축키의 변형에만 사용해라.

몇몇 단축키는 편리하기 때문에 이런 규칙을 깨트린다. 화살표나 `Tab`과 함께 쓰는 `Shift`는 앱을 여는 대신 이동하거나 역방향으로 동작하고, `Print`, 미디어 키, `Alt + Tab`, `Ctrl + Alt + Del`은 다른 모든 곳에서와 똑같이 동작한다. 이들은 예외일 뿐, 따라 할 패턴이 아니다.

기본값이 마음에 들지 않으면(예를 들어 Windows처럼 스크린샷에 `Super + Shift + S`를 쓰고 싶다면), `~/.config/hypr/bindings.lua`에서 다시 바인딩해라.

## 탐색

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy 메뉴(앱 및 그 밖의 모든 것)    |
| `Super + Alt + Space` | 앱 그리드 |
| `Super + Escape` | 시스템 메뉴(절전, 재시작 등)  |
| `Super + Ctrl + L` | 컴퓨터 잠그기 |
| `Super + W` 또는 `Super + Q` | 창 닫기             |
| `Ctrl + Alt + Del` | 모든 창 닫기 |
| `Super + T`               | 창을 타일링/플로팅 간 전환             |
| `Super + J` | 창 위치 전환(가로/세로) |
| `Super + O`               | 창을 sticky'n'floating으로 팝업 전환 |
| `Super + L`               | dwindle, scrolling, floating 레이아웃 순환 |
| `Super + Alt + L`         | 레이아웃 역순 순환 |
| `Super + P`               | pseudo 창 스타일 전환(natural 대 stretch) |
| `Super + F`                 | 전체 화면으로 전환              |
| `Super + Alt + F`                 | 전체 너비로 전환              |
| `Super + Ctrl + F`                 | 창 내부 전체 화면으로 전환              |
| `Super + 1/2/3/4`         | 포커스된 모니터에서 특정 워크스페이스로 이동 |
| `Super + Tab` | 포커스된 모니터에서 다음 워크스페이스로 이동 |
| `Super + Shift + Tab` | 포커스된 모니터에서 이전 워크스페이스로 이동 |
| `Super + Ctrl + Tab` | 포커스된 모니터에서 직전 워크스페이스로 이동 |
| `Super + Shift + 1/2/3/4` | 창을 포커스된 모니터의 워크스페이스로 이동 |
| `Super + Shift + Alt + 1/2/3/4` | 따라가지 않고 창을 포커스된 모니터의 워크스페이스로 이동 |
| `Super + S` | 전체 스크래치패드 전환 |
| `Super + Alt + S` | 창을 전체 스크래치패드로 이동 |
| `Super + Grave` | Quake 콘솔 전환 |
| `Super + Shift + Grave` | 창을 Quake 콘솔로 이동 |
| `Super + Shift + Ctrl + Arrows` | 창을 해당 방향의 모니터로 이동 |
| `Super + Shift + Alt + Arrows` | 워크스페이스를 해당 방향의 모니터로 이동 |
| `Super + Arrow`  | 화살표 방향의 창으로 포커스 이동, 화면 가장자리에서는 그쪽 모니터로 넘어감 |
| `Super + Shift + Arrow`  | 화살표 방향의 다른 창과 교체, 그쪽 모니터에 있는 창 포함 |
| `Super + Minus` | 창을 왼쪽으로 확장 |
| `Super + Equal` | 창을 왼쪽으로 축소 |
| `Super + Shift + Minus` | 창을 위쪽으로 축소 |
| `Super + Shift + Equal` | 창을 아래쪽으로 확장 |
| `Super + Alt + Minus/Equal` | 같은 크기 조절을 더 작은 단계로 |
| `Super + Ctrl + Minus/Equal` | 같은 크기 조절을 더 큰 단계로 |
| `Super + Alt + Home` | 창 너비 저장 |
| `Super + Home` | 저장된 창 너비 복원 |
| `Super + Left Mouse` | 창 드래그 이동 |
| `Super + Right Mouse` | 창 크기 조절 |
| `Super + Scroll Wheel` | 포커스된 모니터에서 워크스페이스 스크롤 |
| `Super + G`               | 창 그룹화 전환      |
| `Super + Alt + G`               | 창을 그룹화에서 빼기      |
| `Super + Alt + Tab`               | 그룹 내 창 순환      |
| `Super + Alt + Shift + Tab`               | 그룹 내 창 역순 순환      |
| `Super + Alt + Scroll Wheel` | 그룹 내 창 순환 |
| `Super + Alt + 1/2/3/4/5`               | 그룹 내 특정 창으로 이동      |
| `Super + Alt + Arrow`  | 화살표 방향으로 창을 그룹에 넣기, 그쪽 모니터에 있는 창 포함 |
| `Super + Ctrl + Left/Right`  | 타일링 그룹 내부의 창 간 이동 |
| `Super + Ctrl + Z` | 화면 확대(반복하면 더 확대) |
| `Super + Ctrl + Alt + Z` | 화면 완전히 축소 |
| `Super + /` | 모니터 배율 옵션 앞으로 이동 |
| `Super + Alt + /` | 모니터 배율 옵션 뒤로 이동 |
| `Alt + Tab` | 활성 워크스페이스의 창 앞으로 순환 |
| `Alt + Shift + Tab` | 활성 워크스페이스의 창 뒤로 순환 |
| `Ctrl + Alt + Tab`| 모니터 간 포커스 앞으로 순환 |
| `Ctrl + Alt + Shift + Tab`| 모니터 간 포커스 뒤로 순환 |

크기 조절 단축키는 키보드에 인쇄된 문자와 상관없이 물리 키 `code:20`과 `code:21`(XKB `<AE11>` 및 `<AE12>`)을 사용한다. 미국 키보드에서 이 키는 `-`와 `=`이고, 일본어(JIS) 키보드에서는 `-`와 `^`이며, 스페인어 키보드에서는 `'`와 `¡`이다. JIS에서는 `Super + ^`가 `Super + Equal`이고, `Super + Shift + -`(`=`를 입력함)는 `Super + Shift + Minus`이다.

## 시스템 컨트롤

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | 오디오 패널    |
| `Super + Ctrl + B`           | Bluetooth 패널    |
| `Super + Ctrl + N`           | Wifi/네트워크 패널    |
| `Super + Ctrl + D`           | 디스플레이 패널    |
| `Super + Ctrl + P`           | 전원 패널    |
| `Super + Ctrl + Alt + D`           | 캘린더 패널    |
| `Super + Ctrl + Alt + E`           | 세계 시계 패널    |
| `Super + Ctrl + 1-9`           | 위치별로 바 패널 전환    |
| `Super + Ctrl + S` | 공유 메뉴(LocalSend 경유) |
| `Super + Ctrl + C` | 캡처 컨트롤(스크린샷/-녹화/피커) |
| `Super + Ctrl + O` | 메뉴 전환 |
| `Super + Ctrl + H` | 하드웨어 메뉴 |
| `Super + Ctrl + E` | 이모지 피커 |
| `Super + Ctrl + .` | 미디어 트랜스코딩 |
| `Super + Shift + Ctrl + A` | AI 에이전트 선택 |

## 조정

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | 화면 밝기 최대 |
| `Shift + Brightness Down` | 화면 밝기 최소 |
| `Alt + Brightness Up/Down` | 정밀한 1% 밝기 변경 |
| `Alt + Volume Up/Down` | 정밀한 1% 볼륨 변경 |
| `Keyboard Brightness Up/Down` | 키보드 백라이트 밝게/어둡게 |
| `Keyboard Backlight` | 키보드 백라이트 단계 순환 |
| `Alt + Play` | 다음 트랙 |
| `Alt + Shift + Play` | 이전 트랙 |

## 앱 실행

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Return`           | 터미널    |
| `Super + Alt + Return` | Tmux 터미널 |
| `Super + Ctrl + Return` | Herdr(에이전트 관리자) |
| `Super + Shift + Return`           | 브라우저    |
| `Super + Shift + Alt + B`           | 브라우저(시크릿/인코그니토)    |
| `Super + Shift + F`           | 파일 관리자    |
| `Super + Shift + Alt + F`           | 터미널의 cwd에서 파일 관리자    |
| `Super + Shift + M`           | 음악(Spotify)    |
| `Super + Shift + Alt + M`           | 음악(cliamp)    |
| `Super + Shift + /`           | 비밀번호 관리자(1password)    |
| `Super + Shift + Q`           | 계산기(Omacalc)    |
| `Super + Shift + T`           | 활동(btop)    |
| `Super + Shift + N`           | 편집기(Neovim)  |
| `Super + Shift + C`           | 캘린더([HEY](https://hey.com/))  |
| `Super + Shift + E`           | 이메일([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | 새 이메일([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI(ChatGPT)  |
| `Super + Shift + Alt + A`           | AI(Grok)  |
| `Super + Shift + G`           | 메신저(Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | 메신저(WhatsApp)  |
| `Super + Shift + Ctrl + G`           | 메신저(Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | 글쓰기(Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

`~/.config/hypr/bindings.lua`에서 바인딩을 변경/추가해라.

## 범용 클립보드

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + A`           | `Ctrl + A`를 지원하는 앱에서 모두 선택    |
| `Super + C`           | 복사    |
| `Super + X`           | 잘라내기(터미널에서는 제외)    |
| `Super + V`           | 붙여넣기    |
| `Super + Ctrl + V`           | 클립보드 관리자    |

보통 Linux에서는 터미널에서 copy'n'paste하려면 `Ctrl + Shift + C/V`가 필요하고, 그 밖의 모든 곳에서는 `Ctrl + C/V`를 써야 한다. Omarchy의 통합 클립보드 단축키는 어디서나 동작한다.

## 캡처

| 단축키              | 기능                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | 스크린샷                      |
| `Super + Ctrl + Alt + C`            | 스크린샷(동일한 촬영, Print Screen 키가 없는 키보드용) |
| `Super + Ctrl + C` | 캡처 메뉴 |
| `Alt + Print Screen`            | 화면 녹화                     |
| `Super + Print Screen` | 색상 피커 |
| `Super + Ctrl + Print Screen` | 텍스트를 추출해 클립보드로 |
| `Super + Alt + [` | 녹화 중 웹캠 오버레이 작게 |
| `Super + Alt + ]` | 녹화 중 웹캠 오버레이 크게 |
| `Alt + Shift + L` | 웹앱 또는 Chromium에서 현재 URL 복사 |
| `Alt + Shift + D` | 현재 페이지의 동영상을 `~/Videos`로 다운로드 |
| `Alt + Space` | 받아쓰기 시작/중지(_Setup > Defaults > Dictation_ 필요) |
| `Right Alt` | 길게 눌러 받아쓰기(_Setup > Defaults > Dictation_ 필요) |

화면 녹화 시, 이 단축키는 먼저 어떤 오디오를 원하는지 묻고 그 다음 녹화를 시작한다. 다시 누르면 중지된다. 자세한 내용은 [스크린샷과 녹화](12-screenshots-recording.md)를 참고해라.

모든 캡처 옵션은 Omarchy 메뉴(`Super + Space`)의 _Trigger > Capture_에서도 접근할 수 있다.

## 알림

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + ,` | 최신 알림에 동작 수행: 열거나 유일한 버튼을 누르고, 선택지 중에서 고르거나, 선택지가 없으면 닫기  |
| `Super + Shift + ,` | 모든 알림 닫기 |
| `Super + Ctrl + ,` | 키보드로 알림 제어  |
| `Super + Alt + ,` | 최신 알림 닫기  |
| `Super + Shift + Alt + ,` | 알림 기록 열기  |
| `Super + Ctrl + Alt + ,` | 알림 무음 전환  |

## 스타일

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | 새 테마 선택(`Super + Ctrl + Shift + Space`도 가능) |
| `Super + Ctrl + W` | 테마 배경 선택(`Super + Ctrl + Space`도 가능) |
| `Super + Backspace` | 창의 투명도 전환 |
| `Super + Ctrl + Backspace` | 단일 창 정사각형 비율 전환 |

추가 배경 이미지는 `~/.config/omarchy/backgrounds/<theme name>`에 있다. Omarchy 메뉴의 _Install > Style > Background_에서도 이용할 수 있다.

모든 스타일 옵션은 Omarchy 메뉴(`Super + Space`)의 _Style_에서도 접근할 수 있다.

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
| `Super + Ctrl + Alt + F` | 전체 화면 데스크톱 전환(상단 바 + 창 간격) |

## 리마인더

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | 리마인더 설정  |
| `Super + Ctrl + Alt + R` | 모든 리마인더 보기  |
| `Super + Ctrl + Shift + R` | 모든 리마인더 지우기  |

## 안내

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | 시간을 알림으로 표시  |
| `Super + Ctrl + Alt + B` | 배터리를 알림으로 표시  |
| `Super + Ctrl + Alt + W` | 날씨를 알림으로 표시 전환  |

## Tmux

접두사 키는 `Ctrl + Space`이다(`Ctrl + B`도 동작한다). 이 바인딩은 `~/.config/tmux/tmux.conf`에서 변경할 수 있다.

### 페인

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + v` | 페인 옆으로 나누기(세로) |
| `Prefix + h` | 페인 아래로 나누기(가로) |
| `Prefix + x` | 페인 종료 |
| `Prefix + z` | 페인 확대/축소 전환(전체 화면) |
| `Alt + Enter` | 페인 아래로 나누기(접두사 없음) |
| `Alt + Shift + Enter` | 페인 옆으로 나누기(접두사 없음) |
| `Alt + Escape` | 페인 종료(접두사 없음) |
| `Ctrl + Alt + Arrows` | 페인 간 이동 |
| `Ctrl + Alt + Shift + Arrows` | 페인 크기 조절 |

### 창

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + c` | 새 창 |
| `Prefix + k` | 창 종료 |
| `Prefix + r` | 창 이름 바꾸기 |
| `Alt + 1-9` | 특정 창으로 이동 |
| `Alt + Arrow Left/Right` | 창 간 이동 |
| `Alt + Shift + Arrow Left/Right` | 창을 왼쪽/오른쪽으로 이동 |

### 세션

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + C` | 새 세션 |
| `Prefix + K` | 세션 종료 |
| `Prefix + R` | 세션 이름 바꾸기 |
| `Prefix + N` | 다음 세션 |
| `Prefix + P` | 이전 세션 |
| `Alt + Arrow Up/Down` | 세션 간 이동 |
| `Prefix + s` | 세션 목록 |
| `Prefix + d` | 세션에서 분리 |

### 복사 모드(vi 스타일)

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Prefix + [` | 복사 모드 진입 |
| `v` | 선택 시작(복사 모드에서) |
| `y` | 선택 복사(복사 모드에서) |

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

## Ghostty Terminal

Ghostty 터미널은 Omarchy 메뉴의 _Install > Terminal_을 이용해 설치한다.

| 단축키                  | 기능              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | 아래로 새 분할 |
| `Ctrl + Shift + O` | 옆으로 새 분할 |
| `Ctrl + Alt + Arrows` | 분할 간 이동 |
| `Super + Ctrl + Shift + Arrows` | 분할 크기를 10줄만큼 조절 |
| `Super + Ctrl + Shift + Alt + Arrows` | 분할 크기를 100줄만큼 조절 |
| `Ctrl + Shift + T` | 새 탭  |
| `Ctrl + Shift + Arrows` | 탭 간 이동 |
| `Alt + Numbers` | 특정 탭으로 이동 |
| `Shift + Pg Up/Down` | 기록 스크롤 |
| `Ctrl + Left mouse` | 브라우저에서 링크 열기 |

## 파일 관리자

| 단축키              | 기능                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | 경로로 이동                     |
| `Space`               | 파일 미리보기(화살표로 탐색) |
| `Alt + Up`       | 상위 폴더로 이동        |

## Neovim (w/ lazyvim)

### 탐색

| 단축키                   | 기능                        |
| ------------------------ | ------------------------------- |
| `Space`                    | 명령 옵션 표시            |
| `Space Space`              | 퍼지 검색으로 파일 열기      |
| `Space E`                  | 사이드바 전환                  |
| `Space G G`                | git 컨트롤 표시               |
| `Space S G`                | 파일 내용 검색             |
| `Ctrl + W W`               | 사이드바와 편집기 간 이동 |
| `Ctrl + Left/right arrow`  | 사이드바 크기 변경          |
| `Shift + H`                      | 왼쪽 파일 탭으로 이동             |
| `Shift + L`                      | 오른쪽 파일 탭으로 이동            |
| `Space B D`                | 파일 탭 닫기                  |

### 사이드바에 있을 때

| 단축키                   | 기능                        |
| ------------------------ | ------------------------------- |
| `A`                        | 상위 디렉터리에 새 파일 추가      |
| `Shift + A`                | 상위 디렉터리에 새 하위 디렉터리 추가    |
| `D`                        | 강조 표시된 파일/디렉터리 삭제     |
| `M`                        | 강조 표시된 파일/디렉터리 이동       |
| `R`                        | 강조 표시된 파일/디렉터리 이름 바꾸기     |
| `?`                        | 모든 명령에 대한 도움말 표시      |

[LazyVim이 설정한 모든 Neovim 단축키 보기](https://www.lazyvim.org/keymaps).

## 빠른 이모지

`Super + Ctrl + E`를 사용하면 선택 항목을 클립보드에 넣는 완전한 이모지 피커를 표시하거나, 이런 빠른 접근 옵션을 사용할 수 있다.

| 단축키       | EM | 힌트       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | 미소      |
| `Shift + CapsLock M C` | 😂 | 울음        |
| `Shift + CapsLock M L` | 😍 | 사랑       |
| `Shift + CapsLock M V` | ✌️ | 승리    |
| `Shift + CapsLock M H` | ❤️ | 하트      |
| `Shift + CapsLock M Y` | 👍 | 예        |
| `Shift + CapsLock M N` | 👎 | 아니오         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | 소원       |
| `Shift + CapsLock M R` | 🤘 | 록       |
| `Shift + CapsLock M K` | 😘 | 키스       |
| `Shift + CapsLock M E` | 🙄 | 눈 굴리기    |
| `Shift + CapsLock M I` | 😉 | 윙크       |
| `Shift + CapsLock M P` | 🙏 | 기도 |
| `Shift + CapsLock M D` | 🤤 | 침 흘리기      |
| `Shift + CapsLock M M` | 💰 | 돈      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | 건배      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | 인사 |
| `Shift + CapsLock M A` |💪 | 팔 |
| `Shift + CapsLock M B` |🤯 | 폭발 |

## 빠른 완성

| 단축키       | 완성       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (mdash)   |
| `Shift + CapsLock Space N` | 이름(설정 시 입력한 대로)  |
| `Shift + CapsLock Space E` | 이메일(설정 시 입력한 대로)  |

`~/.XCompose`를 편집해 직접 더 추가할 수 있으며, 그 다음 터미널에서 `omarchy-restart-xcompose`를 실행하면 변경 사항이 반영된다.
