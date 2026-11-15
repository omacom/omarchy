# 테마

Omarchy에는 아름다운 테마 스물두 가지가 함께 제공됩니다. Omarchy Menu(`Super + Space`)에서 _모양 > 테마_를 통해 선택하거나, `Super + Ctrl + T`를 사용해 테마 선택 화면으로 바로 이동할 수 있습니다.

각 테마는 데스크톱, 터미널, neovim, 활동 화면(btop), Chromium, 그리고 상단 바, 메뉴, 알림, OSD, 잠금 화면을 포함한 전체 Omarchy 셸의 스타일을 지정합니다. (Obsidian의 경우 앱 내부에서 _모양 > 테마_를 통해 Omarchy 테마를 수동으로 선택해야 합니다.)

테마마다 배경 이미지 세트가 있으며, `Super + Ctrl + W`를 사용해 그중에서 선택할 수 있습니다.

[추가 테마 페이지](https://omarchy.org/themes/)에서 더 많은 테마를 찾거나, 심지어 [나만의 테마를 만들](43-making-your-own-theme.md) 수도 있습니다.

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

### 앱 아이콘

앱 런처와 독의 아이콘은 사용 중인 테마의 색상으로 그려지므로, 테마와 함께 바뀝니다. 아이콘은 아이콘 세트에서 가져오며, 테마와는 별도로 _모양 > 아이콘_에서 선택합니다:

- _Papercraft_가 기본값입니다: 설치된 모든 것이 하나의 스타일로 그려집니다. Chrome, HEY, YouTube처럼 로고로 알려진 앱은 형태를 유지하고 테마의 색상을 입습니다.
- _Arcade_는 같은 앱들을 오래된 게임 콘솔처럼 8비트 픽셀 아트로 그립니다.
- _Original_은 모든 앱을 제작자가 제공한 아이콘으로 표시합니다.

다른 사람이 만든 아이콘 세트는 _설치 > 스타일 > 아이콘_(또는 `omarchy icons install <git url>`)으로 설치할 수 있고, _제거 > 아이콘_에서 다시 제거할 수 있습니다. _업데이트 > 추가 아이콘_은 설치한 세트의 최신 버전을 가져옵니다.

직접 만들려면 아이콘을 `~/.config/omarchy/icons/<name>/`에 앱당 파일 하나씩 넣고, 앱의 `.desktop` 파일에 있는 `Icon=` 줄을 따서 이름을 지정하세요. `.svg`로 끝나는 파일은 그대로 표시됩니다. `.svg.tpl`로 끝나는 파일은 테마의 색상으로 그려집니다: 색상이 들어갈 위치에 `{{ icon_main }}`, `{{ icon_mark }}`, `{{ icon_paper }}`, `{{ icon_body }}`, `{{ icon_edge }}`, `{{ icon_ink }}` 또는 `{{ icon_shadow }}`를 쓰세요. `/usr/share/omarchy/icons/papercraft/`에 있는 기본 세트에서 시작하는 것이 좋습니다. 기본 세트의 아이콘 하나를 바꾸려면, 만든 버전을 `~/.config/omarchy/icons/papercraft/`에 넣으세요.

### 잠금 해제

테마에는 부팅 복호화 과정에 사용되는 맞춤형 잠금 해제 디자인도 있을 수 있습니다. _모양 > 잠금 해제_에서 하나를 선택할 수 있습니다. 다음과 같이 생겼습니다:

 ![catppuccin](../themes/catppuccin/preview-unlock.png)
_Catppuccin_

 ![catppuccin-latte](../themes/catppuccin-latte/preview-unlock.png)
_Catppuccin Latte_

 ![ethereal](../themes/ethereal/preview-unlock.png)
_Ethereal_

 ![everforest](../themes/everforest/preview-unlock.png)
_Everforest_

 ![flexoki-light](../themes/flexoki-light/preview-unlock.png)
_Flexoki Light_

 ![gruvbox](../themes/gruvbox/preview-unlock.png)
_Gruvbox_

 ![hackerman](../themes/hackerman/preview-unlock.png)
_Hackerman_

 ![jade-horse](../themes/jade-horse/preview-unlock.png)
_Jade Horse_

 ![kanagawa](../themes/kanagawa/preview-unlock.png)
_Kanagawa_

 ![lumon](../themes/lumon/preview-unlock.png)
_Lumon_

 ![matte-black](../themes/matte-black/preview-unlock.png)
_Matte Black_

![miasma](../themes/miasma/preview-unlock.png)
_Miasma_

 ![nord](../themes/nord/preview-unlock.png)
_Nord_

 ![retro-82](../themes/retro-82/preview-unlock.png)
_Retro 82_

 ![ristretto](../themes/ristretto/preview-unlock.png)
_Ristretto_

![rose-pine](../themes/rose-pine/preview-unlock.png)
_Rose Pine_

 ![tokyo-night](../themes/tokyo-night/preview-unlock.png)
_Tokyo Night_

 ![vantablack](../themes/vantablack/preview-unlock.png)
_Vantablack_

 ![white](../themes/white/preview-unlock.png)
_White_
