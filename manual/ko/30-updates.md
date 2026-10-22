# 업데이트

Omarchy와 패키지는 Omarchy 메뉴(`Super + Space`)의 _업데이트 > Omarchy_를 통해 최신 상태로 유지됩니다.

Omarchy 자체는 [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs)에서 일반 pacman 패키지로 설치되므로, 업데이트하면 [최신 Omarchy 릴리스](https://github.com/omacom/omarchy/releases)를 설치하고, 시스템을 최신 상태와 동기화하기 위해 보류 중인 마이그레이션을 실행하며, [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror)와 [AUR](https://aur.archlinux.org/)(AUR 패키지를 설치한 경우)에서 모든 시스템 패키지를 업데이트합니다.

새 릴리스가 나오면 시계 오른쪽에 원형 화살표 아이콘이 나타납니다. 클릭하면 업데이트 프로세스가 시작됩니다.

![update-available](images/update-available.webp)

### 네 가지 채널

Omarchy는 네 가지 채널, stable, RC, edge, dev를 따라 업데이트됩니다. 새 설치는 stable 채널에서 시작하며, 이는 [공식 릴리스](https://github.com/omacom/omarchy/releases/)를 추적합니다. 또한 최신 버전보다 한 달 뒤처진 [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror)도 추적합니다. 덕분에 구성 변경이 필요한 새로운 비호환성이 사용자에게 문제를 일으키기 전에 잡아낼 수 있습니다.

하지만 그러한 잠재적 문제를 발견하는 일을 돕고 싶다면 edge 채널을 실행할 수 있습니다. 그러면 Omarchy 패키지가 최신 개발 빌드를 추적하고, Arch 패키지가 나올 때마다 즉시 업데이트할 수 있습니다. Linux에 능숙하고 문제가 생긴 시스템을 복구하는 법을 아는 경우에만 이렇게 하세요.

주요 릴리스가 나오기 전에 RC 채널을 사용해 최종 검증을 합니다. 최종 다듬질에 도움을 주고 싶다면 Discord의 #omarchy-release-candidates 채널로 오세요.

마지막으로 dev 채널이 있습니다. Omarchy를 `~/omarchy`의 소스 코드 git 체크아웃에 직접 연결하고 edge 패키지와 결합합니다. Omarchy에서 직접 작업하는 숙련된 Linux 사용자이며 고장도 감수할 의향이 있을 때만 이 채널을 사용하세요.

Omarchy 메뉴의 _업데이트 > 채널_(또는 터미널에서 `omarchy-channel-set`)을 사용해 채널을 전환할 수 있습니다.

### 펌웨어 업데이트

패키지만 오래되는 것은 아닙니다. 많은 노트북과 주변 기기가 Linux Vendor Firmware Service를 통해 BIOS, SSD, 도크 펌웨어를 제공합니다. Omarchy 메뉴의 _업데이트 > 펌웨어_를 사용하면 하드웨어에 기다리고 있는 것을 가져와 설치합니다. 처음 실행할 때 `fwupd`를 설치합니다. 많은 펌웨어는 재부팅 중에만 쓸 수 있으므로, 재부팅을 요청받아도 놀라지 마세요.

### 직접 pacman/yay로 업데이트하는 것에 대한 경고

이미 Arch에 익숙하다면 직접 `pacman -Syu`나 `yay -Syu`를 실행하고 싶을 수도 있습니다. 하지만 그렇게 하면 Omarchy가 새 패키지와 함께 실행하는 스냅샷, 마이그레이션, 구성 업데이트를 놓치게 됩니다. 그래서 Omarchy는 실제로 직접적인 시스템 업그레이드를 중지하고 대신 `omarchy update`를 안내합니다. (정말로 무슨 일을 하는지 안다면, 가드가 단일 트랜잭션에 대해 이를 우회하는 법을 알려줄 것입니다.)

### 잘못된 업데이트 롤백하기

업데이트 후 문제가 생긴 적이 있다면, 업데이트 전에 찍은 스냅샷으로 시스템을 롤백할 수 있습니다. 재시작한 뒤 부트 로딩 메뉴에서 업데이트를 시작하기 전 스냅샷을 선택하면 됩니다.

![bootloader](images/bootloader.webp)

어떻게든 구성 파일이 손상되었다면 터미널에서 `omarchy reinstall`을 사용해 Omarchy를 재설치할 수도 있습니다. 이렇게 하면 모든 기본 Omarchy 패키지를 다시 설치하고, stable로 전환하며, 너무 새로운 패키지는 다운그레이드하고, 모든 구성 파일을 재설정합니다. Omarchy 기본값에 대한 모든 사용자 구성 변경 사항은 이 과정에서 덮어씌워진다는 점에 유의하세요!
