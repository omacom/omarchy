# 문제 해결

### 업데이트하다가 시스템을 망가뜨렸어요!

먼저 최근 업데이트 이전 버전으로 [시스템을 롤백](47-system-snapshots.md)해 보세요. 그래도 안 되면 `omarchy-debug`를 사용해 Discord의 #omarchy-help에 문제를 공유하세요. 그것도 다 안 되면 `omarchy-reinstall`을 사용해 기본 설정과 패키지를 다시 설치할 수 있습니다.

### 왜 일부 앱이 디스플레이에서 너무 크게 보이나요?

Omarchy는 2x 고해상도 디스플레이를 가정하므로, 모니터 패널에서 배율을 선택하기 전까지 `GDK_SCALE`을 2로 설정합니다. 1x 디스플레이를 사용하는데 GTK 또는 X11 앱이 너무 크게 나온다면, 모니터 패널에서 해당 디스플레이에 1x를 선택하거나 `~/.config/hypr/monitors.lua`에 `hl.env("GDK_SCALE", "1")`를 추가하세요(그런 다음 너무 크게 보이는 앱은 다시 시작하세요). [모니터에 관한 매뉴얼](33-monitors.md)을 참고하세요.

Spotify에서는 `Ctrl + Minus`로 UI를 축소할 수 있고(`Ctrl + Plus`로 확대할 수 있습니다).

### 왜 Super 키 바인딩이 전부 작동을 멈췄나요?

일부 ASUS ROG 및 TUF 노트북에서는 `Fn + Super`가 놓치기 쉬운 조합으로, 펌웨어의 Windows 키 잠금을 토글합니다(게임 중에 실수로 게임을 나가지 않도록 만든 기능입니다). 화면에는 아무 표시도 나오지 않습니다. 잠금이 켜져 있는 동안에는 Super가 아무것도 내보내지 않으므로, Super를 사용하는 모든 Omarchy 바인딩이 그냥 멈추고, Hyprland가 고장 난 것처럼 보입니다.

`~/.config/hypr/`를 파헤치기 전에 `Fn + Super`를 한 번 누르고, 그래도 Super가 돌아오지 않으면 잠금을 켠 상태로 두지 않도록 한 번 더 누르세요. 이는 F 키 열의 동작만 바꾸는 Fn-lock과는 다릅니다.

### Wi-Fi, Bluetooth, 오디오 또는 트랙패드가 갑자기 작동을 멈췄어요

재부팅하기 전에, 문제가 있는 하위 시스템만 따로 다시 시작해 보세요. Omarchy 메뉴의 _Update > Hardware_에는 Wi-Fi, Bluetooth, Audio, Trackpad가 있으며, 이 중 하나를 다시 로드하면 "5분 전까지만 해도 됐는데" 하는 상황의 대부분이 해결됩니다 — 다시 연결되지 않는 Bluetooth 헤드셋, 절전 모드에서 깨어난 뒤 먹통이 된 트랙패드, 모니터를 뽑았더니 사라진 사운드 같은 경우입니다.

### 왜 외부 스피커에서 소리가 나지 않나요?

아마 기본 출력으로 설정되어 있지 않기 때문일 겁니다. 바 오른쪽의 스피커 아이콘을 클릭하면 볼륨 팝업이 열리고, 거기서 출력 장치를 선택할 수 있습니다(앱별 볼륨을 믹싱할 수도 있습니다).

### 노트북 스피커 소리가 이상해요

일부 노트북에서는 Omarchy가 내장 스피커의 주파수 응답을 보정하는 스피커 튜닝을 자동으로 적용합니다. `omarchy audio tuning status`를 실행하면 사용 중인 기기에 활성화된 튜닝이 있는지 알 수 있고, 스피커의 날것 그대로의 소리를 듣고 싶다면 `omarchy audio tuning off`로 끌 수 있습니다.

### 왜 비밀번호로 로그인하거나 sudo를 사용할 수 없나요?

아마 비밀번호를 너무 여러 번 잘못 입력해서 잠긴 것일 겁니다. 잠금 화면에서 이 일이 발생했다면 `CTRL + ALT + F2`를 눌러 새 TTY를 시작하고 root로 로그인한 뒤 `faillock --reset --user [your-username]`를 실행하세요. 잠금이 해제되어 다시 사용할 수 있게 됩니다.

### 왜 1Password SSH Agent / CLI에 대한 1Password 인증 프롬프트가 나타나지 않나요?

이는 두 가지 이유로 발생할 수 있습니다:

상세한 승인 프롬프트가 나타나려면 Settings > Advanced > Use Hardware Acceleration이 켜져 있어야 합니다. _참고: 이는 재부팅해야 작동하기 시작합니다._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

또, 부팅한 뒤 1Password를 실행한 적이 없다면 프롬프트가 나타나지 않습니다.
