# Mac 지원

Omarchy는 **Intel Mac**을 기본으로 지원합니다. 현재 알려진 제한이 몇 가지 있지만, 이를 알고 있고 괜찮다면 Omarchy를 설치해 낡은 Mac에 새 생명을 불어넣을 수 있습니다.

M 시리즈 Mac에 설치하는 것은 현재 직접 지원되지 않는다는 점에 유의하세요. 이에 대한 상황은 [Discord](https://discord.gg/tXFUdasqhY)의 #omarchy-on-other 채널에서 더 알아볼 수 있습니다.

간단한 테스트에서 Omarchy를 설치하는 것만으로 2019년 MacBook Pro에서 36%의 성능 향상을 달성할 수 있었습니다.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Mac에 Omarchy 설치하기

Omarchy는 현재 설치된 **유일한** OS인 경우만 지원합니다. 설치 중에 드라이브가 지워지고 MacOS는 더 이상 부팅할 수 없게 됩니다.

나중에 필요하다면 인터넷 복구(Internet Recovery)를 통해 복원할 수는 있습니다.

이 부분을 위해서는 이미 [시작하기](02-getting-started.md)를 검토했고 USB 드라이브를 준비했다고 가정하겠습니다. 아직이라면 지금 그렇게 하세요.

#### 시큐어 부트 비활성화하기

부팅 가능한 USB와 OS를 부팅하려면 Apple의 시큐어 부트(Secure Boot)를 비활성화해야 합니다. 비활성화하려면 다음을 수행하세요:

1. Mac을 끄세요
2. Mac을 켜고 _곧바로_ 로딩 화면이 나타날 때까지 Command-R을 길게 누르세요
3. 사용자를 선택하고 메시지가 표시되면 비밀번호를 입력하세요
4. 복구 화면에 들어가면 메뉴 막대에서 **Utilities > Startup Security Utility**를 선택하세요
5. 인증하라는 메시지가 표시되면 비밀번호를 입력하세요
6. Secure Boot 옵션에서 "No Security"를 선택하세요
7. External Boot 옵션에서 "Allow booting from external or removable media"를 선택하세요

#### 설치 시작하기

1. USB 드라이브를 꽂으세요
2. Mac을 재시작하고 _곧바로_ 부팅 기기 화면이 나타날 때까지 Option을 길게 누르세요
3. 주황색 EFI Boot 기기를 선택하세요
4. [평소처럼 설치를 진행하세요](02-getting-started.md)

설치 프로그램은 Mac 하드웨어를 감지하고 필요한 수정을 자동으로 적용합니다: Broadcom Wi-Fi 드라이버와 펌웨어, 이를 필요로 하는 MacBook 모델용 SPI 키보드 드라이버, 그리고 같은 모델용 NVMe 일시 중단 수정입니다.

### 알려진 제한 사항

커뮤니티 회원들은 이러한 어려움에 대한 해결책을 계속 찾고 있으므로, 이런 것들이 문제가 된다면 [Discord](https://discord.gg/tXFUdasqhY)의 #omarchy-on-other 채널에 참여해 이를 해결할 최신 방법이 있는지 확인해 보세요.

#### T1 칩을 탑재한 기기

Apple T1 칩은 2016년 말에 도입되었으며 Touch Bar를 탑재한 1세대 MacBook Pro 모델에만 독점적으로 사용되었습니다.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### 알려진 문제

- Touch Bar가 작동하지 않습니다
- 소리가 작동하지 않습니다

#### T2 칩을 탑재한 기기

Apple T2 보안 칩은 2017년에 도입되었습니다. T2 칩은 2020년부터 시작된 Apple 실리콘(M 시리즈 칩)으로의 전환과 함께 단종되었습니다.

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

이 모델들에서는 설치 프로그램이 패치된 `linux-t2` 커널, T2 오디오 설정, Apple의 Broadcom Wi-Fi/Bluetooth 펌웨어, 그리고 `t2fanrd`를 통한 팬 제어를 자동으로 설정합니다. Touch Bar는 커널에 내장된 Boot Camp 방식 지원으로 실행됩니다.
