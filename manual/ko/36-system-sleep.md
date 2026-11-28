# 시스템 절전

Omarchy는 기본적으로 일시 중단을 활성화하고, 최대 절전 모드는 설정이 완료되면 활성화하지만, 사용 중인 기기에서 둘 중 하나에 문제가 있다면 비활성화할 수 있습니다.

DGX Spark 및 ASUS Ascent GX10과 같은 NVIDIA GB10 기기에서는 NVIDIA의 DGX OS에서와 마찬가지로 일시 중단과 최대 절전 모드가 꺼져 있습니다. 해당 하드웨어에서는 절전이 아직 제대로 작동하는 것으로 확인되지 않았기 때문입니다. 일시 중단 토글과 최대 절전 모드 설정은 거기에 적용되지 않습니다. 절전을 다시 켜려면 `sudo rm`으로 `/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf`를 삭제하세요. 그러면 Suspend가 메뉴에 다시 나타나고, 다른 기기에서와 마찬가지로 최대 절전 모드를 설정할 수 있습니다. `sudo omarchy apply hardware --install-user "$USER"`를 실행하면 파일이 다시 생성됩니다.

### 전원 프로필

노트북에서는 Omarchy가 전원을 연결했을 때와 배터리로 실행 중일 때의 전원 프로필을 따로 기억하고, 전원을 연결하거나 분리할 때 두 프로필 사이를 전환합니다. 기본적으로는 AC 전원에서는 performance, 배터리에서는 balanced를 사용합니다.

사용 중인 기기에서 제공하는 항목은 `omarchy powerprofiles list`로 확인할 수 있고, 현재 상태에 원하는 항목은 `omarchy powerprofiles set autodetect power-saver`로 설정할 수 있습니다. 아무것도 분리하지 않고 다른 상태를 설정하려면 직접 이름을 지정하세요: `omarchy powerprofiles set battery power-saver`. 어떤 항목을 선택하든 다음에 해당 상태가 되었을 때 그 항목이 다시 적용됩니다.

### 일시 중단 토글

터미널에서 `omarchy toggle suspend`를 실행해 일시 중단을 토글합니다. 이는 _System_ (또는 `Super + Esc`) 아래의 옵션을 표시하거나 숨길 뿐이며, 이후 시스템에서 일관되게 작동하는지 확인할 수 있습니다. 작동하지 않으면 같은 명령으로 다시 숨길 수 있습니다.

### 최대 절전 모드 토글

터미널에서 `omarchy hibernation setup`를 실행해 최대 절전 모드를 설정합니다(Apple Silicon Mac에서는 사용할 수 없습니다). 최대 절전 모드는 부팅 드라이브에 실제 RAM 용량과 같은 크기의 /swap 서브볼륨을 생성하므로, 여유 공간이 충분한지 확인하세요. 32GB 기기에서는 이 볼륨을 위해 항상 32GB 이상의 여유 공간이 필요합니다. 최대 절전 모드에는 기본 Limine 부트로더도 필요합니다.

설정이 완료되면 _System_ (또는 `Super + Esc`) 아래에 최대 절전 모드 옵션이 표시되며, 이후 시스템에서 일관되게 작동하는지 확인할 수 있습니다. 작동하지 않으면 `omarchy hibernation remove`를 실행해 다시 제거할 수 있습니다.
