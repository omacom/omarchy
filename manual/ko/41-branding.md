# 브랜딩

Omarchy에서는 부팅 잠금 해제 화면, 화면 보호기, 정보 화면에 사용할 회사 로고나 개인 이미지를 설정할 수 있습니다.

### 부팅 잠금 해제

`omarchy plymouth preview`를 사용하면 사용자 지정 로고와 색상이 어떻게 보일지 미리 볼 수 있습니다. 배경색, 텍스트 색상, 로고 png, 그리고 미리보기 이미지의 경로를 인자로 받습니다:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

그런 다음 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`로 설정을 적용하면 SDDM 로그인 화면에도 같은 색상과 로고가 적용됩니다. 되돌리고 싶으면 `omarchy plymouth reset`을 사용하면 됩니다.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 화면 보호기

화면 보호기에 사용되는 로고는 _Appearance > Branding > Screensaver_에서 변경할 수 있습니다. ASCII 로고이므로 텍스트를 직접 편집할 수도 있지만, png나 svg 이미지를 건네면 ASCII로 변환해 드립니다. 꽤 멋지게 보입니다.

 ![branding-screensaver](images/branding-screensaver.webp)

그 메뉴에는 세 가지 항목이 있습니다:

- **Edit Text**는 편집기에서 `~/.config/omarchy/branding/screensaver.txt`를 엽니다. ASCII 아트, 이름, 무례한 단어 등 원하는 것을 무엇이든 입력하거나 붙여넣으세요. 저장하고 종료하면 화면 보호기가 즉시 실행되어 결과를 확인할 수 있습니다.
- **Set From Image**는 png나 svg용 파일 선택기를 열고, 이를 ASCII로 변환한 뒤 결과를 보여줍니다. 사진보다 실루엣이 뚜렷한 로고가 훨씬 더 잘 됩니다.
- **Restore Default**는 Omarchy 로고를 다시 적용합니다.

### 정보 화면

Omarchy 메뉴에서 열리는 _About_ 화면에 대해서도 _Appearance > Branding > About_ 아래에 동일한 세 가지 옵션이 있으며, 작동 방식도 완전히 같습니다 — 파일은 `~/.config/omarchy/branding/about.txt`이고, 변경할 때마다 About 창이 팝업으로 나타납니다. About 아트는 화면 전체를 채우는 것이 아니라 창 안에 들어가야 하므로 화면 보호기보다 작은 크기로 변환됩니다.

창이 열려 있는 동안 몇 초마다 녹색 빛이 아트 위를 비스듬히 지나갔다가 다시 가만히 둡니다. 직접 만든 아트도 마찬가지입니다. 단, 그 안의 모든 문자가 한 열 너비여야 합니다 — _Set From Image_로 만든 것은 모두 그렇습니다. 이모지나 두 칸 너비 문자로 만든 아트는 대신 가만히 있고, 직접 만든 fastfetch 설정을 유지하는 경우에도 화면은 가만히 있습니다. 그런 경우 로고가 움직이지 않는 것은 애니메이션이 실패한 것이 아니라 방해가 되지 않도록 물러나 있는 것입니다. 빛을 그 위로 밀어버리면 줄의 나머지가 엉뚱한 위치에 놓이게 되기 때문입니다.

 ![branding-about](images/branding-about.webp)

### 직접 이미지 변환하기

두 _Set From Image_ 옵션은 모두 `omarchy transcode ascii`를 호출할 뿐이므로, 변환을 직접 제어하고 싶으면 직접 실행할 수 있습니다:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

터미널 열과 행 단위의 `--width`와 `--height`, `braille`(기본값이며 훨씬 더 세밀합니다) 또는 `block` 중 하나인 `--mode`, 어떤 픽셀을 로고의 일부로 볼지 결정하는 백분율인 `--threshold`, 그리고 로고가 어두운 배경 위에 밝은 색일 때를 위한 `--invert`를 받습니다. 변환 결과가 덩어리처럼 나오면 보통 임계값이 조정해야 할 부분입니다.

### 로고 대신 단어

`omarchy ascii`는 Omarchy 워드마크 자체가 그려진 FIGlet 글꼴인 Delta Corps Priest 1로 텍스트를 그립니다. 그래서 화면 보호기가 그림을 보여주는 대신 무언가를 말할 수 있습니다:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

텍스트를 인자로 받거나, 인자가 없으면 파이프에서 읽습니다. 이 글꼴은 글자와 공백만 담고 있습니다 — 숫자와 구두점 없이 그려졌습니다 — 따라서 그 외의 것은 조용히 삼켜지는 대신 삭제되고 stderr에 그 이름이 표시됩니다.
