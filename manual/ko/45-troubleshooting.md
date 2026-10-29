# 문제 해결

### 업데이트하다가 시스템을 망가뜨렸어요!

먼저 [시스템을 롤백해](47-system-snapshots.md) 최근 업데이트 이전 버전으로 되돌려 보세요. 그래도 안 되면 `omarchy-debug`를 사용해 Discord의 #omarchy-help에 문제를 공유하세요. 그리고 그마저도 안 되면 `omarchy-reinstall`을 사용해 기본 설정과 패키지를 재설치할 수 있습니다.

### 왜 일부 앱이 화면에 너무 크게 표시되나요?

Omarchy는 2x 고해상도 디스플레이를 가정하므로 `~/.config/hypr/monitors.lua`에서 `GDK_SCALE`을 2로 설정해야 합니다. 하지만 1x 디스플레이를 사용 중이라면 `local omarchy_gdk_scale = 2`를 1로 변경하세요 (그런 다음 너무 크게 표시되는 앱을 다시 시작하세요). [모니터에 관한 매뉴얼](33-monitors.md)을 참조하세요.

Spotify에서는 `Ctrl + Minus`를 눌러 UI를 축소할 수 있습니다 (`Ctrl + Plus`를 누르면 확대됩니다).

### Super 키 바인딩이 전부 작동하지 않는 이유는 무엇인가요?

일부 ASUS ROG 및 TUF 노트북에서는 `Fn + Super`가 눈에 잘 띄지 않는 단축키인데, 이 단축키를 누르면 펌웨어 Windows 키 잠금이 토글됩니다 (게임 중 실수로 게임을 나가지 않도록 하기 위한 기능입니다). 화면에는 아무런 표시도 나타나지 않습니다. 잠금이 켜져 있는 동안에는 Super 키가 아무것도 출력하지 않으므로, Super를 사용하는 모든 Omarchy 바인딩이 그냥 멈추고, Hyprland가 고장 난 것처럼 보입니다.

`~/.config/hypr/`를 파헤치기 전에 `Fn + Super`를 한 번 눌러 보세요. 그래도 Super가 돌아오지 않으면 잠금을 켠 채로 두지 않도록 다시 한 번 누르세요. 이는 F 키 열의 동작만 바꾸는 Fn-lock과는 다릅니다.

### Wi-Fi, Bluetooth, 오디오 또는 트랙패드가 갑자기 작동을 멈췄어요

재부팅하기 전에 문제가 있는 하위 시스템만 따로 다시 시작해 보세요. Omarchy 메뉴의 _Update > Hardware_에는 Wi-Fi, Bluetooth, Audio, Trackpad가 있으며, 그중 하나를 다시 로드하면 "5분 전에는 됐는데" 하는 상황 대부분이 해결됩니다. 다시 연결되지 않는 Bluetooth 헤드셋, 절전 모드에서 깨어난 뒤 먹통이 된 트랙패드, 모니터를 뽑았을 때 사라진 소리 같은 경우입니다.

### 외부 스피커에서 소리가 나지 않는 이유는 무엇인가요?

기본 출력으로 설정되어 있지 않기 때문일 가능성이 큽니다. 바 오른쪽에 있는 스피커 아이콘을 클릭하면 볼륨 팝업이 열리며, 여기서 출력 장치를 선택할 수 있습니다 (앱별 볼륨을 조절할 수도 있습니다).

### 노트북 스피커 소리가 이상해요

일부 노트북에서는 Omarchy가 내장 스피커의 주파수 응답을 보정하는 스피커 튜닝을 자동으로 적용합니다. `omarchy audio tuning status`를 실행하면 사용 중인 기기에 튜닝이 활성화되어 있는지 확인할 수 있고, 스피커 본연의 소리를 듣고 싶다면 `omarchy audio tuning off`로 끌 수 있습니다.

### 비밀번호로 로그인하거나 sudo를 사용할 수 없는 이유는 무엇인가요?

비밀번호를 너무 여러 번 잘못 입력해서 잠겼을 가능성이 큽니다. 잠금 화면에서 이런 일이 발생했다면 `CTRL + ALT + F2`를 눌러 새 TTY를 시작한 뒤 root로 로그인하고 `faillock --reset --user [your-username]`를 실행하세요. 잠금이 초기화되어 다시 사용할 수 있게 됩니다.

### 1Password SSH Agent / CLI에 대한 1Password 인증 프롬프트가 나타나지 않는 이유는 무엇인가요?

이런 현상은 두 가지 이유로 발생할 수 있습니다:

풍부한 승인 프롬프트가 나타나려면 Settings > Advanced > Use Hardware Acceleration이 켜져 있어야 합니다. _참고: 이 설정을 적용하려면 재부팅해야 합니다._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

또는 부팅한 뒤 1Password를 한 번도 실행하지 않았다면 프롬프트가 나타나지 않습니다.
