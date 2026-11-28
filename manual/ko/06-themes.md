# 테마

Omarchy에는 아름다운 테마가 스물세 개 기본으로 들어 있다. Omarchy Menu(`Super + Space`)에서 _Appearance > Theme_을 통해 테마를 고르거나, `Super + Ctrl + T`로 테마 선택 화면으로 바로 이동할 수 있다.

각 테마는 데스크톱, 터미널, neovim, 활동 화면(btop), 브라우저(Chrome, Chromium, Edge 또는 Brave), 그리고 상단 바, 메뉴, 알림, OSD, 잠금 화면을 아우르는 Omarchy 셸 전체의 스타일을 바꾼다. (Obsidian에서는 앱 안의 _Appearance > Themes_에서 Omarchy 테마를 직접 선택해야 한다).

테마마다 배경 이미지 세트가 들어 있으며, `Super + Ctrl + W`로 그중에서 고를 수 있다.

[추가 테마 페이지](https://omarchy.org/themes/)에서 더 많은 테마를 찾거나, [직접 테마를 만들](43-making-your-own-theme.md) 수도 있다.

 ![tokyo-night](../themes/tokyo-night/preview.png)
_Tokyo Night_

 ![catppuccin](../themes/catppuccin/preview.png)
_Catppuccin_

 ![lumon](../themes/lumon/preview.png)
_Lumon_

 ![ethereal](../themes/ethereal/preview.png)
_Ethereal_

 ![everforest](../themes/everforest/preview.png)
_Everforest_

 ![gruvbox](../themes/gruvbox/preview.png)
_Gruvbox_

 ![miasma](../themes/miasma/preview.png)
_Miasma_

 ![hackerman](../themes/hackerman/preview.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview.png)
_Kanagawa_

 ![nord](../themes/nord/preview.png)
_Nord_

 ![matte-black](../themes/matte-black/preview.png)
_Matte Black_

 ![vantablack](../themes/vantablack/preview.png)
_Vantablack_

 ![ristretto](../themes/ristretto/preview.png)
_Ristretto_

 ![retro-82](../themes/retro-82/preview.png)
_Retro 82_

 ![flexoki-light](../themes/flexoki-light/preview.png)
_Flexoki Light_

 ![rose-pine](../themes/rose-pine/preview.png)
_Rose Pine_

 ![catppuccin-latte](../themes/catppuccin-latte/preview.png)
_Catppuccin Latte_

 ![white](../themes/white/preview.png)
_White_

 ![last-horizon](../themes/last-horizon/preview.png)
_Last Horizon_

 ![lupine](../themes/lupine/preview.png)
_Lupine_

 ![solitude](../themes/solitude/preview.png)
_Solitude_

 ![starship](../themes/starship/preview.png)
_Starship_

### App icons

앱 실행기와 독에 있는 아이콘은 테마 색상으로 그려지므로 테마와 함께 바뀐다. 아이콘은 아이콘 세트에서 가져오며, 테마와 별도로 _Appearance > Icons_에서 각 세트의 미리보기를 보고 테마를 고르는 것과 같은 방식으로 선택한다:

- _Papercraft_가 기본값이다: 설치된 모든 것이 하나의 스타일로 그려진다. Chrome, HEY, YouTube처럼 로고로 알려진 앱은 형태를 유지한 채 테마 색상을 입는다.
- _Arcade_는 같은 앱들을 옛날 게임 콘솔처럼 8비트 픽셀 아트로 그린다.
- _Original_은 모든 앱을 만든 사람이 제공한 아이콘 그대로 보여준다.

다른 사람이 만든 아이콘 세트는 _Install > Style > Icons_ (또는 `omarchy icons install <git url>`)로 설치할 수 있고, _Remove > Icons_에서 다시 제거할 수 있다. _Update > Extra Icons_는 설치한 세트의 최신 버전을 가져온다.

직접 만들려면 아이콘을 `~/.config/omarchy/icons/<name>/`에 넣되, 앱당 파일 하나씩, 앱의 `.desktop` 파일에 있는 `Icon=` 줄을 따서 이름을 붙인다. `.svg`로 끝나는 파일은 있는 그대로 표시된다. `.svg.tpl`로 끝나는 파일은 테마 색상으로 그려진다: 색상이 들어갈 자리에 `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` 또는 `{{ icon_shadow }}`를 쓰면 된다. `/usr/share/omarchy/icons/papercraft/`에 있는 기본 세트에서 출발하는 것이 좋다. `preview.png`를 추가하면 선택 화면에 내 세트가 표시된다; 없으면 Omarchy가 아이콘으로 미리보기를 그린다. 기본 세트의 아이콘 하나만 바꾸려면 내 버전을 `~/.config/omarchy/icons/papercraft/`에 넣으면 된다.

### 부팅과 로그인

컴퓨터가 시작될 때 드라이브 암호를 묻는 화면과 로그인 화면도 테마를 따른다. 테마를 바꿀 때마다 배경, 텍스트, 강조, 빨간색을 테마에서 가져오므로 따로 고를 잠금 해제 디자인이 없다. Apple Silicon Mac에서는 드라이브 암호 화면이 어떤 테마에서든 Omarchy의 기본 모습을 유지한다.
