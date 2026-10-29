# 개발 도구

## 대체 편집기

Omarchy는 기본적으로 [Neovim](https://neovim.io/)와 함께 제공되지만, 좀 더 대중적이고 익숙한 무언가를 원한다면 Omarchy Menu(`Super + Space`)를 실행하고 _Install > Editor_ 아래의 옵션을 확인하면 된다. 거기에는 VSCode, Cursor, Zed, Sublime Text, Helix, Vim, Emacs가 나열되어 있다. 찾는 것이 없다면 _Install > Package_를 확인하고 Arch 패키지에 있는지 살펴보라(없다면 _Install > AUR_을 시도해 AUR을 확인해 보라).

원본 `vi` 편집기도 기본으로 사용할 수 있다. `vi filename`을 실행하면 터미널에서 파일을 편집할 수 있다.

`VSCode`, `Cursor`, `VSCodium`, `Helix`에는 테마 매칭이 제공된다.

시스템 전체 기본 편집기는 `Setup > Defaults > Editor`에서 설정할 수 있다.

## 환경

Omarchy는 Omarchy Menu(`Super + Space`)의 _Install > Development_ 섹션을 통해 온갖 개발 환경을 설정할 수 있도록 지원한다. 물론 _Ruby on Rails_도 있지만, JavaScript용 주요 런타임 3종(Node.js, Bun, Deno)은 물론 Laravel, Symfony 같은 인기 PHP 프레임워크도 있다. 아, Go, Rust, Python, Java, Elixir(Phoenix 포함), .NET, OCaml, Zig, Clojure, Scala도 있다. 정말 폭넓은 선택지다!

이러한 환경 대부분은 [Mise](https://mise.jdx.dev/)로 관리된다. 같은 컴퓨터에 프로그래밍 언어의 여러 버전을 설치하고 실행할 수 있게 해주는 도구다. Ruby용 rbenv나 rvm, Python용 virtualenv와 같지만, 다양한 환경에서 작동한다.

예를 들어 Ruby를 설치하려면 `mise use -g ruby`를 실행하면 Ruby가 설치되고 전역 기본값으로 설정된다. 또는 프로젝트에 .ruby-version 파일이 있으면 해당 프로젝트 루트에서 `mise i`만 실행하면 된다.

## 사전 설치된 CLI 도구

Omarchy는 [mise의 지연 설치](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools)를 통해 `gh`, `uv`와 대부분의 [코딩 에이전트](17-ai.md) 같은 도구를 사용할 수 있게 한다. 처음 실행할 때 mise가 설치한다. 이후 실행에서는 설치된 버전을 재사용하며, 실행할 때마다 업데이트를 확인하지 않는다.

기본값을 확인하거나 미리 설치할 수도 있다:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

`omarchy update`를 실행하면 Omarchy 전체와 함께 설치된 도구도 업데이트된다. `mup` 별칭은 mise가 관리하는 도구만 업데이트한다. 자신의 구성에 다른 도구를 추가하려면 `mise use -g <tool>`을 사용하라.

Python을 설정하면 mise를 통해 `uv`도 설치된다. Python 개발 환경을 제거해도 `uv`는 독립적인 도구로 계속 사용할 수 있다.

### 자신만의 설치 사용하기

mise의 명령은 `PATH`에서 `~/.local/bin`보다 앞에 오므로, 예를 들어 Claude Code나 Cursor 자체 설치 프로그램으로 직접 설치한 도구도 여전히 mise의 복사본이 실행된다. 데스크톱에서 실행한 앱도 시스템 패키지보다 mise의 명령을 먼저 찾으므로, pacman으로 `github-cli`를 설치했더라도 `gh`를 실행하는 앱은 mise의 복사본을 사용하고, mise는 처음 사용할 때 그 복사본을 설치한다. 대신 자신의 것을 사용하려면 `~/.config/mise/config.toml`에서 mise의 복사본을 비활성화하라. 예를 들어 Cursor CLI를 직접 설치했다면:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

이미 `[settings]` 테이블이 있다면 거기에 항목을 추가하라; 기존 `disable_tools` 목록이 있으면 교체하지 말고 확장하라. 자신의 설치가 `PATH`에 있는지 확인하라. 명령과 다를 수 있는 mise 도구 이름을 사용하라: 예를 들어 `oh-my-pi`는 `omp`를 제공한다. 기본 에이전트 실행기도 `~/.local/bin`에 사용자가 설치한 Cursor나 Claude Code를 우선한다.

### 기본값 제거 및 복원

_Remove Preinstalls_는 `~/.config/mise/miserc.toml`의 `ignored_config_paths`에 항목을 추가하여 mise가 사용자를 위한 Omarchy의 도구 선언을 건너뛰게 한다. _Restore Preinstalls_는 그 줄을 다시 제거한다. 자신의 구성이나 프로젝트의 `mise.toml`에 직접 선언한 도구는 어느 경우에도 계속 작동한다. 사전 설치 항목을 제거한 뒤 기본 에이전트를 선택하거나 Python을 설정하면 해당 도구가 자신의 구성에 추가된다. 둘 다 자신의 사용자에게만 적용되며, 컴퓨터의 다른 사용자는 각자의 선택을 유지한다.

## Docker

[Docker](https://www.docker.com/)는 굳이 소개할 필요가 거의 없다. 격리된 컨테이너를 실행할 수 있게 해주며, Omarchy는 Docker 자체와 [Docker Compose](https://docs.docker.com/compose/)를 포함해 Docker를 잘 실행하는 데 필요한 모든 것을 설치한다.

기본적으로 사용자는 `docker` 그룹에 *속하지 않는다*. 이 그룹은 사실상 비밀번호 없는 root나 마찬가지다 — 이 그룹에 속한 것은 무엇이든 `docker run -v /:/host`를 실행해 컴퓨터를 장악할 수 있다 — 따라서 악성 스크립트나 의존성 하나가 사용자로 실행되기만 해도 root까지 한 명령만 남게 된다. 그래서 명령줄에서는 `sudo`와 함께 Docker를 실행하고(`sudo docker ps`, `sudo docker compose up`), 데몬과 통신하는 그래픽 도구 — Windows VM — 는 필요할 때 권한을 요청한다. 그룹 없는 설정의 편리함을 되찾고 싶고 그 대가를 이해한다면 **Setup > Security > Sudoless Docker**에서 활성화하라(또는 `omarchy-setup-security-sudoless-docker` 실행). 경고 후 `docker` 그룹에 추가된다; 그러면 일반 `docker`와 `d` 별칭이 다시 `sudo` 없이 작동한다.

Omarchy 메뉴의 _Install > Development > Docker DB_를 사용해 Docker에서 로컬 개발용 일반 데이터베이스를 설정할 수 있다.

## GitHub CLI

[GitHub CLI](https://cli.github.com/)는 터미널에서 저장소, 이슈, pull request를 작업하기 위한 `gh`로 사용할 수 있다. `gh auth login`을 실행해 처음 사용할 때 설치하고 인증한 뒤, `gh repo clone org/repo`로 저장소를 클론하라. `gh --help`를 실행하면 명령을 살펴볼 수 있다.

pull request용 터미널 인터페이스를 사용하려면 `ghui`를 실행하라; mise가 처음 사용할 때 이것도 설치한다. Git 자체를 작업하기 위한 [Lazygit](https://github.com/jesseduffield/lazygit)는 사전 설치되어 있다.
