# Dotfiles

Omarchy는 주로 `~/.config`에 사는 이른바 dotfiles를 통해 구성됩니다. 이는 변경을 위한 당신의 파일로 간주됩니다. `/usr/share/omarchy`에 사는 파일은 Omarchy 자체에 속하며, 건드리면 안 됩니다. `/usr/share/omarchy`에서 무언가를 변경해야 한다면, 대신 `~/.config`에서 값을 덮어써야 합니다.

주요 구성은 Omarchy 메뉴(`Super + Space`)에서 직접 편집할 수 있습니다. 예를 들어 _설정 > 모니터_, _설정 > 단축키_, _설정 > 입력_, _설정 > 구성 > [file]_ 같은 항목입니다. 이렇게 하면 구성 편집 후 재시작이 필요한 프로세스는 편집기를 종료한 뒤 자동으로 재시작됩니다(기본값은 Neovim입니다 — `:wq`, 기억하세요! — 하지만 _설정 > 기본값 > 편집기_에서 변경할 수 있습니다).

다음은 `~/.config`의 주요 파일 목록과 그 파일이 제어하는 내용입니다:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 메인 Hyprland 구성입니다. Omarchy 기본값과 아래의 자체 재정의 파일을 로드합니다. [Hyprland 구성에 대해 더 알아보기](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | 자체 단축키와 기본값의 재정의입니다. |
| `~/.config/hypr/monitors.lua` | 모니터, 해상도, 위치를 제어합니다. |
| `~/.config/hypr/input.lua` | 키보드 레이아웃, 마우스, 트랙패드 설정을 제어합니다. |
| `~/.config/hypr/looknfeel.lua` | 간격, 테두리, 애니메이션, 나머지 외관을 제어합니다. |
| `~/.config/hypr/autostart.lua` | 세션과 함께 시작되는 추가 프로세스를 제어합니다. |
| `~/.config/omarchy/shell.json` | Omarchy 셸을 제어합니다: 막대 위치, 레이아웃, 위젯, 화면 보호기, 잠금, 유휴 타이밍. |
| `~/.config/foot/foot.ini` | 터미널을 제어합니다(foot이 기본값입니다). |
| `~/.XCompose` | 빠른 접근 이모지와 이름/이메일 자동 완성을 정의합니다. 변경 후에는 반드시 `omarchy-restart-xcompose`를 실행하세요. |

자체 설정을 조정하기 위해 많은 변경을 하게 된다면, 모든 dotfiles를 백업하는 것이 좋습니다. [Stow가 좋은 방법입니다](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### 세션과 함께 자체 앱 시작하기

로그인할 때마다 무언가를 실행하고 싶다면 — 동기화 데몬, 채팅 앱, 자체 스크립트 — `~/.config/hypr/autostart.lua`에 넣으세요:

```lua
o.launch_on_start("my-service")
```

그러면 해당 명령이 세션의 일부로 시작되어, 로그아웃할 때 제대로 정리됩니다.

### 시스템 이벤트에서 스크립트 실행하기

Omarchy는 몇 가지 순간에 훅을 발생시키며, 거기에 자체 스크립트를 걸 수 있습니다. 훅은 `~/.config/omarchy/hooks/<event>.d/`에 살며, 이벤트당 하나의 디렉터리가 있고, 거기에 있는 모든 실행 파일은 이벤트가 발생할 때 실행됩니다:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 데스크톱이 시작된 직후 |
| `post-update` | `omarchy update`의 거의 마지막, 패키지, 마이그레이션, 서비스 재시작 이후, mise 도구가 업데이트되기 전 |
| `pre-refresh-pacman` | `omarchy refresh pacman`이 패키지 구성을 다시 동기화한 뒤, 패키지를 업데이트하기 전; 채널 전환은 같은 새로고침 단계에서 이를 실행합니다 |
| `theme-set` | 테마 변경 후(테마 이름은 `$1`) |
| `font-set` | 글꼴 변경 후(글꼴 이름은 `$1`) |
| `battery-low` | 배터리가 부족해질 때(백분율은 `$1`) |

`pre-refresh-pacman` 훅은 패키지 트랜잭션 전에 실행되므로 사용자 지정 저장소나 `IgnorePkg` 줄이 들어가야 하는 곳입니다. 두 업데이트 관련 훅 모두 Omarchy가 캐시된 sudo 권한을 지운 뒤 사용자로 실행되므로, `sudo`를 사용하는 훅은 자체 권한이 필요하며 암호를 물을 수 있습니다.

해당 디렉터리 각각에는 이미 훅의 모양을 보여주는 `.sample` 파일이 있습니다 — 이름에서 `.sample`을 떼면 동작하게 됩니다. 다른 곳에 작성한 스크립트를 설치하려면 `omarchy hook install post-boot ~/my-hook`을 사용하세요. 스크립트를 복사하고 실행 가능하게 만듭니다.

### 자체 메뉴 항목 추가하기

Omarchy 메뉴(`Super + Space`)는 `~/.config/omarchy/extensions/omarchy-menu.jsonc`를 편집해 자체 행으로 확장할 수 있습니다. 항목은 점으로 구분된 id로 키가 지정되며, id가 트리에서 항목을 배치합니다. 따라서 `personal`은 루트 메뉴에 나타나고 `personal.notes`는 그 안에 나타납니다:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

기존 id를 재사용하면 새 행을 추가하는 대신 그 행을 재정의합니다. 파일에는 사용 가능한 모든 필드가 주석으로 문서화되어 있습니다.

### 자체 셸 내보내기, 함수, 별칭 추가하기

Omarchy에는 인체공학적 별칭과 유용한 함수가 잔뜩 함께 제공되지만, 직접 추가하고 싶은 경우가 매우 흔합니다. 별칭, 함수, 내보내기 모두를 `~/.bashrc`에 추가해야 합니다. 이 파일은 업데이트 시 덮어씌워지지 않습니다. Omarchy 기본값 중 어떤 것을 변경하고 싶다면, 여기에도 안전하게 추가할 수 있습니다.

### 내부 Omarchy 파일 변경하기

이건 당신의 컴퓨터입니다. 원하는 대로 무엇이든 할 수 있지만, `/usr/share/omarchy`의 파일을 직접 변경하지 말 것을 권합니다. 그 파일들은 Omarchy pacman 패키지에 속하므로, 변경 사항은 다음 업데이트 때 그냥 덮어씌워집니다. 대신 마음에 들지 않는 기본값은 `~/.config/*` 폴더에서 덮어쓰는 것이 낫습니다.

그렇게 하면 기본 단축키처럼 거의 모든 것을 변경할 수 있습니다. `~/.config/hypr/bindings.lua`를 편집해, 예를 들어 [Obsidian](https://obsidian.md/)을 [Joplin](https://joplinapp.org/)으로 바꾸세요(`omarchy-pkg-add joplin-bin`으로 설치):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind`는 교체 항목을 추가하기 전에 기존 바인딩을 제거합니다. 실행 도우미와 바인딩 옵션을 포함해 `o.bind`와 동일한 인수를 받습니다. 바인딩을 추가하려면 `o.bind`를, 교체하지 않고 제거하려면 `hl.unbind`를 사용하세요.

내부 Omarchy 파일을 굳이 해킹하고 싶다면 _업데이트 > 채널 > Dev_를 통해 dev 채널로 전환하세요. 그러면 Omarchy가 `~/omarchy`의 소스 코드 git 체크아웃에 연결되어, 마음껏 변경할 수 있습니다. 당신에게 뭐라 할 사람은 아무도 없습니다!

### 변경 사항 재설정하기

구성을 엉망으로 만들게 된다면, Omarchy 메뉴의 _업데이트 > 구성_을 통해 언제든 기본값으로 되돌릴 수 있습니다. 또는 `omarchy reinstall configs`를 실행해 모든 것을 재설정할 수 있습니다.
