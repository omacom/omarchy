# 나만의 테마 만들기

`~/.config/omarchy/themes`에 나만의 테마를 추가할 수 있습니다. 기존 테마 중 하나를 복사해 베이스로 삼고(`/usr/share/omarchy/themes`에서 확인하세요), 마음껏 손보세요. 테마가 그 폴더 안에 있기만 하면 테마 선택 메뉴에 포함됩니다.

주로 손봐야 할 파일은 `colors.toml`입니다. 이 파일이 색상 세트를 정의하고, 이를 바탕으로 터미널(Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, 그리고 전체 Omarchy 셸(상단 바, 메뉴, 알림, OSD, 잠금 화면)의 설정이 생성됩니다.

포함된 Aether 애플리케이션을 사용해 멋진 GUI 인터페이스로 색상을 가지고 놀고 배경을 검색하며 새 테마를 만들 수도 있습니다. `Super + Alt + Space`의 앱 그리드에서 실행하세요.

### 설치된 테마에 포함될 수 있는 것

`~/.config/omarchy/themes`에 직접 작성한 테마에는 원하는 무엇이든 넣을 수 있습니다 — 여러분의 머신이고 여러분의 파일이니, Omarchy는 그 전부를 적용합니다.

`omarchy theme install`로 다른 사람의 저장소에서 설치한 테마는 색상에 관한 모든 것을 유지하고, 여러분의 머신에서 코드를 실행하게 되는 소수의 파일은 잃습니다: 모든 `.lua` 파일, 터미널 설정(`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), 그리고 `vscode.json`이 바로 그것들입니다. 테마의 `hyprland.lua`는 로그인 시 컴포지터가 실행하는 Lua이고, 터미널 설정은 터미널이 시작할 프로그램을 지정하며, `vscode.json`은 설치할 VSCode 확장을 지정합니다. 누군가의 테마를 설치하면 데스크톱의 모습이 바뀌어야지, 실행되는 것이 바뀌어서는 안 됩니다.

나머지는 모두 테마 작성자가 작성한 그대로 동작합니다 — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, 배경과 미리보기는 모두 유지됩니다. 제거된 것만 여러분의 머신에서 `colors.toml`을 바탕으로 다시 생성됩니다.

Omarchy는 테마 내부에 자체 git 저장소가 있는지를 보고 둘을 구분합니다. 이는 `omarchy theme install`이 클론할 때 남기는 것입니다. 그래서 직접 작성한 테마는 여러분의 것으로 남고, 인터넷에서 가져온 테마는 색상으로만 남습니다.

### 라이트 모드

라이트 모드 테마를 만든다면 `colors.toml` 맨 위에 `mode = "light"`를 설정하세요. 그러면 모든 앱에서 자동으로 라이트 모드와 짝을 이룹니다. (테마 루트에 `light.mode`라는 빈 파일을 넣는 옛 방식도 여전히 동작합니다.)

### 잠금 해제 이미지

`unlock.png`와 `preview-unlock.png` 이미지가 포함된 테마는 _모양 > 잠금 해제_ 아래에 표시됩니다. `unlock.png`는 투명 png인 것이 좋습니다. 그리고 `omarchy plymouth preview`를 사용해 미리보기 이미지를 만들 수 있습니다.

### Omarchy가 다루지 않는 앱에 테마 적용하기

그 목록에 없는 앱을 사용한다면 템플릿으로 Omarchy가 해당 앱에 테마를 적용하도록 직접 가르칠 수 있습니다. `~/.config/omarchy/themed/`에 생성할 설정 파일 이름에 `.tpl` 확장자를 붙인 파일을 넣고, `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`부터 `{{ color15 }}`까지, 그리고 나머지 팔레트를 플레이스홀더로 사용해 설정을 작성하세요. 테마를 전환할 때마다 파일이 해당 테마의 색상으로 다시 생성됩니다.

그 폴더에는 복사해서 쓸 수 있는, 주석이 충실히 달린 `alacritty.toml.tpl.sample`이 있습니다 — 사용할 수 있는 모든 변수는 물론, `#` 없는 색상이나 십진 RGB 색상을 원하는 앱을 위한 `_strip` 및 `_rgb` 수정자까지 나열되어 있습니다. 여러분의 템플릿이 Omarchy 자체 템플릿보다 우선하므로, 기본 앱에 테마가 적용되는 방식을 재정의하는 데도 사용할 수 있습니다.

### 테마 배포하기

테마를 배포해 다른 사람들이 사용할 수 있게 하려면 GitHub 같은 공개 git 서버에 올려야 합니다. 그러면 사람들이 그 URL을 사용해 Omarchy 메뉴의 _설치 > 스타일 > 테마_에서 설치할 수 있습니다. `omarchy-[themename]-theme`라는 명명 규칙을 따르는 것을 권장합니다. 그래야 설치 후 테마 선택 메뉴에 테마가 그냥 `[themename]`으로 올바르게 표시됩니다.

그렇게 남은 `[themename]`이 테마의 디렉터리 이름이 되므로, Omarchy가 안전하게 다룰 수 있는 이름이어야 합니다: 문자, 숫자 또는 밑줄로 시작해야 하고, 나머지는 문자, 숫자, `.`, `_`, `+`, `-`를 포함할 수 있습니다. 대문자는 자동으로 소문자로 변환되지만, 그 밖의 것 — 공백, 따옴표, 영어가 아닌 문자 — 은 디렉터리 이름으로 변환되지 않고 설치 시 거부됩니다. 따라서 `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, `omarchy-c++-theme`은 모두 문제없이 설치됩니다.

저장소에서 설치되면 함께 제공되는 모든 `.lua`, 터미널 설정 또는 `vscode.json`은 제거되므로, 테마를 그런 것들을 중심으로 만들지 마세요.

[omarchy-site 저장소](https://github.com/omacom-io/omarchy-site)에 pull request를 보내면 여러분의 테마를 [추가 테마 페이지](https://omarchy.org/themes/)에 추가할 수 있습니다.
