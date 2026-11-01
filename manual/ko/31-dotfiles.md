# 닷파일

Omarchy는 주로 `~/.config`에 있는 이른바 닷파일을 통해 설정합니다. 이 파일들은 당신이 변경할 수 있는 당신 소유의 파일로 간주됩니다. `/usr/share/omarchy`에 있는 파일은 Omarchy 자체에 속하므로 건드리지 않는 것이 좋습니다. `/usr/share/omarchy`의 무언가를 바꿔야 한다면, 대신 `~/.config`에서 그 값을 덮어써야 합니다.

주요 설정은 Omarchy 메뉴(`Super + Space`)에서 바로 편집할 수 있습니다. 예를 들어 _Setup > Keybindings_, _Setup > Input_, _Setup > Config > [file]_ 같은 항목입니다. 이런 방식으로 편집하면, 설정을 바꾼 뒤 재시작이 필요한 프로세스가 있으면 편집기를 종료한 후 자동으로 재시작됩니다(기본값은 Neovim — `:wq`를 기억하세요! — 하지만 _Setup > Defaults > Editor_에서 변경할 수 있습니다).

`~/.config`의 주요 파일 목록과 각 파일이 제어하는 항목은 다음과 같습니다:

| 파일 | 용도 |
| ----------------------- | --------------------- |
| `~/.config/hypr/hyprland.lua` | Hyprland의 메인 설정 파일입니다. Omarchy 기본값과 아래의 사용자 오버라이드 파일을 불러옵니다. [Hyprland 설정에 대해 자세히 알아보기](https://wiki.hypr.land/Configuring/). |
| `~/.config/hypr/bindings.lua` | 사용자 키 바인딩과 기본값에 대한 오버라이드입니다. |
| `~/.config/hypr/monitors.lua` | 회전, 추가 모드, 모니터 끄기처럼 모니터 패널에서 다루지 않는 모니터 설정입니다. |
| `~/.config/hypr/input.lua` | 키보드 레이아웃, 마우스, 트랙패드 설정을 제어합니다. |
| `~/.config/hypr/looknfeel.lua` | 간격, 테두리, 애니메이션, 그 외 외관 전반을 제어합니다. |
| `~/.config/hypr/autostart.lua` | 세션과 함께 시작되는 추가 프로세스를 제어합니다. |
| `~/.config/omarchy/shell.json` | 바 위치, 레이아웃, 위젯, 그리고 화면 보호기, 잠금, 유휴 시간 설정을 포함해 Omarchy 셸을 제어합니다. |
| `~/.config/foot/foot.ini` | 터미널을 제어합니다(foot가 기본값입니다). |
| `~/.XCompose` | 빠른 입력 이모지와 이름/이메일 자동 완성을 정의합니다. 변경한 후에는 반드시 `omarchy-restart-xcompose`를 실행하세요. |

자신만의 설정을 조정하느라 변경 사항이 많아졌다면, 이 닷파일들을 모두 백업해 두는 것이 좋습니다. [Stow는 그렇게 하기에 아주 좋은 방법입니다](https://www.youtube.com/watch?v=NoFiYOqnC4o).

### 세션과 함께 내 앱 시작하기

로그인할 때마다 무언가를 실행하고 싶다면 — 동기화 데몬, 채팅 앱, 직접 만든 스크립트 등 — `~/.config/hypr/autostart.lua`에 넣어 두세요:

```lua
o.launch_on_start("my-service")
```

그러면 해당 명령은 세션의 일부로 시작되므로, 다시 로그아웃할 때 깔끔하게 정리됩니다.

### 시스템 이벤트에서 스크립트 실행하기

Omarchy는 몇 가지 순간에 훅을 발생시키며, 여기에 나만의 스크립트를 걸어 둘 수 있습니다. 훅은 `~/.config/omarchy/hooks/<event>.d/`에 이벤트별 디렉터리 하나씩으로 위치하며, 그 안에 있는 실행 가능한 파일은 모두 해당 이벤트가 발생할 때 실행됩니다:

| 이벤트 | 실행 시점 |
| ----- | ------------ |
| `post-boot` | 데스크톱이 시작된 직후 |
| `post-update` | 패키지, 마이그레이션, 서비스 재시작이 끝난 뒤, mise 도구가 업데이트되기 전, `omarchy update`의 거의 마지막 단계 |
| `pre-refresh-pacman` | `omarchy refresh pacman`이 패키지 설정을 다시 동기화한 후, 패키지를 업데이트하기 전; 채널 전환 시에도 같은 새로고침 단계에서 실행됩니다 |
| `theme-set` | 테마가 변경된 후(테마 이름은 `$1`) |
| `font-set` | 글꼴이 변경된 후(글꼴 이름은 `$1`) |
| `battery-low` | 배터리가 부족할 때(백분율은 `$1`) |

`pre-refresh-pacman` 훅은 패키지 트랜잭션이 실행되기 전에 실행되므로, 사용자 지정 리포지토리나 `IgnorePkg` 줄은 여기에 넣어 두는 것이 좋습니다. 두 업데이트 관련 훅은 모두 Omarchy가 캐시된 sudo 인증을 지운 뒤 사용자 권한으로 실행되므로, `sudo`를 사용하는 훅은 자체 인증이 필요하며 비밀번호를 묻는 메시지가 표시될 수 있습니다.

각 디렉터리에는 훅의 형태를 보여 주는 `.sample` 파일이 이미 들어 있습니다 — 이름에서 `.sample`을 제거하면 바로 사용할 수 있습니다. 다른 곳에서 작성한 스크립트를 설치하려면 `omarchy hook install post-boot ~/my-hook`를 사용하세요. 스크립트를 복사해 넣고 실행 가능하게 만들어 줍니다.

### 내 메뉴 항목 추가하기

Omarchy 메뉴(`Super + Space`)는 `~/.config/omarchy/extensions/omarchy-menu.jsonc`를 편집해 나만의 행으로 확장할 수 있습니다. 항목은 점으로 구분된 id를 키로 사용하며, 이 id가 트리에서 항목의 위치를 결정합니다. 따라서 `personal`은 루트 메뉴에 표시되고 `personal.notes`는 그 안에 표시됩니다:

```jsonc
"personal": {"icon":"","label":"Personal"},
"personal.notes": {"icon":"󰎞","label":"Notes","action":"omarchy-launch-editor ~/notes"},
```

기존 id를 재사용하면 새 항목을 추가하는 대신 해당 행을 덮어씁니다. 이 파일에는 사용할 수 있는 모든 필드가 주석으로 문서화되어 함께 제공됩니다.

### 내 셸 export, 함수, 별칭 추가하기

Omarchy에는 편리한 별칭과 유용한 함수가 많이 포함되어 있지만, 나만의 것을 추가하고 싶어지는 경우도 흔합니다. 별칭, 함수, export는 모두 `~/.bashrc`에 추가해야 합니다. 이 파일은 업데이트 시 덮어써지지 않습니다. Omarchy 기본값 중 바꾸고 싶은 것이 있다면 여기에 안전하게 추가할 수도 있습니다.

### 데스크톱용 환경 변수 설정하기

데스크톱 세션 export는 `~/.config/uwsm/env.d/`에 넣어야 합니다. 이 파일들은 데스크톱이 시작되기 전에 실행되므로, 셸 오류가 발생하면 로그인 화면으로 되돌아갈 수 있습니다. 편집하는 동안에는 작동 중인 터미널을 열어 두세요. 오버라이드를 비활성화하려면 `env.d` 밖으로 이동하세요. 변경 때문에 로그인이 안 될 경우 [로그인 복구](45-troubleshooting.md#my-password-is-accepted-but-i-return-to-the-login-screen)를 참조하세요.

### Omarchy 내부 파일 변경하기

솔직히 말해서, 이건 당신의 컴퓨터입니다. 원하는 대로 해도 되지만, `/usr/share/omarchy`에 있는 파일을 직접 변경하는 것은 권하지 않습니다. 이 파일들은 Omarchy pacman 패키지에 속하므로, 변경 내용은 다음 업데이트 때 그냥 덮어써집니다. 대신 마음에 들지 않는 기본값이 있다면 `~/.config/*` 폴더에서 덮어쓰는 편이 훨씬 낫습니다.

그런 방식으로 거의 모든 것을 바꿀 수 있습니다. 예를 들어 기본 키 바인딩도 마찬가지입니다. `~/.config/hypr/bindings.lua`를 편집해서, 가령 [Obsidian](https://obsidian.md/)을 [Joplin](https://joplinapp.org/)으로 교체해 보세요(`omarchy-pkg-add joplin-bin`으로 설치):

```lua
o.rebind("SUPER + SHIFT + O", "Joplin", "joplin-desktop")
```

`o.rebind`는 대체 바인딩을 추가하기 전에 기존 바인딩을 제거합니다. 실행 도우미와 바인딩 옵션을 포함해 `o.bind`와 같은 인수를 받습니다. 바인딩을 추가하려면 `o.bind`를, 대체 없이 삭제하려면 `hl.unbind`를 사용하세요.

그래도 내부 Omarchy 파일을 꼭 해킹하고 싶다면, _Update > Channel > Dev_를 통해 dev 채널로 전환하세요. 그러면 Omarchy가 `~/omarchy`에 있는 소스 코드의 git 체크아웃에 연결되며, 마음껏 변경할 수 있습니다. 여기서 당신에게 이래라저래라 할 사람은 아무도 없습니다!

### 변경 사항 초기화하기

설정을 엉망으로 만들었다면, Omarchy 메뉴의 _Update > Config_를 통해 언제든지 기본값으로 되돌릴 수 있습니다. 또는 `omarchy reinstall configs`를 실행해 모든 것을 초기화할 수도 있습니다.
