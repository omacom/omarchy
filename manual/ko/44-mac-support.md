# Mac 지원

Omarchy에는 **Intel Mac**에 대한 지원이 내장되어 있습니다. 현재 알려진 제한 사항이 몇 가지 있지만, 이를 인지하고 괜찮다면 Omarchy를 설치해 오래된 Mac에 새 생명을 불어넣을 수 있습니다.

M 시리즈 Mac에 대한 설치는 현재 직접 지원되지 않습니다. 이에 대한 현황은 저희 [Discord](https://discord.gg/tXFUdasqhY)의 #omarchy-on-other에서 자세히 확인할 수 있습니다.

간단한 테스트에서, Omarchy를 설치하는 것만으로 2019년형 MacBook Pro에서 36%의 성능 향상을 얻을 수 있었습니다.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac에 Omarchy 설치하기

Omarchy는 현재 **유일한** OS로 설치되는 경우만 지원합니다. 설치 과정에서 드라이브가 지워지고 MacOS는 더 이상 부팅할 수 없게 됩니다.

원한다면 나중에 Internet Recovery를 통해 복원할 수 있습니다.

이 부분에서는 이미 [시작하기](02-getting-started.md)를 검토했고 USB 드라이브가 준비되어 있다고 가정하겠습니다. 아직 하지 않았다면 지금 하세요.

#### Secure Boot 비활성화

부팅 가능한 USB는 물론 OS를 부팅하려면 Apple의 Secure Boot를 비활성화해야 합니다. 비활성화하려면 다음을 수행하세요:

1. Mac을 끄세요
2. Mac을 켜고 로딩 화면이 나타날 때까지 _즉시_ Command-R을 길게 누르세요
3. 사용자를 선택하고 메시지가 표시되면 비밀번호를 입력하세요
4. 복구 화면에 들어가면 메뉴 막대에서 **Utilities > Startup Security Utility**를 선택하세요
5. 인증하라는 메시지가 표시되면 비밀번호를 입력하세요
6. Secure Boot 옵션에서 "No Security"를 선택하세요
7. External Boot 옵션에서 "Allow booting from external or removable media"를 선택하세요

#### 설치 시작하기

1. USB 드라이브를 삽입하세요
2. Mac을 재시동하고 부팅 장치 화면이 나타날 때까지 _즉시_ Option을 길게 누르세요
3. 주황색 EFI Boot 장치를 선택하세요
4. [평소와 같이 설치를 진행하세요](02-getting-started.md)

설치 프로그램이 Mac 하드웨어를 감지하고 필요한 수정 사항을 자동으로 적용합니다: Broadcom Wi-Fi 드라이버와 펌웨어, 필요한 MacBook 모델의 SPI 키보드 드라이버, 그리고 동일한 모델에 대한 NVMe suspend 수정 사항입니다.

### 알려진 제한 사항

커뮤니티 구성원들이 이러한 문제를 해결하기 위해 끊임없이 노력하고 있으니, 이러한 문제가 불편하다면 저희 [Discord](https://discord.gg/tXFUdasqhY)의 #omarchy-on-other에 참여해 최신 해결 방법이 있는지 확인해 보세요.

#### T1 칩이 탑재된 기기

Apple T1 칩은 2016년 말에 도입되었으며 Touch Bar가 탑재된 1세대 MacBook Pro 모델에만 사용되었습니다.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### 알려진 문제

- Touch Bar가 작동하지 않습니다
- 사운드가 작동하지 않습니다

#### T2 칩이 탑재된 기기

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

이러한 모델에서는 설치 프로그램이 패치된 `linux-t2` 커널, T2 오디오 구성, Apple의 Broadcom Wi-Fi/Bluetooth 펌웨어, 그리고 `t2fanrd`를 통한 팬 제어를 자동으로 설정합니다. Touch Bar는 커널에 내장된 Boot Camp 방식 지원을 통해 작동합니다.

#### iMac Retina 5K (2017)

2017년형 27인치 iMac에는 T2 칩이 없으므로, 설치 프로그램은 다른 Intel Mac과 동일하게 설정합니다.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### 알려진 문제

- 디스플레이가 기본 해상도인 5120×2880으로 작동하지 않습니다: 패널이 두 개의 타일로 구성되어 있는데 기본 드라이버는 하나만 켭니다
- 사운드가 작동하지 않습니다
- 밝기 조절이 작동하지 않습니다
- 절전 모드에서 기기가 멈추며, 전원을 껐다 켜야만 복구됩니다

이 모델용 커뮤니티 패처가 디스플레이, 사운드, 밝기 문제를 해결합니다: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
