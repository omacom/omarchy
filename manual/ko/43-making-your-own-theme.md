# 나만의 테마 만들기

`~/.config/omarchy/themes`에 나만의 테마를 추가할 수 있다. 기존 테마 중 하나를 복사해 베이스로 삼고(`/usr/share/omarchy/themes`를 보라), 마음껏 수정하면 된다. 테마가 그 폴더 안에 있는 한, 테마 선택 메뉴에 포함된다.

주로 손봐야 할 파일은 `colors.toml`이다. 거기서 정의한 색상 세트를 이용해 터미널(Foot/Alacritty/Ghostty/Kitty), btop, Chromium, Hyprland, Neovim, Helix, VSCode, Obsidian, Qt 앱, 키보드 백라이트, 입력기, 화면 공유 선택기, 앱 아이콘, 여러 AI 도구(Claude, Pi, Hermes, T3 Code, Herdr), 그리고 Omarchy 셸 전체(상단 바, 메뉴, 알림, OSD, 잠금 화면)의 설정을 생성한다.

포함된 Aether 애플리케이션을 사용해 멋진 GUI 인터페이스로 색상을 가지고 놀고 배경을 검색하며 새 테마를 만들 수도 있다. `Super + Alt + Space`에서 앱 그리드를 열어 실행하기만 하면 된다.

### 설치된 테마에 포함될 수 있는 것

직접 `~/.config/omarchy/themes`에 작성한 테마에는 원하는 것은 무엇이든 넣을 수 있다 — 네 컴퓨터이고 네 파일이니까, Omarchy는 그 전부를 적용한다.

`omarchy theme install`로 다른 사람의 저장소에서 설치한 테마는 색상에 관한 것은 모두 유지하지만, 컴퓨터에서 코드를 실행하게 되는 몇 안 되는 파일은 잃는다: 모든 `.lua` 파일, 터미널 설정(`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`), 그리고 `vscode.json`이 그 대상이다. 테마의 `hyprland.lua`는 로그인할 때 컴포지터가 실행하는 Lua이고, 터미널 설정은 터미널이 시작할 프로그램을 지정하며, `vscode.json`은 설치할 VSCode 확장을 지정한다. 다른 사람의 테마를 설치하는 일은 데스크톱이 실행하는 것을 바꿔서는 안 되고, 보이는 모습만 바꿔야 한다.

나머지는 모두 테마 작성자가 작성한 그대로 작동한다 — `btop.theme`, `chromium.theme`, `helix.toml`, `shell.toml`, 배경과 미리보기는 모두 유지된다. 삭제된 것만 네 컴퓨터에서 `colors.toml`을 바탕으로 다시 생성된다.

Omarchy는 테마 안에 자체 git 저장소가 있는지를 보고 둘을 구별하는데, 이는 `omarchy theme install`이 클론할 때 남기는 것이다. 그래서 직접 작성한 테마는 온전히 네 것으로 남고, 인터넷에서 가져온 테마는 색상만 남는다.

### 라이트 모드

라이트 모드 테마를 만들고 있다면, `colors.toml` 맨 위에 `mode = "light"`를 설정하라. 그러면 모든 앱에서 자동으로 라이트 모드와 함께 적용된다. (테마 루트에 `light.mode`라는 빈 파일을 두는 옛 방식도 여전히 작동한다.)

### 잠금 해제 이미지

`unlock.png`와 `preview-unlock.png` 이미지가 포함된 테마는 _모양 > 잠금 해제_ 아래에 표시된다. `unlock.png`는 가급적 투명한 png여야 한다. 그리고 `omarchy plymouth preview`를 사용해 미리보기 이미지를 만들 수 있다.

### Omarchy가 지원하지 않는 앱에 테마 적용하기

목록에 없는 앱을 사용한다면, 템플릿으로 Omarchy가 그 앱에 테마를 적용하도록 직접 가르칠 수 있다. `~/.config/omarchy/themed/`에 생성할 설정 파일 이름에 `.tpl` 확장자를 붙인 파일을 넣고, `{{ background }}`, `{{ foreground }}`, `{{ accent }}`, `{{ red }}`, `{{ color0 }}`부터 `{{ color15 }}`까지, 그리고 나머지 팔레트를 자리 표시자로 사용해 설정을 작성하라. 테마를 전환할 때마다 그 테마의 색상으로 파일이 다시 생성된다.

그 폴더에는 주석이 충실히 달린 `alacritty.toml.tpl.sample`이 있어 복사해 쓸 수 있다 — 사용할 수 있는 모든 변수와 함께, `#` 없이 색상을 원하거나 10진수 RGB로 색상을 원하는 앱을 위한 `_strip` 및 `_rgb` 수정자도 나열되어 있다. 네 템플릿이 Omarchy 기본 템플릿보다 우선하므로, 기본 제공 앱에 테마가 적용되는 방식을 재정의하는 데에도 사용할 수 있다.

### 테마 배포하기

다른 사람들이 사용할 수 있도록 테마를 배포하고 싶다면, GitHub 같은 공개 git 서버에 올려야 한다. 그러면 사람들이 Omarchy 메뉴의 _설치 > 스타일 > 테마_에서 그 URL을 사용해 설치할 수 있다. `omarchy-[themename]-theme`라는 이름 규칙을 따르는 것이 좋다. 그래야 설치 후 테마 선택 메뉴에 테마가 `[themename]`으로만 올바르게 표시된다.

그 남은 `[themename]`이 테마의 디렉터리 이름이 되므로, Omarchy가 안전하게 다룰 수 있는 이름이어야 한다: 문자, 숫자, 또는 밑줄로 시작해야 하고, 나머지는 문자, 숫자, `.`, `_`, `+`, `-`를 포함할 수 있다. 대문자는 소문자로 변환되지만, 그 외의 것 — 공백, 따옴표, 영어가 아닌 문자 — 은 디렉터리 이름으로 변환되지 않고 설치 시 거부된다. 그래서 `omarchy-tokyo-night-theme`, `omarchy-flexoki_light-theme`, `omarchy-c++-theme`은 모두 문제없이 설치된다.

저장소에서 설치되고 나면 함께 제공된 모든 `.lua`, 터미널 설정 또는 `vscode.json`은 삭제된다는 점을 기억하라. 그러니 테마를 그런 것들을 중심으로 만들지 마라.

[추가 테마 페이지](https://omarchy.org/themes/)에 네 테마를 추가하려면 [omarchy-site 저장소](https://github.com/omacom-io/omarchy-site)에 pull request를 보내면 된다.
