# 무인 설치

Omarchy ISO는 키보드 앞에 아무도 없이 스스로 설치할 수 있습니다. 설치 프로그램이 설정 파일을 담고 있는 `cidata`라는 레이블의 두 번째 드라이브를 발견하면 이를 복사하고, 설치 마법사를 완전히 건너뛰고, 스스로 완성된 시스템으로 재부팅합니다. 특별한 ISO 빌드도, 추가 부팅 메뉴 항목도 없습니다 — 그런 드라이브가 연결되어 있지 않으면 아무것도 바뀌지 않고 일반적인 마법사를 보게 됩니다.

이 덕분에 Omarchy는 쓰고 버리는 개발 환경의 기본 이미지로 훌륭합니다: Proxmox나 Packer로 VM을 만들고 부팅해 자리를 떠나면 SSH로 접속할 수 있습니다. `cidata`는 cloud-init의 `NoCloud` 레이블이므로, 흔한 가상화 도구는 모두 그런 드라이브를 연결하는 법을 이미 알고 있습니다.

## 설정 파일

파일은 설치 프로그램 자체 마법사가 작성하는 것과 정확히 같으므로, 시작 파일 집합을 얻는 가장 쉬운 방법은 대화형 설치를 한 번 실행하고(예: VM에서) `/root`에 쓴 것을 복사하는 것입니다:

| 파일 | 필수 | 목적 |
|------|----------|---------|
| `user_configuration.json` | 예 | 디스크, 호스트 이름, 시간대, 키보드 |
| `user_credentials.json` | 예 | 사용자 이름과 비밀번호 해시 |
| `user_full_name.txt` | 아니오 | Git 전체 이름 |
| `user_email_address.txt` | 아니오 | Git 이메일 |
| `user_encrypt_installation.txt` | 아니오 | 설정에 `disk_encryption` 블록이 있을 때 `true` |
| `authorized_keys` | 아니오 | SSH 공개 키, 한 줄에 하나씩 |
| `tailscale_authkey` | 아니오 | 첫 부팅에서 tailnet에 참여하기 위한 Tailscale 인증 키 |

`openssl passwd -6 "yourpassword"`로 `user_credentials.json`용 비밀번호 해시를 생성하세요.

`user_credentials.json` 대신 `defer-provisioning`이라는 빈 파일을 넣을 수도 있습니다. 그러면 대화형으로 실행할 수도 있는 [다른 소유자를 위해 준비하는 설치](02-getting-started.md)와 같은 과정이 실행됩니다: 컴퓨터는 개인 정보 없이 설치되고, 처음 부팅하는 사람이 키보드를 고르고 사용자를 만듭니다. 이는 드라이브가 누구의 자격 증명도 담아서는 안 되는 이미징 장비용 모드입니다.

## SSH 접근

`authorized_keys`가 있으면 설치는 이 키들을 사용자의 `~/.ssh/authorized_keys`로 설정하고, `sshd`를 활성화하며, 방화벽을 엽니다. (기본 Omarchy 설치는 서비스가 비활성화되고 포트가 닫힌 채로 openssh를 제공하므로, 무인 컴퓨터에 닿을 수 없게 됩니다.) 설치는 키를 추가할 뿐입니다 — SSH 데몬의 다른 인증 설정을 완화하지는 않습니다.

`tailscale_authkey`가 있으면 컴퓨터는 대신 첫 부팅에서 tailnet에 참여합니다: Tailscale은 ISO의 번들 패키지에서 설치되고, 방화벽은 tailnet 인터페이스를 허용하며, 컴퓨터가 실제로 네트워크를 갖추는 즉시 백그라운드 작업이 참여를 실행하고 성공할 때까지 재시도합니다. 하나의 드라이브 이미지가 많은 컴퓨터에 쓰일 수 있도록 재사용 가능하고 사전 승인된 키를 사용하세요.

## cidata 드라이브 구축하기

올바른 레이블을 가진 파일시스템이라면 무엇이든 됩니다. 작은 ISO가 쉬운 방법입니다:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

그런 다음 Omarchy ISO와 나란히 VM에 연결하세요. 전체 Proxmox 예시는 다음과 같습니다:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

부팅 순서에서 디스크를 일부러 먼저 나열했습니다: 빈 디스크는 첫 부팅에서 ISO로 넘어가고, 설치된 시스템은 그 이후로 늘 디스크에서 부팅합니다.

## 두 가지 주의 사항

암호화된 무인 설치는 완전히 무인이 아닙니다 — 누군가 첫 부팅에서 LUKS 암호 문구를 입력해야 합니다. 그리고 `user_configuration.json`의 `disk_encryption` 블록은 그 암호 문구를 평문으로 담고 있으므로, 암호화된 설치로 만든 cidata 드라이브는 비밀인 대로 취급하세요.
