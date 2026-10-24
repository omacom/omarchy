# 개발 도구

## 대체 편집기

Omarchy는 기본적으로 [Neovim](https://neovim.io/)을 제공하지만, 좀 더 주류적이고 익숙한 무언가를 원한다면 Omarchy 메뉴(`Super + Space`)를 실행하고 _설치 > 편집기_ 아래의 옵션을 살펴보세요. VSCode, Cursor, Zed, Sublime Text, Helix, Vim, Emacs가 나열되어 있습니다. 원하는 것을 찾지 못했다면 _설치 > 패키지_를 확인하고 Arch 패키지에 없는지 살펴보세요(없다면 _설치 > AUR_에서 AUR을 확인해 보세요).

원본 `vi` 편집기도 기본으로 사용할 수 있습니다. 터미널에서 파일을 편집하려면 `vi filename`을 실행하세요.

테마 맞춤은 `VSCode`, `Cursor`, `VSCodium`, `Helix`에서 제공됩니다.

시스템 전체 기본 편집기는 `Setup > Defaults > Editor`에서 설정할 수 있습니다.

## 환경

Omarchy는 Omarchy 메뉴(`Super + Space`)의 _설치 > 개발_ 섹션을 통해 다양한 개발 환경 설정을 지원합니다. 물론 _Ruby on Rails_를 찾을 수 있지만, JavaScript용 세 가지 주요 런타임(Node.js, Bun, Deno)과 Laravel, Symfony 같은 인기 있는 PHP 프레임워크도 있습니다. 아, 그리고 Go, Rust, Python, Java, Elixir(Phoenix 포함), .NET, OCaml, Zig, Clojure, Scala도 있습니다. 정말 폭넓은 선택지입니다!

이러한 환경 대부분은 [Mise](https://mise.jdx.dev/)가 관리합니다. 같은 컴퓨터에 프로그래밍 언어의 여러 버전을 설치하고 실행할 수 있게 해주는 도구입니다. Ruby용 rbenv나 rvm, Python용 virtualenv와 비슷하지만, 여러 다른 환경에서 동작합니다.

예를 들어 Ruby를 설치하려면 `mise use -g ruby`를 실행하면 Ruby를 설치하고 전역 기본값으로 설정합니다. 프로젝트에 .ruby-version 파일이 있다면, 해당 프로젝트의 루트에서 `mise i`를 실행하면 됩니다.

## Docker

[Docker](https://www.docker.com/)는 소개가 거의 필요 없습니다. 격리된 컨테이너를 실행할 수 있게 해주며, Omarchy는 Docker 자체와 [Docker Compose](https://docs.docker.com/compose/)를 포함해 Docker를 잘 실행하는 데 필요한 모든 것을 설치합니다.

기본적으로 사용자는 `docker` 그룹에 *속해 있지 않습니다*. 그 그룹은 사실상 암호 없는 root입니다 — 그 그룹에 속한 무엇이든 `docker run -v /:/host`를 실행해 컴퓨터를 장악할 수 있습니다 — 따라서 사용자로 실행되는 악성 스크립트나 종속성 하나가 한 명령으로 root 권한을 얻을 수 있습니다. 그래서 명령줄에서는 Docker를 `sudo`와 함께 실행하고(`sudo docker ps`, `sudo docker compose up`), 데몬과 통신하는 그래픽 도구 — Windows VM — 는 필요할 때 권한을 요청합니다. 그룹 없는 구성의 편리함을 되찾고 싶고 그 대가를 이해한다면, **Setup > Security > Sudoless Docker**에서 활성화하세요(또는 `omarchy-setup-security-sudoless-docker`를 실행하세요). 경고를 표시한 뒤 사용자를 `docker` 그룹에 추가합니다. 그러면 평범한 `docker`와 `d` 별칭이 다시 `sudo` 없이 동작합니다.

Omarchy 메뉴의 _설치 > 개발 > Docker DB_를 사용해 Docker에서 로컬 개발용 일반 데이터베이스를 설정할 수 있습니다.

## GitHub CLI

[GitHub CLI](https://cli.github.com/)를 사용하면 GitHub 계정으로 인증하고 이를 이용해 비공개 저장소를 복제할 수 있습니다. 지연 로드되는 mise 스텁 중 하나로 연결되어 있어, `gh`를 처음 실행할 때 스스로 설치됩니다. 인증하려면 `gh auth login`을 실행하세요. 그러면 `gh repo clone org/repo`를 사용해 비공개 저장소를 체크아웃할 수 있습니다.

이 명령을 사용해 다른 많은 GitHub 작업도 수행할 수 있습니다. `gh`를 실행하면 가능한 모든 것을 볼 수 있습니다.

풀 리퀘스트를 TUI로 관리하기 위한 `ghui`용 지연 설치 스텁도 있습니다. 그리고 git 자체를 TUI로 다루고 싶다면 [lazygit](https://github.com/jesseduffield/lazygit)이 사전 설치되어 있습니다.
