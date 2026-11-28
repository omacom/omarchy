# 나만의 테마 만들기

`~/.config/omarchy/themes`에 나만의 테마를 추가할 수 있습니다. 기존 테마 중 하나를 복사해 베이스로 삼은 다음(`/usr/share/omarchy/themes`에서 확인하세요), 마음껏 수정하세요. 테마가 그 폴더 안에 있기만 하면 테마 선택 메뉴에 포함됩니다.

수정해야 할 주요 파일은 `colors.toml`입니다. 이 파일은 터미널(Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt 앱, 키보드 백라이트, 입력 방식, 화면 공유 선택기, 앱 아이콘, 여러 AI 도구(Claude, Pi, Hermes, T3 Code, Herdr), 그리고 Omarchy 셸 전체(상단 바, 메뉴, 알림, OSD, 잠금 화면)에 대한 구성을 생성하는 데 사용되는 색상 세트를 정의합니다.

포함된 Aether 애플리케이션을 사용해 색상을 가지고 놀고 배경을 검색할 수 있는 멋진 GUI 인터페이스로 새 테마를 만들 수도 있습니다. `Super + Alt + Space`로 앱 그리드에서 실행하기만 하면 됩니다.

### 설치된 테마에 포함될 수 있는 것

`~/.config/omarchy/themes`에 직접 작성한 테마에는 원하는 것은 무엇이든 넣을 수 있습니다. 당신의 컴퓨터이고 당신의 파일이며, Omarchy는 그 전부를 적용합니다.

`omarchy theme install`로 다른 사람의 저장소에서 설치한 테마는 색상에 관한 모든 것은 유지하고, 컴퓨터에서 코드를 실행하게 되는 몇 안 되는 파일은 잃습니다. 모든 `.lua` 파일, 터미널 구성(`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), 그리고 `vscode.json`이 여기에 해당합니다. 테마의 `hyprland.lua`는 로그인 시 컴포지터가 실행하는 Lua이고, 터미널 구성은 터미널이 시작할 프로그램을 지정하며, `vscode.json`은 설치할 VSCode 확장을 지정합니다. 다른 사람의 테마를 설치하는 것은 데스크톱의 실행 대상이 아니라 모양을 바꿔야 합니다.

그 밖의 모든 것은 테마 작성자가 작성한 그대로 작동합니다. `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, 배경과 미리 보기는 모두 유지됩니다. 삭제된 것만 당신의 컴퓨터에서 `colors.toml`로부터 다시 생성됩니다.

Omarchy는 테마 내부에 자체 git 저장소가 있는지를 기준으로 둘을 구별하는데, 이는 `omarchy theme install`이 클론할 때 남기는 것입니다. 따라서 직접 작성한 테마는 당신의 것으로 남고, 인터넷에서 가져온 테마는 색상으로만 남습니다.

### 라이트 모드

라이트 모드 테마를 만드는 경우, `colors.toml` 상단에 `mode = "light"`를 설정하세요. 그러면 모든 앱에 대해 라이트 모드와 자동으로 짝을 이룹니다. (테마 루트에 `light.mode`라는 빈 파일을 넣는 옛 방식도 여전히 작동합니다.)

### 부팅 및 로그인 화면

부팅 시 드라이브 비밀번호를 묻는 화면과 로그인 화면은 테마의 `background` 위에 `accent` 색상으로 Omarchy 로고를 그리고, 비밀번호 필드는 `foreground`로, 잘못된 비밀번호는 `red`로 표시합니다. 이들을 위해 추가로 제공할 것은 없습니다. Omarchy는 더 이상 테마의 `unlock.png`나 `preview-unlock.png`를 사용하지 않습니다. Apple Silicon Mac에서는 드라이브 비밀번호 화면이 테마와 관계없이 Omarchy의 기본 모양을 유지합니다.

### Omarchy가 다루지 않는 앱에 테마 적용하기

그 목록에 없는 앱을 사용하는 경우, 템플릿을 이용해 Omarchy가 해당 앱에 테마를 적용하도록 직접 가르칠 수 있습니다. `~/.config/omarchy/themed/`에 생성할 구성의 이름에 `.tpl` 확장자를 붙인 이름으로 파일을 넣고, `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`부터 `{{ color15 }}`까지, 그리고 나머지 팔레트를 플레이스홀더로 사용해 구성을 작성하세요. 테마를 전환할 때마다 파일은 해당 테마의 색상으로 다시 생성됩니다.

그 폴더에는 복사해서 사용할 수 있는 주석이 충분히 달린 `alacritty.toml.tpl.sample`이 있습니다. 사용할 수 있는 모든 변수와, `#` 없이 색상을 원하거나 십진 RGB로 색상을 원하는 앱을 위한 `_strip` 및 `_rgb` 수정자가 나열되어 있습니다. 당신의 템플릿은 Omarchy 자체 템플릿보다 우선하므로, 이를 사용해 기본 앱에 테마가 적용되는 방식을 재정의할 수도 있습니다.

### 테마 배포하기

다른 사람들이 사용할 수 있도록 테마를 배포하려면 GitHub 같은 공개 git 서버에 올려야 합니다. 그러면 사람들이 그 URL을 사용해 Omarchy 메뉴의 _설치 > 스타일 > 테마_에서 설치할 수 있습니다. 테마가 설치 후 테마 선택 메뉴에 `[themename]`으로만 올바르게 표시되도록 `omarchy-[themename]-theme`라는 명명 규칙을 따르는 것이 좋습니다.

남은 `[themename]`은 테마의 디렉터리 이름이 되므로, Omarchy가 안전하게 전달할 수 있는 이름이어야 합니다. 문자, 숫자 또는 밑줄로 시작해야 하며, 나머지는 문자, 숫자, `.`, `_`, `+`, `-`를 포함할 수 있습니다. 대문자는 소문자로 변환되지만, 공백, 따옴표, 영어가 아닌 문자 등 그 밖의 문자는 디렉터리 이름으로 변환되지 않고 설치 시 거부됩니다. 따라서 `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, `omarchy-c++-theme`은 모두 문제없이 설치됩니다.

저장소에서 설치된 뒤에는 테마가 제공하는 모든 `.lua`, 터미널 구성 또는 `vscode.json`이 삭제되므로, 테마를 그런 것들을 중심으로 만들지 마세요.

[omarchy-site 저장소](https://github.com/omacom-io/omarchy-site)에 풀 리퀘스트를 보내면 당신의 테마를 [추가 테마 페이지](https://omarchy.org/themes/)에 추가할 수 있습니다.
