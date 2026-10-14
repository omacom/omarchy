# 직접 테마 만들기

`~/.config/omarchy/themes`에 직접 테마를 추가할 수 있습니다. 기존 테마 중 하나를 기반으로 복사한 뒤(`/usr/share/omarchy/themes`를 보세요) 마음껏 조정하세요. 테마가 그 폴더 안에 있는 한 테마 선택 메뉴에 포함됩니다.

주로 조정해야 하는 파일은 `colors.toml`입니다. 이 파일이 색상 집합을 정의하고, 그 색상은 터미널(Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, 그리고 전체 Omarchy 셸(상단 막대, 메뉴, 알림, OSD, 잠금 화면)용 설정을 생성하는 데 쓰입니다.

함께 제공되는 Aether 애플리케이션을 사용해 사랑스러운 GUI 인터페이스로 색상을 가지고 놀고 배경을 검색하며 새 테마를 만들 수도 있습니다. `Super + Alt + Space`의 앱 그리드에서 실행하세요.

### 설치된 테마에 들어갈 수 있는 것

`~/.config/omarchy/themes`에 직접 쓴 테마에는 원하는 무엇이든 들어갈 수 있습니다 — 자기 컴퓨터이고 자기 파일이며, Omarchy는 그 전부를 적용합니다.

`omarchy theme install`로 다른 사람의 저장소에서 설치한 테마는 색상인 것은 모두 유지하고, 컴퓨터에서 코드를 실행하게 될 몇 가지 파일을 잃습니다: 모든 `.lua` 파일, 터미널 설정(`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), 그리고 `vscode.json`입니다. 테마의 `hyprland.lua`는 로그인할 때 컴포지터가 실행하는 Lua이고, 터미널 설정은 터미널이 시작할 프로그램을 이름 짓고, `vscode.json`은 설치할 VSCode 확장을 이름 짓습니다. 다른 사람의 테마를 설치하는 것은 데스크톱의 모습만 바꿔야 하며, 실행되는 것을 바꿔서는 안 됩니다.

그 외의 것은 전부 테마 작성자가 쓴 대로 정확히 작동합니다 — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, 배경과 미리 보기는 모두 유지됩니다. 버려진 것만 자기 컴퓨터에서 `colors.toml`로 다시 생성됩니다.

Omarchy는 테마 안에 자체 git 저장소가 있는지로 둘을 구분합니다. 이는 `omarchy theme install`이 복제(clone)할 때 남기는 것입니다. 그래서 직접 쓴 테마는 자기 것으로 남고, 인터넷에서 가져온 테마는 색상으로 남습니다.

### 밝은 모드

밝은 모드 테마를 만들고 있다면 `colors.toml` 맨 위에 `mode = "light"`를 설정하세요. 그러면 모든 앱에 자동으로 밝은 모드와 짝을 이룹니다. (테마 루트에 `light.mode`라는 빈 파일을 넣어 두는 옛날 방식도 여전히 작동합니다.)

### 아이콘 색상

파일 관리자 아이콘 색상을 테마와 맞추고 싶다면, 사용하려는 아이콘 세트의 이름을 담은 `icons.theme`라는 파일을 추가하세요. 기본으로 제공되는 옵션은 `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`입니다.

### 잠금 해제 이미지

`unlock.png`와 `preview-unlock.png` 이미지와 함께 제공되는 테마는 _스타일 > 잠금 해제_ 아래에 표시됩니다. `unlock.png`는 투명한 png인 것이 좋습니다. 그리고 `omarchy plymouth preview`를 사용해 미리 보기 이미지를 만들 수 있습니다.

### Omarchy가 다루지 않는 앱 테마 적용하기

목록에 없는 앱을 사용한다면 템플릿을 사용해 Omarchy가 직접 그 앱을 테마 적용하게 가르칠 수 있습니다. `~/.config/omarchy/themed/`에 생성되는 설정 이름에 `.tpl` 확장자를 붙인 파일을 넣고, `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`부터 `{{ color15 }}`까지, 그리고 팔레트의 나머지를 자리 표시자로 사용해 설정을 작성하세요. 테마를 전환할 때마다 파일은 해당 테마의 색상으로 다시 생성됩니다.

그 폴더에는 복사해 쓸 수 있는, 주석이 충실히 달린 `alacritty.toml.tpl.sample`이 있습니다 — 사용할 수 있는 모든 변수와, `#` 없이 색상을 원하거나 십진수 RGB로 색상을 원하는 앱을 위한 `_strip`과 `_rgb` 한정자가 나열되어 있습니다. 직접 만든 템플릿은 Omarchy 자체 템플릿보다 우선하므로, 이를 사용해 내장 앱의 테마 적용 방식을 덮어쓸 수도 있습니다.

### 테마 배포하기

다른 사람도 쓸 수 있도록 테마를 배포하고 싶다면 GitHub 같은 공개 git 서버에 올려야 합니다. 그러면 사람들은 그 URL을 사용해 Omarchy 메뉴의 _설치 > 스타일 > 테마_로 설치할 수 있습니다. `omarchy-[themename]-theme`라는 이름 규칙을 따르는 것이 좋습니다. 설치 후 테마 선택 메뉴에 `[themename]`으로만 정확히 표시되기 때문입니다.

남은 `[themename]`은 테마의 디렉터리 이름이 되므로, Omarchy가 안전하게 넘겨줄 수 있는 이름이어야 합니다: 문자, 숫자, 또는 밑줄로 시작해야 하며, 나머지는 문자, 숫자, `.`, `_`, `+`, `-`를 담을 수 있습니다. 대문자는 소문자로 바꿔 주지만, 그 외의 것 — 공백, 따옴표, 영어가 아닌 문자 — 은 디렉터리 이름으로 바뀌는 대신 설치 시점에 거부됩니다. 그래서 `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, `omarchy-c++-theme`는 모두 문제없이 설치됩니다.

저장소에서 설치되고 나면 함께 제공되는 모든 `.lua`, 터미널 설정 또는 `vscode.json`은 버려지므로, 테마를 그것들을 중심으로 만들지 마세요.

[omarchy-site 저장소](https://github.com/omacom-io/omarchy-site)에 풀 리퀘스트를 보내면 [추가 테마 페이지](https://omarchy.org/themes/)에 테마를 추가할 수 있습니다.
