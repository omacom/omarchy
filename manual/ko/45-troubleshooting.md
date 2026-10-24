# 문제 해결

### 업데이트로 시스템을 망쳤어요!

먼저 최근 업데이트 이전 버전으로 [시스템을 롤백해 보세요](47-system-snapshots.md). 그래도 안 되면 `omarchy-debug`를 사용해 Discord의 #omarchy-help 채널에서 문제를 공유하세요. 그리고 이 모든 게 실패하면 `omarchy-reinstall`을 사용해 기본 설정과 패키지를 다시 설치할 수 있습니다.

### 왜 디스플레이에서 어떤 앱은 이렇게 크게 보이나요?

Omarchy는 2배 고해상도 디스플레이를 가정하는데, 이를 위해서는 `~/.config/hypr/monitors.lua`에서 `GDK_SCALE`을 2로 설정해야 합니다. 하지만 1배 디스플레이라면 `local omarchy_gdk_scale = 2`를 1로 바꿀 수 있습니다(그리고 너무 크게 보이는 앱은 재시작하세요). [모니터 매뉴얼](33-monitors.md)을 참조하세요.

Spotify에서는 `Ctrl + Minus`를 사용해 UI를 줄일 수 있고(`Ctrl + Plus`는 크게 만듭니다).

### Wi-Fi, Bluetooth, 오디오 또는 터치패드가 갑자기 작동을 멈췄어요

재부팅하기 전에 문제의 하위 시스템만 따로 재시작해 보세요. Omarchy 메뉴의 _업데이트 > 하드웨어_에는 Wi-Fi, Bluetooth, 오디오, 터치패드가 있으며, 그중 하나를 다시 불러오면 "5분 전에는 됐는데" 하는 상황의 대부분이 해결됩니다 — 다시 연결되지 않는 Bluetooth 헤드셋, 일시 중단 후 죽어 버린 터치패드, 모니터를 뽑았더니 사라진 소리 같은 것들입니다.

### 왜 외장 스피커에서 소리가 나지 않나요?

아마 기본 출력으로 설정되어 있지 않기 때문일 겁니다. 막대 오른쪽의 스피커 아이콘을 클릭하면 볼륨 팝업이 열려 출력 기기를 고를 수 있습니다(앱별 볼륨 믹싱도 가능합니다).

### 노트북 스피커 소리가 이상해요

일부 노트북에서는 Omarchy가 내장 스피커의 주파수 응답을 보정하는 스피커 튜닝을 자동으로 적용합니다. `omarchy audio tuning status`는 사용하는 컴퓨터에서 하나가 활성화되어 있는지 알려 주고, `omarchy audio tuning off`는 스피커 소리를 있는 그대로 듣고 싶다면 이를 끕니다.

### 왜 비밀번호로 로그인하거나 sudo를 쓸 수 없나요?

아마 너무 많이 틀렸고 잠긴 것일 겁니다. 잠금 화면에서 이런 일이 생기고 있다면 `CTRL + ALT + F2`를 눌러 새 TTY를 시작하고 루트로 로그인한 뒤 `faillock --reset --user [your-username]`을 실행할 수 있습니다. 그러면 잠금이 재설정되고 사용할 수 있습니다.

### 왜 1Password SSH Agent / CLI용 1Password 승인 프롬프트가 나타나지 않나요?

두 가지 이유가 있을 수 있습니다:

풍부한 승인 프롬프트가 나타나려면 Settings > Advanced > Use Hardware Acceleration이 켜져 있어야 합니다. _참고: 이는 작동하기 위해 재부팅이 필요합니다._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

또는 부팅 이후 1Password를 실행한 적이 없다면 프롬프트가 나타나지 않습니다.
