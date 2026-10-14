# 텍스트 추출 및 받아쓰기

### 텍스트 추출

텍스트를 추출할 화면 영역을 선택하려면 `Super + Ctrl + PrtScr`를 누르세요. 그러면 tesseract 오픈 소스 OCR 모델이 선택 영역을 빠르게 텍스트로 변환해 클립보드에 올려 줍니다. 그런 다음 `Super + V`를 누르면 붙여넣을 수 있습니다.

이미지 푸터에서 주소를 가져오거나 웹사이트 헤드라인에 내장된 전화번호를 가져올 때 매우 유용합니다.

 ![text-extraction](images/text-extraction.webp)

### 받아쓰기

새로 설치한 경우, [Superwhisper](https://superwhisper.com/)가 기본 받아쓰기 백엔드이며 오프라인 모델을 다운로드하지 않고 클라우드 처리를 사용합니다. Omarchy 메뉴에서 _설정 > 기본값 > 받아쓰기_를 통해 Superwhisper 또는 [Voxtype](https://voxtype.io/)를 선택하세요. 백엔드를 선택하면 필요하면 설치하고 받아쓰기 기본값으로 만듭니다. Voxtype는 150MB를 차지하는 기본 영어 모델을 로드합니다. `voxtype setup model`로 모델을 바꾸고 다른 설정은 `~/.config/voxtype/config.toml`에서 변경하세요. Superwhisper는 설정을 열어 클라우드 처리나 로컬 처리를 선택할 수 있게 하며, OPR이 애플리케이션을 최신 상태로 유지합니다.

`Right Alt`나 `F9`를 길게 누르거나 `Super + Ctrl + X`로 토글하여 받아쓰면, 받아쓴 텍스트가 포커스된 입력 영역에 나타납니다. 이 단축키는 선택한 백엔드를 사용합니다. Right Alt는 수정자 코드(chord) 안에서도 받아쓰기를 시작합니다. 그런 코드에는 Left Alt를 사용하세요. Right Alt가 AltGr인 키보드 레이아웃에서는 입력 시 AltGr를 계속 사용할 수 있도록 `F9`를 사용하세요.

같은 단축키가 두 백엔드 모두에서 작동합니다. 설정 > 기본값 > 받아쓰기에서 백엔드를 선택하세요. 백엔드 설치 프로그램이 이를 구성하고 선택을 저장합니다. 어떤 것이 선택되었는지 보려면 `omarchy default dictation`을 실행하세요. 선택은 `~/.config/omarchy/defaults/dictation`에 저장됩니다. 새로 설치하면 자동으로 Superwhisper가 선택됩니다.

Omarchy는 선택한 백엔드의 데스크톱 통합을 자동으로 로드합니다. `~/.config/hypr/`에서 Superwhisper를 구성할 필요가 없습니다.

사용자 지정 바인딩과 스크립트는 `omarchy dictation start`, `omarchy dictation stop`, `omarchy dictation toggle`를 사용할 수 있습니다. 선택한 백엔드가 녹음과 전사를 담당합니다. Superwhisper를 선택하면 네이티브 홀드 단축키를 비활성화하고 네이티브 토글을 `Alt + Space`로 설정하여 Omarchy 녹음 키와 분리합니다. Superwhisper에는 최소 하나의 네이티브 녹음 단축키가 필요하며, 취소 단축키는 계속 사용할 수 있습니다.

추가 백엔드는 Omarchy를 바꾸지 않고 통합될 수 있습니다. PATH에 `omarchy-dictation-<backend>`라는 이름의 실행 파일을 제공하세요. 이는 `start`, `stop`, `toggle`을 받아들이고 즉시 반환하며, 실패 시 0이 아닌 상태를 반환합니다. 그 설치 프로그램이 공급자를 구성하고 설정이 성공하면 `omarchy-dictation-use <backend>`를 호출합니다. 그러면 이전 백엔드가 중단되고 선택이 원자적으로 저장됩니다. `stop`은 공급자가 유휴 상태이거나 사용할 수 없을 때도 성공해야 합니다. 백엔드 이름은 소문자, 숫자, 하이픈을 사용합니다. 설정을 위해 `omarchy-install-dictation-<backend>`를 제공하세요. `omarchy default dictation <backend>`가 이를 실행합니다. 해당 선택기를 호출할 기본값(Defaults) 메뉴 항목은 Omarchy 메뉴 확장을 통해 추가하세요. 선택 사항인 데스크톱 통합은 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`에 있을 수 있습니다.
