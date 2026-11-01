# 셸 도구

표준 Linux 도구 외에도 Omarchy에는 향상된 셸 도구가 잔뜩 포함되어 있습니다. 주요 도구는 다음과 같습니다.

## fzf

[fzf](https://junegunn.github.io/fzf/)는 `ff` 별칭을 통해 파일을 퍼지 파인딩으로 찾을 수 있게 해줍니다. 아무 디렉터리로 가서 `ff`를 입력하면, 오른쪽에서 좁혀나가는 파일들의 미리보기를 보면서 해당 트리의 모든 파일을 퍼지 파인딩으로 찾을 수 있습니다.

`Ctrl + R`을 사용하면 fzf로 명령 기록을 퍼지 파인딩으로 탐색할 수 있습니다.

이 도구는 `Space Space`를 입력할 때 Neovim에서도 사용됩니다.

전체 설명서는 `man fzf`로 볼 수 있습니다.

## Zoxide

[Zoxide](https://github.com/ajeetdsouza/zoxide)는 cd의 대체 도구입니다. 방문한 디렉터리를 기억하므로 다음에 더 쉽게 이동할 수 있습니다. 예를 들어 `cd ~/.config/omarchy`를 한 번 실행했다고 합시다. 다음번에는 그냥 `cd omarchy`(또는 `cd oma`)를 실행하면 Zoxide가 바로 그곳으로 데려다줍니다.

전체 설명서는 `man zoxide`로 볼 수 있습니다.

## ripgrep

[ripgrep](https://github.com/BurntSushi/ripgrep)은 `rg <pattern> <path>`를 사용해 파일 내용을 검색합니다. 예를 들어 `rg Controller app/`은 app 디렉터리에서 `Controller`에 대한 모든 언급을 찾습니다.

이 도구는 `Space S G`를 입력할 때 Neovim에서도 사용됩니다.

전체 설명서는 `man rg`로 볼 수 있습니다.

## eza

[eza](https://eza.rocks/)는 ls의 대체 도구입니다. 더 많은 정보, 색상, 아이콘과 함께 디렉터리 목록을 보여줍니다. 기본적으로 eza는 ls로 별칭이 지정되어 있습니다. `lt`를 사용하면 두 단계 깊이의 중첩 목록을 볼 수도 있습니다. `lsa`는 숨김 파일을 포함한 목록을 보여줍니다. 그리고 `lta`는 숨김 파일을 포함한 중첩 목록을 보여줍니다.

전체 설명서는 `man eza`로 볼 수 있습니다.

## fd

[fd](https://github.com/sharkdp/fd)는 `find`를 더 쉽게 사용할 수 있도록 만든 대체 도구입니다. `fd person.rb`를 사용하면 현재 트리에서 `person.rb`라는 파일을 찾습니다. `fd person.rb /`는 전체 파일 시스템을 검색합니다. `fd person.rb / -H`는 숨김 디렉터리를 포함해 전체 파일 시스템을 검색합니다.

전체 설명서는 `man fd`로 볼 수 있습니다.

## bat

[bat](https://github.com/sharkdp/bat)은 구문 강조, 줄 번호, 페이징 기능이 있는 `cat`입니다. `bat somefile.rb`를 실행해 보면 왜 돌아가기 힘든지 알게 될 것입니다. 다른 곳에서도 조용히 작업을 해줍니다. man 페이지를 컬러로 표시하는 것도, `ff`에서 미리보기를 렌더링하는 것도 bat입니다.

전체 설명서는 `man bat`으로 볼 수 있습니다.

## tldr

[tldr](https://tldr.sh/)은 예제를 하나라도 보여주기 전에 세 화면짜리 역사로 시작하는 man 페이지에 대한 해독제입니다. `tldr tar`는 실제로 원했던 몇 가지 호출 방법을 보여줍니다.

## yt-dlp

[yt-dlp](https://github.com/yt-dlp/yt-dlp)는 YouTube와 수백 개의 다른 사이트에서 비디오를 다운로드합니다. `yt-dlp <url>`은 현재 디렉터리에 사용 가능한 최고 품질을 다운로드합니다.

전체 설명서는 `man yt-dlp`로 볼 수 있습니다.

## try

[try](https://github.com/tobi/try)는 날짜가 찍힌 디렉터리로 프로그래밍 실험을 쉽게 관리할 수 있게 해줍니다. 모든 실험은 `~/Work/tries`에 살며, `try`를 통해 접근할 수 있습니다.

Omarchy는 프로젝트의 `bin/` 디렉터리를 `PATH`에 자동으로 추가하지 않습니다. 신뢰할 수 있는 프로젝트 로컬 도구는 `bin/rails`나 `./bin/dev`처럼 명시적인 상대 경로로 실행하세요.
