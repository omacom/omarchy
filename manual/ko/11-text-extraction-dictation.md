# 텍스트 추출 및 받아쓰기

### 텍스트 추출

`Super + Ctrl + PrtScr`을 눌러 화면에서 텍스트를 추출할 영역을 선택하세요. 그러면 tesseract 오픈 소스 OCR 모델이 해당 선택 영역을 빠르게 텍스트로 변환해 클립보드에 넣습니다. 그런 다음 `Super + V`를 누르기만 하면 붙여넣을 수 있습니다.

이는 이미지 하단에 있는 주소를 가져오거나 웹사이트 헤드라인에 포함된 전화번호를 가져올 때 매우 유용합니다.

 ![text-extraction](images/text-extraction.webp)

### 받아쓰기

새로 설치한 경우, [Superwhisper](https://superwhisper.com/)가 기본 받아쓰기 백엔드이며, 오프라인 모델 다운로드 없이 클라우드 처리를 사용합니다. Omarchy 메뉴의 _Setup > Defaults > Dictation_에서 Superwhisper 또는 [Voxtype](https://voxtype.io/)를 선택하세요. 백엔드를 선택하면 필요 시 설치하고 이를 받아쓰기 기본값으로 설정합니다. Voxtype은 150MB를 차지하는 기본 영어 모델을 불러옵니다; `voxtype setup model`로 모델을 변경하고 `~/.config/voxtype/config.toml`을 통해 다른 설정을 변경하세요. Superwhisper는 클라우드 또는 로컬 처리를 선택할 수 있는 해당 설정을 열며, OPR이 애플리케이션을 최신 상태로 유지합니다.

`Right Alt`를 누르고 있거나 `Alt + Space`로 토글하여 받아쓰기를 하면, 받아쓴 텍스트가 포커스가 있는 입력 영역에 나타납니다. 이러한 단축키는 선택한 백엔드를 사용합니다. Right Alt는 수정 키 조합에서 사용될 때도 받아쓰기를 시작합니다; 해당 조합에는 Left Alt를 사용하세요. Right Alt가 AltGr인 키보드 레이아웃에서는 입력을 위해 AltGr을 사용할 수 있도록 `Alt + Space`를 사용하세요. Alt + Space가 기본값이 되기 전의 설치에서는 눌러서 말하기에 `F9`를, 토글에 `Super + Ctrl + X`를 유지하며, 이는 `~/.config/hypr/bindings.lua`에 추가됩니다; 해당 키를 애플리케이션에 돌려주려면 거기에서 제거하세요.

동일한 단축키는 어느 백엔드에서든 작동합니다. Setup > Defaults > Dictation에서 백엔드를 선택하세요. 백엔드 설치 프로그램이 이를 구성하고 선택 사항을 저장합니다. `omarchy default dictation`을 실행하면 어느 것이 선택되었는지 확인할 수 있습니다. 선택 사항은 `~/.config/omarchy/defaults/dictation`에 저장됩니다. 새로 설치한 경우 Superwhisper가 자동으로 선택됩니다.

Omarchy는 선택한 백엔드의 데스크톱 통합을 자동으로 불러옵니다. `~/.config/hypr/`에 Superwhisper 구성이 필요하지 않습니다.

사용자 지정 바인딩과 스크립트는 `omarchy dictation start`, `omarchy dictation stop`, `omarchy dictation toggle`을 사용할 수 있습니다. 선택한 백엔드가 녹음과 전사를 처리합니다. Superwhisper를 선택하면 해당 네이티브 길게 누르기 단축키가 비활성화되고 해당 네이티브 토글이 `Ctrl + Alt + Space`로 설정되어 Omarchy의 녹음 키와 분리된 상태로 유지됩니다. Superwhisper에는 최소 하나의 네이티브 녹음 단축키가 필요하며, 해당 취소 단축키는 계속 사용할 수 있습니다.

추가 백엔드는 Omarchy를 변경하지 않고도 통합할 수 있습니다. `start`, `stop`, `toggle`을 허용하고 즉시 반환하며 실패 시 0이 아닌 상태로 반환하는, PATH에 있는 `omarchy-dictation-<backend>`라는 이름의 실행 파일을 제공하세요. 해당 설치 프로그램은 제공업체를 구성하고 설정에 성공한 후 `omarchy-dictation-use <backend>`를 호출합니다. 이는 이전 백엔드를 중지하고 선택 사항을 원자적으로 저장합니다; `stop`은 제공업체가 유휴 상태이거나 사용할 수 없을 때 성공해야 합니다. 백엔드 이름은 소문자, 숫자, 하이픈을 사용합니다. 설정을 위해 `omarchy-install-dictation-<backend>`를 제공하세요; `omarchy default dictation <backend>`가 이를 실행합니다. 해당 선택기를 호출할 Defaults 메뉴 항목을 Omarchy 메뉴 확장을 통해 추가하세요. 선택적 데스크톱 통합은 `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`에 있을 수 있습니다.
