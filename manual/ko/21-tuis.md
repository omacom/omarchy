# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit)은 GitHub Desktop 같은 애플리케이션에 대한 즐거운 대안이며, 터미널 안에서 실행된다.

git으로 관리되는 아무 디렉터리로 이동해 `lazygit`을 실행하면 직접 실행할 수 있다. 또는 Neovim 안에서도 실행할 수 있으며, 여기서는 `Space G G`로 시작할 수 있다.

`Tab`을 사용해 여러 창 사이를 이동한다. Files 창에서는 `Space`를 사용해 스테이징할 파일을 선택한 다음, `c`를 사용해 새 커밋을 만들 수 있다. `?`를 사용하면 사용할 수 있는 모든 명령을 볼 수 있다.

## Btop

[Btop](https://github.com/aristocratos/btop)은 메모리, CPU, 디스크, 네트워크 사용량을 보여주는 아름다운 리소스 관리자다. 또한 실행 중인 모든 프로세스를 나열하고, 이를 관리할 수 있게 해준다.

Omarchy는 이를 Activity Monitor라고 부르며, 앱 런처에서 시작하거나 `Super + Shift + T`를 눌러 시작할 수 있다. 떠 있는 창으로 열리며, `Super + T`를 사용하면 타일로 배치할 수 있다.

## Herdr

[Herdr](https://github.com/omacom-io/herdr)은 워크스페이스, 탭, 창을 제공하는 터미널 워크스페이스 관리자이며, 분리했다가 나중에 돌아올 수 있는 영구 세션에서 이 모든 것을 계속 실행 상태로 유지한다.

`Super + Ctrl + Return`을 사용하면 시작하거나 (또는 기존 세션에 다시 연결) 할 수 있다. Omarchy는 Tmux 설정을 본뜬 Herdr 구성을 제공하므로, 여기서도 접두사 키는 `Ctrl + Space`다. `Super + Ctrl + K`를 사용하면 모든 키 바인딩을 둘러볼 수 있다.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch)는 커널 버전, 가동 시간, 테마, CPU, 메모리 등 시스템 정보를 보여준다. 인기 있는 neofetch 도구의 후계자다.

Omarchy는 이를 Omarchy 메뉴(`Super + Space`)의 _정보_로 패키징했다.

## Cliamp

[Cliamp](https://www.cliamp.stream/)는 Winamp 2.x에서 영감을 받은 레트로 터미널 음악 플레이어로, lo-fi 비트를 위한 라디오 방송국이 내장되어 있다. `Super + Shift + Alt + M`으로 실행하거나, Omarchy 메뉴의 _앱_에서 실행한다. `?`를 누르면 전체 키 바인딩 목록을 볼 수 있다.

## Wi-Fi와 Bluetooth는요?

Wi-Fi와 Bluetooth용 TUI는 찾을 수 없을 것이다 — 그 일은 Omarchy 셸의 몫이다. 상단 바의 Wi-Fi 아이콘을 클릭하거나 (`Super + Ctrl + N`을 눌러) 네트워크를 보고 연결하고, Bluetooth 아이콘을 클릭하거나 (`Super + Ctrl + B`를 눌러) 기기를 페어링하고 연결한다. 전체 이야기는 [네트워킹](35-networking.md)을 참조하라.

## 나만의 것 추가하기

모든 터미널 프로그램은 완전한 앱 대우를 받을 수 있다. Omarchy 메뉴(`Super + Space`)에서 _설치 > TUI_로 이동해 이름, 실행 명령, 창 스타일, 아이콘을 지정하면 다른 애플리케이션과 마찬가지로 앱 런처에 표시된다. _제거 > TUI_에서 다시 제거할 수 있다.
