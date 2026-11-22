# Neovim

[Neovim](https://neovim.io/)은 1976년으로 거슬러 올라가 Bill Joy가 만든 [vi 편집기](<https://en.wikipedia.org/wiki/Vi_(text_editor)>)의 현대적인 구현입니다. 입력 모드와 명령 모드가 분리된 모달 편집기이며, 엄청나게 방대한 키 명령어 중 일부만 익혀도 일종의 초능력 같은 힘을 발휘합니다. 하지만 배워야 할 것도 꽤 많습니다!

vim 스타일 편집이 완전히 처음이라면 YouTube에서 [ThePrimeagen의 Vim As Your Editor 시리즈](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R)를 확인해 보시길 추천합니다. 기본기를 가르쳐 줄 것입니다. 다만 더 비슷해 보이는 주류 편집기들과 달리, vim의 기본적인 숙련도를 갖추는 데는 더 오랜 시간이 걸린다는 점은 알아 두세요. 하지만 일단 익히고 나면 그 보상도 더 큽니다.

Neovim은 기본적으로 무한히 설정할 수 있습니다. 정말 제대로 파고들고 싶다면 Neovim 설정을 처음부터 직접 만들 수도 있습니다. [Typecraft의 Neovim을 처음부터 설정하는 훌륭한 강좌](https://www.youtube.com/watch?v=zHTeCSVAFNY)가 있습니다. 그리고 [ThePrimeagen의 강좌도 있습니다](https://www.youtube.com/watch?v=w7i4amO_zaE).

하지만 Omarchy에는 완성된 Neovim 설정 — `omarchy-nvim` 패키지 — 가 함께 제공되며, 설정 한 줄 작성하지 않고도 기본 상태에서 가능한 최고의 모습을 보여 주도록 정성껏 다듬어졌습니다! Neovim 플러그인과 설정의 배포판인 [LazyVim](https://www.lazyvim.org/)을 기반으로 만들어졌습니다. 정말 훌륭합니다.

## LazyVim 기본 사항

앞서 말했듯이 이 짧은 소개에서 vim을 가르쳐 드리지는 않겠지만, LazyVim의 몇 가지 기본 사항과 사용법은 보여 드릴 수 있습니다.

먼저 Neovim에는 리더 키라는 개념이 있습니다. 기본적으로 모든 명령으로 통하는 관문입니다. LazyVim은 이를 `Space`로 설정했습니다. 그러니 그냥 그 키를 누르고 1초 기다리면 다음과 같이 인라인으로 설명된 여러 옵션이 표시됩니다:

제가 항상 사용하는 기본 명령 몇 가지는 다음과 같습니다:

- `Space Space` - 현재 디렉터리에서 모든 파일을 퍼지 검색합니다.
- `Space S G` - 미리보기와 함께 grep을 사용해 모든 파일을 검색합니다.
- `Space E` - 파일 트리를 켜거나 끕니다.
- `Ctrl + W W` - 파일 트리와 편집기 사이를 오갑니다.
- `Shift + H` - 열린 탭 사이를 왼쪽으로 이동합니다(vim에서는 버퍼라고 부릅니다).
- `Shift + L` - 열린 탭 사이를 오른쪽으로 이동합니다.
- `Space B D` - 탭을 닫습니다.
- `Space B O` - 현재 탭을 제외한 다른 모든 탭을 닫습니다.
- `Space G G` - 현재 디렉터리에서 떠 있는 창에 LazyGit을 실행합니다.
- `Space U W` - 소프트 랩을 켜거나 끕니다.

파일 트리에 있는 동안(`Space E`를 눌러 표시하고 `Ctrl + W W`를 눌러 이동) `a`로 새 파일을 추가하거나 `A`로 새 디렉터리를 추가할 수 있습니다. 트리에서 `?`를 누르면 모든 명령을 볼 수 있습니다.

기본적인 vim 언어를 익히고 싶다면 제가 쓴 [세 부분으로 이루어진 구문](https://world.hey.com/dhh/wonderful-vi-a1d034d3)에 대한 글과 멋진 콤보 기술을 구사하는 방법을 확인해 보세요!

가능한 모든 명령은 [LazyVim Keymaps 페이지](https://www.lazyvim.org/keymaps)에서 볼 수 있습니다.

## Neovim 시작하기

`Super + Shift + N`을 누르면 기본 편집기가 실행되는데, 새로 설치한 경우에는 Plain입니다. 대신 Neovim이 실행되도록 하려면 _설정 > 기본값 > 편집기_에서 Neovim을 선택하세요. 하지만 보통은 터미널에서 작업하려는 디렉터리로 이동한 뒤 `n`을 입력하는 편이 더 쉽습니다. `n`은 `nvim`의 별칭으로, 기본적으로 현재 디렉터리를 열어 사용합니다. `n myfile.txt`로 단일 파일을 열 수 있습니다.

## sudo 편집에 Neovim 사용하기

슈퍼유저로만 변경할 수 있는 파일을 편집해야 한다면 `sudoedit /etc/sudoers.d/00-sudo-only-file`을 실행하세요. 기본 편집기가 열리므로, 모든 플러그인과 함께 Neovim을 사용하고 싶다면 _설정 > 기본값 > 편집기_에서 Neovim을 설정하세요.
