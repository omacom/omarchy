# Mac 지원

## Apple Silicon용 Omarchy

Apple Silicon용 Omarchy는 공식 Omacom 솔루션이며, Omarchy 4.5와 함께 처음 출시되었습니다. macOS 옆에 설치되며, Mac이 시작될 때 둘 중 하나를 선택합니다.

Omarchy Mac에 대한 알림을 받으셨나요? [Omarchy Mac에서 오기](#coming-from-omarchy-mac)로 이동하세요.

다음 Mac에서 실행됩니다:

| Mac | Chips |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 및 그 이후 Mac은 아직 지원되지 않습니다. M4 지원은 edge 채널에서 테스트 중이며 다음으로 제공됩니다. 설치 프로그램은 아무것도 변경하기 전에 사용자의 Mac을 확인합니다.

M4 및 그 이후를 포함한 모든 Apple Silicon Mac에서는 [Try Omarchy](https://github.com/omacom/try-omarchy)를 이용해 가상 머신에서 Omarchy를 실행할 수 있습니다.

### 필요한 것

- macOS 15 Sequoia 이상, 그리고 관리자 계정
- Omarchy를 위한 여유 디스크 공간. 설치 프로그램이 크기를 제안하며, 변경할 수 있습니다.
- Mac의 백업, 전원, 그리고 인터넷 연결. 설치 과정에서 수 기가바이트를 다운로드합니다.

### 설치하기

macOS에서 설치합니다. [Homebrew](https://brew.sh)로 Omarchy Installer를 설치하세요:

```sh
brew install omacom/mac/omarchy
```

또는 최신 Omarchy Installer를 [releases page](https://github.com/omacom/omarchy-mac-installer/releases)에서 다운로드해 여세요.

설치 프로그램은 사용자의 Mac을 확인하고, 계획을 보여주며, macOS 파티션을 축소해 Omarchy가 들어갈 공간을 만듭니다. macOS는 디스크에 그대로 남아 있으며 USB 드라이브는 필요 없습니다. 첫 번째 단계가 끝나면 macOS Recovery에서 설정을 마치는 과정을 안내합니다: 종료하고, "Loading startup options"가 나타날 때까지 전원 버튼을 길게 누른 뒤, Omarchy를 선택하고 단계에 따라 진행하세요.

처음 부팅할 때 Omarchy는 디스크를 암호화할 비밀번호를 묻습니다. 복구 키는 없습니다: 비밀번호를 잊으면 Omarchy 파일을 복구할 수 없습니다.

나중에 Omarchy와 macOS 사이를 전환하려면 종료한 뒤, 시작 옵션이 나타날 때까지 전원 버튼을 길게 누르고 하나를 선택하세요.

### Omarchy Mac에서 오기

Omarchy Mac은 이제 Apple Silicon용 Omarchy의 일부이며, 이를 실행했던 모든 Mac이 지원됩니다. 현재 설치는 계속 실행되고 시스템 패키지도 계속 업데이트되지만, 더 이상 Omarchy 업데이트는 받지 않습니다. 기한은 없으며 제자리 업그레이드도 없습니다: 백업하고, 기존 설치를 제거하고, 새로 설치한 뒤, 복원합니다. 2단계부터 5단계까지는 macOS에서 진행되므로, 재시작하기 전에 이 페이지를 휴대폰에서 여세요.

1. **Omarchy에서, Mac 외부로 백업하세요.** 기존 설치를 제거하면 삭제되며, macOS는 Omarchy 디스크를 읽을 수 없습니다. SSH 및 GPG 키, 브라우저 프로필, 푸시하지 않은 작업을 포함해 홈 폴더를 외장 드라이브나 다른 컴퓨터로 복사하세요. `pacman -Qqe > ~/packages.txt`로 패키지 목록을 저장하세요. 제거와 설치 모두 디스크 크기를 조정하므로 macOS도 백업하세요.
2. **macOS에서 Mac을 시작하세요.** 종료하고, 시작 옵션이 나타날 때까지 전원 버튼을 길게 누른 뒤, macOS를 선택하세요.
3. [설치하기](#installing)에 나와 있는 대로 **Omarchy Installer를 설치하세요**.
4. **기존 설치를 제거하세요.** Omarchy Installer를 열고 Installation > Remove Omarchy를 선택하세요. 삭제할 항목을 보여주고 공간을 macOS로 반환합니다. 설치를 인식하지 못하면 디스크를 변경하지 않고 중단합니다. 파티션을 직접 삭제하면 macOS까지 지워질 수 있으니, 그렇게 하지 말고 [Discord](https://discord.gg/tXFUdasqhY)에서 도움을 요청하세요.
5. 설치 프로그램으로 **Apple Silicon용 Omarchy를 설치하세요**.
6. **파일을 복원하세요.** 기존 설정이 새 기본값을 덮어쓸 수 있으므로, `~/.config` 전체를 복사하지 말고 설정을 조금씩 되돌리세요.

### 알아두면 좋은 점

- M1 및 M2 MacBooks에서는 덮개를 열거나 전원 버튼을 눌러 절전 모드에서 깨우세요.
- 질문이나 문제가 있으신가요: [Discord](https://discord.gg/tXFUdasqhY)에서 물어보세요.

[installer's README](https://github.com/omacom/omarchy-mac-installer#readme)에서는 릴리스 채널, 설치 프로그램 업데이트, Omarchy 제거를 다룹니다.

## Intel Macs

간단한 테스트에서, Omarchy를 설치하는 것만으로 2019 MacBook Pro에서 36%의 성능 향상을 얻을 수 있었습니다.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac에 Omarchy 설치하기

Omarchy는 현재 설치된 **유일한** OS인 경우만 지원합니다. 설치 과정에서 드라이브가 지워지고 MacOS는 더 이상 부팅할 수 없게 됩니다.

나중에 원한다면 Internet Recovery를 통해 여전히 복원할 수 있습니다.

이 부분에서는 이미 [Getting Started](02-getting-started.md)를 검토했고 USB 드라이브가 준비되어 있다고 가정합니다. 아직 하지 않았다면 지금 바로 하세요.

#### Secure Boot 비활성화

부팅 가능한 USB는 물론 OS를 부팅하려면 Apple의 Secure Boot를 비활성화해야 합니다. 비활성화하려면 다음을 수행하세요:

1. Mac 끄기
2. Mac을 켜고 로딩 화면이 나타날 때까지 _즉시_ Command-R을 길게 누르기
3. 사용자를 선택하고 메시지가 나타나면 비밀번호 입력하기
4. 복구 화면에 들어간 뒤, 메뉴 막대에서 **Utilities > Startup Security Utility** 선택하기
5. 인증하라는 메시지가 나타나면 비밀번호 입력하기
6. Secure Boot 옵션에서 "No Security" 선택하기
7. External Boot 옵션에서 "Allow booting from external or removable media" 선택하기

#### 설치 시작하기

1. USB 드라이브 삽입하기
2. Mac을 재시작하고 부팅 기기 화면이 나타날 때까지 _즉시_ Option을 길게 누르기
3. 주황색 EFI Boot 기기 선택하기
4. [평소와 같이 설치](02-getting-started.md)를 진행하기

설치 프로그램은 Mac 하드웨어를 감지하고 필요한 수정을 자동으로 적용합니다: Broadcom Wi-Fi 드라이버와 펌웨어, 필요한 MacBook 모델용 SPI 키보드 드라이버, 그리고 같은 모델용 NVMe 일시 중단 수정입니다.

### 알려진 제한 사항

커뮤니티 구성원들은 이러한 문제를 해결하기 위해 끊임없이 노력하고 있으니, 이 문제가 본인에게 심각하다면 [Discord](https://discord.gg/tXFUdasqhY)의 #omarchy-on-other에 참여해 최신 해결 방법이 있는지 확인해 보세요.

#### T1 Chip이 있는 기기

Apple T1 칩은 2016년 말에 도입되었으며 Touch Bar를 탑재한 1세대 MacBook Pro 모델에만 독점적으로 사용되었습니다.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### 알려진 문제

- Touch Bar가 작동하지 않음
- 사운드가 작동하지 않음

#### T2 Chip이 있는 기기

Apple T2 Security Chip은 2017년에 도입되었습니다. T2 칩은 2020년부터 시작된 Apple silicon(M 시리즈 칩)으로의 전환과 함께 단종되었습니다.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

이 모델에서는 설치 프로그램이 패치된 `linux-t2` 커널, T2 오디오 구성, Apple의 Broadcom Wi-Fi/Bluetooth 펌웨어, 그리고 `t2fanrd`를 통한 팬 제어를 자동으로 설정합니다. Touch Bar는 커널에 내장된 Boot Camp 방식 지원을 사용해 실행됩니다.

#### iMac Retina 5K (2017)

2017 27-inch iMac에는 T2 칩이 없으므로, 설치 프로그램은 다른 Intel Macs와 동일하게 설정합니다.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### 알려진 문제

- 디스플레이가 기본 해상도인 5120×2880으로 실행되지 않음: 패널이 두 개의 타일로 이루어져 있는데 기본 드라이버는 하나만 켬
- 사운드가 작동하지 않음
- 밝기 조절이 아무 효과가 없음
- 절전 모드에서 기기가 멈추며, 전원을 껐다 켜는 것만으로 복구됨

이 모델용 커뮤니티 패처는 디스플레이, 사운드, 밝기를 수정합니다: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
