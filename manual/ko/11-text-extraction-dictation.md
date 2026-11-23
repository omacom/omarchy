# 텍스트 추출 & 받아쓰기

### 텍스트 추출

`Super + Ctrl + PrtScr`를 눌러 화면에서 텍스트를 추출할 영역을 선택하세요. 그러면 tesseract 오픈 소스 OCR 모델이 해당 선택 영역을 빠르게 텍스트로 변환해 클립보드에 넣어줍니다. 그다음 `Super + V`를 누르기만 하면 붙여넣을 수 있습니다.

이는 이미지 푸터에 있는 주소를 가져오거나 웹사이트 헤드라인에 포함된 전화번호를 가져올 때 매우 유용합니다.

 ![text-extraction](images/text-extraction.webp)

### 받아쓰기

새로 설치한 경우, [Superwhisper](https://superwhisper.com/)가 기본 받아쓰기 백엔드이며, 오프라인 모델을 다운로드하지 않고 클라우드 처리를 사용합니다. Omarchy 메뉴의 _Setup > Defaults > Dictation_에서 Superwhisper, [Voxtype](https://voxtype.io/), 또는 [Hex](https://anoma.ly/hex/) 중에서 선택하세요. 백엔드를 선택하면 필요할 경우 설치하고 받아쓰기의 기본값으로 설정합니다. Voxtype은 150MB를 차지하는 기본 영어 모델을 로드합니다; `voxtype setup model`로 모델을 변경하고 `~/.config/voxtype/config.toml`을 통해 다른 설정을 변경하세요. Superwhisper는 설정을 열어 클라우드 또는 로컬 처리를 선택할 수 있게 하며, OPR이 애플리케이션을 최신 상태로 유지합니다. Hex는 설치 과정에서 온디바이스 음성 모델을 다운로드하고 `hex.service` 사용자 서비스로 실행됩니다; 바의 트레이 아이콘에서 창을 열거나 `hex`를 실행해 모델과 다른 설정을 변경하세요.

`Right Alt`를 누르고 있거나 `Alt + Space`로 토글해 받아쓰기를 하면, 받아쓴 텍스트가 포커스된 입력 영역에 나타납니다. 이러한 단축키는 선택된 백엔드를 사용합니다. Right Alt는 수식 키 조합에 사용될 때도 받아쓰기를 시작합니다; 그런 조합에는 Left Alt를 사용하세요. Right Alt가 AltGr인 키보드 레이아웃에서는, 전환해서 사용하는 그런 레이아웃인 경우를 포함해, 받아쓰기를 하려면 잠시 단독으로 누르고 계세요; 다른 키와 함께 누른 AltGr는 여전히 해당 문자를 입력합니다. Alt + Space가 기본값이 되기 전에 설치한 경우 push-to-talk에는 `F9`를, 토글에는 `Super + Ctrl + X`를 유지하며, 이는 `~/.config/hypr/bindings.lua`에 추가되고, 여기서 해당 `Super + Ctrl + X`가 agents 패널을 대신합니다; 애플리케이션과 패널에 해당 키를 돌려주려면 거기에서 제거하세요.

동일한 단축키는 모든 백엔드에서 작동합니다. Setup > Defaults > Dictation에서 백엔드를 선택하세요. 백엔드 설치 프로그램이 이를 구성하고 선택을 저장합니다. 어떤 것이 선택되었는지 확인하려면 `omarchy default dictation`을 실행하세요. 선택은 `~/.config/omarchy/defaults/dictation`에 저장됩니다. 새로 설치한 경우 Superwhisper가 자동으로 선택됩니다.

Omarchy는 선택된 백엔드의 데스크톱 통합을 자동으로 로드합니다. `~/.config/hypr/`에 Superwhisper 구성이 필요하지 않습니다.

사용자 지정 바인딩과 스크립트는 `omarchy dictation start`, `omarchy dictation stop`, `omarchy dictation toggle`을 사용할 수 있습니다. 선택된 백엔드가 녹음과 전사를 처리합니다. Superwhisper를 선택하면 해당 네이티브 홀드 단축키가 비활성화되고 네이티브 토글이 `Ctrl + Alt + Space`로 설정되어 Omarchy의 녹음 키와 분리됩니다. Superwhisper에는 최소 하나의 네이티브 녹음 단축키가 필요하며, 취소 단축키는 계속 사용할 수 있습니다.

추가 백엔드는 Omarchy를 변경하지 않고도 통합할 수 있습니다. PATH에 `start`, `stop`, `toggle`을 받아들이고 즉시 반환하며, 실패 시 0이 아닌 상태를 반환하는 `omarchy-dictation-<backend>`라는 이름의 실행 파일을 제공하세요. 설치 프로그램은 제공자를 구성하고 설정이 성공한 후 `omarchy-dictation-use <backend>`를 호출합니다. 이는 이전 백엔드를 중지하고 선택을 원자적으로 저장합니다; `stop`은 제공자가 유휴 상태이거나 사용할 수 없을 때도 성공해야 합니다. 백엔드 이름은 소문자, 숫자, 하이픈을 사용합니다. 설정을 위해 `omarchy-install-dictation-<backend>`를 제공하세요; `omarchy default dictation <backend>`가 이를 실행합니다. 해당 선택자를 호출하는 Defaults 메뉴 항목을 Omarchy 메뉴 확장을 통해 추가하세요. 선택적 데스크톱 통합은 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`에 둘 수 있습니다.
