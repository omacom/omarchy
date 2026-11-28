# 개발 도구

## 대체 편집기

Omarchy는 새 설치에서 Plain을 기본 편집기로 제공하며 [Neovim](https://neovim.io/)도 사전 설치되어 있지만, 조금 더 주류이고 익숙한 것을 원한다면 Omarchy Menu(`Super + Space`)를 실행해 _설치 > 편집기_ 아래의 옵션을 확인하면 된다. VSCode, Cursor, Zed, Sublime Text, Helix, Vim, Emacs가 거기에 나열되어 있다. 찾는 것이 없으면 _설치 > 패키지_를 확인해 Arch 패키지에 있는지 보고, 그래도 없으면 _설치 > AUR_에서 AUR을 확인해 보라.

원래의 `vi` 편집기도 기본으로 사용할 수 있다. 터미널에서 `vi filename`을 실행해 파일을 편집하면 된다.

`VSCode`, `Cursor`, `VSCodium`, `Helix`에는 테마 맞춤이 제공된다.

시스템 전체의 기본 편집기는 `Setup > Defaults > Editor`에서 설정할 수 있다.

## 환경

Omarchy는 Omarchy Menu(`Super + Space`)의 _설치 > 개발_ 섹션을 통해 온갖 개발 환경을 설정할 수 있게 지원한다. 물론 _Ruby on Rails_도 있지만, JavaScript용 주요 런타임 3종(Node.js, Bun, Deno)은 물론 Laravel, Symfony 같은 인기 PHP 프레임워크도 있다. 아, Go, Rust, Python, Java, Elixir(Phoenix 포함), .NET, OCaml, Zig, Clojure, Scala도 있다. 아주 폭넓은 선택지다!

이 환경들은 대부분 [Mise](https://mise.jdx.dev/)로 관리된다. 같은 컴퓨터에 프로그래밍 언어의 여러 버전을 설치하고 실행할 수 있게 해주는 도구다. Ruby용 rbenv나 rvm, Python용 virtualenv와 같지만, 온갖 다양한 환경에서 작동한다.

예를 들어 Ruby를 설치하려면 `mise use -g ruby`를 실행하면 되는데, 그러면 Ruby가 설치되고 전역 기본값으로 설정된다. 또는 프로젝트에 .ruby-version 파일이 있으면 해당 프로젝트의 루트에서 `mise i`를 실행하기만 하면 된다.

## 사전 설치된 CLI 도구

`uv`, Node.js, `playwright-cli`(에이전트가 설치된 Chrome을 사용해 브라우저를 조작하기 위한 것)는 패키지로 설치되어 제공되며, `omarchy update`가 시스템의 나머지와 함께 이를 최신 상태로 유지한다. [Hunk](https://github.com/modem-dev/hunk)와 GitHub, Basecamp, Cloudflare, HEY CLI는 _설치 > CLI_에서 클릭 한 번으로 설치할 수 있고, [코딩 에이전트](17-ai.md)는 _설치 > AI > CLI_에 있다.

mise는 _설치 > 개발_에서 설정한 런타임만 관리한다. Omarchy는 자체적으로 mise를 통해 아무것도 설치하지 않는다. Omarchy의 나머지와 함께 업데이트하려면 `omarchy update`를 실행하면 된다. `mup` 별칭은 mise로 관리되는 도구만 업데이트한다. 자신의 구성에 다른 도구를 추가하려면 `mise use -g <tool>`을 사용하라.

## Docker

[Docker](https://www.docker.com/)는 굳이 소개할 필요가 거의 없다. 격리된 컨테이너를 실행할 수 있게 해주며, Omarchy는 Docker 자체와 [Docker Compose](https://docs.docker.com/compose/)를 포함해 이를 제대로 실행하는 데 필요한 모든 것을 설치한다.

기본적으로 사용자는 `docker` 그룹에 *속해 있지 않다*. 그 그룹은 사실상 비밀번호 없는 root나 마찬가지다. 그 그룹에 속한 것은 무엇이든 `docker run -v /:/host`를 실행해 컴퓨터를 장악할 수 있다. 따라서 사용자로 실행되는 악성 스크립트나 의존성 하나가 그렇지 않았다면 root까지 명령 하나만을 남겨두게 되었을 것이다. 그래서 명령줄에서는 Docker를 `sudo`로 실행하고(`sudo docker ps`, `sudo docker compose up`), 데몬과 통신하는 그래픽 도구인 Windows VM은 필요할 때 인증을 요청한다. 그룹 없는 설정의 편리함을 되찾고 싶고 그 대가를 이해하고 있다면 **설정 > 보안 > Sudoless Docker**에서 이를 활성화하라(또는 `omarchy-setup-security-sudoless-docker`를 실행하라). 그러면 경고 후 `docker` 그룹에 추가된다. 이후에는 일반 `docker`와 `d` 별칭이 다시 `sudo` 없이 작동한다.

Omarchy 메뉴의 _설치 > 개발 > Docker DB_를 사용해 로컬 개발용 일반 데이터베이스를 Docker에 설정할 수 있다.

## GitHub CLI

[GitHub CLI](https://cli.github.com/)는 `gh`로, 터미널에서 저장소, 이슈, 풀 리퀘스트를 다루기 위한 것이다. 그곳에서 GitHub에 로그인하기로 선택하면 _설정 > Git_이 이를 설치하거나, _설치 > CLI > GitHub_에서 단독으로 설치할 수 있다. 이후 `gh repo clone org/repo`로 저장소를 복제하면 된다. `gh --help`를 실행해 그 명령들을 살펴보라.

[Lazygit](https://github.com/jesseduffield/lazygit)는 Git 자체를 다루기 위해 사전 설치되어 있다.
