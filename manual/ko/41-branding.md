# 브랜딩

Omarchy에서는 부팅 잠금 해제 화면, 화면 보호기, 정보 화면 모두에 회사 로고나 개인 이미지를 설정할 수 있습니다.

### 부팅 잠금 해제

`omarchy plymouth preview`를 사용하면 사용자 지정 로고와 색상이 어떻게 보일지 미리 볼 수 있습니다. 배경 색상, 텍스트 색상, 로고 png, 미리 보기 이미지의 경로를 받습니다:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

그런 다음 `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`로 설정을 적용하세요. SDDM 로그인 화면에도 같은 색상과 로고가 적용됩니다. 되돌리고 싶다면 `omarchy plymouth reset`을 사용할 수 있습니다.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### 화면 보호기

_스타일 > 화면 보호기_에서 화면 보호기에 사용되는 로고를 바꿀 수 있습니다. ASCII 로고이므로 텍스트를 직접 편집할 수도 있지만, png나 svg 이미지를 건네주면 ASCII로 변환해 줍니다. 꽤 멋집니다.

 ![branding-screensaver](images/branding-screensaver.webp)

그 메뉴에는 세 가지 항목이 있습니다:

- **텍스트 편집**은 편집기에서 `~/.config/omarchy/branding/screensaver.txt`를 엽니다. ASCII 아트, 이름, 무례한 단어 등 원하는 것을 입력하거나 붙여 넣으세요. 저장하고 종료하면 화면 보호기가 즉시 실행되어 결과를 볼 수 있습니다.
- **이미지에서 설정**은 png나 svg용 파일 선택기를 열어 ASCII로 변환하고 결과를 보여 줍니다. 사진보다 윤곽이 뚜렷한 로고가 훨씬 잘 됩니다.
- **기본값 복원**은 Omarchy 로고를 되돌려 놓습니다.

### 정보 화면

같은 세 가지 옵션은 Omarchy 메뉴에서 여는 _정보_ 화면용으로 _스타일 > 정보_ 아래에도 있으며, 파일이 `~/.config/omarchy/branding/about.txt`이고 변경 후 정보 창이 나타난다는 점을 빼고 동일하게 작동합니다. 정보 아트는 화면 보호기보다 작은 크기로 변환됩니다. 디스플레이를 채우는 게 아니라 창 안에 들어가야 하기 때문입니다.

창이 열려 있는 동안에는 몇 초마다 초록빛 반짝임이 아트를 가로질러 기운 뒤 다시 가만히 둡니다. 모든 문자가 한 열 너비인 한 자기 아트도 마찬가지입니다 — _이미지에서 설정_이 만드는 것은 모두 그렇습니다. 이모지나 두 배 너비 문자로 만든 아트는 대신 가만히 있고, 직접 만든 fastfetch 설정을 유지하는 경우 화면도 가만히 있습니다. 그런 경우 정지한 로고는 애니메이션이 방해를 피하는 것이지 실패한 것이 아닙니다. 반짝임을 가로질러 밀어 넣으면 줄의 나머지가 잘못된 위치에 닿기 때문입니다.

 ![branding-about](images/branding-about.webp)

### 직접 이미지 변환하기

_이미지에서 설정_ 옵션은 둘 다 `omarchy transcode ascii`를 호출할 뿐이므로 변환을 직접 제어하고 싶다면 직접 실행할 수 있습니다:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

터미널의 열과 행으로 지정하는 `--width`와 `--height`, `braille`(기본값이며 훨씬 세밀합니다) 또는 `block` 중 하나인 `--mode`, 어떤 픽셀을 로고의 일부로 볼지 정하는 `--threshold` 백분율, 그리고 로고가 어두운 배경 위에 밝을 때 쓰는 `--invert`를 받습니다. 변환 결과가 덩어리로 나오면 보통 임계값이 돌려 봐야 할 손잡이입니다.

### 로고 대신 단어

`omarchy ascii`는 Omarchy 워드마크 자체가 그려진 FIGlet 글꼴인 Delta Corps Priest 1으로 텍스트를 그리므로, 화면 보호기가 그림을 보여 주는 대신 무언가를 말할 수 있습니다:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

인수로 텍스트를 받거나, 아무것도 주어지지 않으면 파이프에서 읽습니다. 이 글꼴은 문자와 공백만 담고 있습니다 — 숫자나 구두점 없이 그려졌기 때문입니다 — 그래서 그 외의 것은 조용히 삼켜지지 않고 stderr에 이름과 함께 버려집니다.
