# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit)는 GitHub Desktop 같은 애플리케이션을 대체하는 즐거운 대안이며, 터미널 안에서 실행됩니다.

git으로 관리되는 아무 디렉터리로나 이동해 `lazygit`를 실행하면 직접 실행할 수 있습니다. 또는 Neovim 안에서 실행할 수도 있으며, Neovim에서는 `Space G G`로 시작할 수 있습니다.

`Tab`을 사용해 서로 다른 창 사이를 오갑니다. Files 창에서는 `Space`를 사용해 스테이징할 파일을 선택한 다음, `c`를 사용해 새 커밋을 만들 수 있습니다. `?`를 사용하면 사용할 수 있는 모든 명령어를 볼 수 있습니다.

## Btop

[Btop](https://github.com/aristocratos/btop)는 메모리, CPU, 디스크, 네트워크 사용량을 보여주는 아름다운 리소스 관리자입니다. 모든 활성 프로세스도 나열하며, 이를 관리할 수 있게 해줍니다.

Omarchy에서는 이를 Activity라고 부르며, `Super + Shift + T`를 눌러 시작합니다. 플로팅 창으로 열리며, `Super + T`를 사용해 타일로 배치할 수 있습니다.

## Herdr

[Herdr](https://github.com/omacom-io/herdr)는 워크스페이스, 탭, 창을 제공하는 터미널 워크스페이스 관리자이며, 분리했다가 나중에 돌아올 수 있는 영구 세션에서 모두 계속 실행되게 해줍니다.

`Super + Ctrl + Return`으로 시작합니다(또는 기존 세션에 다시 연결합니다). Omarchy에는 Tmux 설정을 그대로 반영한 Herdr 설정이 포함되어 있어, 여기서도 접두사 키는 `Ctrl + Space`입니다. `Super + Ctrl + K`로 모든 키 바인딩을 살펴볼 수 있습니다.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch)는 커널 버전, 가동 시간, 테마, CPU, 메모리 등 시스템 정보를 보여줍니다. 인기 있는 neofetch 도구의 후계자입니다.

Omarchy는 이를 Omarchy 메뉴(`Super + Space`)에서 _About_으로 패키징했습니다.

## Cliamp

[Cliamp](https://www.cliamp.stream/)는 Winamp 2.x에서 영감을 받은 레트로 터미널 음악 플레이어로, lo-fi 비트를 위한 내장 라디오 방송국까지 갖추고 있습니다. `Super + Shift + Alt + M`으로 실행하거나, Omarchy 메뉴의 _Apps_에서 실행하세요. `?`를 누르면 전체 키 바인딩 목록을 볼 수 있습니다.

## Wi-Fi와 Bluetooth는요?

Wi-Fi와 Bluetooth용 TUI는 찾을 수 없습니다 — 그 작업은 Omarchy 셸의 몫입니다. 상단 바의 Wi-Fi 아이콘을 클릭하거나(`Super + Ctrl + N`을 눌러) 네트워크를 보고 연결하고, Bluetooth 아이콘을 클릭하거나(`Super + Ctrl + B`를 눌러) 기기를 페어링하고 연결하세요. 전체 내용은 [네트워킹](35-networking.md)을 참조하세요.

## 직접 추가하기

모든 터미널 프로그램은 완전한 앱 대우를 받을 수 있습니다. Omarchy 메뉴(`Super + Space`)에서 _Install > TUI_로 이동해 이름, 실행 명령어, 창 스타일, 아이콘을 지정하면, 다른 모든 애플리케이션과 마찬가지로 앱 런처에 표시됩니다. _Remove > TUI_에서 다시 제거할 수 있습니다.
