# 나만의 테마 만들기

`~/.config/omarchy/themes`에 직접 테마를 추가할 수 있다. 기존 테마 중 하나를 복사해 베이스로 삼은 뒤(`/usr/share/omarchy/themes`를 보라), 마음껏 손보면 된다. 테마가 그 폴더 안에 있기만 하면 테마 선택 메뉴에 포함된다.

주로 손봐야 할 파일은 `colors.toml`이다. 이 파일이 색상 세트를 정의하고, 그 색상 세트를 이용해 터미널(Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, 그리고 Omarchy 셸 전체(상단 바, 메뉴, 알림, OSD, 잠금 화면)의 설정이 생성된다.

포함된 Aether 애플리케이션을 이용해 색상을 가지고 놀고 배경을 찾을 수 있는 멋진 GUI 인터페이스로 새 테마를 만들 수도 있다. `Super + Alt + Space`의 앱 그리드에서 실행하면 된다.

### 설치된 테마에 들어갈 수 있는 것

`~/.config/omarchy/themes`에 직접 쓰는 테마에는 무엇이든 넣을 수 있다 — 내 컴퓨터, 내 파일이니 Omarchy가 전부 적용한다.

`omarchy theme install`로 다른 사람의 repo에서 설치한 테마는 색상에 관한 것은 모두 유지하지만, 내 컴퓨터에서 코드를 실행하게 되는 소수의 파일은 잃는다: 모든 `.lua` 파일, 터미널 설정(`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), 그리고 `vscode.json`이다. 테마의 `hyprland.lua`는 컴포지터가 로그인 때 실행하는 Lua이고, 터미널 설정은 터미널이 시작할 프로그램을 지정하며, `vscode.json`은 설치할 VSCode 확장을 지정한다. 다른 사람의 테마를 설치하면 데스크톱의 모습이 바뀌어야지, 데스크톱이 실행하는 것이 바뀌어서는 안 된다.

그 외의 모든 것은 테마 작성자가 작성한 그대로 동작한다 — `btop.theme`, `chromium.theme`, `helix.toml`, `icons.theme`, `shell.toml`, 배경과 미리보기는 모두 유지된다. 버려진 것만 내 컴퓨터에서 `colors.toml`을 이용해 다시 생성된다.

Omarchy는 테마 안에 자체 git repo가 있는지로 둘을 구분하는데, 이는 `omarchy theme install`이 clone할 때 남기는 것이다. 그래서 직접 쓴 테마는 내 것으로 남고, 인터넷에서 가져온 테마는 색상으로만 남는다.

### 라이트 모드

라이트 모드 테마를 만든다면 `colors.toml` 맨 위에 `mode = "light"`라고 설정하라. 그러면 모든 앱에서 자동으로 라이트 모드와 짝을 이룬다. (테마 루트에 `light.mode`라는 빈 파일을 넣는 옛 방식도 여전히 동작한다.)

### 아이콘 색상

파일 관리자 아이콘의 색상을 테마에 맞추고 싶다면, 사용하고 싶은 아이콘 세트의 이름을 담은 `icons.theme`라는 파일을 추가하라. 기본적으로 옵션은 다음과 같다: `Yaru Yaru-blue Yaru-dark Yaru-magenta Yaru-olive Yaru-prussiangreen Yaru-purple Yaru-red Yaru-sage Yaru-wartybrown Yaru-yellow`.

### 잠금 해제 이미지

`unlock.png`와 `preview-unlock.png` 이미지가 함께 제공되는 테마는 _모양 > 잠금 해제_ 아래에 나열된다. `unlock.png`는 투명한 png인 것이 바람직하다. 그리고 `omarchy plymouth preview`를 이용해 미리보기 이미지를 만들 수 있다.

### Omarchy가 다루지 않는 앱 테마 적용하기

그 목록에 없는 앱을 사용한다면, 템플릿으로 Omarchy가 그 앱에 테마를 적용하도록 가르칠 수 있다. `~/.config/omarchy/themed/`에 생성할 설정 파일의 이름에 `.tpl` 확장자를 붙인 이름으로 파일을 넣고, `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`부터 `{{ color15 }}`까지, 그리고 나머지 팔레트를 플레이스홀더로 사용해 설정을 작성하라. 테마를 바꿀 때마다 그 테마의 색상으로 파일이 다시 생성된다.

그 폴더에는 복사해 쓸 수 있는, 주석이 충실히 달린 `alacritty.toml.tpl.sample`이 있다 — 사용할 수 있는 모든 변수가 나열되어 있고, `#` 없는 색상이나 십진 RGB 색상을 원하는 앱을 위한 `_strip`와 `_rgb` 수정자도 들어 있다. 내 템플릿이 Omarchy 자체 템플릿보다 우선하므로, 기본 앱에 테마가 적용되는 방식을 재정의하는 데도 이를 사용할 수 있다.

### 테마 배포하기

다른 사람들도 쓸 수 있도록 테마를 배포하고 싶다면 GitHub 같은 공개 git 서버에 올려야 한다. 그러면 사람들이 그 URL을 이용해 Omarchy 메뉴의 _설치 > 스타일 > 테마_에서 설치할 수 있다. 테마 이름은 `omarchy-[themename]-theme`라는 명명 규칙을 따르는 것이 좋다. 그래야 설치 후 테마 선택 메뉴에 테마가 올바르게 `[themename]`으로만 표시된다.

남은 `[themename]`이 테마의 디렉터리 이름이 되므로, Omarchy가 안전하게 주고받을 수 있는 이름이어야 한다: 문자, 숫자, 또는 밑줄로 시작해야 하고, 나머지에는 문자, 숫자, `.`, `_`, `+`, `-`가 들어갈 수 있다. 대문자는 소문자로 변환해 주지만, 그 외의 것 — 공백, 따옴표, 영어가 아닌 문자 — 은 디렉터리 이름으로 바뀌는 대신 설치 시점에 거부된다. 그래서 `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, `omarchy-c++-theme`은 모두 문제없이 설치된다.

repo에서 설치된 뒤에는 테마가 함께 제공하는 모든 `.lua`, 터미널 설정, `vscode.json`이 버려진다는 점을 기억하라. 그러니 테마를 그런 것들을 중심으로 만들지 마라.

[omarchy-site repo](https://github.com/omacom-io/omarchy-site)에 pull request를 보내면 내 테마를 [추가 테마 페이지](https://omarchy.org/themes/)에 추가할 수 있다.
