# 시스템 스냅샷

모든 Omarchy 업데이트마다 스냅샷을 자동으로 생성하지만, 직접 만들고 싶다면 `omarchy-snapshot create`를 사용할 수 있습니다.

스냅샷으로 부팅하고 복원하는 방법은 컴퓨터가 시작할 때 사용하는 부트 로더에 따라 다릅니다. 새 UEFI 설치는 systemd-boot를 사용하고, 이전 설치와 BIOS 컴퓨터는 Limine을 사용합니다. `omarchy-boot-backend`를 실행하면 어떤 것을 사용 중인지 알 수 있습니다.

## systemd-boot를 사용하는 경우

Omarchy 메뉴에서 _System > Snapshots_를 선택하고 부팅할 스냅샷을 고르세요. 컴퓨터가 해당 스냅샷으로 한 번 재시작합니다. 또는 컴퓨터가 시작될 때 Space를 길게 누르면 부팅 메뉴가 나타나며, 모든 스냅샷이 Omarchy 버전과 날짜와 함께 최신순으로 나열됩니다.

스냅샷은 위에 임시 레이어가 얹힌 상태로 부팅되므로 평소와 똑같이 사용할 수 있지만, 변경한 내용은 다음 재부팅 때 모두 사라집니다. 유지하려면 이를 내 시스템으로 만드세요: 로그인할 때 나타나는 알림을 클릭하거나, _System > Snapshots > Restore This Snapshot_를 선택하거나, `omarchy-snapshot restore`를 실행하세요. 복원은 컴퓨터가 재시작되는 동안 이루어집니다. 이전 상태의 시스템은 부팅 메뉴에 _Before restore_로 남아 있으며, `omarchy-snapshot restore backup`을 실행하면 되돌릴 수 있습니다.

터미널에서:

- `omarchy-snapshot list`는 부팅할 수 있는 스냅샷을 나열합니다;
- `omarchy-snapshot boot 12`는 스냅샷 12로 한 번 재시작합니다;
- `omarchy-snapshot restore 12`는 다음 재시작 때 스냅샷 12를 시스템으로 만들며, `omarchy-snapshot restore --cancel`은 그 재시작 전에 마음을 바꿀 수 있게 해줍니다.

## Limine을 사용하는 경우

스냅샷으로 부팅하고 복원하려면 Limine 부트 로더에서 해당 스냅샷을 선택합니다. 부팅 메뉴는 기본적으로 숨겨져 있으므로, Limine이 시작되자마자 아무 키나 눌러 메뉴를 불러오세요.

그 화면에서 날짜와 버전을 기준으로 부팅할 스냅샷을 선택하세요. 스냅샷 당시의 Omarchy 버전은 왼쪽 하단 모서리에서 확인할 수 있습니다.

 ![snapshots-bootloader](images/snapshots-bootloader.webp)

안에 들어오면 부팅 가능한 스냅샷 안에 있다는 알림이 팝업으로 뜨며, 클릭하면 복원 과정이 시작됩니다. 또는 `omarchy-snapshot restore`를 사용할 수도 있습니다.

 ![snapshots-restore](images/snapshots-restore.webp)

## 복원이 적용되는 범위

복원은 루트 파일시스템을 되돌리지만 `/home`은 되돌리지 않습니다. 따라서 망가진 시스템 업데이트를 되돌리는 데는 쓸 수 있지만, 잃어버린 개인 파일을 복구하는 데는 쓸 수 없습니다.

이는 `~/.config` 디렉터리도 그대로 유지된다는 뜻이기도 합니다. 따라서 설정 파일을 새 형식으로 저장하는 라이브러리나 애플리케이션의 이전 버전으로 롤백한다면, 그 문제는 직접 해결해야 합니다.

이미 실행된 마이그레이션을 기록한 Omarchy 자체 기록도 마찬가지입니다: 이 기록은 홈 디렉터리에 있으므로 복원 후에도 살아남습니다. 스냅샷이 생성된 뒤에 실행된 마이그레이션은 루트 파일시스템에 가한 변경이 롤백되었음에도 완료된 것으로 표시된 채로 남으며, 다음 `omarchy update`는 이를 다시 실행하지 않습니다. 따라서 복원 후 다시 업데이트했는데 이전 업데이트가 설정해 두었어야 할 무언가가 여전히 없다면, 그게 이유일 가능성이 큽니다.
