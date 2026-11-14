# 스크린샷 및 녹화

화면에서 캡처할 수 있는 모든 것은 Print Screen 키에 달려 있다. 키 하나만 누르면 사진을 찍고, 수정자 키를 함께 누르면 녹화, 색상, 또는 영역 안의 텍스트를 가져온다. 키보드에 Print Screen 키가 아예 없다면 `Super + Ctrl + Alt + C`로도 같은 스크린샷을 찍을 수 있고, `Super + Ctrl + C`를 누르면 전체 세트가 메뉴로 열린다.

| Hotkey | Function |
| ------ | -------- |
| `Print Screen` | 스크린샷 |
| `Super + Ctrl + Alt + C` | 스크린샷 |
| `Alt + Print Screen` | 화면 녹화 (또는 실행 중인 녹화 중지) |
| `Super + Print Screen` | 색상 선택기 |
| `Super + Ctrl + Print Screen` | 영역에서 텍스트 추출 |
| `Super + Ctrl + C` | 캡처 메뉴 |
| `Super + Ctrl + .` | 사진 또는 동영상 트랜스코딩 |

## 스크린샷

`Print Screen`(또는 `Super + Ctrl + Alt + C`)을 누르면 Omasnap이 오버레이가 나타나기 전에 포커스된 모니터를 캡처하므로, 조준하는 동안 화면이 아래에서 흔들리는 일이 없다. 자유형 영역을 드래그하거나, 창을 클릭해 그 창을 캡처하거나, 빈 공간을 클릭해 모니터 전체를 캡처하라. 그리기 전에 `S`를 누르면 스크롤 영역을 캡처할 수 있다. 마음이 바뀌었는가? 같은 키를 다시 누르면 Omasnap이 닫힌다.

영역을 선택하면 Omasnap이 캡처를 저장하고 클립보드에 복사한 다음, 저장된 화면 녹화처럼 썸네일이 있는 알림을 보여준다. Open을 선택하면 저장된 사진을 이미지 뷰어에서 볼 수 있고, Edit를 선택하면 주석을 달 수 있다.

주석 편집기에서는 화살표, 선, 도형, 강조 표시, 번호 마커, 텍스트, 안전한 가림 처리를 그릴 수 있고, 이미지의 일부를 자르거나 잘라낼 수 있으며, 텍스트를 OCR하고, 배경을 추가할 수 있다. 편집기에서 `Enter`를 누르면 완성된 PNG를 복사하고 저장하고, `Ctrl + C`를 누르면 저장하지 않고 복사하며, `Ctrl + S`를 누르면 복사하지 않고 저장한다.

저장된 스크린샷은 기본적으로 `~/Pictures/Screenshots`에 들어가며, 이름은 `screenshot-2026-08-13_14-22-05-firefox.png`와 같은 식이다. 다른 디렉터리를 사용하려면 `OMASNAP_SCREENSHOT_DIR`를 설정하라. 세션 환경 변수를 어디에 넣어야 하는지는 [자주 묻는 질문](46-faq.md)을 참고하라. Omasnap은 첫 번째 사진을 저장할 때 그 디렉터리를 만든다. 자동 저장을 끄려면 `~/.config/omasnap/omasnap.conf`에서 `[output] autosave = false`로 설정하라. 그러면 캡처는 복사만 되고, 10초 동안 미리 보기로 표시되며, 고정 버튼이나 `Ctrl + P`로 화면에 계속 띄워 둘 수 있다.

터미널에서는 `omarchy screenshot`이 같은 오버레이를 열며, 시작 모드를 선택할 수 있다: `omarchy capture screenshot region`, `windows`, `fullscreen`, 또는 `scroll`. 두 번째 인자로 `copy` 또는 `save`를 주면 사진이 곧바로 해당 대상으로 전송된다. 출력 전에 편집하려면 전체 화면 편집기에는 `omarchy screenshot --editor=overlay`를, 별도 창에는 `omarchy screenshot --editor=window`를 사용하라.

### 키보드로 선택 도구 조작하기

선택 화면이 떠 있는 동안에는 마우스를 전혀 사용하지 않아도 된다:

| Key | Function |
| --- | -------- |
| `S` | 스크롤 영역 모드 전환 |
| `Super + Arrow keys` | Window 모드에서 창 사이 이동 |
| `Return` | 강조 표시된 창 캡처 |
| `Ctrl + A` | 포커스된 모니터 전체 캡처 |
| `R` | 이 세션에서 마지막으로 그린 영역 복원 |
| `Esc` | Omasnap 닫기 |

이 단축키는 Omasnap이 열려 있을 때만 존재하므로, 네 설정에 있는 어떤 것과도 충돌할 수 없다.

## 화면 녹화

`Alt + Print Screen`을 누르면 _Trigger > Capture > Screenrecord_가 열리고, 사운드트랙에 무엇을 넣을지 묻는다: 오디오 없음, 데스크톱 오디오, 데스크톱과 마이크, 또는 데스크톱과 마이크와 웹캠. 마지막 항목은 카메라가 실제로 연결되어 있을 때만 나타난다. 하나를 고르면 Omarchy의 녹화 선택 도구로 영역을 드래그하거나 창이나 모니터를 클릭할 수 있다.

