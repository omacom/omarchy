# 개발 도구

## 대체 편집기

Omarchy는 새 설치에서 기본 편집기로 Plain을 제공하며 [Neovim](https://neovim.io/)이 사전 설치되어 있지만, 조금 더 대중적이고 익숙한 것을 원한다면 Omarchy Menu(`Super + Space`)를 실행하고 _설치 > 편집기_ 아래의 옵션을 확인하세요. 거기에는 VSCode, Cursor, Zed, Sublime Text, Helix, Vim, Emacs가 나열되어 있습니다. 원하는 것을 찾지 못했다면 _설치 > 패키지_를 확인해 Arch 패키지에 있는지 살펴보세요(없다면 _설치 > AUR_에서 AUR을 확인해 보세요).

원본 `vi` 편집기도 기본으로 사용할 수 있습니다. 터미널에서 `vi filename`을 실행해 파일을 편집하세요.

`VSCode`, `Cursor`, `VSCodium`, `Helix`에는 테마 매칭이 제공됩니다.

`설정 > 기본값 > 편집기`에서 시스템 전체 기본 편집기를 설정할 수 있습니다.

## 환경

Omarchy는 Omarchy Menu(`Super + Space`)의 _설치 > 개발_ 섹션을 통해 다양한 개발 환경을 설정할 수 있도록 지원합니다. 물론 _Ruby on Rails_도 있지만, JavaScript용 주요 런타임 3종(Node.js, Bun, Deno)과 Laravel, Symfony 같은 인기 PHP 프레임워크도 있습니다. 아, Go, Rust, Python, Java, Elixir(Phoenix 포함), .NET, OCaml, Zig, Clojure, Scala도 있습니다. 매우 폭넓은 선택지입니다!

이러한 환경 대부분은 [Mise](https://mise.jdx.dev/)로 관리됩니다. 같은 컴퓨터에 프로그래밍 언어의 여러 버전을 설치하고 실행할 수 있게 해주는 도구입니다. Ruby용 rbenv나 rvm, Python용 virtualenv와 비슷하지만, 다양한 환경에서 작동합니다.

예를 들어 Ruby를 설치하려면 `mise use -g ruby`를 실행하면 Ruby가 설치되고 전역 기본값으로 설정됩니다. 또는 프로젝트에 .ruby-version 파일이 있다면 해당 프로젝트의 루트에서 `mise i`를 실행하면 됩니다.

## 사전 설치된 CLI 도구

Omarchy는 [mise의 지연 설치](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools)를 통해 `gh`, `uv` 같은 도구와 대부분의 [코딩 에이전트](17-ai.md)를 제공합니다. 처음 실행할 때 mise가 이를 설치합니다. 그런 다음 코딩 에이전트는 실행 전에 업데이트를 확인하는데, 최대 4시간에 한 번만 확인합니다. `gh`, `uv` 같은 다른 도구는 업데이트할 때까지 설치된 버전을 계속 사용합니다.

기본값을 확인하거나 미리 설치할 수도 있습니다:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

`omarchy update`를 실행하면 Omarchy의 나머지 부분과 함께 설치된 도구가 업데이트됩니다. `mup` 별칭은 mise로 관리되는 도구만 업데이트합니다. 자신의 구성에 다른 도구를 추가하려면 `mise use -g <tool>`을 사용하세요.

Python 설정을 하면 mise를 통해 `uv`도 설치됩니다. Python 개발 환경을 제거해도 `uv`는 독립 도구로 계속 사용할 수 있습니다.

### 자체 설치 사용하기

mise의 명령이 `PATH`에서 `~/.local/bin`보다 앞에 오므로, 예를 들어 Claude Code나 Cursor 자체 설치 프로그램으로 직접 설치한 도구도 여전히 mise의 복사본이 실행됩니다. 데스크톱에서 실행한 앱도 시스템 패키지보다 mise의 명령을 먼저 찾으므로, `gh`를 실행하는 앱은 pacman으로 `github-cli`를 설치했더라도 mise의 복사본을 사용하며, mise는 처음 사용할 때 그 복사본을 설치합니다. 대신 직접 설치한 것을 사용하려면 `~/.config/mise/config.toml`에서 mise의 복사본을 비활성화하세요. 예를 들어 Cursor CLI를 직접 설치했다면 다음과 같습니다:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

이미 `[settings]` 테이블이 있다면 거기에 항목을 추가하세요. 기존 `disable_tools` 목록은 교체하지 말고 확장하세요. 직접 설치한 것이 `PATH`에 있는지 확인하세요. 명령과 다를 수 있는 mise 도구 이름을 사용하세요. 예를 들어 `oh-my-pi`는 `omp`를 제공합니다. 기본 에이전트 실행기도 `~/.local/bin`에 사용자가 설치한 Cursor나 Claude Code를 우선합니다.

### 기본값 제거 및 복원

_제거 > 사전 설치 항목_은 Omarchy에 사전 설치된 웹 앱, TUI, 앱을 제거하고, `~/.config/mise/miserc.toml`의 `ignored_config_paths`에 추가함으로써 mise가 사용자에게 적용되는 Omarchy의 도구 선언을 건너뛰게 합니다. _설치 > 사전 설치 항목_을 사용하면 이들이 복원되고 그 줄이 다시 제거됩니다. 자신의 구성이나 프로젝트의 `mise.toml`에 직접 선언한 도구는 어느 경우든 계속 작동합니다. 사전 설치 항목을 제거한 뒤 기본 에이전트를 선택하거나 Python을 설정하면 해당 도구가 자신의 구성에 추가됩니다. mise 설정은 자신의 사용자에게만 적용되며 다른 사용자는 각자의 선택을 유지합니다. 다만 앱은 패키지이므로, 이를 제거하거나 복원하면 컴퓨터의 모든 사용자에게 변경 사항이 적용됩니다.

## Docker

[Docker](https://www.docker.com/)는 굳이 소개할 필요가 없을 정도입니다. 격리된 컨테이너를 실행할 수 있게 해주며, Omarchy는 Docker 자체와 [Docker Compose](https://docs.docker.com/compose/)를 포함해 이를 잘 실행하는 데 필요한 모든 것을 설치합니다.

기본적으로 사용자는 `docker` 그룹에 속해 있지 *않습니다*. 그 그룹은 사실상 비밀번호 없는 root나 마찬가지입니다. 그 그룹에 속한 것은 무엇이든 `docker run -v /:/host`를 실행해 컴퓨터를 장악할 수 있습니다. 따라서 사용자로 실행되는 악성 스크립트나 의존성 하나가 그렇지 않았다면 root까지 단 한 번의 명령만으로 도달할 수 있게 됩니다. 그래서 명령줄에서는 `sudo`와 함께 Docker를 실행하고(`sudo docker ps`, `sudo docker compose up`), 데몬과 통신하는 그래픽 도구인 Windows VM은 필요할 때 권한 부여를 요청합니다. 그룹 없는 설정의 편리함을 되찾고 싶고 그 대가를 이해한다면 **설정 > 보안 > Sudoless Docker**에서 활성화하거나(`omarchy-setup-security-sudoless-docker` 실행) 하세요. 경고 후 `docker` 그룹에 추가됩니다. 그러면 일반 `docker`와 `d` 별칭이 다시 `sudo` 없이 작동합니다.

Omarchy 메뉴의 _설치 > 개발 > Docker DB_를 사용해 Docker에서 로컬 개발용 일반 데이터베이스를 설정할 수 있습니다.

## GitHub CLI

[GitHub CLI](https://cli.github.com/)는 터미널에서 저장소, 이슈, pull request를 다루기 위한 `gh`로 사용할 수 있습니다. `gh auth login`을 실행해 처음 사용할 때 설치하고 인증한 다음, `gh repo clone org/repo`를 실행해 저장소를 클론하세요. `gh --help`를 실행해 명령을 살펴보세요.

pull request용 터미널 인터페이스를 사용하려면 `ghui`를 실행하세요. mise가 처음 사용할 때 설치합니다. Git 자체를 다루기 위한 [Lazygit](https://github.com/jesseduffield/lazygit)도 사전 설치되어 있습니다.
