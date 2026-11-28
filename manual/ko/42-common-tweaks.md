# 자주 사용하는 조정

이것은 Omarchy 설정을 자주 맞춤 설정하는 방법들을 모아 둔 것이다. 알아 두어라. 시스템 업데이트 때문에 특정 설정을 원래 상태로 되돌려야 할 때가 가끔 있을 수 있다. 그런 경우에도 변경 사항이 사라지지는 않고, 원본 옆에 `.bak.<timestamp>` 파일로 보관된다.

무언가를 망쳤다면, Omarchy 메뉴의 _Update > Config_를 통해 개별 설정을 원래 설정으로 복원할 수 있다. 정말로 모든 것을 망쳤다면, `omarchy reinstall configs`로 모든 설정을 초기화하거나, `omarchy reinstall`로 모든 기본 패키지와 설정을 다시 설치할 수 있다.

### 항상 모든 트레이 아이콘 표시하기

기본적으로 Dropbox, 1password, Steam 같은 트레이 아이콘은 트레이 확장 화살표 뒤에 숨겨져 있으며, 그 위에 커서를 올리면 나타난다. 항상 드러나게 하고 싶다면, 확장 화살표를 마우스 오른쪽 버튼으로 클릭해 트레이 아이콘 관리자를 열고, 계속 보이게 할 아이콘을 고정하라(절대 보고 싶지 않은 아이콘은 숨길 수도 있다).

### 둥근 창 모서리

Omarchy의 기본 디자인은 각진 모서리이지만, 조금 부드럽게 만들고 싶다면 Omarchy 메뉴에서 _Appearance > Windows > Window Corners > Rounded Corners_를 선택하거나 `omarchy hyprland corners rounded`를 실행하라. _Theme Corners_는 테마가 사용하는 설정으로 되돌린다. 반경을 직접 정하려면 _Theme Corners_(`omarchy hyprland corners theme`)를 그대로 사용하라. Rounded와 Sharp는 당신의 설정 뒤에 로드되어 이를 덮어쓰기 때문이다. 그리고 `~/.config/hypr/looknfeel.lua`에서 rounding의 주석을 해제하라:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### 창 간격 제거하기

노트북 디스플레이에서는 창 간격에 픽셀 하나도 낭비하고 싶어 하지 않는 사람들도 있다(심지어 상단 바도 마찬가지인데, `Super + Shift + Space`로 끌 수 있다). `Super + Shift + Backspace`로 모든 간격과 테두리를 켜고 끌 수 있으며, `~/.config/hypr/looknfeel.lua`의 이 섹션에서 주석을 제거하면 영구적으로 제거할 수 있다:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
