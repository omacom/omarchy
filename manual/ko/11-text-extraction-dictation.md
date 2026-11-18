# 텍스트 추출 및 받아쓰기

### 텍스트 추출

`Super + Ctrl + PrtScr`을 눌러 화면에서 텍스트를 추출할 영역을 선택하세요. 그러면 오픈 소스 OCR 모델인 tesseract가 해당 선택 영역을 빠르게 텍스트로 변환해 클립보드에 넣어줍니다. 그다음 `Super + V`만 누르면 붙여넣을 수 있습니다.

이미지 푸터에 있는 주소나 웹사이트 헤드라인에 포함된 전화번호를 가져올 때 매우 유용합니다.

 ![text-extraction](images/text-extraction.webp)

### 받아쓰기

새로 설치한 경우, [Superwhisper](https://superwhisper.com/)가 기본 받아쓰기 백엔드이며, 오프라인 모델을 다운로드하지 않고 클라우드 처리를 사용합니다. Omarchy 메뉴의 _Setup > Defaults > Dictation_에서 Superwhisper, [Voxtype](https://voxtype.io/) 또는 [Hex](https://anoma.ly/hex/)를 선택하세요. 백엔드를 선택하면 필요할 경우 설치하고 받아쓰기의 기본값으로 설정합니다. Voxtype은 150MB를 차지하는 기본 영어 모델을 로드합니다. 모델은 `voxtype setup model`로 변경하고, 그 외 설정은 `~/.config/voxtype/config.toml`을 통해 변경하세요. Superwhisper는 설정을 열어 클라우드 처리 또는 로컬 처리를 선택할 수 있게 하며, OPR이 애플리케이션을 최신 상태로 유지합니다. Hex는 설정 과정에서 온디바이스 음성 모델을 다운로드하고 `hex.service` 사용자 서비스로 실행됩니다. 모델과 그 외 설정을 변경하려면 바의 트레이 아이콘에서 창을 열거나 `hex`를 실행하세요.

`Right Alt`를 누르고 있거나 `Alt + Space`로 토글하여 받아쓰면, 받아쓴 텍스트가 포커스된 입력 영역에 나타납니다. 이 단축키는 선택한 백엔드를 사용합니다. Right Alt는 수식 키 조합에 사용될 때도 받아쓰기를 시작합니다. 그런 조합에는 Left Alt를 사용하세요. Right Alt가 AltGr인 키보드 레이아웃에서는 입력을 위해 AltGr을 계속 쓸 수 있도록 `Alt + Space`를 사용하세요. Alt + Space가 기본값이 되기 전부터 설치된 환경에서는 눌러서 말하기용 `F9`와 토글용 `Super + Ctrl + X`가 유지되며, 이는 `~/.config/hypr/bindings.lua`에 추가되어 있고, 여기서 그 `Super + Ctrl + X`가 에이전트 패널을 대신합니다. 해당 키들을 애플리케이션과 패널에 돌려주려면 거기에서 제거하세요.

모든 백엔드에서 동일한 단축키가 작동합니다. Setup > Defaults > Dictation에서 백엔드를 선택하세요. 백엔드 설치 프로그램이 이를 구성하고 선택 사항을 저장합니다. 어떤 백엔드가 선택되어 있는지 확인하려면 `omarchy default dictation`을 실행하세요. 선택 사항은 `~/.config/omarchy/defaults/dictation`에 저장됩니다. 새로 설치하면 Superwhisper가 자동으로 선택됩니다.

Omarchy는 선택한 백엔드의 데스크톱 통합을 자동으로 로드합니다. `~/.config/hypr/`에 Superwhisper를 구성할 필요는 없습니다.

사용자 지정 바인딩과 스크립트에서는 `omarchy dictation start`, `omarchy dictation stop`, `omarchy dictation toggle`을 사용할 수 있습니다. 선택한 백엔드가 녹음과 전사를 처리합니다. Superwhisper를 선택하면 기본 홀드 단축키가 비활성화되고 기본 토글이 `Ctrl + Alt + Space`로 설정되어 Omarchy의 녹음 키와 분리된 상태로 유지됩니다. Superwhisper에는 최소 하나의 기본 녹음 단축키가 필요하며, 취소 단축키는 계속 사용할 수 있습니다.

추가 백엔드는 Omarchy를 변경하지 않고도 통합할 수 있습니다. `start`, `stop`, `toggle`을 받아들이고 즉시 반환하며 실패 시 0이 아닌 상태 코드를 반환하는 `omarchy-dictation-<backend>`라는 이름의 실행 파일을 PATH에 제공하세요. 해당 설치 프로그램은 제공자를 구성하고 설정이 성공한 후 `omarchy-dictation-use <backend>`를 호출합니다. 그러면 이전 백엔드가 중지되고 선택 사항이 원자적으로 저장됩니다. `stop`은 제공자가 유휴 상태이거나 사용할 수 없는 경우에도 성공해야 합니다. 백엔드 이름에는 소문자, 숫자, 하이픈을 사용합니다. 설정을 위해 `omarchy-install-dictation-<backend>`를 제공하세요. `omarchy default dictation <backend>`가 이를 실행합니다. Omarchy 메뉴 확장을 통해 Defaults 메뉴 항목을 추가하여 해당 선택기를 호출하세요. 선택적 데스크톱 통합은 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`에 둘 수 있습니다.
