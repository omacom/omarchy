# Neovim

[Neovim](https://neovim.io/)은 1976년 Bill Joy가 만들었던 [vi 편집기](<https://en.wikipedia.org/wiki/Vi_(text_editor)>)의 현대적인 구현입니다. 입력 모드와 명령 모드가 분리된 모달 편집기이며, 믿을 수 없을 정도로 깊이 있는 키 명령 집합 중 일부만 익혀도 일종의 초능력이 됩니다. 하지만 학습 곡선도 상당합니다!

vim 스타일 편집이 완전히 처음이라면 YouTube에서 [ThePrimeagen의 Vim As Your Editor 시리즈](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)를 살펴보길 권합니다. 기본기를 가르쳐 줄 것입니다. 다만 비슷한 주류 편집기와 달리 vim은 기본적인 숙련도를 얻는 데 더 오래 걸린다는 것을 알아 두세요. 하지만 일단 익숙해지면 보상은 더 큽니다.

이제 Neovim은 기본적으로 무한히 구성할 수 있습니다. 정말 끝까지 파고들고 싶다면 Neovim 구성을 처음부터 직접 만들 수도 있습니다. [Typecraft의 Neovim 처음부터 설정하기](https://www.youtube.com/watch?v=zHTeCSVAFNY) 강의가 훌륭합니다. 그리고 [ThePrimeagen에게도 하나 있습니다](https://www.youtube.com/watch?v=w7i4amO_zaE).

하지만 Omarchy는 완전한 Neovim 설정 — `omarchy-nvim` 패키지 — 와 함께 제공됩니다. 이 패키지는 기본 상태에서 가능한 최선의 모습을 보여 주도록 정성껏 조정되었습니다. 구성 한 줄도 쓰지 않아도 됩니다! Neovim 플러그인과 구성의 배포판인 [LazyVim](https://www.lazyvim.org/)을 기반으로 합니다. 끝내줍니다.

## LazyVim 기본기

앞서 말했듯이 이 짧은 소개에서 vim을 가르쳐 드리지는 않겠지만, LazyVim의 기본기와 탐색 방법은 보여 드릴 수 있습니다.

먼저 Neovim에는 리더 키라는 개념이 있습니다. 기본적으로 모든 명령으로 통하는 관문입니다. LazyVim은 이를 `Space`로 설정했습니다. 그러니 그 키를 누르고 1초 정도 기다리면, 다음과 같이 인라인으로 설명되는 여러 옵션을 볼 수 있습니다:

제가 항상 사용하는 기본 명령 몇 가지는 다음과 같습니다:

- `Space Space` - 현재 디렉터리에서 모든 파일을 퍼지 검색합니다.
- `Space S G` - 미리보기와 함께 grep으로 모든 파일을 검색합니다.
- `Space E` - 파일 트리를 켜고 끕니다.
- `Ctrl + W W` - 파일 트리와 편집기 사이를 오갑니다.
- `Shift + H` - 열린 탭(vim에서는 버퍼라고 함) 사이에서 왼쪽으로 이동합니다.
- `Shift + L` - 열린 탭 사이에서 오른쪽으로 이동합니다.
- `Space B D` - 탭을 닫습니다.
- `Space B O` - 현재 탭을 제외한 다른 모든 탭을 닫습니다.
- `Space G G` - 현재 디렉터리에서 플로팅 창(pane)으로 LazyGit을 실행합니다.
- `Space U W` - 소프트 랩을 토글합니다.

파일 트리에 있는 동안(`Space E`로 표시, `Ctrl + W W`로 이동), `a`로 새 파일을 만들거나 `A`로 새 디렉터리를 만들 수 있습니다. 트리 안에서 `?`를 누르면 모든 명령을 볼 수 있습니다.

기본적인 vim 언어를 익히고 싶다면, 제가 [세 부분으로 이루어진 문법](https://world.hey.com/dhh/wonderful-vi-a1d034d3)과 그 멋진 콤보 동작들을 구사하는 법에 대해 쓴 글이 있습니다!

가능한 모든 명령은 [LazyVim Keymaps 페이지](https://www.lazyvim.org/keymaps)에서 볼 수 있습니다.

## Neovim 시작하기

`Super + Shift + N`으로 Neovim을 시작할 수 있지만(이 바인딩은 기본 편집기를 실행하며, 기본값은 Neovim입니다), 보통은 터미널에서 작업하려는 디렉터리로 이동한 뒤 `n`을 입력해 사용하는 편이 더 쉽습니다. `n`은 `nvim`의 별칭이며, 기본적으로 현재 디렉터리를 열어 사용합니다. `n myfile.txt`로 단일 파일을 열 수 있습니다.

## sudo 편집에 Neovim 사용하기

슈퍼 유저로만 변경할 수 있는 파일을 편집해야 한다면, `sudoedit /etc/sudoers.d/00-sudo-only-file`을 실행해 모든 플러그인이 설정된 Neovim을 사용할 수 있습니다.
