# 시작하기

Omarchy는 ISO를 사용해 설치합니다. 전체 드라이브를 차지하는 전체 디스크 설치와, 드라이브의 할당되지 않은 공간에 Omarchy를 설치하는 여유 공간 설치 중에서 선택할 수 있습니다 — 여유 공간 설치가 Windows나 다른 OS와 함께 듀얼 부팅하는 방법입니다([이중 부팅 설치](50-dual-boot-install.md) 참조 — 먼저 Windows에서 BitLocker를 꺼야 합니다). 어느 경우든 설치는 기본적으로 전체 암호화를 사용하며, 전체 디스크 옵션은 선택한 드라이브를 지우므로, 기존 드라이브를 사용하기 전에 반드시 백업하세요!

먼저 [Omarchy ISO 다운로드](https://omarchy.org/)를 받아 USB 스틱에 넣고(Windows에서는 [Rufus](https://rufus.ie/), Mac에서는 [balenaEtcher](https://etcher.balena.io/), Linux에서는 [caligula](https://github.com/ifd3f/caligula)를 사용하세요), 해당 스틱으로 부팅하세요.

_BIOS에서 Secure Boot 및/또는 TPM을 꺼야 합니다. Omarchy를 설치하려면 이들을 꺼야 합니다. 이들은 Windows와 Microsoft 계열 Linux 배포판을 위한 Microsoft 보안 체계입니다._

그런 다음 구성 질문에 답하고, 다음과 같이 확인하세요:

 ![install-config](images/install-config.webp)

그런 다음 설치할 드라이브를 선택하고, 설치 쇼를 편안히 지켜보세요. 가장 빠른 최신 컴퓨터에서는 1분도 안 걸려 완료될 수 있지만, 오래된 컴퓨터에서도 5분 이상 걸리지는 않을 것입니다.

 ![install-done](images/install-done.webp)

이제 Omarchy를 즐길 준비가 되었습니다!

### 유선 또는 2.4ghz 키보드를 사용하세요!

전체 디스크 암호화 때문에 시작 시 Bluetooth 키보드로는 비밀번호를 입력할 수 없습니다. PC에서 Bluetooth 키보드로 BIOS에 들어갈 수 없는 것과 마찬가지입니다. 2.4ghz 동글을 사용하거나 케이블로 연결하는 키보드가 필요합니다(어차피 지연 시간 면에서 케이블이 훨씬 낫습니다!). 저는 개인적으로 [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)를 정말 좋아합니다!

### 다른 소유자를 위해 설치하기

가족, 신규 직원, 구매자 등 다른 사람을 위해 컴퓨터를 설정하는 경우, 그 사람을 대신해 개인적인 질문에 답해서는 안 됩니다. 설치 프로그램의 첫 번째 화면(키보드 선택)에서 `Ctrl + C`를 누르면 Omarchy가 대신 다른 소유자를 위해 컴퓨터를 준비할 것을 제안합니다. 시스템은 즉시 설치되지만, 키보드 레이아웃, 사용자 이름, 비밀번호 등 모든 개인 설정은 컴퓨터가 처음 부팅될 때까지 미뤄집니다. 드라이브는 여전히 기본적으로 암호화되며, 새 소유자가 첫 부팅 시 선택하는 비밀번호가 암호화 비밀번호도 됩니다. (이미 사용 중인 컴퓨터도 재설치 없이 넘길 수 있습니다 — [컴퓨터 재설정](48-security.md) 참조.)

### 무인 설치

ISO는 두 번째 드라이브에 구성이 제공되면 키보드도, 마법사도 없이 완전히 스스로 설치할 수도 있습니다. 이것이 Omarchy를 VMs와 플릿 컴퓨터용 기본 이미지로 다루는 방법입니다. [무인 설치](51-unattended-installs.md)를 참조하세요.

### 암호화 없는 설치

Omarchy는 기본적으로 암호화되어 설치됩니다. 분실하거나 도난당할 수 있는 모든 컴퓨터에 대해 안전하고 책임 있는 선택입니다. 하드웨어에 접근할 수 있는 사람이 내 데이터를 가져갈 수 있게 하고 싶지는 않을 것입니다!

하지만 보호된 컴퓨터에 Omarchy를 원격으로 설치하거나 민감한 데이터가 없는 일회용 설치와 같은 특수한 상황에서는 암호화 없이 설치하고 싶을 수 있습니다. 디스크 포맷 확인 화면에서 `Ctrl + C`를 누르면 암호화 없는 설치로 전환할 수 있습니다.

### 언어

Omarchy는 omarchy.org와 동일한 50개 언어를 지원하며, 기본값은 영어입니다. 전환하려면 Omarchy 메뉴를 열고 _설정 > 언어_로 이동하거나, 터미널에서 `omarchy language <code>`를 실행하세요(`omarchy language list`는 코드 목록을 보여줍니다). 메뉴, 데스크톱, Omarchy 자체 알림은 즉시 언어가 바뀌며, 이후에 여는 모든 애플리케이션도 마찬가지입니다. 이미 열려 있던 앱은 다시 시작하면 전환됩니다.

### 막혔을 때 도움받기

막히면 [커뮤니티 Discord](https://omarchy.org/discord)의 _#omarchy-help_ 채널에서 보통 도와줄 사람을 찾을 수 있습니다.
