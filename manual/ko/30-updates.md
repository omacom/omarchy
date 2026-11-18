# 업데이트

Omarchy와 설치된 패키지는 Omarchy 메뉴(`Super + Space`)의 _업데이트 > Omarchy_를 통해 최신 상태로 유지됩니다.

Omarchy 자체는 [Omarchy 패키지 저장소](https://github.com/omacom-io/omarchy-pkgs)에서 일반 pacman 패키지로 설치되므로, 업데이트를 하면 [최신 Omarchy 릴리스](https://github.com/omacom/omarchy/releases)가 설치되고, 보류 중인 마이그레이션을 모두 실행해 시스템을 최신 상태와 동기화하며, [Omarchy Arch 미러](https://github.com/omacom-io/omarchy-mirror)와 [AUR](https://aur.archlinux.org/)(AUR 패키지를 설치한 경우)에서 모든 시스템 패키지를 업데이트합니다.

새 릴리스가 나오면 시계 오른쪽에 원형 화살표 아이콘이 나타납니다. 그 아이콘을 클릭하면 업데이트 과정이 시작됩니다.

![update-available](images/update-available.webp)

### 네 가지 채널

Omarchy는 stable, RC, edge, dev의 네 가지 채널을 통해 업데이트됩니다. 새로 설치하면 [공식 릴리스](https://github.com/omacom/omarchy/releases/)와, 최신보다 한 달 뒤처져 있어 설정 변경이 필요한 새로운 비호환성이 사람들에게 문제를 일으키기 전에 미리 잡아낼 수 있는 [stable Omarchy Arch 미러](https://github.com/omacom-io/omarchy-mirror)를 추적하는 stable 채널에서 시작합니다.

하지만 그런 잠재적 문제를 찾아내는 데 도움을 주고 싶다면 edge 채널을 사용할 수 있습니다. 그러면 Omarchy 패키지가 최신 개발 빌드를 추적하게 되고, 최신 Arch 패키지가 나오자마자 업데이트할 수 있게 됩니다. Linux 경험이 풍부하고 문제가 생긴 시스템을 복구하는 방법을 아는 경우에만 이렇게 하세요.

새로운 주요 릴리스가 나오기 전에는 RC 채널을 사용해 최종 검증을 진행하겠습니다. 최종 다듬질에 도움을 주고 싶다면 Discord의 #omarchy-release-candidates에 와서 함께해 주세요.

마지막으로 dev 채널은 Omarchy를 `~/omarchy`에 있는 소스 코드 git 체크아웃에 직접 연결하고 edge 패키지와 결합합니다. Linux 경험이 풍부하고, Omarchy를 직접 개발하며, 고장이 나도 감수할 의향이 있는 경우에만 이 채널을 사용하세요.

채널은 Omarchy 메뉴의 _업데이트 > 채널_을 사용해(또는 터미널에서 `omarchy-channel-set`을 사용해) 전환할 수 있습니다.

### 커널 전환

Omarchy는 자체 `linux-omarchy` 커널로 부팅하지만, 기본 Arch `linux` 커널이나 테스트 중인 실험 빌드 같은 다른 커널을 그 옆에 함께 설치해 둘 수도 있습니다. 커널이 두 개 이상 있으면 Omarchy 메뉴의 _업데이트 > 커널_에 커널 목록이 표시되며, 기본으로 부팅되는 커널 옆에는 체크 표시가 붙습니다. 다른 커널을 선택하고 비밀번호를 한 번 입력하면 다음 재시작 후 해당 커널로 부팅됩니다. 다른 커널은 부팅 메뉴에 그대로 남아 있으므로, 새 기본 커널에 문제가 생기면 직접 골라서 부팅할 수도 있습니다. 터미널에서는 현재 기본값을 보려면 `omarchy-kernel`을, 설치된 커널을 보려면 `omarchy-kernel list`를, 전환하려면 `omarchy-kernel set <kernel>`을 사용합니다.

### 펌웨어 업데이트

오래되어 뒤처지는 것은 패키지만이 아닙니다. 많은 노트북과 주변 기기가 Linux Vendor Firmware Service를 통해 BIOS, SSD, 독 펌웨어를 제공하며, Omarchy 메뉴의 _업데이트 > 펌웨어_를 사용하면 하드웨어가 기다리고 있는 업데이트를 모두 가져와 설치합니다. 처음 실행하면 `fwupd`가 설치됩니다. 많은 펌웨어는 재부팅 중에만 쓸 수 있으므로, 재부팅을 요구받아도 놀라지 마세요.

BIOS 자체의 설정을 변경해야 할 때는 시스템 메뉴(`Super + Escape`)에서 `Alt`를 누르고 있으면 _재시작_이 _BIOS로 재시작_으로 바뀌며, 부팅 시점에 맞는 키를 눌러야 할 필요 없이 펌웨어 설정으로 바로 재시작합니다. 터미널에서는 `omarchy system firmware`를 사용합니다.

### pacman/yay 직접 업데이트에 대한 경고

이미 Arch에 익숙하다면 직접 `pacman -Syu`나 `yay -Syu`를 실행하고 싶을 수도 있지만, 그렇게 하면 Omarchy가 새 패키지와 함께 실행하는 스냅샷, 마이그레이션, 설정 업데이트를 놓치게 됩니다. 그래서 Omarchy는 실제로 직접 시스템 업그레이드를 중단시키고 대신 `omarchy update`를 사용하라고 안내합니다. (정말로 무엇을 하는지 알고 있다면, 이 보호 장치가 단일 트랜잭션에 한해 이를 우회하는 방법을 알려줄 것입니다.)

### 문제가 생긴 업데이트 롤백하기

업데이트 후 문제가 발생한 적이 있다면, 업데이트 전에 찍은 스냅샷으로 시스템을 롤백할 수 있습니다. 재시작한 다음 업데이트를 시작하기 전의 부팅 로딩 메뉴에서 해당 스냅샷을 선택하기만 하면 됩니다.

![bootloader](images/bootloader.webp)

설정 파일이 somehow 손상된 경우에는 터미널에서 `omarchy reinstall`을 사용해 Omarchy를 다시 설치할 수도 있습니다. 이렇게 하면 모든 기본 Omarchy 패키지가 다시 설치되고, stable 채널로 되돌아가며, 너무 새로운 패키지는 다운그레이드되고, 모든 설정 파일이 초기화됩니다. 이렇게 하면 Omarchy 기본값에 대한 모든 사용자 설정 변경 사항이 덮어써지니 유의하세요!
