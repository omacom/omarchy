# 업데이트

Omarchy와 패키지는 Omarchy 메뉴(`Super + Space`)의 _Update > Omarchy_를 통해 최신 상태로 유지됩니다.

Omarchy 자체는 [Omarchy Package Repository](https://github.com/omacom-io/omarchy-pkgs)에서 일반 pacman 패키지로 설치되므로, 업데이트를 하면 [최신 Omarchy 릴리스](https://github.com/omacom/omarchy/releases)가 설치되고, 시스템을 최신 상태와 동기화하기 위해 보류 중인 마이그레이션이 실행되며, [Omarchy Arch Mirror](https://github.com/omacom-io/omarchy-mirror)와 [AUR](https://aur.archlinux.org/)(AUR 패키지를 설치한 적이 있는 경우)에서 모든 시스템 패키지가 업데이트됩니다.

새 릴리스가 나오면 시계 오른쪽에 원형 화살표 아이콘이 나타납니다. 이를 클릭하면 업데이트 프로세스가 시작됩니다.

![update-available](images/update-available.webp)

### 네 가지 채널

Omarchy는 stable, RC, edge, dev 네 가지 채널을 따라 업데이트됩니다. 새 설치는 stable 채널에서 시작합니다. 이 채널은 [공식 릴리스](https://github.com/omacom/omarchy/releases/)와, 최신보다 한 달 뒤처져 운영되는 [stable Omarchy Arch mirror](https://github.com/omacom-io/omarchy-mirror)를 추적합니다. 덕분에 구성 변경이 필요한 새로운 비호환성이 사람들에게 문제를 일으키기 전에 잡아낼 수 있습니다.

하지만 그런 잠재적 문제를 찾아내는 데 도움을 주고 싶다면 edge 채널을 실행할 수 있습니다. 그러면 Omarchy 패키지가 최신 개발 빌드를 추적하고, 최신 Arch 패키지를 사용할 수 있게 되는 즉시 업데이트할 수 있습니다. Linux에 익숙하고, 문제가 생긴 시스템을 복구하는 방법을 아는 경우에만 이렇게 하세요.

새로운 메이저 릴리스가 나오기 전에는 RC 채널을 사용해 최종 검증을 진행합니다. 최종 다듬질에 도움을 주고 싶다면 Discord의 #omarchy-release-candidates에 놀러 오세요.

마지막으로 dev 채널이 있습니다. 이는 Omarchy를 `~/omarchy`에 있는 소스 코드의 git 체크아웃에 직접 연결하고, edge 패키지와 결합합니다. 숙련된 Linux 사용자이고, Omarchy를 직접 개발하고 있으며, 고장도 감수할 의향이 있는 경우에만 이 채널을 사용하세요.

Omarchy 메뉴의 _Update > Channel_을 사용해(또는 터미널에서 `omarchy-channel-set`으로) 채널을 전환할 수 있습니다.

### 커널 전환

Omarchy는 자체 `linux-omarchy` 커널로 부팅하지만, 스톡 Arch `linux` 커널이나 테스트 중인 실험적 빌드처럼 다른 커널을 그 옆에 설치해 둘 수도 있습니다. 커널이 두 개 이상 있으면 Omarchy 메뉴의 _Update > Kernel_에 커널 목록이 표시되며, 기본으로 부팅되는 커널 옆에는 체크 표시가 붙습니다. 다른 커널을 선택하고 비밀번호를 한 번 입력하면 다음 재시작 후 그 커널로 부팅됩니다. 다른 커널은 부팅 메뉴에 그대로 남아 있으므로, 새 기본값에 문제가 생기면 수동으로 하나를 선택할 수도 있습니다. 터미널에서는 현재 기본값을 보려면 `omarchy-kernel`, 설치된 커널을 보려면 `omarchy-kernel list`, 전환하려면 `omarchy-kernel set <kernel>`을 사용합니다.

### 펌웨어 업데이트

패키지만 오래되는 것은 아닙니다. 많은 노트북과 주변기기는 Linux Vendor Firmware Service를 통해 BIOS, SSD, 독 펌웨어를 제공하며, Omarchy 메뉴의 _Update > Firmware_가 하드웨어에 대기 중인 펌웨어를 가져와 설치합니다. 처음 실행할 때 `fwupd`를 설치합니다. 많은 펌웨어는 재부팅 중에만 쓸 수 있으니, 재부팅하라는 요청을 받아도 놀라지 마세요.

### 직접 pacman/yay 업데이트에 대한 경고

Arch에 이미 익숙하다면 직접 `pacman -Syu`나 `yay -Syu`를 실행하고 싶은 유혹이 들 수 있지만, 그렇게 하면 Omarchy가 새 패키지와 함께 실행하는 스냅샷, 마이그레이션, 구성 업데이트를 놓치게 됩니다. 그래서 Omarchy는 실제로 직접 시스템 업그레이드를 중단하고 대신 `omarchy update`를 사용하라고 안내합니다. (정말로 자신이 무엇을 하고 있는지 안다면, 가드가 단일 트랜잭션에 대해 이를 우회하는 방법을 알려줄 것입니다.)

### 잘못된 업데이트 롤백하기

업데이트 후 문제가 생기면 업데이트 전에 찍은 스냅샷으로 시스템을 롤백할 수 있습니다. 그냥 재시작하고 부팅 로딩 메뉴에서 업데이트를 시작하기 전의 스냅샷을 선택하세요.

![bootloader](images/bootloader.webp)

어떤 이유로든 구성 파일이 손상되었다면 터미널에서 `omarchy reinstall`을 사용해 Omarchy를 재설치할 수도 있습니다. 그러면 모든 기본 Omarchy 패키지가 재설치되고, stable로 전환되며, 너무 새로운 패키지는 다운그레이드되고, 모든 구성 파일이 초기화됩니다. 이렇게 하면 Omarchy 기본값에 대한 모든 사용자 구성 변경 사항이 덮어씌워진다는 점에 유의하세요!
