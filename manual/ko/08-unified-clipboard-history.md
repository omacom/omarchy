# 통합 클립보드 및 기록

보통 Linux에서는 터미널에서 복사하고 붙여넣으려면 `Ctrl + Shift + C/V`를 써야 하고, 다른 모든 곳에서는 `Ctrl + C/V`를 써야 한다. Linux만 쓰며 나고 자란 사람이 아니라면 누구에게나 적응하기 힘든 일이다! Mac에서 넘어온 경우 Super에서 Ctrl로 바뀌는 것도 마찬가지다.

Omarchy는 (거의) 모든 곳에서 작동하는 통합 클립보드 단축키로 두 문제를 모두 해결한다. 단축키는 다음과 같다:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | 전체 선택 |
| Super + C | 복사 |
| Super + X | 잘라내기 |
| Super + V | 붙여넣기 |
| Super + Ctrl + V | 클립보드 기록 |

_대부분의 에이전트 하네스는 이미지 붙여넣기에 `Ctrl + V`를 사용하지만, 텍스트 붙여넣기에는 `Super + V`를 사용한다는 점에 유의하라._

포커스된 텍스트 필드나 `Ctrl + A`를 지원하는 다른 앱에서 모든 내용을 복사하려면 `Super + A`를 누른 다음 `Super + C`를 눌러라. 터미널에서는 `Ctrl + A`가 텍스트를 선택하는 대신 명령줄의 시작으로 이동한다.

### 클립보드 기록

클립보드 기록은 Omarchy 셸에서 제공하며 텍스트와 이미지 모두에서 작동한다. `Super + Ctrl + V`로 실행하고, Return으로 항목을 선택하면 클립보드에 올려져 `Super + V`로 붙여넣을 준비가 된다.

 ![clipboard-history](images/clipboard-history.webp)

입력하기 시작하는 것만으로 기록을 검색할 수도 있다:

 ![clipboard-history-search](images/clipboard-history-search.webp)
