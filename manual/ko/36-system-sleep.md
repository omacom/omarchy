# 시스템 절전

Omarchy는 기본적으로 절전 모드를 활성화하고, 설정이 완료되면 최대 절전 모드도 활성화하지만, 사용 중인 기기에서 둘 중 하나라도 문제가 있다면 이를 껐다 켤 수 있습니다.

DGX Spark와 ASUS Ascent GX10 같은 NVIDIA GB10 기기에서는 NVIDIA의 DGX OS에서처럼 절전 모드와 최대 절전 모드가 꺼져 있습니다. 해당 하드웨어에서는 절전이 아직 제대로 작동하는 것이 확인되지 않았기 때문입니다. ASUS Zenbook A16 (UX3607OA)도 마찬가지입니다. 절전 모드가 아직 칩을 완전히 절전 상태로 만들지 못해 밤새 멈춰 버릴 수 있습니다. 절전 토글과 최대 절전 모드 설정은 거기에는 적용되지 않습니다. 절전을 다시 켜려면 `sudo rm`으로 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`를 제거하세요. 그러면 절전이 메뉴에 다시 나타나고, 다른 기기에서처럼 최대 절전 모드를 설정할 수 있습니다. `sudo omarchy apply hardware --install-user "$USER"`를 실행하면 파일이 다시 생깁니다.

### 전원 프로필

노트북에서는 Omarchy가 전원에 연결된 상태와 배터리로 실행 중인 상태의 전원 프로필을 따로 기억하고, 플러그를 꽂고 뽑을 때 둘 사이를 전환합니다. 기본 상태에서는 AC 전원에서는 성능 모드, 배터리에서는 균형 모드를 사용합니다.

`omarchy powerprofiles list`로 사용 중인 기기가 제공하는 프로필을 확인할 수 있고, `omarchy powerprofiles set autodetect power-saver`로 현재 상태에 원하는 프로필을 설정할 수 있습니다. 아무것도 뽑지 않고 다른 상태의 프로필을 설정하려면 직접 이름을 지정하세요: `omarchy powerprofiles set battery power-saver`. 무엇을 선택하든 다음에 그 상태가 되면 그 프로필이 다시 적용됩니다.

### 절전 모드 토글

터미널에서 `omarchy toggle suspend`를 실행해 절전 모드를 토글합니다. 이는 그저 _시스템_ (또는 `Super + Esc`) 아래의 옵션을 표시/숨기기만 하며, 그런 다음 시스템에서 일관되게 작동하는지 확인할 수 있습니다. 그렇지 않다면 같은 명령으로 다시 숨길 수 있습니다.

### 최대 절전 모드 토글

터미널에서 `omarchy hibernation setup`을 실행해 최대 절전 모드를 설정합니다 (Apple Silicon Mac에서는 사용할 수 없습니다). 최대 절전 모드는 물리적 RAM 할당 크기만큼 부팅 드라이브에 /swap 하위 볼륨을 생성하므로, 여유 공간이 충분한지 확인하세요. 32GB 기기에서는 이 볼륨을 위해 항상 32GB 이상의 여유 공간이 필요합니다. 최대 절전 모드에는 기본 Limine 부트로더도 필요합니다.

설정이 완료되면 _시스템_ (또는 `Super + Esc`) 아래에 최대 절전 옵션이 표시되며, 그런 다음 시스템에서 일관되게 작동하는지 확인할 수 있습니다. 그렇지 않다면 `omarchy hibernation remove`를 실행해 다시 제거할 수 있습니다.
