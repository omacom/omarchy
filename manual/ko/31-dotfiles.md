# Dotfiles

Omarchy는 주로 `~/.config`에 있는 이른바 dotfiles를 통해 설정합니다. 이 파일들은 당신의 변경을 위한 당신의 파일로 간주됩니다. `/usr/share/omarchy`에 있는 파일들은 Omarchy 자체에 속하므로, 그 파일들을 건드려서는 안 됩니다. `/usr/share/omarchy`의 무언가를 변경해야 한다면, 대신 `~/.config`에서 값을 덮어써야 합니다.

주요 설정은 Omarchy 메뉴(`Super + Space`)에서 바로 편집할 수 있습니다. 예를 들어 _Setup > Keyboard > Keybindings_, _Setup > Input_, _Setup > Config > [file]_이 그렇습니다. 이런 방식으로 편집하면, 설정을 편집한 뒤 재시작이 필요한 프로세스는 편집기를 종료한 뒤 자동으로 재시작됩니다 (기본값은 Neovim입니다 — `:wq`, 기억하세요! — 하지만 _Setup > Defaults > Editor_를 통해 변경할 수 있습니다).

다음은 `~/.config`의 주요 파일과 각 파일이 제어하는 항목 목록입니다:

| File                  | Purpose              |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | 메인 Hyprland 설정입니다. Omarchy 기본값과 아래의 사용자 재정의 파일을 불러옵니다. [Hyprland 설정에 대해 자세히 알아보기](https://wiki.hypr.land/Configuring/).  |
| `~/.config/hypr/bindings.lua` | 직접 만든 키 바인딩과 기본값 재정의입니다. |
| `~/.config/hypr/monitors.lua` | 회전, 추가 모드, 모니터 꺼두기처럼 모니터 패널에서 다루지 않는 모니터 설정입니다. |
| `~/.config/hypr/input.lua` | 키보드 레이아웃, 마우스, 트랙패드 설정을 제어합니다. |
| `~/.config/hypr/looknfeel.lua` | 간격, 테두리, 애니메이션 및 나머지 외관을 제어합니다. |
| `~/.config/hypr/autostart.lua` | 세션과 함께 시작되는 추가 프로세스를 제어합니다. |
| `~/.config/omarchy/shell.json` | Omarchy shell을 제어합니다: 바 위치, 레이아웃, 위젯, 그리고 화면 보호기, 잠금, 유휴 시간 설정입니다. |
| `~/.config/foot/foot.ini` | 터미널을 제어합니다 (foot이 기본값입니다). |
| `~/.XCompose` | 빠른 접근용 이모지와 이름/이메일 자동 완성을 정의합니다. 변경한 후에는 반드시 `omarchy-restart-xcompose`를 실행하세요. |

자신의 setup을 조정하느라 결국 많은 변경을 하게 된다면, 이 모든 dotfiles를 백업해 두는 것이 좋습니다. [Stow가 그 작업을 하기 좋은 방법입니다](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### 세션과 함께 나만의 앱 시작하기

로그인할 때마다 무언가를 실행하고 싶다면 — 동기화 데몬, 채팅 앱, 직접 만든 스크립트 등 — `~/.config/hypr/autostart.lua`에 넣으세요:

```lua
o.launch_on_start("my-service")
```

이렇게 하면 명령이 세션의 일부로 시작되므로, 다시 로그아웃할 때 제대로 정리됩니다.

### 시스템 이벤트에서 스크립트 실행하기

Omarchy는 몇 가지 시점에 hook을 실행하며, 여기에 직접 만든 스크립트를 연결할 수 있습니다. 스크립트는 `~/.config/omarchy/hooks/<event>.d/`에 있으며 이벤트마다 디렉터리가 하나씩 있고, `.sample`로 끝나지 않는 그 안의 모든 파일은 이벤트가 발생할 때 bash로 실행됩니다:

| Event | When it runs |
| ----- | ------------ |
| `post-boot` | 데스크톱이 시작된 직후 |
| `post-update` | `omarchy update`가 끝날 무렵, 패키지, 마이그레이션, 서비스 재시작 이후, mise 도구가 업데이트되기 전 |
| `pre-refresh-pacman` | `omarchy refresh pacman`이 패키지 설정을 다시 동기화한 후, 패키지를 업데이트하기 전; 채널 전환 시에도 같은 새로고침 단계에서 실행됩니다 |
| `theme-set` | 테마 변경 후 (테마 이름은 `$1`에 있음) |
| `font-set` | 폰트 변경 후 (폰트 이름은 `$1`에 있음) |
| `battery-low` | 배터리가 부족할 때 (백분율은 `$1`에 있음) |

`pre-refresh-pacman` hook은 패키지 트랜잭션 전에 실행되므로 사용자 지정 저장소나 `IgnorePkg` 줄을 넣을 곳입니다. 둘 다 당신의 사용자 권한으로 실행됩니다. `post-update`는 `omarchy update`의 sudo 인증이 아직 유효한 동안 실행되므로, `sudo`를 사용하는 hook은 비밀번호를 다시 묻지 않습니다; `pre-refresh-pacman`은 `omarchy refresh pacman`이 직접 sudo를 사용한 직후에 실행됩니다.

각 디렉터리에는 이미 hook의 형태를 보여 주는 `.sample` 파일이 들어 있습니다 — 이름에서 `.sample`을 떼면 바로 사용할 수 있습니다. 다른 곳에 작성한 스크립트를 설치하려면 `omarchy hook install post-boot ~/my-hook`를 사용하세요. 파일을 복사하고 실행 가능하게 만들어 줍니다.

### 나만의 메뉴 항목 추가하기

Omarchy 메뉴(`Super + Space`)는 `~/.config/omarchy/extensions/omarchy-menu.jsonc`를 편집해 직접 만든 행으로 확장할 수 있습니다. 항목은 점으로 구분된 id를 키로 하며, 이 id가 트리에서 항목의 위치를 정합니다. 그래서 `personal`은 루트 메뉴에 나타나고 `personal.notes`는 그 안에 나타납니다:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

기존 id를 재사용하면 새 행을 추가하는 대신 해당 행을 재정의합니다. 파일에는 사용할 수 있는 모든 필드가 주석으로 문서화되어 함께 제공됩니다.

### 나만의 shell export, 함수 및 alias 추가하기

Omarchy에는 사용하기 편한 alias와 유용한 함수가 많이 함께 제공되지만, 직접 만든 것을 추가하고 싶어지는 경우도 아주 흔합니다. alias, 함수, export는 모두 `~/.bashrc`에 추가해야 합니다. 이 파일은 업데이트 시 덮어써지지 않습니다. Omarchy 기본값 중 어느 것이든 바꾸고 싶다면 여기에 안전하게 추가해도 됩니다.

### 데스크톱 환경 변수 설정하기

데스크톱 세션 export는 `~/.config/uwsm/env.d/`에 있어야 합니다. 이 파일들은 데스크톱이 시작되기 전에 실행되므로 shell 오류가 발생하면 로그인 화면으로 되돌아갈 수 있습니다. 편집하는 동안에는 작동하는 터미널을 열어 두세요. 재정의를 비활성화하려면 `env.d` 밖으로 옮기세요. 변경 때문에 로그인할 수 없게 되면 [로그인 복구](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)를 참고하세요.

### 내부 Omarchy 파일 변경하기

자, 이건 당신의 컴퓨터입니다. 무엇이든 원하는 대로 할 수 있지만, `/usr/share/omarchy`에 있는 파일을 직접 변경하는 것은 권하지 않습니다. 그 파일들은 Omarchy pacman 패키지에 속하므로, 변경 사항은 다음 업데이트 때 그냥 덮어써집니다. 마음에 들지 않는 기본값은 차라리 `~/.config/*` 폴더에서 덮어쓰는 편이 낫습니다.

그런 방식으로 기본 키 바인딩을 포함해 거의 모든 것을 바꿀 수 있습니다. 예를 들어 [Obsidian](https://obsidian.md/)을 [Joplin](https://joplinapp.org/)으로 바꾸려면 `~/.config/hypr/bindings.lua`를 편집하기만 하면 됩니다 (`omarchy-pkg-add joplin-bin`으로 설치):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind`는 대체 항목을 추가하기 전에 기존 바인딩을 제거합니다. 실행 도우미와 바인딩 옵션을 포함해 `o.bind`와 같은 인수를 받습니다. 바인딩을 추가하려면 `o.bind`를 사용하고, 대체하지 않고 제거하려면 `hl.unbind`를 사용하세요.

그래도 내부 Omarchy 파일을 꼭 손대고 싶다면 _Update > Channel > Dev_를 통해 dev 채널로 전환하세요. 그러면 Omarchy가 `~/omarchy`에 있는 소스 코드의 git 체크아웃에 연결되며, 마음껏 자유롭게 변경할 수 있습니다. 여기서 이래라저래라 할 사람은 아무도 없습니다!

### 변경 사항 되돌리기

설정을 엉망으로 만들었다면 Omarchy 메뉴의 _Update > Config_를 통해 언제든 기본값으로 되돌릴 수 있습니다. 또는 `omarchy reinstall configs`를 실행해 모든 것을 초기화할 수도 있습니다.
