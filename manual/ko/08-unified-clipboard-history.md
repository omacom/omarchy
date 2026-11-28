# 통합 클립보드 및 히스토리

보통 Linux에서는 터미널에서 복사하고 붙여넣으려면 `Ctrl + Shift + C/V`가 필요하고, 그 밖의 모든 곳에서는 `Ctrl + C/V`를 사용해야 합니다. Linux에서 태어나고 자라지 않은 사람이라면 익숙해지기 정말 어렵습니다! Mac에서 넘어왔다면 super에서 ctrl로 바뀌는 것도 마찬가지입니다.

Omarchy는 (거의) 모든 곳에서 작동하는 통합 클립보드 단축키로 두 문제를 모두 해결합니다. 단축키는 다음과 같습니다:

| Hotkey | Command |
| ------- | ----------- |
| Super + A | 전체 선택 |
| Super + C | 복사 |
| Super + X | 잘라내기 |
| Super + V | 붙여넣기 |
| Super + Ctrl + V | 클립보드 히스토리 |

_대부분의 에이전트 하네스는 이미지를 붙여넣을 때는 `Ctrl + V`를 사용하지만, 텍스트를 붙여넣을 때는 `Super + V`를 사용한다는 점에 유의하세요._

포커스가 있는 텍스트 필드나 `Ctrl + A`를 지원하는 다른 앱에서 모든 내용을 복사하려면 `Super + A`를 누른 다음 `Super + C`를 누르세요. 터미널에서는 `Ctrl + A`가 텍스트를 선택하는 대신 명령줄의 시작으로 이동합니다.

### 클립보드 히스토리

클립보드 히스토리는 Omarchy shell에서 제공하며 텍스트와 이미지 모두에서 작동합니다. `Super + Ctrl + V`로 실행하고 Return으로 항목을 선택하면, 이전에 있던 앱에 바로 붙여넣어집니다. 클립보드에 복사만 하려면 `Shift + Return`을, 열려면 `Alt + Return`을, 히스토리에서 제거하려면 `Delete`를, 전체 히스토리를 지우려면 `Shift + Delete`를 사용하세요.

 ![clipboard-history](images/clipboard-history.webp)

타이핑을 시작하기만 하면 히스토리를 검색할 수도 있습니다:

 ![clipboard-history-search](images/clipboard-history-search.webp)
