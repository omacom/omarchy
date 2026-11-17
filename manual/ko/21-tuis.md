# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit)는 GitHub Desktop 같은 앱의 즐거운 대안이며, 터미널 안에서 실행된다.

git으로 관리되는 어떤 디렉터리로든 이동해 `lazygit`를 실행하면 직접 실행할 수 있다. 아니면 Neovim 안에서 실행할 수도 있는데, 거기서는 `Space G G`로 시작할 수 있다.

`Tab`으로 여러 창 사이를 이동한다. Files 창에서는 `Space`로 스테이징할 파일을 선택한 뒤, `c`로 새 커밋을 만들 수 있다. 사용 가능한 모든 명령은 `?`로 볼 수 있다.

## Btop

[Btop](https://github.com/aristocratos/btop)은 메모리, CPU, 디스크, 네트워크 사용량을 보여주는 아름다운 리소스 관리자다. 모든 활성 프로세스도 나열하며, 직접 관리할 수 있게 해준다.

Omarchy에서는 이를 Activity Monitor라고 부르며, 앱 런처에서 시작하거나 `Super + Shift + T`를 눌러 시작한다. 떠 있는 창으로 열리는데, `Super + T`로 타일링할 수 있다.

## Herdr

[Herdr](https://github.com/omacom-io/herdr)는 워크스페이스, 탭, 창을 제공하는 터미널 워크스페이스 관리자이며, 분리했다가 나중에 다시 돌아올 수 있는 영구 세션 안에서 모두 계속 실행되게 해준다.

앱 런처에서 시작하거나(또는 기존 세션에 다시 연결하거나) `Super + Ctrl + Return`을 누르면 된다. Omarchy에는 Tmux 설정을 그대로 반영한 Herdr 설정이 포함되어 있어, 여기서도 접두사 키는 `Ctrl + Space`다. `Super + Ctrl + K`로 모든 키 바인딩을 살펴볼 수 있다.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch)는 커널 버전, 가동 시간, 테마, CPU, 메모리 등 시스템 정보를 보여준다. 인기 있던 neofetch 도구의 후계자다.

Omarchy 메뉴(`Super + Space`)에서는 이를 _정보_로 제공한다.

## Cliamp

[Cliamp](https://www.cliamp.stream/)는 Winamp 2.x에서 영감을 받은 레트로 터미널 음악 플레이어로, lo-fi 비트를 위한 라디오 방송국이 내장되어 있다. `Super + Shift + Alt + M`으로 실행하거나, Omarchy 메뉴의 _앱_에서 실행한다. `?`를 누르면 전체 키 바인딩 목록이 나온다.

## Wi-Fi와 Bluetooth는요?

Wi-Fi와 Bluetooth용 TUI는 찾을 수 없을 것이다 — 그 일은 Omarchy 셸의 몫이다. 상단 바의 Wi-Fi 아이콘을 클릭하거나(또는 `Super + Ctrl + N`을 눌러) 네트워크를 보고 연결하고, Bluetooth 아이콘을 클릭하거나(또는 `Super + Ctrl + B`를 눌러) 기기를 페어링하고 연결한다. 전체 이야기는 [네트워킹](35-networking.md)을 참고한다.

## 직접 추가하기

어떤 터미널 프로그램이든 온전한 앱 대우를 받을 수 있다. Omarchy 메뉴(`Super + Space`)에서 _설치 > TUI_로 이동해 이름, 실행 명령, 창 스타일, 아이콘을 지정하면 다른 모든 애플리케이션처럼 앱 런처에 나타난다. _제거 > TUI_에서 다시 제거할 수 있다.