녹화는 gpu-screen-recorder로 실행되며, GPU에서 60fps로 인코딩하고 어쩔 수 없으면 CPU로 대체한다. 결과는 `~/Videos`에 있는 MP4이며, 이름은 `screenrecording-2026-08-13_14-22-05.mp4`와 같다. 이를 변경하려면 `OMARCHY_SCREENRECORD_DIR`를 설정하라. 단, 스크린샷 디렉터리와 달리 이 디렉터리는 이미 존재해야 하며, 그렇지 않으면 녹화가 시작을 거부한다는 점에 유의하라.

녹화 중에는 바에 작은 표시기가 나타난다. 클릭하면 중지된다. `Alt + Print Screen`을 다시 눌러 중지할 수도 있고, 실제로 녹화 중일 때만 나타나는 _Trigger > Capture > Screenrecord_ 아래의 _Stop Screenrecording_ 항목으로 중지할 수도 있다.

중지하면 파일을 건네기 전에 약간의 정리 작업을 한다: 첫 번째 프레임이 잘리고, 오디오가 있으면 -14 LUFS로 정규화되며 맨 처음에 있는 PipeWire 캡처 팝음이 음소거된다. 그런 다음 녹화에서 가져온 썸네일과 함께 알림이 나타난다. 클릭하면 mpv에서 파일이 재생된다.

### 웹캠 오버레이

웹캠과 함께 녹화하면 카메라는 녹화 중인 화면의 오른쪽 아래 모서리에 고정되고 잘린 세로형 창처럼 나타난다. 필요한 것 위에 겹쳐 있다면 즉석에서 크기를 조정하라:

| Hotkey | Function |
| ------ | -------- |
| `Super + Alt + [` | 웹캠 오버레이 작게 만들기 |
| `Super + Alt + ]` | 웹캠 오버레이 크게 만들기 |

크기는 small, medium, large 세 가지이며, 단축키로 그 사이를 오간다. Medium이 기본값이다. 녹화에 비례하므로, 1080p 모니터를 녹화하든 6K 모니터를 녹화하든 카메라가 프레임에서 차지하는 비율은 같다. 그리고 전체 디스플레이가 아니라 영역을 녹화했다면 오버레이는 모니터의 모서리가 아니라 그 영역의 모서리에 고정되므로, 사진 안에 그대로 들어간다.

`omarchy-capture-webcam-resize small`로 직접 호출할 수도 있고, `reset`으로 medium으로 돌아갈 수도 있다.

## 텍스트, QR 코드 및 색상

`Super + Ctrl + Print Screen`은 영역을 선택하고 그 내용을 OCR해 클립보드에 넣는다. 이는 [텍스트 추출 및 받아쓰기](11-text-extraction-dictation.md)에서 제대로 다룬다.

_Trigger > Capture > QR Code_도 QR 코드에 대해 같은 요령을 부린다. 코드가 있는 영역을 선택하면 디코딩된 값이 클립보드로 간다. QR 코드만 찾는다. 촘촘한 화면 내용은 그렇지 않으면 바코드로 오인되는 일이 잦기 때문이다. 알아둘 만한 점: 디코딩된 값은 클립보드로만 가고 그 외 어디에도 가지 않는다. 출력되지 않고, 알림에도 없으며, 민감한 것으로 표시되어 [클립보드 기록](08-unified-clipboard-history.md)에 남아 있지 않는다. QR 코드는 일상적으로 비밀을 담고 있다. 예를 들어 2FA 설정 코드 뒤에 있는 `otpauth://` URI가 그렇다. 그런 것이 로그에 남는 것은 원치 않을 것이다. 붙여넣기는 여전히 잘 된다.

`Super + Print Screen`(또는 _Trigger > Capture > Color_)을 누르면 커서가 스포이드로 바뀐다. 화면의 아무 곳이나 클릭하면 그 색상이 클립보드에 들어간다. 단축키를 다시 누르면 선택하지 않고 빠져나온다.

## 공유하기 전에 트랜스코딩하기

4K 화면 녹화나 휴대폰에서 가져온 원본 HEIC는 그냥 보내기에는 너무 큰 경우가 많다. `Super + Ctrl + .`(또는 _Trigger > Transcode_)가 이를 해결한다. `~/Pictures`와 `~/Videos`를 대상으로 퍼지 파일 선택 도구를 제공한 다음, 형식과 크기를 묻는다.

사진은 high, medium, low로 jpg 또는 png가 되며, 너비는 각각 최대 3160, 2160, 1080 픽셀로 제한된다. 동영상은 4k, 1080p, 720p로 mp4 또는 애니메이션 gif가 된다. 변환된 파일은 원본 옆에 해상도를 이름에 넣어 기록된다. 예를 들어 `demo-1080p.mp4`와 같으며, 경로는 파일 URI로 클립보드에 복사되므로 파일 드롭을 받는 앱에 직접 붙여넣을 수 있다.

이미 원하는 것을 알고 있다면 터미널에서도 동작한다: `omarchy transcode ~/Videos/demo.mov mp4 1080p`. 이미지를 ASCII 아트로 바꾸는 `omarchy transcode ascii`도 있는데, 이는 주로 [브랜딩](41-branding.md)을 위한 것이다.

## 어딘가로 보내기

파일을 확보했으면 `Super + Ctrl + S`를 눌러 Share 메뉴를 열고 LocalSend를 통해 네트워크상의 다른 기기로 보내라. 이에 대해서는 [GUI](22-guis.md)를 참고하라.
