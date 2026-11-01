# 흔한 조정

Omarchy 설정을 맞춤 조정하는 흔한 방법들을 모은 것입니다. 시스템 업데이트 때문에 특정 설정을 원래 상태로 되돌려야 하는 경우가 가끔 있을 수 있다는 점을 알아 두세요. 이런 일이 생기더라도 변경 사항은 사라지지 않고 같은 디렉터리의 `.bak` 파일에 들어갑니다.

무언가를 망쳤다면 Omarchy 메뉴의 _업데이트 > 설정_을 통해 개별 설정을 원래 설정으로 복원할 수 있습니다. 모든 것을 _정말로_ 망쳤다면 `omarchy-reinstall`로 모든 설정을 재설정할 수 있습니다.

### 모든 트레이 아이콘을 항상 표시하기

기본으로 Dropbox, 1password, Steam 같은 트레이 아이콘은 마우스를 올리면 펼쳐지는 트레이 확장 화살표 뒤에 숨겨져 있습니다. 항상 드러내 두고 싶다면 확장 화살표를 마우스 오른쪽 버튼으로 클릭해 트레이 아이콘 관리자를 연 뒤, 보이게 유지하고 싶은 아이콘을 고정하세요(절대 보고 싶지 않은 아이콘은 숨길 수도 있습니다).

### 둥근 창 모서리

Omarchy의 기본 디자인은 각진 모서리이지만, 조금 부드럽게 하고 싶다면 `~/.config/hypr/looknfeel.lua`의 rounding이 더 이상 주석 처리되지 않도록 바꾸세요:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### 창 간격 제거하기

노트북 화면에서는 창 간격(이나 `Super + Shift + Space`로 끌 수 있는 상단 막대까지도)에 픽셀을 낭비하지 않는 것을 선호하는 사람이 많습니다. `Super + Shift + Backspace`로 모든 간격과 테두리를 켜고 끌 수 있고, `~/.config/hypr/looknfeel.lua`의 이 섹션에서 주석을 제거해 영구적으로 없앨 수도 있습니다:

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
