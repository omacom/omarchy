# Mac 지원

## Apple Silicon용 Omarchy

Omarchy for Apple Silicon은 공식 Omacom 솔루션으로, Omarchy 4.5와 함께 처음 출시됐다. macOS 옆에 설치되며, Mac을 시작할 때 둘 중 하나를 선택한다.

Omarchy Mac에 대한 안내를 받았는가? [Omarchy Mac에서 오기](#coming-from-omarchy-mac)로 가라.

다음 Mac에서 실행된다:

| Mac | 칩 |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 및 그보다 새로운 Mac은 아직 지원되지 않는다. M4 지원은 edge 채널에서 테스트 중이며 다음으로 제공된다. 설치 프로그램은 아무것도 변경하기 전에 Mac을 검사한다.

M4 및 그보다 새로운 모델을 포함해 모든 Apple Silicon Mac에서 [Try Omarchy](https://github.com/omacom/try-omarchy)를 사용해 가상 머신으로 Omarchy를 실행할 수 있다.

### 필요한 것

- macOS 15 Sequoia 이상, 그리고 관리자 계정
- Omarchy를 위한 여유 디스크 공간. 설치 프로그램이 크기를 제안하고 변경할 수 있게 한다.
- Mac 백업, 전원, 인터넷 연결. 설치 시 수 기가바이트를 다운로드한다.

### 설치하기

macOS에서 설치한다. [Homebrew](https://brew.sh)를 이용해 Omarchy Installer를 설치하라:

```sh
brew install omacom/mac/omarchy
```

또는 최신 Omarchy Installer를 [릴리스 페이지](https://github.com/omacom/omarchy-mac-installer/releases)에서 다운로드해 열어라.

설치 프로그램은 Mac을 검사하고, 계획을 보여주며, macOS 파티션을 줄여 Omarchy를 위한 공간을 만든다. macOS는 디스크에 그대로 남고 USB 드라이브는 필요 없다. 첫 단계가 끝나면 macOS Recovery에서 설정을 마치는 과정을 안내한다: 종료하고, "Loading startup options"가 나타날 때까지 전원 버튼을 길게 누르고, Omarchy를 선택한 뒤 단계를 따르라.

처음 부팅할 때 Omarchy는 디스크를 암호화할 비밀번호를 묻는다. 복구 키는 없다: 비밀번호를 잊으면 Omarchy 파일을 복구할 수 없다.

나중에 Omarchy와 macOS 사이에서 전환하려면 종료한 뒤, 시작 옵션이 나타날 때까지 전원 버튼을 길게 누르고 하나를 선택하라.

### Omarchy Mac에서 오기

Omarchy Mac은 이제 Omarchy for Apple Silicon의 일부이며, 이를 실행했던 모든 Mac이 지원된다. 현재 설치는 계속 실행되고 시스템 패키지도 계속 업데이트되지만, 더 이상 Omarchy 업데이트는 받지 못한다. 기한은 없고 제자리 업그레이드도 없다: 백업하고, 기존 설치를 제거하고, 새로 설치한 뒤 복원하라. 2단계부터 5단계까지는 macOS에서 진행되므로, 재시작하기 전에 이 페이지를 휴대폰에서 열어 두라.

1. **Omarchy에서 Mac 외부로 백업하라.** 기존 설치를 제거하면 삭제되며, macOS는 Omarchy 디스크를 읽을 수 없다. SSH 및 GPG 키, 브라우저 프로필, 푸시하지 않은 작업을 포함해 홈 폴더를 외장 드라이브나 다른 컴퓨터로 복사하라. `pacman -Qqe > ~/packages.txt`로 패키지 목록을 저장하라. 제거와 설치 모두 디스크 크기를 조정하므로 macOS도 백업하라.
2. **macOS로 Mac을 시작하라.** 종료하고, 시작 옵션이 나타날 때까지 전원 버튼을 길게 누른 뒤 macOS를 선택하라.
3. **[설치하기](#installing)에 나온 대로 Omarchy Installer를 설치하라.**
4. **기존 설치를 제거하라.** Omarchy Installer를 열고 Installation > Remove Omarchy를 선택하라. 삭제할 항목을 보여주고 공간을 macOS로 되돌린다. 설치를 인식하지 못하면 디스크를 변경하지 않고 중단한다. 파티션을 직접 삭제하면 macOS까지 지워질 수 있으니, 그렇게 하지 말고 [Discord](https://discord.gg/tXFUdasqhY)에서 도움을 요청하라.
5. **설치 프로그램으로 Omarchy for Apple Silicon을 설치하라.**
6. **파일을 복원하라.** `~/.config` 전체를 새 기본값 위에 복사하면 기존 설정이 이를 덮어쓸 수 있으므로, 설정을 한 번에 한 조각씩 되돌려라.

### 알아 두면 좋은 것

- M1 및 M2 MacBook에서는 뚜껑을 열거나 전원 버튼을 눌러 잠자기에서 깨워라.
- 질문이나 문제가 있는가: [Discord](https://discord.gg/tXFUdasqhY)에서 물어보라.

[설치 프로그램의 README](https://github.com/omacom/omarchy-mac-installer#readme)에서는 릴리스 채널, 설치 프로그램 업데이트, Omarchy 제거를 다룬다.

## Intel Macs

간단한 테스트에서 2019 MacBook Pro에 Omarchy를 설치하는 것만으로 36%의 성능 향상을 얻을 수 있었다.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac에 Omarchy 설치하기

Omarchy는 현재 **유일한** OS로 설치되는 것만 지원한다. 설치 과정에서 드라이브가 지워지고 MacOS는 더 이상 부팅할 수 없게 된다.

나중에 원한다면 Internet Recovery를 통해 복원할 수는 있다.

이 부분에서는 이미 [시작하기](02-getting-started.md)를 검토하고 USB 드라이브를 준비했다고 가정한다. 아직 하지 않았다면 지금 하라.

#### Secure Boot 비활성화

부팅 가능한 USB와 OS를 부팅하려면 Apple의 Secure Boot를 비활성화해야 한다. 비활성화하려면 다음을 수행하라:

1. Mac을 꺼라
2. 전원을 켜고 로딩 화면이 나타날 때까지 _즉시_ Command-R을 길게 눌러라
3. 사용자를 선택하고 메시지가 나타나면 비밀번호를 입력하라
4. 복구 화면에 들어가면 메뉴바에서 **Utilities > Startup Security Utility**를 선택하라
5. 인증하라는 메시지가 나타나면 비밀번호를 입력하라
6. Secure Boot 옵션에서 "No Security"를 선택하라
7. External Boot 옵션에서 "Allow booting from external or removable media"를 선택하라

#### 설치 시작

1. USB 드라이브를 삽입하라
2. Mac을 재시작하고 부팅 장치 화면이 나타날 때까지 _즉시_ Option을 길게 눌러라
3. 주황색 EFI Boot 장치를 선택하라
4. [일반적인 설치](02-getting-started.md)대로 진행하라

설치 프로그램은 Mac 하드웨어를 감지해 필요한 수정을 자동으로 적용한다: Broadcom Wi-Fi 드라이버와 펌웨어, Broadcom 1570을 탑재한 기기의 FaceTime HD 카메라 드라이버(설치 프로그램은 오프라인으로 동작하므로 펌웨어는 Mac이 온라인 상태가 된 뒤 Apple에서 다운로드된다), 필요한 MacBook 모델의 SPI 키보드 드라이버, 그리고 같은 모델들의 NVMe 일시 중단 수정.

### 알려진 제한 사항

커뮤니티 구성원들이 이러한 문제를 해결하기 위해 계속 노력하고 있으니, 이 문제들이 걸린다면 [Discord](https://discord.gg/tXFUdasqhY)의 #omarchy-on-other에 참여해 최신 해결 방법이 있는지 확인하라.

#### FaceTime HD Camera

카메라 드라이버는 Mac이 최대 절전 모드에 들어갈 때 로드되어 있으면 기기를 멈추게 하므로, 먼저 언로드된다. 앱이 카메라를 열어 둔 동안에는 언로드할 수 없으므로, 최대 절전 모드가 취소되고 해당 앱 이름을 알리는 알림이 표시된다: 앱을 닫고 다시 최대 절전 모드로 전환하라. 여기에는 배터리가 위급한 상황에서의 자동 최대 절전 모드와, 일시 중단 전에 거부되는 suspend-then-hibernate가 포함된다. 일반적인 일시 중단은 알림 없이, 카메라가 열려 있는 동안 드라이버 자체에 의해 거부된다.

카메라 펌웨어는 Apple에서 다운로드되므로, 카메라는 Mac이 온라인 상태가 된 뒤에야 작동한다. 다운로드는 부팅 시 시작되며 네트워크가 문제인 동안 15분마다 재시도된다; Apple의 파일이 변경됐다면 중단하고 Omarchy 업데이트를 기다린다. 카메라가 나타나지 않으면 `journalctl -u facetimehd-firmware-fetcher`가 이유를 알려주고, `sudo systemctl restart facetimehd-firmware-fetcher`가 다시 시도하며, 다운로드가 끝났는데도 카메라가 여전히 없으면 재부팅하면 드라이버가 로드된다.

#### T1 칩 탑재 기기

Apple T1 칩은 2016년 말에 도입됐으며 Touch Bar를 탑재한 1세대 MacBook Pro 모델에만 사용됐다.
- MacBook Pro 13인치 (2016, Thunderbolt 3 포트 2개) – Model: A1706
- MacBook Pro 13인치 (2016, Thunderbolt 3 포트 4개) – Model: A1708
- MacBook Pro 15인치 (2016) – Model: A1707

#### 알려진 문제

- Touch Bar가 작동하지 않는다
- 사운드가 작동하지 않는다

#### T2 칩 탑재 기기

Apple T2 Security Chip은 2017년에 도입됐다. T2 칩은 2020년부터 시작된 Apple silicon (M 시리즈 칩)으로의 전환과 함께 단종됐다.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13인치 (2018, Thunderbolt 3 포트 4개) – Model: A1989
- MacBook Pro 15인치 (2018) – Model: A1990
- MacBook Air (Retina, 13인치, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13인치 (2019, Thunderbolt 3 포트 2개) – Model: A2159
- MacBook Pro 13인치 (2019, Thunderbolt 3 포트 4개) – Model: A2178
- MacBook Pro 15인치 (2019) – Model: A1990
- iMac (Retina 5K, 27인치, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13인치 (2020, Thunderbolt 3 포트 2개) – Model: A2265
- MacBook Pro 15인치 (2020) – Model: A1990

이 모델들에서는 설치 프로그램이 패치된 `linux-t2` 커널, T2 오디오 구성, Apple의 Broadcom Wi-Fi/Bluetooth 펌웨어, `t2fanrd`를 이용한 팬 제어를 자동으로 설정한다. Touch Bar는 커널에 내장된 Boot Camp 방식 지원으로 실행된다.

#### iMac Retina 5K (2017)

2017년 27인치 iMac에는 T2 칩이 없으므로, 설치 프로그램은 다른 Intel Macs와 마찬가지로 설정한다.

- iMac (Retina 5K, 27인치, 2017) – Model: A1419

#### 알려진 문제

- 디스플레이가 네이티브 5120×2880으로 실행되지 않는다: 패널은 두 개의 타일로 이루어져 있으며 기본 드라이버는 하나만 켠다
- 사운드가 작동하지 않는다
- 밝기 조절이 효과가 없다
- 잠자기에 들어가면 기기가 멈춘다; 전원을 껐다 켜는 것만으로 복구된다

이 모델의 디스플레이, 사운드, 밝기를 수정하는 커뮤니티 패처: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
