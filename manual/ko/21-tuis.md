# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit)는 GitHub Desktop 같은 애플리케이션의 즐거운 대안이며, 터미널 안에서 실행됩니다.

git으로 관리되는 아무 디렉터리로 이동해 `lazygit`를 실행하면 직접 실행할 수 있습니다. 또는 Neovim 안에서 실행할 수도 있는데, 거기서는 `Space G G`로 시작할 수 있습니다.

`Tab`을 사용해 여러 창 사이를 이동합니다. 파일 창에서는 `Space`를 사용해 스테이징할 파일을 선택한 다음, `c`를 사용해 새 커밋을 만들 수 있습니다. `?`를 사용하면 사용할 수 있는 모든 명령을 볼 수 있습니다.

## Btop

[Btop](https://github.com/aristocratos/btop)는 메모리, CPU, 디스크, 네트워크 사용량을 보여주는 아름다운 리소스 관리자입니다. 모든 활성 프로세스도 나열하고, 이를 관리할 수 있게 해줍니다.

Omarchy에서는 이를 Activity Monitor라고 부르며, 앱 런처에서 시작하거나 `Super + Shift + T`를 눌러 시작합니다. 플로팅 창으로 열리며, `Super + T`를 사용해 타일로 만들 수 있습니다.

## Herdr

[Herdr](https://github.com/omacom-io/herdr)는 워크스페이스, 탭, 창을 제공하는 터미널 워크스페이스 관리자이며, 분리했다가 나중에 돌아올 수 있는 영구 세션 안에서 그 모든 것을 계속 실행 상태로 유지합니다.

앱 런처에서 또는 `Super + Ctrl + Return`으로 시작합니다(또는 기존 세션에 다시 연결합니다). Omarchy는 Tmux 설정을 그대로 반영한 Herdr 설정을 함께 제공하므로, 여기서도 접두 키는 `Ctrl + Space`입니다. `Super + Ctrl + K`로 모든 키 바인딩을 살펴볼 수 있습니다.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch)는 커널 버전, 가동 시간, 테마, CPU, 메모리 등 시스템 정보를 보여줍니다. 인기 있는 neofetch 도구의 후계자입니다.

Omarchy는 이를 Omarchy 메뉴(`Super + Space`)의 _System > About_으로 묶어 제공합니다.

## Cliamp

[Cliamp](https://www.cliamp.stream/)는 Winamp 2.x에서 영감을 받은 레트로 터미널 음악 플레이어로, lo-fi 비트를 위한 라디오 방송국이 내장되어 있습니다. `Super + Shift + Alt + M`으로 실행하거나 Omarchy 메뉴의 _Apps_ 아래에서 실행하세요. 전체 키 바인딩 목록은 `?`를 누르세요.

## Wi-Fi와 Bluetooth는요?

Wi-Fi와 Bluetooth용 TUI는 찾을 수 없습니다 — 그 일은 Omarchy 셸의 몫입니다. 네트워크를 보고 연결하려면 상단 바의 Wi-Fi 아이콘을 클릭하고(또는 `Super + Ctrl + N`을 누르고), 장치를 페어링하고 연결하려면 Bluetooth 아이콘을 클릭하세요(또는 `Super + Ctrl + B`를 누르세요). 전체 이야기는 [네트워킹](35-networking.md)을 참조하세요.

## 직접 추가하기

모든 터미널 프로그램은 완전한 앱 대우를 받을 수 있습니다. Omarchy 메뉴(`Super + Space`)에서 _Install > TUI_로 이동해 이름, 실행 명령, 창 스타일, 아이콘을 지정하면 다른 애플리케이션과 마찬가지로 앱 런처에 표시됩니다. _Remove > TUI_ 아래에서 다시 제거할 수 있습니다.
