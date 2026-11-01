# 터미널

[Foot](https://codeberg.org/dnkl/foot)는 Omarchy의 기본 터미널입니다. 빠르고 가벼우며 오래된 컴퓨터에서도 호환됩니다. 하지만 네이티브 탭이나 분할은 지원하지 않습니다.

Tmux를 쓴다면 신경 쓰이지 않을 수 있지만, 그렇지 않다면 _Alacritty_, _Ghostty_, _Kitty_도 옵션으로 완전히 지원합니다. Omarchy 메뉴의 _설치 > 터미널_에서 원하는 것을 고르세요.

`Super + Return`으로 새 터미널을 시작합니다. (이 바인딩은 _설치 > 터미널_을 통해 설치한 터미널을 자동으로 가리키며, _설정 > 기본값 > 터미널_에서 설치된 터미널 간에 전환할 수 있습니다.)

## Tmux

Tmux는 터미널과 관계없이 창(pane), 윈도우(탭이라고도 함), 재개 가능한 세션을 위한 일관되고 프로그래밍 가능한 인터페이스를 제공합니다. 원격 호스트에서도 작동하므로 서버에 SSH로 접속할 때도 같은 접근 방식을 사용할 수 있습니다.

`Super + Alt + Return`으로 새 터미널에서 새 Tmux 세션을 시작합니다. Tmux는 영속적인 프로세스이므로 해당 터미널을 닫아도 세션을 재개할 수 있습니다. `Ctrl + Space`(프리픽스 키라고 함)를 누른 뒤 `s`를 누르면 모든 활성 세션을 볼 수 있습니다.

Omarchy는 인체공학적으로 최적화된 Tmux 구성과 함께 제공되며, 배워야 할 키바인딩이 많으므로 [치트시트를 곁에 두세요](07-hotkeys.md#tmux).

## Tmux 레이아웃 함수

Tmux는 프로그래밍 가능하므로 함수를 사용해 레이아웃을 만들 수 있습니다. Omarchy는 일반적인 개발자 레이아웃을 위한 네 가지 서로 다른 함수와 함께 제공됩니다.

`tdl [agent]`는 왼쪽에 `$EDITOR`, 오른쪽에 선택한 AI 에이전트(예: opencode용 `c`, Claude용 `cx`, OpenAI용 `codex`), 아래쪽에 터미널이 있는 3분할 IDE 같은 인터페이스를 시작합니다.

따라서 `tdl c`를 실행하면 다음과 같은 화면이 시작됩니다(또는 그냥 `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

`tdl c cx`(opencode + claude)로 두 번째 에이전트도 시작할 수 있습니다(또는 그냥 `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

왼쪽 위에 편집기, 오른쪽 위에 실시간 diff 감시자, 왼쪽 아래에 터미널, 오른쪽 아래에 opencode가 있는 4분할 정사각형을 시작하는 `tds`도 있습니다.

`tdlm [agent]`를 사용해 현재 디렉터리의 모든 하위 디렉터리에 대해 이 레이아웃 구성을 시작할 수도 있으며, 그런 다음 `alt + 1/2/3/4/5/...`로 이동합니다:

 ![tmux-tdlm](images/tmux-tdlm.webp)

마지막으로 `tsl [panes] [command]`를 사용해 에이전트 스웜을 시작할 수 있습니다. 따라서 `tsl 4 c`를 실행하면 opencode 에이전트로 구성된 4분할 그리드가 생성됩니다:

 ![tmux-tsl](images/tmux-tsl.webp)
