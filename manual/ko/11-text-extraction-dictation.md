# 텍스트 추출 및 받아쓰기

### 텍스트 추출

화면에서 텍스트를 추출할 영역을 선택하려면 `Super + Ctrl + PrtScr`를 누르세요. 그러면 tesseract 오픈 소스 OCR 모델이 선택 영역을 빠르게 텍스트로 변환해 클립보드에 넣습니다. 그런 다음 `Super + V`를 눌러 붙여넣기만 하면 됩니다.

이는 이미지 푸터에서 주소를 가져오거나 웹사이트 헤드라인에 포함된 전화번호를 가져올 때 매우 유용합니다.

 ![text-extraction](images/text-extraction.webp)

### 받아쓰기

새로 설치한 경우, [Superwhisper](https://superwhisper.com/)가 기본 받아쓰기 백엔드이며 오프라인 모델 다운로드 없이 클라우드 처리를 사용합니다. Omarchy 메뉴의 _Setup > Defaults > Dictation_을 통해 Superwhisper, [Voxtype](https://voxtype.io/), 또는 [Hex](https://anoma.ly/hex/)를 선택하세요. 백엔드를 선택하면 필요할 경우 설치하고 받아쓰기의 기본값으로 만듭니다. Voxtype는 150MB를 차지하는 기본 영어 모델을 로드합니다. `voxtype setup model`로 모델을 변경하고 `~/.config/voxtype/config.toml`을 통해 다른 설정을 변경하세요. Superwhisper는 클라우드 또는 로컬 처리를 선택할 수 있도록 설정을 열며, OPR이 애플리케이션을 최신 상태로 유지합니다. Hex는 설정 중에 온디바이스 음성 모델을 다운로드하고 `hex.service` 사용자 서비스로 실행됩니다. 바의 트레이 아이콘에서 또는 `hex`를 실행하여 창을 열고 모델과 다른 설정을 변경하세요.

`Right Alt`를 길게 누르거나 `Alt + Space`로 토글하여 받아쓰면, 받아쓴 텍스트가 포커스된 입력 영역에 나타납니다. 이 단축키는 선택한 백엔드를 사용합니다. Right Alt는 수식키 조합으로 사용할 때도 받아쓰기를 시작합니다. 해당 조합에는 Left Alt를 사용하세요. Right Alt가 AltGr인 키보드 레이아웃에서는 `Alt + Space`를 사용하여 AltGr을 입력에 계속 사용할 수 있게 하세요. Alt + Space가 기본값이 되기 전에 설치한 경우 `F9`는 길게 눌러 말하기용으로, 토글용인 `Super + Ctrl + X`는 `~/.config/hypr/bindings.lua`에 추가된 상태로 유지됩니다. 해당 키를 애플리케이션에 돌려주려면 거기에서 제거하세요.

동일한 단축키는 모든 백엔드에서 작동합니다. Setup > Defaults > Dictation을 통해 백엔드를 선택하세요. 백엔드 설치 프로그램이 이를 구성하고 선택 내용을 저장합니다. 어떤 백엔드가 선택되었는지 확인하려면 `omarchy default dictation`을 실행하세요. 선택 내용은 `~/.config/omarchy/defaults/dictation`에 저장됩니다. 새로 설치하면 Superwhisper가 자동으로 선택됩니다.

Omarchy는 선택한 백엔드의 데스크톱 통합을 자동으로 로드합니다. `~/.config/hypr/`에 Superwhisper 구성이 필요하지 않습니다.

사용자 지정 바인딩과 스크립트는 `omarchy dictation start`, `omarchy dictation stop`, `omarchy dictation toggle`을 사용할 수 있습니다. 선택한 백엔드가 녹음과 전사를 처리합니다. Superwhisper를 선택하면 기본 길게 누르기 단축키가 비활성화되고 기본 토글이 `Ctrl + Alt + Space`로 설정되어 Omarchy의 녹음 키와 분리됩니다. Superwhisper에는 최소 하나의 기본 녹음 단축키가 필요하며, 취소 단축키는 계속 사용할 수 있습니다.

추가 백엔드는 Omarchy를 변경하지 않고 통합할 수 있습니다. PATH에 `start`, `stop`, `toggle`을 허용하고 즉시 반환하며 실패 시 0이 아닌 상태를 반환하는, `omarchy-dictation-<backend>`라는 이름의 실행 파일을 제공하세요. 설치 프로그램은 공급자를 구성하고 설정에 성공한 후 `omarchy-dictation-use <backend>`를 호출합니다. 이는 이전 백엔드를 중지하고 선택 내용을 원자적으로 저장합니다. 공급자가 유휴 상태이거나 사용할 수 없는 경우에도 `stop`은 성공해야 합니다. 백엔드 이름에는 소문자, 숫자, 하이픈을 사용합니다. 설정을 위해 `omarchy-install-dictation-<backend>`를 제공하세요. `omarchy default dictation <backend>`가 이를 실행합니다. Omarchy 메뉴 확장 프로그램을 통해 Defaults 메뉴 항목을 추가하여 해당 선택기를 호출하세요. 선택적 데스크톱 통합은 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`에 있을 수 있습니다.
